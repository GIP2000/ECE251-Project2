.data
.balign 4
scanf_input_file_msg: .asciz "Enter the input file path: \n"

.balign 4
scanf_output_file_msg: .asciz "Enter the output file path: \n"

.balign 4 
read_mode: .asciz "r"

.balign 4 
write_mode: .asciz "w+"

.balign 4 
file_read_pattern: .asciz "%d\n"

.balign 4
file_write_pattern: .asciz "%d\n"

.balign 4
input_file_name: .skip 50

.balign 4
output_file_name: .skip 50

.balign 4
scanpattern: .asciz " %[^\n]s"

.balign 4
return : .word 0

.balign 4
number: .skip 4

.balign 4 
array: .skip 404

.balign 4
flag_str: .asciz "Flag\n"

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
    bl scanf

    ldr r0,=scanf_output_file_msg
    bl printf 
    ldr r0,=scanpattern
    ldr r1,=output_file_name
    bl scanf

load_file: 
    ldr r0,=input_file_name
    ldr r1,=read_mode
    bl fopen
    cmp r0, #0x00
    beq exit
    mov r7,r0
    mov r6,#0 @ this will be the index of our array 
load_arr:
    mov r0,r7
    ldr r1,=file_read_pattern
    ldr r2,=number
    bl fscanf
    cmp r0,#1
    bne sort

    ldr r0,=number
    ldr r0,[r0]
    ldr r1,=array
    str r0, [r1,r6, LSL #2]
    add r6, r6, #1
    cmp r6, #100
    beq sort
    b load_arr

sort:
    mov r0, r7
    bl fclose
bubble_sort_top:
    mov r5,#0
    mov r7,#1
    mov r9,#0
    
bubble_sort_bot: 
    ldr r0,=array
    ldr r1,[r0,r5,LSL #2]
    ldr r0,=array
    ldr r2,[r0,r7,LSL #2]
    ldr r0,=array
    cmp r1,r2
    bgt swap
    b continue
swap:    
    str r2,[r0,r5, LSL #2]
    str r1,[r0,r7, LSL #2]
    mov r9, #1
continue:
    mov r5,r7
    add r7,r7,#1
    cmp r7,r6
    bge check_fin
    b bubble_sort_bot
check_fin:
    cmp r9,#1
    beq bubble_sort_top
setup_output:
    mov r5,#0

output: 
    ldr r0,=output_file_name
    ldr r1,=write_mode
    bl fopen
    cmp r0, #0x00
    beq exit
    mov r7,r0
    mov r5,#0
write_loop:
    ldr r10,=array
    mov r0,r7
    ldr r1,=file_write_pattern
    ldr r2,[r10,r5,LSL #2]
    bl fprintf
    add r5,r5,#1
    cmp r5,r6
    beq exit
    b write_loop

exit:
    ldr lr,=return
    ldr lr,[lr]
    bx lr


.global printf
.global scanf
.global fopen 
.global fclose
.global fscanf
.global fprintf 