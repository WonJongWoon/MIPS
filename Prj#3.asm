.text

.globl main

main:
	# Register assignments
	# s0 = heap, $s1 = size, $s2 = i ( counter )
	
	la $s0, heap 			# $s0 = heap
	lw $s1, size			# $s1 = size
	li $s2, 0			# i = 0
	
main_loop:
	move $a0, $s0			# Argument 1: &heap
	move $a1, $s2			# Argument 2: i
	jal input			# input(&heap, i)
	
	addi $s2, $s2, 1		# i = i + 1
	
	move $a0, $s0			# Argument 1: &heap
	move $a1, $s2			# Argument 2: i
	jal heapSort			# heapSort(&heap, i)
	
	move $a0, $s0			# Argument 1: &heap
	move $a1, $s2			# Argument 2: i
	jal print			# print(&heap, i)
	
	bne $s2, $s1, main_loop		# if (i != size) goto main_loop
	j main_end			# if (i == size) goto exit
	
# FUNCTION: void input(int* heap,int index)
# Arguments are stored in $a0 (heap), $a1 (index)
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
	# $s0 = heap, $s1 = index, $s2 = i ( indexing )
	
	move $s0, $a0			# heap = $a0
	move $s1, $a1			# index = $a1
	li $s2, 0			# Initialize indexing ( i )
	
	mul $s2, $s1,4			# i = index * 4
	add $s0, $s0, $s2		# heap += i
	
	li $v0,5			# read_int syscall code = 5
	syscall				# syscall results returned in $v0
	sw $v0, 0($s0)			# *heap = $v0
	
	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
	
	lw $ra, 12($sp)			# Restore $ra
	lw $s0, 8($sp)			# Restore $s0
	lw $s1, 4($sp)			# Restore $s1
	lw $s2, 0($sp)			# Restore $s2
	addi $sp, $sp, 16		# Adjust stack pointer
	
	# Return from function
	jr $ra				# Jump to addr stored in $ra
	
	
# FUNCTION: void heapSort(int* heap,int size)
# Arguments are stored in $a0 (heap), $a1 (sizex)
# Return value is void
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
	# $s0 = heap, $s1 = bHeap ( immutable, for restore ), $s2 = size
    	# $s3 = i ( counter ) , $s4 = j ( indexing )

	move $s0, $a0			# heap = $a0
    	move $s1, $a0			# bHeap = $a0
	move $s2, $a1			# size = $a1
	
	move $s3, $s2			# i = size
	srl $s3, $s3, 1			# i = i / 2
	addi $s3, $s3, -1		# i = i - 1
	
	# normal array to max heap
	maxheap_loop:
	blt $s3, $zero, ordering_set	# if ( i < 0 ) goto ordering_set label
	
	move $a0, $s0			# Argument 1 : &heap
	move $a1, $s2			# Arugment 2 : size
	move $a2, $s3			# Arguemnt 3 : i
	jal heapify			# heapify(&heap, size, i)
	addi $s3, $s3, -1		# i = i - 1
	j maxheap_loop			# jump to maxheap_loop label
	
	# setting for next 
	ordering_set:
	
	move $s3, $s2			# i = size
	addi $s3, $s3, -1		# i = i - 1
	
	mul $s4, $s3, 4			# j = i * 4
	add $s0, $s0, $s4		# heap += j
	
	# extract max elements from heap
	ordering_loop:
	beq $s3, $zero, heapSort_end	# if ( i == 0 ) goto heapSort_end label
	
	move $a0, $s1			# Argument 1 : &heap[0]
	move $a1, $s0			# Argument 2 : &heap[i]
	jal swap			# swap(&heap[0], &heap[i])
	
	move $a0, $s1			# Argument 1 : &heap
	move $a1, $s3			# Argument 2 : i
	move $a2, $zero			# Arugment 3 : 0
	jal heapify			# heapify(&heap, i, 0)
	
	addi $s3, $s3, -1		# i = i - 1	
	addi $s0, $s0, -4		# heap--
	j ordering_loop			# jump to ordering_loop label
		
	# Restore saved register values from stack in opposite order
	# This is POP'ing from the stack
	
	heapSort_end:
	lw $ra, 20($sp)			# Restore $ra
	lw $s0, 16($sp)			# Restore $s0
	lw $s1, 12($sp)			# Restore $s2
	lw $s2, 8($sp)			# Restore $s3
	lw $s3, 4($sp)			# Restore $s4
	lw $s4, 0($sp)			# Restore $s1
	addi $sp, $sp, 24		# Adjust stack pointer

	# Return from function
	jr $ra				# Jump to addr stored in $ra	

