`timescale 1ns/1ns
/*
Monash University ECE2072: Assignment 
This file contains a Verilog test bench to test the correctness of the individual 
    components used in the processor.

Please enter your student ID:
35056401 Kai Chun Wong
34146636 Bao Tri Truong
*/

module components_tb;
    // TODO: Implement the logic of your testbench here
    reg clk, rst, enable;

    // Instantiate Sign Extender  (Pass)
    reg [8:0] in;
    wire [15:0] ext;
    reg [15:0] expected_ext;
    sign_extend module1_DUT (.in(in), .ext(ext));

    // Instantiate tick FSM  (FAIL)
    wire [3:0] tick; 	
    reg [3:0] expected_tick;	 
    tick_FSM module2_DUT (.enable(enable), .rst(rst), .clk(clk), .tick(tick));

    // Instantiate 10:1 MUX  (Pass)
    reg [15:0] SignExtDin,R0,R1,R2,R3,R4,R5,R6,R7,G;
    reg [3:0] sel;
    wire [15:0] Bus;
    reg [15:0] expected_bus;  // Mutiplexer
    multiplexer module3_DUT (.SignExtDin(SignExtDin), .R0(R0), .R1(R1), .R2(R2), .R3(R3), .R4(R4), .R5(R5), .R6(R6), .R7(R7), .G(G), .sel(sel), .Bus(Bus));

    // Instantiate ALU  
    reg [15:0] input_a, input_b;
    reg [2:0] alu_op;
    wire [15:0] result;
    reg signed [15:0] a, b;	
    reg [15:0] expected_result; 
    ALU module4_DUT (.input_a(input_a), .input_b(input_b), .alu_op(alu_op), .result(result));

    // Instantiate register_n  (Fail)
    reg r_in;
    reg [15:0] data_in;
    wire [15:0] Q; 
    reg [15:0] expected_Q;
    register_n module5_DUT (.r_in(r_in), .data_in(data_in), .Q(Q), .clk(clk), .rst(rst));

    // Generate clock
    always #5 clk = ~clk;
	
    integer tests_total, errors;
    integer i, j, k;

    // Testbench 
    initial begin
        enable = 0; in = 0;
        {R0,R1,R2,R3,R4,R5,R6,R7} = {8{16'h0000}};
        sel = 0; input_a = 0; input_b = 0; alu_op = 3'b000;
        r_in = 0; data_in = 16'h0000;
        clk = 0;  rst = 1;

		tests_total = 0; errors = 0;
        // Sign Extender
        for (i = 0; i < 512; i = i + 1) begin
            in = i[8:0];
            expected_ext = {{7{in[8]}}, in};  #1;                           
            tests_total = tests_total + 1;
				if (tests_total == 512 && ext == expected_ext) 
					 $display("PASS: Sign extend tb compiled sucessfully");
				if (ext != expected_ext)
                $display("FAIL: in=%b ext=%b expected=%b", in, ext, expected_ext);
        end
	     
//		  Specific case check
		  // -------- Case 1: +5 --------
		 in = 9'b000_000_101; 
		 expected_ext = 16'b0000_0000_0000_0101; #1;
		 tests_total = tests_total + 1;
		 if (expected_ext == ext) begin
            $display("Pass: in=%b ext=%b expected=%b", in, ext, expected_ext);
		  end else begin
            $display("FAIL: in=%b ext=%b expected=%b", in, ext, expected_ext);
        end
		  
		  in = 9'b111_111_000;  // (-8)
		  expected_ext = 16'b1111_1111_1111_1000; #1;
		  tests_total = tests_total + 1;
		  if (expected_ext == ext) begin
            $display("Pass: in=%b ext=%b expected=%b", in, ext, expected_ext);
		  end else begin
            $display("FAIL: in=%b ext=%b expected=%b", in, ext, expected_ext);
        end
		  
		  in = 9'b011_111_111;  // (+255)
		  expected_ext = 16'b0000_0000_1111_1111;	#1;
		  tests_total = tests_total + 1;
		  if (expected_ext == ext) begin
            $display("Pass: in=%b ext=%b expected=%b", in, ext, expected_ext);
		  end else begin
            $display("FAIL: in=%b ext=%b expected=%b", in, ext, expected_ext);
        end
		  
		  in = 9'b111_111_111;  // (-256)
		  expected_ext = 16'b1111_1111_1111_1111; #1;
		  tests_total = tests_total + 1;
		  if (expected_ext == ext) begin
            $display("Pass: in=%b ext=%b expected=%b", in, ext, expected_ext);
		  end else begin
            $display("FAIL: in=%b ext=%b expected=%b", in, ext, expected_ext);
        end
			
        // tick FSM  
        enable = 0;
        // Reset = 1,output = 4'b0001
        expected_tick = 4'b0001;
        tests_total = tests_total + 1;  // 513
        @(posedge clk); #1;
        if (tick == expected_tick) begin
            $display("PASS! Got %b, as the expected %b", tick, expected_tick);
        end else begin
            $display("FAIL! Got %b but the expected %b", tick, expected_tick);
            errors = errors + 1;
        end
		  
        // Active enable
        rst = 0;  enable = 1;
		  
        // Tick 1 -> Tick 2
        expected_tick = 4'b0010;
        tests_total = tests_total + 1;
        @(posedge clk); #1;
        if (tick == expected_tick) begin
            $display("PASS! Got %b, expected %b", tick, expected_tick);
        end else begin
            $display("FAIL! Got %b but the expected should be %b", tick, expected_tick);
            errors = errors + 1;
        end
		  
        // Tick 2 -> Tick 3
        expected_tick = 4'b0100;
        tests_total = tests_total + 1;
        @(posedge clk); #1;
        if (tick == expected_tick) begin
            $display("PASS! Got %b as the expected %b", tick,expected_tick);
        end else begin
            $display("FAIL! Got %b but the expected should be %b", tick, expected_tick);
            errors = errors + 1;
        end
		  
        // Tick 3 -> Tick 4
        expected_tick = 4'b1000;
        tests_total = tests_total + 1;
        @(posedge clk); #1;
        if (tick == expected_tick) begin
            $display("PASS! Got %b as the expected %b", tick, expected_tick);
        end else begin
            $display("FAIL! Got %b but the expected should be %b", tick, expected_tick);
            errors = errors + 1;
        end

        // Tick 4 -> Tick 1
        expected_tick = 4'b0001;
        tests_total = tests_total + 1;
        @(posedge clk); #1;
        if (tick == expected_tick) begin
            $display("PASS! Got %b as the expected %b", tick, expected_tick);
        end else begin
            $display("FAIL! Got %b but the expected should be %b", tick, expected_tick);
            errors = errors + 1;
        end
		  
        // Hold if enable = 0 
        enable = 0;
        tests_total = tests_total + 1;
        @(posedge clk); #1;
        expected_tick = 4'b0001;
        if (tick == expected_tick) begin
            $display("Success! Got %b as the expected %b ", tick, expected_tick);
        end else begin
            $display("FAIL! Got %b but the expected should be %b", tick, expected_tick);
            errors = errors + 1;
        end
		  
        // Change enable as 1 and tick 1 should go to tick 2
        enable = 1;
        tests_total = tests_total + 1; // 519
        @(posedge clk); #1;
        expected_tick = 4'b0010;
        if (tick == expected_tick) begin
            $display("PASS! Got %b as the expected %b", tick, expected_tick);
        end else begin
            $display("FAIL! Got %b but the expected should be %b", tick, expected_tick);
            errors = errors + 1;
        end
		 
        // MUX  
        R0 = 16'h0000; R1 = 16'h0001; R2 = 16'h0010; R3 = 16'h0011; 
        R4 = 16'h0100; R5 = 16'h0101; R6 = 16'h0110; R7 = 16'h0111;
        G = 16'h1000; SignExtDin = 16'h1111;
       
        for (i = 0; i <= 9; i = i + 1) begin
            sel = i[3:0]; 
            case(i)
                0: expected_bus = R0;
                1: expected_bus = R1;
                2: expected_bus = R2;	
                3: expected_bus = R3;
                4: expected_bus = R4;
                5: expected_bus = R5;
                6: expected_bus = R6;
                7: expected_bus = R7;
                8: expected_bus = G;
                9: expected_bus = SignExtDin;
                default: expected_bus = 16'h0000;
            endcase 
				#1;
            tests_total = tests_total + 1;  // 528
            if (Bus != expected_bus) begin
                $display("FAIL sel=%d: expected=%h, got=%h", sel, expected_bus, Bus);
                errors = errors + 1;
            end else begin
                $display("PASS sel=%d: Bus=%h", sel, Bus);
            end
        end
		 
        // ALU 
        for (k = 0; k < 4; k = k + 1) begin  // Test for + - * shift
            for (i = 0; i < 16; i = i + 1) begin  // loop for a 
                for (j = 0; j < 16; j = j + 1) begin  // loop for b
                    input_a = i[15:0];
                    input_b = j[15:0];
                    alu_op  = k[2:0];

                    a = input_a;
                    b = input_b;
                    case (alu_op)
                        3'b000: expected_result = a * b; 
                        3'b001: expected_result = a + b;   
                        3'b010: expected_result = a - b; 
                        3'b011: begin  
                            if (a > 0)  expected_result = b <<< a;  // shift a bits to the left if a is +ve  
                            else if (a < 0)  expected_result = b >>> -a; // shift right by |a|
                            else    expected_result = b;
                        end
                        default: expected_result = 16'h0000;
                    endcase
                    #1;
                    tests_total = tests_total + 1;  // 1552
                    if (result != expected_result) begin
                        $display("FAIL: op=%b a=%d b=%d got=%d expected=%d", alu_op, a, b, result, expected_result);
                        errors = errors + 1;
                        $stop;
                    end
//                        $display("ALU tb is compiled successfully!");
//                    end
                end
            end
        end
		 
         // Specific Case sanity check
//			Multiplication
			input_a = 16'd500; input_b = 16'd7; alu_op = 3'b000; 
			#1;
			expected_result = 16'd3500;
			tests_total = tests_total + 1;
			if (result !== expected_result) begin
			  $display("FAIL: op=%b a=%d b=%d got=%d expected=%d",alu_op, input_a, input_b, result, expected_result);
			  errors = errors + 1;
			end else begin
			  $display("PASS: op=%b a=%d b=%d got=%d",alu_op, input_a, input_b, result);
			end

			// Addition
			input_a = 16'd200; input_b = 16'd1000; alu_op = 3'b001; 
			#1;
			expected_result = 16'd1200;
			tests_total = tests_total + 1;
			if (result !== expected_result) begin
			  $display("FAIL: op=%b a=%d b=%d got=%d expected=%0d",alu_op, input_a, input_b, result, expected_result);
			  errors = errors + 1;
			end else begin
			  $display("PASS: op=%b a=%d b=%d got=%d",alu_op, input_a, input_b, result);
			end

			// Subtraction
			input_a = 16'd500; input_b = 16'd500; alu_op = 3'b010;  
			#1;
			expected_result = 16'd0;
			tests_total = tests_total + 1;
			if (result !== expected_result) begin
			  $display("FAIL: op=%b a=%d b=%d got=%d expected=%d",alu_op, input_a, input_b, result, expected_result);
			  errors = errors + 1;
			end else begin
			  $display("PASS: op=%b a=%d b=%d got=%d",alu_op, input_a, input_b, result);
			end

			// Shift with a bits, where a > 0
			input_a = 16'd3; input_b = 16'd100; alu_op = 3'b011;  
			#1;
			expected_result = 16'd800; 
			tests_total = tests_total + 1;
			if (result !== expected_result) begin
			  $display("FAIL: op=%b a=%d b=%d got=%d expected=%d",alu_op, input_a, input_b, result, expected_result);
			  errors = errors + 1;
			end else begin
			  $display("PASS: op=%b a=%d b=%d got=%d",alu_op, input_a, input_b, result);
			end

			// Shift left with a bits, where a < 0
			input_a = -16'd3; input_b = 16'd1000; alu_op = 3'b011;  
			#1;
			expected_result = 16'd125; 
			tests_total = tests_total + 1;
			if (result !== expected_result) begin
			  $display("FAIL: op=%b a=%d b=%d got=%d expected=%d",alu_op, input_a, input_b, result, expected_result);
			  errors = errors + 1;
			end else begin
			  $display("PASS: op=%b a=%d b=%d got=%d",alu_op, input_a, input_b, result);
			end
		  
        // Register_n
        rst = 1; r_in = 0; 
        expected_Q = 16'h0000;
        tests_total = tests_total + 1;
        @(posedge clk); #1;   // posedge 1			
        if (Q !== expected_Q) begin
            $display("FAIL: Expected = h, Got = %h", expected_Q, Q);
            errors = errors + 1;
        end else begin
            $display("PASS: Expected = %h, Got = %h", expected_Q, Q);
        end

        // 2nd step for hold state  (r_in = 0, rst = 0), Q = 16'h0000
        @(negedge clk);  // negdege 1
        rst = 0;
        data_in = 16'h1234;
        r_in = 0;

        @(posedge clk); #1;  // posdege 2
        expected_Q = 16'h0000;
        tests_total = tests_total + 1;
        if (Q !== expected_Q) begin
            $display("FAIL: Hold when r_in=0, Expected = %h, Got = %h",expected_Q, Q);
            errors = errors + 1;
        end else begin
            $display("PASS: Expected = %h, Got = %h", expected_Q, Q);
        end

        // 3rd step for storing data input  (r_in = 1, rst = 0), 16'h1234
        @(negedge clk);  // negedge 2
        r_in = 1; 
        data_in = 16'h1234;
        expected_Q = 16'h1234;

        @(posedge clk); #1;  // posedge 3
        tests_total = tests_total + 1;
        if (Q !== expected_Q) begin
            $display("FAIL: Store when r_in=1, Expected = %h, Got = %h", expected_Q, Q);
            errors = errors + 1;
        end else begin
            $display("PASS: Expected = %h, Got = %h", expected_Q, Q);
        end
		
        // Generate Test Summary
        $display("Test Summary: total = %d", tests_total);
        if (errors == 0)  $display("Congrats! All test passed!");
        else  $display("There are %0d test failed! Please check further on your program.", errors);
        $finish;
    end
endmodule