module top (input logic clk,reset,EN,           
output logic [31:0] ResultW,instrOut,pcOut,
output logic MemWriteM);          
logic [31:0] WriteDataM; 
       
assign instrOut = instr;
assign pcOut = PCF;

logic CLR;
logic ALUSrcD,ALUSrcE;
logic RegDstD,RegDstE; 
logic BranchD,BranchM,BranchE;
logic [31:0] instr,instrD;
logic [31:0] PC,PCF,PCPlus4F,PCPlus4D,PCPlus4E;
logic PCSrcM;
logic [31:0] RD1, RD2;
logic [4:0] RsD, RtD, RdD;
logic [31:0] SignImmD,SignImmE;
logic RegWriteD,RegWriteE,RegWriteM,RegWriteW; 
logic MemWriteE,MemWriteD;
logic [2:0] ALUControlE,ALUControlD;
logic [31:0] RE1, RE2;
logic [4:0] RsE, RtE, RdE;
logic [31:0] SrcAE,SrcBE;
logic [31:0] WriteDataE;
logic ZeroE,ZeroM;
logic [4:0] WriteRegE,WriteRegM,WriteRegW;
logic [31:0] PCBranchE,PCBranchM;
logic  MemtoRegM, MemtoRegE,MemtoRegW,MemtoRegD;
logic [31:0] ALUOutM,ALUOutW,ALUOutE;
logic [31:0] ReadDataM,ReadDataW;
//logic [31:0] ResultW;
logic [1:0] ForwardAE, ForwardBE;
logic FlushE, StallD, StallF;
logic [31:0] temp1,temp2,temp3;

assign PCPlus4F = PCF + 4;
//adder       pcadd1(PCF, 32'b100, PCPlus4F);
assign RsD = instrD[25:21];
assign RtD = instrD[20:16];
assign RdD = instrD[15:11];
assign PCSrcM = BranchM & ZeroM;
 
controller control (instrD[31:26], instrD[5:0], MemtoRegD, MemWriteD, ALUSrcD, RegDstD, RegWriteD, ALUControlD, BranchD);
imem ins (PCF [7:2], instr);
dmem data(clk, MemWriteM, ALUOutM, WriteDataM, ReadDataM);
regfile regf( clk, RegWriteW, instr[25:21], instr[20:16], WriteRegW, ResultW, RD1, RD2);
// triple multiplexers' works in step by step with mux2
mux2   check1(RE1, ResultW, ForwardAE[0], temp1);
mux2   check2(temp1, ALUOutM, ForwardAE[1], SrcAE);
mux2   check3(RE2, ResultW, ForwardBE[0], temp2);
mux2   check4(temp2, ALUOutM, ForwardBE[1], WriteDataE);

mux2   src(WriteDataE, SignImmE, ALUSrcE, SrcBE);
mux2   resmux (ALUOutW,ReadDataW,MemtoRegW, ResultW);
mux2   pcmux (PCPlus4F, PCBranchM, PCSrcM, PC); // new Pc
mux2#(5) regmux (RtE, RdE, RegDstE, WriteRegE);

alu alu(SrcAE, SrcBE, ALUControlE, ALUOutE, ZeroE);
sl2 shift(SignImmE, temp3);
signext extend(instrD[15:0], SignImmD);
adder adding (temp3, PCPlus4E, PCBranchE);

PipeFtoD d (instr, PCPlus4F, EN, clk, instrD, PCPlus4D, StallD);
PipeWtoF f (PC, EN, clk, PCF, StallF,reset);
PipeMtoW w (clk,RegWriteM, MemtoRegM, ReadDataM, ALUOutM, WriteRegM,RegWriteW, MemtoRegW, ReadDataW, ALUOutW, WriteRegW);
PipeEtoM m (clk,RegWriteE, MemtoRegE, MemWriteE, BranchE, ZeroE, ALUOutE, WriteDataE, WriteRegE, PCBranchE,RegWriteM, MemtoRegM, MemWriteM, BranchM, ZeroM, ALUOutM, WriteDataM, WriteRegM, PCBranchM);
PipeDtoE e (clk,CLR,RegWriteD, MemtoRegD, MemWriteD, ALUControlD, ALUSrcD, RegDstD, BranchD, RD1, RD2, RsD, RtD, RdD, PCPlus4D, SignImmD,RegWriteE, MemtoRegE, MemWriteE, ALUControlE, ALUSrcE, RegDstE, BranchE, RE1, RE2, RsE, RtE, RdE, PCPlus4E, SignImmE, FlushE);

HazardUnit edenhazard (RegWriteW, WriteRegW, RegWriteM, MemtoRegM, WriteRegM, RegWriteE, MemtoRegE, RsE,RtE, RsD, RtD, ForwardAE, ForwardBE, FlushE, StallD, StallF, BranchD, BranchE, BranchM);

endmodule


module PipeFtoD(input logic[31:0] instr, PcPlus4F,
                input logic EN, clk,		// StallD will be connected as this EN
                output logic[31:0] instrD, PcPlus4D,
                input logic  StallD);
                
                always_ff @(posedge clk)
                    if(EN & !StallD)
                        begin
                        instrD<=instr;
                        PcPlus4D<=PcPlus4F;
                        end
                
