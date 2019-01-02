[org 0]
[bits 16]

start:                        ; this address 0x10000 (0x1000:0000)
  mov ax, cs                  ; 0x1000 in cs
  mov ds, ax                  ; set value
  xor ax, ax
  mov ss, ax

  lea esi, [msgKernel]        ; address copy
  mov ax, 0xB800
  mov es, ax
  mov edi, 0
  call printf

  jmp $

printf:
  push eax                    ; push to stack

printf_loop:
  mov al, byte [esi]
  mov byte [es:edi], al
  or al, al                   ; when al value is 0, jump to printf_end
  jz printf_end
  inc edi
  mov byte [es:edi], 0x06
  inc esi
  inc edi
  jmp printf_loop

printf_end:
  pop eax
  ret

msgKernel db "We are in kernel program", 0
