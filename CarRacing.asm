org 100h


start:
    mov ax, 0x0003
    int 0x10
    
    mov ah, 0x01
    mov ch, 0x20
    int 0x10
    
    mov ax, 0xB800
    mov es, ax
    
    call intro_screen
    call init_music

    
    xor ah, ah
    int 0x16
    
    call loading_screen
    
    xor di, di
    mov cx, 2000
    mov ax, 0x2220
    rep stosw
    
    mov word [tree1_row], 2
    mov word [tree2_row], 10
    mov word [tree3_row], 18
    mov word [tree4_row], 5
    mov word [tree5_row], 15
    
    call draw_grass_areas
    call draw_road
    call draw_scenery
    call draw_trees
    call draw_car
    call draw_score
    
    mov ah, 0x00
    int 0x1A
    mov [random_seed], dx
    
    call setup_timer_isr

main_loop:
    cmp byte [time_up], 1
    je game_over_screen
    
    call scroll_road
    call scroll_trees
    
    call spawn_objects
    
    call check_collisions
    cmp byte [game_over], 1
    je game_over_screen
    
    call draw_car
    call draw_score
    call draw_timer
    
    mov cx, 7
.delay_outer:
    push cx
    mov cx, 0xFFFF
.delay_inner:
    loop .delay_inner
    pop cx
    loop .delay_outer
    
    mov ah, 0x01
    int 0x16
    jz main_loop
    
    xor ah, ah
    int 0x16
    
    cmp ah, 0x4B
    je move_left
    cmp ah, 0x4D
    je move_right
    cmp al, 27
    je exit_game
    jmp main_loop

move_left:
    call erase_car
    mov ax, [car_col]
    cmp ax, 22
    jle main_loop
    sub ax, 17
    mov [car_col], ax
    jmp main_loop

move_right:
    call erase_car
    mov ax, [car_col]
    cmp ax, 55
    jge main_loop
    add ax, 17
    mov [car_col], ax
    jmp main_loop

game_over_screen:
    call restore_timer_isr
    call stop_music
    
    xor di, di
    mov cx, 2000
    mov ax, 0x5D20
    rep stosw
    
    mov di, (5*80 + 35)*2
    mov si, game_over_text
    mov cx, 13
    mov ax, 0x8E20
.print_go:
    lodsb
    stosw
    loop .print_go
    
    mov di, (12*80 + 35)*2
    mov si, score_text
    mov cx, 8
    mov ax, 0x0F20
.print_score:
    lodsb
    stosw
    loop .print_score
    
    mov ax, [score]
    call print_number
    
    mov di, (14*80 + 33)*2
    mov si, play_again_msg
    mov cx, 17
    mov ax, 0xD020
.print_playagain:
    lodsb
    stosw
    loop .print_playagain

.wait_choice:
    xor ah, ah
    int 0x16
    cmp al, 'y'
    je restart_game
    cmp al, 'Y'
    je restart_game
    cmp al, 'n'
    je exit_game
    cmp al, 'N'
    je exit_game
    jmp .wait_choice

restart_game:
    mov word [score], 0
    mov byte [game_over], 0
    mov word [scroll_counter], 0
    mov byte [time_up], 0
    mov word [timer_ticks], 0
    mov word [seconds_left], 30
    mov word [tree1_row], 2
    mov word [tree2_row], 10
    mov word [tree3_row], 18
    mov word [tree4_row], 5
    mov word [tree5_row], 15
    mov word [car_col], 35
    mov byte [timer_color], 0x0A
    mov word [spawn_cooldown], 0
    mov word [bonus_cooldown], 0
    jmp start

exit_game:
    call stop_music
    
    call restore_timer_isr
    mov ax, 0x4C00
    int 0x21

intro_screen:
    xor di, di
    mov cx, 2000
    mov ax, 0x0520
    rep stosw
    
    mov di, (2*80)*2
    mov cx, 80
    mov ax, 0x0EDB
.top_border:
    stosw
    loop .top_border
    
    mov di, (22*80)*2
    mov cx, 80
    mov ax, 0x0EDB
.bottom_border:
    stosw
    loop .bottom_border
    
    mov di, (5*80 + 30)*2
    mov si, title_line1
    mov cx, 17
    mov ah, 0x0E
.print_title:
    lodsb
    stosw
    loop .print_title
    
    mov di, (6*80 + 25)*2
    mov cx, 30
    mov ax, 0x0CDC
