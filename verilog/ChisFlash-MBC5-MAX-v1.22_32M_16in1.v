`timescale 1ns / 1ps

// Game Boy interface (inputs from the host)
input [15:0] GB_A,      // A0-A15, Cartridge pin6-21. A0-A14 used for address, A15 used for ROM_CS (active low)
input [7:0]  GB_D,      // D0-D7, Cartridge pin22-29
input        GB_CS,     // CS (Chip Select), Cartridge pin5
input        nGB_WR,    // WR (Write Enable, active low), Cartridge pin3
input        GB_RD,     // RD (Read Enable), Cartridge pin4
input        GB_CLK,    // CLK (Clock), Cartridge pin2

// RAM & ROM interface (outputs to chips)
output       GB_RST,    // RST (Reset), Cartridge pin30 (output from cartridge to host)
output [24:14] ROM_A,   // ROM_A14-A24, ROM's PIN A13-A21 (extra bits A23-A24 for bank switching)
output [18:13] RAM_A,   // RAM_A13-A18, RAM's PIN A13-A18
output       nROM_CS,   // ROM CE# (Chip Enable, active low)
output       nRAM_CS    // RAM CE1# (Chip Enable 1, active low)

);

// Internal oscillator signals
wire oscena_sig = 1'b1;
wire osc_sig;

// Instantiate internal oscillator
OSC OSC_inst (
    .oscena ( oscena_sig ),
    .osc ( osc_sig )
);

// Reset control
reg nRST_reg = 1'b1;
assign GB_RST = nRST_reg;  // Default high (inactive)
reg [15:0] rst_counter;    // 10ms counter for reset timing
reg rst_active;            // Reset activation flag
reg gamestart_flag = 1'b0; // Game start flag

// MBC5 bank registers
reg [10:0] rom_bank = 11'b00000000001; // ROM bank (11 bits, default=1)
reg [6:0] ram_bank = 7'b0;             // RAM bank (7 bits, default=0)
reg ram_en = 1'b0;                     // RAM enable flag (default disabled)
reg game_sel_en = 1'b0;                // Multi-game selection enable
reg [3:0] game_sel;                    // Game selection index (4 bits = 16 games)

/* Address range decoding for ROM and RAM */
wire [15:0] gb_addr;                   // GB 16-bit address bus
assign gb_addr[15:12] = GB_A[15:12];   // Upper 4 address bits
assign gb_addr[11:0] = 12'b0;          // Lower 12 bits zero (MBC only cares about high bits)

wire rom_addr_en;                      // ROM address range (0x0000-0x7FFF)
assign rom_addr_en = (gb_addr >= 16'h0000) && (gb_addr <= 16'h7FFF);

wire ram_addr_en;                      // RAM address range (0xA000-0xBFFF)
assign ram_addr_en = (gb_addr >= 16'hA000) && (gb_addr <= 16'hBFFF);

wire rom_addr_lo;                      // Lower ROM area (0x0000-0x3FFF)
assign rom_addr_lo = (gb_addr >= 16'h0000) && (gb_addr <= 16'h3FFF);

// ROM chip select (active low)
assign nROM_CS = (rom_addr_en) ? 1'b0 : 1'b1;

// RAM chip select (active low, enabled when RAM enabled and multi-game mode not active)
assign nRAM_CS = ((ram_addr_en) && (ram_en) && (ram_bank[6] == 1'b0)) ? 1'b0 : 1'b1;

/* Bank selection logic */
wire [10:0] rom_a_pre;                 // Pre-mapped ROM bank address
assign rom_a_pre[10:0] = rom_addr_lo ? 11'b0 : rom_bank[10:0]; // Bank 0 for lower ROM

wire [5:0] ram_a_pre;                  // Pre-mapped RAM bank address
assign ram_a_pre[5:0] = ram_bank[5:0]; // Direct RAM bank mapping

/* ROM address mapping */
assign ROM_A[24:21] = (game_sel_en) ? (game_sel[3:0]) : (rom_a_pre[10:7]); // Upper bits
assign ROM_A[20] = ((game_sel_en) && (game_sel[3:0] == 4'b0000)) ? (1'b1) : (rom_a_pre[6]); // Special case for game 0
assign ROM_A[19:14] = rom_a_pre[5:0];  // Lower bits

/* RAM address mapping */
assign RAM_A[18:15] = (game_sel_en) ? (game_sel[3:0]) : (ram_a_pre[5:2]); // Upper bits
assign RAM_A[14:13] = ram_a_pre[1:0];  // Lower bits

///////////////////////////////// MBC5 Behavior Simulation /////////////////////////////
//
// MBC5 write registers (all triggered on falling edge of write enable):
// 0x0000-0x1FFF: Enable/disable RAM (write 0x0A to enable, anything else to disable)
// 0x2000-0x2FFF: Set lower 8 bits of ROM bank
// 0x3000-0x3FFF: Set bit 9 of ROM bank (using D0 only)
// 0x4000-0x5FFF: Set RAM bank number (lower 6 bits, bit 6 for multi-game mode)
// 0x6000-0x7FFF: Mode setting (not used in MBC5)

// Clock signals for each register write
wire rom_bank_lo_clk;                  // ROM bank lower bits write clock
assign rom_bank_lo_clk = (!nGB_WR) && (gb_addr == 16'h2000);

wire rom_bank_hi_clk;                  // ROM bank bit 9 write clock
assign rom_bank_hi_clk = (!nGB_WR) && (gb_addr == 16'h3000);

wire ram_bank_clk;                     // RAM bank write clock
assign ram_bank_clk = (!nGB_WR) && ((gb_addr == 16'h4000) || (gb_addr == 16'h5000));

wire ram_en_clk;                       // RAM enable write clock
assign ram_en_clk = (!nGB_WR) && ((gb_addr == 16'h0000) || (gb_addr == 16'h1000));

wire game_en_clk;                      // Multi-game enable write clock
assign game_en_clk = (!nGB_WR) && (gb_addr == 16'hA000) && (ram_bank[6] == 1'b1);

wire game_sel_clk;                     // Game selection write clock
assign game_sel_clk = (!nGB_WR) && (gb_addr == 16'hB000) && (ram_bank[6] == 1'b1);

wire rst_clk;                          // Reset trigger clock
assign rst_clk = (!nGB_WR) && (gb_addr == 16'h4000) && (ram_bank[6] == 1'b1) && (gamestart_flag == 1'b0);

/* Reset timing control for multi-game mode */
always @(posedge osc_sig) begin
    if (rst_clk && (game_sel_en == 1'b1)) begin
        rst_active <= 1'b1;            // Activate reset
        rst_counter <= 0;              // Clear counter
        nRST_reg <= 1'b0;              // Pull RST low
    end else if (rst_active && (game_sel_en == 1'b1)) begin
        if (rst_counter >= 16'd182032) begin  // Count to ~10ms at 4.194304MHz
            nRST_reg <= 1'b1;          // Restore high level
            rst_active <= 1'b0;        // End reset
            gamestart_flag <= 1'b1;    // Set game start flag
        end else begin
            rst_counter <= rst_counter + 1;  // Increment counter
        end
    end
end

/* ROM bank lower bits (0x2000) */
always @(negedge rom_bank_lo_clk) begin
    rom_bank[7:0] <= GB_D[7:0];       // Set lower 8 bits of ROM bank
end

/* ROM bank bit 9 (0x3000) */
always @(negedge rom_bank_hi_clk) begin
    rom_bank[10:8] <= GB_D[2:0];      // Set bits 8-10 of ROM bank
end

/* RAM bank selection (0x4000-0x5000) */
always @(negedge ram_bank_clk) begin
    ram_bank[5:0] <= GB_D[5:0];       // Set lower 6 bits of RAM bank
    if (!game_sel_en)
        ram_bank[6] <= GB_D[6];       // Bit 6 for multi-game mode (if not in multi-game mode)
    else
        ram_bank[6] <= 1'b0;          // Force to 0 in multi-game mode
end

/* RAM enable/disable (0x0000-0x1000) */
always @(negedge ram_en_clk) begin
    ram_en <= (GB_D[3:0] == 4'hA) ? 1 : 0;  // Enable if lower nibble is 0xA
end

/* Multi-game mode enable (0xA000 when bit 6 of ram_bank is set) */
always @(negedge game_en_clk) begin
    game_sel_en <= GB_D[0];           // Enable/disable multi-game mode
end

/* Game selection index (0xB000 when bit 6 of ram_bank is set) */
always @(negedge game_sel_clk) begin
    game_sel[3:0] <= GB_D[3:0];       // Set 4-bit game selection index
end
