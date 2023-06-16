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
module mul_4to2_tree(
    input wire logic [DATA_LEN-1:0] op1, op2
    );
    
    
    logic [DATA_LEN-1:0][DATA_LEN*2-1:0] pp_nontri, pp;
    logic [DATA_LEN-1:0][DATA_LEN-1:0] multiplicand_qual;
    
    //generate partial products
    always_comb begin
        for (int i = 0; i < DATA_LEN; i++) begin
            multiplicand_qual[i] = op1 & {DATA_LEN{op2[i]}};
            pp_nontri[i] = multiplicand_qual[i] << i;
        end
        
        for (int i = 0; i < DATA_LEN; i++) begin
            for (int j = DATA_LEN; j < DATA_LEN*2; j++) begin           
                pp[(DATA_LEN-1)-i][j] = pp_nontri[i][j];
            end
        end
        for (int i = 0; i < DATA_LEN; i++) begin 
            for (int j = 0; j < DATA_LEN; j++) begin
                pp[i][j] = pp_nontri[i][j];
            end
        end
    end

    //generate first stage of tree
    logic [DATA_LEN/2-1:0][DATA_LEN*2-1:0] cout_stg1 = '{default:0};
    logic [DATA_LEN/4-1:0][DATA_LEN*2-1:0] cout_stg2 = '{default:0};
    
    logic [DATA_LEN/2-1:0][DATA_LEN*2-1:0] in_stg2 = '{default:'0};
    logic [DATA_LEN/4-1:0][DATA_LEN*2-1:0] in_stg3 = '{default:'0};
    
    genvar g_i,g_j;

    //create stage 2 default inputs (just original partial products)
    always_comb begin          
        for (int i = 0; i <= 3; i++)
            for (int j = i; j >= 0; j--)
                in_stg2[j][i] = pp[j][i];
        /*      
        for (int j = 0; j <= 2; j++)
            for (int i = 3; i >= j; i--)
                in_stg2[i][j+4] = pp[i][j+4];
        */
        in_stg2[1][4] = pp[2][4];
        in_stg2[2][4] = pp[3][4];
        in_stg2[3][4] = pp[4][4];

        in_stg2[2][5] = pp[4][5];
        in_stg2[3][5] = pp[5][5];

        in_stg2[3][6] = pp[6][6];    
        for (int j = 0; j <= 2; j++) 
            for (int i = (2-j); i >= 0; i--)
                in_stg2[i][j+12] = pp[i][j+12]; 
                
        in_stg2[2][11] = pp[3][11]; 
        in_stg2[2][10] = pp[4][10];
        
        in_stg2[3][11]  = cout_stg1[0][10]; //output from last of top 4to2 compresors //Y
    end
    
    //stage 1 adder tree
    generate
        
        ha ha_stg1_0_4(.a(pp[0][4]), .b(pp[1][4]), .s(in_stg2[0][4]), .c(in_stg2[1][5])); //Y
        
        for (g_i = 5; g_i <= 10; g_i++) begin 
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
        
        
        
        csa csa_stg1_0_11(.a(pp[0][11]), .b(pp[1][11]), .c(pp[2][11]), .s(in_stg2[0][11]), .cout(in_stg2[3][12])); //Y
        
        ha ha_stg1_1_6(.a(pp[4][6]), .b(pp[5][6]), .s(in_stg2[2][6]), .c(in_stg2[3][7])); // Y
        
        for (g_i = 7; g_i <= 8; g_i++) begin 
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
        
        csa csa_stg1_1_9(.a(pp[4][9]), .b(pp[5][9]), .c(cout_stg1[1][8]), .s(in_stg2[2][9]), .cout(in_stg2[3][10])); //Y
                                  
    endgenerate
    
    //create stage 3 default inputs (just unused from stage 2)
    always_comb begin
        in_stg3[0][0] = in_stg2[0][0];
        in_stg3[0][1] = in_stg2[0][1];
        in_stg3[1][1] = in_stg2[1][1];
        in_stg3[1][2] = in_stg2[2][2];
        in_stg3[0][14] = in_stg2[0][14];
    end
    
    //stage 2 adder tree 
    generate
        ha ha_stg2_0(.a(in_stg2[0][2]), .b(in_stg2[1][2]), .s(in_stg3[0][2]), .c(in_stg3[1][3]));
        
        for (g_i = 3; g_i <= 12; g_i++) begin 
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
        
        csa csa_stg2_0_13(.a(in_stg2[0][13]), .b(in_stg2[1][13]), .c(cout_stg2[0][12]), .s(in_stg3[0][13]), .cout(in_stg3[1][14]));
        
    endgenerate
    
    logic [DATA_LEN*2-2:0] sum_4to2_tree, cout_4to2_tree;
    logic [DATA_LEN*2-1:0] mul_result; //unsigned multiplication cannot overflow
    
 
    
    //stage 3 (add sum and carries for final product)
    always_comb begin
        sum_4to2_tree  = '0;
        cout_4to2_tree = '0;
        for (int i = 1; i < (DATA_LEN*2)-1; i++) begin
            sum_4to2_tree[i]  = in_stg3[0][i];
            cout_4to2_tree[i] = in_stg3[1][i];
        end
        sum_4to2_tree[0] = in_stg3[0][0];
        
    end
    
    assign mul_result = sum_4to2_tree + cout_4to2_tree;
    
    /*
    generate
        for (g_i = 1; g_i <= 14; g_i++) begin 
            ha ha_stg3(.a(in_stg3[0][g_i]), .b(in_stg3[1][g_i]), .s(mul_result[g_i]), .c
        end 
    endgenerate
    */
endmodule