# FUNCTION: void heapify(int* heap,int size, int index)
# Arguments are stored in $a0 (heap), $a1 (size), $a2 (index)
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
	# $s0 = heap, , $s1 = bHeap, $s2 = size, $s3 = index, $s4 = parent, $s5 = left, $s6 = right
	# $t0 = i ( indexing ), t1 = &heap[index], $t2 = &heap[paraent], &t3 = &heap[left], &t4 = &heap[right]
	# t5 = heap[parent], $t6 = heap[left], $t7 = heap[Right]
	
	move $s0, $a0			# heap = $a0
	move $s1, $a0			# bHeap = $a0
	move $s2, $a1			# size = $a1
	move $s3, $a2			# index = $s3
	
	move $s4, $s3			# parent = index
	move $s5, $s4			# left = parent
	mul $s5, $s5,2			# left = left * 2
	
	addi $s6, $s5, 2		# Right = Left + 2
	addi $s5, $s5, 1		# Left = Left + 1

	move $t0, $s3			# i = index
	mul $t0, $t0, 4			# i = i * 4
	
	add $s0, $s0, $t0       	# heap += i
	move $t1, $s0			# $t1 = &heap[index]
	move $t2, $s0			# $t2 = &heap[parent]
	
	add $s0, $s0, $t0		# heap += i
	addi $s0, $s0, 4		# heap++
	move $t3, $s0			# $t3 = &heap[left]
	
	addi $s0, $s0, 4       		# heap++
	move $t4, $s0 			# $t4 = &heap[right]
	
	bge $s5, $s2, branch2		# if ( left >=  size ) goto branch2
	
	lw $t5, 0($t2)			# $t5 = heap[parent]
	lw $t6, 0($t3)			# $t6 = heap[left]
	
	bge $t5, $t6, branch2		# if ( heap[paraent] >= heap[left] ) goto branch2 label
	move $s4, $s5           	# parent = left
	
	branch2:	
	bge $s6, $s2, branch3		# if ( right >= size ) goto branch3 label

	move $t0, $s4           	# i = parent
	mul $t0, $t0, 4         	# i = i * 4
	add $t2, $s1, $t0       	# $t2 = heap[parent]
	
	lw $t5, 0($t2)			# $t5 = heap[parent]
	lw $t7, 0($t4)			# $t7 = heap[right]
	
	bge $t5, $t7, branch3		# if ( heap[parent] >= heap[right]) goto branch3 label
	move $s4, $s6           	# parent = right
	
	branch3:
	bne $s3, $s4, action		# if ( index != parent ) goto action label
	j heapify_end			# jump to heapify_end label
	
	action:
	mul $t0, $s4, 4         	# i = 4 * parent
	add $t2, $a0, $t0		# $t2 = heap[parent]
	
	move $a0, $t2			# Argument 1: &heap[parent]
	move $a1, $t1			# Argument 2: &heap[index]
	jal swap			# swap(&heap[parent], &heap[index])	
	
	move $a0, $s1			# Argument 1: &heap
	move $a1, $s2			# Argument 2: size
	move $a2, $s4			# Argument 3: parent
	jal heapify             	# heapify(&heap, size, parent)
	
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
	
	
# FUNCTION: void print(int* heap,int size)
# Arguments are stored in $a0 (heap), $a1 (size)
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
	# $s0 = heap, $s1 = size , $s2 = i ( counter )
	
	move $s0, $a0			# heap = $a0
	move $s1, $a1			# size = $a1
	li $s2, 0			# i = 0
		
print_loop:
	li $v0, 1			# print_int syscall code = 1
	lw $a0, 0($s0)		
	syscall
	
	addi $s2, $s2, 1		# i = i + 1
	addi $s0, $s0, 4		# heap++
	
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

heap: 		.space 40 		# Heap Array Memory Size = Heap Array length * 4
size: 		.word 10		# Heap Array length
delimiter: 	.asciiz " "		# delimiter for heap array elements printing
newLine:	.asciiz "\n"		# line feed
