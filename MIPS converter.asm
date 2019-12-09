############################################################################
# Created by:  Stone, Matthew
#              1673656
#              11/13/18
# 
# Assignment:  Lab 4 
#              CMPE 012, Computer Systems and Assembly Language 
#              UC Santa Cruz, Fall 2018 
#  
# Description: This program prints ‘Hello world.’ to the screen. 
#  
# Notes:       This program is intended to be run from the MARS IDE. 
############################################################################
# PSUEDO CODE
# MAIN:
# print intro
# print inputs
# jump to decimal converter
# jumnp back to here
# add s1 and s2, storing in s0
# print Decimal intro
# print s0
# jump to binary converter
# print binary intro
# print s0 in 2c
# jump to morse code converter
# print morse corde intro
# print s0 in morse corde
#
# LOOP:
#	if counter = 2, exit
# 	load char into temp register
# 	if char = -
#		move offset
#		convert from ASCII to Decimal
#		add to a temp register
#		subtract from 0
# 	else
# 		convert ASCII to Decimal by subtracting 48 from temp register
# 		multiply temp register by 10
#		add to third temp register
#	if loop counter = 1
#		move temp register into s2
#	else
#		move temp into s1
#		jump back to LLOOP
#
# 2C CONVERTER: printing to bindary using binary masking
# $s0 = sum (-27)
#      x x x x x x x x
#  AND 0 1 0 0 0 0 0 0 -> mask
#      x 0 0 0 0 0 0 0 -> result
# if result == 0
# print 0
# else
# print 1]
# 
# MORSE CODE CONVERTER: Requires array
# jump back to main
#
# REGISTER USAGE
#
# $s0 = sum of S1 and S2
# $S1 = first argument
# $S2 = second argument
#
# $t0 = loader register for the input
# $t1 = counter register to count bits loaded from t0.
# $t2 = temporary register to move values around while loading from input
# $t3 = universal temp register for the major loops.
# $t4 = loop counter for binary conversion.
# $t5 = not used.
# $t6 = not used.
# $t7 = not used.
# $t8 = bit mask register used to print binary using shift left logical
# $t9 = negative flag to keep track of negativity through the conversions

.data
intro: .asciiz "You entered the decimal numbers: \n"
sumd: .asciiz "The sum in decimal is: "
sumb: .asciiz "The sum in two's complement binary is:\n"
summ: .asciiz "The sum in Morse code is:\n"
terminator: .asciiz "\n"
spacer: .asciiz " "
mneg: .asciiz "-....-"
mzero: .asciiz "-----"
mone: .asciiz ".----"
mtwo: .asciiz "..---"
mthree: .asciiz "...--"
mfour: .asciiz "....-"
mfive: .asciiz "....."
msix: .asciiz "-...."
mseven: .asciiz "--..."
meight: .asciiz "---.."
mnine: .asciiz "----."
.text
main: nop
        # intro
        li $v0, 4
        la $a0, intro
        syscall
        # prints arguments
        li $v0, 4
        lw $a0, ($a1)
        syscall
        li $v0, 4
        la $a0, spacer
        syscall
        li $v0, 4
        lw $a0, 4($a1)
        syscall
        li $v0, 4
        la $a0, terminator
        syscall 
        syscall
        j loop
        out: nop
        move $t1, $zero
        # prints decimals
        li $v0, 4
        la $a0, sumd
        syscall
        la $a0, terminator
        syscall
        j decimal
        dback:nop
	li $v0, 4
        la $a0, terminator
        syscall
        syscall
        # prints binary
        la $a0, sumb
        syscall
        j bconverter
        bback: nop
        li $v0, 4
        la $a0, terminator
        syscall
        syscall
        la $a0, summ
        syscall
        j Mconverter
        morseback: nop
        la $a0, spacer
        syscall
        la $a0, terminator
        syscall
j exit
# first loop - loads in input
loop:
        # counter
        beq $t1, 2, out
        lw $t0, ($a1)
        # loads first bit
        lb $t2, ($t0)
        beq $t2, 45, negative
        sub $t2, $t2, 48
        mul $t2, $t2, 10
        move $t3, $t2
        move $t2, $zero
        # loads second bit
        lb $t2, 1($t0)
        sub $t2, $t2, 48
        addu $t3, $t2, $t3
        move $t2, $zero
        fneg: nop
        # stores values in S registers
        beq $t1, 1, secondary
        move $s1, $t3
        move $t3, $zero
        second: nop
        # iterates
        addi $t1, $t1, 1
        # loads next word
        add $a1, $a1, 4
j loop
# auxillary path for a negative number
negative: nop
        # moves offset
        lb $t2, 1($t0)
        sub $t2, $t2, 48
        mul $t2, $t2, 10
        move $t3, $t2
        move $t2, $zero
        # loads second bit
        lb $t2, 2($t0)
        sub $t2, $t2, 48
        addu $t3, $t2, $t3
        move $t2, $zero
        mul  $t3, $t3, -1
