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
	movl	$1, 4(%rsp)
	cmpl	$1, 4(%rsp)
	jne	.LBB0_2
# %bb.1:                                # %ifTrue
	movl	$1, %edi
	callq	print_int
	movl	4(%rsp), %edi
	callq	print_int
	movl	$2, %edi
	callq	print_int
.LBB0_2:                                # %ifEnd
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function

	.section	".note.GNU-stack","",@progbits
