	.text
	.file	"Test"
	.globl	cr                      # -- Begin function cr
	.p2align	4, 0x90
	.type	cr,@function
cr:                                     # @cr
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$.Lglobalstring.3, %edi
	callq	print_string
	popq	%rax
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end0:
	.size	cr, .Lfunc_end0-cr
	.cfi_endproc
                                        # -- End function
	.globl	displayList             # -- Begin function displayList
	.p2align	4, 0x90
	.type	displayList,@function
displayList:                            # @displayList
	.cfi_startproc
# %bb.0:                                # %entry
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movl	%edi, 16(%rsp)
	movl	%esi, 20(%rsp)
	movl	$0, 12(%rsp)
	movl	$.Lglobalstring.1, %edi
	callq	print_string
	movl	16(%rsp), %eax
	movl	%eax, 12(%rsp)
	jmp	.LBB1_1
	.p2align	4, 0x90
.LBB1_6:                                # %ifEnd
                                        #   in Loop: Header=BB1_1 Depth=1
	incl	12(%rsp)
.LBB1_1:                                # %for
                                        # =>This Inner Loop Header: Depth=1
	movl	16(%rsp), %eax
	addl	20(%rsp), %eax
	cmpl	%eax, 12(%rsp)
	jge	.LBB1_7
# %bb.2:                                # %do
                                        #   in Loop: Header=BB1_1 Depth=1
	movslq	12(%rsp), %rax
	movl	list(,%rax,4), %edi
	callq	print_int
	movl	$.Lglobalstring.2, %edi
	callq	print_string
	movl	12(%rsp), %eax
	subl	16(%rsp), %eax
	incl	%eax
	cltq
	imulq	$1717986919, %rax, %rcx # imm = 0x66666667
	movq	%rcx, %rdx
	shrq	$63, %rdx
	sarq	$35, %rcx
	addl	%edx, %ecx
	shll	$2, %ecx
	leal	(%rcx,%rcx,4), %ecx
	subl	%ecx, %eax
	sete	%cl
	je	.LBB1_4
# %bb.3:                                # %noSC
                                        #   in Loop: Header=BB1_1 Depth=1
	testl	%eax, %eax
	sete	%al
	movl	12(%rsp), %ecx
	incl	%ecx
	movl	16(%rsp), %edx
	addl	20(%rsp), %edx
	cmpl	%edx, %ecx
	sete	%cl
	orb	%al, %cl
.LBB1_4:                                # %scEnd
                                        #   in Loop: Header=BB1_1 Depth=1
	testb	%cl, %cl
	je	.LBB1_6
# %bb.5:                                # %ifTrue
                                        #   in Loop: Header=BB1_1 Depth=1
	callq	cr
	jmp	.LBB1_6
.LBB1_7:                                # %endfor
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end1:
	.size	displayList, .Lfunc_end1-displayList
	.cfi_endproc
                                        # -- End function
	.globl	initList                # -- Begin function initList
	.p2align	4, 0x90
	.type	initList,@function
initList:                               # @initList
	.cfi_startproc
# %bb.0:                                # %entry
	movl	%edi, -4(%rsp)
	movl	$0, -8(%rsp)
	jmp	.LBB2_1
	.p2align	4, 0x90
.LBB2_2:                                # %do
                                        #   in Loop: Header=BB2_1 Depth=1
	movslq	-8(%rsp), %rax
	imull	$2382983, %eax, %ecx    # imm = 0x245C87
	movslq	%ecx, %rcx
	imulq	$1374389535, %rcx, %rdx # imm = 0x51EB851F
	movq	%rdx, %rsi
	shrq	$63, %rsi
	sarq	$37, %rdx
	addl	%esi, %edx
	imull	$100, %edx, %edx
	subl	%edx, %ecx
	movl	%ecx, list(,%rax,4)
	incl	-8(%rsp)
.LBB2_1:                                # %for
                                        # =>This Inner Loop Header: Depth=1
	movl	-8(%rsp), %eax
	cmpl	-4(%rsp), %eax
	jl	.LBB2_2
# %bb.3:                                # %endfor
	retq
.Lfunc_end2:
	.size	initList, .Lfunc_end2-initList
	.cfi_endproc
                                        # -- End function
	.globl	swap                    # -- Begin function swap
	.p2align	4, 0x90
	.type	swap,@function
swap:                                   # @swap
	.cfi_startproc
# %bb.0:                                # %entry
	movl	%edi, -4(%rsp)
	movl	%esi, -8(%rsp)
	movl	$0, -12(%rsp)
	movslq	%edi, %rax
	movl	list(,%rax,4), %ecx
	movl	%ecx, -12(%rsp)
	movslq	%esi, %rdx
	movl	list(,%rdx,4), %esi
	movl	%esi, list(,%rax,4)
	movl	%ecx, list(,%rdx,4)
	retq
.Lfunc_end3:
	.size	swap, .Lfunc_end3-swap
	.cfi_endproc
                                        # -- End function
	.globl	quickSort               # -- Begin function quickSort
	.p2align	4, 0x90
	.type	quickSort,@function