endmodule

// Similarly, the pipe between Writeback (W) and Fetch (F) is given as follows.

module PipeWtoF(input logic[31:0] PC,
                input logic EN, clk,		// StallF will be connected as this EN
                output logic[31:0] PCF,
                input logic StallF,reset);
                           
                always_ff @(posedge clk)
                      if(reset) PCF <=0;   
                      else if(EN & !StallF)PCF<=PC;
                      
endmodule

// *******************************************************************************
// Below, write the modules for the pipes PipeDtoE, PipeEtoM, PipeMtoW yourselves.
// Don't forget to connect Control signals in these pipes as well.
// *******************************************************************************


module PipeDtoE(input logic clk,CLR,RegWriteD, MemtoRegD, MemWriteD, 
                input logic [2:0] ALUControlD,
                input logic ALUSrcD, RegDstD, BranchD, 
                input logic [31:0] RD1, RD2,
                input logic [4:0] RsD, RtD, RdD,
                input logic [31:0] PCPlus4D, SignImmD,
                output logic RegWriteE, MemtoRegE, MemWriteE, 
                output logic [2:0] ALUControlE,
                output logic ALUSrcE, RegDstE, BranchE,
                output logic [31:0] RE1, RE2,
                output logic [4:0] RsE, RtE, RdE,
                output logic [31:0] PCPlus4E, SignImmE,
                input FlushE);
                
                always_ff @(posedge clk)
                   if(CLR & !FlushE)
                       begin
                       RegWriteE <= RegWriteD;
                       MemtoRegE  <= MemtoRegD;
                       MemWriteE   <=MemWriteD;
                       ALUControlE <=ALUControlD;
                       ALUSrcE <=ALUSrcD;
                       RegDstE <= RegDstD;
                       BranchE <=BranchD;
                       RE1 <= RD1;
                       RE2 <= RD2;
                       RsE<=RsD;
                       RtE<=RtD;
                       RdE<=RdD;
                       PCPlus4E <= PCPlus4D;
                       SignImmE <= SignImmD;
                       end
                   else if(CLR & FlushE)
                           begin
                           RegWriteE <= 0;
                           MemtoRegE  <= 0;
                           MemWriteE   <=0;
                           ALUControlE <=0;
                           ALUSrcE <=0;
                           RegDstE <= 0;
                           BranchE <=0;
                           RE1 <= 0;
                           RE1 <= 0;
                           RsE<=0;
                           RtE<=0;
                           RdE<=0;
                           PCPlus4E <=0;
                           SignImmE <=0;
                           end
endmodule

module PipeEtoM(input logic clk,RegWriteE, MemtoRegE, MemWriteE,BranchE, ZeroE, 
                input logic [31:0] ALUOutE, WriteDataE,
                input logic [4:0] WriteRegE,
                input logic [31:0] PCBranchE,
                output logic RegWriteM, MemtoRegM, MemWriteM,BranchM, ZeroM, 
                output logic [31:0] ALUOutM, WriteDataM,
                output logic [4:0] WriteRegM,
                output logic [31:0] PCBranchM);
                
                
                always_ff @(posedge clk)
                       begin
                       RegWriteM  <= RegWriteE;
                       MemtoRegM  <= MemtoRegE;
                       MemWriteM  <= MemWriteE;
                       BranchM <= BranchE;
                       ZeroM <= ZeroE;
                       ALUOutM <= ALUOutE;
                       WriteDataM <= WriteDataE;
                       WriteRegM <= WriteRegE;
                       PCBranchM <= PCBranchE;
                       end
endmodule

module PipeMtoW(input logic clk,RegWriteM, MemtoRegM, 
                input logic [31:0] ReadDataM, ALUOutM,
                input logic [4:0] WriteRegM,
                output logic RegWriteW, MemtoRegW,  
                output logic [31:0] ReadDataW, ALUOutW,
                output logic [4:0] WriteRegW);
                
                always_ff @(posedge clk)
                       begin
                       RegWriteW  <= RegWriteM;
                       MemtoRegW  <= MemtoRegM;
                       ReadDataW  <= ReadDataM;
                       ALUOutW <= ALUOutM;
                       WriteRegW <= WriteRegM;
                       end    
                                 
endmodule

// Hazard Unit with inputs and outputs named
// according to the convention that is followed on the book.

