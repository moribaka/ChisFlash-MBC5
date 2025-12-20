`timescale 1ns / 1ps

module MBC5(
    // GB Interface (inputs from console)
    input [15:0] GB_A,       // Address bus (A0-A15)
    input [7:0] GB_D,        // Data bus (D0-D7)
    input GB_CS,             // Chip select
    input nGB_WR,            // Write enable (active low)
    input GB_RD,             // Read enable
    input GB_CLK,            // Clock
    
    // RAM/ROM Interface (outputs to memory)
    inout GB_RST,            // Reset output to console
    output [24:14] ROM_A,    // ROM address (A14-A24 for 8MB)
    output [18:13] RAM_A,    // RAM address (A13-A18 for 128KB)
    output nROM_CS,          // ROM chip select (active low)
    output nRAM_CS           // RAM chip select (active low)
);

    // Internal oscillator
    wire oscena_sig = 1'b1;
    wire osc_sig;
    OSC OSC_inst (.oscena(oscena_sig), .osc(osc_sig));

    // Reset control
    reg nRST_reg = 1'b1;
    assign GB_RST = nRST_reg;
    reg [15:0] rst_counter;
    reg rst_active;
    reg gamestart_flag = 1'b0;
    
    // Memory banking registers
    reg [10:0] rom_bank = 11'b00000000001;  // Current ROM bank (0-511, default 1)
    reg [6:0] ram_bank = 7'b0;             // Current RAM bank (0-127, default 0)
    reg ram_en = 1'b0;                     // RAM enable flag
    reg game_sel_en = 1'b0;                // Multi-cart enable
    reg [3:0] game_sel;                    // Program selection (0-15)

    // Address decoding
    wire [15:0] gb_addr = {GB_A[15:12], 12'b0};  // Mask lower 12 bits
    wire rom_addr_en = (gb_addr >= 16'h0000) && (gb_addr <= 16'h7FFF);
    wire ram_addr_en = (gb_addr >= 16'hA000) && (gb_addr <= 16'hBFFF);
    wire rom_addr_lo = (gb_addr >= 16'h0000) && (gb_addr <= 16'h3FFF);
    
    // Chip select generation
    assign nROM_CS = rom_addr_en ? 0 : 1;
    assign nRAM_CS = (ram_addr_en && ram_en && (ram_bank[6] == 1'b0)) ? 0 : 1;
    
    // Bank selection logic
    wire [10:0] rom_a_pre = rom_addr_lo ? 11'b0 : rom_bank[10:0];
    wire [5:0] ram_a_pre = ram_bank[5:0];
    
    // Address output assignment
    assign ROM_A[24:21] = game_sel_en ? game_sel[3:0] : rom_a_pre[10:7];
    assign ROM_A[20] = (game_sel_en && (game_sel[3:0] == 4'b0000)) ? 1'b1 : rom_a_pre[6];
    assign ROM_A[19:14] = rom_a_pre[5:0];
    assign RAM_A[18:15] = game_sel_en ? game_sel[3:0] : ram_a_pre[5:2];
    assign RAM_A[14:13] = ram_a_pre[1:0];

    // MBC5 control signals
    wire rom_bank_lo_clk = (!nGB_WR) && (gb_addr == 16'h2000);
    wire rom_bank_hi_clk = (!nGB_WR) && (gb_addr == 16'h3000);
    wire ram_bank_clk = (!nGB_WR) && ((gb_addr == 16'h4000) || (gb_addr == 16'h5000));
    wire ram_en_clk = (!nGB_WR) && ((gb_addr == 16'h0000) || (gb_addr == 16'h1000));
    wire game_en_clk = (!nGB_WR) && (gb_addr == 16'hA000) && (ram_bank[6] == 1'b1);
    wire game_sel_clk = (!nGB_WR) && (gb_addr == 16'hB000) && (ram_bank[6] == 1'b1);
    wire rst_clk = (!nGB_WR) && (gb_addr == 16'h4000) && (ram_bank[6] == 1'b1) && (gamestart_flag == 1'b0);

    // Reset timing control (10ms reset pulse)
    always @(posedge osc_sig) begin
        if (rst_clk && game_sel_en == 1'b1) begin
            rst_active <= 1'b1;
            rst_counter <= 0;
            nRST_reg <= 1'b0;
        end else if (rst_active && game_sel_en == 1'b1) begin
            if (rst_counter >= 16'd182032) begin  // ~10ms at 4.194304MHz
                nRST_reg <= 1'b1;
                rst_active <= 1'b0;
                gamestart_flag <= 1'b1;
            end else begin
                rst_counter <= rst_counter + 1;
            end
        end
    end

    // Register control
    always @(negedge rom_bank_lo_clk) begin
        rom_bank[7:0] <= GB_D[7:0];
    end

    always @(negedge rom_bank_hi_clk) begin
        rom_bank[10:8] <= GB_D[2:0];
    end

    always @(negedge ram_bank_clk) begin
        ram_bank[5:0] <= GB_D[5:0];
        ram_bank[6] <= game_sel_en ? 1'b0 : GB_D[6];
    end

    always @(negedge ram_en_clk) begin
        ram_en <= (GB_D[3:0] == 4'hA) ? 1 : 0;
    end

    always @(negedge game_en_clk) begin
        game_sel_en <= GB_D[0];
    end

    always @(negedge game_sel_clk) begin
        game_sel[3:0] <= GB_D[3:0];
    end

endmodule
