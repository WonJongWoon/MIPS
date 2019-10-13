.text

.globl main


main:
	la $a0, A					# Argument 1: A
	lw $a1, size					# Argument 2: size
	jal inverse					# inverse(A, size)
	
	move $a0, $v0					# Argument 1: $v0 = inverse(A, size)
	lw $a1, size					# Argument 2: size
	jal print					# print($v0, size)
	
	li $v0, 10					# exit syscall code = 10
    	syscall
	
# FUNCTION: float* inverse(float* matrix, int size)
# Arguments are stored in $a0 = matrix, $a1 = size
# Return value is $v0
# Return address is stored in $ra (put there by jal instruction)
# Typical function operation is:
inverse:

	# This function overwrites $s0 and $s1, $s2, $s3, $s4, $s5
	# We should save those on the stack
	# This is PUSH'ing onto the stack
	
	addi $sp, $sp, -28	    			# Adjust stack pointer
	sw $ra, 24($sp)		    			# Save $ra
	sw $s0, 20($sp)		    			# Save $s0
	sw $s1, 16($sp)		    			# Save $s1
	sw $s2, 12($sp)		    			# Save $s2
	sw $s3, 8($sp)		    			# Save $s3
	sw $s4, 4($sp)		    			# Save $s4
	sw $s5, 0($sp)		    			# Save $s5

	# Reg assignment
	# $s0 = matrix, $s1 = identity, $s2 = size, $s3 = ex_row ( counter )
	# $s4 = in_row ( counter ), $s5 = col ( counter )
	
	move $s0, $a0					# matrix = $a0
	la $s1, Identity				# identity = Identity
	move $s2, $a1					# size = $a1
	
	li $s3, 0					# ex_row = 0
	inverse_for_1:	
        	beq $s2, $s3, inverse_for_1_end			# if ( size == ex_row ) goto inverse_end label
        
        	move $a0, $s0					# Argument 1: matrix
        	move $a1, $s3					# Argument 2: ex_row
        	move $a2, $s3					# Argument 3: ex_row
        	jal get_element					# get_element(matrix, ex_row, ex_row)
        
        	mtc1 $v0, $f31					# pivot = $f31 = $v0 = get_element(matrix, ex_row, ex_row);
        	c.eq.s $f31, $f30				# if (pivot == zero) flag = 0 else flag = 1
        	bc1t inverse_for_2_end				# if (flag == 0) goto inverse_for_2_end label
        
        	li $s5, 0					# col = 0
        	inverse_for_2:
            		beq $s2, $s5, inverse_for_2_end 		# if (size == col) goto inverse_for_2_end
            
            		move $a0, $s0					# Argument 1: matrix
            		move $a1, $s3					# Argument 2: ex_row
            		move $a2, $s5					# Argument 3: col
            		jal get_element					# get_element(matrix, ex_row, col)
            
            		mtc1 $v0, $f0					# $f0 = $v0 = get_element(matrix, ex_row, col)
            
            		move $a0, $s1					# Argument 1: identity
            		move $a1, $s3					# Argument 2: ex_row
            		move $a2, $s5					# Argument 3: col
            		jal get_element					# get_element(identity, ex_row, col)
            
            		mtc1 $v0, $f1					# $f1 = $v0 = get_element(identity, ex_row, col)

            		div.s $f0, $f0, $f31				# $f0 = $f0 / pivot
            		div.s $f1, $f1, $f31				# $f1 = $f1 / pivot
            
           		move $a0, $s0					# Argument 1: matrix
            		move $a1, $s3					# Argument 2: ex_row
            		move $a2, $s5					# Argument 3: col
            		mfc1 $a3, $f0					# Argument 4: $f0 = matrix[ex_row][col] / pivot
            		jal set_element					# set_element(matrix, ex_row, col, $f0)
            
            		move $a0, $s1					# Argument 1: identity
            		move $a1, $s3					# Argument 2: ex_row
            		move $a2, $s5					# Argument 3: col
            		mfc1 $a3, $f1					# Argument 4: $f1 = identity[ex_row][col] / pivot
            		jal set_element					# set_element(identity, ex_row, col, $f1)
        
        	inverse_for_2_next:
            		add $s5, $s5, 1					# col = col + 1
            		j inverse_for_2					# jump to inverse_for2 label
        
        	inverse_for_2_end:
        
        	li $s4, 0					# in_row = 0
        	inverse_for_3:
            		beq $s4, $s2, inverse_for_3_end			# if ( in_row == size ) goto inverse_for_3_end label
            		beq $s4, $s3, inverse_for_3_next		# if ( in_row == ex_row ) goto inverse_for_3_next label 
            

            		move $a0, $s0					# Argument 1: matrix
            		move $a1, $s4					# Argument 2: in_row
            		move $a2, $s3					# Argument 3: ex_row
            		jal get_element					# get_element(matrix, in_row, ex_row)
            
            		mtc1 $v0, $f0					# mul = $f0 = $v0 = get_element(matrix, in_row, ex_row)
            		
                        li $s5, 0					# col = 0        
            		inverse_for_4:
                		beq $s5, $s2, inverse_for_4_end		# if ( col == size ) goto inverse_for_3_next label
                
                		move $a0, $s0					# Argument 1: matrix
                		move $a1, $s4					# Argument 2: in_row
                		move $a2, $s5					# Argument 3: col
                		jal get_element					# get_element(matrix, in_row, col)
                
                		mtc1 $v0, $f1					# $f1 = $v0 = get_element(matrix, in_row, col)
                
                		move $a0, $s1					# Argument 1: identity
                		move $a1, $s4					# Argument 2: in_row
                		move $a2, $s5					# Argument 3: col
                		jal get_element					# get_element(identity, in_row, col)
                
                		mtc1 $v0, $f2					# $f2 = $v0 = get_element(identity, in_row, col)
                
                		move $a0, $s0					# Argument 1: matrix
                		move $a1, $s3					# Argument 2: ex_row
                		move $a2, $s5					# Argument 3: col
                		jal get_element					# get_element(matrix, ex_row, col)
                
                		mtc1 $v0, $f3					# $f3 = $v0 = get_element(matrix, ex_row, col)
                
                		move $a0, $s1					# Argument 1: identity
                		move $a1, $s3					# Argument 2: ex_row
                		move $a2, $s5					# Argument 3: col
                		jal get_element					# get_element(identity, ex_row, col)	
                
                		mtc1 $v0, $f4  					# $f4 = $v0 = get_element(identity, ex_row, col)	
                
                		mul.s $f3, $f3, $f0				# $f3 = matrix[ex_row][col] * mul
                		mul.s $f4, $f4, $f0				# $f4 = identity[ex_row][col] * mul
                
                		sub.s $f1, $f1, $f3				# $f1 = matrix[in_row][col] - $f3
                		sub.s $f2, $f2, $f4				# $f2 = identity[in_row][col] - $f4
                
                		move $a0, $s0					# Argument 1: matrix
                		move $a1, $s4					# Argument 2: in_row
                		move $a2, $s5					# Argument 3: col
                		mfc1 $a3, $f1					# Argument 4: $f1 = matrix[in_row][col] - matrix[ex_row][col] * mul
                		jal set_element					# set_element(matrix, in_row, col, $f1)
                
                		move $a0, $s1					# Argument 1: identity
                		move $a1, $s4					# Argument 2: in_row
                		move $a2, $s5					# Argument 3: col
                		mfc1 $a3, $f2					# Argument 4: $f2 = identity[in_row][col] - identity[ex_row][col] * mul
                		jal set_element					# set_element(identity, in_row, col, $f2)

            		inverse_for_4_next:
                		add $s5, $s5, 1					# col = col + 1
                		j inverse_for_4					# jump to inverse_for_4 label
            
            		inverse_for_4_end:
                        
        	inverse_for_3_next:
            		add $s4, $s4, 1					# in_row = in_row + 1
            		j inverse_for_3					# jump to inverse_for_3
        
        	inverse_for_3_end:
        
	inverse_for_1_next:
        	add $s3, $s3, 1					# ex_row = ex_row + 1
        	j inverse_for_1					# jump to inverse_for_1 label
		
	inverse_for_1_end:
		move $v0, $s1					# $v0 = Identity
	
