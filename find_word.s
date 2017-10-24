# This file was formatted for normal text editors, not mars!


.data
    # allocate 1000 bytes for the input
    input: 		    .space 		1001
    word_found:	    .space 		51

    # define text variables
    prompt1:        .asciiz  	"Enter input: "
    newline:        .asciiz  	"\n"
    endprompt:      .asciiz  	"\noutput: \n"

    hyphen:		    .asciiz		"-"

    # iterator used to iterate over single character
    iterator: 	    .word 		0
    max_size:	    .word		1000

.text

main:
    # Prompt:
    li   $v0, 4           	# print_string("Enter input: ");
    la   $a0, prompt1
    syscall
        
    # get_input()
    li $v0, 8 		# syscall #8 means reading string
    la $a0, input 		# 1st arg is buffer
    la $a1, max_size 	# 2nd arg is max lenght
    syscall
       
       
    # s0 will hold pointer to last processed character
    la $s0, input

    # output:
    li   $v0, 4
    la   $a0, endprompt
    syscall

    main_loop:
        move $a0, $s0
        la $a1, word_found
        jal process_input

        # If we have enountered a zero byte exit
        bne $0, $v1, end

        # save new addres to $s0
        move $s0, $v0

        # print the word
        li   $v0, 4
        la   $a0, word_found
        syscall

        # line between words

        li   $v0, 4
        la   $a0, newline
        syscall

        j main_loop
        

process_input: 	
    # (a0: address to beggining of string, a1: address where to store it)
    # -> v0: new address of the string
    # -> v1: set to 1 if we encountered zero byte - end of sentence

    # I have modified the arguments of this function to make it more pure and
    # not dependent on the global variables

    # Register usage:
    # s0 - pointer to current char
    # s1 - pointer to last character in a parsed word
    # s2 - current character
    # s3 - our return address
    # s4 - number of accepted characters

    # Make this function stack neutral:
    addi $sp, $sp, -20
    sw   $s0, 0($sp)
    sw   $s1, 4($sp)
    sw   $s2, 8($sp)
    sw   $s3, 12($sp)
    sw   $s4, 16($sp)


    # move our arguments to stack so that they dont get lost when we call function
    move $s0, $a0
    move $s1, $a1
    move $s3, $ra

    # so far we accepted 0 chars:
    li $s4, 0

    # we did not encountered a zero byte so far
    li $v1, 0


    # start our while loop:
    while_char:
        # load byte at t1 and store it at a2
        lb $s2, ($s0)
        move $a0, $s2

        # end of sentence we encountered zero byte
        beq $a0, $0, exit_final

        # v0 = is_valid_char(a0)
        jal is_valid_character

        # if not is_valid_character(a0): return
        beq $v0, $0, handle_invalid_char

        handle_valid_char:
            # save char to the word buffer
            sb $s2, 0($s1)

            # move to the next char:
            addi $s0, $s0, 1
            addi $s1, $s1, 1
            # increase number of accepted chars:
            addi $s4, $s4, 1
            j while_char

        handle_invalid_char:
            # if we still did not accept any char we should just move on.
            beq $s4, $0, continue

            # else we should check if its a hyphen:
            move $a0, $s2
            jal is_hyphen

            beq $v0, $0, exit_loop

            handle_hyphen: # we have to do look-ahead to check if the next character is valid:
                addi $t0, $s0, 1
                lb $a0, ($t0)
                jal is_valid_character
                beq $v0, $0, exit_loop  # if next char is not valid it means end of word

                j handle_valid_char     # add hyphen to the word
            continue:
                addi $s0, $s0, 1
                j while_char


    exit_final: 		# End of sentence.
        li $v1, 1
        j exit_loop

    exit_loop:
        # add 0 byte to parsed word to end it - we need to do this because that memory might have contained a longer word before

        #addi $t1, $s1, 1
        sb $0, 0($s1)

        # save return address to t0 so we can restore s3 register
        move $t0, $s3
        move $v0, $s0


        # restore stack
        lw   $s0, 0($sp)
        lw   $s1, 4($sp)
        lw   $s2, 8($sp)
        lw   $s3, 12($sp)
        lw   $s4, 16($sp)
        addi $sp, $sp, 20
        jr $t0  	   # return
              
                
is_valid_character: # is_valid_character(char a0) -> 0/1 bool set to v0 if this is character
    slti $t0, $a0, 65  			# if a0 > A
    beq  $t0, $0,  over65  			# goto over65

    j return_false				# else return false

    over65:
        slti $t0, $a0, 91  		# if a0 > Z
        beq  $t0, $0,  over90  		# goto over65
        j return_true			# else return true

    over90:
        slti $t0, $a0, 97  		# if a0 > a
        beq  $t0, $0,  over97  		# jump to over97
        j return_false			# else return false

    over97:
        slti $t0, $a0, 123  		# if a0 > a
        beq  $t0, $0,  return_false 	# jump to over97
        j return_true			# else return false

is_hyphen: # return a0 == '-' 
    la $t0, hyphen
    lb $t0, ($t0)
    bne $a0, $t0, return_false
    j return_true


# even though these return statements should probably be separate for each function I think we can use them for all functions
return_false:
    li $v0, 0
    jr $ra

return_true:	
    li $v0, 1
    jr $ra
    j return_true

end:      
    # call sys exit
    li   $v0, 10
    syscall
