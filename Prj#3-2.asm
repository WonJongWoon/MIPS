.text

.globl main

main:
	# Register assignments
	# s0 = array, $s1 = size, $s2 = i ( counter )
	
	la $s0, array 			# $s0 = array
	lw $s1, size			# $s1 = size
	li $s2, 0			# i = 0
	
main_loop:
	bge $s2, $s1, main_end		# if (i >= size) goto main_end label
	move $a0, $s0			# Argument 1: &array
	move $a1, $s2			# Argument 2: i
	jal input			# input(&array, i)
	
	addi $s2, $s2, 1		# i = i + 1
	
	move $a0, $s0			# Argument 1: &array
	move $a1, $s2			# Argument 2: i
	jal heapSort			# heapSort(&array, i)
	
	move $a0, $v0			# Argument 1: $v0 [ $v0 = heapSort(&array, i) ]
	move $a1, $s2			# Argument 2: i
	jal print			# print(&array, i)
	
	j main_loop			# goto main_loop label
	
# FUNCTION: void input(int* array,int index)
# Arguments are stored in $a0 (array), $a1 (index)
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
	
	mul $s2, $s1,4			# i = index * 4
	add $s0, $s0, $s2		# array += i 
	
	li $v0,5			# read_int syscall code = 5
	syscall				# syscall results returned in $v0
	sw $v0, 0($s0)			# *array = $v0 
	
	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
	
	lw $ra, 12($sp)			# Restore $ra
	lw $s0, 8($sp)			# Restore $s0
	lw $s1, 4($sp)			# Restore $s1
	lw $s2, 0($sp)			# Restore $s2
	addi $sp, $sp, 16		# Adjust stack pointer
	
	# Return from function
	jr $ra				# Jump to addr stored in $ra
	
	
# FUNCTION: int* heapSort(int* array,int size)
# Arguments are stored in $a0 (array), $a1 (size)
# Return value is $v0 ( result array )
# Return address is stored in $ra (put there by jal instruction)
# Typical function operation is:
heapSort:

	# This function overwrites $s0 and $s1, $s2, $s3, $s4
	# We should save those on the stack
	# This is PUSH'ing onto the stack
	
	addi $sp, $sp, -24		# Adjust stack pointer
	sw $ra, 20($sp)			# Save $ra
	sw $s0, 16($sp)			# Save $s0
	sw $s1, 12($sp)			# Save $s1
	sw $s2, 8($sp)			# Save $s2
	sw $s3, 4($sp)			# Save $s3
	sw $s4, 0($sp)			# Save $s4
	
	# Reg assignment
	# $s0 = array, $s1 = bArray ( immutable, for restore ), $s2 = size
    	# $s3 = i ( counter ) , $s4 = j ( indexing ) $t0 = temp ( temporary value )
	# $v0 = return 
	
	move $s0, $a0			# array = $a0
    	move $s1, $a0			# bArray = $a0
	move $s2, $a1			# size = $a1
	la $v0, result			# return = result ( empty array for return )
	
	move $s3, $s2			# i = size
	srl $s3, $s3, 1			# i = i / 2
	addi $s3, $s3, -1		# i = i - 1 
	
	# normal array to max heap
	maxheap_loop:
	blt $s3, $zero, ordering_set	# if ( i < 0 ) goto ordering_set label
	
	move $a0, $s0			# Argument 1 : &array
	move $a1, $s2			# Argument 2 : size
	move $a2, $s3			# Argument 3 : i
	jal heapify			# heapify(&array, size, i)
	addi $s3, $s3, -1		# i = i - 1
	j maxheap_loop			# jump to maxheap_loop label
	
	# setting for ordering_loop
	ordering_set:
	
	move $s3, $s2			# i = size
	addi $s3, $s3, -1		# i = i - 1

	mul $s4, $s3, 4			# j = i * 4
	add $s0, $s0, $s4		# array += j 

	# extract max elements from heap
	ordering_loop:
	blt $s3, $zero, heapSort_end	# if ( i < 0 ) goto heapSort_end label
	
	lw $t0, 0($s1)			# temp = &array[0]
	sw $t0, 0($v0)			# *result = temp
	addi $v0, $v0, 4		# result++
	
	move $a0, $s1			# Argument 1 : &array[0]
	move $a1, $s0			# Argument 2 : &array[i]
	jal swap			# swap(&array[0], &array[i])
	
	move $a0, $s1			# Argument 1 : &array
	move $a1, $s3			# Argument 2 : i
	move $a2, $zero			# Argument 3 : 0
	jal heapify			# heapify(&array, i, 0)
	
	addi $s3, $s3, -1		# i = i - 1	
	addi $s0, $s0, -4		# array--
	j ordering_loop			# jump to ordering_loop label
		
	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
	
	heapSort_end:
	la $v0, result			# restore result start address
	
	lw $ra, 20($sp)			# Restore $ra
	lw $s0, 16($sp)			# Restore $s0
	lw $s1, 12($sp)			# Restore $s1
	lw $s2, 8($sp)			# Restore $s2
	lw $s3, 4($sp)			# Restore $s3
	lw $s4, 0($sp)			# Restore $s4
	addi $sp, $sp, 24		# Adjust stack pointer

	# Return from function
	jr $ra				# Jump to addr stored in $ra	

