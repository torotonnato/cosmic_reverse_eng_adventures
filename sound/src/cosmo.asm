org 100h

jmp main

%include "tui.asm"

bins_no: equ 20

%macro setup_widget 0
    mov ax, bins_no
    call speaker_drv_get_current_note
    jz .idx_done
    push ax
    mov bp, sp
    fld st4                                 ;(pit_src_clock_hz * bins_mult_log) (1.0 - bins_alpha) (bins_alpha) (bins_max_height) (f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)
    fild word [bp]                          ;(lambda) (pit_src_clock_hz * bins_mult_log) (1.0 - bins_alpha) (bins_alpha) (bins_max_height) (f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)
    fmul st0, st5                           ;(f_max * lambda) (pit_src_clock_hz * bins_mult_log) (1.0 - bins_alpha) (bins_alpha) (bins_max_height) (f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)
    fdivp st1, st0                          ;(pit_src_clock_hz * bin_mult_log / f_max * lambda) (1.0 - bins_alpha) (bins_alpha) (bins_max_height) (f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)
    fld st6                                 ;(bins_mult) (pit_src_clock_hz * bin_mult_log / f_max * lambda) (1.0 - bins_alpha) (bins_alpha) (bins_max_height) (f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)
    fxch                                    ;(pit_src_clock_hz * bin_mult_log / f_max * lambda) (bins_mult) (1.0 - bins_alpha) (bins_alpha) (bins_max_height) (f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)
    fyl2xp1                                 ;(log) (1.0 - bins_alpha) (bins_alpha) (bins_max_height) (f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)
    fistp word [bp]                         ;(1.0 - bins_alpha) (bins_alpha) (bins_max_height) (f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)
    pop ax
    cmp ax, bins_no
    jb .idx_done
    mov al, bins_no - 1
.idx_done:
    sub ax, bins_no
    not ax                                  ;(bins_no - 1) - ax
    mov si, bins
    mov di, ibins
    mov cx, bins_no
.update:
    fld dword [si]                          ;(bins[i]) (1.0 - bins_alpha) (bins_alpha) (bins_max_height) (f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)
    fmul st1                                ;(bins[i] * (1.0 - bins_alpha)) (1.0 - bins_alpha) (bins_alpha) (bins_max_height) (f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)
    cmp ax, cx
    jne .not_selected
    fadd st2                                ;(alpha + bins[i] * (1.0 - bins_alpha)) (1.0 - bins_alpha) (bins_alpha) (bins_max_height) (f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)
.not_selected:
    fst dword [si]                          ;(alpha + bins[i] * (1.0 - bins_alpha)) (1.0 - bins_alpha) (bins_alpha) (bins_max_height) (f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)
    fmul st3                                ;((bins_max_height * (alpha + bins[i] * (1.0 - bins_alpha)))) (1.0 - bins_alpha) (bins_alpha) (bins_max_height) (f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)
    fistp word [di]                         ;(1.0 - bins_alpha) (bins_alpha) (bins_max_height) (f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)
    add si, 4
    inc di
    inc di
    loop .update
%endmacro

main:
	tui_init
	call speaker_drv_init

	mov si, sound2
	call speaker_drv_play

    fld dword [bins_mult]                         ;(bins_mult)
    fld dword [bins_mult_log]                     ;(bins_mul_log) (bins_mult)
    fld dword [pit_src_clock_hz]                  ;(pit_src_clock_hz) (bins_mult_log) (bins_mult)
    fmulp                                         ;(pit_src_clock_hz * bins_mult_log) (bins_mult)
    fild word [bins_f_max]                        ;(f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)
    fild word [bins_max_height]                   ;(bins_max_height) (f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)
    fld dword [bins_alpha]                        ;(bins_alpha) (bins_max_height) (f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)
    fld1                                          ;(1.0) (bins_alpha) (bins_max_height) (f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)
    fsub st0, st1                                 ;(1.0 - bins_alpha) (bins_alpha) (bins_max_height) (f_max) (pit_src_clock_hz * bins_mult_log) (bins_mult)

.l:
    setup_widget
    tui_widget (title_str + 9), (ibins)
    in al, 0x60
    cmp al, 1
    jnz .l

	call speaker_drv_shutdown
    tui_shutdown

	ret

pit_src_clock_hz: dd 1193181.6666

bins_max_height:  dw 16
bins_alpha:       dd 0.2
bins:             times bins_no dd 0.0
bins_mult:        dd 4.0
bins_mult_log:    dd 31.0
bins_f_max:       dw 10000

ibins: times bins_no dw 0

sound2: db 0x7E, 0x04, 0x7E, 0x04, 0x7E, 0x04, 0x7E, 0x04, 0x7E, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x36, 0x10, 0x36, 0x10, 0x36, 0x10, 0x36, 0x10, 0x36, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x28, 0x0A, 0x28, 0x0A, 0x28, 0x0A, 0x28, 0x0A, 0x28, 0x0A, 0x28, 0x0A, 0x28, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x3A, 0x07, 0x3A, 0x07, 0x3A, 0x07, 0x3A, 0x07, 0x3A, 0x07, 0x3A, 0x07, 0x3A, 0x07, 0x3A, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x38, 0x18, 0xA8, 0x16, 0x4A, 0x15, 0x82, 0x14, 0x24, 0x13, 0x8E, 0x12, 0xC6, 0x11, 0xCC, 0x10, 0xD2, 0x0F, 0x3C, 0x0F, 0x74, 0x0E, 0x7A, 0x0D, 0x86, 0x0B, 0x60, 0x09, 0x98, 0x08, 0x02, 0x08, 0x3A, 0x07, 0xA4, 0x06, 0xDC, 0x05, 0x46, 0x05, 0xB0, 0x04, 0x1A, 0x04, 0xFF, 0xFF

title_str: db '  ciaone  '

%include "speaker_drv.asm"