j fneg 
# auxillary path for the 2nd input loaded.
secondary: nop
        move $s2, $t3
        move $t3, $zero
j second

# ASCII to Decimal converter
decimal: nop
        addu $s0, $s1, $s2
        blt $s0, 0, dnegative
        dnegback: nop
        # converts back to ASCII for printing
        addi $s0, $s0, 48
        li $v0, 11
        la $a0, ($s0)
        syscall
j dback

# Decimal to ASCII converter if negative
dnegative: nop
        mul  $s0, $s0, -1
        li $v0, 11
        la $a0, 45
        syscall
        # sets negative flag for binary MSB
        addi $t9, $zero, 1
j dnegback

# ASCII to binary converter
bconverter: nop
        # converts back to decimal
        sub $s0, $s0, 48
        # if negative number, fixes it so no overflow
        beq $t9, 1, fixer
        fback: nop
        # sets bit mask
        addi $t8, $t8, 6
        # prepares to print characters
        li $v0, 11
        # clears the  previous loop counter for another use
        move $t3, $zero
        # sign extender using binary flag
        MSB: nop
                # set to 26 as you only need 8 bits to represent -63 to 63.
                beq $t1, 25, while
                beq $t9, 1, one
                # if not negative, print 0's
                li $a0, 48
                syscall
                oback: nop
                addi $t1, $t1, 1
        j MSB
        # binary printer
        while: nop
		# need only 7 bits for the range of possible numbers.
                beq $t4, 7, bbback
                # bitwise operation to print 1's and 0's 
                srlv $t3, $s0, $t8
                and $t3, 1
                # if 0, print 0, else 1
                beq $t3, $zero, zero 
                li $a0, 49
                syscall
                zback: nop
                # iterates T4, counts down t8, clears t3.
                addiu $t4, $t4, 1
                subi $t8, $t8, 1
                move $t3, $zero
       j while
bbback: nop
j bback

# converts to morse code, hard coded by advice of MSI TA.
Mconverter: nop
      bgt $t9, 0, fixer2
      NMback: nop
      # checks for 2nd digit, and subtracts so that S0 is one digit.
      bge $s0, 60, M60
      bge $s0, 50, M50
      bge $s0, 40, M40
      bge $s0, 30, M30
      bge $s0, 20, M20
      bge $s0, 10, M10
j morse

M60: nop
      li $v0, 4
      la $a0, msix
      syscall
      subi $s0, $s0, 60
j morse

M50: nop
      li $v0, 4
      la $a0, mfive
      syscall
      subi $s0, $s0, 50
j morse

M40: nop
      li $v0, 4
      la $a0, mfour
      syscall
      subi $s0, $s0, 40
j morse

M30: nop
      li $v0, 4
      la $a0, mthree
      syscall
      subi $s0, $s0, 30
j morse

M20: nop
      li $v0, 4
      la $a0, mtwo
      syscall
      subi $s0, $s0, 20
j morse

M10: nop
      li $v0, 4
      la $a0, mone
      syscall
      subi $s0, $s0, 10
j morse

# morse converts the remaining number to morse code.
morse: nop
      beq $s0, 9, pnine
      beq $s0, 8, peight
      beq $s0, 7, pseven
      beq $s0, 6, psix
      beq $s0, 5, pfive
      beq $s0, 4, pfour
      beq $s0, 3, pthree
      beq $s0, 2, ptwo
      beq $s0, 1, pone
j morseback

# functions to print morse as strings. jumps back to main.
pnine: nop
      li $v0, 4
      la $a0, mnine
      syscall
j morseback

peight: nop
      li $v0, 4
      la $a0, meight
      syscall
j morseback

pseven: nop
      li $v0, 4
      la $a0, mseven
      syscall
j morseback

psix: nop
      li $v0, 4
      la $a0, msix
      syscall
j morseback

pfive: nop
      li $v0, 4
      la $a0, mfive
      syscall
j morseback

pfour: nop
      li $v0, 4
      la $a0, mfour
      syscall
j morseback

pthree: nop
      li $v0, 4
      la $a0, mthree
      syscall
j morseback

ptwo: nop
      li $v0, 4
      la $a0, mtwo
      syscall
j morseback

pone: nop
      li $v0, 4
      la $a0, mone
      syscall
j morseback

one:nop
        li $a0, 49
        syscall
j oback

zero:nop
        li $a0, 48
        syscall
j zback

# negative converters
fixer: nop
        mul $s0, $s0, -1
j fback

fixer2: nop
        mul $s0, $s0, -1
        li $v0, 4
        la $a0, mneg
        syscall
        la $a0, spacer
        syscall
j NMback

exit: nop
        li $v0, 10
syscall