# FUNCTION: void heapify(int* array,int size, int index)
# Arguments are stored in $a0 (array), $a1 (size), $a2 (index)
# Return value is void
# Return address is stored in $ra (put there by jal instruction)
# Typical function operation is:
heapify:

	# This function overwrites $s0 and $s2, $s3, $s4, $s5, $s6
	# We should save those on the stack
	# This is PUSH'ing onto the stack
	
	addi $sp, $sp, -32	    	# Adjust stack pointer
	sw $ra, 28($sp)		    	# Save $ra
	sw $s0, 24($sp)		    	# Save $s0
	sw $s1, 20($sp)		    	# Save $s1
	sw $s2, 16($sp)		    	# Save $s2
	sw $s3, 12($sp)		    	# Save $s3
	sw $s4, 8($sp)		    	# Save $s4
	sw $s5, 4($sp)		    	# Save $s5
	sw $s6, 0($sp)			# Save $s6

    	# Reg assignment
	# $s0 = array, $s1 = bArray, $s2 = size, $s3 = index, $s4 = parent, $s5 = left, $s6 = right
	# $t0 = i ( indexing ), $t1 = array[index], $t2 = array[paraent], $t3 = array[left]
	# &t4 = &array[parent], $t5 = array[index]
	
	move $s0, $a0			# array = $a0
	move $s1, $a0			# bArray = $a0
	move $s2, $a1			# size = $a1
	move $s3, $a2			# index = $a2
	
	move $s4, $s3			# parent = index
	move $s5, $s4			# left = parent
	mul $s5, $s5,2			# left = left * 2
	
	addi $s6, $s5, 2		# Right = Left + 2
	addi $s5, $s5, 1		# Left = Left + 1
	
	bge $s5, $s2, branch2		# if ( left >=  size ) goto branch2
	
	move $s0, $a0			# array = $a0
	mul $t0, $s4, 4			# i = 4 * parent
	add $s0, $s0, $t0		# array += i
	lw $t1, 0($s0)			# $t1 = array[parent]
	
	move $s0, $a0			# array = $a0
	mul $t0, $s5, 4			# i = 4 * left
	add $s0, $s0, $t0		# array += i
	lw $t2, 0($s0)			# $t2 = array[left]
	
	bge $t1, $t2, branch2		# if ( array[paraent] >= array[left] ) goto branch2 label
	move $s4, $s5           	# parent = left
	
	branch2:	
	bge $s6, $s2, branch3		# if ( right >= size ) goto branch3 label

	move $s0, $a0			# array = $a0
	mul $t0, $s4, 4			# i = 4 * parent
	add $s0, $s0, $t0       	# array += i
	lw $t1, 0($s0)			# $t1 = array[parent]
	
	move $s0, $a0			# array = $a0
	mul $t0, $s6, 4			# i = 4 * right
	add $s0, $s0, $t0       	# array += i
	lw $t3, 0($s0)			# $t3 = array[right]
	
	bge $t1, $t3, branch3		# if ( array[parent] >= array[right]) goto branch3 label
	move $s4, $s6           	# parent = right
	
	branch3:
	bne $s3, $s4, action		# if ( index != parent ) goto action label
	j heapify_end			# jump to heapify_end label
	
	action:
	move $s0, $a0			# array = $a0
	mul $t0, $s4, 4         	# i = 4 * parent
	add $t4, $s0, $t0		# array += i
	
	move $s0, $a0			# array = $a0
	mul $t0, $s3, 4         	# i = 4 * index
	add $t5, $s0, $t0		# array += i
	
	move $a0, $t4			# Argument 1: &array[parent]
	move $a1, $t5			# Argument 2: &array[index]
	jal swap			# swap(&array[parent], &array[index])	
	
	move $a0, $s1			# Argument 1: &array
	move $a1, $s2			# Argument 2: size
	move $a2, $s4			# Argument 3: parent
	jal heapify             	# heapify(&array, size, parent)
	
	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
	
	heapify_end:
	lw $ra, 28($sp)		    	# Restore $ra
	lw $s0, 24($sp)		    	# Restore $s0
	lw $s1, 20($sp)		    	# Restore $s1
	lw $s2, 16($sp)		    	# Restore $s2
	lw $s3, 12($sp)		    	# Restore $s3
	lw $s4, 8($sp)		    	# Restore $s4
	lw $s5, 4($sp)		    	# Restore $s5
    	lw $s6, 0($sp)          	# Restore $s6
	addi $sp, $sp, 32	    	# Adjust stack pointer
	
	# Return from function
	jr $ra			        # Jump to addr stored in $ra	
	
	
