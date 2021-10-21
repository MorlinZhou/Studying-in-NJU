section .data
    msg  db  "Please input x and y:", 0Ah, 0h

section .bss
    sinput  resb 60                 ;reserve byte 保留空白字节
    x       resb 30
    xlen    resb 1
    y       resb 30
    ylen    resb 1
    addRes  resb 31
    multRes resb 61
    resLen  resb 1

section .text
global _start
_start:
    mov  eax,msg
    call sprint
input:
; read x & y
    mov  eax, 3                     ;system_read方法，edx为大小
    mov  ebx, 0
    mov  ecx, sinput                ;ecx为char*指针，指向input存储的地方
    mov  edx, 30
    int  80h

; memory allocate x & y
    xor  eax, eax
    xor  ebx, ebx
    xor  ecx, ecx
    xor  edx, edx
loop1:
    cmp  byte [sinput + eax], ' '   ;判断现在是不是空格，如果是空格说明第一个数结束了
    jz   loop2                      ;jz=jump if zero
    inc  eax                        ;得出第一个数有几个byte长，用eax保存
    jmp  loop1
loop2:
    cmp  ebx, eax                   ;第一个数存完ebx=eax
    jz   loop3                      ;存完了就跳转
    mov  cl, byte [sinput + ebx]    
    mov  byte [x + ebx], cl         ;将输入存在x开头的内存中，一个字节一个字节存
    inc  ebx                        ;存完一个字节ebx++
    jmp  loop2
loop3:
    cmp  byte [sinput + ebx], 0     ;如果这地方是0（即ebx指向第二个数末尾了，后面都是系统之前清0的内存区域）
    jz   processFinished            ;处理结束
    cmp  byte [sinput + ebx], ' '   ;如果是空格，说明第一个数刚刚读完
    jz   spaceProcess               
    mov  cl, byte [sinput + ebx]    
    mov  edx, ebx                   
    sub  edx, 1                     
    sub  edx, eax                   ;现在的地址-1减去x的长度，得到现在已经读取的y的长度
    mov  byte [y + edx], cl         ;剩下的都是y了
spaceProcess:
    inc  ebx                        ;跳过空格，准备读下一个数
    jmp  loop3                      ;该函数和loop3一起循环存储y

processFinished:
    mov  byte [xlen], al            ;存储x的长度到xlen中
    add  edx, 1
    mov  byte [ylen], dl
    
    xor  ebx, ebx                   ;ebx清零
    mov  eax, x                     ;x的地址给eax
    mov  bl, byte [xlen]
    call strToInt
    
    mov  eax, y
    mov  bl, byte [ylen]
    call strToInt
    
    mov  ecx, 0Ah                   ;0Ah换行符
    push ecx
    mov  edx, 1
    mov  ecx, esp                   ;esp栈顶指针
    mov  ebx, 1
    mov  eax, 4
    int  80h                        ;eax=4，调用system_write，ecx为const char*，大小为edx
    pop  ecx

addPrepare:
    xor  eax, eax
    xor  ebx, ebx
    mov  al, byte [xlen]
    mov  bl, byte [ylen]
    mov  byte [resLen], al
    cmp  eax, ebx
    jg   addStart                   ;jg=jump if greater
    mov  byte [resLen], bl          ;resLen里存储两个数的len中更大的那个
addStart:
    xor  ecx, ecx
    xor  edx, edx
addLoop:
    cmp  ecx, [resLen]              ;ecx为已经计算结束的字节数
    jg   addLoopFinished            ;ecx大于resLen计算结束
    dec  eax                        ;x_len-1
    dec  ebx                        ;y_len-1
eaxProcess:
    cmp  eax, 0
    jl   eaxOutOfBounds
    mov  dl, byte [x + eax]
    jmp  ebxProcess
eaxOutOfBounds:
    mov  dl, 0
ebxProcess:
    cmp  ebx, 0
    jl   ebxOutOfBounds
    add  dl, byte [y + ebx]
    jmp  continue
ebxOutOfBounds:
    add  dl, 0
continue:
    mov  byte [addRes + ecx], dl    ;按字节存储结算结果
    inc  ecx
    jmp  addLoop
addLoopFinished:
    mov  eax, addRes
    mov  ebx, [resLen]
    call carry
    call numPrinter
multPrepare:
    xor  eax, eax
    xor  ebx, ebx
    mov  al, [xlen]                     ;eax为x的长度
    mov  bl, [ylen]                     ;ebx为y的长度
    add  eax, ebx
    mov  byte [resLen], al
    mov  al, [xlen]
multStart:
    xor  esi, esi                       ;存储器指针SI，DI
    xor  edi, edi
    xor  ecx, ecx
    xor  edx, edx
