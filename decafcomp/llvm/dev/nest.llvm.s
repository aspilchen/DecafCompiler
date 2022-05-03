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
	movl	$0, 4(%rsp)
	movl	$0, 8(%rsp)
	movl	$0, 12(%rsp)
	movl	$0, 16(%rsp)
	movl	$0, 20(%rsp)
	movl	$.Lglobalstring, %edi
	callq	print_string
	movl	$0, 20(%rsp)
	movl	$0, 4(%rsp)
	cmpl	$9, 4(%rsp)
	jle	.LBB0_2
	jmp	.LBB0_34
	.p2align	4, 0x90
.LBB0_3:                                # %increment
                                        #   in Loop: Header=BB0_2 Depth=1
	incl	4(%rsp)
	cmpl	$9, 4(%rsp)
	jg	.LBB0_34
.LBB0_2:                                # %do
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_6 Depth 2
                                        #       Child Loop BB0_11 Depth 3
                                        #         Child Loop BB0_18 Depth 4
	cmpl	$5, 4(%rsp)
	je	.LBB0_3
# %bb.4:                                # %ifEnd
                                        #   in Loop: Header=BB0_2 Depth=1
	movl	$0, 8(%rsp)
	cmpl	$9, 8(%rsp)
	jle	.LBB0_6
	jmp	.LBB0_33
	.p2align	4, 0x90
.LBB0_44:                               # %increment5
                                        #   in Loop: Header=BB0_6 Depth=2
	incl	8(%rsp)
	cmpl	$9, 8(%rsp)
	jg	.LBB0_33
.LBB0_6:                                # %do4
                                        #   Parent Loop BB0_2 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB0_11 Depth 3
                                        #         Child Loop BB0_18 Depth 4
	movl	4(%rsp), %eax
	cmpl	$2, %eax
	sete	%cl
	jne	.LBB0_8
# %bb.7:                                # %noSC
                                        #   in Loop: Header=BB0_6 Depth=2
	xorl	$2, %eax
	movl	8(%rsp), %ecx
	xorl	$4, %ecx
	orl	%eax, %ecx
	sete	%cl
.LBB0_8:                                # %scEnd
                                        #   in Loop: Header=BB0_6 Depth=2
	testb	%cl, %cl
	jne	.LBB0_44
# %bb.9:                                # %ifEnd15
                                        #   in Loop: Header=BB0_6 Depth=2
	movl	$0, 12(%rsp)
	cmpl	$9, 12(%rsp)
	jle	.LBB0_11
	jmp	.LBB0_41
	.p2align	4, 0x90
.LBB0_40:                               # %increment18
                                        #   in Loop: Header=BB0_11 Depth=3
	incl	12(%rsp)
	cmpl	$9, 12(%rsp)
	jg	.LBB0_41
.LBB0_11:                               # %do17
                                        #   Parent Loop BB0_2 Depth=1
                                        #     Parent Loop BB0_6 Depth=2
                                        # =>    This Loop Header: Depth=3
                                        #         Child Loop BB0_18 Depth 4
	movl	4(%rsp), %ecx
	cmpl	$8, %ecx
	sete	%al
	je	.LBB0_12
# %bb.13:                               # %scEnd27
                                        #   in Loop: Header=BB0_11 Depth=3
	testb	%al, %al
	jne	.LBB0_14
.LBB0_15:                               # %scEnd33
                                        #   in Loop: Header=BB0_11 Depth=3
	testb	%al, %al
	jne	.LBB0_40
	jmp	.LBB0_16
	.p2align	4, 0x90
.LBB0_12:                               # %noSC26
                                        #   in Loop: Header=BB0_11 Depth=3
	xorl	$8, %ecx
	movl	8(%rsp), %eax
	xorl	$1, %eax
	orl	%ecx, %eax
	sete	%al
	testb	%al, %al
	je	.LBB0_15
.LBB0_14:                               # %noSC32
                                        #   in Loop: Header=BB0_11 Depth=3
	cmpl	$3, 12(%rsp)
	sete	%cl
	andb	%cl, %al
	testb	%al, %al
	jne	.LBB0_40
.LBB0_16:                               # %ifEnd38
                                        #   in Loop: Header=BB0_11 Depth=3
	movl	$0, 16(%rsp)
	cmpl	$9, 16(%rsp)
	jle	.LBB0_18
	jmp	.LBB0_35
	.p2align	4, 0x90
.LBB0_32:                               # %increment41
                                        #   in Loop: Header=BB0_18 Depth=4
	incl	16(%rsp)
	cmpl	$9, 16(%rsp)
	jg	.LBB0_35
.LBB0_18:                               # %do40
                                        #   Parent Loop BB0_2 Depth=1
                                        #     Parent Loop BB0_6 Depth=2
                                        #       Parent Loop BB0_11 Depth=3
                                        # =>      This Inner Loop Header: Depth=4
	movl	4(%rsp), %ecx
	cmpl	$1, %ecx
	sete	%al
	je	.LBB0_19
# %bb.20:                               # %scEnd50
                                        #   in Loop: Header=BB0_18 Depth=4
	testb	%al, %al
	jne	.LBB0_21
.LBB0_22:                               # %scEnd56
                                        #   in Loop: Header=BB0_18 Depth=4
	testb	%al, %al
	jne	.LBB0_23
