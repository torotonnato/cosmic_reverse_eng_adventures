TEXT_COLUMNS: equ 80
TEXT_ROWS:    equ 25

font8x8_tbl:  equ 0xC000

%macro tui_init 0
    mov ax, 0x03
    int 0x10

    mov ah, 0x01
	mov cx, 0x100
	int 0x10 ;enable high-intensity background

	mov ax, 0x1003
	mov bl, 0x00
	int 0x10 ;disable cursor

    mov ax, 0x1130
    mov bh, 0x03 ;8x8 font
    int 0x10 ;get font bitmap

    sub si, si
    mov cx, 0x400
.mov:
    mov al, es:[bp + si]
    mov [si + font8x8_tbl], al
    inc si
    loop .mov

	mov si, tui_palette
.set_color:
    lodsw
    xchg ax, bx
	mov dh, bh
    lodsw
    xchg ax, cx
	mov ax, 0x1010
	int 0x10
    cmp bl, tui_palette_last_ega_color
	jne .set_color

    push 0xB800
	pop es
%endmacro

%macro tui_widget 2
    mov bp, %1
    mov dh, 0x01
    mov di, (TEXT_COLUMNS - 1) * 2
    mov cx, di
.cols:
    mov bx, cx
    shr bx, 3
    shl bx, 1
    mov dl, [bx + %2]
    mov bl, ds:[bp]
    shl bx, 3
    lea si, [bx + font8x8_tbl]
    mov bx, -4
.rows:
    mov al, TEXT_ROWS - 6
    sub al, bl
    cmp dl, al
    jge .text_draw
    sub al, al
.text_draw:
    test bl, 24
    jnz .pixel_done
    test [bx + si], dh
    jz .pixel_done
    mov al, 0x0f
.pixel_done:
    shl ax, 12
    stosw
    add di, (TEXT_COLUMNS - 1) * 2
    inc bx
    cmp bl, TEXT_ROWS - 5
    jl .rows
    sub di, TEXT_COLUMNS * (TEXT_ROWS - 1) * 2 + 2
    rol dh, 1
    sbb bp, 0
    dec cx
    dec cx
    jns .cols
    mov di, TEXT_COLUMNS * (TEXT_ROWS - 1) * 2
    mov si, tui_widget_banner_str
    mov cx, TEXT_COLUMNS * 2
    repz movsw
%endmacro

%macro tui_shutdown 0
	mov ax, 0x03
	int 0x10
%endmacro

%include "tui_palette.asm"
%include "tui_widget_banner.asm"
