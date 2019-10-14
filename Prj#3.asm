.text

.globl main

main:
	# Register assignments
	# $s0 = size, $s1 = i ( counter )
	
	lw $s0, size				# $s0 = size
	
	li $s1, 0				# i = 0
	main_for_1:
		beq $s0, $s1, main_for_1_end		# if ( size == i ) goto main_for_1_end
	
		la $a0, array				# Argument 1: array
		move $a1, $s1				# Argument 2: i
		jal input				# input(array, i)
	
		la $a0, array				# Argument 1: array
		move $a1, $s1			
		addi $a1, $a1, 1			# Argument 2: i + 1
		jal heapSort				# heapSort(array, i + 1)
	
		move $a0, $v0				# Argument 1: $v0 = heapSort(array, i) 
		move $a1, $s1			
		add $a1, $a1, 1				# Argument 2: i + 1
		jal print				# print(array, i + 1)
	
	main_for_1_next:
		add $s1, $s1, 1				# i = i + 1
		j main_for_1				# goto main_for_1 label
	
	main_for_1_end:
		li $v0, 10				# exit syscall code = 10
		syscall
		
main_end:	
	li $v0, 10			# exit syscall code = 10
	syscall
	
# FUNCTION: int get_element(int* array, int index)
# Arguments are stored in $a0 = array, $a1 = index
# Return value is $v0
# Return address is stored in $ra (put there by jal instruction)
# Typical function operation is:		
get_element:

	# This function overwrites $s0 and $s1, $s2
	# We should save those on the stack
	# This is PUSH'ing onto the stack
	
	addi $sp, $sp, -16	    			# Adjust stack pointer
	sw $ra, 12($sp)		    			# Save $ra
	sw $s0, 8($sp)		    			# Save $s0
	sw $s1, 4($sp)		    			# Save $s1
	sw $s2, 0($sp)		    			# Save $s2
	
	# Reg assignment
	# $s0 = array, $s1 = index, $s2 = i ( indexing )
	
	move $s0, $a0					# $s0 = array
	move $s1, $a1					# $s1 = index
	
	sll $s2, $s1, 2					# i = 4 * index
	add $s0, $s0, $s2				# array = array + i
	
	lw $v0, 0($s0)					# $v0 = *matrix
get_element_end:

	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
		
	lw $ra, 12($sp)		    			# Restore $ra
	lw $s0, 8($sp)		    			# Restore $s0
	lw $s1, 4($sp)		    			# Restore $s1
	lw $s2, 0($sp)		    			# Restore $s2
	addi $sp, $sp, 16	    			# Adjust stack pointer
	
	jr $ra						# Return from function
		
# FUNCTION: void input(int* array,int index)
# Arguments are stored in $a0 = array, $a1 = index
# Return value is void
# Return address is stored in $ra (put there by jal instruction)
# Typical function operation is:
input:

	# This function overwrites $s0 and $s1, $s2
	# We should save those on the stack
	# This is PUSH'ing onto the stack
	
	addi $sp, $sp, -16		# Adjust stack pointer
	sw $ra, 12($sp)			# Save $ra
	sw $s0, 8($sp)			# Save $s0
	sw $s1, 4($sp)			# Save $s1
	sw $s2, 0($sp)			# Save $s2
	
	# Reg assignment
	# $s0 = array, $s1 = index, $s2 = i ( indexing )
	
	move $s0, $a0			# array = $a0
	move $s1, $a1			# index = $a1
	
	sll $s2, $s1, 2			# i = index * 4
	add $s0, $s0, $s2		# array = array + i
	
	li $v0, 5			# read_int syscall code = 5
	syscall				# syscall results returned in $v0
	sw $v0, 0($s0)			# *array = $v0 
	
