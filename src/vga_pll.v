/**
 * PLL configuration
 *
 * This Verilog module was generated automatically
 * using the icepll tool from the IceStorm project.
 * Use at your own risk.
 *
 * Given input frequency:       100.000 MHz
 * Requested output frequency:   25.175 MHz
 * Achieved output frequency:    25.312 MHz
 */

module vga_pll(
	input  clock_in,
	output clock_out,
	output pll_locked,
	);

	SB_PLL40_PAD #(
		.DIVR(4'b1001),		// DIVR =  9
		.DIVF(7'b1010000),	// DIVF = 80
		.DIVQ(3'b101),		// DIVQ =  5
		.FILTER_RANGE(3'b001),	// FILTER_RANGE = 1
		.FEEDBACK_PATH("SIMPLE"),
		.DELAY_ADJUSTMENT_MODE_FEEDBACK("FIXED"),
		.FDA_FEEDBACK(4'b0000),
		.DELAY_ADJUSTMENT_MODE_RELATIVE("FIXED"),
		.FDA_RELATIVE(4'b0000),
		.SHIFTREG_DIV_MODE(2'b00),
		.PLLOUT_SELECT("GENCLK"),
		.ENABLE_ICEGATE(1'b0)
	) pll_inst (
		.PACKAGEPIN(clock_in),
		.PLLOUTCORE(),
		.PLLOUTGLOBAL(clock_out),
		.EXTFEEDBACK(),
		.DYNAMICDELAY(),
		.RESETB(1'b1),
		.BYPASS(1'b0),
		.LOCK(pll_locked),
		.LATCHINPUTVALUE(),
	);

endmodule
