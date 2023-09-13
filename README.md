# FastMultiplication
Fast Multiplication algorithm in SystemVerilog by using 4 to 2 compressors combined with Half adders and CSA (Carry Sum Adders)

## 8 Bit 4:2 Compression Tree Multiplication Now Functional!!!!!
- fix cin bug on removal of '{default:'0} for synthesis error
- Now to make 16 bit, 32 bit and 64 bit : )
- but first need to make a signed 8 bit multiplier
- - making the 8 bit tree took me over 24 hours of work lmaoo bc stupid bugs and complicated tree
  - - - on the plus side, the code is much more readable than other trees I have seen online

- Of several 4:2 compression techniques, this should be the most optimal routing to ensure fastest result, however, I acknowledge that modern Synthesis tools may be better at optimization

- at end of multiplication tree, just use CPA (Carry Propogate Adder) to get final results

## Currently exploring Hybrid 4:2 Compression tree with 3:2 CSA for Booth Recoding multiplication
