.text
.globl main

main:

	# Reg assignment
	# $s0 = A, $s1 = x ( vector )
	
	la $s0, A				# $s0 = A
	la $s1, x				# $s1 = x
	lw $s2, size 				# $s2 = size
	
	la $a0, A				# Argument 1: A
	la $a1, x				# Argument 2: x
	move $a2, $s2				# Argument 3: size
	jal multiplication			# $v0 = multiplication(&A, &x)
	
	move $a0, $v0				# Argument 1: $v0
	move $a1, $s2
	jal print
	j main_end
	
# FUNCTION: int* multiplication(int* matrix,int* vector, int size)
# Arguments are stored in $a0 (matrix), $a1 (vector), $a2 (size)
# Return value is void
# Return address is stored in $ra (put there by jal instruction)
# Typical function operation is:

multiplication:

	# This function overwrites $s0 and $s1, $s2, $s3
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
	# $s0 = matrix, $s1 = vector, $s2 = bVector, $s3 = size, $s4 = c ( column counter )
	# $s5 = r ( row counter ), $s6 = total
	# $t0 = val1, $t1 = val2, $t2 = sum , $t3 = i ( indexing )
	
	move $s0, $a0				# matrix = $a0
	move $s1, $a1				# vector = $a1
	move $s2, $a1				# bVector = $a1
	move $s3, $a2				# size = $a2
	la $v0, b				# v0 = b
	
	move $s4, $s3				# c = size
	move $s5, $s3				# r = size
	li $s6, 0				# total = 0
	
	calculate_loop:
	beq $s4, $zero, clear
	
	lw $t0, 0($s0)				# val1 = *matrix
	lw $t1, 0($s1)				# val2 = *vector
	mul $t2, $t0, $t1 			# sum = val1 * val2
	add $s6, $s6, $t2			# total += sum
	
	addi $s4, $s4, -1			# c = c - 1
	addi $s0, $s0, 4			# matrix++
	addi $s1, $s1, 4			# vector++

	j calculate_loop			# jump to calculate_loop label
	
	clear:
	sw $s6, 0($v0)				# *v0 = total
	
	addi $s5, $s5, -1			# r = r - 1
	beq $s5, $zero, multiplication_end	# if ( r == 0 ) goto multiplication_end label
	
	move $s1, $s2				# vector = bVector
	addi $v0, $v0, 4			# v0++ 
	move $s4, $s3				# c = size
	move $s6, $zero				# total = 0
	
	j calculate_loop			# jump to calculate_loop label
	
	
	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
	
	multiplication_end:
	
	addi $t3, $s3, -1			# i = size - 1
	mul $t3, $t3, 4				# i = i * 4
	sub $v0, $v0, $t3			# v0 -= i
	
	
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

# FUNCTION: void print(int* array,int size)
# Arguments are stored in $a0 (heap), $a1 (size)
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
	# $s0 = array, $s1 = size , $s2 = i ( counter )
	
	move $s0, $a0				# array = $a0
	move $s1, $a1				# size = $a1
	li $s2, 0				# i = 0
		
print_loop:
	li $v0, 1				# print_int syscall code = 1
	lw $a0, 0($s0)		
	syscall
	
	addi $s2, $s2, 1			# i = i + 1
	addi $s0, $s0, 4			# array++
	
	beq $s2, $s1, print_end			# if (i == size) goto print_end label
		
	# Print delimiter
	li $v0, 4				# print_string syscall code = 4
	la $a0, delimiter
	syscall
	
	j print_loop				# Jump to loop

print_end:
	
	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
	
	lw $ra, 12($sp)				# Restore $ra
	lw $s0, 8($sp)				# Restore $s0
	lw $s1, 4($sp)				# Restore $s1
	lw $s2, 0($sp)				# Restore $s2
	addi $sp, $sp, 16			# Adjust stack pointer
	
	# Return from function
	jr $ra					# Jump to addr stored in $ra		

main_end:
	li $v0, 10				# exit syscall code = 10
	syscall
	
.data		# Set elements of Matrix A ( size x size )
A:		.word 21, 32, 9, 61, 5, 41, 1, 23, 21, 5, 100, 21, 21, 50, 32, 12
		# Set elements of Vector X ( size x 1 )
x:		.word 41,5,71,64
		# result vector ( size * size )			
b:		.space 16				
		# Matrix, Vector size
size:		.word 4
		# delimiter for output printing
delimiter:    	.asciiz	"\n"			