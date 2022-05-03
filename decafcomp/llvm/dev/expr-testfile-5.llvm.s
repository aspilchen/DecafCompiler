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
	movb	$0, 5(%rsp)
	movb	$1, 7(%rsp)
	movb	$1, 6(%rsp)
	movb	$1, %al
	xorl	%ecx, %ecx
	testb	%cl, %cl
	jne	.LBB0_2
# %bb.1:                                # %noSC
	andb	6(%rsp), %al
.LBB0_2:                                # %scEnd
	movb	%al, 5(%rsp)
	movzbl	%al, %edi
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
