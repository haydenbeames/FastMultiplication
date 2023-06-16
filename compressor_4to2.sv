
module compressor_4_2(

  input wire logic in1, in2, in3, in4, cin,
  output logic s, c, cout
  );
  
  //Gate-level implemtation instead of FA
  //based to reduce critical path to 3 XORs.
  //REF: http://www.ece.ucdavis.edu/~vojin/CLASSES/EEC180A/W2005/lectures/Lect-Multiplier.pdf
  logic cin_in1;
  logic i2_i3_i4;
  
  assign cin_in1 = cin ^ in1;
  assign i2_i3_i4 = ~(in2 ^ in3 ^ in4);
  assign s = ~(cin_in1 ^ i2_i3_i4); 
  
  logic mux1;
  logic mux0;
  
  assign mux1 = ~(cin & in1);
  assign mux0 = ~(cin | in1);
  assign c = (i2_i3_i4)?~mux1:~mux0; 
  assign cout = ~((~(in2 & in3)) & (~(in2 & in4)) & (~(in3 & in4)));  
  //assign s = sPartial ^ cin;
  //assign c = (sPartial==0)?in1:cin;
  //assign cout = (partial12==1)?in3:in1;
  //wire s1;
  
  //full_adder fa1(in1, in2, in3, s1, cout);
  //full_adder fa2(cin, in4, s1, s, c);  

  
endmodule
