[org 0]
[bits 16]

start:                        ; this address 0x10000 (0x1000:0000)
  mov ax, cs                  ; 0x1000 in cs
  mov ds, ax                  ; set value
  xor ax, ax
  mov ss, ax

  cli

  lgdt[gdtr]                  ; register gdt so that cpu is known

  mov eax, cr0
  or eax, 0x00000001
  mov cr0, eax

  jmp $+2
  nop
  nop

  db 0x66
  db 0x67
  db 0xEA
  dd PM_Start
  dw SysCodeSelector

;+++++ start protected mode +++++
[bits 32]
PM_Start:
  mov bx, SysDataSelector
  mov ds, bx                ; put value(0x10) to segment selector
  mov es, bx
  mov fs, bx
  mov gs, bx
  mov ss, bx

  xor eax, eax
  mov ax , VideoSelector
  mov es, ax                ; put value to segment selector
  mov edi, 80*2*10+2*10
  lea esi, [ds:msgPMode]
  call printf

  jmp $

;+++++ sub routines +++++
printf:
  push eax

printf_loop:
  or al, al
  jz printf_end
  mov al, byte[esi]
  mov byte [es:edi], al
  inc edi
  mov byte [es:edi], 0x06
  inc esi
  inc edi
  jmp printf_loop

printf_end:
  pop eax
  ret

msgPMode db "We are in Protected Mode", 0

;+++++ GDT Table +++++
gdtr:
  dw gdt_end - gdt -1         ; GDT Size (8Byte * 4 = 32Byte)
  dd gdt+0x10000              ; GDT start address

gdt:                          ; NULL descriptor
  dw 0
  dw 0
  db 0
  db 0
  db 0
  db 0

; Code Segment Descriptor
SysCodeSelector equ 0x08      ; index(15~3 bit) / T1,RPL(2~0 bit) - index 1
  dw 0xFFFF                   ; Limit(0xFFFF)
  dw 0x0000                   ; Base Address
  db 0x01                     ; Base Address (0x010000)
  db 0x9A                     ; P(1), DPL(0_kernelLevel), S(1_Code) / TYPE(CODE, read/write)
  db 0xCF                     ; G(1_4KB), D(1_32bit) / Limit(0xF)_0xFFFFF => 0xFFFFF*0xFFF = 4GB
  db 0x00                     ; Base Adress

; Data Segment Descriptor
SysDataSelector equ 0x10      ; index 2
  dw 0xFFFF                   ; Limit(0xFFFF)
  dw 0x0000                   ; Base Address
  db 0x01                     ; Base Address (0x010000)
  db 0x92                     ; P(1), DPL(0), S(1_Code) / TYPE(DATA, read/write)
  db 0xCF
  db 0x00

; Video Segment Descriptor (0xB8000 ~ 0xC7FFF)
VideoSelector equ 0x18        ; index 3
  dw 0xFFFF                   ; Limit (0xFFFF)
  dw 0x8000
  db 0x0B                     ; Base Address (0xB8000)
  db 0x92
  db 0x40                     ; G(0_1Byte), D(1_32bit) / Limit(0xFFFF)
  db 0x00
gdt_end:
