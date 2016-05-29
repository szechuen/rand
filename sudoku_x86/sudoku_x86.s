.data

puzzle:
	.long	row0, row1, row2, row3, row4, row5, row6, row7, row8

# Sample puzzle from https://projecteuler.net/problem=96

row0:	.long	0,0,3,0,2,0,6,0,0
row1:	.long	9,0,0,3,0,5,0,0,1
row2:	.long	0,0,1,8,0,6,4,0,0
row3:	.long	0,0,8,1,0,2,9,0,0
row4:	.long	7,0,0,0,0,0,0,0,8
row5:	.long	0,0,6,7,0,8,2,0,0
row6:	.long	0,0,2,6,0,9,5,0,0
row7:	.long	8,0,0,2,0,3,0,0,9
row8:	.long	0,0,5,0,1,0,3,0,0

row:
	.long	0x01FF, 0x01FF, 0x01FF, 0x01FF, 0x01FF, 0x01FF, 0x01FF, 0x01FF, 0x01FF
col:
	.long	0x01FF, 0x01FF, 0x01FF, 0x01FF, 0x01FF, 0x01FF, 0x01FF, 0x01FF, 0x01FF
box:
	.long	0x01FF, 0x01FF, 0x01FF, 0x01FF, 0x01FF, 0x01FF, 0x01FF, 0x01FF, 0x01FF

mask:
	.long	0xFFFF, 0xFFFE, 0xFFFD, 0xFFFB, 0xFFF7, 0xFFEF, 0xFFDF, 0xFFBF, 0xFF7F, 0xFEFF
reset:
	.long	0x0000, 0x0001, 0x0002, 0x0004, 0x0008, 0x0010, 0x0020, 0x0040, 0x0080, 0x0100

box_index:
	.long	0, 0, 0, 1, 1, 1, 2, 2, 2
box_lookup:
	.byte	0, 1, 2, 0, 3, 4, 5, 0, 6, 7, 8, 0

.text

# int main()

.globl	_main
_main:
	pushl	%ebp
	movl	%esp, %ebp

	pushl	%ebx
	pushl	%esi
	pushl	%edi


	pushl	%eax
	pushl	%ecx
	pushl	%edx

	call	load_puzzle

	popl	%edx
	popl	%ecx
	popl	%eax


	pushl	%eax
	pushl	%ecx
	pushl	%edx

	pushl	$-1
	pushl	$0

	call	solve

	addl	$8, %esp

	popl	%edx
	popl	%ecx
	addl	$4, %esp

	# Return value from solve()

	popl	%edi
	popl	%esi
	popl	%ebx

	popl	%ebp
cp:
	retl

# int load_puzzle()

load_puzzle:
	pushl	%ebp
	movl	%esp, %ebp

	pushl	%ebx
	pushl	%esi
	pushl	%edi


	xorl	%ecx, %ecx

load_row:
	xorl	%edx, %edx

load_col:
	movl	puzzle(,%ecx,4), %eax
	movl	(%eax,%edx,4), %eax
	movl	mask(,%eax,4), %eax

	andl	%eax, row(,%ecx,4)

	andl	%eax, col(,%edx,4)

	movl	box_index(,%ecx,4), %esi
	movl	box_index(,%edx,4), %edi
	xorl	%ebx, %ebx
	movb	box_lookup(%edi,%esi,4), %bl

	andl	%eax, box(,%ebx,4)


	incl	%edx

	cmpl	$9, %edx
	jb		load_col

	incl	%ecx

	cmpl	$9, %ecx
	jb		load_row


	xorl	%eax, %eax

	popl	%edi
	popl	%esi
	popl	%ebx

	popl	%ebp
	retl

# int solve(last_row, last_col)

solve:
	pushl	%ebp
	movl	%esp, %ebp

	pushl	%ebx
	pushl	%esi
	pushl	%edi


	# Find next unfilled cell

	movl	8(%ebp), %ecx
	movl	12(%ebp), %edx

	jmp		jmp_start

next_row:
	xorl	%edx, %edx

next_col:
	movl	puzzle(,%ecx,4), %eax
	movl	(%eax,%edx,4), %eax

	testl	%eax, %eax
	je		found

jmp_start:
	incl	%edx

	cmpl	$9, %edx
	jb		next_col

	incl	%ecx

	cmpl	$9, %ecx
	jb		next_row

	jmp		done


found:
	# Guess number in cell

	movl	row(,%ecx,4), %eax
	andl	col(,%edx,4), %eax

	movl	box_index(,%ecx,4), %esi
	movl	box_index(,%edx,4), %edi
	xorl	%ebx, %ebx
	movb	box_lookup(%edi,%esi,4), %bl

	andl	box(,%ebx,4), %eax

	xorl	%ebx, %ebx

next_num:
	btl		%ebx, %eax
	incl	%ebx
	jnb		skip_guess

	movl	puzzle(,%ecx,4), %edi
	movl	%ebx, (%edi,%edx,4)

	movl	mask(,%ebx,4), %esi
	andl	%esi, row(,%ecx,4)
	andl	%esi, col(,%edx,4)

	pushl	%ecx
	pushl	%edx

	movl	box_index(,%ecx,4), %ecx
	movl	box_index(,%edx,4), %edi
	xorl	%edx, %edx
	movb	box_lookup(%edi,%ecx,4), %dl

	andl	%esi, box(,%edx,4)

	popl	%edx
	popl	%ecx

	pushl	%eax
	pushl	%edx
	pushl	%ecx

	call	solve

	popl	%ecx
	popl	%edx

	testl	%eax, %eax
	popl	%eax
	je		done

	movl	puzzle(,%ecx,4), %edi
	movl	$0, (%edi,%edx,4)

	movl	reset(,%ebx,4), %esi
	orl		%esi, row(,%ecx,4)
	orl		%esi, col(,%edx,4)

	pushl	%ecx
	pushl	%edx

	movl	box_index(,%ecx,4), %ecx
	movl	box_index(,%edx,4), %edi
	xorl	%edx, %edx
	movb	box_lookup(%edi,%ecx,4), %dl

	orl		%esi, box(,%edx,4)

	popl	%edx
	popl	%ecx

skip_guess:
	cmpl	$9, %ebx
	jbe		next_num

	movl	$-1, %eax
	jmp		ret_solve

done:
	xorl	%eax, %eax

ret_solve:
	popl	%edi
	popl	%esi
	popl	%ebx

	popl	%ebp
	retl