input_end:

	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
	
	lw $ra, 12($sp)			# Restore $ra
	lw $s0, 8($sp)			# Restore $s0
	lw $s1, 4($sp)			# Restore $s1
	lw $s2, 0($sp)			# Restore $s2
	addi $sp, $sp, 16		# Adjust stack pointer
	
	jr $ra				# Return from function
	
	
# FUNCTION: int* heapSort(int* array,int size)
# Arguments are stored in $a0 = array, $a1 = size
# Return value is $v0 ( result array )
# Return address is stored in $ra (put there by jal instruction)
# Typical function operation is:
heapSort:

	# This function overwrites $s0 and $s1, $s1, $s2, $s4
	# We should save those on the stack
	# This is PUSH'ing onto the stack
	
	addi $sp, $sp, -24		# Adjust stack pointer
	sw $ra, 20($sp)			# Save $ra
	sw $s0, 16($sp)			# Save $s0
	sw $s1, 12($sp)			# Save $s1
	sw $s2, 8($sp)			# Save $s2
	sw $s3, 4($sp)			# Save $s3
	sw $s4, 0($sp)			# save $s4
	
	# Reg assignment
	# $s0 = array, $s1 = size, $s2 = i ( counter ), $s3 = j ( indexing )
	# $s4 = ret ( allocate address in heap ), $t0 = temp ( temporary value )

	move $s0, $a0			# array = $a0
	move $s1, $a1			# size = $a1
	
	sll $t0, $s1, 2			# $t0 = size * 4
	
	li $v0, 9			# allocate memory in heap syscall code = 9
	move $a0, $t0 			# Argument 1: 4 * size ( why, first argument is memory size )
	syscall			
	
	move $s4, $v0			# ret = malloc(4*size);
	
	move $s2, $s1			# i = size
	srl $s2, $s2, 1			# i = i / 2
	addi $s2, $s2, -1		# i = i - 1 
	maxheap_for_1:
		blt $s2, $zero, maxheap_for_1_end	# if ( i < 0 ) goto ordering_set label
	
		move $a0, $s0			# Argument 1 : array
		move $a1, $s1			# Argument 2 : size
		move $a2, $s2			# Argument 3 : i
		jal heapify			# heapify(array, size, i)

	maxheap_for_1_next:
		addi $s2, $s2, -1	# i = i - 1
		j maxheap_for_1		# jump to maxheap_for_1 label
		
	maxheap_for_1_end:
	

	addi $s2, $s1, -1		# i = size - 1
	ordering_for_1:
		blt $s2, $zero, ordering_for_1_end	# if ( i < 0 ) goto ordering_for_1_end label
	
		move $a0, $s0			# Argument 1: array
		move $a1, $zero			# Argument 2: 0
		jal get_element			# get_element(array, 0)
		
		sw $v0, 0($s4)			# *ret = $v0 = get_element(array, 0)

		move $a0, $s0			# Argument 1 : &array[0]
		mul $s3, $s2, 4			# j = 4 * i
		move $a1, $s0			# $a1 = array
		add $a1, $a1, $s3		# Argument 2 : &array[i] = array + 4 * j
		jal swap			# swap(&array[0], &array[i])
	
		move $a0, $s0			# Argument 1 : array
		move $a1, $s2			# Argument 2 : i
		move $a2, $zero			# Argument 3 : 0
		jal heapify			# heapify(array, i, 0)
	
	ordering_for_1_next:
		addi $s2, $s2, -1		# i = i - 1	
		addi $s4, $s4, 4		# ret++
		j ordering_for_1		# jump to ordering_for_1 label
		
	ordering_for_1_end:	
		mul $s3, $s1, 4			# j = size * 4
		sub $s4, $s4, $s3		# ret = ret - j
		move $v0, $s4			# $v0 = ret
	
heapSort_end:

	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack

	lw $ra, 20($sp)			# Restore $ra
	lw $s0, 16($sp)			# Restore $s0
	lw $s1, 12($sp)			# Restore $s1
	lw $s2, 8($sp)			# Restore $s2
	lw $s3, 4($sp)			# Restore $s3
	lw $s4, 0($sp)			# Restore $s4
	addi $sp, $sp, 24		# Adjust stack pointer

	jr $ra				# Return from function

