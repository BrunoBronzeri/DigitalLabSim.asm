# UNIVERSIDADE FEDERAL DE SANTA CATARINA - Campus Blumenau
# Engenharia de Controle & Automação - Microprocessadores
#
# No digital Lab Sim, o usuário informa dois valores (Hexadecimal) e o programa em pooling faz a contagem
# regressiva até o zero. E então o mesmo reinicia o processo em looping.
#
# Autores:		Bruno Bueno Bronzeri..........(20204055)
#			Leonardo dos Santos Schmitt...(20201428)
# 										Data: 24/01/2022
#-------------------------------------------------------------------------------------------------------------------
.data
	input: .half 0x11, 0x21, 0x41, 0x81, 0x12, 0x22, 0x42, 0x82, 0x14, 0x24, 0x44, 0x84, 0x18, 0x28, 0x48, 0x88
	output: .half 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x67, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71
.text
	j PROC_main
	
PROC_lab_sim: # função linkada ao PROC_MAIN que realizar ascender o LED da esquerda e direita
	addi $sp, $sp, -24 # cria pilha 
	sw $t0, 0($sp) 
	sw $t1, 4($sp)  
	sw $t2, 8($sp) 
	sw $t3, 12($sp) 
	sw $t4, 16($sp) 
	sw $t5, 20($sp)

# loop responsável por verificar se há informação de input em alguma linha
loop_linha:	
	move $t1, $zero
	li $t1, 1
	sb $t1, 0($s4)
	lb $t0, 0($s5)
	beqz $t0, continua_loop # continua para laço onde será inserido os valores (2,4,8)
	beqz $t2, contador_laço # contador que permite a gente controlar quantas vezes a tecla foi digitada
	bnez $t2, percorre_novo_input # mesma função do 'percorre_input' mas para a segunda tecla selecionada
	
continua_loop:
	mul $t1, $t1, 2	
	bgt $t1, 8, loop_linha # se for igual a 16 nem continua
	sb $t1, 0($s4)
	lb $t0, 0($s5)
	beqz $t0, continua_loop 
	beqz $t2, contador_laço # contador que permite a gente controlar quantas vezes a tecla foi digitada
	bnez $t2, percorre_novo_input
	
contador_laço:
	add $t2, $t2 ,1
	
percorre_input:  # verifica a posição no input e realiza uma contagem até alcanaçar o '.data' input 
	lb $t3, 0($s0)
	beq $t0, $t3, acender_led_esquerda # se for igual vai para ascender led esquerda
	addi $s0, $s0, 2
	add $t4, $t4, 2 # contador para posição do input análoga ao output
	
	b percorre_input
	
acender_led_esquerda:
	add $s1, $s1, $t4 # soma no '.data' output o análogo '.data' input contado na branch acima
	lb $t5, 0($s1)
	sb $t5, 0($s2) # mostra no led da esquerda a 1a tecla selecionada
	sub $s1, $s1, $t4 # diminui para o endereço inicial no '.data output'
	sub $s0, $s0 ,$t4 # diminui para o endereço inicial '.data input'
	move $t3, $zero # zera a referência que aponta para o input
	move $t4, $zero # zera o contador
	
next_key: # zera t0 e espera a proxima tecla
	mul $t0, $t0, 0
	sb $t1, 0($s4)
	lb $t0, 0($s5)
	bnez $t0, next_key
	beqz $t0, loop_linha # pode sumir
	
percorre_novo_input:
	lb $t3, 0($s0)
	beq $t0, $t3, acender_led_direita # se for igual vai para acender led direita
	addi $s0, $s0, 2
	add $t4, $t4, 2 # contador para posição do input análoga ao output
	
	b percorre_novo_input
	
acender_led_direita:
	add $s1, $s1, $t4 # soma a posição do input para percorrer o output
	lb $t5, 0($s1)
	sb $t5, 0($s3) # mostra no led da direita e temos a primeira vitória 

zera_t0: # zera t0 e aguarda até que a tecla não esteja mais selecionada
	mul $t0, $t0, 0
	sb $t1, 0($s4)
	lb $t0, 0($s5)
	bnez $t0, zera_t0
	
