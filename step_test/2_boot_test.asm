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
  mov ax, 0x1000              ; load kernel to 0x10000 adress
  mov es, ax                  ; address place -> es:bx
  mov bx, 0

  mov ah, 2                   ; BIOS CALL number
  mov al, 1                   ; 1 sector read
  mov ch, 0                   ; cylinder value 0
  mov cl, 2                   ; where place from sector
  mov dh, 0                   ; head value
  mov dl, 0                   ; driver number -> floppy disk
  int 0x13                    ; BIOS CALL - read sector and load to RAM
                              ; If it's happen the error, CF bit set 1
  jc read                     ; When CF bit is set, return read: (re read)
  jmp 0x1000:0000

msgBack db '.', 0x67

times 510-($-$$) db 0
dw 0AA55h
