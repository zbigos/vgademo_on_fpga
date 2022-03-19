module dump();
    initial begin
        $dumpfile ("vga_demo.vcd");
        $dumpvars (0, vga_demo);
        #1;
    end
endmodule