inverse_end:

    # Restore saved register values from stack in opposite order
    # This is POP'ing from the stack
    
    lw $ra, 24($sp)		    			# Restore $ra
    lw $s0, 20($sp)		    			# Restore $s0
    lw $s1, 16($sp)		    			# Restore $s1
    lw $s2, 12($sp)		    			# Restore $s2
    lw $s3, 8($sp)		    			# Restore $s3
    lw $s4, 4($sp)		    			# Restore $s4
    lw $s5, 0($sp)		    			# Restore $s5
    addi $sp, $sp, 28	    				# Adjust stack pointer

    jr $ra			        		# Return from function

# FUNCTION: void print(float* matrix, int size)
# Arguments are stored in $a0 = matrix, $a1 = size
# Return value is void
# Return address is stored in $ra (put there by jal instruction)
# Typical function operation is:
print:

	# This function overwrites $s0 and $s1, $s2, $s3
	# We should save those on the stack
	# This is PUSH'ing onto the stack
	
	addi $sp, $sp, -20				# Adjust stack pointer	
	sw $ra, 16($sp)					# Save $ra
	sw $s0, 12($sp)					# Save $s0
	sw $s1, 8($sp)					# Save $s1
	sw $s2, 4($sp)					# Save $s2
	sw $s3, 0($sp)					# Save $s3
	
	# Reg assignment
	# $s0 = matrix, $s1 = size , $s2 = row ( counter ), $s3 = col ( counter )
	
	move $s0, $a0					# matrix = $a0
	move $s1, $a1					# size = $a1
	
	li $s2, 0					# row = 0	
	print_for_1:
		beq $s1, $s2, print_for_1_end			# if ( size == row ) goto print_for_1_end label

        	li $s3, 0					# col = 0
       		print_for_2:
            		beq $s1, $s3, print_for_2_end			# if ( size == col ) goto print_for_1_next label
            
            		li $v0, 2					# print_float syscall code = 2
            		lwc1 $f12, 0($s0)		
            		syscall

            		# Print delimiter
            		li $v0, 4					# print_string syscall code = 4
            		la $a0, delimiter
            		syscall
        
        	print_for_2_next:
            		add $s3, $s3, 1					# col = col + 1
            		add $s0, $s0, 4					# matrix++
            		j print_for_2					# Jump to loop
        
        	print_for_2_end:
	
	print_for_1_next:
		add $s2, $s2, 1					# row = row + 1
	
        	# Print newLine	
        	li $v0, 4					# print_string syscall code = 4
        	la $a0, newLine
        	syscall
            
        	j print_for_1					# jump to print_for_1 lael
	
	print_for_1_end:	
	
