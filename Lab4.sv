`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/26/2018 11:45:26 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// Written by David_Harris@hmc.edu

// Top level system including MIPS and memories


module top(input   logic 	 clk, reset,button,                    

	        output  logic       memwrite,  

	     output logic [3:0]an,

	     output logic[6:0]C,

	     output logic DP);

   logic  [31:0] instrOut;        

   logic[31:0] writedata, dataadr;

   logic [31:0] pc,instr,readdata;

   //assign pcOut = pc;

   //assign instrOut = instr;  

   logic clk_pulse;  



   

   top_old (clk_pulse,reset,pc,instr,writedata,dataadr,memwrite); 

   display_controller (clk,reset,4'b1111,writedata[7:4],writedata[3:0],dataadr[7:4],dataadr[3:0],an,C,DP);

   pulse_controller (clk,button,reset,clk_pulse); 

endmodule



module top_old(input   logic 	 clk, reset,            

	     output  logic[31:0] writedata, dataadr,pcOut,instrOut,            

	     output  logic memwrite);  



   logic [31:0] pc, instr, readdata;

   assign pcOut = pc;

   assign instrOut= instr;    



   // instantiate processor and memories  

   mips mips (clk, reset, pc, instr, memwrite, dataadr, writedata, readdata);  

   imem imem (pc[7:2], instr);  

   dmem dmem (clk, memwrite, dataadr, writedata, readdata);



endmodule



// External instruction memory used by MIPS single-cycle

// processor. It models instruction memory as a stored-program 

// ROM, with address as input, and instruction as output





module imem ( input logic [5:0] addr, output logic [31:0] instr);



// imem is modeled as a lookup table, a stored-program byte-addressable ROM

	always_comb

	   case ({addr,2'b00})		   	// word-aligned fetch

//		address		instruction

//		-------		-----------
        
//	    8'h00: instr = 32'h20020005;  	// disassemble, by hand 

//		8'h04: instr = 32'h2003000c;  	// or with a program,

//		8'h08: instr = 32'h2067fff7;  	// to find out what

//		8'h0c: instr = 32'h00e22025;  	// this program does!

//		8'h10: instr = 32'h00642824;

//		8'h14: instr = 32'h00a42820;

//		8'h18: instr = 32'h10a70002;

//		8'h1c: instr = 32'h0c020001; // lui

//		8'h20: instr = 32'h04400003; // bge

//		8'h24: instr = 32'h20020005;

//		8'h28: instr = 32'h00e2202a;

//		8'h2c: instr = 32'h00853820;

//		8'h30: instr = 32'h00e23822;

//		8'h34: instr = 32'hac670044;

//		8'h38: instr = 32'h8c020050;

//		8'h3c: instr = 32'h08000011;

//		8'h40: instr = 32'h20020001;

//		8'h44: instr = 32'hac020054;

//		8'h48: instr = 32'h08000012;	// j 48, so it will loop here
//	     default:  instr = {32{1'bx}};	// unknown address
8'h00: instr = 32'h20020005;  // addi v0,0,5 
8'h04: instr = 32'h2003000c;   //	addi$ v1, $0 ,12

8'h08: instr = 32'h2067fff0;   //  	addi $a3 ,$v1, -9

8'h0c: instr = 32'h00e22025;   // or $a0, $a3, $v0

8'h10: instr = 32'h00642824;	//and $a1, $v1, $a0

8'h14: instr = 32'h00a42820;	//add $a1, $a1, $a0
8'h18: instr = 32'h10a70002;	//beq $a1, $a3, 0x0002

8'h1c: instr = 32'h0c020001; // lui lui $v0,0001

8'h20: instr = 32'h04400003; // bge bge $v0, $0, 0x3

8'h24: instr = 32'h20020005;	//addi $v0, $0, 5

8'h28: instr = 32'h00e2202a;	//slt $a0, $a3, $v0

8'h2c: instr = 32'h0400002; // bge bge $0, $0, 0x2

8'h30: instr = 32'h00e23822;   	//sub $a3, $a3, $v0

8'h34: instr = 32'hac670044; 	//sw $a3, 44($v1)

8'h38: instr = 32'h8c020050;	//lw $v0,50($0)

8'h3c: instr = 32'h08000011;	//j 0x11

8'h40: instr = 32'h20020001;	//addi  $v0, $0, 1

8'h44: instr = 32'hac020054;	//sw v0, 54($0)

8'h48: instr = 32'h08000012; // j 48, so it will loop here j 0x12
     default:  instr = {32{1'bx}}; // unknown address


	   endcase

endmodule

// External data memory used by MIPS single-cycle processor

module dmem (input  logic        clk, we,

             input  logic[31:0]  a, wd,

             output logic[31:0]  rd);



   logic  [31:0] RAM[63:0];

  

   assign rd = RAM[a[31:2]];    // word-aligned  read (for lw)



   always_ff @(posedge clk)

     if (we)

       RAM[a[31:2]] <= wd;      // word-aligned write (for sw)



endmodule

// single-cycle MIPS processor, with controller and datapath

module mips (input  logic        clk, reset,

             output logic[31:0]  pc,

             input  logic[31:0]  instr,

             output logic        memwrite,

             output logic[31:0]  aluout, writedata,

             input  logic[31:0]  readdata);



  logic        memtoreg, pcsrc, zero, alusrc, regdst, regwrite, jump,bge,luisignal,branch;

  logic [2:0]  alucontrol;
  
  logic [31:0] aluresult;
  //assign aluresult = aluout;
  
  logic andResult1,andResult2;
 
 
  controller  c(instr[31:26], instr[5:0], zero, memtoreg, memwrite, pcsrc,

                        alusrc, regdst, regwrite, jump, alucontrol,bge,luisignal,branch);

  datapath  d(clk, reset, memtoreg, pcsrc, alusrc, regdst, regwrite, jump,

                          alucontrol, zero, pc, instr, aluout, writedata, readdata,bge,luisignal,branch);
     
     //andGate     first(branch,zero,andResult1);
    // andGate     second(bge,!aluout[31:30],andResult2);
     //orGate      endbta(andResult1,andResult2,pcsrc);
    
    

endmodule

module controller(input  logic[5:0] op, funct,

                  input  logic     zero,

                  output logic     memtoreg, memwrite,

                  output logic     pcsrc, alusrc,

                  output logic     regdst, regwrite,

                  output logic     jump,

                  output logic[2:0] alucontrol,
                  output logic bge,
                  output logic luisignal,
                  output logic branch
                  );



   logic [1:0] aluop;

   //logic       branch;



   maindec md (op, memtoreg, memwrite, branch, alusrc, regdst, regwrite, 

		 jump, aluop,bge,luisignal);



   aludec  ad (funct, aluop, alucontrol);



   assign pcsrc = branch & zero;



endmodule



module maindec (input logic[5:0] op, 

	              output logic memtoreg, memwrite, branch,

	              output logic alusrc, regdst, regwrite, jump,

	              output logic[1:0] aluop,
	              output logic bge,
	              output logic luisignal );

   logic [10:0] controls;



   assign {regwrite, regdst, alusrc, branch, memwrite,

                memtoreg,  aluop, jump,bge,luisignal} = controls;



  always_comb

    case(op)

          6'b000000: controls  = 11'b11000010000; //Rtype

          6'b100011: controls  = 11'b10100100000; //LW

          6'b101011: controls  = 11'b00101000000; //SW

          6'b000100: controls  = 11'b00010001000; //BEQ

          6'b001000: controls  = 11'b10100000000; //ADDI

          6'b000010: controls  = 11'b00000000100; //J
          
          6'b000001: controls <= 11'b00010001010;  // bge
          6'b000011: controls <= 11'b10000000001; // lui

          default:       controls  = 11'bxxxxxxxxx;    //???

    endcase

endmodule



module aludec (input    logic[5:0] funct,

               input    logic[1:0] aluop,

               output   logic[2:0] alucontrol);

  always_comb

    case(aluop)

      2'b00: alucontrol  = 3'b010;  // add  (for lw/sw/addi)

      2'b01: alucontrol  = 3'b110;  // sub   (for beq)

      default: case(funct)          // R-TYPE instructions

          6'b100000: alucontrol  = 3'b010; // ADD

          6'b100010: alucontrol  = 3'b110; // SUB

          6'b100100: alucontrol  = 3'b000; // AND

          6'b100101: alucontrol  = 3'b001; // OR

          6'b101010: alucontrol  = 3'b111; // SLT

          default:   alucontrol  = 3'bxxx; // ???

        endcase

    endcase

endmodule



module datapath (input  logic clk, reset, memtoreg, pcsrc, alusrc, regdst,

                 input  logic regwrite, jump, 

		 input  logic[2:0]  alucontrol, 

                 output logic zero, 

		 output logic[31:0] pc, 

	         input  logic[31:0] instr,

                 output logic[31:0] aluout, writedata, 

	         input  logic[31:0] readdata,
	         input logic bge,
	         input logic luisignal,
	         input logic branch
	         );



  logic [4:0]  writereg;

  logic [31:0] pcnext, pcnextbr, pcplus4, pcbranch;

  logic [31:0] signimm, signimmsh, srca, srcb, luiresult,first_result , result;
    
  logic btaresult;  
  
  //logic andResult1,andResult2;
  
  //assign pcsrc = (branch & zero) | ( bge & !aluout[31]);  
 
  assign btaresult = pcsrc | (bge & !aluout[31:30] );
  // next PC logic

  flopr #(32) pcreg(clk, reset, pcnext, pc);

  adder       pcadd1(pc, 32'b100, pcplus4);

  sl2         immsh(signimm, signimmsh);
  
  sl16        lastim(signimm,luiresult); // lui result 
  //sl2        lastim(signimmsh,luiresult)
  //sl2        lastim(signimmsh,luiresult)
  //sl2        lastim(signimmsh,luiresult)

  adder       pcadd2(pcplus4, signimmsh, pcbranch);

  mux2 #(32)  pcbrmux(pcplus4, pcbranch, btaresult,

                      pcnextbr);

  mux2 #(32)  pcmux(pcnextbr, {pcplus4[31:28], 

                    instr[25:0], 2'b00}, jump, pcnext);



// register file logic

   regfile     rf (clk, regwrite, instr[25:21], instr[20:16], writereg,

                   result, srca, writedata);



   mux2 #(5)    wrmux (instr[20:16], instr[15:11], regdst, writereg);

   mux2 #(32)  resmux (aluout, readdata, memtoreg, first_result); 
   mux2 #(32)  res2mux (first_result,luiresult , luisignal, result); // lui result or normal result

   signext         se (instr[15:0], signimm);



  // ALU logic

   mux2 #(32)  srcbmux (writedata, signimm, alusrc, srcb);

   alu         alu (srca, srcb, alucontrol, aluout, zero);
   //andGate     first(branch,zero,andResult1);
   //andGate     second(bge,!aluout[31:30],andResult2);
   //orGate      endbta(andResult1,andResult2,pcsrc);
 

endmodule





module regfile (input    logic clk, we3, 

                input    logic[4:0]  ra1, ra2, wa3, 

                input    logic[31:0] wd3, 

                output   logic[31:0] rd1, rd2);



  logic [31:0] rf [31:0];



  // three ported register file: read two ports combinationally

  // write third port on rising edge of clock. Register0 hardwired to 0.



  always_ff@(posedge clk)

     if (we3) 

         rf [wa3] <= wd3;	



  assign rd1 = (ra1 != 0) ? rf [ra1] : 0;

  assign rd2 = (ra2 != 0) ? rf[ ra2] : 0;



endmodule





module adder (input  logic[31:0] a, b,

              output logic[31:0] y);

     

     assign y = a + b;

endmodule



module sl2 (input  logic[31:0] a,

            output logic[31:0] y);

     

     assign y = {a[29:0], 2'b00}; // shifts left by 2

endmodule


module sl16 (input  logic[31:0] a,
            output logic[31:0] y);
     assign y = {a[15:0], 16'b0000000000000000}; // shifts left by 2
endmodule


module signext (input  logic[15:0] a,

                output logic[31:0] y);

              

  assign y = {{16{a[15]}}, a};    // sign-extends 16-bit a

endmodule



// parameterized register

module flopr #(parameter WIDTH = 8)

              (input logic clk, reset, 

	       input logic[WIDTH-1:0] d, 

               output logic[WIDTH-1:0] q);



  always_ff@(posedge clk, posedge reset)

    if (reset) q <= 0; 

    else       q <= d;

endmodule





// paramaterized 2-to-1 MUX

module mux2 #(parameter WIDTH = 8)

             (input  logic[WIDTH-1:0] d0, d1,  

              input  logic s, 

              output logic[WIDTH-1:0] y);

  

   assign y = s ? d1 : d0; 

endmodule





module alu(input  logic [31:0] a, b, 

           input  logic [2:0]  alucont, 

           output logic [31:0] result,

           output logic zero);

   

    assign zero = (result==0); 

           always @(alucont, a, b) begin //reevaluate if these change

               case (alucont)

                   0: result <= a & b; //000 and

                   1: result <= a | b; //  001 or

                   2: result <= a + b; // 010 add

                   6: result <= a - b; // 110 sub

                   7: result <= a < b ? 1 : 0; // set less than

                   default: result <= 0;

               endcase

           end      




  // The details are to be filled..

  // HINT: Do a lookup according to the alucont signal for result(s)

endmodule

module display_controller (
		input logic clk, clear,
		input logic [3:0] enables, 
		input logic [3:0] digit3, digit2, digit1, digit0,
		output logic [3:0] AN,
		output logic [6:0] C,
		output logic       DP
		);

		logic [3:0] current_digit, cur_dig_AN;
		logic [6:0] segments;
		
      assign AN = ~(enables & cur_dig_AN);// AN signals are active low on the BASYS3 board,
                                // and must be enabled in order to display the digit
      assign C = ~segments;     // segments must be inverted, since the C values are active low
      assign DP = 1;            // makes the dot point always off 
                                // (0 = on, since it is active low)

// the 19-bit counter, runs at 100 MHz, so bit17 changes each 131072 clock cycles, 
//   or about once each 1.3 millisecond. Turning on and off the digits at this rate will
//   fool the human eye and make them appear to be on continuously
	   localparam N=19;
	   logic [N-1:0] count;
	always_ff @(posedge clk, posedge clear)
		if(clear) count <= 0;
		else count <= count + 1;	

// the upper 2 bits of count will cycle through the digits and the AN patterns
//  from left to right across the display unit			
	always_comb
	   case (count[N-1:N-2])
                // left most, AN3  
		2'b00: begin current_digit = digit3; cur_dig_AN = 4'b1000; end  
		2'b01: begin current_digit = digit2; cur_dig_AN = 4'b0100; end
		2'b10: begin current_digit = digit1; cur_dig_AN = 4'b0010; end
		2'b11: begin current_digit = digit0; cur_dig_AN = 4'b0001; end
                // right most, AN0
		default: begin current_digit = 4'bxxxx; cur_dig_AN = 4'bxxxx; end
	   endcase

// the hex-to-7-segment decoder
	always_comb
		case (current_digit)
		4'b0000: segments = 7'b111_1110;  // 0
		4'b0001: segments = 7'b011_0000;  // 1
		4'b0010: segments = 7'b110_1101;  // 2
		4'b0011: segments = 7'b111_1001;  // 3
		4'b0100: segments = 7'b011_0011;  // 4
		4'b0101: segments = 7'b101_1011;  // 5
		4'b0110: segments = 7'b101_1111;  // 6
		4'b0111: segments = 7'b111_0000;  // 7
		4'b1000: segments = 7'b111_1111;  // 8
		4'b1001: segments = 7'b111_0011;  // 9
		4'b1010: segments = 7'b111_0111;  // A
		4'b1011: segments = 7'b001_1111;  // b
		4'b1100: segments = 7'b000_1101;  // c
		4'b1101: segments = 7'b011_1101;  // d
		4'b1110: segments = 7'b100_1111;  // E
		4'b1111: segments = 7'b100_0111;  // F
		default: segments = 7'bxxx_xxxx;
		endcase		
endmodule



module pulse_controller(
	input CLK, sw_input, clear,
	output reg clk_pulse );

	 reg [2:0] state, nextstate;
	 reg [27:0] CNT; 
	 wire cnt_zero; 

	always @ (posedge CLK, posedge clear)
	   if(clear)
	    	state <=3'b000;
	   else
	    	state <= nextstate;

	always @ (sw_input, state, cnt_zero)
          case (state)
             3'b000: begin if (sw_input) nextstate = 3'b001; 
                           else nextstate = 3'b000; clk_pulse = 0; end	     
             3'b001: begin nextstate = 3'b010; clk_pulse = 1; end
             3'b010: begin if (cnt_zero) nextstate = 3'b011; 
                           else nextstate = 3'b010; clk_pulse = 1; end
             3'b011: begin if (sw_input) nextstate = 3'b011; 
                           else nextstate = 3'b100; clk_pulse = 0; end
             3'b100: begin if (cnt_zero) nextstate = 3'b000; 
                           else nextstate = 3'b100; clk_pulse = 0; end
            default: begin nextstate = 3'b000; clk_pulse = 0; end
          endcase

	always @(posedge CLK)
	   case(state)
		3'b001: CNT <= 100000000;
		3'b010: CNT <= CNT-1;
		3'b011: CNT <= 100000000;
		3'b100: CNT <= CNT-1;
	   endcase

//  reduction operator |CNT gives the OR of all bits in the CNT register	
	assign cnt_zero = ~|CNT;

endmodule


module alu_testbench( );

logic [31:0] a, b; 

logic [2:0]  alucont; 

logic [31:0] result;

logic zero;

alu x(a,b,alucont,result,zero);

   

   initial begin 

   // a = 12 b = 9  

   

    // test and

    a <= 32'b0000_1100 ; b <=32'b0000_1001 ; alucont <= 3'b000;

    #100;



    // test or  

    alucont <= 3'b001;

    #100;



    // test add

    alucont <= 3'b010;

    #100;

    

    // test sub

    alucont <= 3'b110;

    #100;



    // test set less than

     alucont <= 3'b111;

      #1;

    

  end

endmodule






#------------------------------------------------------------

#---------------------- Clock signal ------------------------

#------------------------------------------------------------

set_property PACKAGE_PIN W5 [get_ports clk]  	 	 	 	  

set_property IOSTANDARD LVCMOS33 [get_ports clk] 

create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk] 

##Buttons

set_property PACKAGE_PIN U18 [get_ports button]						

set_property IOSTANDARD LVCMOS33 [get_ports button]



## LEDs

set_property PACKAGE_PIN U16 [get_ports {memwrite}]					

set_property IOSTANDARD LVCMOS33 [get_ports {memwrite}]



## Switches

set_property PACKAGE_PIN V17 [get_ports {reset}]					

set_property IOSTANDARD LVCMOS33 [get_ports {reset}]

 	

     #------------------------------------------------------------

     #-------------------- 7 segment display ---------------------

     #------------------------------------------------------------

     set_property PACKAGE_PIN W7 [get_ports {C[6]}]                          

          set_property IOSTANDARD LVCMOS33 [get_ports C[6]] 

     set_property PACKAGE_PIN W6 [get_ports {C[5]}]                          

          set_property IOSTANDARD LVCMOS33 [get_ports C[5]] 

     set_property PACKAGE_PIN U8 [get_ports {C[4]}]                          

          set_property IOSTANDARD LVCMOS33 [get_ports C[4]] 

     set_property PACKAGE_PIN V8 [get_ports {C[3]}]                          

          set_property IOSTANDARD LVCMOS33 [get_ports C[3]] 

     set_property PACKAGE_PIN U5 [get_ports {C[2]}]                          

          set_property IOSTANDARD LVCMOS33 [get_ports C[2]] 

     set_property PACKAGE_PIN V5 [get_ports {C[1]}]                          

          set_property IOSTANDARD LVCMOS33 [get_ports C[1]] 

     set_property PACKAGE_PIN U7 [get_ports {C[0]}]                          

          set_property IOSTANDARD LVCMOS33 [get_ports C[0]] 

          

          

     set_property PACKAGE_PIN V7 [get_ports {DP}]                       

          set_property IOSTANDARD LVCMOS33 [get_ports DP] 

         

     set_property PACKAGE_PIN U2 [get_ports an[0]]                          

          set_property IOSTANDARD LVCMOS33 [get_ports an[0]] 

     set_property PACKAGE_PIN U4 [get_ports an[1]]                          

          set_property IOSTANDARD LVCMOS33 [get_ports an[1]] 

     set_property PACKAGE_PIN V4 [get_ports an[2]]                          

          set_property IOSTANDARD LVCMOS33 [get_ports an[2]] 

     set_property PACKAGE_PIN W4 [get_ports an[3]]                          

          set_property IOSTANDARD LVCMOS33 [get_ports an[3]]



module top_testbench();

    

 logic 	 clk; 

    logic reset;            

    logic [31:0] writedata, datadr,pc,instruction;            

    logic       memwrite;

    top a (clk,reset,writedata,datadr,pc,instruction, memwrite);

    

    initial begin

    

    reset <= 1;#10;

    reset <= 0;

    

    end  

    always

    begin

    

    clk <= 1; # 5;

    clk <= 0; # 5;

    end   

endmodule
