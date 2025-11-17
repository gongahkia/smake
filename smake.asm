; ----- SMAKE -----
; Snake game for DOS - assembled with NASM

org 100h                ; DOS .COM program starts at 100h

jmp start               ; Jump over data section

; ----- DATA SECTION -----
screen_width db 80
screen_height db 25
snake_char db 219       ; Full block character
fruit_char db 4         ; Diamond character
direction db 'd'
snake_length db 3
snake_x times 255 db 0
snake_y times 255 db 0
fruit_x db 20
fruit_y db 10
score_msg db "SNAKE - WASD to move | Score: ", 0
game_over_msg db "GAME OVER! Press any key...", 0

; ----- CODE SECTION -----
start:
    ; Set video mode to text 80x25
    mov ax, 0x0003
    int 10h
    
    ; Hide cursor
    mov ah, 0x01
    mov ch, 0x20
    int 10h
    
    ; Initialize snake position
    mov byte [snake_x], 40
    mov byte [snake_y], 12
    mov byte [snake_x + 1], 39
    mov byte [snake_y + 1], 12
    mov byte [snake_x + 2], 38
    mov byte [snake_y + 2], 12
    
    call generate_fruit

game_loop:
    call draw_screen
    call get_input
    call update_snake
    call check_collisions
    cmp ax, 0
    jne game_over
    call check_fruit
    call delay
    jmp game_loop

game_over:
    ; Clear screen
    mov ax, 0x0003
    int 10h
    
    ; Set cursor position
    mov ah, 0x02
    mov bh, 0
    mov dx, 0x0C20      ; Row 12, col 32
    int 10h
    
    ; Print game over message using simpler method
    mov si, game_over_msg
print_game_over:
    lodsb
    or al, al
    jz wait_for_key
    mov ah, 0x0E
    mov bl, 0x0C        ; Red text
    int 10h
    jmp print_game_over
    
wait_for_key:
    ; Clear keyboard buffer first
    mov ah, 0x01
    int 16h
    jz buffer_clear
    mov ah, 0x00
    int 16h
    jmp wait_for_key
    
buffer_clear:
    ; Wait for keypress
    mov ah, 0x00
    int 16h
    
    ; Exit to DOS
    mov ah, 0x4C
    xor al, al
    int 21h

draw_screen:
    ; Set cursor to top left
    mov ah, 0x02
    mov bh, 0
    mov dx, 0
    int 10h
    
    ; Draw title
    mov si, score_msg
    call print_string
    
    ; Draw snake
    xor di, di
    movzx cx, byte [snake_length]
draw_snake_loop:
    mov ah, 0x02
    mov bh, 0
    mov dl, [snake_x + di]
    mov dh, [snake_y + di]
    int 10h
    
    mov ah, 0x09
    mov al, [snake_char]
    mov bh, 0
    mov bl, 0x0A        ; Green
    mov cx, 1
    int 10h
    
    inc di
    loop draw_snake_loop
    
    ; Draw fruit
    mov ah, 0x02
    mov bh, 0
    mov dl, [fruit_x]
    mov dh, [fruit_y]
    int 10h
    
    mov ah, 0x09
    mov al, [fruit_char]
    mov bh, 0
    mov bl, 0x0C        ; Red
    mov cx, 1
    int 10h
    
    ret

print_string:
    lodsb
    or al, al
    jz print_done
    mov ah, 0x0E
    int 10h
    jmp print_string
print_done:
    ret

get_input:
    mov ah, 0x01
    int 16h
    jz no_input
    
    mov ah, 0
    int 16h
    
    ; Check for WASD keys
    cmp al, 'w'
    je set_up
    cmp al, 's'
    je set_down
    cmp al, 'a'
    je set_left
    cmp al, 'd'
    je set_right
    jmp no_input
    
set_up:
    cmp byte [direction], 's'
    je no_input
    mov byte [direction], 'w'
    jmp no_input
set_down:
    cmp byte [direction], 'w'
    je no_input
    mov byte [direction], 's'
    jmp no_input
set_left:
    cmp byte [direction], 'd'
    je no_input
    mov byte [direction], 'a'
    jmp no_input
set_right:
    cmp byte [direction], 'a'
    je no_input
    mov byte [direction], 'd'
    
no_input:
    ret

update_snake:
    ; First, shift all body segments backwards (from tail to neck)
    movzx cx, byte [snake_length]
    dec cx                  ; Don't move the head yet
    jle move_head           ; If length is 1 or less, just move head
    
    ; Start from the tail (last segment) and move each segment to previous position
    mov si, cx              ; si = last segment index (length - 1)
shift_body:
    cmp si, 1
    jl move_head            ; Stop when si < 1
    
    mov di, si
    dec di                  ; di = previous segment index
    
    mov al, [snake_x + di]
    mov [snake_x + si], al
    mov al, [snake_y + di]
    mov [snake_y + si], al
    
    dec si
    jmp shift_body
    
move_head:
    ; Now move the head based on direction
    mov al, [direction]
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
    dec byte [snake_y]
    ; Wrap around vertically
    cmp byte [snake_y], 0
    jg up_done
    mov byte [snake_y], 24
up_done:
    ret
    
move_down:
    inc byte [snake_y]
    ; Wrap around vertically
    cmp byte [snake_y], 25
    jl down_done
    mov byte [snake_y], 1
down_done:
    ret
    
move_left:
    dec byte [snake_x]
    ; Wrap around horizontally
    cmp byte [snake_x], 0
    jge left_done
    mov byte [snake_x], 79
left_done:
    ret
    
move_right:
    inc byte [snake_x]
    ; Wrap around horizontally
    cmp byte [snake_x], 80
    jl right_done
    mov byte [snake_x], 0
right_done:
    ret

check_collisions:
    xor ax, ax
    
    ; Skip wall collision check - wrapping is enabled
    
    ; Check self collision only
    mov si, 1
self_collision_loop:
    movzx cx, byte [snake_length]
    cmp si, cx
    jge no_collision
    
    mov al, [snake_x]
    cmp al, [snake_x + si]
    jne next_segment
    mov al, [snake_y]
    cmp al, [snake_y + si]
    je collision
    
next_segment:
    inc si
    jmp self_collision_loop
    
collision:
    mov ax, 1
    ret
    
no_collision:
    xor ax, ax
    ret

check_fruit:
    mov al, [snake_x]
    cmp al, [fruit_x]
    jne no_fruit
    mov al, [snake_y]
    cmp al, [fruit_y]
    jne no_fruit
    
    ; Ate fruit - grow snake
    inc byte [snake_length]
    call generate_fruit
    
no_fruit:
    ret

generate_fruit:
    ; Get timer for random number
    mov ah, 0
    int 1Ah
    
    ; Use CX for X coordinate
    mov ax, cx
    xor dx, dx
    mov bx, 78
    div bx
    add dl, 1
    mov [fruit_x], dl
    
    ; Use DX for Y coordinate
    mov ah, 0
    int 1Ah
    mov ax, dx
    xor dx, dx
    mov bx, 22
    div bx
    add dl, 2
    mov [fruit_y], dl
    ret

delay:
    mov cx, 1
delay_outer:
    push cx
    mov cx, 0x8000
delay_inner:
    nop
    loop delay_inner
    pop cx
    loop delay_outer
    ret