.subtitle_line:
    stosw
    loop .subtitle_line
    
    mov di, (8*80 + 28)*2
    mov si, subtitle_text
    mov cx, 22
    mov ah, 0x0B
.print_subtitle:
    lodsb
    stosw
    loop .print_subtitle
    
    mov di, (10*80 + 20)*2
    mov ax, 0x0FDB
    stosw
    mov cx, 38
    mov ax, 0x0FDF
.dev_box_top:
    stosw
    loop .dev_box_top
    mov ax, 0x0FDB
    stosw
    
    mov di, (11*80 + 20)*2
    mov ax, 0x0FDB
    stosw
    mov di, (11*80 + 33)*2
    mov si, dev1_name
    mov cx, 13
    mov ah, 0x0F
.print_dev1:
    lodsb
    stosw
    loop .print_dev1
    mov di, (11*80 + 59)*2
    mov ax, 0x0FDB
    stosw
    
    mov di, (12*80 + 20)*2
    mov ax, 0x0FDB
    stosw
    mov di, (12*80 + 32)*2
    mov si, dev1_roll
    mov cx, 17
    mov ah, 0x0A
.print_roll1:
    lodsb
    stosw
    loop .print_roll1
    mov di, (12*80 + 59)*2
    mov ax, 0x0FDB
    stosw
    
    mov di, (13*80 + 20)*2
    mov ax, 0x0FDB
    stosw
    mov cx, 38
    mov ax, 0x0FC4
.separator:
    stosw
    loop .separator
    mov ax, 0x0FDB
    stosw
    
    mov di, (14*80 + 20)*2
    mov ax, 0x0FDB
    stosw
    mov di, (14*80 + 33)*2
    mov si, dev2_name
    mov cx, 15
    mov ah, 0x0F
.print_dev2:
    lodsb
    stosw
    loop .print_dev2
    mov di, (14*80 + 59)*2
    mov ax, 0x0FDB
    stosw
    
    mov di, (15*80 + 20)*2
    mov ax, 0x0FDB
    stosw
    mov di, (15*80 + 32)*2
    mov si, dev2_roll
    mov cx, 17
    mov ah, 0x0A
.print_roll2:
    lodsb
    stosw
    loop .print_roll2
    mov di, (15*80 + 59)*2
    mov ax, 0x0FDB
    stosw
    
    mov di, (16*80 + 20)*2
    mov ax, 0x0FDB
    stosw
    mov cx, 38
    mov ax, 0x0FDC
.dev_box_bottom:
    stosw
    loop .dev_box_bottom
    mov ax, 0x0FDB
    stosw
    
    mov di, (18*80 + 30)*2
    mov si, semester_text
    mov cx, 19
    mov ah, 0x0D
.print_semester:
    lodsb
    stosw
    loop .print_semester
    
    mov di, (20*80 + 27)*2
    mov si, press_any_key
    mov cx, 27
    mov ah, 0x8E
.print_instruction:
    lodsb
    stosw
    loop .print_instruction
    
    ret

loading_screen:
    xor di, di
    mov cx, 2000
    mov ax, 0x0020
    rep stosw
    
    mov di, (8*80 + 15)*2
    mov ax, 0x0FDB
    stosw
    mov cx, 48
    mov ax, 0x0FDF
.box_top:
    stosw
    loop .box_top
    mov ax, 0x0FDB
    stosw
    
    mov di, (9*80 + 15)*2
    mov ax, 0x0FDB
    stosw
    mov di, (9*80 + 33)*2
    mov si, loading_text
    mov cx, 14
    mov ah, 0x0E
.print_loading:
    lodsb
    stosw
    loop .print_loading
    mov di, (9*80 + 64)*2
    mov ax, 0x0FDB
    stosw
    
    mov di, (11*80 + 15)*2
    mov ax, 0x0FDB
    stosw
    mov di, (11*80 + 17)*2
    mov cx, 46
    mov ax, 0x08B0
.progress_bg:
    stosw
    loop .progress_bg
    mov di, (11*80 + 64)*2
    mov ax, 0x0FDB
    stosw
    
    mov di, (13*80 + 15)*2
    mov ax, 0x0FDB
    stosw
    mov di, (13*80 + 64)*2
    mov ax, 0x0FDB
    stosw
    
    mov di, (14*80 + 15)*2
    mov ax, 0x0FDB
    stosw
    mov cx, 48
    mov ax, 0x0FDC
.box_bottom:
    stosw
    loop .box_bottom
    mov ax, 0x0FDB
    stosw
    
    mov word [load_progress], 0
    
