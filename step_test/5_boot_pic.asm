%include "init.inc"

[org 0]
  jmp 07C0h:start

start:
  mov ax, cs
  mov ds, ax
  mov es, ax

reset:
  mov ax, 0
  mov dl, 0
  int 13h
  jc reset

  mov ax, 0xB800
  mov es, ax
  mov di, 0
  mov ax, word [msgBack]
  mov cx, 0x7FF

paint:
  mov word [es:di], ax
  add di, 2
  dec cx
  jnz paint

read:
  mov ax, 0x1000
  mov es, ax
  mov bx, 0

  mov ah, 2
  mov al, 1
  mov ch, 0
  mov cl, 2
  mov dh, 0
  mov dl, 0
  int 13h

  jc read

  mov dx, 0x3F2
  xor al, al
  out dx, al

  cli

  ; ICW 1
  mov al, 0x11      ; PIC init
  out 0x20, al      ; master PIC
  dw 0x00eb, 0x00eb ; jmp$+2, jmp$+2
  out 0xA0, al      ; slave PIC
  dw 0x00eb, 0x00eb ; jmp$+2, jmp$+2

  ; ICW 2
  mov al, 0x20      ; master PIC
  out 0x21, al
  dw 0x00eb, 0x00eb
  mov al, 0x28      ; slave PIC
  out 0xA1, al
  dw 0x00eb, 0x00eb

  ; ICW 3
  mov al, 0x04      ; master PIC IRQ 2 <- slave PIC
  out 0x21, al
  dw 0x00eb, 0x00eb
  mov al, 0x02      ; slave PIC IRQ 2 <- master PIC
  out 0xA1, al
  dw 0x00eb, 0x00eb

  ; ICW 4
  mov al, 0x01      ; use the 8086 mode
  out 0x21, al
  dw 0x00eb, 0x00eb
  out 0xA1, al
  dw 0x00eb, 0x00eb

  mov al, 0xFF
  out 0xA1, al
  dw 0x00eb, 0x00eb
  mov al, 0xFB
  out 0x21, al

  lgdt[gdtr]

  mov eax, cr0
  or eax, 0x00000001
  mov cr0, eax

  jmp $+2
  nop
  nop

  mov bx, SysDataSelector
  mov ds, bx
  mov es, bx
  mov fs, bx
  mov gs, bx
  mov ss, bx

  jmp dword SysCodeSelector:0x10000

  msgBack db '.', 0x67

;+++++ GDT Table +++++
gdtr:
  dw gdt_end - gdt -1
  dd gdt+0x7C00

gdt:
  dd 0, 0
  dd 0x0000FFFF, 0x00CF9A00
  dd 0x0000FFFF, 0x00CF9200
  dd 0x8000FFFF, 0x0040920B

gdt_end:

times 510-($-$$) db 0
dw 0AA55h
