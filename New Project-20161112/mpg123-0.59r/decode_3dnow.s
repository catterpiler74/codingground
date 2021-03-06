/ synth_1to1_3dnow works the same way as the c version of
/ synth_1to1. this assembler code based 'decode-i586.s'
/ (by Stefan Bieschewski <stb@acm.org>), two types of changes
/ have been made:
/ - use {MMX,3DNow!} instruction for reduce cpu 
/ - remove unused(?) local symbols
/
/ useful sources of information on optimizing 3DNow! code include:
/ AMD 3DNow! Technology Manual (Publication #21928)
/     English:  http://www.amd.com/K6/k6docs/pdf/21928d.pdf
/    (Japanese: http://www.amd.com/japan/K6/k6docs/j21928c.pdf)
/ AMD-K6-2 Processor Code Optimization Application Note (Publication #21924)
/     English:	http://www.amd.com/K6/k6docs/pdf/21924b.pdf
/
/ This code was tested only AMD-K6-2 processor Linux systems,
/ please tell me:
/ - whether this code works on other 3DNow! capable processors
/  (ex.IDT-C6-2) or not
/ - whether this code works on other OSes or not
/
/ by KIMURA Takuhiro <kim@hannah.ipc.miyakyo-u.ac.jp> - until 31.Mar.1998
/                    <kim@comtec.co.jp>               - after  1.Apr.1998

/ Enhancments for q-word operation by Michael Hipp

.bss
	.comm	buffs,4352,4
.data
	.align 4
bo:
	.long 1
.text
.globl synth_1to1_3dnow
synth_1to1_3dnow:
	subl $12,%esp
	pushl %ebp
	pushl %edi
	pushl %esi
	pushl %ebx
	movl 32(%esp),%eax
	movl 40(%esp),%esi
	movl $0,%edi
	movl bo,%ebp
	cmpl %edi,36(%esp)
	jne .L48
	decl %ebp
	andl $15,%ebp
	movl %ebp,bo
	movl $buffs,%ecx
	jmp .L49
.L48:
	addl $2,%esi
	movl $buffs+2176,%ecx
.L49:
	testl $1,%ebp
	je .L50
	movl %ecx,%ebx
	movl %ebp,16(%esp)
	pushl %eax
	movl 20(%esp),%edx
	leal (%ebx,%edx,4),%eax
	pushl %eax
	movl 24(%esp),%eax
	incl %eax
	andl $15,%eax
	leal 1088(,%eax,4),%eax
	addl %ebx,%eax
	jmp .L74
.L50:
	leal 1088(%ecx),%ebx
	leal 1(%ebp),%edx
	movl %edx,16(%esp)
	pushl %eax
	leal 1092(%ecx,%ebp,4),%eax
	pushl %eax
	leal (%ecx,%ebp,4),%eax
.L74:
	pushl %eax
	call dct64
	addl $12,%esp
	movl 16(%esp),%edx
	leal 0(,%edx,4),%edx
	movl $decwin+64,%eax
	movl %eax,%ecx
	subl %edx,%ecx
	movl $16,%ebp

.L55:
	movq (%ecx),%mm4
	movq (%ebx),%mm3
        movq 8(%ecx),%mm0
        movq 8(%ebx),%mm1
	pfmul %mm3,%mm4

        movq 16(%ecx),%mm2
        pfmul %mm1,%mm0
        movq 16(%ebx),%mm3
	pfadd %mm0,%mm4

        movq 24(%ecx),%mm0
        pfmul %mm2,%mm3
        movq 24(%ebx),%mm1
        pfadd %mm3,%mm4

        movq 32(%ecx),%mm2
        pfmul %mm1,%mm0
        movq 32(%ebx),%mm3
        pfadd %mm0,%mm4

        movq 40(%ecx),%mm0
        pfmul %mm2,%mm3
        movq 40(%ebx),%mm1
        pfadd %mm3,%mm4

        movq 48(%ecx),%mm2
        pfmul %mm1,%mm0
        movq 48(%ebx),%mm3
        pfadd %mm0,%mm4

        movq 56(%ecx),%mm0
        pfmul %mm2,%mm3
        movq 56(%ebx),%mm1
        pfadd %mm3,%mm4

        pfmul %mm1,%mm0
        pfadd %mm0,%mm4

	movq %mm4,%mm0
	psrlq $32,%mm0
	pfsub %mm0,%mm4

	pf2id %mm4,%mm4
	movd %mm4,%eax

	sar	$16,%eax	/ new clip
	movw %ax,(%esi)

	addl $64,%ebx
	subl $-128,%ecx
	addl $4,%esi
	decl %ebp
	jnz .L55

/ --- end of loop 1 ---

	movd (%ecx),%mm2
	movd (%ebx),%mm1
	pfmul %mm1,%mm2

	movd 8(%ecx),%mm0
	movd 8(%ebx),%mm1
	pfmul %mm0,%mm1
	pfadd %mm1,%mm2

        movd 16(%ecx),%mm0
        movd 16(%ebx),%mm1
        pfmul %mm0,%mm1
        pfadd %mm1,%mm2

        movd 24(%ecx),%mm0
        movd 24(%ebx),%mm1
        pfmul %mm0,%mm1
        pfadd %mm1,%mm2

        movd 32(%ecx),%mm0
        movd 32(%ebx),%mm1
        pfmul %mm0,%mm1
        pfadd %mm1,%mm2

        movd 40(%ecx),%mm0
        movd 40(%ebx),%mm1
        pfmul %mm0,%mm1
        pfadd %mm1,%mm2

        movd 48(%ecx),%mm0
        movd 48(%ebx),%mm1
        pfmul %mm0,%mm1
        pfadd %mm1,%mm2

        movd 56(%ecx),%mm0
        movd 56(%ebx),%mm1
        pfmul %mm0,%mm1
        pfadd %mm1,%mm2

	pf2id %mm2,%mm2
	movd %mm2,%eax

	sar $16,%eax	/ new clip

	movw %ax,(%esi)

	addl $-64,%ebx
	addl $4,%esi
	addl $256,%ecx
	movl $15,%ebp

.L68:
	psubd 	  %mm0,%mm0

	movq    (%ebx),%mm1
	movq    (%ecx),%mm2
	pfmul     %mm1,%mm2
	pfsub     %mm2,%mm0

	movq   8(%ebx),%mm3
	movq   8(%ecx),%mm4
	pfmul     %mm3,%mm4
	pfsub     %mm4,%mm0

        movq  16(%ebx),%mm1
        movq  16(%ecx),%mm2
        pfmul     %mm1,%mm2
        pfsub     %mm2,%mm0

        movq  24(%ebx),%mm3
        movq  24(%ecx),%mm4
        pfmul     %mm3,%mm4
        pfsub     %mm4,%mm0

        movq  32(%ebx),%mm1
        movq  32(%ecx),%mm2
        pfmul     %mm1,%mm2
        pfsub     %mm2,%mm0

        movq  40(%ebx),%mm3
        movq  40(%ecx),%mm4
        pfmul     %mm3,%mm4
        pfsub     %mm4,%mm0

        movq  48(%ebx),%mm1
        movq  48(%ecx),%mm2
        pfmul     %mm1,%mm2
        pfsub     %mm2,%mm0

        movq  56(%ebx),%mm3
        movq  56(%ecx),%mm4
        pfmul     %mm3,%mm4
        pfsub     %mm4,%mm0

	pfacc     %mm0,%mm0

	pf2id %mm0,%mm0
	movd %mm0,%eax

	sar $16,%eax	/ new clip

	movw %ax,(%esi)

	addl $-64,%ebx
	subl $-128,%ecx
	addl $4,%esi
	decl %ebp
	jnz .L68

/ --- end of loop 2

	femms

	movl %edi,%eax
	popl %ebx
	popl %esi
	popl %edi
	popl %ebp
	addl $12,%esp
	ret
