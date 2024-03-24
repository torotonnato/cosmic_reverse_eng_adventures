org 100h

jmp main

%include "tui.asm"

bins_no: equ 20

main:
	tui_init
	call speaker_drv_init

	mov si, sound2
	call speaker_drv_play

    fild word [bins_max_height] ;(bins_max_height)
    fld dword [bins_alpha] ;(alpha) (bins_max_height)
    fld1 ;(1.0) (alpha) (bins_max_height)
    fsub st0, st1 ;(1.0 - alpha) (alpha) (bins_max_height)
.l:
    call setup_widget
    tui_widget (title_str + 9), (ibins)
    in al, 0x60
    cmp al, 1
    jnz .l

	call speaker_drv_shutdown
    tui_shutdown

	ret

setup_widget:
    mov ax, bins_no
    call speaker_drv_get_current_note
    jz .idx_done
    push ax
    mov bp, sp
    fld dword [bins_mult] ;(bin_mult)
    fld dword [bins_mult_log] ;(bin_mul_log) (bin_mult)
    fld dword [pit_src_clock_hz] ;(pit_src_clock_hz) (bin_mult_log) (bin_mult)
    fmulp ;(pit_src_clock_hz * bin_mult_log) (bin_mult)
    fild word [bp] ;(lambda) (pit_src_clock_hz * bin_mult_log) (bin_mult)
    fild word [bins_f_max] ;(f_max) (lambda) (pit_src_clock_hz * bin_mult_log) (bin_mult)
    fmulp ;(f_max * lambda) (pit_src_clock_hz * bin_mult_log) (bin_mult)
    fdivp ;(pit_src_clock_hz * bin_mult_log / f_max * lambda) (bin_mult)
    fyl2xp1
    fistp word [bp]
    pop ax
    cmp ax, bins_no
    jb .idx_done
    mov ax, bins_no - 1
.idx_done:
    sub ax, bins_no
    inc ax
    neg ax
    mov si, bins
    mov di, ibins
    mov cx, bins_no
.update:
    fld dword [si] ;(bins[i]) (1.0 - alpha) (alpha) (bins_max_height)
    fmul st1 ;(bins[i] * (1.0 - alpha)) (1.0 - alpha) (alpha) (bins_max_height)
    cmp ax, cx
    jne .not_selected
    fadd st2 ;(alpha + bins[i] * (1.0 - alpha)) (1.0 - alpha) (alpha) (bins_max_height)
.not_selected:
    fst dword [si]
    fmul st3
    fistp word [di]
    add si, 4
    add di, 2
    loop .update
    ret


pit_src_clock_hz: dd 1193181.6666

bins_max_height: dw 16
bins_alpha: dd 0.2
bins: times bins_no dd 0.0
bins_mult: dd 4.0
bins_mult_log: dd 31.0
bins_f_max: dw 10000

ibins: times bins_no dw 0

sound2: db 0x7E, 0x04, 0x7E, 0x04, 0x7E, 0x04, 0x7E, 0x04, 0x7E, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x36, 0x10, 0x36, 0x10, 0x36, 0x10, 0x36, 0x10, 0x36, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x28, 0x0A, 0x28, 0x0A, 0x28, 0x0A, 0x28, 0x0A, 0x28, 0x0A, 0x28, 0x0A, 0x28, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3A, 0x07, 0x3A, 0x07, 0x3A, 0x07, 0x3A, 0x07, 0x3A, 0x07, 0x3A, 0x07, 0x3A, 0x07, 0x3A, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x38, 0x18, 0xA8, 0x16, 0x4A, 0x15, 0x82, 0x14, 0x24, 0x13, 0x8E, 0x12, 0xC6, 0x11, 0xCC, 0x10, 0xD2, 0x0F, 0x3C, 0x0F, 0x74, 0x0E, 0x7A, 0x0D, 0x86, 0x0B, 0x60, 0x09, 0x98, 0x08, 0x02, 0x08, 0x3A, 0x07, 0xA4, 0x06, 0xDC, 0x05, 0x46, 0x05, 0xB0, 0x04, 0x1A, 0x04, 0xFF, 0xFF

title_str: db '  ciaone  '

%include "speaker_drv.asm"
