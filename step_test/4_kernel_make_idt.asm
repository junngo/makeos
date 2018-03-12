%include "init.inc"

[org 0x10000]
[bits 32]

PM_Start:
  mov bx, SysDataSelector
  mov ds, bx
  mov es, bx
  mov fs, bx
  mov gs, bx
  mov ss, bx

  lea esp, [PM_Start]         ; stack pointer init

  mov edi, 0
  lea esi, [msgPMode]
  call printf

  cld
  mov ax, SysDataSelector     ; es = SysDataSelector
  mov es, ax
  xor eax, eax                ; eax, ecx init 0
  xor ecx, ecx
  mov ax, 256                 ; copy 256 descriptor to IDT region
  mov edi, 0                  ; physical 0 to copy descriptor

loop_idt:
  lea esi, [idt_ignore]       ; esi = idt_ignore addr (lea-address copy)
  mov cx, 8
  rep movsb                   ; DS:ESI -> ES:EDI (rep movsb - repeat move single byte)
  dec ax
  jnz loop_idt

  lidt [idtr]                 ; register idt so that cpu is known

  sti                         ; interrupt active -> IE Bit set
  int 0x77                    ; software interrupt
  jmp $

;+++++ sub routines +++++
printf:
  push eax
  push es
  mov ax, VideoSelector
  mov es, ax

printf_loop:
  mov al, byte [esi]
  mov byte [es:edi], al
  inc edi
  mov byte [es:edi], 0x06
  inc esi
  inc edi
  or al, al
  jz printf_end
  jmp printf_loop

printf_end:
  pop es
  pop eax
  ret

;+++++ Data Area +++++
msgPMode db "We are in Protected Mode", 0
msg_isr_ignore db "This is an ignorable interrupt", 0
msg_isr_32_timer db ".This is the timer interrupt", 0


;+++++ Interrupt Service routines +++++
isr_ignore:
  push gs
  push fs
  push es
  push ds
  pushad
  pushfd

  mov ax, VideoSelector
  mov es, ax
  mov edi, (80*7*2)
  lea esi, [msg_isr_ignore]
  call printf

  popfd
  popad
  pop ds
  pop es
  pop fs
  pop gs

  iret

;+++++ IDT +++++
idtr:
  dw 256*8-1                  ; idt size
  dd 0                        ; idt start address

idt_ignore:
  dw isr_ignore
  dw SysCodeSelector
  db 0
  db 0x8E
  dw 0x0001

times 512-($-$$) db 0
