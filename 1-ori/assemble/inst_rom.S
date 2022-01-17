.org 0x0
.global _start
.set noat //允许使用寄存器$1
_start:
    ori $1,$0,0x1100        #$1 = $0 | 0x1100 = 0x1100
    ori $2,$0,0x0020        #$1 = $0 | 0x0020 = 0x0020   
    ori $3,$0,0xff00        #$1 = $0 | 0xff00 = 0xff00
    ori $4,$0,0xffff        #$1 = $0 | 0xffff = 0xffff