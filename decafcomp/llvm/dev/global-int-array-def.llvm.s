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
	movl	$2, foo+12(%rip)
	movl	$2, 4(%rsp)
	movl	$2, %edi
	callq	print_int
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	foo,@object             # @foo
	.bss
	.globl	foo
	.p2align	4
foo:
	.zero	20
	.size	foo, 20


	.section	".note.GNU-stack","",@progbits
