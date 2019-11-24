##	a0 - points to the string
##

#################################
#					 	#
#		text segment		#
#						#
#################################

	.text		
	.globl __start 

__start:		# execution starts here
	la $a0,str	# put string address into a0
	li $v0,4	# system call to print
	syscall	#   out a string

	li $v0,10  # system call to exit
	syscall	#    bye bye


#################################
#					 	#
#     	 data segment		#
#						#
#################################

	.data
str:	.asciiz "Alican\n"
n:	.word	10

##
## end of file Program1.asm


##
## Program2.asm asks user for temperature in Celsius,
##  converts to Fahrenheit, prints the result.
##
##	v0 - reads in Celsius
##	t0 - holds Fahrenheit result
##	a0 - points to output strings
##

#################################
#					 	#
#		text segment		#
#						#
#################################

	.text		
	.globl __start	

__start:
	la $a0,prompt	# output prompt message on terminal
	li $v0,4		# syscall 4 prints the string
	syscall

	li $v0, 5		# syscall 5 reads an integer
	syscall

	mul $t0,$v0,9	# to convert,multiply by 9,
	div $t0,$t0,5	# divide by 5, then
	add $t0,$t0,32	# add 32

	la $a0,ans1	# print string before result
	li $v0,4
	syscall

	move $a0,$t0	# print integer result
	li $v0,1		# using syscall 1
	syscall

	la $a0,endl	# system call to print
	li $v0,4		# out a newline
	syscall

	li $v0,10		# system call to exit
	syscall		#    bye bye


#################################
#					 	#
#     	 data segment		#
#						#
#################################

	.data
prompt:	.asciiz "Enter temperature (Celsius): "
ans1:		.asciiz "The temperature in Fahrenheit is "
endl:		.asciiz "\n"

##
## end of file Program2.asm

##
##	Program3.asm is a loop implementation
##	of the Fibonacci function
##        

#################################
#					 	#
#		text segment		#
#						#
#################################

	.text		
.globl __start
 
__start:			# execution starts here
	li $a0,7		# to calculate fib(7)
	jal fib		# call fib
	move $a0,$v0	# print result
	li $v0, 1
	syscall

	la $a0,endl		# print newline
	li $v0,4
	syscall

	li $v0,10
	syscall		# bye bye

#------------------------------------------------


fib:	move $v0,$a0	# initialise last element
	blt $a0,2,done	# fib(0)=0, fib(1)=1

	li $t0,0		# second last element
	li $v0,1		# last element

loop:	add $t1,$t0,$v0	# get next value
	move $t0,$v0	# update second last
	move $v0,$t1	# update last element
	sub $a0,$a0,1	# decrement count
	bgt $a0,1,loop	# exit loop when count=0
done:	jr $ra

#################################
#					 	#
#     	 data segment		#
#						#
#################################

	.data
endl:	.asciiz "\n"

##
## end of Program3.asm



PART 4


.data
prompt: .asciiz "Enter the number : "
prompt2: .asciiz "Result: "

.text

li $v0,4
la $a0,prompt
syscall 

# get the number
li $v0, 5 # num of element
syscall
move $t0,$v0 # a

li $v0,4
la $a0,prompt
syscall

# get the number
li $v0, 5 # num of element
syscall
move $t1,$v0 # b

li $v0,4
la $a0,prompt
syscall  

# get the number
li $v0, 5 # num of element
syscall
move $t2,$v0 # c

mul $t1,$t1,3 # 3b
add $t0,$t0,$t1 # (a+3b)
addi $t2,$t2,2 # (c+2)

mul $t0,$t0,$t2 # (a + 3b) * (c+2)
srl $t0,$t0,2 # (a + 3b) * (c+2)/4

#print result
move $a0,$t0 
li $v0,1
syscall



PART5





.data
array: .space 400
menu1: .asciiz " Enter the how many numbers you want to add"
menu2: .asciiz "Enter: "
choice: .asciiz "\n1. Find summation of numbers stored in the array which is greater than an input number. \n2. Find summation of even and odd numbers and display them.\n3. Display the number of occurrences of the array elements divisible by a certain input number.\n4. Quit."
output: .asciiz "Total: "
output_even: .asciiz " Even Total: "
output_odd: .asciiz " Odd total: "
output_accurances: .asciiz "Number of Accurances: "
.text