.loading_loop:
    mov ax, [load_progress]
    mov bx, 46
    mul bx
    mov bx, 100
    div bx
    mov cx, ax
    
    mov di, (11*80 + 17)*2
    mov ax, 0x0ADB
    cmp cx, 0
    je .draw_percentage
.fill_bar:
    stosw
    loop .fill_bar
    
.draw_percentage:
    mov di, (11*80 + 67)*2
    mov ax, [load_progress]
    push di
    call print_load_percent
    
    mov ax, [load_progress]
    cmp ax, 20
    jl .status1
    cmp ax, 40
    jl .status2
    cmp ax, 60
    jl .status3
    cmp ax, 80
    jl .status4
    jmp .status5
    
.status1:
    mov si, status_msg1
    mov cx, 22
    jmp .print_status
.status2:
    mov si, status_msg2
    mov cx, 19
    jmp .print_status
.status3:
    mov si, status_msg3
    mov cx, 17
    jmp .print_status
.status4:
    mov si, status_msg4
    mov cx, 21
    jmp .print_status
.status5:
    mov si, status_msg5
    mov cx, 17
    
.print_status:
    mov di, (13*80 + 17)*2
    push cx
    push si
    mov cx, 46
    mov ax, 0x0020
.clear_status:
    stosw
    loop .clear_status
    pop si
    pop cx
    
    mov di, (13*80 + 17)*2
    mov ah, 0x0B
.print_stat:
    lodsb
    stosw
    loop .print_stat
    
    push cx
    mov cx, 5
.delay_outer:
    push cx
    mov cx, 0xFFFF
.delay_inner:
    loop .delay_inner
    pop cx
    loop .delay_outer
    pop cx
    
    add word [load_progress], 2
    cmp word [load_progress], 100
    jle .loading_loop
    
    mov cx, 10
.final_delay_outer:
    push cx
    mov cx, 0xFFFF
.final_delay_inner:
    loop .final_delay_inner
    pop cx
    loop .final_delay_outer
    
    ret

print_load_percent:
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push di
    
    mov di, [bp + 2]
    mov ax, [load_progress]
    
    xor cx, cx
    mov bx, 10
.divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne .divide
    
.print_digit:
    pop dx
    mov al, dl
    add al, '0'
    mov ah, 0x0F
    stosw
    loop .print_digit
    
    mov ax, 0x0F25
    stosw
    
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret 2
    
setup_timer_isr:
    push ax
    push bx
    push dx
    push es
    
    mov ax, 0x3508
    int 0x21
    mov [old_timer_offset], bx
    mov [old_timer_segment], es
    
    push ds
    mov ax, cs
    mov ds, ax
    mov dx, timer_isr
    mov ax, 0x2508
    int 0x21
    pop ds
    
    mov word [timer_ticks], 0
    mov word [seconds_left], 30
    mov byte [time_up], 0
    
    pop es
    pop dx
    pop bx
    pop ax
    ret

restore_timer_isr:
    push ax
    push dx
    push ds
    
    mov dx, [old_timer_offset]
    mov ax, [old_timer_segment]
    mov ds, ax
    mov ax, 0x2508
    int 0x21
    
    pop ds
    pop dx
    pop ax
    ret

timer_isr:
    push ax
    push bx
    push ds
    
    mov ax, cs
    mov ds, ax
    
    inc word [timer_ticks]
    
    call update_music
    
    cmp word [timer_ticks], 18
    jl .done
    
    mov word [timer_ticks], 0
    
    cmp word [seconds_left], 0
    je .time_up
    dec word [seconds_left]
    jmp .done
    
.time_up:
    mov byte [time_up], 1
    
.done:
    pop ds
    pop bx
    pop ax
    
    jmp far [cs:old_timer_offset]

draw_timer:
    mov di, (24*80 + 2)*2
    mov cx, 12
    mov ax, 0x0020
.clear:
    stosw
    loop .clear
    
    mov di, (24*80 + 2)*2
    mov si, timer_label
    mov cx, 6
    mov ah, 0x0F
.print_label:
    lodsb
    stosw
    loop .print_label
    
    mov ax, [seconds_left]
    
    cmp ax, 10
    jg .normal_color
    mov byte [timer_color], 0x0C
    jmp .print_time
.normal_color:
    mov byte [timer_color], 0x0A
    
.print_time:
    call print_timer_number
    ret

print_timer_number:
    push bx
    push cx
    push dx
    
    xor cx, cx
    mov bx, 10
.divide_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne .divide_loop
    
