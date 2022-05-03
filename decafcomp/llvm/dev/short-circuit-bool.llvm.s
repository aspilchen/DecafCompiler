	.text
	.file	"Test"
	.globl	foo                     # -- Begin function foo
	.p2align	4, 0x90
	.type	foo,@function
foo:                                    # @foo
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	%edi, 4(%rsp)
	movl	$.Lglobalstring.1, %edi
	callq	print_string
	cmpl	$200, 4(%rsp)
	setg	%al
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	foo, .Lfunc_end0-foo
	.cfi_endproc
                                        # -- End function
	.globl	bar                     # -- Begin function bar
	.p2align	4, 0x90
	.type	bar,@function
bar:                                    # @bar
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	%edi, 4(%rsp)
	movl	%esi, (%rsp)
	movl	$.Lglobalstring, %edi
	callq	print_string
	movl	4(%rsp), %eax
	cmpl	(%rsp), %eax
	setne	%al
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	bar, .Lfunc_end1-bar
	.cfi_endproc
                                        # -- End function
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	pushq	%rbx
	.cfi_def_cfa_offset 24
	subq	$24, %rsp
	.cfi_def_cfa_offset 48
	.cfi_offset %rbx, -24
	.cfi_offset %rbp, -16
	movb	$0, 15(%rsp)
	movl	$99, 16(%rsp)
	movl	$201, 20(%rsp)
	movb	$1, %al
	testb	%al, %al
	jne	.LBB2_4
# %bb.1:                                # %noSC
	movl	$99, %ebp
	movl	16(%rsp), %edi
	callq	foo
	movl	%eax, %ebx
	testb	$1, %al
	je	.LBB2_3
# %bb.2:                                # %noSC3
	movl	16(%rsp), %edi
	movl	20(%rsp), %esi
	callq	bar
	andb	%al, %bl
.LBB2_3:                                # %scEnd4
	cmpl	$100, %ebp
	setl	%al
	orb	%bl, %al
.LBB2_4:                                # %scEnd
	testb	$1, %al
	movzbl	%al, %edi
	andb	$1, %al
	movb	%al, 15(%rsp)
	andl	$1, %edi
	callq	print_int
	xorl	%eax, %eax
	addq	$24, %rsp
	.cfi_def_cfa_offset 24
	popq	%rbx
	.cfi_def_cfa_offset 16
	popq	%rbp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end2:
	.size	main, .Lfunc_end2-main
	.cfi_endproc
                                        # -- End function
	.type	.Lglobalstring,@object  # @globalstring
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lglobalstring:
	.asciz	"bar"
	.size	.Lglobalstring, 4

	.type	.Lglobalstring.1,@object # @globalstring.1
.Lglobalstring.1:
	.asciz	"foo"
	.size	.Lglobalstring.1, 4


	.section	".note.GNU-stack","",@progbits
