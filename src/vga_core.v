`default_nettype none
`timescale 1ns/1ns

module VGAcore 
    # (
        parameter NATIVE_HRES = 640,
        parameter FRONT_PORCH_H = 16,
        parameter SYNC_PULSE_H = 96,
        parameter BACK_PORCH_H = 48,

        parameter NATIVE_VRES = 480,
        parameter FRONT_PORCH_V = 10,
        parameter SYNC_PULSE_V = 2,
        parameter BACK_PORCH_V = 33,
        parameter RES_PRESCALER = 1
    ) (
        input wire clk_25_175,
        input wire reset,
        output wire h_sync,
        output wire v_sync,
        output reg[9:0] hreadwire,
        output reg[9:0] vreadwire,
        input wire[11:0] pixstream,
        output wire[3:0] r,
        output wire[3:0] g,
        output wire[3:0] b,
        output wire drawing_pixels
);

    /* expected frequency is 40Hz. Need to find such a prescaler that
       1. divides 800, 840, 968, 1056
       2. expects a clock that can be generated from 12MHz 

       common divisors of 800, 840, 968 and 1056 are 1, 2, 4, 8
       this means that frequencies are constrained to 40, 20, 10, 5 MHz

       with prescaler = 
    */    
    reg [3:0] proposed_r;
    reg [3:0] proposed_b;
    reg [3:0] proposed_g;
    wire h_drawing_pixels, v_drawing_pixels;
    assign drawing_pixels = h_drawing_pixels & v_drawing_pixels;

    assign r = drawing_pixels ? proposed_r : 4'b0000;
    assign b = drawing_pixels ? proposed_g : 4'b0000;
    assign g = drawing_pixels ? proposed_b : 4'b0000;

    assign h_drawing_pixels = hreadwire < 10'd656 & hreadwire > 10'd16;
    assign v_drawing_pixels = vreadwire < 10'd490 & vreadwire > 10'd10; 
    assign h_sync = !((hreadwire >= 10'd656) & (hreadwire < 10'd752));
    assign v_sync = !((vreadwire > 10'd490) & (vreadwire < 10'd492));

    always @(posedge clk_25_175) begin
        if (!reset) begin
            hreadwire <= 0;
            vreadwire <= 0;
            proposed_r <= {4'b0};
            proposed_g <= {4'b0};
            proposed_b <= {4'b0};
        end else begin    
            if (hreadwire == 10'd799) begin
                hreadwire <= 0;
                vreadwire <= vreadwire + 1'b1;
            end else if (vreadwire == 10'd524) begin
                vreadwire <= 0;
            end else begin
                proposed_r[3:0] <= pixstream[3:0];
                proposed_g[3:0] <= pixstream[7:4];
                proposed_b[3:0] <= pixstream[11:8];
                hreadwire <= hreadwire + 1'b1;
            end
        end
    end

endmodule