.print_loop:
    pop dx
    mov al, dl
    add al, '0'
    mov ah, [timer_color]
    stosw
    loop .print_loop
    
    mov ax, 0x0F73
    stosw
    
    pop dx
    pop cx
    pop bx
    ret

draw_grass_areas:
    xor si, si
.left_row:
    xor bx, bx
.left_col:
    mov ax, si
    mov dx, 80
    mul dx
    add ax, bx
    shl ax, 1
    mov di, ax
    mov ax, 0x2220
    stosw
.next_left:
    inc bx
    cmp bx, 15
    jl .left_col
    inc si
    cmp si, 25
    jl .left_row
    
    xor si, si
.right_row:
    mov bx, 65
.right_col:
    mov ax, si
    mov dx, 80
    mul dx
    add ax, bx
    shl ax, 1
    mov di, ax
    mov ax, 0x2220
    stosw
.next_right:
    inc bx
    cmp bx, 80
    jl .right_col
    inc si
    cmp si, 25
    jl .right_row
    ret

draw_trees:
    mov ax, [tree1_row]
    mov bx, 80
    mul bx
    add ax, 5
    shl ax, 1
    mov di, ax
    push di
    call tree_base
    
    mov ax, [tree1_row]
    sub ax, 3
    mov bx, 80
    mul bx
    add ax, 3
    shl ax, 1
    mov di, ax
    push 1
    push di
    push 5
    call Print_Bushes
    
    mov ax, [tree2_row]
    mov bx, 80
    mul bx
    add ax, 10
    shl ax, 1
    mov di, ax
    push di
    call tree_base
    
    mov ax, [tree2_row]
    sub ax, 3
    mov bx, 80
    mul bx
    add ax, 8
    shl ax, 1
    mov di, ax
    push 1
    push di
    push 5
    call Print_Bushes
    
    mov ax, [tree3_row]
    mov bx, 80
    mul bx
    add ax, 3
    shl ax, 1
    mov di, ax
    push di
    call tree_base
    
    mov ax, [tree3_row]
    sub ax, 3
    mov bx, 80
    mul bx
    add ax, 1
    shl ax, 1
    mov di, ax
    push 1
    push di
    push 5
    call Print_Bushes
    
    mov ax, [tree4_row]
    mov bx, 80
    mul bx
    add ax, 70
    shl ax, 1
    mov di, ax
    push di
    call tree_base
    
    mov ax, [tree4_row]
    sub ax, 3
    mov bx, 80
    mul bx
    add ax, 68
    shl ax, 1
    mov di, ax
    push 1
    push di
    push 5
    call Print_Bushes
    
    mov ax, [tree5_row]
    mov bx, 80
    mul bx
    add ax, 75
    shl ax, 1
    mov di, ax
    push di
    call tree_base
    
    mov ax, [tree5_row]
    sub ax, 3
    mov bx, 80
    mul bx
    add ax, 73
    shl ax, 1
    mov di, ax
    push 1
    push di
    push 5
    call Print_Bushes
    
    ret

scroll_trees:
    call erase_all_trees
    
    inc word [tree1_row]
    inc word [tree2_row]
    inc word [tree3_row]
    inc word [tree4_row]
    inc word [tree5_row]
    
    cmp word [tree1_row], 25
    jl .check_tree2
    mov word [tree1_row], 0
.check_tree2:
    cmp word [tree2_row], 25
    jl .check_tree3
    mov word [tree2_row], 0
.check_tree3:
    cmp word [tree3_row], 25
    jl .check_tree4
    mov word [tree3_row], 0
.check_tree4:
    cmp word [tree4_row], 25
    jl .check_tree5
    mov word [tree4_row], 0
.check_tree5:
    cmp word [tree5_row], 25
    jl .done
    mov word [tree5_row], 0
.done:
    call draw_trees
    ret

erase_all_trees:
    xor si, si
.left_row:
    xor bx, bx
.left_col:
    mov ax, si
    mov dx, 80
    mul dx
    add ax, bx
    shl ax, 1
    mov di, ax
    mov ax, 0x2220
    stosw
    inc bx
    cmp bx, 15
    jl .left_col
    inc si
    cmp si, 25
    jl .left_row
    
    xor si, si
.right_row:
    mov bx, 65
.right_col:
    mov ax, si
    mov dx, 80
    mul dx
    add ax, bx
    shl ax, 1
    mov di, ax
    mov ax, 0x2220
    stosw
    inc bx
    cmp bx, 80
    jl .right_col
    inc si
    cmp si, 25
    jl .right_row
    ret
	
draw_road:
    xor si, si
.row:
    mov bx, 15          
.col:
    mov ax, si
    mov dx, 80
    mul dx
    add ax, bx
    shl ax, 1
    mov di, ax
    
    cmp bx, 30         
    je .check_dash
    cmp bx, 47          
    je .check_dash
    mov ax, 0x7720      
    jmp .draw
.check_dash:
    mov ax, si
    and ax, 3
    cmp ax, 1
    jle .white_dash
    mov ax, 0x7720      
    jmp .draw
.white_dash:
    mov ax, 0x0FDB      
.draw:
    stosw
    inc bx
    cmp bx, 65          
    jl .col
    inc si
    cmp si, 25
    jl .row
    ret

draw_scenery:
    ; Sign on right grass
    mov di, (2*80 + 70)*2
    mov cx, 8
    mov ax, 0x0CDC
    rep stosw
    
    mov di, (3*80 + 69)*2
    mov ax, 0x0EDB
    stosw
    mov ax, 0x0E47      ; 'G'
    stosw
    mov ax, 0x0E4F      ; 'O'
    stosw
    mov ax, 0x0E21      ; '!'
    stosw
    mov cx, 3
    mov ax, 0x0EDB
    rep stosw
    
    mov di, (4*80 + 70)*2
    mov cx, 8
    mov ax, 0x0CDC
    rep stosw
    ret

scroll_road:
    mov cx, 23
.scroll_loop:
    push cx
    mov ax, cx
    dec ax
    mov bx, 160
    mul bx
    add ax, 15*2        
    mov si, ax
    
    mov ax, cx
    mov bx, 160
    mul bx
    add ax, 15*2
    mov di, ax
    
    mov bx, 50         
.copy_row:
    mov ax, [es:si]
    mov [es:di], ax
    add si, 2
    add di, 2
    dec bx
    jnz .copy_row
    pop cx
    loop .scroll_loop
    
    mov bx, 15          
.draw_top:
    mov di, 1
    mov ax, 80
    mul di
    add ax, bx
    shl ax, 1
    mov di, ax
    
    cmp bx, 30
    je .check_dash_top
    cmp bx, 47
    je .check_dash_top
    mov ax, 0x7720     
    jmp .draw_pixel
.check_dash_top:
    mov ax, [scroll_counter]
    and ax, 3
    cmp ax, 1
    jle .white_dash_top
    mov ax, 0x7720     
    jmp .draw_pixel
.white_dash_top:
    mov ax, 0x0FDB     
.draw_pixel:
    stosw
    inc bx
    cmp bx, 65         
    jl .draw_top
    
    inc word [scroll_counter]
    ret
	
draw_car:
    mov bx, [car_col]
    mov ax, 19
    mov dx, 80
    mul dx
    add ax, bx
    shl ax, 1
    
    push ax
    call car_print
    ret

erase_car:
    mov bx, [car_col]
    mov si, 19
.erase_row:
    mov ax, si
    mov dx, 80
    mul dx
    add ax, bx
    shl ax, 1
    mov di, ax
    mov cx, 9
    mov ax, 0x7720
.erase_col:
    stosw
    loop .erase_col
    inc si
    cmp si, 25
    jl .erase_row
    ret

car_print:
	push bp
	mov bp, sp
	push ax
	push bx
	push cx
	push dx
	push di
	push si
    mov ax, 0xB800
    mov es, ax
    mov di, [bp + 4]
	
	push di
	mov cx, 6
	mov bx, 9
	mov si, di
	
clear_car_area:
	mov dx, bx
	mov di, si
clear_inner:
	mov ax, 0x7720
	mov [es:di], ax
	add di, 2
	dec dx
	jnz clear_inner
	add si, 160
	loop clear_car_area
	
	pop di
	
	mov cx, 6
	mov bl, 9
	
	car_loop:
	mov dl, bl
	
		car_inner_loop:
			mov ax, 0x4020
			
			cmp dl, 1
			je tires_print
			
			cmp dl, bl
			jne other_conditions
			
			tires_print:
			mov ax, 0x0020
			
			cmp cx, 6
			je make_tires
			cmp cx, 2
			je make_tires
			jmp normal_car
				
			make_tires:
			mov ax, 0xF020
			jmp normal_car
			
			other_conditions:
			
			condition_0:
			cmp cx, 6
			jne condition_1
			
			cmp dl, 8
			je normal_car
			cmp dl, 2
			je normal_car
			mov ax, 0x3020
			jmp normal_car
						
			condition_1:
			cmp cx, 4
			ja condition_2
			
			cmp dl, 8
			je normal_car
			cmp dl, 2
			je normal_car
			mov ax, 0xF020
			
			condition_2:
			cmp cx, 1
			jne normal_car
			mov ax, 0x4020 
			
			normal_car:
				mov [es:di], ax
				add di, 2
				dec dl
				cmp dl, 0
			jne car_inner_loop
		add di, 160
		shl bx, 1
		sub di, bx
		shr bx, 1
	loop car_loop
		
	pop si
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
    ret 2

spawn_objects:
    mov ax, [spawn_cooldown]
    cmp ax, 0
    je .can_spawn
    dec ax
    mov [spawn_cooldown], ax
    jmp .check_bonus
    
.can_spawn:
    call get_random
    xor dx, dx
    mov cx, 10
    div cx
    cmp dx, 0
    jne .check_bonus
    
    call get_random
    xor dx, dx
    mov cx, 3
    div cx
    cmp dx, 0
    je .lane0
    cmp dx, 1
    je .lane1
    mov bx, 52
    jmp .spawn_enemy
.lane0:
    mov bx, 18
    jmp .spawn_enemy
.lane1:
    mov bx, 35
.spawn_enemy:
    call draw_enemy_car
    mov word [spawn_cooldown], 8
    
.check_bonus:
    mov ax, [bonus_cooldown]
    cmp ax, 0
    je .can_spawn_bonus
    dec ax
    mov [bonus_cooldown], ax
    jmp .done
    
.can_spawn_bonus:
    call get_random
    and ax, 0x0F
    cmp ax, 0
    jne .done
    
    call get_random
    xor dx, dx
    mov cx, 3
    div cx
    cmp dx, 0
    je .bonus_lane0
    cmp dx, 1
    je .bonus_lane1
    mov bx, 56
    jmp .spawn_bonus
.bonus_lane0:
    mov bx, 22
    jmp .spawn_bonus
.bonus_lane1:
    mov bx, 39
.spawn_bonus:
    call draw_coin
    mov word [bonus_cooldown], 15
    
.done:
    ret

draw_enemy_car:
    push ax
    push bx
    push cx
    push dx
    push di
    push si
    
    mov ax, 1
    mov dx, 80
    mul dx
    add ax, bx
    shl ax, 1
    
    push ax
    call enemy_car_print
    
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

enemy_car_print:
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push di
    push si
    mov ax, 0xB800
    mov es, ax
    mov di, [bp + 4]
    
    mov cx, 6
    mov bl, 9
    
enemy_car_loop:
    mov dl, bl
    
enemy_car_inner_loop:
    mov ax, 0x1020
    
    cmp dl, 1
    je enemy_tires_print
    cmp dl, bl
    jne enemy_other_conditions
    
enemy_tires_print:
    mov ax, 0x0020
    cmp cx, 6
    je enemy_make_tires
    cmp cx, 2
    je enemy_make_tires
    jmp enemy_normal_car
    
enemy_make_tires:
    mov ax, 0xF020
    jmp enemy_normal_car
    
enemy_other_conditions:
    cmp cx, 6
    jne enemy_condition_1
    cmp dl, 8
    je enemy_normal_car
    cmp dl, 2
    je enemy_normal_car
    mov ax, 0x9020
    jmp enemy_normal_car
    
enemy_condition_1:
    cmp cx, 4
    ja enemy_condition_2
    cmp dl, 8
    je enemy_normal_car
    cmp dl, 2
    je enemy_normal_car
    mov ax, 0xF020
    
enemy_condition_2:
    cmp cx, 1
    jne enemy_normal_car
    mov ax, 0x1020
    
enemy_normal_car:
    mov [es:di], ax
    add di, 2
    dec dl
    cmp dl, 0
    jne enemy_car_inner_loop
    
    add di, 160
    shl bx, 1
    sub di, bx
    shr bx, 1
    loop enemy_car_loop
    
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 2

draw_coin:
    mov di, 1
    mov ax, 80
    mul di
    add ax, bx
    shl ax, 1
    mov di, ax
    mov ax, 0xEE24
    stosw
    ret

check_collisions:
    mov bx, [car_col]
    mov si, 19
.check_rows:
    push bx
    mov cx, 8
