.data
comma: .asciiz ","
row : .asciiz "\nrow: " 
column : .asciiz "\ncolumn: "
enterNumber: .asciiz "\nEnter the number you want to access: "
enterSize: .asciiz "\nEnter the size of array"
rowtotal: .asciiz "\nrow total : "
columntotal: .asciiz"\ncolumn total : "
enterRow: .asciiz "\n enter row:  "
enterColumn: .asciiz "\n enter column:  "
element: .asciiz "\n element:  "
menu: .asciiz "\n1.Create an array with desired size.\n2.Ask user the matrix element to be accessed and display the content.\n3.Obtain summation of matrix elements row-major (row by row) summation.\n4.Obtain summation of matrix elements column-major (column by column) summation.\n5.Display desired elements of the matrix by specifying its row and column member.\n6.Quit.

.text


cacheTest: 
		#jal arrayGenerate
		#jal columnBasedTotal
		#li $v0,10
                #syscall
main :          
                li $v0,4
                la $a0,menu
                syscall
                li $v0,5
                syscall
                addi $s3,$0,1
                addi $s4,$0,2
                addi $s5,$0,3
                addi $s6,$0,4
                addi $s7,$0,5
                addi $t9,$0,6

                bne $v0,$s3,cık1
                jal arrayGenerate
                #jal printArray
                cık1:           
                bne $v0,$s4,cık2
                jal accessElement
                cık2:
                bne $v0,$s5,cık3
                jal rowBasedTotal
                cık3:
                bne $v0,$s6,cık4
                jal columnBasedTotal
                cık4:
                bne $v0,$s7,cık5
                jal displayDesiredElement
                cık5:
                bne $v0,$t9,cık6
                li $v0,10
                syscall
                cık6:
                
                j main

arrayGenerate:  
                 li $v0,4
                 la $a0,enterSize
                 syscall

                li $v0,5 # get n
                syscall

                addi $s2,$v0,0 #row and column count
                mult $v0,$v0 # n square
                mflo $s0

                # allocate space              
                li $v0,9
                addi $a0,$s0,0 
                syscall         

                addi $s1,$v0,0 # head of array

                addi $t0,$s1,0

                addi $t1,$0,0 # count 1 by 1 
                addi $t2,$t1,1 

                addi $t3,$0,0

                addi $t4,$0,4
                mult $t4,$s2
                mflo $t4 

               loop: beq $t1,$s0,exit

                 # for:
                 #    beq $t3,$s2,forout

                  #   mult $t3,$t4
                  #   mflo $t5
                  #   add $t5,$t5,$t0

                    sw $t2,0($t0)
                   #  addi $t2,$t2,1 
                   #  addi $t3,$t3,1
                   #  j for
                  #forout:                                    
                    addi $t0,$t0,4
                    addi $t1,$t1,1
                    addi $t2,$t1,1
                   #  addi $t1,$t1,1
                   #  addi $t3,$0,0                   
                     j loop          
               exit:

               jr $ra

printArray:     addi $t0,$s1,0
                addi $t1,$0,0

                loop2: beq $t1,$s0,exit2

                     lw $t2,0($t0)

                     li $v0,1
                     addi $a0,$t2,0
                     syscall

                     li $v0,4
                     la $a0,comma
                     syscall

                     addi $t0,$t0,4
                     addi $t1,$t1,1
                     j loop2         
               exit2:
                     jr $ra

accessElement:       li $v0,4
                     la $a0,enterRow
                     syscall 

                     li $v0,5 # get n
                     syscall

                     add $t0,$0,$v0 #row number
                     addi $t0,$t0,-1       
                     li $v0,4
                     la $a0,enterColumn
                     syscall               

                     li $v0,5 # get n
                     syscall                                                                                           

                    add $t1,$0,$v0 #column number
                    addi $t1,$t1,-1

                    addi $t2,$0,4

                    mult $t0,$s2
                    mflo $t3 #row
                    mult $t3 $t2

                    mflo $t3        
                    add $t3,$t3,$s1 # go to row base

                    mult $t2,$t1
                    mflo $t4
                    add $t5,$t4,$t3     

                    lw $t6,0($t5)

                    li $v0,4
                    la $a0,element
                    syscall

                    li $v0,1
                    addi $a0,$t6,0
                    syscall

                     jr $ra                  

