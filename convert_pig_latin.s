# This file was formatted for normal text editors, not mars!

.data

    # allocate 1000 bytes for the input
    input:          .space      1001
    output:         .space      3001

    # buffer for a single world
    word_found:     .space      55
    # buffer for a converted world
    word_converted: .space      301

    # define text variables
    prompt1:        .asciiz     "Enter input: "
    endprompt:      .asciiz     "output: "
    newline:        .asciiz     "\n"

    hyphen:         .asciiz     "-"
    max_size:       .word       1000

.text

main:
    # Prompt:
    li   $v0, 4             # print_string("Enter input: ");
    la   $a0, prompt1
    syscall
        
    # get_input()
    li $v0, 8           # syscall #8 means reading string
    la $a0, input       # 1st arg is buffer
    la $a1, max_size    # 2nd arg is max lenght
    syscall
    
    # process input:
    j process_input


    print_output:
        # output:
        li   $v0, 4
        la   $a0, endprompt
        syscall

        # output:
        li   $v0, 4
        la   $a0, output
        syscall

    j end

convert_word:
    # Converts the word in word_found and stores it in word_converted
    # Register usage:
    # s0 - return address
    # s1 - buffer with the input word
    # s2 - buffer with the output word
    # s3 - capitalize all
    # s4 - capitalize 1st
    # s5 - location of the 1st vowel

    # Make this function stack neutral:
    addi $sp, $sp, -24
    sw   $s0, 0($sp)
    sw   $s1, 4($sp)
    sw   $s2, 8($sp)
    sw   $s3, 12($sp)
    sw   $s4, 16($sp)
    sw   $s5, 20($sp)

    move $s0, $ra
    la $s1, word_found
    la $s2, word_converted


    ### Handle capitalization flags:
    la $a0, word_found
    jal is_capital_only
    move $s3, $v0        # s1 = is_capital_only(word)
    # check that 1st letter is capital:
    lb $a0, ($s1)
    # v0 = is_uppercase(a0)
    jal is_uppercase
    # capitalize_first = ((!capitalized_all) && (is_capital(word[0]))
    not $t0, $s3
    and $s4, $t0, $v0


    # if the 1st letter of the word is uppercase we should loverwase it
    # before it gets to the middle of the output word
    beq $s4, $0, no_lowercasing
        lb $t1, ($s1)
        addi $t1, $t1, 32
        sb $t1, ($s1)

    no_lowercasing:


    # find a position of 1st vowel
    li $s5, 0
    while_not_vowel:
        lb $a0, ($s1)
        beq $a0, $0, vowel_or_exit
        jal is_vowel
        bne $v0, $0, vowel_or_exit
        # increase char position and vowel index
        addi $s5, $s5, 1
        addi $s1, $s1, 1

    j while_not_vowel

    vowel_or_exit:  # we either find vowel or end of the word

    # add all chars after the vowel to the word:
    while_add_after_vowel:
        lb $t1, 0($s1)
        beq $t1, $0, chars_before_vowel_added   # exit on end of word

        sb $t1, 0($s2)      # out[output_index] = converted_word[i];
        addi $s2, $s2, 1    # output_index += 1;
        addi $s1, $s1, 1

        j while_add_after_vowel

    chars_before_vowel_added:

    # reset pointer to the begining of the word
    la $s1, word_found
    la $t0, 0

    add_chars_before_vowel:
        beq $t0, $s5, add_ay  # if we are at vowel position stop adding letters

        lb $t1, 0($s1)
        beq $t1, $0, add_ay   # exit on end of word

        sb $t1, 0($s2)        # out[output_index] = converted_word[i];
        addi $s2, $s2, 1      # output_index += 1;
        addi $s1, $s1, 1
        addi $t0, $t0, 1

        j add_chars_before_vowel


    add_ay:
        bne $0, $s3, add_big

        add_small:
            li $t0, 'a'
            sb $t0, 0($s2)
            li $t0, 'y'
            sb $t0, 1($s2)

            j add0

        add_big:
            li $t0, 'A'
            sb $t0, 0($s2)
            li $t0, 'Y'
            sb $t0, 1($s2)

    add0:

    sb $0,  2($s2)


    # if the 1st letter of the word is uppercase we should loverwase it
    # before it gets to the middle of the output word

    beq $s4, $0, no_lowercasing_output
        la $t0, word_converted   # we need 1st char in input
        lb $t1, ($t0)
        addi $t1, $t1, -32
        sb $t1, ($t0)

    no_lowercasing_output:

    # save return address to t0 so we can restore s3 register
    move $t0, $s0

    # restore stack
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    lw   $s3, 12($sp)
    lw   $s4, 16($sp)
    lw   $s5, 20($sp)
    addi $sp, $sp, 24
    jr   $t0       # return


