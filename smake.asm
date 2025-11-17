; ----- SMAKE -----
    ; i hope this works please
    ; smake is assembled with NASM, runs on DOS

org 100h                ; DOS .COM program starts at 100h

section .data
    screen_width db 80
    screen_height db 25
    snake_char db 'O'
    fruit_char db '*'
    key db 0
    game_over_message db "Game Over! Press any key to exit...", 0Dh, 0Ah, "$"
    
section .bss
    snake_x resb 255
    snake_y resb 255
    snake_length resb 1
    fruit_x resb 1
    fruit_y resb 1

section .text
    global _start

_start:
    ; Initialize snake
    mov byte [snake_length], 3
    mov byte [snake_x], 40
    mov byte [snake_y], 12
    mov byte [snake_x + 1], 39
    mov byte [snake_y + 1], 12
    mov byte [snake_x + 2], 38
    mov byte [snake_y + 2], 12
    mov byte [key], 'd'  ; Start moving right
    call generate_fruit

game_loop:
    call clear_screen
    call draw_snake
    call draw_fruit
    call get_input
    call update_snake_position
    call check_collisions
    cmp ax, 0
    jne collision_detected
    call check_eat_fruit
    call delay
    jmp game_loop

collision_detected:
    call game_over
    jmp exit

clear_screen:
    mov ah, 0x06
    mov al, 0
    mov bh, 0x07
    mov cx, 0
    mov dx, 184Fh
    int 10h
    ret

draw_snake:
    xor di, di
    movzx si, byte [snake_length]
draw_snake_loop:
    mov ah, 2
    mov bh, 0
    mov dl, [snake_x + di]
    mov dh, [snake_y + di]
    int 10h
    mov ah, 0x0E
    mov al, [snake_char]
    int 10h
    inc di
    dec si
    jnz draw_snake_loop
    ret

draw_fruit:
    mov ah, 2
    mov bh, 0
    mov dl, [fruit_x]
    mov dh, [fruit_y]
    int 10h
    mov ah, 0x0E
    mov al, [fruit_char]
    int 10h
    ret

generate_fruit:
    mov ah, 0
    int 1Ah
    xor ah, ah
    mov cx, ax
    mov ax, cx
    xor dx, dx
    div byte [screen_width]
    mov [fruit_x], dl
    mov ax, cx
    xor dx, dx
    div byte [screen_height]
    mov [fruit_y], dl
    ret

get_input:
    mov ah, 0x01
    int 16h
    jz no_key
    mov ah, 0
    int 16h
    mov [key], al
no_key:
    ret

update_snake_position:
    mov al, [key]
    cmp al, 'w'
    je move_up
    cmp al, 's'
    je move_down
    cmp al, 'a'
    je move_left
    cmp al, 'd'
    je move_right
    ret

move_up:
    call move_snake_body
    mov al, [snake_y]
    dec al
    mov [snake_y], al
    ret

move_down:
    call move_snake_body
    mov al, [snake_y]
    inc al
    mov [snake_y], al
    ret

move_left:
    call move_snake_body
    mov al, [snake_x]
    dec al
    mov [snake_x], al
    ret

move_right:
    call move_snake_body
    mov al, [snake_x]
    inc al
    mov [snake_x], al
    ret

move_snake_body:
    movzx si, byte [snake_length]
    dec si
move_snake_body_loop:
    cmp si, 0
    je move_snake_body_done
    dec si
    mov al, [snake_x + si]
    mov [snake_x + si + 1], al
    mov al, [snake_y + si]
    mov [snake_y + si + 1], al
    jmp move_snake_body_loop
move_snake_body_done:
    ret

check_eat_fruit:
    mov al, [snake_x]
    cmp al, [fruit_x]
    jne not_eating_fruit
    mov al, [snake_y]
    cmp al, [fruit_y]
    jne not_eating_fruit
    inc byte [snake_length]
    call generate_fruit
not_eating_fruit:
    ret

check_collisions:
    ; Check wall collisions
    mov al, [snake_x]
    cmp al, 0
    jle collision_detected_jmp
    cmp al, [screen_width]
    jge collision_detected_jmp
    mov al, [snake_y]
    cmp al, 0
    jle collision_detected_jmp
    cmp al, [screen_height]
    jge collision_detected_jmp
    
    ; Check self collision
    xor si, si
    inc si
collision_loop:
    movzx cx, byte [snake_length]
    cmp si, cx
    jge no_self_collision
    mov al, [snake_x]
    cmp al, [snake_x + si]
    jne next_check
    mov al, [snake_y]
    cmp al, [snake_y + si]
    je collision_detected_jmp
next_check:
    inc si
    jmp collision_loop

collision_detected_jmp:
    mov ax, 1  ; Set flag for collision
    ret

no_self_collision:
    xor ax, ax  ; Clear flag - no collision
    ret

delay:
    mov cx, 0FFFFh
delay_loop:
    loop delay_loop
    ret

game_over:
    call clear_screen
    mov ah, 0x09
    mov dx, game_over_message
    int 21h
    ; Wait for keypress
    mov ah, 0
    int 16h
    ret

exit:
    mov ah, 0x4C
    xor al, al
    int 21h