# FUNCTION: void print(int* array,int size)
# Arguments are stored in $a0 (array), $a1 (size)
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
		
print_loop:
	li $v0, 1			# print_int syscall code = 1
	lw $a0, 0($s0)		
	syscall
	
	addi $s2, $s2, 1		# i = i + 1
	addi $s0, $s0, 4		# array++
	
	beq $s2, $s1, print_end		# if (i == size) goto print_end label
		
	# Print delimiter
	li $v0, 4			# print_string syscall code = 4
	la $a0, delimiter
	syscall
	
	j print_loop			# Jump to loop

print_end:

	# Print newLine	
	li $v0, 4			# print_string syscall code = 4
	la $a0, newLine
	syscall
	
	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
	
	lw $ra, 12($sp)			# Restore $ra
	lw $s0, 8($sp)			# Restore $s0
	lw $s1, 4($sp)			# Restore $s1
	lw $s2, 0($sp)			# Restore $s2
	addi $sp, $sp, 16		# Adjust stack pointer
	
	# Return from function
	jr $ra				# Jump to addr stored in $ra		


# FUNCTION: void swap(int *a, int *b)
# Arguments are stored in $a0 (a), $a1 (b)
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
	
	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
	
	lw $ra, 8($sp)			# Restore $ra
	lw $s0, 4($sp)			# Restore $s0
	lw $s1, 0($sp)			# Resotre $s1
	addi $sp, $sp,12		# Adjust stack pointer
	
	# Return from function
	jr $ra				# Jump to addr stored in $ra			

main_end:	
	li $v0, 10			# exit syscall code = 10
	syscall


.data

array: 		.space 40 		# Heap Array Memory Size = Heap Array length * 4
result:		.space 40 		# Result Array Memroy Size = Heap Array Legnth * 4
size: 		.word 10		# Heap Array length
delimiter: 	.asciiz " "		# delimiter for heap array elements printing
newLine:	.asciiz "\n"		# line feed