# ask user how many numbers you want to add
li $v0,4
la $a0,menu1
syscall 

# get the number
li $v0, 5 # num of element
syscall
move $s0,$v0  # store it at s0

addi $t0,$0,0
addi $t1,$0,0 # counter bytes 4 by 4

turn: 	
	li $v0,4
	la $a0,menu2
	syscall 
	
	#read integer
	li $v0,5
	syscall 
	move $s1,$v0
	
	sw $s1, array($t1)
	add $t0,$t0,1
	add $t1,$t1,4
loop: bne $t0,$s0,turn

       addi $s1,$0,1 # 1.choice
       addi $s2,$0,2 # 2.choice
       addi $s3,$0,3 # 3.choice
       addi $s4,$0,4 # 4.Quit choice
menu:	

	li $v0,4
	la $a0,choice
	syscall 
	
	#read integer
	li $v0,5
	syscall 
	move $s5,$v0
	
	bne $s1,$s5,exit2
	jal findSum
	exit2:
	
	bne $s2,$s5,exit3
	jal findEvenOdd
	exit3:
	
	bne $s3,$s5,exit4
	jal numOfAccurance
	exit4:
	
loop2: bne $s4,$s5,menu
       
       	li $v0,10
       	syscall	
	
findSum: addi $t0,$0,0 # counter 1 by 1
	 addi $t1,$0,0 # byte counter
	 addi $t2,$0,0 # result sum
	 
	  #read integer
	   li $v0,5
	   syscall 
	   move $t5,$v0
	
turn2:   lw $t3,array($t1)
	 ble $t3,$t5,outxx	 
         add $t2,$t2,$t3
         outxx:
         add $t0,$t0,1
         add $t1,$t1,4	 	 
totalloop: bne $t0,$s0,turn2
	  # show prompt
	   li $v0,4
	   la $a0,output
	   syscall 
	   # print result
	   li $v0,1
	   move $a0,$t2
	   syscall  	 	 	 
	 jr $ra # return

findEvenOdd: addi $t0,$0,0 # counter 1 by 1
	     addi $t1,$0,0 # byte counter
	     addi $t2,$0,0 # result even sum
	     addi $t3,$0,0 # result odd sum	 
	     addi $t4,$0,0x0001 # it is hexadecimal 0x01 also 
	    
turn3:   
	 lw $t6,array($t1)
	 and $t5,$t6,$t4
	 
	 bne $t5,$0,out
	 add $t2,$t2,$t6 # result even sum
	 out:
	 
	 bne $t5,$t4,out2
	 add $t3,$t3,$t6 # result odd sum
	 out2:
	 	
         add $t0,$t0,1
         add $t1,$t1,4	 	 
even_odd_loop: bne $t0,$s0,turn3
	 
	  # show prompt
	   li $v0,4
	   la $a0,output_even
	   syscall 
	   # print result
	   li $v0,1
	   move $a0,$t2
	   syscall 
	   
	   # show prompt
	   li $v0,4
	   la $a0,output_odd
	   syscall 
	   # print result
	   li $v0,1
	   move $a0,$t3
	   syscall 	 	 
	   
	   jr $ra	 	 	 
	 
numOfAccurance: li $v0,4
		la $a0,menu2
		syscall 
		
		addi $t0,$0,0 # counter 1 by 1
	     	addi $t1,$0,0 # byte counter
		addi $t3,$0,0 # accurances
		#read integer
		li $v0,5
		syscall 
		move $t4,$v0
		
turn4:   lw $t5,array($t1)
	 #check divisible or not
	 div $t6,$t5,$t4
	 mfhi $t7
	 # if remainder is 0
	 bne $t7,$0,outx
	 add $t3,$t3,1
	 outx:
         add $t0,$t0,1
         add $t1,$t1,4	 	 
accurances_loop: bne $t0,$s0,turn4
		
		 # show prompt
	   	li $v0,4
	   	la $a0,output_accurances
	   	syscall
	   	
	   	# print result
	   	li $v0,1
	        move $a0,$t3
	        syscall 
	        
	        jr $ra	 	 	 	 	  	 	 	 	 
