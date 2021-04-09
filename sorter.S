.data
.balign 4
scanf_input_file_msg: .asciz "Enter the input file path: \n"

.balign 4
input_file_err_msg: .asciz "File name invalid. Program terminated. \n"

.balign 4
scanf_output_file_msg: .asciz "Enter the output file path: \n"

.balign 4 
read_mode: .asciz "r" // regular read mode

.balign 4 
write_mode: .asciz "w+" // use w+ to create the output file in case it doesn't exist

.balign 4 
file_pattern: .asciz "%d\n" // pattern that writes a number and newline

.balign 4
input_file_name: .skip 50

.balign 4
output_file_name: .skip 50

.balign 4
scanpattern: .asciz " %[^\n]s" // this scan pattern was used to get a string (s) and ignore a new line. This prevents spaces in the input from counting it as two input strings.

.balign 4
return : .word 0

.balign 4
number: .skip 4

.balign 4 
array: .skip 404

.text

.global main
main: 
    ldr r1,=return 
    str lr,[r1]

load_file_paths: 
    ldr r0,=scanf_input_file_msg
    bl printf 
    ldr r0,=scanpattern
    ldr r1,=input_file_name
    bl scanf // scan for the input file name

    ldr r0,=scanf_output_file_msg
    bl printf 
    ldr r0,=scanpattern
    ldr r1,=output_file_name
    bl scanf // scan for the output file name (if it doesn't exist create a new one)

load_file: 
    ldr r0,=input_file_name
    ldr r1,=read_mode
    bl fopen
    cmp r0, #0x00
    beq error // exit if at end of file
    mov r7,r0 // store file pointer in r7
    mov r6,#0 // this will be the index of our array (and later used as the length)

load_arr:
    mov r0,r7
    ldr r1,=file_pattern
    ldr r2,=number
    bl fscanf // scan file
    cmp r0,#1 // if at end of file, move onto sorting
    bne sort

    ldr r0,=number
    ldr r0,[r0]
    ldr r1,=array
    str r0, [r1,r6, LSL #2] // using a logical shift to move onto the next address in the array
    add r6, r6, #1
    cmp r6, #100 // if at maximum capacity (100 bytes), move onto sorting 
    beq sort
    b load_arr

sort:
    mov r0, r7
    bl fclose
bubble_sort_top:
    mov r5,#0 // set index for first number
    mov r7,#1 // set index for next number for comparison
    mov r9,#0 // r9 is used for flagging if any numbers were swapped
    
bubble_sort_bot: 
    ldr r0,=array
    ldr r1,[r0,r5,LSL #2] // load first value into r1
    ldr r0,=array
    ldr r2,[r0,r7,LSL #2] // load second value into r2
    ldr r0,=array
    cmp r1,r2
    bgt swap // if r1 > r2, swap them
    b continue
swap:    
    str r2,[r0,r5, LSL #2] // use logical shift to store the value in the original position
    str r1,[r0,r7, LSL #2] // use shift to store the value in the original position + 1
    mov r9, #1 // flag that a swap was made
continue:
    mov r5,r7
    add r7,r7,#1 // increment indices
    cmp r7,r6 // if at end of the array, check if it is done
    bge check_fin
    b bubble_sort_bot
check_fin:
    cmp r9,#1 // the sort is done if the flag was never raised
    beq bubble_sort_top // if a swap was made, start the sort from the top

output: 
    ldr r0,=output_file_name
    ldr r1,=write_mode
    bl fopen
    cmp r0, #0x00
    beq exit
    mov r7,r0
    mov r5,#0 // reset r5 to be used as the index for printing to the output file

write_loop:
    ldr r10,=array
    mov r0,r7
    ldr r1,=file_pattern
    ldr r2,[r10,r5,LSL #2] // load next item in the array
    bl fprintf
    add r5,r5,#1
    cmp r5,r6
    beq exit // if not and end of the array, loop again and continue writing to the output file
    b write_loop

exit:
    ldr lr,=return
    ldr lr,[lr]
    bx lr

error:
    ldr r0, =input_file_err_msg
    bl printf
    b exit

.global printf
.global scanf
.global fopen 
.global fclose
.global fscanf
.global fprintf 