module HazardUnit( input logic RegWriteW,
                input logic [4:0] WriteRegW,
                input logic RegWriteM, MemToRegM,
                input logic [4:0] WriteRegM,
                input logic RegWriteE, MemToRegE,
                input logic [4:0] rsE,rtE,
                input logic [4:0] rsD,rtD,
                output logic [1:0] ForwardAE,ForwardBE,
                output logic FlushE,StallD,StallF,
                input logic BranchD, BranchE, BranchM
    );
    
    logic lwstall, Bstall;
    
    always_comb
    begin
    
	if  ((rsE != 0) & (rsE == WriteRegM) & RegWriteM)     
          ForwardAE <= 10;
    else if ((rsE != 0) & (rsE == WriteRegW) & RegWriteW) 
          ForwardAE <= 01;
    else    
          ForwardAE <= 00;
    
    if  ((rtE != 0) & (rtE == WriteRegM) & RegWriteM)     
          ForwardBE <= 10;
    else if ((rtE != 0) & (rtE == WriteRegW) & RegWriteW) 
          ForwardBE <= 01;
    else    
          ForwardBE <= 00;
          
    
    lwstall <= ((rsD==rtE) | (rtD==rtE)) & MemToRegE;
        
    Bstall <= (BranchD | BranchE | BranchM);
    
    StallF <= (lwstall | Bstall);
    StallD <= (lwstall | Bstall);
    FlushE <= (lwstall | Bstall);
    
    end
endmodule


// External instruction memory used by MIPS single-cycle
// processor. It models instruction memory as a stored-program 
// ROM, with address as input, and instruction as output
// Modify it to test your own programs.

module imem ( input logic [5:0] addr, output logic [31:0] instr);

// imem is modeled as a lookup table, a stored-program byte-addressable ROM
	always_comb
	   case ({addr,2'b00})		   	// word-aligned fetch
//
// 	***************************************************************************
//	Here, you can paste your own test cases that you prepared for the part 1-g.
//	Below is a program from the single-cycle lab.
//	***************************************************************************

//		address		instruction
//		-------		-----------
		8'h00: instr = 32'h20020005;  	// disassemble, by hand 
		8'h04: instr = 32'h2003000c;  	// or with a program,
		8'h08: instr = 32'h2067fff7;  	// to find out what
		8'h0c: instr = 32'h00e22025;  	// this program does!
		8'h10: instr = 32'h00642824;
		8'h14: instr = 32'h00a42820;
		8'h18: instr = 32'h10a7000a;
		8'h1c: instr = 32'h0064202a;
		8'h20: instr = 32'h10800001;
		8'h24: instr = 32'h20050000;
		8'h28: instr = 32'h00e2202a;
		8'h2c: instr = 32'h00853820;
		8'h30: instr = 32'h00e23822;
		8'h34: instr = 32'hac670044;
		8'h38: instr = 32'h8c020050;
		8'h3c: instr = 32'h08000011;
		8'h40: instr = 32'h20020001;
		8'h44: instr = 32'hac020054;
		8'h48: instr = 32'h08000012;	// j 48, so it will loop here
	     default:  instr = {32{1'bx}};	// unknown address
	   endcase
endmodule


// 	***************************************************************************
//	Below are the modules that you shouldn't need to modify at all..
//	***************************************************************************

module controller(input  logic[5:0] op, funct,
                  output logic     memtoreg, memwrite,
                  output logic     alusrc,
                  output logic     regdst, regwrite,
                  output logic[2:0] alucontrol,
                  output logic branch);

   logic [1:0] aluop;

   maindec md (op, memtoreg, memwrite, branch, alusrc, regdst, regwrite, aluop);

   aludec  ad (funct, aluop, alucontrol);

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

module maindec (input logic[5:0] op, 
	              output logic memtoreg, memwrite, branch,
	              output logic alusrc, regdst, regwrite,
	              output logic[1:0] aluop );
   logic [7:0] controls;

   assign {regwrite, regdst, alusrc, branch, memwrite,
                memtoreg,  aluop} = controls;

  always_comb
    case(op)
      6'b000000: controls <= 8'b11000010; // R-type
      6'b100011: controls <= 8'b10100100; // LW
      6'b101011: controls <= 8'b00101000; // SW
      6'b000100: controls <= 8'b00010001; // BEQ
      6'b001000: controls <= 8'b10100000; // ADDI
      default:   controls <= 8'bxxxxxxxx; // illegal op
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

module regfile (input    logic clk, we3, 
                input    logic[4:0]  ra1, ra2, wa3, 
                input    logic[31:0] wd3, 
                output   logic[31:0] rd1, rd2);

  logic [31:0] rf [31:0];

  // three ported register file: read two ports combinationally
  // write third port on rising edge of clock. Register0 hardwired to 0.

  always_ff @(negedge clk)
     if (we3) 
         rf [wa3] <= wd3;	

  assign rd1 = (ra1 != 0) ? rf [ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ ra2] : 0;

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
endmodule


module adder (input  logic[31:0] a, b,
              output logic[31:0] y);
     
     assign y = a + b;
endmodule

module sl2 (input  logic[31:0] a,
            output logic[31:0] y);
     
     assign y = {a[29:0], 2'b00}; // shifts left by 2
endmodule

module signext (input  logic[15:0] a,
                output logic[31:0] y);
              
  assign y = {{16{a[15]}}, a};    // sign-extends 16-bit a
endmodule

// paramaterized 2-to-1 MUX
module mux2 #(parameter WIDTH = 32)
             (input  logic[WIDTH-1:0] d0, d1,  
              input  logic s, 
              output logic[WIDTH-1:0] y);
  
   assign y = s ? d1 : d0; 
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
