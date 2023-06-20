restart

run 10ns 

#run signed test
add_force func3 000
# -1 * 1
add_force op1 11111111  
add_force op2 00000001  

run 20ns
# -25 * -25 = 0000001001110001 signed * signed
add_force op1 11100111  
add_force op2 11100111  

run 20ns

add_force op1 00000000
add_force op2 00000000

run 20ns

# 19 * -3 = 1111111111000111
add_force op1 00010011
add_force op2 11111101
run 20ns

# -3 * 19 = 1111111111000111  #check partial products
add_force op1 11111101
add_force op2 00010011
run 20ns

# 19 * -3 = signed * unsigned = 19 * 253 = 4807 = 0001001011000111
add_force func3 010 
add_force op1 00010011
add_force op2 11111101
run 20ns

# -3 * -3 = unsigned * unsigned = 253*253 = 0000 % 1111101000001001  #check partial products (*truncated to 16 bits)
add_force func3 011
add_force op1 11111101
add_force op2 11111101
run 20ns



