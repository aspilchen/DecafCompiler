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
	movl	$0, 4(%rsp)
	movl	$5, (%rsp)
	movb	$1, %al
	testb	%al, %al
	jne	.LBB0_2
# %bb.1:                                # %noSC
	movl	$5, %eax
	cmpl	$6, %eax
	setl	%cl
	movl	(%rsp), %eax
	cltd
	idivl	4(%rsp)
	testl	%eax, %eax
	sete	%al
	orb	%cl, %al
.LBB0_2:                                # %scEnd
	testb	%al, %al
	je	.LBB0_3
# %bb.7:                                # %ifTrue
	movl	(%rsp), %edi
	callq	print_int
.LBB0_3:                                # %ifEnd
	cmpl	$5, (%rsp)
	setl	%al
	jge	.LBB0_5
# %bb.4:                                # %noSC9
	xorl	%eax, %eax
.LBB0_5:                                # %scEnd10
	testb	%al, %al
	je	.LBB0_6
# %bb.8:                                # %ifTrue6
	movl	4(%rsp), %edi
	callq	print_int
.LBB0_6:                                # %ifEnd12
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function

	.section	".note.GNU-stack","",@progbits
