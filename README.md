# FastMultiplication
Fast Multiplication algorithm in SystemVerilog by using 4 to 2 compressors combined with Half adders and CSA (Carry Sum Adders)

## 8 Bit 4:2 Compression Tree Multiplication Now Functional!!!!!

- Now to make 16 bit, 32 bit and 64 bit : )
- but first need to make a signed 8 bit multiplier
- - making the 8 bit tree took me over 24 hours of work lmaoo bc stupid bugs and complicated tree
  - - - on the plus side, the code is much more readable than other trees I have seen online

- Have seen repositories of 4:2 reduction schemes but likely none as efficient as this implementation

- at end of multiplication tree, just use CPA (Carry Propogate Adder) to get final results
