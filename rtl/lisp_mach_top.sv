/*
 * top of LX45 fpga for CADDR
 */

`define full_design
//`define use_spyport
//`define use_vga
//`define use_hdmi
//`define use_ps2
//`define use_mmc
//`define spy_mmc

module top(
	   
   input	usb_rxd,
   output	usb_txd,

   output [4:0] led,
   input 	sysclk,

//   input	ps2_clk,
//   input 	ps2_data,
   
//   inout	ms_ps2_clk,
//   inout 	ms_ps2_data,
   
//   output 	vga_hsync,
//   output 	vga_vsync,
//   output 	vga_r,
//   output 	vga_g,
//   output 	vga_b,

   output 	mmc_cs,
   output 	mmc_do,
   output 	mmc_sclk,
   input 	mmc_di,

   input 	switch,
   
   inout [15:0]  mcb3_dram_dq,
   output [12:0] mcb3_dram_a,
   output [1:0]  mcb3_dram_ba,
   output 	 mcb3_dram_cke,
   output 	 mcb3_dram_ras_n,
   output 	 mcb3_dram_cas_n,
   output 	 mcb3_dram_we_n,
   output 	 mcb3_dram_dm,
   inout 	 mcb3_dram_udqs,
   inout 	 mcb3_rzq,
   output 	 mcb3_dram_udm,
   inout 	 mcb3_dram_dqs,
   output 	 mcb3_dram_ck,
   output 	 mcb3_dram_ck_n
);
extern module support(
   input sysclk,
   input cpuclk,
   input button_r,
   input button_b,
   input button_h,
   input button_c,
   input lpddr_calib_done,
  
   output lpddr_reset,
   output dcm_reset,
   output reset,
   output interrupt,
   output boot,
   output halt
);
extern module lx45_ram_controller(
   input sysclk_in,
   output lpddr_clk_out,
   input lpddr_reset,
   output lpddr_calib_done,
   
   input clk,
   input vga_clk,
   input cpu_clk,

   input reset,
   input prefetch,
   input fetch,
   input machrun,
   output [3:0] state_out,
   
   input [13:0]  mcr_addr,
   output [48:0] mcr_data_out,
   input [48:0]  mcr_data_in,
   output 	 mcr_ready,
   input 	 mcr_write,
   output 	 mcr_done,

   input [21:0]  sdram_addr,
   output [31:0] sdram_data_out,
   input [31:0]  sdram_data_in,
   input 	 sdram_req,
   output 	 sdram_ready,
   input 	 sdram_write,
   output 	 sdram_done,

   input [14:0]  vram_cpu_addr,
   output [31:0] vram_cpu_data_out,
   input [31:0]  vram_cpu_data_in,
   input 	 vram_cpu_req,
   output 	 vram_cpu_ready,
   input 	 vram_cpu_write,
   output 	 vram_cpu_done,

   input [14:0]  vram_vga_addr,
   output [31:0] vram_vga_data_out,
   input 	 vram_vga_req,
   output 	 vram_vga_ready,

   inout [15:0]  mcb3_dram_dq,
   output [12:0] mcb3_dram_a,
   output [1:0]  mcb3_dram_ba,
   output 	 mcb3_dram_cke,
   output 	 mcb3_dram_ras_n,
   output 	 mcb3_dram_cas_n,
   output 	 mcb3_dram_we_n,
   output 	 mcb3_dram_dm,
   inout 	 mcb3_dram_udqs,
   inout 	 mcb3_rzq,
   output 	 mcb3_dram_udm,
   inout 	 mcb3_dram_dqs,
   output 	 mcb3_dram_ck,
   output 	 mcb3_dram_ck_n 
);
extern module caddr ( 
   input clk,
   input ext_int,
   input ext_reset,
   input ext_boot,
   input ext_halt,

   input [15:0] spy_in,
   output [15:0] spy_out,
   input 	dbread,
   input 	dbwrite,
   input [4:0] 	eadr,
   output [3:0]	spy_reg,
   output 	spy_rd,
   output 	spy_wr,
   
   output [13:0] pc_out,
   output [5:0]  state_out,
   output [4:0]  disk_state_out,
   output [3:0]  bus_state_out,
   output 	 machrun_out,
   output 	 prefetch_out,
   output 	 fetch_out,

   output [13:0] mcr_addr,
   output [48:0] mcr_data_out,
   input [48:0]  mcr_data_in,
   input 	 mcr_ready,
   output 	 mcr_write,
   input 	 mcr_done,

   output [21:0]  sdram_addr,
   output [31:0] sdram_data_out,
   input [31:0]  sdram_data_in,
   output 	 sdram_req,
   input 	 sdram_ready,
   output 	 sdram_write,
   input 	 sdram_done,

   output [14:0] vram_addr,
   output [31:0] vram_data_out,
   input [31:0]  vram_data_in,
   output 	 vram_req,
   input 	 vram_ready,
   output 	 vram_write,
   input 	 vram_done,
   
   output [1:0]  bd_cmd,	/* generic block device interface */
   output 	 bd_start,
   input 	 bd_bsy,
   input 	 bd_rdy,
   input 	 bd_err,
   output [23:0] bd_addr,
   input [15:0]  bd_data_in,
   output [15:0] bd_data_out,
   output 	 bd_rd,
   output 	 bd_wr,
   input 	 bd_iordy,
   input [11:0]  bd_state_in,

   input [15:0]  kb_data,
   input 	 kb_ready,
   
   input [11:0]  ms_x, ms_y,
   input [2:0] 	 ms_button,
   input 	 ms_ready
);
// -----------------------------------------------------------------

   logic 	 sysclk_buf; // synthesis attribute period clk50 "50 MHz";
   logic 	 clk50;      // synthesis attribute period clk50 "50 MHz";
   logic 	 pixclk;     // synthesis attribute period pixclk "108 MHz";
   logic 	 cpuclk;     // synthesis attribute period cpuclk "25 MHz";

