# 这一节成功跑过的部分
在书上p266页中的指令

lw $1 0x8($0)
lwl $1 0x5($0)
在lw这条指令之前(以及lw), 没有问题
# 这一节没通过的部分
lwl没有访问到lw保存到寄存器1中的内容.
