	.text
	.file	"Test"
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movb	$0, 15(%rsp)
	movb	$0, 14(%rsp)
	movl	$0, 16(%rsp)
	movb	$1, 23(%rsp)
	movb	$1, 13(%rsp)
	movb	$1, %al
	testb	%al, %al
	jne	.LBB0_4
# %bb.1:                                # %noSC
	movb	14(%rsp), %cl
	testb	%cl, %cl
	je	.LBB0_3
# %bb.2:                                # %noSC3
	movb	13(%rsp), %dl
	xorb	$1, %dl
	andb	%dl, %cl
.LBB0_3:                                # %scEnd4
	orb	%cl, %al
.LBB0_4:                                # %scEnd
	movb	%al, 15(%rsp)
	movl	$0, 16(%rsp)
	cmpl	$0, 16(%rsp)
	js	.LBB0_6
# %bb.5:                                # %ifTrue
	movl	16(%rsp), %edi
	callq	print_int
.LBB0_6:                                # %ifEnd
	xorl	%eax, %eax
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function

	.section	".note.GNU-stack","",@progbits
