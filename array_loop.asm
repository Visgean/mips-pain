.data


rajesh: 	.asciiz "Rajesh\n"
tomas: 		.asciiz "Tom\n"
krendis: 	.asciiz "Kren\n"
petr: 		.asciiz "Petr\n"

names: 		.word rajesh, tomas, krendis, petr

iterator: 	.word 		0
size: 		.word 		3  # 0, 1, 2, 3 - max index of our words

.text
main:
	la $t0, names
	lw $t1, iterator
	lw $t2, size
	
	
	#print ith word, increase i
	
begin_loop:	
	bgt $t1, $t2, exit_loop
	
	# iterator * 4
	sll $t3, $t1, 2
	addu $t3, $t3, $t0
	
	# print: 
	li $v0, 4
	lw $a0, 0($t3)
	syscall
	
	# add 1 to iterator	
	addi $t1, $t1, 1
	
	j begin_loop
	
	
exit_loop:
