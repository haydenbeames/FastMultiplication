//Carry Lookahead Adder
module cla #(parameter WIDTH = 16) (
  input  wire [WIDTH-1:0] A,
  input  wire [WIDTH-1:0] B,
  output wire [WIDTH-1:0] Sum,
  output wire             CarryOut
);
  wire [WIDTH-1:0] G;    // Generate
  wire [WIDTH-1:0] P;    // Propagate
  wire [WIDTH:0]   C;    // Carry
  
  genvar i;
  generate
    for (i=0; i<WIDTH; i=i+1) begin : bit
      assign G[i] = A[i] & B[i];  
      assign P[i] = A[i] ^ B[i];  
    end
  endgenerate

  // Carry bits calculation.
  assign C[0] = 1'b0;   // Initial carry is zero.
  generate
    for (i=0; i<WIDTH; i=i+1) begin : carry_calculation
      assign C[i+1] = G[i] | (P[i] & C[i]);
    end
  endgenerate
  
  assign CarryOut = C[WIDTH];
  
  // Sum bits calculation.
  generate
    for (i=0; i<WIDTH; i=i+1) begin : sum_calculation
      assign Sum[i] = P[i] ^ C[i];
    end
  endgenerate
endmodule
