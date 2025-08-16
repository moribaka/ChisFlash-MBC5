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

// Internal Signals
wire oscena_sig = 1'b1; // Oscillator enable signal (active high)
wire osc_sig;           // Oscillator output signal

// Instantiate oscillator module
OSC OSC_inst (
    .oscena ( oscena_sig ),
    .osc  ( osc_sig )
);

// Set RST to high by default
reg nRST_reg = 1'b1;
assign GB_RST = nRST_reg;

// Reset counter and control
reg [15:0] rst_counter;       // 10ms reset counter
reg rst_active;               // Reset activation flag

// ROM bank register (11 bits, default=1)
// Total banks = 2^11 = 2048 (0-2047), each 16KB (total 32MB)
reg [10:0] rom_bank = 11'b00000000001;

// RAM bank register (7 bits, default=0)
// - Lower 6 bits: RAM bank selection (64 banks, 8KB each)
// - Bit 6: Multi-game mode flag (0=normal, 1=multi-game)
reg [6:0] ram_bank = 7'b0;

// RAM enable flag (default=disabled)
reg ram_en = 1'b0;

// Multi-game cartridge control
reg game_sel_en = 1'b0; // Multi-game enable
reg [3:0] game_sel;     // Game selection (4 bits = 16 games)

//=====================A. Signal Wiring & Definitions ==================
//

// Full 16-bit GB address bus
wire [15:0] gb_addr;    
assign gb_addr[15:12] = GB_A[15:12]; // High 4 bits from GB_A
assign gb_addr[11:0] = 12'b0;        // Low 12 bits fixed to 0

// ROM chip select logic
wire rom_addr_en;        // ROM address range (0x0000-0x7FFF)
assign rom_addr_en = (gb_addr >= 16'h0000) && (gb_addr <= 16'h7FFF);
assign nROM_CS = (rom_addr_en) ? 1'b0 : 1'b1; // ROM CS# active low

// RAM chip select logic
wire ram_addr_en;        // RAM address range (0xA000-0xBFFF)
assign ram_addr_en = (gb_addr >= 16'hA000) && (gb_addr <= 16'hBFFF);
assign nRAM_CS = ((ram_addr_en) && ram_en && (ram_bank[6] == 1'b0)) ? 1'b0 : 1'b1;

//=====================B. MBC5 Behavior Simulation ==================
//

// 0.1 ROM Bank Mapping (MBC5)
// 0.1.1 No action if accessing ROM0 area (first 16KB)
// 0.1.2 Bank switching if accessing ROM1 area (second 16KB)
wire [10:0] rom_a_pre; // Pre-mapped ROM bank address
wire rom_addr_lo;      // Low ROM bank (0x0000-0x3FFF)
assign rom_addr_lo = (gb_addr >= 16'h0000) && (gb_addr <= 16'h3FFF);
assign rom_a_pre[10:0] = rom_addr_lo ? 11'b0 : rom_bank[10:0]; 

// ROM address mapping
assign ROM_A[24:21] = game_sel_en ? game_sel[3:0] : rom_a_pre[10:7]; // High 4 bits for multi-game
assign ROM_A[20] = (game_sel_en && (game_sel[3:0] == 4'b0000)) ? 1'b1 : rom_a_pre[6]; // Special mode 0
assign ROM_A[19:14] = rom_a_pre[5:0]; // Direct mapping for lower bits

// 0.2 RAM Bank Mapping (MBC5)
wire [5:0] ram_a_