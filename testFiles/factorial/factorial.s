    .text
    .globl main

main:
    # Initialize values
    addi x5, x0, 6           # x5 = 6, number to calculate factorial of
    addi x6, x0, 1           # x6 = 1, initial factorial result

Factorial_loop:
    # Loop to calculate factorial
    addi x1, x0, 1           # x1 = 1
    slt x2, x5, x1           # x2 = (x5 < x1)
    beq x2, x1, END_PROGRAM  # If x5 < 1, end program
    jal x31, MULTIPLY        # Call multiply subroutine
    sub x5, x5, x1           # Decrement x5
    jal x0, Factorial_loop   # Repeat factorial loop

MULTIPLY:
    # Multiplication subroutine
    addi x7, x0, 0           # x7 = 0, multiplication result
    addi x8, x0, 0           # x8 = 0, counter

MUL_LOOP:
    # Loop for multiplication by repeated addition
    beq x8, x5, END_MUL      # If counter reaches x5, end multiplication
    add x7, x7, x6           # Add x6 to x7
    addi x8, x8, 1           # Increment counter
    jal x0, MUL_LOOP         # Repeat multiplication loop

END_MUL:
    # End of multiplication subroutine
    add x6, x0, x7           # Move result to x6
    jalr x0, x31, 0          # Return from subroutine

END_PROGRAM:
    # End of the program
    ecall                    # System call to end program

# 4700 ns for 5!
# 5900 ns for 6!