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
	movl	$3, 20(%rsp)
	movl	$7, 16(%rsp)
	movb	$1, 11(%rsp)
	movl	$-3, 12(%rsp)
	xorl	%eax, %eax
	testb	%al, %al
	jne	.LBB0_2
# %bb.1:                                # %ifTrue
	movl	20(%rsp), %edi
	callq	print_int
	movl	16(%rsp), %edi
	callq	print_int
	movzbl	11(%rsp), %edi
	callq	print_int
	movl	12(%rsp), %edi
	callq	print_int
.LBB0_2:                                # %ifEnd
	xorl	%eax, %eax
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function

	.section	".note.GNU-stack","",@progbits