print_end:

    # Restore saved register values from stack in opposite order
    # This is POP'ing from the stack

    lw $ra, 16($sp)					# Restore $ra
    lw $s0, 12($sp)					# Restore $s0
    lw $s1, 8($sp)					# Restore $s1
    lw $s2, 4($sp)					# Restore $s2
    lw $s3, 0($sp)					# Restore $s3
    addi $sp, $sp, 20					# Adjust stack pointer

    jr $ra						# Return from function	


# FUNCTION: float get_element(float* matrix, int row, int col)
# Arguments are stored in $a0 = matrix, $a1 = row, $a2 = col
# Return value is $v0
# Return address is stored in $ra (put there by jal instruction)
# Typical function operation is:		
get_element:

	# This function overwrites $s0 and $s1, $s2, $s3
	# We should save those on the stack
	# This is PUSH'ing onto the stack
	
	addi $sp, $sp, -20	    			# Adjust stack pointer
	sw $ra, 16($sp)		    			# Save $ra
	sw $s0, 12($sp)		    			# Save $s0
	sw $s1, 8($sp)		    			# Save $s1
	sw $s2, 4($sp)		    			# Save $s2
	sw $s3, 0($sp)		    			# Save $s3
	
	# Reg assignment
	# $s0 = matrix, $s1 = row, $s2 = col, $s3 = i ( indexing )
	
	move $s0, $a0					# $s0 = matrix
	move $s1, $a1					# $s1 = row
	move $s2, $a2					# $s2 = col
	
	mul $s3, $s1, 12				# i = 12 * row
	add $s0, $s0, $s3				# matrix = matrix + i
	
	sll $s3, $s2, 2					# i = 4 * col
	add $s0, $s0, $s3				# matrix = matrix + i
	
	lw $v0, 0($s0)					# $v0 = *matrix
