`timescale 1ns / 1ps

module tb_mult8bit;
    // Declare signals
    logic clk = 0;
    logic rst_n; // reset signal
    logic signed [7:0] op1, op2;
    logic [2:0] func3;
    logic signed [15:0] mul_result;
    logic signed [15:0] expected_result;

    // Instantiate the DUT
    signed_mul_4to2_tree_8bit u1 (
        .clk(clk),
        .rst_n(rst_n), // connect reset signal
        .func3(func3),
        .op1(op1),
        .op2(op2),
        .mul_result(mul_result)
    );

    // Stimulus and result checking
    initial begin
        $dumpfile("tb_mult8bit.vcd");
        $dumpvars(0, tb_mult8bit);
        
        // Initialize
        op1 = 0;
        op2 = 0;
        func3 = 3'b000; // MUL
        expected_result = $signed(op1) * $signed(op2);
        rst_n = 0;
        #10 rst_n = 1; // De-assert reset after 10 time units

        // 10 Test cases for each instruction
        // Corner cases: lowest, highest, near-to-lowest, near-to-highest values for each test

        // Test cases for MUL
        for (op1 = 8'sb00000000; op1 <= 8'b01111111;op1++) begin
            op1 = op1 << 1;
            for (op2 = 8'sb00000000; op2 <= 8'b01111111; op2++) begin
                #10;
                expected_result = $signed(op1) * $signed(op2);
                check_result();
                op2 = op2 << 1;
            end    
        end
        //better signed test
        for (op1 = 8'sb00000000; op1 <= 8'b01111111;op1++) begin
            op1 = op1 << 1;
            op1 |= 8'b10000000;
            for (op2 = 8'sb00000000; op2 <= 8'b01111111; op2++) begin
                #10;
                op2 = op2 << 1;
                op1 |= 8'b10000000;
                expected_result = $signed(op1) * $signed(op2);
                check_result();
            end    
        end
        
        
        // Change instruction to MULH
        #10 func3 = 3'b001;
        
        for (op1 = 8'sb00000000; op1 <= 8'b01111111;op1++) begin
            op1 = op1 << 1;
            for (op2 = 8'sb00000000; op2 <= 8'b01111111; op2++) begin
                #10;
                expected_result = $signed(op1) * $signed(op2);
                check_result();
                op2 = op2 << 1;
            end    
        end
        //better signed test
        for (op1 = 8'sb00000000; op1 <= 8'b01111111;op1++) begin
            op1 = op1 << 1;
            op1 |= 8'b10000000;
            for (op2 = 8'sb00000000; op2 <= 8'b01111111; op2++) begin
                #10;
                op2 = op2 << 1;
                op1 |= 8'b10000000;
                expected_result = $signed(op1) * $signed(op2);
                check_result();
            end    
        end
        
        // Change instruction to MULHSU
        #10 func3 = 3'b010;

        // Test cases for MULHSU
        for (op1 = 8'sb00000000; op1 <= 8'b01111111;op1++) begin
            op1 = op1 << 1;
            for (op2 = 8'sb00000000; op2 <= 8'b01111111; op2++) begin
                #10;
                expected_result = $signed(op1) * $unsigned(op2);
                check_result();
                op2 = op2 << 1;
            end    
        end
        //better signed test
        for (op1 = 8'sb00000000; op1 <= 8'b01111111;op1++) begin
            op1 = op1 << 1;
            op1 |= 8'b10000000;
            for (op2 = 8'sb00000000; op2 <= 8'b01111111; op2++) begin
                #10;
                op2 = op2 << 1;
                op1 |= 8'b10000000;
                expected_result = $signed(op1) * $unsigned(op2);
                check_result();
            end    
        end

        // Change instruction to MULHU
        #10 func3 = 3'b011;

        // Test cases for MULHU
        for (op1 = 8'sb00000000; op1 <= 8'b01111111;op1++) begin
            op1 = op1 << 1;
            for (op2 = 8'sb00000000; op2 <= 8'b01111111; op2++) begin
                #10;
                expected_result = $unsigned(op1) * $unsigned(op2);
                check_result();
                op2 = op2 << 1;
            end    
        end
        //better signed test
        for (op1 = 8'sb00000000; op1 <= 8'b01111111;op1++) begin
            op1 = op1 << 1;
            op1 |= 8'b10000000;
            for (op2 = 8'sb00000000; op2 <= 8'b01111111; op2++) begin
                #10;
                op2 = op2 << 1;
                op1 |= 8'b10000000;
                expected_result = $unsigned(op1) * $unsigned(op2);
                check_result();
            end    
        end
        
        #10 $finish;
    end

    // Monitor
    initial begin
        $monitor("At time %0d ns, func3 = %b, op1 = %d, op2 = %d, mul_result = %d, expected_result = %d", 
                  $time, func3, op1, op2, mul_result, expected_result);
    end

    // Check result
    task check_result;
        begin
            #10; // Wait for a clock cycle to ensure that output is updated
            if (mul_result !== expected_result) begin
                $display("Mismatch at time %0d: Got %0d, expected %0d", $time, mul_result, expected_result);
                $display("Failure!");
            end else begin
                $display("Test passed at time %0d", $time);
            end
        end
    endtask

    // Clock generator
    always begin
        #5 clk = ~clk;
    end

endmodule
