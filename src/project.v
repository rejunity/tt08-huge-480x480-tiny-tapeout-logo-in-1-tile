
/*
 * Copyright (c) 2024 Tiny Tapeout LTD
 * SPDX-License-Identifier: Apache-2.0
 * Author: Renaldas Zioma
 */

`default_nettype none

`define VGA_REGISTERED_OUTPUTS

parameter LOGO_SIZE = 480;  // Size of the logo in pixels
parameter DISPLAY_WIDTH = 640;  // VGA display width
parameter DISPLAY_HEIGHT = 480;  // VGA display height

module gradient(
  input wire clk,
  input wire reset,
  output wire [10:0] value
);
  reg [10:0] acc;
  reg [19:0] lfsr; 
  wire feedback = lfsr[19] ^ lfsr[15] ^ lfsr[11] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3] ^ 1'b1;

  always @(posedge clk) begin
    if (reset) begin
      acc <= 0;
      lfsr <= 0;
    end else begin
      acc <= acc + lfsr[7:0];
      lfsr <= {lfsr[18:0], feedback};
    end
  end
  assign value = acc;
endmodule

module tt_um_rejunity_vga_logo (
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  localparam LIGHT_SPEED = 32;

  wire [9:0] x = pix_x;
  wire [9:0] y = pix_y;
  wire [10:0] xx = pix_x + pix_y/4 - counter*LIGHT_SPEED;
  //wire[10:0] xxS = pix_x + pix_y/4 - counter*LIGHT_SPEED;
  wire[ 10:0] xx2 = pix_x + pix_y/4;

  // reg [7:0] acc;
  // reg line;
  // reg [19:0] lfsr; 
  // wire feedback = lfsr[19] ^ lfsr[15] ^ lfsr[11] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3] + 1;

  reg [5:0] grad_colors [4:0];
  initial begin
    // grad_colors[0] = 6'b11_00_11;
    // grad_colors[1] = 6'b11_10_10;
    // grad_colors[2] = 6'b11_01_01;
    // grad_colors[3] = 6'b11_00_00;

    // miami
    // grad_colors[0] = 6'b11_00_11;
    // grad_colors[1] = 6'b11_00_10;
    // grad_colors[2] = 6'b11_01_01;
    // grad_colors[3] = 6'b11_01_00;
    // grad_colors[4] = 6'b11_00_00;

    // sky
    grad_colors[0] = 63;
    grad_colors[1] = 63;
    grad_colors[2] = 43;
    grad_colors[3] = 23;
    grad_colors[4] = 3;

    // sky 2
    grad_colors[0] = 63;
    grad_colors[1] = 62;
    grad_colors[2] = 63-5;
    grad_colors[3] = 43-5;
    grad_colors[4] = 23-5;

    // sky 3
    // grad_colors[0] = 63;
    // grad_colors[1] = 43;
    // grad_colors[2] = 23;
    // grad_colors[3] = 19;
    // grad_colors[4] = 2;

  end

  // reg [5:0] logo_colors [7:0];
  // initial begin
  //   logo_colors[0] = 0;
  //   logo_colors[1] = 6'b01_01_01;
  //   logo_colors[2] = 0;
  //   logo_colors[3] = 0;
  //   logo_colors[4] = 0;
  //   logo_colors[5] = 6'b01_01_01;
  //   logo_colors[6] = 6'b10_10_10;
  //   logo_colors[7] = 63;
  // end

  // reg [5:0] logo_colors [7:0];
  // initial begin
  //   logo_colors[0] = 0;
  //   logo_colors[1] = 6'b01_01_00;
  //   logo_colors[2] = 0;
  //   logo_colors[3] = 0;
  //   logo_colors[4] = 0;
  //   logo_colors[5] = 6'b01_01_00;
  //   logo_colors[6] = 6'b10_10_00;
  //   logo_colors[7] = 6'b11_11_10;
  // end

  reg [5:0] logo_colors [15:0];
  initial begin
    logo_colors[0]  = 6'b01_00_00;
    logo_colors[1]  = 0;
    logo_colors[2]  = 0;
    logo_colors[3]  = 0;
    logo_colors[4]  = 0;
    logo_colors[5]  = 0;
    logo_colors[6]  = 0;
    logo_colors[7]  = 0;
    logo_colors[8]  = 0;
    logo_colors[9]  = 0;
    logo_colors[10] = 0;
    logo_colors[11] = 0;
    logo_colors[12] = 0;
    logo_colors[13] = 6'b10_00_00;
    logo_colors[14] = 6'b10_01_00;
    logo_colors[15] = 6'b11_10_00;
  end


  reg [5:0] logo2_colors [3:0];
  initial begin
    // logo2_colors[0]  = 6'b01_00_01;
    // logo2_colors[1]  = 0;//6'b10_00_10;
    // logo2_colors[2]  = 6'b01_00_01;
    // logo2_colors[3]  = 0;//6'b10_00_10;

    // logo2_colors[0]  = 3;
    // logo2_colors[1]  = 1;
    // logo2_colors[2]  = 19;
    // logo2_colors[3]  = 2;

    logo2_colors[0]  = 16;
    logo2_colors[1]  = 17;
    logo2_colors[2]  = 16;
    logo2_colors[3]  = 17;

  end


  localparam BLING = 6'b11_11_10;
  // localparam BLING = 6'b11_10_01;
  localparam SPEC_SPEED = 2;//65;
  localparam COUNTER_DIV = 10-$clog2(LIGHT_SPEED);
  wire [10:0] grad_value;
  // wire line = grad_value[7:0] < y; 
  // wire [5:0] fg = 6'b11_11_01;
  wire [5:0] fgc = (grad_value[8:0] < (xx2-120)) ? 6'b01_00_01 : 6'b10_00_10;
    // grad_value[8:0] > xxS[8:0] ? logo2_colors[xxS[10:9]] : logo2_colors[xxS[10:9]+1];
  wire [5:0] fgl = 
    // counter[4:0]*SPEC_SPEED > xx2+6*SPEC_SPEED & counter[4:0]*SPEC_SPEED <= xx2+8*SPEC_SPEED ? 6'b11_11_00:
    // counter[5:0]*LIGHT_SPEED*SPEC_SPEED > xx2+12*LIGHT_SPEED*SPEC_SPEED & counter[5:0]*LIGHT_SPEED*SPEC_SPEED <= xx2+18*LIGHT_SPEED*SPEC_SPEED ? 6'b11_11_00:
    // counter[COUNTER_DIV:0]*LIGHT_SPEED*SPEC_SPEED > xx2+200*SPEC_SPEED*SPEC_SPEED &
    // counter[COUNTER_DIV:0]*LIGHT_SPEED*SPEC_SPEED <= xx2+270*SPEC_SPEED*SPEC_SPEED ? 6'b11_11_00:
    // counter[COUNTER_DIV:0]*LIGHT_SPEED*SPEC_SPEED > xx2+200*SPEC_SPEED*SPEC_SPEED &
    // counter[COUNTER_DIV:0]*LIGHT_SPEED*SPEC_SPEED <= xx2+270*SPEC_SPEED*SPEC_SPEED ? BLING:
    counter[COUNTER_DIV:0]*LIGHT_SPEED*SPEC_SPEED > xx2+180*SPEC_SPEED*SPEC_SPEED &
    counter[COUNTER_DIV:0]*LIGHT_SPEED*SPEC_SPEED <= xx2+230*SPEC_SPEED*SPEC_SPEED ? BLING:
    // 0;
     (grad_value[6:0] > xx[6:0]) ? logo_colors[xx[10:7]] : logo_colors[xx[10:7]+1];
  wire [5:0] fg = fgc | fgl;

  wire [5:0] bg = 
    (grad_value[6:0] > y[6:0]) ? grad_colors[y[8:7]] : grad_colors[y[8:7]+1];
    // grad1_value[7:0] > y       & y < 256 ? 6'b10_00_11 : //6'b11_00_10;
    // grad2_value[7:0] > (y-256) & y > 256 ? 6'b11_00_10 : 6'b10_00_01;
      // grad1_value[7:0] > y        ? 6'b11_11_11 : //6'b00_00_00 
      // grad2_value[7:0] > (y-255)  & y < 400 ? 6'b00_00_00 : 6'b00_00_11;

  gradient grad1(
    .clk(clk),
    .reset(~rst_n),
    .value(grad_value));

  // no multipliers - sequential only access
  reg [16:0] r;
  always @(posedge clk) begin
    if (~rst_n) begin
      r <= 0;
    end else begin
      if (vsync) begin
        r <= 320*320 + 240*240;
        // acc <= 0;
        // lfsr <= 8'd1;
      end
        // line <= acc < y;
        // acc <= acc + lfsr*1;
        // lfsr <= {lfsr[6:0], feedback};

        // line <= acc < x;
        // acc <= acc + lfsr[7:0];
        // lfsr <= {lfsr[18:0], feedback};
        // if (lfsr == 0)
        //   lfsr <= 1;

      if (x == 0) begin

        // line <= 0;
        // if (add > THR) begin
        //   flip <= ~flip;
        //   add <= THR;
        //   line <= 1;
        // end 
        // if (acc > THR*2-1) begin
        //   add <= flip ? add-1: add+1;
        //   acc <= 0;
        //   line <= 1;
        // end
        // else
        //   acc <= acc + add;

        // if (dd == 1) begin
        //   flip <= ~flip;
        //   // dd <= 0;//flip ? 1: 16;
        //   // cc <= 0;
        //   // cc <= dd;
        //   cc <= 8;
        // end
        // if (cc == 0) begin
        //   cc <= flip ? dd + 1 : dd - 1;
        //   dd <= flip ? dd + 1 : dd - 1;
        // end else
        //   cc <= cc - 1;
      end

      if (video_active & x == 0) begin
        r <= r + 2*(y-240)+1 - 320*2;
      end else if (video_active) begin
        r <= r + 2*(x-320)+1;
      end
    end
  end
  

  // reg [16:0] r;
  // // reg [16:0] rx, ry;
  // always @(posedge clk) begin
  //   if (~rst_n) begin
  //     r <= 0;
  //   end else begin
  //     if (vsync) begin
  //       r <= 320*320 + 240*240;
  //       // ry <= 240*240;
  //       // rx <= 320*320;
  //     end
  //     if (video_active & x == 0) begin
  //       // rx <= 320*320;
  //       // ry <= ry + 2*(y-240) + 1;
  //       r <= r + 2*(y-240) + 1 - 320*2;
  //     end else if (video_active) begin
  //       // rx <= rx + 2*(x-320)+1;
  //       r <= r + 2*(x-320)+1;
  //     end
  //   end
  // end

  // wire ring = (rx+ry) < 240*240 & (rx+ry) > (240-36)*(240-36);
  wire ring = r < 238*238 & r > (238-36)*(238-36);

  // xy: 46x100 wh:240x64
  wire hat0 = x >= 80+46  & x < 80+46+240  & y >= 100 & y < 100+64;
  // xy:144x100 wh:70x228
  wire leg0 = x >= 80+144 & x < 80+144+70  & y >= 100 & y < 100+228;
  // xy:144x222 wh:254x64
  wire hat1 = x >= 80+144 & x < 80+144+254 & y >= 222 & y < 222+64;
  // xy:256x222 wh:70x240
  wire leg1 = x >= 80+256 & x < 80+256+70  & y >= 222 & y < 222+240;

  // xy:(256+70)x(222+64) wh:20x...
  wire cut0 = ~(x >= 80   & x < 80+144     & y >= 100+64 & y < 100+60+22);
  // xy:(256+70)x(222+64) wh:20x...
  wire cut1 = ~(x >= 80+256+70 & x < 80+256+70+22 & y >= 222+64 & y < LOGO_SIZE);

  // wire bg = y[5]^y[4]^y[3];//y[0]+y[1]+y[2]+y[3]+y[4]+y[5]+y[6]+y[7]+y[8] > 2;
  // wire bg = acc[6]^flip;//(cc == 1)^flip;
  // wire bg = line;

  wire logo = (ring&cut0&cut1)|hat0|leg0|hat1|leg1;
  assign {R, G, B} = 
    ~video_active ? 0 :
             // logo ? 6'b00_00_00 : 6'b11_11_11;
                logo ? fg : bg;


  // VGA signals
  wire hsync;
  wire vsync;
  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // TinyVGA PMOD
`ifdef VGA_REGISTERED_OUTPUTS
  reg [7:0] UO_OUT;
  always @(posedge clk)
    UO_OUT <= {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};
  assign uo_out = UO_OUT;
`else
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};
`endif

  // Unused outputs assigned to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};

  // reg [10:0] counter;
  reg [10:0] counter2;
  wire [9:0] counter = counter2;

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );
  
  // wire [9:0] moving_x = pix_x + counter;

  // assign R = video_active ? {moving_x[5], pix_y[2]} : 2'b00;
  // assign G = video_active ? {moving_x[6], pix_y[2]} : 2'b00;
  // assign B = video_active ? {moving_x[7], pix_y[5]} : 2'b00;
  
  reg vsync_prev; always @(posedge clk) vsync_prev <= vsync;

  always @(posedge clk) begin
    if (~rst_n) begin
      counter2 <= 0;
    end else if (vsync_prev != vsync && vsync)
      counter2 <= counter2 + 1;
  end
  
endmodule