# FUNCTION: void heapify(int* array,int size, int index)
# Arguments are stored in $a0 = array, $a1 = size, $a2 = index
# Return value is void
# Return address is stored in $ra (put there by jal instruction)
# Typical function operation is:
heapify:

	# This function overwrites $s0 and $s1, $s2, $s3, $s4, $s5
	# We should save those on the stack
	# This is PUSH'ing onto the stack
	
	addi $sp, $sp, -28	    	# Adjust stack pointer
	sw $ra, 24($sp)		    	# Save $ra
	sw $s0, 20($sp)		    	# Save $s0
	sw $s1, 16($sp)		    	# Save $s1
	sw $s2, 12($sp)		    	# Save $s2
	sw $s3, 8($sp)		    	# Save $s3
	sw $s4, 4($sp)		    	# Save $s4
	sw $s5, 0($sp)			# Save $s5

    	# Reg assignment
	# $s0 = array, $s1 = size, $s2 = index, $s3 = parent, $s4 = left, $s5 = right
	# $t0 = i ( indexing ), $t1 = array[parent], $t2 = array[left], $t3 = array[right]
	# &t4 = &array[parent], $t5 = &array[index]
	
	move $s0, $a0			# array = $a0
	move $s1, $a1			# size = $a1
	move $s2, $a2			# index = $a2
	
	move $s3, $s2			# parent = index
	move $s4, $s3			# left = parent
	sll $s4, $s4,1			# left = left * 2
	
	addi $s4, $s4, 1		# Left = Left + 1
	addi $s5, $s4, 1		# right = left + 1
	
	bge $s4, $s1, branch1		# if ( left >=  size ) goto branch1
	
	move $a0, $s0			# Argument 1: array
	move $a1, $s3			# Argument 2: parent
	jal get_element			# get_element(array, parent)
	move $t1, $v0			# $t1 = $v0 = get_element(array, parent)
	
	move $a0, $s0			# Argument 1: array
	move $a1, $s4			# Argument 2: left
	jal get_element 		# get_element(array, left)
	move $t2, $v0			# $t2 = $v0 = get_element(array, left)
	
	bge $t1, $t2, branch1		# if ( array[paraent] >= array[left] ) goto branch1 label
	move $s3, $s4           	# parent = left
	
	branch1:	
		bge $s5, $s1, branch2		# if ( right >= size ) goto branch2 label

		move $a0, $s0			# Argument 1: array
		move $a1, $s3			# Argument 2: parent
		jal get_element 		# get_element(array, parent)
		move $t1, $v0			# $t1 = $v0 = get_element(array, parent)

		move $a0, $s0			# Argument 1: array
		move $a1, $s5			# Argument 2: right
		jal get_element 		# get_element(array, right)
		move $t3, $v0			# $t3 = $v0 = get_element(array, right)
	
		bge $t1, $t3, branch2		# if ( array[parent] >= array[right]) goto branch2 label
		move $s3, $s5           	# parent = right
	
	branch2:
		bne $s2, $s3, action		# if ( index != parent ) goto action label
		j heapify_end			# jump to heapify_end label
	
		action:
			sll $t0, $s3, 2         	# i = 4 * parent
			add $t4, $s0, $t0		# array += i

			sll $t0, $s2, 2         	# i = 4 * index
			add $t5, $s0, $t0		# array += i
	
			move $a0, $t4			# Argument 1: &array[parent]
			move $a1, $t5			# Argument 2: &array[index]
			jal swap			# swap(&array[parent], &array[index])	
	
			move $a0, $s0			# Argument 1: array
			move $a1, $s1			# Argument 2: size
			move $a2, $s3			# Argument 3: parent
			jal heapify             	# heapify(array, size, parent)
		
