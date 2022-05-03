	.text
	.file	"Test"
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movb	$0, 2(%rsp)
	movl	$-958, 4(%rsp)          # imm = 0xFC42
	movb	$1, 3(%rsp)
	movb	$1, %al
	testb	%al, %al
	jne	.LBB0_2
# %bb.1:                                # %noSC3
	orb	2(%rsp), %al
.LBB0_2:                                # %scEnd4
	andb	$1, %al
	movb	%al, 3(%rsp)
	xorl	%edi, %edi
	subl	4(%rsp), %edi
	callq	print_int
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function

	.section	".note.GNU-stack","",@progbits
