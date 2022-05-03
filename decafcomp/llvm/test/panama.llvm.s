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
	pushq	%r14
	pushq	%rbx
	.cfi_offset %rbx, -32
	.cfi_offset %r14, -24
	movl	$1, %edi
	callq	a
	movl	%eax, %ebx
	testb	$1, %al
	jne	.LBB0_4
# %bb.1:                                # %noSC1
	callq	man
                                        # kill: def $al killed $al def $eax
	testb	$1, %al
	je	.LBB0_3
# %bb.2:                                # %noSC4
	xorl	%eax, %eax
.LBB0_3:                                # %scEnd5
	orb	%al, %bl
.LBB0_4:                                # %scEnd2
	testb	$1, %bl
	je	.LBB0_9
# %bb.5:                                # %ifTrue
	movl	$.Lglobalstring.13, %edi
	jmp	.LBB0_6
.LBB0_9:                                # %ifElse
	movl	$.Lglobalstring.6, %edi
	callq	print_string
	xorl	%edi, %edi
	callq	a
	movl	%eax, %ebx
	testb	$1, %al
	je	.LBB0_11
# %bb.10:                               # %noSC12
	callq	canal
	andb	%al, %bl
.LBB0_11:                               # %scEnd13
	testb	$1, %bl
	je	.LBB0_12
# %bb.8:                                # %ifTrue10
	movl	$.Lglobalstring.12, %edi
	jmp	.LBB0_6
.LBB0_12:                               # %ifElse17
	callq	plan
	xorl	%ecx, %ecx
	testb	%cl, %cl
	jne	.LBB0_19
# %bb.13:                               # %ifElse17
	testb	$1, %al
	je	.LBB0_19
# %bb.14:                               # %ifTrue28
	movq	%rsp, %rax
	leaq	-16(%rax), %r14
	movq	%r14, %rsp
	movb	$1, -16(%rax)
	jmp	.LBB0_15
	.p2align	4, 0x90
.LBB0_18:                               # %do76
                                        #   in Loop: Header=BB0_15 Depth=1
	movl	$.Lglobalstring.11, %edi
	callq	print_string
	movb	$0, (%r14)
.LBB0_15:                               # %while75
                                        # =>This Inner Loop Header: Depth=1
	movzbl	(%r14), %ebx
	testb	%bl, %bl
	je	.LBB0_17
# %bb.16:                               # %noSC79
                                        #   in Loop: Header=BB0_15 Depth=1
	callq	canal
	andb	%al, %bl
.LBB0_17:                               # %scEnd80
                                        #   in Loop: Header=BB0_15 Depth=1
	testb	%bl, %bl
	jne	.LBB0_18
	jmp	.LBB0_7
.LBB0_19:                               # %ifElse37
	movl	$.Lglobalstring.7, %edi
	callq	print_string
	xorl	%edi, %edi
	callq	a
	testb	$1, %al
	testb	$1, %al
	je	.LBB0_20
# %bb.28:                               # %ifTrue40
	movl	$.Lglobalstring.10, %edi
.LBB0_6:                                # %ifEnd
	callq	print_string
.LBB0_7:                                # %ifEnd
	xorl	%eax, %eax
	leaq	-16(%rbp), %rsp
	popq	%rbx
	popq	%r14
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.LBB0_20:                               # %ifElse49
	.cfi_def_cfa %rbp, 16
	callq	canal
	movl	%eax, %ebx
	testb	$1, %al
	jne	.LBB0_22
# %bb.21:                               # %noSC62
	callq	man
	orb	%al, %bl
.LBB0_22:                               # %scEnd63
	testb	$1, %bl
	je	.LBB0_7
# %bb.23:                               # %ifTrue52
	movq	%rsp, %rbx
	leaq	-16(%rbx), %r14
	movq	%r14, %rsp
	movb	$0, -16(%rbx)
	movl	$.Lglobalstring.8, %edi
	callq	print_string
	movb	$1, -16(%rbx)
	jmp	.LBB0_24
	.p2align	4, 0x90
.LBB0_27:                               # %do
                                        #   in Loop: Header=BB0_24 Depth=1
	movb	$0, (%r14)
	movl	$.Lglobalstring.9, %edi
	callq	print_string
.LBB0_24:                               # %while
                                        # =>This Inner Loop Header: Depth=1
	movzbl	(%r14), %ebx
	testb	%bl, %bl
	je	.LBB0_26
# %bb.25:                               # %noSC69
                                        #   in Loop: Header=BB0_24 Depth=1
	callq	panama
	andb	%al, %bl
