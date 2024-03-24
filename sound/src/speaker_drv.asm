PIC_MASTER_CMD_PORT equ 0x20
PIC_EOI             equ 0x20
PIT_CH0_DATA_PORT   equ 0x40
PIT_CH2_DATA_PORT   equ 0x42
PIT_MODE_PORT       equ 0x43
PPI_REG_B_PORT      equ 0x61

%macro speaker_disable 0
	in al, PPI_REG_B_PORT
	and al, 0xFC
	out PPI_REG_B_PORT, al
%endmacro

%macro speaker_square_wave 0
	push ax
	mov al, 0xB6
	out PIT_MODE_PORT, al
	pop ax
	out PIT_CH2_DATA_PORT, al
	mov al, ah
	out PIT_CH2_DATA_PORT, al
%endmacro

%macro speaker_enable 0
	in al, PPI_REG_B_PORT
	or al, 0x03
	out PPI_REG_B_PORT, al
%endmacro

%macro pit_ch0_trig_after 0
	push ax
	mov al, 0x30
	out PIT_MODE_PORT, al
	pop ax
	out PIT_CH0_DATA_PORT, al
	mov al, ah
	out PIT_CH0_DATA_PORT, al
%endmacro

speaker_drv_init:
	push es
	push ds
	push bx
	push ax
	speaker_disable
	mov ax, 3508h
	int 21h
	mov cs:[irq0_prev_handler], bx
	mov cs:[irq0_prev_handler + 2], es
	mov ax, 0x2508
	mov dx, speaker_drv_irq_handler
	cli
	int 0x21
	mov al, 0x30
	out PIT_MODE_PORT, al
	sti
	pop ax
	pop bx
	pop ds
	pop es
	ret

speaker_drv_play:
	cli
	mov cs:[speaker_drv_irq_sample_ptr], si
	mov cs:[speaker_drv_irq_sample_ptr + 2], ds
	mov byte cs:[speaker_drv_irq_state], SPEAKER_PLAY
	sti
	int 8
	ret

speaker_drv_wait:
	cmp byte cs:[speaker_drv_irq_state], SPEAKER_PLAY
	je speaker_drv_wait
	ret

speaker_drv_stop:
	cli
	mov byte cs:[speaker_drv_irq_state], SPEAKER_STOP
	sti
	ret

speaker_drv_shutdown:
	push ds
	push dx
	push ax
	speaker_disable
	mov al, 54h
	out PIT_MODE_PORT, al
	mov al, 0xff
	out PIT_CH2_DATA_PORT, al
	out PIT_CH2_DATA_PORT, al
	cli
	mov ax, 2508h
	lds dx, cs:[irq0_prev_handler]
	int 21h
	sti
	pop ax
	pop dx
	pop ds
	ret

speaker_drv_get_current_note:
    cmp byte cs:[speaker_drv_irq_state], SPEAKER_STOP
    jz .no_note
    mov si, cs:[speaker_drv_irq_sample_ptr]
    mov ax, cs:[si]
    cmp ax, 0xFFFF
    jz .no_note
    test ax, ax
.no_note:
    ret

SPEAKER_STOP equ 0x00
SPEAKER_PLAY equ 0x01

speaker_drv_irq_handler:
	cli
	push ax
	cmp byte cs:[speaker_drv_irq_state], SPEAKER_PLAY
	je .play
.disable_and_return:
	speaker_disable
    jmp .end
.play:
	push ds
	push si
	lds si, cs:[speaker_drv_irq_sample_ptr]
	lodsw
	mov cs:[speaker_drv_irq_sample_ptr], si
	pop si
	pop ds
	cmp ax, 0xFFFF
	jne .stream_continue
	mov byte cs:[speaker_drv_irq_state], SPEAKER_STOP
	jmp .disable_and_return
.stream_continue:
	test ax, ax
	jnz .play_note
	speaker_disable
    mov ax, 0x3FFF
    jmp .pre_end
.play_note:
	push ax
	speaker_square_wave
	speaker_enable
	pop ax
.pre_end:
	pit_ch0_trig_after
.end:
	mov al, PIC_EOI
	out PIC_MASTER_CMD_PORT, al
	pop ax
	iret

speaker_drv_irq_state:      db SPEAKER_STOP
speaker_drv_irq_sample_ptr: dw 0, 0

irq0_prev_handler:          dw 0, 0