find_word:
    # (a0: address to beggining of string)
    # -> v0: new address of the string

    # Register usage:
    # s0 - pointer to current char
    # s1 - pointer to last character in a parsed word
    # s2 - current character
    # s3 - our return address

    # Make this function stack neutral:
    addi $sp, $sp, -20
    sw   $s0, 0($sp)
    sw   $s1, 4($sp)
    sw   $s2, 8($sp)
    sw   $s3, 12($sp)
    sw   $s4, 16($sp)


    # move our arguments to stack so that they dont get lost when we call function
    move $s0, $a0
    move $s3, $ra

    # char current_word[MAX_WORD_LENGTH+1];
    la $s1, word_found

    # start our while loop:
    find_word_while_char:
        # load 1st letter
        lb $s2, ($s0)
        move $a0, $s2

        # end of sentence we encountered zero byte
        beq $s2, $0, find_word_exit_loop

        # v0 = is_valid_char(a0)
        jal is_word_character
        # if not is_valid_character(a0): check if its hyphen
        beq $v0, $0, find_word_handle_invalid_char

        find_word_handle_valid_char:
            # save char to the word buffer
            sb $s2, 0($s1)

            # move to the next char:
            addi $s0, $s0, 1
            addi $s1, $s1, 1
            j find_word_while_char

        find_word_handle_invalid_char:
            # we should check if its a hyphen:
            move $a0, $s2
            jal is_hyphen

            beq $v0, $0, find_word_exit_loop

            find_word_handle_hyphen: # we have to do look-ahead to check if the next character is valid:
                addi $t0, $s0, 1
                lb $a0, ($t0)
                jal is_word_character
                beq $v0, $0, find_word_exit_loop  # if next char is not valid it means end of word

                j find_word_handle_valid_char     # add hyphen to the word
            find_word_continue:
                addi $s0, $s0, 1
                j find_word_while_char


        li   $v0, 4
        la   $a0, word_found
        syscall

    find_word_exit_loop:

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
        jr   $t0       # return



process_input:  
    # this is a procedure rather then function that handles all of the input
    # processing.


    # I have modified the arguments of this function to make it more pure and not dependent on the global variables
    # for now lets skip the hiphens

    # Register usage:
    # s0 - pointer to current input character
    # s1 - pointer to current output character
    # s2 - current character
    # s3 - ?
    # s4 - ?

    # Make this function stack neutral:
    addi $sp, $sp, -20
    sw   $s0, 0($sp)
    sw   $s1, 4($sp)
    sw   $s2, 8($sp)
    sw   $s3, 12($sp)
    sw   $s4, 16($sp)


    la $s0, input
    la $s1, output


    # start our while loop:
    while_char:
        # load char to s2
        lb $s2, ($s0)
        move $a0, $s2

        # end of sentence we encountered zero byte
        beq $a0, $0, exit_loop

        # v0 = is_valid_char(a0)
        jal is_word_character

        # if not is_word_character(a0): return
        beq $v0, $0, handle_invalid_char

        handle_valid_char:       # if (is_valid_character(cur_char))
            # if we have found a valid char we use function find_word to find
            # the whole world
            move $a0, $s0
            jal find_word
            move $s0, $v0

            # apply the pig latin words to the word
            jal convert_word

            # add the new word to the output:
            la $t0, word_converted

            while_add_pig_word:
                lb $t1, 0($t0)
                beq $t1, $0, while_char  # exit on end of word

                sb $t1, 0($s1)      # out[output_index] = converted_word[i];
                addi $t0, $t0, 1    # output_index += 1;
                addi $s1, $s1, 1

                j while_add_pig_word


        handle_invalid_char:
            # save char to the word buffer
            sb $s2, 0($s1)

            # move to the next char:
            addi $s0, $s0, 1
            addi $s1, $s1, 1
            # increase number of accepted chars:
            j while_char

    exit_loop:
        # End the string
        sb $0, 0($s1)

        # restore stack
        lw   $s0, 0($sp)
        lw   $s1, 4($sp)
        lw   $s2, 8($sp)
        lw   $s3, 12($sp)
        lw   $s4, 16($sp)
        addi $sp, $sp, 20
        j print_output
              

