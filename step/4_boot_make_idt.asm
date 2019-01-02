%include "init.inc"

[org 0]
  jmp 07C0h:start

start:
  mov ax, cs
  mov ds, ax
  mov es, ax

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

  mov dx, 0x3F2               ; After kernel program copy to RAM and
  xor al, al                  ; turn off floppy
  out dx, al

  cli                         ; block interrupt
  mov al, 0xFF
  out 0xA1, al

  lgdt[gdtr]                  ; register gdt so that cpu is known

  mov eax, cr0
  or eax, 0x00000001          ; PE bit set
  mov cr0, eax                ; Now, Protected Mode

  jmp $+2
  nop
  nop

  mov bx, SysDataSelector     ; SysDataSelector(0x10)
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
  dd 0, 0                     ; NULL descriptor
  dd 0x0000FFFF, 0x00CF9A00   ; SysCodeSelector
  dd 0x0000FFFF, 0x00CF9200   ; SysDataSelector
  dd 0x8000FFFF, 0x0040920B   ; VideoSelector

gdt_end:

times 510-($-$$) db 0
dw 0AA55h