`timescale 1ns / 1ps

module MBC5(
// GB interface, inputs from the host
input [15:0] GB_A,      // A0-A15, Cartridge pin6-21
input [7:0]  GB_D,      // D0-D7, Cartridge pin22-29
input        GB_CS,     // CS (Chip Select), Cartridge pin5
input        nGB_WR,    // WR (Write Enable, active low), Cartridge pin3
input        GB_RD,     // RD (Read Enable), Cartridge pin4
input        GB_CLK,    // CLK (Clock), Cartridge pin2
// input GB_AUDIO_IN,   // AIN (Audio Input), Cartridge pin31

// RAM & ROM interface, outputs to chips
output       GB_RST,    // RST (Reset), Cartridge pin30 (output from cartridge to host)
output [22:14] ROM_A,   // ROM_A14-A22, ROM's PIN A13-A21
output [16:13] RAM_A,   // RAM_A13-A16, RAM's PIN A13-A16
output       nROM_CS,   // ROM CE# (Chip Enable, active low)
output       nRAM_CS,   // RAM CE1# (Chip Enable 1, active low)
output       RAM_CS2,   // RAM CE2# (Chip Enable 2)

// Internal signals
wire oscena_sig = 1'b1; // Oscillator enable signal (active high)
wire osc_sig;           // Oscillator output signal
	 
OSC	OSC_inst (
	.oscena ( oscena_sig ),
	.osc ( osc_sig )
	);

assign RAM_CS2 =1'b1; 
reg nRST_reg = 1'b1;
assign GB_RST = nRST_reg;
reg [15:0] rst_counter;
reg rst_active;

reg [8:0] rom_bank = 9'b000000001;
reg [4:0] ram_bank = 5'b0;
reg ram_en = 1'b0;
reg game_sel_en = 1'b0;
reg [1:0] game_sel;
wire [15:0] gb_addr; 
assign gb_addr[15:12] = GB_A[15:12];
assign gb_addr[11:0] = 12'b0;
wire rom_addr_en;
assign rom_addr_en =  (gb_addr >= 16'h0000)&(gb_addr <= 16'h7FFF);
wire ram_addr_en;
assign ram_addr_en =  (gb_addr >= 16'hA000)&(gb_addr <= 16'hBFFF); 
assign rom_addr_lo =  (gb_addr >= 16'h0000)&(gb_addr <= 16'h3FFF);

assign nROM_CS = (rom_addr_en) ? 0 : 1; 
assign nRAM_CS = ((ram_addr_en) & (ram_en) & (ram_bank[4] == 1'b0)) ? 0 : 1; 

wire [22:14] rom_a_pre; 
assign rom_a_pre[22:14] = rom_addr_lo ? 9'b0 : rom_bank[8:0]; 

wire [16:13] ram_a_pre; 
assign ram_a_pre[16:13] = ram_bank[3:0]; 

reg [22:21] ROM_AB;
 always @(*) begin
	if(game_sel_en)
	  case (game_sel[1:0])
			2'b00: ROM_AB[22:21] = 2'b00; // Mode 0
			2'b01: ROM_AB[22:21] = 2'b01; // Mode 1
			2'b10: ROM_AB[22:21] = {1'b1, rom_a_pre[21]}; // Mode 2
			2'b11: ROM_AB[22:21] = 2'b11; // Mode 3
			default: ROM_AB[22:21] = 2'bxx; // 处理未定义状态
	  endcase
	else
		ROM_AB[22:21] = rom_a_pre[22:21];
 end
 assign ROM_A[22:21] = ROM_AB[22:21];
assign ROM_A[20] = ((game_sel_en)&&(game_sel[1:0] == 2'b00)) ? (1'b1) : (rom_a_pre[20]);
assign ROM_A[19:14] = rom_a_pre[19:14];  
assign RAM_A[16:15] = (game_sel_en) ? (game_sel[1:0]) : (ram_a_pre[16:15]);
assign RAM_A[14:13] = ram_a_pre[14:13];


wire rom_bank_lo_clk;
assign rom_bank_lo_clk = (!nGB_WR) & (gb_addr == 16'h2000);

wire rom_bank_hi_clk;
assign rom_bank_hi_clk = (!nGB_WR) & (gb_addr == 16'h3000); 

wire ram_bank_clk;
assign ram_bank_clk = (!nGB_WR) & ((gb_addr == 16'h4000) | (gb_addr == 16'h5000)); 

wire ram_en_clk;
assign ram_en_clk = (!nGB_WR) & ((gb_addr == 16'h0000) | (gb_addr == 16'h1000)); 

wire game_en_clk;
assign game_en_clk = (!nGB_WR) & (gb_addr == 16'hA000) & (ram_bank[4] == 1'b1);

wire game_sel_clk;
assign game_sel_clk = (!nGB_WR) & (gb_addr == 16'hB000) & (ram_bank[4] == 1'b1);

wire rst_clk;
assign rst_clk = (!nGB_WR) & (gb_addr == 16'h4000) & (ram_bank[4] == 1'b1);

always @(posedge osc_sig) begin
    if (rst_clk) begin
        rst_active <= 1'b1;   
        rst_counter <= 0;  
        nRST_reg <= 1'b0; 
    end else if (rst_active) begin
        if (rst_counter >= 16'd42016) begin 
            nRST_reg <= 1'bz; 
            rst_active <= 1'b0; 
        end else begin
            rst_counter <= rst_counter + 1; 
        end
    end
end

always@(negedge rom_bank_lo_clk)
begin
    rom_bank[7:0] <= GB_D[7:0];
end

always@(negedge rom_bank_hi_clk)
begin
    rom_bank[8] <= GB_D[0];
end

always@(negedge ram_bank_clk)
begin
    ram_bank[3:0] <= GB_D[3:0];
    if (!game_sel_en)
        ram_bank[4] <= GB_D[4];
    else
        ram_bank[4] <= 1'b0;
end

always@(negedge ram_en_clk)
begin
    ram_en <= (GB_D[3:0] == 4'hA) ? 1 : 0; //A real MBC only care about low bits
end

always@(negedge game_en_clk)
begin
   game_sel_en <= GB_D[0];
end

always@(negedge game_sel_clk)
begin
   game_sel[1:0] <= GB_D[1:0];
end

endmodule