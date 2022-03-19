`default_nettype none
`timescale 1ns/1ns

module top(
    input clk,
    input btn,
    output vga_h_sync,
    output vga_v_sync,
    output reg[3:0] vga_r,
    output reg[3:0] vga_g,
    output reg[3:0] vga_b
);

    reg [3:0] resetn_gen = 0;
	reg reset;
    wire pll_locked;
    wire clk_25_175;

    vga_pll pll(
        .clock_in(clk),
        .pll_locked(pll_locked),
        .clock_out(clk_25_175),
    );

	always @(posedge clk_25_175) begin
		reset <= &resetn_gen;
		resetn_gen <= {resetn_gen, pll_locked};
	end

    vga_demo topi(
        .clk(clk_25_175),
        .reset(reset),
        .vga_h_sync(vga_h_sync),
        .vga_v_sync(vga_v_sync),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b)
    );

endmodule