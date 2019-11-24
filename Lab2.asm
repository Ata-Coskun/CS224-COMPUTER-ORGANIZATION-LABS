monitor:
      # menu options  
      addi $s2,$0,1
      addi $s3,$0,2
      addi $s4,$0,3
      addi $s5,$0,4
      addi $s6,$0,5
      
      li $v0,4
      la $a0,choices
      syscall
      
      li $v0,5
      syscall
      add $s7,$v0,$0
      # if choice checks
      bne $s7,$s2,out1
      jal readArray
      out1:
      bne $s7,$s3,out2
      jal bubbleSort
      jal print
      out2:
      bne $s7,$s4,out3
      jal bubbleSort
      jal minmax
      out3:
      bne $s7,$s5,out4
      jal bubbleSort
      jal median
      out4:
      bne $s7,$s6,out5
      li $v0,10
      syscall
      out5:
      bne $s7,$s6,monitor
       
readArray: li $v0,4
 	   la $a0,EnterNumber1
 	   syscall
 	   
 	   li $v0,5
 	   syscall
 	   add $s0,$v0,$0 # number of items
 	   
 	   # invalid check
 	   bgt $s0,$0,endout
 	   
 	   li $v0,4
 	   la $a0,ArrayEmpty
 	   syscall
	
           jr $ra
 	   
 	   endout:  	   
 	   sll $s1,$s0,2 # number of bytes
 	   
 	   #allocate array
 	   add $a0,$s1,$0
 	   li $v0,9
 	   syscall
 	   
 	   add $s1,$v0,$0 # adress of the array
 	   
 	   add $t0,$s0,$0 
 	   add $t1,$s1,$0
 	
 	#initialise array      
turn:   li $v0,4
 	la $a0,EnterNumber2
 	syscall
 	   
 	li $v0,5
 	syscall
 	addi $t3,$v0,0

	sw $t3,0($t1)
	
	addi $t1,$t1,4
	addi $t0,$t0,-1
	bne $t0,$0,turn
	
	add $v0,$s1,$0
	jr $ra  

	
bubbleSort: 

	  addi $t0,$0,0 # i = 0
	  addi $t1,$s0,-1 # n-1

forLoop1: 
	  addi $t2,$0,0 # j = 0
	  sub $t3,$t1,$t0 # n-i-1
	  addi $t9,$0,0
forLoop2: 
	  add $t4,$s1,$t2 # index of j
	  addi $t5,$t4,4 # index of j+1
	  
	  lw $t6,0($t4) # array[j]
	  lw $t7,0($t5) # array[j+1]
	  
	  blt $t6,$t7,out  
	  addi $t8,$t6,0 # temp
	  sw $t7,0($t4)
	  sw $t8,0($t5)
	  out:
	
	addi $t2,$t2,4 
	addi $t9,$t9,1
	blt $t9,$t3,forLoop2  #for ( int j = 0 ; j < n-i-1 , j++)
	
	addi $t0,$t0,1 # i+1
	blt $t0,$t1,forLoop1 #for ( int i = 0 ; i < n-1 , i++)
	jr $ra
print: 	
		
	add $t0,$s0,$0
 	add $t1,$s1,$0
 	
        li $v0,4
	la $a0,Array
	syscall	   
turn2:
	lw $t3,0($t1)
	
	li $v0,1
	add $a0,$t3,$0
	syscall
	
	li $v0,4
	la $a0,Comma
	syscall
	
	addi $t1,$t1,4
	addi $t0,$t0,-1
	bne $t0,$0,turn2
	jr $ra  

minmax: 	 
	      addi $t0,$s1,4 #second
	      sll $t1,$s0,2  
	      addi $t1,$t1,-8 # last
	      add $t1,$t1,$s1
	      # get second min second max
	      lw $t2,0($t0)
	      lw $t3,0($t1)
	      
	      addi $v0,$t2,0
	      addi $v1,$t3,0
	      
	      li $v0,4
 	      la $a0,print1
 	      syscall
 	      
 	      li $v0,1
 	      addi $a0,$t2,0
 	      syscall
 	      
 	      li $v0,4
 	      la $a0,print2
 	      syscall
	      
	      li $v0,1
 	      addi $a0,$t3,0
 	      syscall
 	  	  	 
 	      jr $ra
	      		
median:       	
	      srl $t0,$s0,1 # n/2
	      and $t4,$s0,1
	      addi $t0,$t0,1
 	      add $t1,$s1,$0 #adress of array
turn3:          
	      lw $t3,0($t1) # get elements
	      addi $t1,$t1,4
	      addi $t0,$t0,-1
	      bne $t0,$0,turn3
	      
	      addi $t1,$t1,-8
	      # if array has even number of elements. It adds 2 middle and divide 2
	      bne $t4,$0,pout
	      lw $t5,0($t1)
	      add $t3,$t3,$t5
	      srl $t3,$t3,1
	      pout:
	      
	      li $v0,4
	      la $a0,print3
	      syscall
	      
	      li $v0,1
	      add $a0,$0,$t3
	      syscall
	
	      jr $ra  
  
.data
EnterNumber1: .asciiz "How many number do you want to add? "
EnterNumber2: .asciiz "Enter Number: "
Comma: .asciiz " , "
Array: .asciiz"Array: "
		
print1: .asciiz " Second min:  "
print2: .asciiz " Second max:   "
print3: .asciiz "Median : "  	   
choices: .asciiz" \n 1.Create Array \n 2.Sort \n 3.Show 2nd min,max \n 4.Find median \n 5.quit\n "
ArrayEmpty: .asciiz "Array is empty "
