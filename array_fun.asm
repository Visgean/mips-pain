.data

# Names is the data allocation of our list
names: .space 16

rajesh: .asciiz "Rajesh"
tomas: .asciiz "Tomas"
krendis: .asciiz "Krendis"
petr: .asciiz "Petr"

.text

main: 
	la $t0, names
	
	la $t1, rajesh
	sw $t1, 0($t0)
	
	la $t1, tomas
	sw $t1, 4($t0)
	
	
	# printing the name
	li $v0, 4
	lw $a0, 0($t0)
	syscall
	
	
	li $v0, 4
	lw $a0, 4($t0)
	syscall