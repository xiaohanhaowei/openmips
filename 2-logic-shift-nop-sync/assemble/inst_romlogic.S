.org 0x0
.global _start
.set noat //允许使用寄存器$1
_start:
    lui  $1, 0x0101           # $1 = 0x01010000
    ori  $1, $1, 0x0101       
    ori  $2, $1, 0x1100
    or   $1,$1, $2
    andi $3,$1, 0x00fe
    xori $4,$1, 0xff00
    xor  $1,$4, $1
    nor  $1,$3, $1       