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
	xorl	%edi, %edi
	callq	print_int
	movl	$12345, 4(%rsp)         # imm = 0x3039
	movl	$12345, %edi            # imm = 0x3039
	callq	print_int
	movl	$-12345, 4(%rsp)        # imm = 0xCFC7
	movl	$-12345, %edi           # imm = 0xCFC7
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