//   logic 	 rs232_rxd, rs232_txd;

   logic 	 reset;
   logic 	 vga_reset;
//   logic 	 dcm_reset;
  logic 	 lpddr_reset;
   logic 	 interrupt;
   logic		 boot;

   logic [15:0] 	 spy_in;
   logic [15:0] 	 spy_out;
   logic [3:0] 	 spy_reg;
   logic 	 spy_rd;
   logic 	 spy_wr;
   logic 	 dbread, dbwrite;
   logic [4:0] 	 eadr;
   logic 	 halt;
//   logic
   logic [13:0] 	 mcr_addr;
   logic [48:0] 	 mcr_data_out;
   logic [48:0] 	 mcr_data_in;
   logic 	 mcr_ready;
   logic 	 mcr_write;
   logic 	 mcr_done;

   logic [21:0] 	 sdram_addr;
   logic [31:0] 	 sdram_data_cpu2rc;
   logic [31:0] 	 sdram_data_rc2cpu;
   logic 	 sdram_ready; // synthesis attribute keep sdram_ready true;
   logic 	 sdram_req; // synthesis attribute keep sdram_req true;
   logic 	 sdram_write; // synthesis attribute keep sdram_write true;
   logic 	 sdram_done; // synthesis attribute keep sdram_done true;

   logic [14:0] 	 vram_cpu_addr;
   logic [31:0] 	 vram_cpu_data_out;
   logic [31:0] 	 vram_cpu_data_in;
   logic 	 vram_cpu_req;
   logic 	 vram_cpu_ready;
   logic 	 vram_cpu_write;
   logic 	 vram_cpu_done;

   logic [14:0] 	 vram_vga_addr;
   logic [31:0] 	 vram_vga_data_out;
   logic 	 vram_vga_req;
   logic 	 vram_vga_ready;

   logic [1:0] 	 bd_cmd;	/* generic block device interface */
   logic 	 bd_start;
   logic 	 bd_bsy;
   logic 	 bd_rdy;
   logic 	 bd_err;
   logic [23:0] 	 bd_addr;
   logic [15:0] 	 bd_data_bd2cpu;
   logic [15:0] 	 bd_data_cpu2bd;
   logic 	 bd_rd;
   logic 	 bd_wr;
   logic 	 bd_iordy;
   logic [11:0] 	 bd_state;

   logic [13:0] 	 pc;
   logic [5:0] 	 cpu_state; // synthesis attribute keep cpu_state true;
   logic [4:0] 	 disk_state; // synthesis attribute keep disk_state true;
   logic [3:0] 	 bus_state; // synthesis attribute keep bus_state true;
   logic [3:0] 	 rc_state; // synthesis attribute keep rc_state true;
   logic 	 machrun;
   logic 	 prefetch;
   logic 	 fetch;

   logic [3:0] 	 dots;

   logic [15:0] 	 sram1_in;
   logic [15:0] 	 sram1_out;
   logic [15:0] 	 sram2_in;
   logic [15:0] 	 sram2_out;

   logic [15:0] 	 kb_data;
   logic 	 kb_ready;

   logic [11:0] 	 ms_x, ms_y;
   logic [2:0] 	 ms_button;
   logic 	 ms_ready;
   BUFG sysclk_bufg (.I(sysclk), .O(sysclk_buf));