get_element_end:

	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
		
	lw $ra, 16($sp)		    			# Restore $ra
	lw $s0, 12($sp)		    			# Restore $s0
	lw $s1, 8($sp)		    			# Restore $s1
	lw $s2, 4($sp)		    			# Restore $s2
	lw $s3, 0($sp)		    			# Restore $s3
	addi $sp, $sp, 20	    			# Adjust stack pointer
	
	jr $ra						# Return from function
	
# FUNCTION: void set_element(float* matrix, int row, int col, float element)
# Arguments are stored in $a0 = matrix, $a1 = row, $a2 = col, $a3 = element
# Return value is void
# Return address is stored in $ra (put there by jal instruction)
# Typical function operation is:		
set_element:
	# This function overwrites $s0 and $s1, $s2, $s3, $s4
	# We should save those on the stack
	# This is PUSH'ing onto the stack
	
	addi $sp, $sp, -24	    			# Adjust stack pointer
	sw $ra, 20($sp)		    			# Save $ra
	sw $s0, 16($sp)		    			# Save $s0
	sw $s1, 12($sp)		    			# Save $s1
	sw $s2, 8($sp)		    			# Save $s2
	sw $s3, 4($sp)		    			# Save $s3
	sw $s4, 0($sp)					# Save $s4
	
	# Reg assignment
	# $s0 = matrix, $s1 = row, $s2 = col, $s3 = element
	# $s4 = i ( indexing )
	
	move $s0, $a0					# $s0 = matrix
	move $s1, $a1					# $s1 = row
	move $s2, $a2					# $s2 = col
	move $s3, $a3					# $s3 = element
	
	mul $s4, $s1, 12				# i = 12 * row
	add $s0, $s0, $s4				# matrix = matrix + i
	
	sll $s4, $s2, 2					# i = 4 * col
	add $s0, $s0, $s4				# matrix = matrix + i
	sw $s3, 0($s0)					# *matrix = element
	
set_element_end:

	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
	
	lw $ra, 20($sp)		    			# Restore $ra
	lw $s0, 16($sp)		    			# Restore $s0
	lw $s1, 12($sp)		    			# Restore $s1
	lw $s2, 8($sp)		    			# Restore $s2
	lw $s3, 4($sp)		    			# Restore $s3
	lw $s4, 0($sp)		    			# Restore $s4
	addi $sp, $sp, 24	    			# Adjust stack pointer
	
	jr $ra						# Return from function
	
.data

A: 		.float  2, 10, 12	# Matrix A
		.float 10,  5, 15 
		.float  6,  9,  3

Identity: 	.float 1, 0, 0 		# Identity Matrix
		.float 0, 1, 0
		.float 0, 0, 1
		

size: 		.word 3			# Matrix Size

delimiter: 	.asciiz " "		# delimiter for matrix`s elements printing
newLine:	.asciiz "\n"		# line feed



