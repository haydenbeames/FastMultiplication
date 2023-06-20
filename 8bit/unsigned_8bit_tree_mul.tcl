restart

run 10ns 

add_force op1 11111111
add_force op2 11111111

run 20ns

add_force op1 01111111
add_force op2 11111111

run 20ns

add_force op1 11111111
add_force op2 01111111

run 20ns

add_force op1 11111011
add_force op2 00000111

run 20ns

