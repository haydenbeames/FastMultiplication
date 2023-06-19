`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/14/2023 10:29:41 AM
// Design Name: 
// Module Name: 4to2_tree
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

localparam DATA_LEN = 8;
localparam FUNC3_WIDTH = 3;
localparam MUL_FUNC3    = 3'b000;
localparam MULH_FUNC3   = 3'b001;
localparam MULHSU_FUNC3 = 3'b010;
localparam MULHU_FUNC3  = 3'b011;
localparam TRUE = 1;
localparam FALSE = 0;

module signed_mul_4to2_tree_8bit(
    input wire logic [DATA_LEN-1:0] op1, op2,
    input wire logic [FUNC3_WIDTH-1:0] func3,
    output logic [DATA_LEN*2-1:0] mul_result
    );
    
    logic signed_op1_ex1, signed_op2_ex1;
    //determine if signed multiplication
    always_comb begin
        case(func3)
            MUL_FUNC3: begin
                signed_op1_ex1 = TRUE;
                signed_op2_ex1 = TRUE;
                end
			MULH_FUNC3: begin
                signed_op1_ex1 = TRUE;
                signed_op2_ex1 = TRUE;
                end
			MULHSU_FUNC3: begin
                signed_op1_ex1 = TRUE;
                signed_op2_ex1 = FALSE;
                end
			MULHU_FUNC3: begin
                signed_op1_ex1 = FALSE;
                signed_op2_ex1 = FALSE; 
                end
		    default: begin
                signed_op1_ex1 = TRUE;
                signed_op2_ex1 = TRUE;
                end
		endcase
    end
    
    logic [DATA_LEN-1:0][DATA_LEN*2-1:0] pp_nontri, pp;
    logic [DATA_LEN-1:0][DATA_LEN-1:0] multiplicand_qual;
    
    
    //generate partial products
    always_comb begin
        for (int i = 0; i < DATA_LEN-1; i++) begin
            multiplicand_qual[i] = op1 & {DATA_LEN{op2[i]}};
        end
        
        //potential twos complement last partial product
        if (signed_op2_ex1) 
            multiplicand_qual[DATA_LEN-1] = {DATA_LEN{op2[DATA_LEN-1]}} & (~op1 + 1'b1);
        else
            multiplicand_qual[DATA_LEN-1] = {DATA_LEN{op2[DATA_LEN-1]}} & op1;
            
        for (int i = 0; i < DATA_LEN-1; i++) begin
            for (int j = 0; j < DATA_LEN*2; j++) begin
                if (j < i)
                    pp_nontri[i][j] = 1'b0;
                else if (j < DATA_LEN + i)
                    pp_nontri[i][j] = multiplicand_qual[i][j-i];
                else
                    pp_nontri[i][j] = signed_op1_ex1 & op2[i] & op1[DATA_LEN-1];
            end
        end
        
        //iterate over last partial product sign extension and placement
        for (int j = 0; j < DATA_LEN*2-1; j++) begin
            if (j < (DATA_LEN-1))
                pp_nontri[DATA_LEN-1][j] = 1'b0;
            else if (j < DATA_LEN + (DATA_LEN-1))
                pp_nontri[DATA_LEN-1][j] = multiplicand_qual[DATA_LEN-1][j-(DATA_LEN-1)];
            else
                pp_nontri[DATA_LEN-1][j] = signed_op1_ex1 & op2[DATA_LEN-1] & op1[DATA_LEN-1];
        end
        pp_nontri[DATA_LEN-1][DATA_LEN*2-1] = signed_op1_ex1 & op2[DATA_LEN-1] & multiplicand_qual[DATA_LEN-1][DATA_LEN-1];

        /* Dont need to put lower partial products to upper to create triangle in signed multiplication
        for (int i = 0; i < DATA_LEN; i++) begin
            for (int j = DATA_LEN; j < DATA_LEN*2; j++) begin           
                pp[(DATA_LEN-1)-i][j] = pp_nontri[i][j];
            end
        end
        */
        for (int i = 0; i < DATA_LEN; i++) begin  
            for (int j = 0; j < DATA_LEN*2; j++) begin //adjust from DATA_LEN to DATA_LEN*2 for Signed MUL
                pp[i][j] = pp_nontri[i][j];
            end
        end
    end

    //generate first stage of tree
    logic [DATA_LEN/2-1:0][DATA_LEN*2-1:0] cout_stg1;
    logic [DATA_LEN/4-1:0][DATA_LEN*2-1:0] cout_stg2;
    
    logic [DATA_LEN/2-1:0][DATA_LEN*2-1:0] in_stg2;
    logic [DATA_LEN/4-1:0][DATA_LEN*2-1:0] in_stg3;
    
    genvar g_i,g_j;

    //create stage 2 default inputs (just original partial products)
    always_comb begin          
        for (int i = 0; i <= 3; i++)
            for (int j = i; j >= 0; j--)
                in_stg2[j][i] = pp[j][i];

        in_stg2[1][4] = pp[2][4];
        in_stg2[2][4] = pp[3][4];
        in_stg2[3][4] = pp[4][4];

        in_stg2[2][5] = pp[4][5];
        in_stg2[3][5] = pp[5][5];

        in_stg2[3][6] = pp[6][6];    

    end
    
    //stage 1 adder tree
    generate
        
        ha ha_stg1_4_0(.a(pp[0][4]), .b(pp[1][4]), .s(in_stg2[0][4]), .c(in_stg2[1][5]));
        
        assign cout_stg1[0][4] = 1'b0;
        
        for (g_i = 5; g_i < DATA_LEN*2; g_i++) begin 
            c_4to2 c_4to2_stg1_0(.in1(pp[0][g_i]),
                                 .in2(pp[1][g_i]),
                                 .in3(pp[2][g_i]),
                                 .in4(pp[3][g_i]), //0 for 2nd 4:2 compressor
                                 .cin( cout_stg1[0][g_i-1]),
                                 .s(     in_stg2[0][g_i]),
                                 .c(     in_stg2[1][g_i+1]),
                                 .cout(cout_stg1[0][g_i])
                                 );       
        end
        
        ha ha_stg1_6_1(.a(pp[4][6]), .b(pp[5][6]), .s(in_stg2[2][6]), .c(in_stg2[3][7]));
        
        assign cout_stg1[1][6] = 1'b0;
        
        for (g_i = 7; g_i < DATA_LEN*2; g_i++) begin 
            c_4to2 c_4to2_stg1_0(.in1(pp[4][g_i]),
                                 .in2(pp[5][g_i]),
                                 .in3(pp[6][g_i]),
                                 .in4(pp[7][g_i]),
                                 .cin( cout_stg1[1][g_i-1]),
                                 .s(     in_stg2[2][g_i]),
                                 .c(     in_stg2[3][g_i+1]),
                                 .cout(cout_stg1[1][g_i])
                                 );       
        end
                                  
    endgenerate
    
    //create stage 3 default inputs (just unused from stage 2)
    always_comb begin
        in_stg3[0][0] = in_stg2[0][0];
        in_stg3[0][1] = in_stg2[0][1];
        in_stg3[1][1] = in_stg2[1][1];
        in_stg3[1][2] = in_stg2[2][2];
    end
    
    //stage 2 adder tree 
    generate
    
        ha ha_stg2_0(.a(in_stg2[0][2]), .b(in_stg2[1][2]), .s(in_stg3[0][2]), .c(in_stg3[1][3]));
        
        assign cout_stg2[0][2] = 1'b0;
        
        for (g_i = 3; g_i < DATA_LEN*2; g_i++) begin 
            c_4to2 c_4to2_stg1_0(.in1(in_stg2[0][g_i]),
                                 .in2(in_stg2[1][g_i]),
                                 .in3(in_stg2[2][g_i]),
                                 .in4(in_stg2[3][g_i]), 
                                 .cin( cout_stg2[0][g_i-1]),
                                 .s(     in_stg3[0][g_i]),
                                 .c(     in_stg3[1][g_i+1]),
                                 .cout(cout_stg2[0][g_i])
                                 );                   
        end
        
    endgenerate
    
    logic [DATA_LEN*2-1:0] sum_4to2_tree, cout_4to2_tree;

    //stage 3 (add sum and carries for final product)
    always_comb begin
        sum_4to2_tree  = '0;
        cout_4to2_tree = '0;
        for (int i = 1; i < (DATA_LEN*2); i++) begin
            sum_4to2_tree[i]  = in_stg3[0][i];
            cout_4to2_tree[i] = in_stg3[1][i];
        end
        sum_4to2_tree[0] = in_stg3[0][0];
        
    end
    
    assign mul_result = sum_4to2_tree + cout_4to2_tree;

endmodule
