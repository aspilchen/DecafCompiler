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
	movl	$-14, 4(%rsp)
	movl	$13, (%rsp)
	movl	$-14, %edi
	callq	print_int
	movl	$.Lglobalstring, %edi
	callq	print_string
	movl	(%rsp), %edi
	callq	print_int
	movl	$.Lglobalstring.1, %edi
	callq	print_string
	movl	4(%rsp), %eax
	cltd
	idivl	(%rsp)
	movl	%eax, %edi
	callq	print_int
	movl	$.Lglobalstring.2, %edi
	callq	print_string
	movl	4(%rsp), %ecx
	imull	$10000000, %ecx, %eax   # imm = 0x989680
	movl	(%rsp), %esi
	cltd
	idivl	%esi
	movl	%eax, %edi
	movl	%ecx, %eax
	cltd
	idivl	%esi
	imull	$10000000, %eax, %eax   # imm = 0x989680
	subl	%eax, %edi
	callq	abs
	movl	%eax, %edi
	callq	print_int
	movl	$.Lglobalstring.3, %edi
	callq	print_string
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.globl	abs                     # -- Begin function abs
	.p2align	4, 0x90
	.type	abs,@function
abs:                                    # @abs
	.cfi_startproc
# %bb.0:                                # %entry
	movl	%edi, -4(%rsp)
	cmpl	$0, -4(%rsp)
	jle	.LBB1_2
# %bb.1:                                # %ifTrue
	movl	-4(%rsp), %eax
	retq
.LBB1_2:                                # %ifEnd
	xorl	%eax, %eax
	subl	-4(%rsp), %eax
	retq
.Lfunc_end1:
	.size	abs, .Lfunc_end1-abs
	.cfi_endproc
                                        # -- End function
	.type	.Lglobalstring,@object  # @globalstring
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lglobalstring:
	.asciz	"/"
	.size	.Lglobalstring, 2

	.type	.Lglobalstring.1,@object # @globalstring.1
.Lglobalstring.1:
	.asciz	" = "
	.size	.Lglobalstring.1, 4

	.type	.Lglobalstring.2,@object # @globalstring.2
.Lglobalstring.2:
	.asciz	"."
	.size	.Lglobalstring.2, 2

	.type	.Lglobalstring.3,@object # @globalstring.3
.Lglobalstring.3:
	.asciz	"\n"
	.size	.Lglobalstring.3, 2


	.section	".note.GNU-stack","",@progbits
