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
    logic [DATA_LEN/2-1:0][DATA_LEN*2-1:0] s_st1, c_st1, cout_st1;
    logic [DATA_LEN/4-1:0][DATA_LEN*2-1:0] s_st2, c_st2, cout_st2;
    
    logic [DATA_LEN/2-1:0][DATA_LEN*2-1:0] in_stg2 = '{default:'X};
    logic [DATA_LEN/4-1:0][DATA_LEN*2-1:0] in_stg3 = '{default:'X};
    genvar i,j;
    
    always_comb begin 
        for (int j = 0; j < 4; j++) 
            for (int i = j; i >= 0; i--) 
                in_stg2[i][j] = pp[i][j];

        for (int j = 0; j < 4; j++) 
            for (int i = 12; i >= 0; i--) 
                in_stg2[i][j] = pp[i][j];
                
                
     in_stg2[3]
    end
    generate
        
        ha ha_stg1_ur(.a(pp[0][4]), .b(pp[1][4]), .sum(in_stg2[0][4]), .cout(in_stg2[1][5]));
        
    endgenerate
    
    /*
    generate
        assign cout_st1 = '{default:0};
        assign s_st1    = '{default:0};
        assign c_st1    = '{default:0};
        //make 1st half adder
        ha ha_1ur(pp[0][4], pp[1][4], s_st1[0][4], cout_st1[0][4]); //1 upper right
        //make 2nd lower half adder
        ha ha_1lr(pp[4][6], pp[5][6], s_st1[2][6], cout_st1[2][6]); //1 lower right
        
        //generate 1st stage 4to2 compressors
        for (i = 5; i < 10; i++) begin: gen_1st_U_4to2 //upper
      compressor_4_2 c4to2(.in1(pp[0][i]),
                           .in2(pp[1][i]),
                           .in3(pp[2][i]),
                           .in4(pp[3][i]),
                           .cin( cout_st1[0][i-1]),
                           .s(  in_stg2[0][i]),
                           .c(  in_stg2[1][i+1]),
                           .cout(cout_st1[0][i])
                           );    
                                       
        end
        
        for (i = 7; i < 10; i++) begin: gen_1st_L_4to2 //lower
      compressor_4_2 c4to2(.in1(pp[4][i]),
                           .in2(pp[5][i]),
                           .in3(pp[6][i]),
                           .in4(pp[7][i]), //0 for 2nd 4:2 compressor
                           .cin( cout_st1[2][i-1]),
                           .s(  in_stg2[2][i]),
                           .c(  in_stg2[3][i+1]),
                           .cout(cout_st1[2][i])
                           );             
        end
      compressor_4_2 c4to2_10(.in1(pp[4][i]),
                           .in2(pp[5][i]),
                           .in3(pp[6][i]),
                           .in4(pp[7][i]), //0 for 2nd 4:2 compressor
                           .cin( cout_st1[2][9]),
                           .s(  in_stg2[2][i]),
                           .c(  in_stg2[3][i+1]),
                           .cout(cout_st1[2][i])
                           );                     
        
        ha ha_1ll(pp[4][9], pp[5][9], s_st1[2][9], cout_st1[2][9]); //1 lower left 
        
        fa fa_1ul(pp[0][11], pp[1][11], pp[2][11], s_st1[0][11], cout_st1[0][11]);
    endgenerate
    
    //second stage
    generate
        assign cout_st2 = '{default:0};
        assign s_st2    = '{default:0};
        assign c_st2    = '{default:0};
        
        for (i = 7; i < 10; i++) begin: gen_2nd_4to2
      compressor_4_2 c4to2(.in1(s_st1[0][i]),
                           .in2(c_st1[0][i-1]),
                           .in3(s_st1[2][i]),
                           .in4(c_st1[2][i-1]), //0 for 2nd 4:2 compressor
                           .cin( cout_st2[0][i-1]),
                           .s(      s_st2[0][i]),
                           .c(      c_st2[0][i]),
                           .cout(cout_st2[0][i])
                           );                
        end
        */
            
endmodule