.LBB0_26:                               # %scEnd70
                                        #   in Loop: Header=BB0_24 Depth=1
	testb	%bl, %bl
	jne	.LBB0_27
	jmp	.LBB0_7
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.globl	man                     # -- Begin function man
	.p2align	4, 0x90
	.type	man,@function
man:                                    # @man
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$.Lglobalstring.5, %edi
	callq	print_string
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	man, .Lfunc_end1-man
	.cfi_endproc
                                        # -- End function
	.globl	plan                    # -- Begin function plan
	.p2align	4, 0x90
	.type	plan,@function
plan:                                   # @plan
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$.Lglobalstring.4, %edi
	callq	print_string
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end2:
	.size	plan, .Lfunc_end2-plan
	.cfi_endproc
                                        # -- End function
	.globl	a                       # -- Begin function a
	.p2align	4, 0x90
	.type	a,@function
a:                                      # @a
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	andl	$1, %edi
	movb	%dil, 7(%rsp)
	cmpb	$1, 7(%rsp)
	jne	.LBB3_2
# %bb.1:                                # %ifTrue
	movl	$.Lglobalstring.3, %edi
	jmp	.LBB3_3
.LBB3_2:                                # %ifElse
	movl	$.Lglobalstring.2, %edi
.LBB3_3:                                # %ifEnd
	callq	print_string
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end3:
	.size	a, .Lfunc_end3-a
	.cfi_endproc
                                        # -- End function
	.globl	canal                   # -- Begin function canal
	.p2align	4, 0x90
	.type	canal,@function
canal:                                  # @canal
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$.Lglobalstring.1, %edi
	callq	print_string
	movb	$1, %al
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end4:
	.size	canal, .Lfunc_end4-canal
	.cfi_endproc
                                        # -- End function
	.globl	panama                  # -- Begin function panama
	.p2align	4, 0x90
	.type	panama,@function
panama:                                 # @panama
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$.Lglobalstring, %edi
	callq	print_string
	xorl	%eax, %eax
	popq	%rcx
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end5:
	.size	panama, .Lfunc_end5-panama
	.cfi_endproc
                                        # -- End function
	.type	.Lglobalstring,@object  # @globalstring
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lglobalstring:
	.asciz	"Panama"
	.size	.Lglobalstring, 7

	.type	.Lglobalstring.1,@object # @globalstring.1
.Lglobalstring.1:
	.asciz	"canal"
	.size	.Lglobalstring.1, 6

	.type	.Lglobalstring.2,@object # @globalstring.2
.Lglobalstring.2:
	.asciz	"a "
	.size	.Lglobalstring.2, 3

	.type	.Lglobalstring.3,@object # @globalstring.3
.Lglobalstring.3:
	.asciz	"A "
	.size	.Lglobalstring.3, 3

	.type	.Lglobalstring.4,@object # @globalstring.4
.Lglobalstring.4:
	.asciz	"plan"
	.size	.Lglobalstring.4, 5

	.type	.Lglobalstring.5,@object # @globalstring.5
.Lglobalstring.5:
	.asciz	"man"
	.size	.Lglobalstring.5, 4

	.type	.Lglobalstring.6,@object # @globalstring.6
.Lglobalstring.6:
	.asciz	", "
	.size	.Lglobalstring.6, 3

	.type	.Lglobalstring.7,@object # @globalstring.7
.Lglobalstring.7:
	.asciz	", "
	.size	.Lglobalstring.7, 3

	.type	.Lglobalstring.8,@object # @globalstring.8
.Lglobalstring.8:
	.asciz	"--"
	.size	.Lglobalstring.8, 3

	.type	.Lglobalstring.9,@object # @globalstring.9
.Lglobalstring.9:
	.asciz	"!"
	.size	.Lglobalstring.9, 2

	.type	.Lglobalstring.10,@object # @globalstring.10
.Lglobalstring.10:
	.asciz	"bash"
	.size	.Lglobalstring.10, 5

	.type	.Lglobalstring.11,@object # @globalstring.11
.Lglobalstring.11:
	.asciz	"bar"
	.size	.Lglobalstring.11, 4

	.type	.Lglobalstring.12,@object # @globalstring.12
.Lglobalstring.12:
	.asciz	"foo"
	.size	.Lglobalstring.12, 4

	.type	.Lglobalstring.13,@object # @globalstring.13
.Lglobalstring.13:
	.asciz	"wat"
	.size	.Lglobalstring.13, 4


	.section	".note.GNU-stack","",@progbits
