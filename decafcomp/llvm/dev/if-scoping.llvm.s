	.text
	.file	"Test"
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	subq	$16, %rsp
	movl	$0, -4(%rbp)
	movl	$.Lglobalstring, %edi
	callq	print_string
	movl	$0, -4(%rbp)
	xorl	%eax, %eax
	testb	%al, %al
	jne	.LBB0_2
# %bb.1:                                # %ifTrue
	movq	%rsp, %rax
	leaq	-16(%rax), %rsp
	movl	$2, -16(%rax)
.LBB0_2:                                # %ifEnd
	cmpl	$2, -4(%rbp)
	jg	.LBB0_4
# %bb.3:                                # %ifElse
	movq	%rsp, %rax
	leaq	-16(%rax), %rsp
	movl	$6, -16(%rax)
.LBB0_4:                                # %ifEnd6
	movl	-4(%rbp), %edi
	callq	print_int
	movl	$.Lglobalstring.1, %edi
	callq	print_string
	xorl	%eax, %eax
	movq	%rbp, %rsp
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	fin,@object             # @fin
	.bss
	.globl	fin
	.p2align	4
fin:
	.zero	80
	.size	fin, 80

	.type	.Lglobalstring,@object  # @globalstring
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lglobalstring:
	.asciz	"hello\n"
	.size	.Lglobalstring, 7

	.type	.Lglobalstring.1,@object # @globalstring.1
.Lglobalstring.1:
	.asciz	",\r\n"
	.size	.Lglobalstring.1, 4


	.section	".note.GNU-stack","",@progbits
