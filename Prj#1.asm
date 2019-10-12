.text
.globl main

main:


	la $a0, A				# Argument 1: A
	la $a1, x				# Argument 2: x
	lw $a2, size				# Argument 3: size
	jal multiplication			# multiplication(A, x, size)
	
	move $a0, $v0				# Argument 1: $v0 = multiplication(A, x, size)
	lw $a1, size				# Argument 2: size
	jal print				# print($v0, size)
	
	li $v0, 10				# exit syscall code = 10
	syscall
	
# FUNCTION: int* multiplication(int* matrix, int* vector, int size)
# Arguments are stored in $a0 = matrix, $a1 = vector, $a2 = size
# Return value is $v0
# Return address is stored in $ra (put there by jal instruction)
# Typical function operation is:
multiplication:

	# This function overwrites $s0 and $s1, $s2, $s3, $s4, $s5, $s6
	# We should save those on the stack
	# This is PUSH'ing onto the stack
	
	addi $sp, $sp, -32			# Adjust stack pointer
	sw $ra, 28($sp)				# Save $ra
	sw $s0, 24($sp)				# Save $s0
	sw $s1, 20($sp)				# Save $s1
	sw $s2, 16($sp)				# Save $s2
	sw $s3, 12($sp)				# Save $s3
	sw $s4, 8($sp)				# Save $s4
	sw $s5, 4($sp)				# Save $s5
	sw $s6, 0($sp)				# Save $s6
	
	# Reg assignmnet
	# $s0 = matrix, $s1 = vector, $s2 = bVector, $s3 = size, $s4 = col ( column counter )
	# $s5 = row ( row counter ), $s6 = total
	# $t0 = val1, $t1 = val2, $t2 = sum , $t3 = i ( indexing )
	
	move $s0, $a0				# matrix = $a0
	move $s1, $a1				# vector = $a1
	move $s2, $a1				# bVector = $a1
	move $s3, $a2				# size = $a2

	li $s6, 0				# total = 0
	
	la $v0, b				# *v0 = b	
	
	li $s4, 0				# col = 0-
	multiplication_for_1:
		multiplication_for_2:
		multiplication_for_2_next:
		multiplication_for_2_end:
	multiplication_for_1_next:
		add $
	multiplication_for_1_end:
	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
	
multiplication_end:
	move $v0, $s2				# $v0 = bVector
	
	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
	
	lw $ra, 28($sp)				# Restore $ra
	lw $s0, 24($sp)				# Restore $s0
	lw $s1, 20($sp)				# Restore $s1
	lw $s2, 16($sp)				# Restore $s2
	lw $s3, 12($sp)				# Restore $s3
	lw $s4, 8($sp)				# Restore $s4
	lw $s5, 4($sp)				# Restore $s5
	lw $s6, 0($sp)				# Restore $s6
	addi $sp, $sp, 32			# Adjust stack pointer
	
	# Return from function
	jr $ra					# Jump to addr stored in $ra		

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


# FUNCTION: void print(int* matrix, int size)
# Arguments are stored in $a0 = matrix, $a1 = size
# Return value is void
# Return address is stored in $ra (put there by jal instruction)
# Typical function operation is:
print:

	# This function overwrites $s0 and $s1, $s2
	# We should save those on the stack
	# This is PUSH'ing onto the stack
	
	addi $sp, $sp, -16			# Adjust stack pointer	
	sw $ra, 12($sp)				# Save $ra
	sw $s0, 8($sp)				# Save $s0
	sw $s1, 4($sp)				# Save $s1
	sw $s2, 0($sp)				# Save $s2
	
	# Reg assignment
	# $s0 = matrix, $s1 = size , $s2 = i ( counter )
	
	move $s0, $a0				# matrix = $a0
	move $s1, $a1				# size = $a1
	
	li $s2, 0				# i = 0	
	print_for_1:
		beq $s1, $s2, print_for_1_end	# if ( size == i ) goto print_for_1_end
	
		li $v0, 1			# print_int syscall code = 1
		lw $a0, 0($s0)		
		syscall

		# Print delimiter
		li $v0, 4			# print_string syscall code = 4
		la $a0, delimiter
		syscall
	
	print_for_1_next:
		add $s2, $s2, 1			# i = i + 1
		add $s0, $s0, 4			# matrix++
		j print_for_1			# jump to print_for_1 label
		
	print_for_1_end:
	

print_end:
	
	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
	
	lw $ra, 12($sp)				# Restore $ra
	lw $s0, 8($sp)				# Restore $s0
	lw $s1, 4($sp)				# Restore $s1
	lw $s2, 0($sp)				# Restore $s2
	addi $sp, $sp, 16			# Adjust stack pointer

	jr $ra					# Return from function	

.data		
A:		.word 1, 2, 31, 4, 51, 6, 7, 81, 9	# Set elements of Matrix A ( size x size )
x:		.word 31, 12, 12				# Set elements of Vector X ( size x 1 )	
b:		.space 12				# result vector ( size * size )					
		
size:		.word 3					# Matrix, Vector size
		
delimiter:    	.asciiz	"\n"				# line feed	