.LBB0_24:                               # %scEnd62
                                        #   in Loop: Header=BB0_18 Depth=4
	testb	%al, %al
	jne	.LBB0_32
	jmp	.LBB0_25
	.p2align	4, 0x90
.LBB0_19:                               # %noSC49
                                        #   in Loop: Header=BB0_18 Depth=4
	xorl	$1, %ecx
	movl	8(%rsp), %eax
	xorl	$7, %eax
	orl	%ecx, %eax
	sete	%al
	testb	%al, %al
	je	.LBB0_22
.LBB0_21:                               # %noSC55
                                        #   in Loop: Header=BB0_18 Depth=4
	cmpl	$4, 12(%rsp)
	sete	%cl
	andb	%cl, %al
	testb	%al, %al
	je	.LBB0_24
.LBB0_23:                               # %noSC61
                                        #   in Loop: Header=BB0_18 Depth=4
	cmpl	$1, 16(%rsp)
	sete	%cl
	andb	%cl, %al
	testb	%al, %al
	jne	.LBB0_32
.LBB0_25:                               # %ifEnd67
                                        #   in Loop: Header=BB0_18 Depth=4
	incl	20(%rsp)
	movl	4(%rsp), %ecx
	cmpl	$3, %ecx
	sete	%al
	je	.LBB0_26
# %bb.27:                               # %scEnd74
                                        #   in Loop: Header=BB0_18 Depth=4
	testb	%al, %al
	jne	.LBB0_28
.LBB0_29:                               # %scEnd80
                                        #   in Loop: Header=BB0_18 Depth=4
	testb	%al, %al
	jne	.LBB0_30
.LBB0_31:                               # %scEnd86
                                        #   in Loop: Header=BB0_18 Depth=4
	testb	%al, %al
	je	.LBB0_32
	jmp	.LBB0_35
	.p2align	4, 0x90
.LBB0_26:                               # %noSC73
                                        #   in Loop: Header=BB0_18 Depth=4
	xorl	$3, %ecx
	movl	8(%rsp), %eax
	xorl	$2, %eax
	orl	%ecx, %eax
	sete	%al
	testb	%al, %al
	je	.LBB0_29
.LBB0_28:                               # %noSC79
                                        #   in Loop: Header=BB0_18 Depth=4
	cmpl	$6, 12(%rsp)
	sete	%cl
	andb	%cl, %al
	testb	%al, %al
	je	.LBB0_31
.LBB0_30:                               # %noSC85
                                        #   in Loop: Header=BB0_18 Depth=4
	cmpl	$4, 16(%rsp)
	sete	%cl
	andb	%cl, %al
	testb	%al, %al
	je	.LBB0_32
	.p2align	4, 0x90
.LBB0_35:                               # %endfor42
                                        #   in Loop: Header=BB0_11 Depth=3
	movl	4(%rsp), %ecx
	cmpl	$2, %ecx
	sete	%al
	je	.LBB0_36
# %bb.37:                               # %scEnd99
                                        #   in Loop: Header=BB0_11 Depth=3
	testb	%al, %al
	jne	.LBB0_38
.LBB0_39:                               # %scEnd105
                                        #   in Loop: Header=BB0_11 Depth=3
	testb	%al, %al
	je	.LBB0_40
	jmp	.LBB0_41
	.p2align	4, 0x90
.LBB0_36:                               # %noSC98
                                        #   in Loop: Header=BB0_11 Depth=3
	xorl	$2, %ecx
	movl	8(%rsp), %eax
	xorl	$7, %eax
	orl	%ecx, %eax
	sete	%al
	testb	%al, %al
	je	.LBB0_39
.LBB0_38:                               # %noSC104
                                        #   in Loop: Header=BB0_11 Depth=3
	cmpl	$2, 12(%rsp)
	sete	%cl
	andb	%cl, %al
	testb	%al, %al
	je	.LBB0_40
	.p2align	4, 0x90
.LBB0_41:                               # %endfor19
                                        #   in Loop: Header=BB0_6 Depth=2
	movl	4(%rsp), %eax
	cmpl	$9, %eax
	sete	%cl
	jne	.LBB0_43
# %bb.42:                               # %noSC117
                                        #   in Loop: Header=BB0_6 Depth=2
	xorl	$9, %eax
	movl	8(%rsp), %ecx
	xorl	$1, %ecx
	orl	%eax, %ecx
	sete	%cl
.LBB0_43:                               # %scEnd118
                                        #   in Loop: Header=BB0_6 Depth=2
	testb	%cl, %cl
	je	.LBB0_44
.LBB0_33:                               # %endfor6
                                        #   in Loop: Header=BB0_2 Depth=1
	cmpl	$9, 4(%rsp)
	jne	.LBB0_3
.LBB0_34:                               # %endfor
	movl	20(%rsp), %edi
	callq	print_int
	xorl	%eax, %eax
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	main, .Lfunc_end0-main
	.cfi_endproc
                                        # -- End function
	.type	.Lglobalstring,@object  # @globalstring
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lglobalstring:
	.asciz	"hello\n"
	.size	.Lglobalstring, 7


	.section	".note.GNU-stack","",@progbits