.check_cols:
    push cx
    push bx
    
    mov ax, si
    mov dx, 80
    mul dx
    add ax, bx
    shl ax, 1
    mov di, ax
    mov ax, [es:di]
    
    cmp ah, 0x10
    je .collision
    cmp ah, 0x90
    je .collision
    cmp ah, 0x0F
    je .check_if_enemy
    
    cmp ah, 0xEE
    je .got_coin
    
    jmp .continue_check
    
.check_if_enemy:
    cmp si, 7
    jl .collision
    
.continue_check:
    pop bx
    pop cx
    inc bx
    loop .check_cols
    pop bx
    inc si
    cmp si, 25
    jl .check_rows
    ret
    
.collision:
    pop bx
    pop cx
    pop bx
    mov byte [game_over], 1
    ret
    
.got_coin:
    add word [score], 10
    mov ax, 0x7720
    mov [es:di], ax
    pop bx
    pop cx
    inc bx
    loop .check_cols
    pop bx
    inc si
    cmp si, 25
    jl .check_rows
    ret

draw_score:
    mov di, (24*80 + 65)*2
    mov cx, 14
    mov ax, 0x0020
.clear:
    stosw
    loop .clear
    
    mov di, (24*80 + 65)*2
    mov si, score_label
    mov cx, 9
    mov ah, 0x0F
.print_label:
    lodsb
    stosw
    loop .print_label
    
    mov ax, [score]
    call print_number
    ret

print_number:
    push bx
    push cx
    push dx
    
    xor cx, cx
    mov bx, 10
.divide_loop:
    xor dx, dx
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne .divide_loop
    
.print_loop:
    pop dx
    mov al, dl
    add al, '0'
    mov ah, 0x0F
    stosw
    loop .print_loop
    
    pop dx
    pop cx
    pop bx
    ret

get_random:
    push bx
    push dx
    
    mov ax, [random_seed]
    mov bx, 25173
    mul bx
    add ax, 13849
    mov [random_seed], ax
    
    pop dx
    pop bx
    ret

Print_Bushes:
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push di
    push si
    
    mov ax, [bp + 2]
    mov [width_bush], ax
    mov ax, 0xB800
    mov es, ax
    mov di, [bp + 4]
    mov bx, [width_bush]
    mov ax, 0x0220 

    mov cx, bx	
.continue_1:
    mov [es:di], ax
    add di, 2
    loop .continue_1
    
    add di, 160
    shl bx, 1
    sub di, bx
    shr bx, 1
    shr bx, 1
    mov dx, [width_bush]
    shr dx, 1
    sub di, dx
    add bx, [width_bush]
    mov cx, bx
    mov dx, [width_bush]
    shl dx, 1
    sub dx, 2
    add dx, di
    
.continue_2:
    mov ax, 0x0220
    cmp di, dx
    jne .normal_print_screen
    mov ax, 0x4220
    mov [es:di], ax
    add di, 2
    sub cx, 1
    jmp .continue_2

.normal_print_screen:
    mov [es:di], ax
    add di, 2
    loop .continue_2
    
    add di, 160
    shl bx, 1
    sub di, bx
    shr bx, 1
    shr bx, 1
    mov dx, [width_bush]
    shr dx, 1
    sub di, dx
    add bx, [width_bush]
    mov cx, [width_bush]
    shr cx, 1
    shr cx, 1
    add bx, cx
    mov cx, bx
    
    mov dx, di
    add dx, 4
    
.continue_3:
    mov ax, 0x0220
    cmp di, dx
    jne .normal_print2
    mov ax, 0x4220
    mov [es:di], ax
    add di, 2
    sub cx, 1
    jmp .continue_3

.normal_print2:
    mov [es:di], ax
    add di, 2
    loop .continue_3	

    mov dx, [bp + 6]
    cmp dx, 1
    je .end_of_bush
    
    add di, 160
    shl bx, 1
    sub di, bx
    shr bx, 1
    shr bx, 1
    mov dx, [width_bush]
    shr dx, 1
    sub di, dx
    add bx, [width_bush]
    mov cx, [width_bush]
    shr cx, 1
    add bx, cx
    mov cx, bx
    
    mov dx, di
    add dx, 14
    
.continue_4:
    mov ax, 0x0220 
    cmp di, dx
    jne .normal_print3
    mov ax, 0x4220
    mov [es:di], ax
    add di, 2
    sub cx, 1
    jmp .continue_4

.normal_print3:
    mov [es:di], ax
    add di, 2
    loop .continue_4		
    
.end_of_bush:
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret 6

tree_base:
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push di
    push si
        
    mov ax, 0xB800
    mov es, ax
    mov di, [bp + 2]
    mov si, [bp + 2]
    mov ax, 0x06DB
    mov cx, 3
    