is_vowel: # checks that a0 is a wowel like char.
    li $t0, 97                  # 'a'
    beq $a0, $t0, return_true
    li $t0, 101                 # 'e'
    beq $a0, $t0, return_true
    li $t0, 105                 # 'i'
    beq $a0, $t0, return_true
    li $t0, 111                 # 'o'
    beq $a0, $t0, return_true
    li $t0, 117                 # 'u'
    beq $a0, $t0, return_true
    li $t0, 65                  # 'A'
    beq $a0, $t0, return_true
    li $t0, 69                  # 'E'
    beq $a0, $t0, return_true
    li $t0, 73                  # 'I'
    beq $a0, $t0, return_true
    li $t0, 79                  # 'O'
    beq $a0, $t0, return_true
    li $t0, 85                  # 'U'
    beq $a0, $t0, return_true

    j return_false



is_uppercase: # returns true if its uppercase or hyphen
    li $t0, 45                   # hyphen
    beq $a0, $t0, return_true

    slti $t0, $a0, 65               # if a0 > A
    beq  $t0, $0,  over65_single    # goto over65

    j return_false              # else return false

    over65_single:
        slti $t0, $a0, 90               # if a0 > Z
        beq  $t0, $0,  return_false     # return false
        j return_true                   # else return true



is_capital_only: # a0: address of the string -> v0 true/false
    # Make this function stack neutral:
    addi $sp, $sp, -8
    sw   $s0, 0($sp)
    sw   $s1, 4($sp)

    # save the address of the word to s0:
    move $s0, $a0

    # save return address:
    move $s1, $ra
    li $v0, 1


    while_is_cap:
        lb $a0, ($s0)
        beq $a0, $0, is_capital_return  # end of word

        # v0 = is_uppercase(a0)
        jal is_uppercase

        # if not return
        beq $v0, $0, is_capital_return

        # otherwise
        addi $s0, $s0, 1
        j while_is_cap

    is_capital_return: # note that v0 already has the result of this function
        move $t0, $s1
        
        lw   $s0, 0($sp)
        lw   $s1, 4($sp)
        addi $sp, $sp, 8
        jr $t0




is_word_character: # is_word_character(char a0) -> 0/1 bool set to v0 if this is character
    slti $t0, $a0, 65           # if a0 > A
    beq  $t0, $0,  over65           # goto over65

    j return_false              # else return false

    over65:
        slti $t0, $a0, 91       # if a0 > Z
        beq  $t0, $0,  over90       # goto over65
        j return_true           # else return true

    over90:
        slti $t0, $a0, 97       # if a0 > a
        beq  $t0, $0,  over97       # jump to over97
        j return_false          # else return false

    over97:
        slti $t0, $a0, 123          # if a0 > a
        beq  $t0, $0,  return_false     # jump to over97
        j return_true           # else return false

is_hyphen: # return a0 == '-' 
    la $t0, hyphen
    lb $t0, ($t0)
    bne $a0, $t0, return_false
    j return_true


return_false:
    li $v0, 0
    jr $ra

return_true:    
    li $v0, 1
    jr $ra

end:      
    # call sys exit
    li   $v0, 10
    syscall
