.data
	
	# allocate 1000 bytes for the input
	input: 		.space 		1000
	
	# define text variables
	prompt1:        .asciiz  	"Enter input: "
	newline:        .asciiz  	"\n"

	# iterator used to iterate over single character
	iterator: 	.word 		0
	max_size:	.word		1000

	

.text

main:
	# Prompt:	
	li   $v0, 4           	# print_string("Enter decimal number: ");
        la   $a0, prompt1
        syscall	
        
	# get_input()
        li $v0, 8 		# syscall #8 means reading string
        la $a0, input 		# 1st arg is buffer
        la $a1, max_size 	# 2nd arg is max lenght
        syscall
       
        
        # print_chars()
        la $a0, input 		# 1st arg is buffer
        la $a1, max_size 	# 2nd arg is max lenght
        jal print_chars
	

        j end  			# end-me 
		



print_chars:  # print_char($a0: string, $a1: size)
	# Registers used in this function:
	# t0 - address of the string
	# t1 - size 
	# t2 - iterator

	
	# store arguments in different variables:
	move $t0, $a0
	move $t1, $a1	
	
	# initialize iterator of our while loop to 0
	li $t2, 0
	
	# start our while loop:
	while:		 
		# if iterator == size: jump to exit
		beq $t0, $t2, exit_loop
		
		# t2 = iterator + base_address
		add $t3, $t0, $t2
		# load byte at t1 and store it at a2
		lb $a0, ($t3) 
		
		# jump if we encountered zero byte
		beq $a0, $0, exit_loop
		
		
		
		# print the char
		li $v0, 11
		syscall	
		
		# iterator += 1
		addi $t2, $t2, 1
		
		j while
		
	exit_loop:	
		jr $ra  		# return 


end:      
	# print newline
        li   $v0, 4           
        la   $a0, newline
        syscall

	# call sys exit
        li   $v0, 10         
        syscall	