//   lx45_clocks fpga_clocks(.sysclk(sysclk_buf),
//			   .dcm_reset(dcm_reset),
//			   .clk50(clk50),
//			   .clk1x(cpuclk),
//`ifdef use_hdmi
//			   .pixclk()
//`else
//			   .pixclk(pixclk)
//`endif
//			   
//			   );
   
   support support_inst(.sysclk(sysclk_buf),
		   .cpuclk(cpuclk),
		   .button_r(switch),
		   .button_b(1'b0),
		   .button_h(1'b0),
		   .button_c(1'b0),
		   .dcm_reset(dcm_reset),
		   .lpddr_reset(lpddr_reset),
		   .lpddr_calib_done(lpddr_calib_done),
		   .reset(reset),
		   .interrupt(interrupt),
		   .boot(boot),
		   .halt(halt));

//   assign rs232_rxd = usb_rxd;
//   assign usb_txd = rs232_txd;

//`ifdef full_design
   caddr cpu (
	      .clk(cpuclk),
	      .ext_int(interrupt),
	      .ext_reset(reset),
	      .ext_boot(boot),
	      .ext_halt(halt),

	      .spy_in(spy_in),
	      .spy_out(spy_out),
	      .dbread(dbread),
	      .dbwrite(dbwrite),
	      .eadr(eadr),
	      .spy_reg(spy_reg),
	      .spy_rd(spy_rd),
	      .spy_wr(spy_wr),

	      .pc_out(pc),
	      .state_out(cpu_state),
	      .disk_state_out(disk_state),
	      .bus_state_out(bus_state),
	      .machrun_out(machrun),
	      .prefetch_out(prefetch),
	      .fetch_out(fetch),

	      .mcr_addr(mcr_addr),
	      .mcr_data_out(mcr_data_out),
	      .mcr_data_in(mcr_data_in),
	      .mcr_ready(mcr_ready),
	      .mcr_write(mcr_write),
	      .mcr_done(mcr_done),

	      .sdram_addr(sdram_addr),
	      .sdram_data_in(sdram_data_rc2cpu),
	      .sdram_data_out(sdram_data_cpu2rc),
	      .sdram_req(sdram_req),
	      .sdram_ready(sdram_ready),
	      .sdram_write(sdram_write),
	      .sdram_done(sdram_done),
      
	      .vram_addr(vram_cpu_addr),
	      .vram_data_in(vram_cpu_data_in),
	      .vram_data_out(vram_cpu_data_out),
	      .vram_req(vram_cpu_req),
	      .vram_ready(vram_cpu_ready),
	      .vram_write(vram_cpu_write),
	      .vram_done(vram_cpu_done),

	      .bd_cmd(bd_cmd),
	      .bd_start(bd_start),
	      .bd_bsy(bd_bsy),
	      .bd_rdy(bd_rdy),
	      .bd_err(bd_err),
	      .bd_addr(bd_addr),
	      .bd_data_in(bd_data_bd2cpu),
	      .bd_data_out(bd_data_cpu2bd),
	      .bd_rd(bd_rd),
	      .bd_wr(bd_wr),
	      .bd_iordy(bd_iordy),
	      .bd_state_in(bd_state),

	      .kb_data(kb_data),
	      .kb_ready(kb_ready),
	      .ms_x(ms_x),
	      .ms_y(ms_y),
	      .ms_button(ms_button),
	      .ms_ready(ms_ready));
   
//`ifdef use_spyport
//   wire [1:0] 	 spy_bd_cmd;
//   wire 	 spy_bd_start;
//   wire 	 spy_bd_bsy;
//   wire 	 spy_bd_rdy;
//   wire 	 spy_bd_err;
//   wire [23:0] 	 spy_bd_addr;
//   wire [15:0] 	 spy_bd_data_bd2cpu;
//   wire [15:0] 	 spy_bd_data_cpu2bd;
//   wire 	 spy_bd_rd;
//   wire 	 spy_bd_wr;
//   wire 	 spy_bd_iordy;
//   wire [15:0] 	 spy_bd_state;
//
// spy_port spy_port(
//	     .sysclk(clk50),
//	     .clk(cpuclk),
//	     .reset(reset),
//	     .rs232_rxd(rs232_rxd),
//	     .rs232_txd(rs232_txd),
//	     .spy_in(spy_out),
//	     .spy_out(spy_in),
//	     .dbread(dbread),
//	     .dbwrite(dbwrite),
//	     .eadr(eadr),
//`ifdef spy_mmc
//  		     .bd_cmd(spy_bd_cmd),
//	     .bd_start(spy_bd_start),
//	     .bd_bsy(spy_bd_bsy),
//	     .bd_rdy(spy_bd_rdy),
//	     .bd_err(spy_bd_err),
//	     .bd_addr(spy_bd_addr),
//	     .bd_data_in(spy_bd_data_bd2cpu),
//	     .bd_data_out(spy_bd_data_cpu2bd),
//	     .bd_rd(spy_bd_rd),
//	     .bd_wr(spy_bd_wr),
//	     .bd_iordy(spy_bd_iordy),
//	     .bd_state(spy_bd_state)
//`else
//	     .bd_cmd(),
//	     .bd_start(),
//	     .bd_bsy(1'b0),
//	     .bd_rdy(1'b0),
//	     .bd_err(1'b0),
//	     .bd_addr(),
//	     .bd_data_in(16'b0),
//	     .bd_data_out(),
//	     .bd_rd(),
//	     .bd_wr(),
//	     .bd_iordy(1'b0),
//	     .bd_state(spy_bd_state[11:0])
// `endif
//		     );
//`else   
//   assign      eadr = 4'b0;
//   assign      dbread = 0;
//   assign      dbwrite = 0;
//   assign      spyin = 0;
//   assign      rs232_txd = 1'b1;
//`endif
   
   lx45_ram_controller rc (
			   .sysclk_in(sysclk/*sysclk_buf*/),
			   .lpddr_clk_out(),
			   .lpddr_reset(lpddr_reset),
			   .lpddr_calib_done(lpddr_calib_done),
			   
			   .clk(clk50),
			   .vga_clk(pixclk/*clk50*/),
			   .cpu_clk(cpuclk),
			   .reset(reset),
			   .prefetch(prefetch),
			   .fetch(fetch),
			   .machrun(machrun),
			   .state_out(rc_state),

			   .mcr_addr(mcr_addr),
			   .mcr_data_out(mcr_data_in),
			   .mcr_data_in(mcr_data_out),
			   .mcr_ready(mcr_ready),
			   .mcr_write(mcr_write),
			   .mcr_done(mcr_done),

			   .sdram_addr(sdram_addr),
			   .sdram_data_in(sdram_data_cpu2rc),
			   .sdram_data_out(sdram_data_rc2cpu),
			   .sdram_req(sdram_req),
			   .sdram_ready(sdram_ready),
			   .sdram_write(sdram_write),
			   .sdram_done(sdram_done),
      
			   .vram_cpu_addr(vram_cpu_addr),
			   .vram_cpu_data_in(vram_cpu_data_out),
			   .vram_cpu_data_out(vram_cpu_data_in),
			   .vram_cpu_req(vram_cpu_req),
			   .vram_cpu_ready(vram_cpu_ready),
			   .vram_cpu_write(vram_cpu_write),
			   .vram_cpu_done(vram_cpu_done),
      
			   .vram_vga_addr(vram_vga_addr),
			   .vram_vga_data_out(vram_vga_data_out),
			   .vram_vga_req(vram_vga_req),
			   .vram_vga_ready(vram_vga_ready),

			   .mcb3_dram_dq(mcb3_dram_dq),
			   .mcb3_dram_a(mcb3_dram_a),
			   .mcb3_dram_ba(mcb3_dram_ba),
			   .mcb3_dram_cke(mcb3_dram_cke),
			   .mcb3_dram_ras_n(mcb3_dram_ras_n),
			   .mcb3_dram_cas_n(mcb3_dram_cas_n),
			   .mcb3_dram_we_n(mcb3_dram_we_n),
			   .mcb3_dram_dm(mcb3_dram_dm),
			   .mcb3_dram_udqs(mcb3_dram_udqs),
			   .mcb3_rzq(mcb3_rzq),
			   .mcb3_dram_udm(mcb3_dram_udm),
			   .mcb3_dram_dqs(mcb3_dram_dqs),
			   .mcb3_dram_ck(mcb3_dram_ck),
			   .mcb3_dram_ck_n(mcb3_dram_ck_n)
			   );
//`else
//   assign eadr = 4'b0;
//   assign dbread = 0;
//   assign dbwrite = 0;
//   assign spyin = 0;
//   assign rs232_txd = 1'b1;
// `endif

//`ifdef use_mmc
//   mmc_block_dev mmc_bd(
//			.clk(clk50),
//			.reset(reset),
//   			.bd_cmd(bd_cmd),
//			.bd_start(bd_start),
//			.bd_bsy(bd_bsy),
//			.bd_rdy(bd_rdy),
//			.bd_err(bd_err),
//			.bd_addr(bd_addr),
//			.bd_data_in(bd_data_cpu2bd),
//			.bd_data_out(bd_data_bd2cpu),
//			.bd_rd(bd_rd),
//			.bd_wr(bd_wr),
//			.bd_iordy(bd_iordy),
//			.bd_state(bd_state),
//
//			.mmc_cs(mmc_cs),
//			.mmc_di(mmc_di),
//			.mmc_do(mmc_do),
//			.mmc_sclk(mmc_sclk)
//			);
// `else
//   assign bd_bsy = 0;
//   assign bd_rdy = 0;
//   assign bd_err = 0;
//   assign bd_data_out = 0;
//   assign bd_iordy = 0;
//`endif

//`ifdef spy_mmc
//   mmc_block_dev mmc_bd(
//			.clk(clk50),
//			.reset(reset),
//   			.bd_cmd(spy_bd_cmd),
//			.bd_start(spy_bd_start),
//			.bd_bsy(spy_bd_bsy),
//			.bd_rdy(spy_bd_rdy),
//			.bd_err(spy_bd_err),
//			.bd_addr(spy_bd_addr),
//			.bd_data_in(spy_bd_data_cpu2bd),
//			.bd_data_out(spy_bd_data_bd2cpu),
//			.bd_rd(spy_bd_rd),
//			.bd_wr(spy_bd_wr),
//			.bd_iordy(spy_bd_iordy),
//			.bd_state(spy_bd_state),
//				  
//			.mmc_cs(mmc_cs),
//			.mmc_di(mmc_di),
//			.mmc_do(mmc_do),
//			.mmc_sclk(mmc_sclk)
//			);
//`endif
//   
//`ifdef use_vga
//   wire vga_red, vga_blu, vga_grn, vga_blank;
//
//   assign vga_r = vga_red;
//   assign vga_g = vga_grn;
//   assign vga_b = vga_blu;
//   
//   vga_display vga (.clk(clk50),
//		    .pixclk(pixclk),
//		    .reset(vga_reset),
//
//		    .vram_addr(vram_vga_addr),
//		    .vram_data(vram_vga_data_out),
//		    .vram_req(vram_vga_req),
//		    .vram_ready(vram_vga_ready),
//      
//		    .vga_red(vga_red),
//		    .vga_blu(vga_blu),
//		    .vga_grn(vga_grn),
//		    .vga_hsync(vga_hsync),
//		    .vga_vsync(vga_vsync),
//		    .vga_blank(vga_blank)
//		    );
//
//`else
//   assign vram_vga_req = 0;
//   assign vga_r = 0;
//   assign vga_g = 0;
//   assign vga_b = 0;
//   assign vga_hsync = 0;
//   assign vga_vsync = 0;
//`endif

//`ifdef use_hdmi
//   wire [7:0] red_data, blu_data, grn_data;
//   assign red_data = vga_red ? 8'hff : 8'h00;
//   assign blu_data = vga_blu ? 8'hff : 8'h00;
//   assign grn_data = vga_grn ? 8'hff : 8'h00;
//   
//   dvid_output dvid (
//		     .clk50(sysclk_buf/*clk50*/),
//		     .reset(reset),
//		     .reset_clk(dcm_reset),
//		     .red(red_data),
//		     .green(blu_data),
//		     .blue(grn_data),
//		     .hsync(vga_hsync),
//		     .vsync(vga_vsync),
//		     .blank(vga_blank),
//		     .clk_vga_out(pixclk),
//		     .tmds(tmds),
//		     .tmdsb(tmdsb)
//		     );
//`else
   // generate xsvga clock (108Mhz)
   logic pixclk_locked;

   clocking_m clocking_inst(
			  .CLK_50(sysclk_buf/*sysclk*//*sysclk_buf*/),
			  .CLK_VGA(pixclk),
			  .RESET(dcm_reset),
			  .LOCKED(pixclk_locked)
			  );

   assign vga_reset = reset;
   assign clk50 = sysclk_buf;

   //
//   reg [3:0] clkcnt;
//   initial
//     clkcnt = 0;
//   always @(posedge clk50/*sysclk_buf*/)
//     clkcnt <= clkcnt + 4'd1;
//   BUFG cpuclk_bufg (.I(clkcnt[0]), .O(cpuclk));
   assign cpuclk = clk50;
      
   // dummy drivers
//   logic [3:0] tmds_dummy;
//   OBUFDS obufds_0(.I(tmds_dummy[0]), .O(tmds[0]), .OB(tmdsb[0]));
//   OBUFDS obufds_1(.I(tmds_dummy[1]), .O(tmds[1]), .OB(tmdsb[1]));
//   OBUFDS obufds_2(.I(tmds_dummy[2]), .O(tmds[2]), .OB(tmdsb[2]));
//   OBUFDS obufds_3(.I(tmds_dummy[3]), .O(tmds[3]), .OB(tmdsb[3]));
//`endif
   
//`ifdef use_ps2
//   wire   kb_ps2_clk_in;
//   wire   kb_ps2_data_in;
//   wire   ms_ps2_clk_in;
//   wire   ms_ps2_data_in;
//   wire   ms_ps2_clk_out;
//   wire   ms_ps2_data_out;
//   wire   ms_ps2_dir;
//
//   assign kb_ps2_clk_in = ps2_clk;
//   assign kb_ps2_data_in = ps2_data;
//
//   assign ms_ps2_clk_in = ms_ps2_clk;
//   assign ms_ps2_data_in = ms_ps2_data;
//
//   assign ms_ps2_clk = ms_ps2_dir ? ms_ps2_clk_out : 1'bz;
//   assign ms_ps2_data = ms_ps2_dir ? ms_ps2_data_out : 1'bz;
//   
//   ps2_support ps2_support(
//			   .clk(cpuclk),
//			   .reset(reset),
//			   .kb_ps2_clk_in(kb_ps2_clk_in),
//			   .kb_ps2_data_in(kb_ps2_data_in),
//			   .ms_ps2_clk_in(ms_ps2_clk_in),
//			   .ms_ps2_data_in(ms_ps2_data_in),
//			   .ms_ps2_clk_out(ms_ps2_clk_out),
//			   .ms_ps2_data_out(ms_ps2_data_out),
//			   .ms_ps2_dir(ms_ps2_dir),
//			   .kb_data(kb_data),
//			   .kb_ready(kb_ready),
//			   .ms_x(ms_x),
//			   .ms_y(ms_y),
//			   .ms_button(ms_button),
//			   .ms_ready(ms_ready)
//			   );
//`else
//   assign ps2_clk = 1'bz;
//   assign ps2_data = 1'bz;
//
//   assign kb_ready = 0;
//   assign kb_data = 0;
//   
//   assign ms_ready = 0;
//   assign ms_x = 0;
//   assign ms_y = 0;
//   assign ms_button = 0;
//`endif

//   assign led[4] = disk_state[3];
//   assign led[3] = machrun;
//   assign led[2] = disk_state[2];
//   assign led[1] = disk_state[1];
//   assign led[0] = disk_state[0];

   assign led[4] = disk_state[3];
   assign led[3] = machrun;
   assign led[2] = boot;
   assign led[1] = reset;
   assign led[0] = switch;


endmodule