multiplierLoop:
    dec  eax                            ;eax--
    cmp  eax, 0                         ;x算完了吗？
    jl   multiplierLoopFinished
multiplicandLoop:                       ;相当于在竖式计算中y*x，y在上面
    dec  ebx
    cmp  ebx, 0                         ;y算完了吗？
    jl   multiplicandLoopFinished
    xor  ecx, ecx
    mov  cl, byte [x + eax]             ;x放入cx寄存器低位
    mov  ch, byte [y + ebx]             ;y放入cx寄存器高位
    push eax                            ;保存eax的值
    xor  eax, eax
    mov  al, cl
    mov  ah, ch
    mul  ah                             ;al*ah>>ax
    xor  ecx, ecx
    mov  cl, byte [ylen]
    sub  ecx, ebx                       ;ebx为y剩余待处理的位数，ecx为y总位数，该运算结果为已经处理的位数
    sub  ecx, 1
    mov  esi, ecx
    add  esi, edx
    add  dword [multRes + esi], eax
    pop  eax
    jmp  multiplicandLoop
multiplicandLoopFinished:
    xor  ebx, ebx
    mov  bl, byte [ylen]
    inc  edx
    
    push eax
    
    mov  eax, multRes
    xor  ebx, ebx
    mov  bl, byte [resLen]
    sub  ebx, 1
    call carry
    pop  eax
    
    jmp  multiplierLoop
multiplierLoopFinished:
    mov  eax, multRes
    xor  ebx, ebx
    mov  bl, byte [resLen]
    sub  ebx, 1
    call carry
    call numPrinter
    
    call quit

; Here are the functions.
;------------------------
; numPrinter
numPrinter:
    push edx
    push ecx
    push eax
    push ebx
.printLoop:
    cmp  ebx, 0
    jl   .printFinished
    pop  ecx
    push ecx
    cmp  ebx, ecx
    jz   .headZeroProcess
    jmp  .continue
.headZeroProcess:
    cmp  byte [eax + ecx], 0
    jz   .nextPrintLoop
.continue:
    add  byte [eax + ebx], 48
    
    push eax
    push ebx
    
    mov  edx, 1
    mov  ecx, ebx
    add  ecx, eax
    mov  ebx, 1
    mov  eax, 4
    int  80h
    
    pop  ebx
    pop  eax
.nextPrintLoop:
    dec  ebx
    jmp  .printLoop
.printFinished:
    mov  ecx, 0Ah
    push ecx
    mov  edx, 1
    mov  ecx, esp
    mov  ebx, 1
    mov  eax, 4
    int  80h
    pop  ecx
    
    pop  ebx
    pop  eax
    pop  ecx
    pop  edx
    ret
; carry
carry:
    push ecx                            ;eax存储加法结果，ebx存储长度
    push edx
    xor  ecx, ecx
    xor  edx, edx  
.carryingLoop:
    cmp  ecx, ebx
    jz   .outerLoopFinished
    xor  edx, edx
.countCarryingLoop:
    cmp  byte [eax + ecx], 10               
    jl   .innerLoopFinished             ;如果没有进位
    sub  byte [eax + ecx], 10
    inc  edx                            ;edx为进位
    jmp  .countCarryingLoop
.innerLoopFinished:
    inc  ecx
    add  byte [eax + ecx], dl
    jmp  .carryingLoop
.outerLoopFinished:
    pop  edx
    pop  ecx
    ret
; strToInt
strToInt:
    push ecx
    push edx
    xor  ecx, ecx
    xor  edx, edx
.loop:
    cmp  ecx, ebx
    jz   .finished
    mov  dl, byte [eax + ecx]           ;eax为存储的数的起始地址
    sub  edx, 48                        ;48是0的ASCII
    mov  byte [eax + ecx], dl           ;转换成int后存入原来的位置
    inc  ecx
    jmp  .loop
.finished:
    pop  edx
    pop  ecx
    ret
;------------------------
; slen
; eax stores the length of str in ebx
slen:
    push ebx
    mov  ebx, eax

.nextChar:
    cmp  byte [eax], 0
    jz   .finished
    inc  eax
    jmp  .nextChar

.finished:
    sub  eax, ebx
    pop  ebx
    ret

;-------------------
; sprint
; print str in [eax]
sprint:
    push edx
    push ecx
    push ebx
    push eax
    call slen

    mov  edx, eax
    pop  eax

    mov  ecx, eax
    mov  ebx, 1
    mov  eax, 4
    int  80h

    pop  ebx
    pop  ecx
    pop  edx
    ret

;---------------
; quit
quit:
    mov  ebx, 0
    mov  eax, 1
    int  80h                            ;system_exit
    ret
