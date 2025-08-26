
// synthesis translate_off

`timescale 1ns/1ns

module graphics_line_tb;
   import vga_pkg::*, graphics_pkg::*;

   localparam T = 10;

   logic clk;
   logic clken;
   logic reset;

   // Avalon MM interface for providing input
   logic                         mm_csr_write;
   logic [MM_CSR_ADDR_WIDTH-1:0] mm_csr_address;
   logic [MM_CSR_DATA_WIDTH-1:0] mm_csr_writedata;
   logic                         mm_csr_waitrequest;
   
   // Operation control signals
   logic start;
   logic done;
   
   // Avalon ST source interface for streaming pixels to be changed in frame buffer
   logic                      st_ready;
   pixel_t                    st_data;
   logic                      st_valid;

   graphics_line graphics_line0(
      .clk,
      .clken,
      .reset,
      .mm_csr_write,
      .mm_csr_address,
      .mm_csr_writedata,
      .mm_csr_waitrequest,
      .start,
      .done,
      .st_ready,
      .st_data,
      .st_valid
   );
   
   initial
   begin: clock
      clk = '1;
      clken = '1;
      forever #(T/2) clk = ~clk;
   end

   task automatic start_line(
      input logic [COORD_DATA_WIDTH-1:0] x0,
      input logic [COORD_DATA_WIDTH-1:0] y0,
      input logic [COORD_DATA_WIDTH-1:0] x1,
      input logic [COORD_DATA_WIDTH-1:0] y1,
      input logic [COLOR_DATA_WIDTH-1:0] color
   );
      coordinate_t addr_start, addr_end;
      color_t color_data;

      addr_start.x       = x0;
      addr_start.y       = y0;
      addr_end.x         = x1;
      addr_end.y         = y1;
      color_data.color   = color;
      color_data.padding = '0;

      mm_csr_write     <= '1;
      mm_csr_address   <= LINE_ADDR_START;
      mm_csr_writedata <= addr_start;
      
      #(T);
      mm_csr_write     <= '1;
      mm_csr_address   <= LINE_ADDR_END;
      mm_csr_writedata <= addr_end;

      #(T);
      mm_csr_write     <= '1;
      mm_csr_address   <= LINE_ADDR_COLOR;
      mm_csr_writedata <= color_data;

      #(T);
      mm_csr_write     <= '0;
      start            <= '1;
      
      #(T);
      start            <= '0;
   endtask: start_line

   task automatic check_pixel(
      int i,
      input logic valid,
      input pixel_t expected,
      input pixel_t actual,
      input logic done
   );

      assert (valid) else $error("there should be a pixel output on Avalon interface");
      assert (actual.x == expected.x) else $error("X coordinate does not match in iteration %d", i);
      assert (actual.y == expected.y) else $error("Y coordinate does not match in iteration %d", i);
      assert (actual.color == expected.color) else $error("color does not match in iteration %d", i);
      assert (!done) else $error("done should not be asserted yet");
   endtask: check_pixel
   
   initial
   begin: test_cases
      pixel_t line1[0:6];
      pixel_t line2[0:6];
      pixel_t line3[0:6];
      pixel_t line4[0:0];

      reset            <= '1;
      mm_csr_write     <= '0;
      mm_csr_address   <= '0;
      mm_csr_writedata <= '0;
      start            <= '0;
      st_ready         <= '0;

      #(T);
      reset <= '0;
      st_ready <= '1;

      #(T);
      $info("drawing line 1");

      // Draw a low slope line
      line1 = '{
         '{x: 0, y: 1, color: '1, padding: '0},
         '{x: 1, y: 1, color: '1, padding: '0},
         '{x: 2, y: 2, color: '1, padding: '0},
         '{x: 3, y: 2, color: '1, padding: '0},
         '{x: 4, y: 3, color: '1, padding: '0},
         '{x: 5, y: 3, color: '1, padding: '0},
         '{x: 6, y: 4, color: '1, padding: '0}
      };

      start_line(0, 1, 6, 4, '1);
      
      #(2*T);
      foreach (line1[i]) begin
         #(T) check_pixel(i, st_valid, line1[i], st_data, done);
      end

      #(T);
      assert (done) else $error("done should be asserted now");

      #(T);
      
      // Draw the same line, just swap coordinates
      $info("drawing line 1 again");
      start_line(6, 4, 0, 1, '1);

      #(2*T);
      foreach (line1[i]) begin
         #(T) check_pixel(i, st_valid, line1[i], st_data, done);
      end

      #(T);
      assert (done) else $error("done should be asserted now");

      #(T);
      $info("drawing line 2");

      // Draw a high slope line
      line2 = '{
         '{x: 1, y: 0, color: '1, padding: '0},
         '{x: 1, y: 1, color: '1, padding: '0},
         '{x: 2, y: 2, color: '1, padding: '0},
         '{x: 2, y: 3, color: '1, padding: '0},
         '{x: 3, y: 4, color: '1, padding: '0},
         '{x: 3, y: 5, color: '1, padding: '0},
         '{x: 4, y: 6, color: '1, padding: '0}
      };

      start_line(1, 0, 4, 6, '1);
      
      #(2*T);
      foreach (line2[i]) begin
         #(T) check_pixel(i, st_valid, line2[i], st_data, done);
      end

      #(T);
      assert (done) else $error("done should be asserted now");
      
      #(T);

      // Draw the same line, just swap coordinates
      $info("drawing line 2 again");
      start_line(4, 6, 1, 0, '1);

      #(2*T);
      foreach (line2[i]) begin
         #(T) check_pixel(i, st_valid, line2[i], st_data, done);
      end

      #(T);
      assert (done) else $error("done should be asserted now");

      #(T);
      $info("drawing line 3, slope 1");

      line3 = '{
         '{x: 1, y: 1, color: '1, padding: '0},
         '{x: 2, y: 2, color: '1, padding: '0},
         '{x: 3, y: 3, color: '1, padding: '0},
         '{x: 4, y: 4, color: '1, padding: '0},
         '{x: 5, y: 5, color: '1, padding: '0},
         '{x: 6, y: 6, color: '1, padding: '0},
         '{x: 7, y: 7, color: '1, padding: '0}
      };

      start_line(1, 1, 7, 7, '1);
      
      #(2*T);
      foreach (line3[i]) begin
         #(T) check_pixel(i, st_valid, line3[i], st_data, done);
      end

      #(T);
      assert (done) else $error("done should be asserted now");
      
      #(T);

      #(T);
      $info("drawing line 4, single pixel");

      line4 = '{
         '{x: 2, y: 2, color: '1, padding: '0}
      };

      start_line(2, 2, 2, 2, '1);
      
      #(2*T);
      foreach (line4[i]) begin
         #(T) check_pixel(i, st_valid, line4[i], st_data, done);
      end

      #(T);
      assert (done) else $error("done should be asserted now");
      
      #(T);

      $stop;
   end
endmodule: graphics_line_tb

// synthesis translate_on