.next_loc:
    mov [es:di], ax
    add di, 2
    mov [es:di], ax
    add di, 2
    add si, 160
    mov di, si
    loop .next_loc
        
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret 2

Stone_print:
    mov bp, sp
    push ax
    push bx
    push cx
    push dx
    push di
    push si
    
    mov ax, 0xB800
    mov es, ax
    mov di, [bp + 2]
    mov ax, 0x8020
    mov [es:di], ax
    add di, 2
    
    pop si
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret 2

NOTE_C4  equ 262
NOTE_D4  equ 294
NOTE_E4  equ 330
NOTE_F4  equ 349
NOTE_G4  equ 392
NOTE_A4  equ 440
NOTE_B4  equ 494
NOTE_C5  equ 523
NOTE_REST equ 0

music_data:
    dw NOTE_C5, 8
    dw NOTE_E4, 8
    dw NOTE_G4, 8
    dw NOTE_C5, 8
    dw NOTE_E4, 8
    dw NOTE_G4, 8
    dw NOTE_A4, 15
    dw NOTE_REST, 3
    dw NOTE_B4, 8
    dw NOTE_G4, 8
    dw NOTE_E4, 8
    dw NOTE_C5, 15
    dw NOTE_REST, 3
    dw 0, 0

init_music:
    mov word [music_index], 0
    mov word [music_timer], 0
    mov byte [music_enabled], 1
    ret

update_music:
    push ax
    push bx
    push cx
    push dx
    push si
    
    cmp byte [cs:music_enabled], 0
    je .done
    
    mov ax, [cs:music_timer]
    cmp ax, 0
    je .play_next_note
    dec ax
    mov [cs:music_timer], ax
    jmp .done
    
.play_next_note:
    mov si, [cs:music_index]
    
    mov ax, [cs:music_data + si]
    cmp ax, 0
    jne .not_end
    mov word [cs:music_index], 0
    mov si, 0
    
.not_end:
    mov ax, [cs:music_data + si]
    add si, 2
    mov bx, [cs:music_data + si]
    add si, 2
    mov [cs:music_index], si
    mov [cs:music_timer], bx
    
    cmp ax, NOTE_REST
    je .done
    call play_tone
    
.done:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

play_tone:
    push ax
    push bx
    push dx
    
    cmp ax, 0
    je .silence
    
    mov bx, ax
    mov ax, 1193
    mov dx, 1000
    mul dx
    add ax, 180
    adc dx, 0
    div bx
    mov bx, ax
    
    mov al, 0xB6
    out 0x43, al
    
    mov al, bl
    out 0x42, al
    mov al, bh
    out 0x42, al
    
    in al, 0x61
    or al, 0x03
    out 0x61, al
    jmp .done
    
.silence:
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    
.done:
    pop dx
    pop bx
    pop ax
    ret

stop_music:
    mov byte [cs:music_enabled], 0
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    ret 

score dw 0
scroll_counter dw 0
random_seed dw 12345
spawn_cooldown dw 0
bonus_cooldown dw 0
game_over db 0
car_col dw 35
width_bush dw 0
load_progress dw 0

tree1_row dw 2
tree2_row dw 10
tree3_row dw 18
tree4_row dw 5
tree5_row dw 15

game_over_text db '- GAME OVER -'
score_text db 'SCORE:  '
score_label db '   SCORE: '
exit_msg db 'Press ESC to exit'
play_again_msg db 'Play again? (Y/N)'

title_line1 db '   ASPHALT RUN   '
subtitle_text db '- A Racing Adventure -'
dev1_name db 'AQSA EHTESHAM'
dev1_roll db 'Roll No: 24L-3017'
dev2_name db 'SHEHRYAR WAHEED'
dev2_roll db 'Roll No: 24L-3023'
semester_text db 'SEMESTER: FALL 2025'
press_any_key db 'Press Any Key to Start...'

loading_text db '  LOADING...  '
status_msg1 db 'Initializing Engine...'
status_msg2 db 'Loading Graphics...'
status_msg3 db 'Creating Track...'
status_msg4 db 'Preparing Vehicles...'
status_msg5 db 'Ready to Race!'

old_timer_offset dw 0
old_timer_segment dw 0
timer_ticks dw 0
seconds_left dw 30
time_up db 0
timer_color db 0x0A
timer_label db 'TIME: '

music_index dw 0
music_timer dw 0
music_enabled db 1