end_lab_sim:
	lw $t0, 0($sp)
	lw $t1, 4($sp)  
	lw $t2, 8($sp) 
	lw $t3, 12($sp) 
	lw $t4, 16($sp) 
	lw $t5, 20($sp)
	addi $sp, $sp, 24 # carrega a pilha 
	
	jr $ra # retorna ao ponto no qual a função foi chamada
	
PROC_decremento: # decrementa os valores do led até zerá-lo por completo
	addi $sp, $sp, -24 # cria outra pilha
	sw $t0, 0($sp) 
	sw $t1, 4($sp)  
	sw $t2, 8($sp) 
	sw $t3, 12($sp) 
	sw $t4, 16($sp) 
	sw $t5, 20($sp)
	
	lb $t0, 0($s3) # carrega em t0 o valor referente ao led da direita
	lb $t1, 0($s2) # carrega em t1 o valor referente ao led da esquerda
	
while_not_zeroR: # função de decrementar o led da direita até 0
	sub $s1, $s1, 2
	lb $t0, 0($s1)
	sb $t0, 0($s3)
	li $a0, 350 # sleep do programa por 350 milisec. para Run speed at max
	li $v0 32
	syscall
	
	bne $t0, 0x3F, while_not_zeroR # retorna a branch até zerar o lado da direita
	
contador_output: # função de fazer o s1 ir para a posição do led da esquerda
	lb $t3, 0($s1)
	beq $t1, $t3, while_not_zeroL
	addi $s1, $s1, 2 

	b contador_output
	
while_not_zeroL: # decrementa em uma unidade na esquerda por ciclo completo da direita, até ambos zerarem
	sub $s1, $s1, 2
	lb $t1, 0($s1)
	
	beq $t1, 0xFFFFFF88, end_decremento # quando t1 for igual a 2^32, branch para fim do procedimento
	
	li $a0, 100 # sleep do programa por 100 milisec. para Run speed at max
	li $v0 32
	syscall
	
	sb $t1, 0($s2) # salva t1 em s2 para mostrar o valor decrementado no led da esquerda
	
counter_last_data: # contador até o último '.data' output, para segundo ciclo no led da direita 
	lb $t4, 0($s1)
	beq $t4, 0x71, last_hexa # se t4 for igual ao último '.data' output, branch printar 'F' (0x71)
	addi $s1, $s1, 2 

	b counter_last_data
	
last_hexa: 
	
	lb $t2, 0($s1)
	sb $t2, 0($s3) # printa 'F' (0x71)
	li $a0, 350 # sleep do programa por 350 milisec. para Run speed at max
	li $v0 32
	syscall
	
	beq $t2, 0x71, while_not_zeroR # retorna ao cilo decremento de 'F' à '0' na direita
	
end_decremento: # encerra o decremento com um beep e restaura a pilha para poder reiniciar do início, 2a vitória!

	li $a0, 67 # tone
	li $a1, 1000 # time
	li $a2, 127 # instrument  (127(SHOT) / 15(CHROMATIC) / 71(BUZZER))
	li $a3, 127 # volume
	li $v0, 31 # beep
	syscall
	
	li $a0, 1000 # sleep do programa por 1 sec. para Run speed at max
	li $v0 32
	syscall	
				
	sb $t5, 0($s2) # salva o valor de t5 -> (zero) no led da esquerda
	sb $t5, 0($s3) # salva o valor de t5 -> (zero) no led da direita
		
	lw $t0, 0($sp) 
	lw $t1, 4($sp)  
	lw $t2, 8($sp) 
	lw $t3, 12($sp) 
	lw $t4, 16($sp) 
	lw $t5, 20($sp)	
	addi $sp, $sp, 24 # restaura pilha 
	
	jr $ra # retorna para o ponto no qual a função foi chamada
			
# PROGRAMA PRINCIPAL 
PROC_main:
	
	la $s0, input # load andrees input
	la $s1, output  # load andrees output
	la $s2, 0xFFFF0011 # load andrees led esquerda
	la $s3, 0xFFFF0010 # load andrees led direta
	la $s4, 0xFFFF0012 # load andrees linha
	la $s5, 0xFFFF0014 # load andrees retorna valor
		
	jal PROC_lab_sim
	jal PROC_decremento
	
	b PROC_main # reiniciar o programa