heapify_end:

	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
	
	lw $ra, 24($sp)		    	# Restore $ra
	lw $s0, 20($sp)		    	# Restore $s0
	lw $s1, 16($sp)		    	# Restore $s1
	lw $s2, 12($sp)		    	# Restore $s2
	lw $s3, 8($sp)		    	# Restore $s3
	lw $s4, 4($sp)		    	# Restore $s4
    	lw $s5, 0($sp)          	# Restore $s5
	addi $sp, $sp, 28	    	# Adjust stack pointer
	
	jr $ra			        # Return from function
	
	
# FUNCTION: void print(int* array,int size)
# Arguments are stored in $a0 = array, $a1 = size
# Return value is void
# Return address is stored in $ra (put there by jal instruction)
# Typical function operation is:
print:

	# This function overwrites $s0 and $s1, $s2
	# We should save those on the stack
	# This is PUSH'ing onto the stack
	
	addi $sp, $sp, -16		# Adjust stack pointer	
	sw $ra, 12($sp)			# Save $ra
	sw $s0, 8($sp)			# Save $s0
	sw $s1, 4($sp)			# Save $s1
	sw $s2, 0($sp)			# Save $s2
	
	# Reg assignment
	# $s0 = array, $s1 = size , $s2 = i ( counter )
	
	move $s0, $a0			# array = $a0
	move $s1, $a1			# size = $a1
	
	li $s2, 0			# i = 0
	print_for_1:
		beq $s1, $s2, print_for_1_end	# if ( size == i ) goto print_for_1_end label
		
		li $v0, 1			# print_int syscall code = 1
		lw $a0, 0($s0)		
		syscall
		
		# Print delimiter
		li $v0, 4			# print_string syscall code = 4
		la $a0, delimiter
		syscall
		
	print_for_1_next:
		add $s2, $s2, 1			# i = i + 1
		addi $s0, $s0, 4		# array++
		j print_for_1			# Jump to print_for_1_label
		
	print_for_1_end:
		# Print newLine	
		li $v0, 4			# print_string syscall code = 4
		la $a0, newLine
		syscall
			
print_end:

	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
	
	lw $ra, 12($sp)			# Restore $ra
	lw $s0, 8($sp)			# Restore $s0
	lw $s1, 4($sp)			# Restore $s1
	lw $s2, 0($sp)			# Restore $s2
	addi $sp, $sp, 16		# Adjust stack pointer
	
	jr $ra				# Return from function		


# FUNCTION: void swap(int* a, int* b)
# Arguments are stored in $a0 = a , $a1 = b
# Return value is void
# Return address is stored in $ra (put there by jal instruction)
# Typical function operation is:
swap:

	# This function overwrites $s0 and $s1
	# We should save those on the stack
	# This is PUSH'ing onto the stack
	
	addi $sp, $sp, -12		# Adjust stack pointer
	sw $ra, 8($sp)			# Save $ra
	sw $s0, 4($sp)			# Save $s0
	sw $s1, 0($sp)			# Save $s1
	
	# Reg assignment
	# $s0 = val1, $s1 = val2
	
	lw $s0, 0($a0)			# val1 = *a
	lw $s1, 0($a1)			# val2 = *b
	
	sw $s1, 0($a0)			# *a = val2
	sw $s0, 0($a1)			# *b = val1
	
swap_end:

	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
	
	lw $ra, 8($sp)			# Restore $ra
	lw $s0, 4($sp)			# Restore $s0
	lw $s1, 0($sp)			# Resotre $s1
	addi $sp, $sp,12		# Adjust stack pointer
	
	jr $ra				# Return from function		


.data

array: 		.space 40 		# Heap Array Memory Size = Heap Array length * 4
size: 		.word 10		# Heap Array length
delimiter: 	.asciiz " "		# delimiter for heap array elements printing
newLine:	.asciiz "\n"		# line feed
