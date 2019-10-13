.text
.globl main

main:

	la $a0, A				# Argument 1: A
	la $a1, x				# Argument 2: x
	lw $a2, size
	jal multiplication			# multiplication(A, x)
	
	move $a0, $v0				# Argument 1: $v0 = multiplication(A, x)
	lw $a1, size				# Argumnet 2: size
	jal print				# print($v0, size)
	
	li $v0, 10				# exit syscall code = 10
	syscall
	
# FUNCTION: int* multiplication(int* matrix, int* vector, int size)
# Arguments are stored in $a0 = matrix, $a1 = vector, $a2 = size
# Return value is $v0
# Return address is stored in $ra (put there by jal instruction)
# Typical function operation is:

multiplication:

	# This function overwrites $s0 and $s1, $s2, $s3, $s4, $s5
	# We should save those on the stack
	# This is PUSH'ing onto the stack
	
	addi $sp, $sp, -28			# Adjust stack pointer
	sw $ra, 24($sp)				# Save $ra
	sw $s0, 20($sp)				# Save $s0
	sw $s1, 16($sp)				# Save $s1
	sw $s2, 12($sp)				# Save $s2
	sw $s3, 8($sp)				# Save $s3
	sw $s4, 4($sp)				# Save $s4
	sw $s5, 0($sp)				# Save $s5
	
	# Reg assignmnet
	# $s0 = matrix, $s1 = vector, $s2 = size, $s3 = row ( row counter )
	# $s4 = col ( column counter ), $s5 = total
	# $t0 = val1, $t1 = val2, $t2 = sum, $t3 = i ( indexing )
	
	move $s0, $a0				# matrix = $a0
	move $s1, $a1				# vector = $a1
	move $s2, $a2				# size = $a2
	la $v0, b				# v0 = b
	
	li $s5, 0				# total = 0
	li $s3, 0				# row = 0
	multiplication_for_1:
		beq $s3, $s2, multiplication_for_1_end	# if ( row == size) goto multiplication_for_1_end label
	
		li $s4, 0				# col = 0
		multiplication_for_2:
			beq $s4, $s2, multiplication_for_2_end	# if ( col == size ) goto multiplication_for_2_end label
	
			lw $t0, 0($s0)				# val1 = *matrix
			lw $t1, 0($s1)				# val2 = *vector
			mul $t2, $t0, $t1 			# sum = val1 * val2
			add $s5, $s5, $t2			# total += sum
	
		multiplication_for_2_next:
			addi $s4, $s4, 1			# col = col + 1
			addi $s0, $s0, 4			# matrix++
			addi $s1, $s1, 4			# vector++

			j multiplication_for_2			# jump to multiplication_for_2 label
	
		multiplication_for_2_end:
			sw $s5, 0($v0)				# *v0 = total
			add $v0, $v0, 4				# v0++
			
			sll $t3, $s2, 2				# i = size * 4
			sub $s1, $s1, $t3			# vector = &vector[0]
		
	multiplication_for_1_next:		
		li $s5, 0				# total = 0
		addi $s3, $s3, 1			# row = row + 1
	
		j multiplication_for_1			# jump to multiplication_for_1
	
	multiplication_for_1_end:
		sll $t3, $s3, 2				# i = size * 4
		sub $v0, $v0, $t3			# v0 = &v0[0]
		
multiplication_end:
	
	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
	
	lw $ra, 24($sp)				# Restore $ra
	lw $s0, 20($sp)				# Restore $s0
	lw $s1, 16($sp)				# Restore $s1
	lw $s2, 12($sp)				# Restore $s2
	lw $s3, 8($sp)				# Restore $s3
	lw $s4, 4($sp)				# Restore $s4
	lw $s5, 0($sp)				# Restore $s5
	addi $sp, $sp, 28			# Adjust stack pointer
	
	jr $ra					# Return from function		

# FUNCTION: void print(int* array, int size)
# Arguments are stored in $a0 = array, $a1 = size 
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
	print_for_1:
		beq $s1, $s2, print_for_1_end	# if ( size == i ) goto print_for_1_end label
		
		li $v0, 1				# print_int syscall code = 1
		lw $a0, 0($s0)		
		syscall
		
	print_for_1_next:
		# Print delimiter
		li $v0, 4				# print_string syscall code = 4
		la $a0, delimiter
		syscall
		
		add $s0, $s0, 4				# array++	
		add $s2, $s2, 1				# i = i + 1
		j print_for_1				# jump to print_for_1 label
		
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
A:		.word 1, 1, 9, 6, 5, 5, 1, 2, 1	# Set elements of Matrix A ( size x size )
x:		.word 2, 5, 9			# Set elements of Vector X ( size x 1 )		
b:		.space 12			# result vector ( size * size )			
size:		.word 3				# Matrix, Vector size
delimiter:    	.asciiz	"\n"			# line feed
