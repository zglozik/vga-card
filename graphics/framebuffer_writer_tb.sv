
// synthesis translate_off

`timescale 1ns/1ns

module framebuffer_writer_tb;
   import vga_pkg::*, graphics_pkg::*;

   localparam T = 10;

   logic clk;
   logic reset;

   // Avalon ST source interface for input pixels
   logic   st_ready;
   pixel_t st_data;
   logic   st_valid;
   
   // Avalon MM Slave interface for writing to frame buffer
   logic                         mm_write;
   logic [MM_MEM_ADDR_WIDTH-1:0] mm_address;
   logic [MM_MEM_DATA_WIDTH-1:0] mm_writedata;
   logic                         mm_waitrequest;

   
   function automatic int address(
      input int x,
      input int y);
      address = 1000 + y * WIDTH * MM_MEM_DATA_WIDTH / 8 + x * MM_MEM_DATA_WIDTH / 8;
   endfunction

   struct {
      logic   st_ready;
      pixel_t st_data;
      logic   st_valid;

      logic                         mm_write;
      logic [MM_MEM_ADDR_WIDTH-1:0] mm_address;
      logic [MM_MEM_DATA_WIDTH-1:0] mm_writedata;
      logic                         mm_waitrequest;
   } signals[0:6] = '{
      //  st_ready,                   st_data, st_valid, mm_write,      mm_address, mm_writedata, mm_waitrequest
      '{        '1, '{x: 10, y: 2, color: 15},       '1,       '0,              'x,           'x,             '0},
      '{        '1, '{x:  3, y: 1, color: 20},       '1,       '1,  address(10, 2),           15,             '0},
      '{        '0, '{x:  1, y: 5, color: 50},       '1,       '1,   address(3, 1),           20,             '1},
      '{        '0, '{x:  1, y: 5, color: 50},       '1,       '1,   address(3, 1),           20,             '1},
      '{        '1, '{x:  1, y: 5, color: 50},       '1,       '1,   address(3, 1),           20,             '0},
      '{        '1,                        '0,       '0,       '1,   address(1, 5),           50,             '0},
      '{        '1,                        '0,       '0,       '0,              'x,           'x,             '0}
   };

   framebuffer_writer #(
      .MM_ADDR_WIDTH(MM_MEM_ADDR_WIDTH),
      .MM_DATA_WIDTH(MM_MEM_DATA_WIDTH),
      .MM_START_ADDRESS(1000)
   ) framebuffer_writer0(
      .clk,
      .reset,
      .st_ready,
      .st_data,
      .st_channel('0),
      .st_valid,
      .mm_write,
      .mm_address,
      .mm_writedata,
      .mm_waitrequest
   );
   
   initial
   begin: clock
      clk = '1;
      forever #(T/2) clk = ~clk;
   end
  
   initial
   begin: test_cases
      reset          <= '1;
      mm_waitrequest <= '0;
      st_valid       <= '0;
      st_data        <= '0;

      #(T);
      reset <= '0;

      for (int i = 0; i < $size(signals); i = i + 1) begin
         @(posedge clk);
         st_valid       <= signals[i].st_valid;
         st_data        <= signals[i].st_data;
         mm_waitrequest <= signals[i].mm_waitrequest;

         #(T/2);
         assert(st_ready ==? signals[i].st_ready)         else $error("st_ready does not match in iteration %d", i);
         assert(mm_write ==? signals[i].mm_write)         else $error("mm_write does not match in iteration %d", i);
         assert(mm_address ==? signals[i].mm_address)     else $error("mm_address does not match in iteration %d", i);
         assert(mm_writedata ==? signals[i].mm_writedata) else $error("mm_writedata does not match in iteration %d", i);
      end

      repeat(3)
         @(posedge clk);
      
      $stop;
   end
endmodule: framebuffer_writer_tb

// synthesis translate_on
