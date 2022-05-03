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
	xorl	%eax, %eax
	testb	%al, %al
	jne	.LBB0_2
# %bb.1:                                # %noSC4
	xorl	%eax, %eax
.LBB0_2:                                # %scEnd5
	xorl	%ecx, %ecx
	testb	%cl, %cl
	jne	.LBB0_4
# %bb.3:                                # %noSC13
	movb	$1, %al
.LBB0_4:                                # %scEnd14
	testb	%al, %al
	je	.LBB0_8
# %bb.5:                                # %ifTrue
	xorl	%eax, %eax
	testb	%al, %al
	jne	.LBB0_7
# %bb.6:                                # %ifTrue
	movb	$1, %al
	testb	%al, %al
	je	.LBB0_8
.LBB0_7:                                # %ifTrue18
	movl	$.Lglobalstring, %edi
	callq	print_string
.LBB0_8:                                # %ifEnd
	movl	$.Lglobalstring.2, %edi
	callq	print_string
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	.Lglobalstring,@object  # @globalstring
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lglobalstring:
	.asciz	"O"
	.size	.Lglobalstring, 2

	.type	.Lglobalstring.1,@object # @globalstring.1
.Lglobalstring.1:
	.asciz	"NO"
	.size	.Lglobalstring.1, 3

	.type	.Lglobalstring.2,@object # @globalstring.2
.Lglobalstring.2:
	.asciz	"K"
	.size	.Lglobalstring.2, 2


	.section	".note.GNU-stack","",@progbits
