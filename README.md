# Educational Original Mips Cpu(EOMC)
---
In this project, I will learn how to make a simple Cpu based on mips ISA.
# Inst
## ORI
## logic-shift
## move
## arithmetic-simp-madd-msub
## arithmetic-div
## jump-branch
## load-store
## load-store-loadrelate
## load-store-ll-sc
## coprocessor
## exception
### about self trap:
**Note:**
in self trap, if run with iverilog+gtkwave, its wave will show error when reg1 is 0x9000, the right result should not be in self-trap, but in test, the opposite is true. I run the same code in modelsim, its wave is correct, though. I think it may be the iverilog's fault since I have run successfully in modelsim. 