// ==========================================================================
// PigLatin Converter
// ==========================================================================
// Convert all words in a sentence using PigLatin rules

// Inf2C-CS Coursework 1. Task B
// PROVIDED file, to be used to complete the task in C and as a model for writing MIPS code.

// Instructor: Boris Grot
// TA: Priyank Faldu
// 10 Oct 2017

//---------------------------------------------------------------------------
// C definitions for SPIM system calls
//---------------------------------------------------------------------------
#include <stdio.h>

void read_string(char* s, int size) { fgets(s, size, stdin); }

void print_char(char c)    { printf("%c", c); }
void print_int(int num)    { printf("%d", num); }
void print_string(const char* s) { printf("%s", s); }

#define false 0
#define true 1

// Maximum characters in an input sentence excluding terminating null character
#define MAX_SENTENCE_LENGTH 1000

// Maximum characters in a word excluding terminating null character
#define MAX_WORD_LENGTH 50

// Global variables
// +1 to store terminating null character
char input_sentence[MAX_SENTENCE_LENGTH+1];
char output_sentence[(MAX_SENTENCE_LENGTH*3)+1];

void read_input(const char* inp) {
    print_string("Enter input: ");
    read_string(input_sentence, MAX_SENTENCE_LENGTH+1);
}

void output(const char* out) {
    print_string(out);
    print_string("\n");
}

// Do not modify anything above


// returns true if an input character is a valid word character
// returns false if an input character is any punctuation mark (including hyphen)
int is_valid_character(char ch) {
    if ( ch >= 'a' && ch <= 'z' ) {
        return true;
    } else if ( ch >= 'A' && ch <= 'Z' ) {
        return true;
    } else {
        return false;
    }
}

// returns true only if an input character is hyphen
int is_hyphen(char ch) {
    if ( ch == '-' ) {
        return true;
    } else {
        return false;
    }
}

int is_vowel(char c){
   char owls[] = {'a', 'e', 'i', 'o', 'u', 'A', 'E', 'I', 'O', 'U'};

   for (int i = 0; i < sizeof(owls); i++) {
     if (owls[i] == c){
       return true;
     }
   }
   return false;
}

int is_capital_only(char* inp) {
    char ch;

    for (int i = 0; i < sizeof(inp); ++i) {
        ch = inp[i];
        if (ch == '\n' || ch == '\0'){
            break;
        }

        if (( ch >= 'A' && ch <= 'Z' ) || ch == '-') {
            continue;
        } else {
            return false;
        }
    }
    return true;
}


void convert_word(char* inp, char* word) {
    int capitalized_all =  is_capital_only(inp);
    int capitalize_first = ((!capitalized_all) && (inp[0] >= 'A' && inp[0] <= 'Z'));

    // cast 1st letter to lowercase:
    if (capitalize_first){
        inp[0] += 32;
    }

    // find a position of the 1st vowel
    int vowel_pos = 0;
    while (true) {
        char ch = inp[vowel_pos];
        if (is_vowel(ch)){
            break;
        }
        if (inp[vowel_pos] == '\0') {
            break;
        }
        vowel_pos += 1;
    }

    // add letters that were after vowel to the word:
    int new_word_pos = 0;
    int i = vowel_pos;
    while (1){
        char ch = inp[i];
        if (ch == '\0') {
            break;
        }
        word[new_word_pos] = inp[i];
        new_word_pos += 1;
        i += 1;
    }

    // add letters that were before vowel to the word:
    i = 0;
    while (i < vowel_pos){
        char ch = inp[i];
        if (ch == '\0') {
            break;
        }
        word[new_word_pos] = inp[i];
        new_word_pos += 1;
        i += 1;
    }

    // handle capitalization of the first letter:
    if (capitalize_first){
        word[0] -= 32;
    }


    // add -ay part.
    if (capitalized_all) {
        word[new_word_pos] = 'A';
        word[new_word_pos+1] = 'Y';
    } else {
      word[new_word_pos] = 'a';
      word[new_word_pos+1] = 'y';
    }

    // terminate the string
    word[new_word_pos+2] = '\0';
}


void process_input(char* inp, char* out) {
	// go through each individual character.
	// if this character is a valid word character
	// then we try to find a longest word possible.
	// and convert it to pig latin.

    // Indicates how many elements in "w" contains valid word characters
    int input_index = 0;
    int output_index = 0;

    while( 1 ) {
        // This loop runs until end of an input sentence is encountered or a valid word is extracted
        char cur_char = inp[input_index];

        if (is_valid_character(cur_char)){
            // Find a single consecutive word
            int word_index = 0;
            char current_word[MAX_WORD_LENGTH+1];

            int still_a_word = true;
            while (still_a_word == true) {
                cur_char = inp[input_index];

                if (is_valid_character(cur_char)){
                    current_word[word_index] = cur_char;
                }
                else {
                    // handle hyphen case
                    if (is_hyphen(cur_char) && is_valid_character(inp[input_index + 1])) {
                        current_word[word_index] = cur_char;
                    }
                    else {
                        still_a_word = false;
                        current_word[word_index] = '\0';
                        continue;
                    }
                }
                input_index += 1;
                word_index += 1;
            }

            // add the converted word to the output
            char converted_word[MAX_WORD_LENGTH * 3 + 1];
            convert_word(current_word, converted_word);
            for (int i = 0; i < sizeof(converted_word); ++i) {
                if (converted_word[i] == '\n' || converted_word[i] == '\0'){
                    break;
                }
                out[output_index] = converted_word[i];
                output_index += 1;
            }

        }
        else {
            if (cur_char == '\n' || cur_char == '\0'){
                break;
            }
            else {
                out[output_index] = cur_char;
                input_index += 1;
                output_index += 1;
            }
        }
    }
}

//
// Do not modify anything below


int main() {

    read_input(input_sentence);

    print_string("\noutput:\n");

    output_sentence[0] = '\0';
    process_input(input_sentence, output_sentence);

    output(output_sentence);

    return 0;
}

//---------------------------------------------------------------------------
// End of love
//---------------------------------------------------------------------------
