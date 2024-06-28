; ----- SMAKE -----
    ; i hope this works please
    ; smake is assembled with NASM, runs on DOS

section .bss
    snake_x resb 255
    snake_y resb 255
    snake_length resb 1
    fruit_x resb 1
    fruit_y resb 1

section .data
    screen_width db 80
    screen_height db 25
    snake_char db 'O'
    fruit_char db '*'

section .text
    global _start

_start:
    mov byte [snake_length], 3
    mov byte [snake_x], 40
    mov byte [snake_y], 12
    call generate_fruit

game_loop:
    call clear_screen
    call draw_snake
    call draw_fruit
    call get_input
    call update_snake_position
    call check_collisions
    jz collision_detected
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
    mov si, [snake_length]
    mov di, 0
    mov ah, 2
    mov bh, 0
draw_snake_loop:
    mov dl, [snake_x + di]
    mov dh, [snake_y + di]
    int 10h
    mov ah, 0x0E
    mov al, snake_char
    int 10h
    dec si
    inc di
    jnz draw_snake_loop
    ret

draw_fruit:
    mov ah, 2
    mov bh, 0
    mov dl, [fruit_x]
    mov dh, [fruit_y]
    int 10h
    mov ah, 0x0E
    mov al, fruit_char
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
    mov si, [snake_length]
    dec si
    mov al, [snake_y + si]
    dec al
    mov [snake_y + si], al
    call move_snake_body
    ret

move_down:
    mov si, [snake_length]
    dec si
    mov al, [snake_y + si]
    inc al
    mov [snake_y + si], al
    call move_snake_body
    ret

move_left:
    mov si, [snake_length]
    dec si
    mov al, [snake_x + si]
    dec al
    mov [snake_x + si], al
    call move_snake_body
    ret

move_right:
    mov si, [snake_length]
    dec si
    mov al, [snake_x + si]
    inc al
    mov [snake_x + si], al
    call move_snake_body
    ret

move_snake_body:
    mov si, [snake_length]
    dec si
move_snake_body_loop:
    mov al, [snake_x + si]
    mov [snake_x + si + 1], al
    mov al, [snake_y + si]
    mov [snake_y + si + 1], al
    dec si
    jnz move_snake_body_loop
    ret

check_eat_fruit:
    mov si, [snake_length]
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
    mov al, [snake_x]
    cmp al, 0
    jl collision_detected
    cmp al, [screen_width]
    jg collision_detected
    mov al, [snake_y]
    cmp al, 0
    jl collision_detected
    cmp al, [screen_height]
    jg collision_detected
    mov si, 1
collision_loop:
    cmp si, [snake_length]
    jge no_self_collision
    mov al, [snake_x]
    cmp al, [snake_x + si]
    jne next_check
    mov al, [snake_y]
    cmp al, [snake_y + si]
    je collision_detected
next_check:
    inc si
    jmp collision_loop

no_self_collision:
    xor ax, ax
    ret

delay:
    mov cx, 0FFFFh
delay_loop:
    loop delay_loop
    ret

game_over:
    mov ah, 0x09
    mov dx, game_over_message
    int 21h
    ret

game_over_message db "Game Over!", 0Dh, 0Ah, "$"

exit:
    mov ah, 0x4C
    int 21h
    ret

section .data
    key db 0
