[org 0]
[bits 16]
jmp 0x07c0:start							; offset is start:

start:
	mov ax, cs									; 0x07c0 in cs
	mov ds, ax

	mov ax, 0xB800
	mov es, ax
	mov di, 0
	mov ax, word [msgBack]			; [DS:msgBack] / ax = msgBack value
	mov cx, 0x7FF

paint:
	mov word [es:di], ax				;	[0XB800:0]	= ax
	add di, 2
	dec cx
	jnz paint										; zero flag check

	mov edi, 0									; Video memory format is 2Byte
	mov byte [es:edi], 'A'			; [0XB800:0] = 'A' <- ascii value
	inc edi
	mov byte [es:edi], 0x06			; [0XB800:1] = 0x06 <- 0000(bg color is black ) / 0110(letter color is brown)
	inc edi
	mov byte [es:edi], 'B'
	inc edi
	mov byte [es:edi], 0x06
	inc edi
	mov byte [es:edi], 'C'
	inc edi
	mov byte [es:edi], 0x06
	inc edi
	mov byte [es:edi], '1'
	inc edi
	mov byte [es:edi], 0x06
	inc edi
	mov byte [es:edi], '2'
	inc edi
	mov byte [es:edi], 0x06
	inc edi
	mov byte [es:edi], '3'
	inc edi
	mov byte [es:edi], 0x06

	jmp $

msgBack db '.', 0x67					; letter('.'), color(bg(brown), letter(white))

times 510-($-$$) db 0
dw 0xAA55											; MBR check
