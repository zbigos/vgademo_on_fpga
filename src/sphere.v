module sphere_renderer(
    input wire clk,
    input wire reset,
    input wire [6:0] compr_hrw,
    input wire [6:0] compr_vrw,
    output reg [3:0] colorv,
    input wire startv,
    input wire starth,
    input wire [20:0] top
);

    reg [6:0] current_h;
    reg [6:0] current_v;

    wire [14:0] pmulvire2;
    wire [14:0] pmulvire1;
        
    
    assign pmulvire2 = (compr_hrw - current_h);
    assign pmulvire1 = (compr_vrw - current_v);

    wire [14:0] acc;
    assign acc = pmulvire2 * pmulvire2 + pmulvire1 * pmulvire1;


    wire [20:0] ballsize = 12'd32;
    reg deltav;
    reg deltah;

    reg [20:0] spdcnt;
    

    always @(posedge clk) begin
        if (!reset) begin
            current_h <= 7'd32;
            current_v <= 7'd32;
            deltav <= startv;
            deltah <= starth;
            spdcnt <= 21'b0;
        end else begin
            colorv <= ballsize + 16 > acc ? 4'b1111 : acc < ballsize + 128 ? 16 - (acc - ballsize) / 8 : 4'b0000;
            if (spdcnt == top) begin
                spdcnt <= spdcnt + 1'b1;
                if (current_v < 10) begin
                    deltav <= 1'b1;
                end
                if (current_h < 10) begin
                    deltah <= 1'b1;
                end
                if (current_v > (60 - 10)) begin
                    deltav <= 1'b0;
                end
                if (current_h > (80 - 10)) begin
                    deltah <= 1'b0;
                end
            end else if (spdcnt > top) begin
                if (deltav) begin
                    current_v <= current_v + 1'b1;
                end else begin
                    current_v <= current_v - 1'b1;
                end

                if (deltah) begin
                    current_h <= current_h + 1'b1;
                end else begin
                    current_h <= current_h - 1'b1;
                end

                spdcnt <= 0;
            end else begin
                spdcnt <= spdcnt + 1'b1;
            end
        end
    end

endmodule


