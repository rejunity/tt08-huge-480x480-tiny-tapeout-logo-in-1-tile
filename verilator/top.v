// VGA timing: https://projectf.io/posts/video-timings-vga-720p-1080p/
// PLL setup and sync: https://forum.1bitsquared.com/t/fpga4fun-pong-vga-demo/44
// DVI PMOD 12bpp pcf: https://github.com/icebreaker-fpga/icebreaker-pmod/blob/master/dvi-12bit/icebreaker.pcf or https://github.com/projf/projf-explore/blob/main/graphics/fpga-graphics/ice40/icebreaker.pcf
// DVI PMOD 4bpph pcf: https://github.com/icebreaker-fpga/icebreaker-pmod/blob/master/dvi-4bit/icebreaker.pcf
// Also see: https://projectf.io/posts/fpga-graphics/

`define VGA_6BPP
// `define VGA_12BPP
// `define DVI

module top  (
    input  wire clk_pixel,
    input  wire reset,
    output      vsync,
    output      hsync,
    output      [7:0] r,
    output      [7:0] g,
    output      [7:0] b,
    output      pwm_audio
);

    wire [1:0] vga_6bpp_r;
    wire [1:0] vga_6bpp_g;
    wire [1:0] vga_6bpp_b;

    wire [7:0] pmod1_out;
    wire [7:0] pmod2_out;
    tt_um_rejunity_vga_logo logo(
        .ui_in(8'b0),
        .uo_out(pmod1_out),
        .uio_in(8'b0),
        .uio_out(pmod2_out),
        .uio_oe(),
        .ena(1'b1),
        .clk(clk_pixel),
        .rst_n(~reset)
    );
    assign {
            hsync, vga_6bpp_b[0], vga_6bpp_g[0], vga_6bpp_r[0],
            vsync, vga_6bpp_b[1], vga_6bpp_g[1], vga_6bpp_r[1]} = pmod1_out;

    assign r = {vga_6bpp_r, 6'd0};
    assign g = {vga_6bpp_g, 6'd0};
    assign b = {vga_6bpp_b, 6'd0};

    assign pwm_audio  = pmod2_out[7];

endmodule