quickSort:                              # @quickSort
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register %rbp
	pushq	%rbx
	pushq	%rax
	.cfi_offset %rbx, -24
	movl	%edi, -16(%rbp)
	movl	%esi, -12(%rbp)
	movl	-12(%rbp), %eax
	subl	-16(%rbp), %eax
	testl	%eax, %eax
	jle	.LBB4_2
# %bb.1:                                # %ifElse
	movq	%rsp, %rax
	leaq	-16(%rax), %rsp
	movl	$0, -16(%rax)
	movq	%rsp, %rbx
	leaq	-16(%rbx), %rsp
	movl	$0, -16(%rbx)
	movslq	-12(%rbp), %rcx
	movl	list(,%rcx,4), %edx
	movl	%edx, -16(%rax)
	movl	-16(%rbp), %edi
	movl	-12(%rbp), %esi
	callq	partition
                                        # kill: def $eax killed $eax def $rax
	movl	%eax, -16(%rbx)
	movl	-16(%rbp), %edi
	leal	-1(%rax), %esi
	callq	quickSort
	movl	-16(%rbx), %edi
	incl	%edi
	movl	-12(%rbp), %esi
	callq	quickSort
.LBB4_2:                                # %ifTrue
	leaq	-8(%rbp), %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa %rsp, 8
	retq
.Lfunc_end4:
	.size	quickSort, .Lfunc_end4-quickSort
	.cfi_endproc
                                        # -- End function
	.globl	main                    # -- Begin function main
	.p2align	4, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# %bb.0:                                # %entry
	pushq	%rax
	.cfi_def_cfa_offset 16
	movl	$100, 4(%rsp)
	movl	$100, %edi
	callq	initList
	movl	4(%rsp), %esi
	xorl	%edi, %edi
	callq	displayList
	movl	4(%rsp), %esi
	decl	%esi
	xorl	%edi, %edi
	callq	quickSort
	movl	$.Lglobalstring, %edi
	callq	print_string
	movl	4(%rsp), %esi
	xorl	%edi, %edi
	callq	displayList
	popq	%rax
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end5:
	.size	main, .Lfunc_end5-main
	.cfi_endproc
                                        # -- End function
	.globl	partition               # -- Begin function partition
	.p2align	4, 0x90
	.type	partition,@function
partition:                              # @partition
	.cfi_startproc
# %bb.0:                                # %entry
	subq	$24, %rsp
	.cfi_def_cfa_offset 32
	movl	%edi, 20(%rsp)
	movl	%esi, 16(%rsp)
	movl	%edx, 12(%rsp)
	decl	%edi
	movl	%edi, 4(%rsp)
	movl	%esi, 8(%rsp)
	jmp	.LBB6_1
.LBB6_6:                                # %ifElse
                                        #   in Loop: Header=BB6_1 Depth=1
	movl	4(%rsp), %edi
	movl	8(%rsp), %esi
	callq	swap
	.p2align	4, 0x90
.LBB6_1:                                # %while6
                                        # =>This Loop Header: Depth=1
                                        #     Child Loop BB6_2 Depth 2
	movl	4(%rsp), %eax
	incl	%eax
	movl	%eax, 4(%rsp)
	cltq
	movl	list(,%rax,4), %eax
	cmpl	12(%rsp), %eax
	jl	.LBB6_1
	.p2align	4, 0x90
.LBB6_2:                                # %while12
                                        #   Parent Loop BB6_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	cmpl	$0, 8(%rsp)
	jle	.LBB6_3
# %bb.5:                                # %ifEnd18
                                        #   in Loop: Header=BB6_2 Depth=2
	movl	8(%rsp), %eax
	decl	%eax
	movl	%eax, 8(%rsp)
	cltq
	movl	list(,%rax,4), %eax
	cmpl	12(%rsp), %eax
	jg	.LBB6_2
.LBB6_3:                                # %endWhile14
                                        #   in Loop: Header=BB6_1 Depth=1
	movl	4(%rsp), %eax
	cmpl	8(%rsp), %eax
	jl	.LBB6_6
# %bb.4:                                # %endWhile
	movl	4(%rsp), %edi
	movl	16(%rsp), %esi
	callq	swap
	movl	4(%rsp), %eax
	addq	$24, %rsp
	.cfi_def_cfa_offset 8
	retq
.Lfunc_end6:
	.size	partition, .Lfunc_end6-partition
	.cfi_endproc
                                        # -- End function
	.type	list,@object            # @list
	.bss
	.globl	list
	.p2align	4
list:
	.zero	400
	.size	list, 400

	.type	.Lglobalstring,@object  # @globalstring
	.section	.rodata.str1.1,"aMS",@progbits,1
.Lglobalstring:
	.asciz	"After sorting:\n"
	.size	.Lglobalstring, 16

	.type	.Lglobalstring.1,@object # @globalstring.1
.Lglobalstring.1:
	.asciz	"List:\n"
	.size	.Lglobalstring.1, 7

	.type	.Lglobalstring.2,@object # @globalstring.2
.Lglobalstring.2:
	.asciz	" "
	.size	.Lglobalstring.2, 2

	.type	.Lglobalstring.3,@object # @globalstring.3
.Lglobalstring.3:
	.asciz	"\n"
	.size	.Lglobalstring.3, 2


	.section	".note.GNU-stack","",@progbits
