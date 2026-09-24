/*
Monash University ECE2072: Assignment 
This file contains Verilog code to implement individual components to be used in 
    the CPU.

Please enter your name and student ID: 
35056401 Kai Chun Wong
34146636 Bao Tri Truong
*/

module sign_extend (
	/* * This module sign extends the 9-bit Din to a 16-bit output.
	 */
	// TODO: Declare inputs and outputs
	input [8:0] in,
	output [15:0] ext
	);
	// TODO: implement logic
	assign ext = {{7{in[8]}}, in};
endmodule

module tick_FSM (
	/* * This module implements a tick FSM that will be used to
	 * control the actions of the control unit
	 */

	// TODO: Declare inputs and outputs
	input enable,
	input clk,
	input rst,
	output reg [3:0] tick
	);
    // TODO: implement FSM
	always @(posedge clk) begin
		if (rst) tick <= 4'b0001;
		else if (enable) begin
			case (tick) 
				// Ones hot encoding logic in a 4 bit tick_FSM
				4'b0001: tick <= 4'b0010;  // tick 1 -> tick 2
				4'b0010: tick <= 4'b0100;  // tick 2 -> tick 3
				4'b0100: tick <= 4'b1000;  // tick 3 -> tick 4
				4'b1000: tick <= 4'b0001;  // tick 4 -> tick 1
				default: tick <= 4'b0001;  // otherwise fixed the tick as reset
			endcase
		end
    end 
endmodule 

module multiplexer (
	/* * This module takes 10 inputs and places the correct input onto the bus.
	 */
	// TODO: Declare inputs and outputs
	// Correction: The comma (,) was misplaced in the list of inputs in the original code. 
	// It should only separate the last input/output from the selector.
	input [15:0] SignExtDin, R0, R1, R2, R3, R4, R5, R6, R7,
	input [15:0] G,
	input [3:0] sel,
	output reg [15:0] Bus
	);
	// TODO: implement logic
	always @(*) begin
		case (sel)
			4'd0: Bus = R0;
			4'd1: Bus = R1;
			4'd2: Bus = R2;
			4'd3: Bus = R3;
			4'd4: Bus = R4;
			4'd5: Bus = R5;
			4'd6: Bus = R6;
			4'd7: Bus = R7;
			4'd8: Bus = G;
			4'd9: Bus = SignExtDin;
		default: Bus = 16'h0000;
		endcase
	end
endmodule

module ALU (
	/* * This module implements the arithmetic logic unit of the processor.
	 */
	// TODO: declare inputs and outputs
	input [15:0] input_a, 
	input [15:0] input_b, 
	input [2:0] alu_op,
	output reg [15:0] result
	);
	
	always @(*) begin
		case(alu_op) 
			3'b000: result = input_a * input_b;  // 000 - Multiplication
			3'b001: result = input_a + input_b;  // 001 - Addition
			3'b010: result = input_a - input_b;  // 010 - Subtraction
			3'b011: begin 
				if ($signed(input_a) > 0) 
					result = input_b <<< $signed(input_a);  // Shifted by left (Arithmetic or Logical depending on context)
				else if ($signed(input_a) < 0) 
					result = input_b >>> (-$signed(input_a));  // Shifted by right (Arithmetic for signed data, Logical for unsigned)
				else 
					result = input_b;
				end 
			default: result = 16'b0;  // Set the default value as 0 if it is not in any operation above 
		endcase
	end
endmodule

module register_n #(
	// To set parameter N during instantiation, you can use:
	// register_n #(.N(num_bits)) reg_IR(.....), 
	// where num_bits is how many bits you want to set N to
	// and "..." is your usual input/output signals

	parameter N = 16) (

	/* * This module implements registers that will be used in the processor.
	 */
	// TODO: Declare inputs, outputs, and parameter:
	input  r_in,
	input [N-1:0] data_in,
	input clk,
	input rst,
	output reg [N-1:0] Q
	);
	// TODO: Implement register logic:
	always @(posedge clk) begin
		if (rst) 
			Q <= {N{1'b0}};  // Non-blocking assignment to update synchronously
		else if (r_in)
			Q <= data_in;	
	end
endmodule