columnBasedTotal:                                                                  
                addi $t0,$s1,0
                addi $t1,$0,0
                addi $t3,$0,0   
                addi $t4,$0,0 # row counter                                    
                loop4: beq $t1,$s2,exit4                                                                     
                  inner:   
                     beq $t4,$s2,x

                     lw $t2,0($t0)
                     add $t3,$t3,$t2
                     addi $t4,$t4,1
                     addi $t0,$t0,4
                     j inner
                     x:

                     li $v0,4
                     la $a0,columntotal
                     syscall

                     li $v0,1
                     addi $a0,$t3,0
                     syscall
                    # addi $t0,$t0,4
                     addi $t3,$0,0
                     addi $t4,$0,0
                     addi $t1,$t1,1
                     j loop4         
               exit4:

                     jr $ra

rowBasedTotal: 

                addi $t0,$s1,0

                addi $t1,$0,0 # count 1 by 1 
                addi $t2,$t1,1 

                addi $t3,$0,0

                addi $t4,$0,4
                mult $t4,$s2
                mflo $t4 
                addi $t6,$0,0
               loop5: beq $t1,$s2,exit5

                  for2:
                     beq $t3,$s2,forout2

                     mult $t3,$t4
                     mflo $t5
                     add $t5,$t5,$t0

                     lw $t2,0($t5)
                     add $t6,$t6,$t2
                     addi $t2,$t2,1 
                     addi $t3,$t3,1
                     j for2
                  forout2:
                     li $v0,4
                     la $a0,rowtotal
                     syscall

                     li $v0,1
                     addi $a0,$t6,0
                     syscall

                     addi $t0,$t0,4
                     addi $t1,$t1,1
                     addi $t3,$0,0
                     addi $t6,$0,0                   
                     j loop5         
               exit5:


                     jr $ra                     

displayDesiredElement: 

                     li $v0,4
                     la $a0,enterColumn
                     syscall 

                     li $v0,5 # get n
                     syscall

                     add $t0,$0,$v0 #row number
                     addi $t0,$t0,-1       
                     li $v0,4
                     la $a0,enterRow
                     syscall               

                     li $v0,5 # get n
                     syscall                                                                                           

                    add $t1,$0,$v0 #column number
                    addi $t1,$t1,-1

                    addi $t2,$0,4

                    mult $t0,$s2
                    mflo $t3 #row
                    mult $t3 $t2

                    mflo $t3        
                    add $t3,$t3,$s1

                    addi $t4,$0,0

                    li $v0,4
                    la $a0,column
                    syscall

printRow:           beq $t4,$s2,exitRow

                    lw $t5,0($t3)

                    li $v0,1
                    addi $a0,$t5,0
                    syscall

                    li $v0,4
                    la $a0,comma
                    syscall

                    addi $t4,$t4,1
                    addi $t3,$t3,4
                    j printRow
                    exitRow:

                   li $v0,4
                   la $a0,row
                   syscall 

                   addi $t4,$0,0
                   mult $t2,$t1
                   mflo $t3

                   mult $t2,$s2
                   mflo $t6
                   #addi $t6,$t3,0
                   add $t3,$t3,$s1

printColumn:       beq  $t4,$s2,exitColumn

                   lw $t5,0($t3)

                   li $v0,1
                   addi $a0,$t5,0
                   syscall

                   li $v0,4
                   la $a0,comma
                   syscall

                   add $t3,$t3,$t6
                   addi $t4,$t4,1
                   j printColumn
                   exitColumn:      
                   jr $ra                   
			


