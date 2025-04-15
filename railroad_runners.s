################################################################################
# COMP1521 24T1 -- Assignment 1 -- Railroad Runners!
#
#
# !!! IMPORTANT !!!
# Before starting work on the assignment, make sure you set your tab-width to 8!
# It is also suggested to indent with tabs only.
# Instructions to configure your text editor can be found here:
#   https://cgi.cse.unsw.edu.au/~cs1521/24T1/resources/mips-editors.html
# !!! IMPORTANT !!!
#
#
# This program was written by Melina Salardini (z5393518)
# on 5/3/2024
#
# Version 1.0 (2024-02-27): Team COMP1521 <cs1521@cse.unsw.edu.au>
#
################################################################################

#![tabsize(8)]

# ------------------------------------------------------------------------------
#                                   Constants
# ------------------------------------------------------------------------------

# -------------------------------- C Constants ---------------------------------
TRUE = 1
FALSE = 0

JUMP_KEY = 'w'
LEFT_KEY = 'a'
CROUCH_KEY = 's'
RIGHT_KEY = 'd'
TICK_KEY = '\''
QUIT_KEY = 'q'

ACTION_DURATION = 3
CHUNK_DURATION = 10

SCROLL_SCORE_BONUS = 1
TRAIN_SCORE_BONUS = 1
BARRIER_SCORE_BONUS = 2
CASH_SCORE_BONUS = 3

MAP_HEIGHT = 20
MAP_WIDTH = 5
PLAYER_ROW = 1

PLAYER_RUNNING = 0
PLAYER_CROUCHING = 1
PLAYER_JUMPING = 2

STARTING_COLUMN = MAP_WIDTH / 2

TRAIN_CHAR = 't'
BARRIER_CHAR = 'b'
CASH_CHAR = 'c'
EMPTY_CHAR = ' '
WALL_CHAR = 'w'
RAIL_EDGE = '|'

SAFE_CHUNK_INDEX = 0
NUM_CHUNKS = 14

# --------------------- Useful Offset and Size Constants -----------------------

# struct BlockSpawner offsets
BLOCK_SPAWNER_NEXT_BLOCK_OFFSET = 0
BLOCK_SPAWNER_SAFE_COLUMN_OFFSET = 20
BLOCK_SPAWNER_SIZE = 24

# struct Player offsets
PLAYER_COLUMN_OFFSET = 0
PLAYER_STATE_OFFSET = 4
PLAYER_ACTION_TICKS_LEFT_OFFSET = 8
PLAYER_ON_TRAIN_OFFSET = 12
PLAYER_SCORE_OFFSET = 16
PLAYER_SIZE = 20

SIZEOF_PTR = 4


# ------------------------------------------------------------------------------
#                                 Data Segment
# ------------------------------------------------------------------------------
	.data

# !!! DO NOT ADD, REMOVE, OR MODIFY ANY OF THESE DEFINITIONS !!!

# ----------------------------- String Constants -------------------------------
welcome_msg:
	.asciiz "Welcome to Railroad Runners!\n"
first_keys_description: 
	.asciiz "Use the following keys to control your character: ("
second_keys_description:
	.asciiz "):\n"
move_left_msg:
	.asciiz ": Move left\n"
move_right_msg:
	.asciiz ": Move right\n"
first_crounch_msg:
	.asciiz ": Crouch ("
second_crounch_msg:
	.asciiz ")\n"
first_jump_msg:
	.asciiz ": Jump ("
second_jump_msg:
	.asciiz ")\n"
first_forward_msg:
	.asciiz "or press "
second_forward_msg:
	.asciiz  " to continue moving forward.\n"
first_barriers_msg:
	.asciiz "You must crouch under barriers ("
second_barrier_msg:
	.asciiz ")\n"
first_jump_train_msg:
	.asciiz "and jump over trains ("
second_jump_train_msg:
	.asciiz ").\n"
avoid_walls_msg:
	.asciiz "You should avoid walls ("
collect_cash_msg:
	.asciiz ") and collect cash ("
second_collect_cash_msg:
	.asciiz ").\n"
extra_point_msg:
	.asciiz "On top of collecting cash, running on trains and going under barriers will get you extra points.\n"
first_end_game_msg:
	.asciiz "When you've had enough, press "
second_end_game_msg:
	.asciiz  " to quit. Have fun!\n"

get_command__invalid_input_msg:
	.asciiz "Invalid input!\n"

main__game_over_msg:
	.asciiz "Game over, thanks for playing 😊!\n"

display_game__score_msg:
	.asciiz "Score: "

handle_collision__barrier_msg:
	.asciiz "💥 You ran into a barrier! 😵\n"
handle_collision__train_msg:
	.asciiz "💥 You ran into a train! 😵\n"
handle_collision__wall_msg:
	.asciiz "💥 You ran into a wall! 😵\n"

maybe_pick_new_chunk__column_msg_1:
	.asciiz "Column "
maybe_pick_new_chunk__column_msg_2:
	.asciiz ": "
maybe_pick_new_chunk__safe_msg:
	.asciiz "New safe column: "

get_seed__prompt_msg:
	.asciiz "Enter a non-zero number for the seed: "
get_seed__prompt_invalid_msg:
	.asciiz "Invalid seed!\n"
get_seed__set_msg:
	.asciiz "Seed set to "

TRAIN_SPRITE:
	.asciiz "🚆"
BARRIER_SPRITE:
	.asciiz "🚧"
CASH_SPRITE:
	.asciiz "💵"
EMPTY_SPRITE:
	.asciiz "  "
WALL_SPRITE:
	.asciiz "🧱"

PLAYER_RUNNING_SPRITE:
	.asciiz "🏃"
PLAYER_CROUCHING_SPRITE:
	.asciiz "🧎"
PLAYER_JUMPING_SPRITE:
	.asciiz "🤸"


# ------------------------------- Chunk Layouts --------------------------------

SAFE_CHUNK: # char[]
	.byte EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, '\0',
CHUNK_1: # char[]
	.byte EMPTY_CHAR, CASH_CHAR, EMPTY_CHAR, WALL_CHAR, CASH_CHAR, CASH_CHAR, CASH_CHAR, BARRIER_CHAR, '\0',
CHUNK_2: # char[]
	.byte CASH_CHAR, EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, BARRIER_CHAR, EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, CASH_CHAR, '\0',
CHUNK_3: # char[]
	.byte EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, '\0',
CHUNK_4: # char[]
	.byte EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, EMPTY_CHAR, CASH_CHAR, '\0',
CHUNK_5: # char[]
	.byte EMPTY_CHAR, EMPTY_CHAR, CASH_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, EMPTY_CHAR, TRAIN_CHAR, EMPTY_CHAR, EMPTY_CHAR, '\0',
CHUNK_6: # char[]
	.byte EMPTY_CHAR, EMPTY_CHAR, CASH_CHAR, BARRIER_CHAR, EMPTY_CHAR, EMPTY_CHAR, CASH_CHAR, CASH_CHAR, EMPTY_CHAR, BARRIER_CHAR, '\0'
CHUNK_7: # char[]
	.byte EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, WALL_CHAR, WALL_CHAR, WALL_CHAR, WALL_CHAR, WALL_CHAR, WALL_CHAR, WALL_CHAR, '\0',
CHUNK_8: # char[]
	.byte CASH_CHAR, EMPTY_CHAR, CASH_CHAR, EMPTY_CHAR, CASH_CHAR, EMPTY_CHAR, CASH_CHAR, EMPTY_CHAR, CASH_CHAR, EMPTY_CHAR, '\0',
CHUNK_9: # char[]
	.byte CASH_CHAR, EMPTY_CHAR, EMPTY_CHAR, WALL_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, '\0',
CHUNK_10: # char[]
	.byte CASH_CHAR, CASH_CHAR, CASH_CHAR, CASH_CHAR, CASH_CHAR, CASH_CHAR, CASH_CHAR, CASH_CHAR, CASH_CHAR, CASH_CHAR, '\0',
CHUNK_11: # char[]
	.byte EMPTY_CHAR, EMPTY_CHAR, CASH_CHAR, WALL_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, TRAIN_CHAR, '\0',
CHUNK_12: # char[]
	.byte EMPTY_CHAR, EMPTY_CHAR, CASH_CHAR, '\0',
CHUNK_13: # char[]
	.byte EMPTY_CHAR, EMPTY_CHAR, EMPTY_CHAR, WALL_CHAR, WALL_CHAR, '\0',

CHUNKS:	# char*[]
	.word SAFE_CHUNK, CHUNK_1, CHUNK_2, CHUNK_3, CHUNK_4, CHUNK_5, CHUNK_6, CHUNK_7, CHUNK_8, CHUNK_9, CHUNK_10, CHUNK_11, CHUNK_12, CHUNK_13

# ----------------------------- Global Variables -------------------------------

g_block_spawner: # struct BlockSpawner
	# char *next_block[MAP_WIDTH], offset 0
	.word 0, 0, 0, 0, 0
	# int safe_column, offset 20
	.word STARTING_COLUMN

g_map: # char[MAP_HEIGHT][MAP_WIDTH]
	.space MAP_HEIGHT * MAP_WIDTH

g_player: # struct Player
	# int column, offset 0
	.word STARTING_COLUMN
	# int state, offset 4
	.word PLAYER_RUNNING
	# int action_ticks_left, offset 8
	.word 0
	# int on_train, offset 12
	.word FALSE
	# int score, offset 16
	.word 0

g_rng_state: # unsigned
	.word 1

# !!! Reminder to not not add to or modify any of the above !!!
# !!! strings or any other part of the data segment.        !!!

# ------------------------------------------------------------------------------
#                                 Text Segment
# ------------------------------------------------------------------------------
	.text

############################################################
####                                                    ####
####   Your journey begins here, intrepid adventurer!   ####
####                                                    ####
############################################################

################################################################################
#
# Implement the following functions,
# and check these boxes as you finish implementing each function.
#
#  SUBSET 0
#  - [ ] print_welcome
#  SUBSET 1
#  - [ ] get_command
#  - [ ] main
#  - [ ] init_map
#  SUBSET 2
#  - [ ] run_game
#  - [ ] display_game
#  - [ ] maybe_print_player
#  - [ ] handle_command
#  SUBSET 3
#  - [ ] handle_collision
#  - [ ] maybe_pick_new_chunk
#  - [ ] do_tick
#  PROVIDED
#  - [X] get_seed
#  - [X] rng
#  - [X] read_char
################################################################################

################################################################################
# .TEXT <print_welcome>
print_welcome:
	# Subset:   0
	#
	# Args:     None
	#
	# Returns:  None
	#
	# Frame:    [$ra]
	# Uses:     [$ra, $v0, $a0]
	# Clobbers: [$v0, $v0]
	#
	# Locals:
	#   - None
	#
	# Structure:
	#   print_welcome
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

print_welcome__prologue:
	.text
print_welcome__body:

	li	$v0, 4						# syscall 4: print_str
	la	$a0, welcome_msg				# printf("Welcome to Railroad Runners!\n");						
	syscall


	li	$v0, 4						# syscall 4: print_str
	la	$a0, first_keys_description			# printf("Use the following keys to control your character:);				
	syscall


	li	$v0, 4						# syscall 4: print_str
	la	$a0, PLAYER_RUNNING_SPRITE			# print PLAYER_RUNNING_SPRITE
	syscall


	li	$v0, 4						# syscall 4: print_str
	la	$a0, second_keys_description			# printf():\n");
	syscall	


	li	$v0, 11						# syscall 4: print_character
	la	$a0, LEFT_KEY					# print LEFT_KEY
	syscall	


	li	$v0, 4						# syscall 4: print_str
	la	$a0, move_left_msg				# printf(": Move left\n");
	syscall	


	li	$v0, 11						# syscall 4: print_character
	la	$a0, RIGHT_KEY					# print RIGHT_KEY
	syscall	


	li	$v0, 4						# syscall 4: print_str
	la	$a0, move_right_msg				# printf(": Move right\n");
	syscall	


	li	$v0, 11						# syscall 4: print_character
	la	$a0, CROUCH_KEY					# print CROUCH_KEY
	syscall	


	li	$v0, 4						# syscall 4: print_str
	la	$a0, first_crounch_msg				# printf(": Crouch (");
	syscall	


	li	$v0, 4						# syscall 4: print_str
	la	$a0, PLAYER_CROUCHING_SPRITE			# print PLAYER_CROUCHING_SPRITE
	syscall


	li	$v0, 4						# syscall 4: print_str
	la	$a0, second_crounch_msg				# printf(")\n");
	syscall


	li	$v0, 11						# syscall 4: print_character
	la	$a0, JUMP_KEY					# print JUMP_KEY
	syscall	


	li	$v0, 4						# syscall 4: print_str
	la	$a0, first_jump_msg				# printf(": Jump (");
	syscall	

	
	li	$v0, 4						# syscall 4: print_str
	la	$a0, PLAYER_JUMPING_SPRITE			# print PLAYER_JUMPING_SPRITE
	syscall

	
	li	$v0, 4						# syscall 4: print_str
	la	$a0, second_jump_msg				# printf(")\n");
	syscall

	
	li	$v0, 4						# syscall 4: print_str
	la	$a0, first_forward_msg				# printf("or press ");
	syscall	

	
	li	$v0, 11						# syscall 4: print_character
	la	$a0, TICK_KEY					# print TICK_KEY
	syscall	


	li	$v0, 4						# syscall 4: print_str
	la	$a0, second_forward_msg				#printf(" to continue moving forward.\n");
	syscall	

	
	li	$v0, 4						# syscall 4: print_str
	la	$a0, first_barriers_msg				#printf("You must crouch under barriers (");
	syscall	

	
	li	$v0, 4						# syscall 4: print_str
	la	$a0, BARRIER_SPRITE				# print BARRIER_SPRITE
	syscall	

	
	li	$v0, 4						# syscall 4: print_str
	la	$a0, second_barrier_msg				# printf(")\n");
	syscall	
	
	
	li	$v0, 4						# syscall 4: print_str
	la	$a0, first_jump_train_msg			#printf("and jump over trains (");
	syscall	

	
	li	$v0, 4						# syscall 4: print_str
	la	$a0, TRAIN_SPRITE				# print TRAIN_SPRITE
	syscall	

	
	li	$v0, 4						# syscall 4: print_str
	la	$a0, second_jump_train_msg			# printf(")\n");
	syscall

	
	
	li	$v0, 4						# syscall 4: print_str
	la	$a0, avoid_walls_msg				#printf("You should avoid walls (");
	syscall	

	
	li	$v0, 4						# syscall 4: print_str
	la	$a0, WALL_SPRITE				# print WALL_SPRITE
	syscall	

	
	li	$v0, 4						# syscall 4: print_str
	la	$a0, collect_cash_msg				#printf(") and collect cash (");
	syscall	

	
	li	$v0, 4						# syscall 4: print_str
	la	$a0, CASH_SPRITE				# print CASH_SPRITE
	syscall	

	
	li	$v0, 4						# syscall 4: print_str
	la	$a0, second_collect_cash_msg			# printf(")\n");
	syscall	

	# printf("On top of collecting cash, running on trains and going under barriers will get you extra points.\n");
	li	$v0, 4						# syscall 4: print_str
	la	$a0, extra_point_msg
	syscall	

	
	li	$v0, 4						# syscall 4: print_str
	la	$a0, first_end_game_msg				# printf("When you've had enough, press ");
	syscall	

	
	li	$v0, 11						# syscall 4: print_character
	la	$a0, QUIT_KEY					# print QUIT_KEY
	syscall	

	
	li	$v0, 4						# syscall 4: print_str
	la	$a0, second_end_game_msg			#printf(" to quit. Have fun!\n");
	syscall	




print_welcome__epilogue:
	jr	$ra





################################################################################
# .TEXT <get_command>
	.text
get_command:
	# Subset:   1
	#
	# Args:     None
	#
	# Returns:  $v0: char
	#
	# Frame:    [$ra]
	# Uses:     [$ra, $t0, $v0, $a0]
	# Clobbers: [$v0, $a0]
	#
	# Locals:
	#   - None
	#
	# Structure:
	#   get_command
	#   -> [prologue]
	#     -> body
	#	-> get_command__while_loop
	#	-> get_command__print
	#   -> [epilogue]

get_command__prologue:
	push  	$ra           				# save $ra onto stack

get_command__body:

get_command__while_loop:
	jal	read_char				# call the function read_char
	move	$t0, $v0				# put the output of the function into $t0

	beq	$t0, QUIT_KEY, get_command__epilogue
	beq	$t0, JUMP_KEY, get_command__epilogue
	beq	$t0, LEFT_KEY, get_command__epilogue
	beq	$t0, CROUCH_KEY, get_command__epilogue
	beq	$t0, RIGHT_KEY, get_command__epilogue
	beq	$t0, TICK_KEY, get_command__epilogue
get_command__print:
	li	$v0, 4					# syscall 4: print_string
	la	$a0, get_command__invalid_input_msg	# printf("Invalid input!\n");
	syscall
	j	get_command__while_loop

get_command__epilogue:

	pop   	$ra           				# recover $ra from stack
	move	$v0, $t0				# return input;
	jr	$ra


################################################################################
# .TEXT <main>
	.text
main:
	# Subset:   1
	#
	# Args:     None
	#
	# Returns:  $v0: int
	#
	# Frame:    [$ra]
	# Uses:     [$ra, $v0, $a0, $a1, $a2, $a3]
	# Clobbers: [$a0, $v0]
	#
	# Locals:
	#   - ...
	#
	# Structure:
	#   main
	#   -> [prologue]
	#     -> body
	#	-> main__body_do_loop
	#	-> main__body_while_loop
	#	-> main__body_print
	#   -> [epilogue]

main__prologue:
	push 	$ra           			# save $ra onto stack

main__body:
	jal	print_welcome			# calling the function print_welcome
	jal	get_seed			# calling the function get_seed

	li	$a0, g_map			# load g_map into $a0 
	jal	init_map			# calling the function init_map

main__body_do_loop:
	li	$a0, g_map			
	la	$a1, g_player
	jal	display_game			# display_game(g_map, &g_player);
main__body_while_loop:
	li	$a0, g_map			
	la	$a1, g_player
	la	$a2, g_block_spawner
	jal	get_command			# call the function get_command
	move	$a3, $v0			# put the output of the function into $a3

	li	$a0, g_map			# initializing the $a0 registers again to		
	la	$a1, g_player
	la	$a2, g_block_spawner

	jal	run_game			# call the function run_game

	beq	$v0, FALSE, main__body_print	# if run_game output is false goto main_body_print 

	j	main__body_do_loop

main__body_print:
	li	$v0, 4				# syscall 4: print_string
	la	$a0, main__game_over_msg	# printf("Game over, thanks for playing 😊!\n");
	syscall
main__epilogue:
	pop	$ra           			# recover $ra from stack
    	li	$v0, 0         			# fails because $ra changes since main called
    	jr	$ra            			# return from function main


################################################################################
# .TEXT <init_map>
	.text
init_map:
	# Subset:   1
	#
	# Args:
	#   - $a0: char map[MAP_HEIGHT][MAP_WIDTH]
	#
	# Returns:  None
	#
	# Frame:    [$ra]
	# Uses:     [$ra, $t0, $t1, $t1, $t2, $t3, $t4]
	# Clobbers: [ ]
	#
	# Locals:
	#   - $t0 -> i
	#   - $t1 -> j
	#   - $t2 -> (i * MAP_WIDTH) + j
	#
	# Structure:
	#   init_map
	#   -> [prologue]
	#     -> body
	#	-> init_map__first_while_loop_start
	#	-> init_map__first_while_loop_cond
	#	-> init_map__first_while_loop_body
	#	   -> init_map__second_while_loop_start
	#	   -> init_map__second_while_loop_cond
	#	   -> init_map__second_while_loop_body
	#	   -> init_map__second_while_loop_increment
	#	   -> init_map__second_while_loop_end
	#	-> init_map__first_while_loop_increment
	#	-> init_map__first_while_loop_end
	#   -> [epilogue]

init_map__prologue:
init_map__body:
init_map__first_while_loop_start:
	li	$t0, 0						# int i = 0;
init_map__first_while_loop_cond:
	bge	$t0, MAP_HEIGHT, init_map__first_while_loop_end	# if(i >= MAP_HEIGHT)
init_map__first_while_loop_body:

init_map__second_while_loop_start:
	li	$t1, 0						# int j = 0
init_map__second_while_loop_cond:
	bge	$t1, MAP_WIDTH, init_map__second_while_loop_end	# if(j >= MAP_WIDTH)
init_map__second_while_loop_body:
	# calculating the index in 1D array
	mul	$t2, $t0, MAP_WIDTH				# $t2 = i * MAP_WIDTH
	add	$t2, $t2, $t1					# $t2 = (i * MAP_WIDTH) + j
	# access the map[i][j] element
	move	$t3, $a0					# accessing the map
	add	$t3, $t3, $t2					# accessing map[i][j]
	la	$t4, EMPTY_CHAR					# putting the value of EMPTY_CHAR into $t4
	sb	$t4, ($t3)					# map[i][j] = EMPTY_CHAR;
init_map__second_while_loop_increment:
	addi	$t1, $t1, 1					# j++
	j	init_map__second_while_loop_cond
init_map__second_while_loop_end:

init_map__first_while_loop_increment:
	addi	$t0, $t0, 1					# i++
	j	init_map__first_while_loop_cond
init_map__first_while_loop_end:
	# Hard code some things onto the map for easier testing

	# map[6][0] = WALL_CHAR;
	move	$t3, $a0					# accessing the map
	add	$t3,$t3, 30					# accessing map[6][0]
	la	$t4, WALL_CHAR					# putting the value of WALL_CHAR into $t4
	sb	$t4, ($t3)					# map[6][0] = WALL_CHAR;

	# map[6][1] = TRAIN_CHAR
	move	$t3, $a0					# accessing the map
	add	$t3,$t3, 31					# accessing map[6][1]
	la	$t4, TRAIN_CHAR					# putting the value of TRAIN_CHAR into $t4
	sb	$t4, ($t3)					# map[6][1] = TRAIN_CHAR;

	# map[6][2] = CASH_CHAR;
	move	$t3, $a0					# accessing the map
	add	$t3,$t3, 32					# accessing map[6][2]
	la	$t4, CASH_CHAR					# putting the value of CASH_CHAR into $t4
	sb	$t4, ($t3)					# map[6][2] = CASH_CHAR;

	# map[8][2] = BARRIER_CHAR;
	move	$t3, $a0					# accessing the map
	add	$t3,$t3, 42					# accessing map[8][2]
	la	$t4, BARRIER_CHAR				# putting the value of BARRIER_CHAR into $t4
	sb	$t4, ($t3)					# map[8][2] = BARRIER_CHAR;

init_map__epilogue:
	jr	$ra


################################################################################
# .TEXT <run_game>
	.text
run_game:
	# Subset:   2
	#
	# Args:
	#   - $a0: char map[MAP_HEIGHT][MAP_WIDTH]
	#   - $a1: struct Player *player
	#   - $a2: struct BlockSpawner *block_spawner
	#   - $a3: char input
	#
	# Returns:  $v0: int
	#
	# Frame:    [$ra, $s0, $s1, $s2, $s3]
	# Uses:     [$ra, $s0, $s1, $s2, $s3, $a0, $a1, $a2, $a3, $v0]
	# Clobbers: [$v0]
	#
	# Locals:
	#   - None
	#
	# Structure:
	#   run_game
	#   -> [prologue]
	#     -> body
	#	-> run_game__continue
	#   -> [epilogue]

run_game__prologue:
	push  	$ra           				# save $ra onto stack
	push	$s0
	push 	$s1
	push	$s2
	push	$s3

	move	$s0, $a0
	move 	$s1, $a1
	move	$s2, $a2
	move	$s3, $a3
run_game__body:
	bne	$a3, QUIT_KEY, run_game__continue	# if (input != QUIT_KEY) goto run_game__continue
	li	$v0, FALSE				# put the out put as FALSE
	j	run_game__epilogue
run_game__continue:
	jal	handle_command				# call the handle_command function

	move	$a0, $s0
	move	$a1, $s1
	jal	handle_collision			# call the handle_collision function
run_game__epilogue:
	pop	$s3
	pop	$s2
	pop	$s1
	pop	$s0
	pop	$ra					# recover $ra from the stack
	jr	$ra


################################################################################
# .TEXT <display_game>
	.text
display_game:
	# Subset:   2
	#
	# Args:
	#   - $a0: char map[MAP_HEIGHT][MAP_WIDTH]
	#   - $a1: struct Player *player
	#
	# Returns:  None
	#
	# Frame:    [$ra, $s0, $s1, $s2, $s3]
	# Uses:     [$t2, $t3, $t4, $s0, $s1, $s2, $s3, $a0, $a1, $v0]
	# Clobbers: [$a0, $a1, $v0]
	#
	# Locals:
	#   - $s2 -> i
	#   - $s3 -> j
	#   - $t4 -> map[i][j]
	#
	# Structure:
	#   display_game
	#   -> [prologue]
	#     -> body
	#	-> display_game__first_while_loop_init
	#	-> display_game__first_while_loop_cond
	#	-> display_game__first_while_loop_body
	#	   -> display_game__second_while_loop_init
	#	   -> display_game__second_while_loop_cond
	#		-> display_game__first_if
	#		-> display_game__second_if
	#		-> display_game__third_if
	#		-> display_game__fourth_if
	#		-> display_game__fifth_if
	#	   -> display_game__second_while_loop_increment
	#	   -> display_game__second_while_loop_end
	#	-> display_game__first_while_loop_increment 
	#	-> display_game__first_while_loop_end
	#   -> [epilogue]

display_game__prologue:
	push	$ra							# saving $ra on the stack							
	push	$s0							# saving $s0 on the stack
	push	$s1							# saving $s1 on the stack
	push	$s2							# saving $s2 on the stack
	push	$s3							# saving $s3 on the stack

	move	$s0, $a0						# preserve $a0 for use after function call
	move	$s1, $a1						# preserve $a1 for use after function call
display_game__body:
display_game__first_while_loop_init:
	li	$s2, MAP_HEIGHT						# $s2 -> MAP_HEIGHT
	sub	$s2, $s2, 1						# int i = MAP_HEIGHT - 1
display_game__first_while_loop_cond:
	blt	$s2, 0, display_game__first_while_loop_end		# if (i < 0)
display_game__first_while_loop_body:

display_game__second_while_loop_init:
	li	$s3, 0							# int j = 0;
display_game__second_while_loop_cond:
	bge	$s3, MAP_WIDTH, display_game__second_while_loop_end	# if (j >= MAP_WIDTH)
	li	$v0, 11							# syscall 4: print_str
	la	$a0, RAIL_EDGE						# putchar(RAIL_EDGE);
	syscall

	move	$a0, $s1						# set $a0 -> player
	move	$a1, $s2						# set $a1 -> i
	move	$a2, $s3						# set $a2 -> j
	jal	maybe_print_player					# calling the function maybe_print_player

	beq	$v0, TRUE, display_game__second_while_loop_increment	# if (maybe_print_player(player, i, j) === TRUE)
	# calculating the offset in 2D array
	mul	$t2, $s2, MAP_WIDTH
	add	$t2, $t2, $s3
	# calculating the memory address of the map[i][j]
	add	$t3, $s0, $t2

	lb	$t4, 0($t3)						# load the value of map[i][j] into register

display_game__first_if:
	bne	$t4, EMPTY_CHAR, display_game__second_if		# if (map_char != EMPTY_CHAR) 
	li	$v0, 4							# syscall 4: print_str
	la	$a0, EMPTY_SPRITE					# printf(EMPTY_SPRITE);
	syscall

	j	display_game__second_while_loop_increment
display_game__second_if:
	bne	$t4, BARRIER_CHAR, display_game__third_if		# if (map_char != BARRIER_CHAR)

	li	$v0, 4							# syscall 4: print_str
	la	$a0, BARRIER_SPRITE					# printf(BARRIER_SPRITE);
	syscall

	j	display_game__second_while_loop_increment
display_game__third_if:
	bne	$t4, TRAIN_CHAR, display_game__fourth_if		# if (map_char != TRAIN_CHAR)

	li	$v0, 4							# syscall 4: print_str
	la	$a0, TRAIN_SPRITE					# printf(TRAIN_SPRITE);
	syscall

	j	display_game__second_while_loop_increment
display_game__fourth_if:
	bne	$t4, CASH_CHAR, display_game__fifth_if			# if (map_char != CASH_CHAR)

	li	$v0, 4							# syscall 4: print_str
	la	$a0, CASH_SPRITE					# printf(CASH_SPRITE);
	syscall

	j	display_game__second_while_loop_increment
display_game__fifth_if:
	bne	$t4, WALL_CHAR, display_game__second_while_loop_increment# if (map_char != WALL_CHAR)

	li	$v0, 4							# syscall 4: print_str
	la	$a0, WALL_SPRITE					# printf(WALL_SPRITE);
	syscall

	j	display_game__second_while_loop_increment
display_game__second_while_loop_increment:
	li	$v0,11							# syscall 4: print_str
	la	$a0, RAIL_EDGE						# putchar(RAIL_EDGE);
	syscall

	add	$s3, $s3, 1						# j++;
	j	display_game__second_while_loop_cond
display_game__second_while_loop_end:			
	li	$v0, 11							# syscall 11 -> print_char							
	la	$a0, '\n'						# putchar('\n');
	syscall

display_game__first_while_loop_increment:
	sub	$s2, $s2, 1						# i--
	j	display_game__first_while_loop_cond
display_game__first_while_loop_end:

	li	$v0, 4							# syscall 4: print_str
	la	$a0, display_game__score_msg					# printf("score: ")
	syscall

	lw	$a0, PLAYER_SCORE_OFFSET($s1)				# load the value of player->score into $t5

	li	$v0, 1							# syscall 1: print_int
	syscall

	li	$v0, 11							# syscall 11 -> print_char							
	la	$a0, '\n'						# putchar('\n');
	syscall

display_game__epilogue:
	pop	$s3							# recover $s3 from the stack
	pop	$s2							# recover $s2 from the stack
	pop	$s1							# recover $s1 from the stack
	pop	$s0							# recover $s0 from the stack
	pop 	$ra							# recover $ra from the stack 
	jr	$ra

################################################################################
# .TEXT <maybe_print_player>
	.text
maybe_print_player:
	# Subset:   2
	#
	# Args:
	#   - $a0: struct Player *player
	#   - $a1: int row
	#   - $a2: int column
	#
	# Returns:  $v0: int
	#
	# Frame:    [$ra, $s0, $s1, $s2]
	# Uses:     [$t0, $t1, $s0, $s1, $s2, $a0, $v0]
	# Clobbers: [$a0, $v0]
	#
	# Locals:
	#   - $t0: player->column
	#   - $t1: player->state
	#
	# Structure:
	#   maybe_print_player
	#   -> [prologue]
	#     -> body
	#	-> maybe_print_player__first_if
	#	   -> maybe_print_player__second_if
	#	   -> maybe_print_player__third_if
	#	   -> maybe_print_player__fourth_if
	#	   -> maybe_print_player__second_if_end
	#   -> [epilogue]

maybe_print_player__prologue:
	push	$ra							# saving $ra on the stack
	push	$s0							# saving $s0 on the stack
	push	$s1							# saving $s1 on the stack
	push	$s2							# saving $s2 on the stack

	move	$s0, $a0						# preserve $a0 for use after function call
	move	$s1, $a1						# preserve $a1 for use after function call
	move	$s2, $a2						# preserve $a2 for use after function call
maybe_print_player__body:

maybe_print_player__first_if:
	bne	$s1, PLAYER_ROW, maybe_print_player__epilogue		# if(row != PLAYER_ROW)

	lw	$t0, PLAYER_COLUMN_OFFSET($s0)				# $t0: player->column
	bne	$s2, $t0, maybe_print_player__epilogue			# if(column != player->column)
maybe_print_player__second_if:
	lw	$t1, PLAYER_STATE_OFFSET($s0)				# $t1: player->state
	bne	$t1, PLAYER_RUNNING, maybe_print_player__third_if	# if (player->state != PLAYER_RUNNING)

	li	$v0, 4							# syscall 4: print_str
	la	$a0, PLAYER_RUNNING_SPRITE				# printf(PLAYER_RUNNING_SPRITE);
	syscall
maybe_print_player__third_if:
	bne	$t1, PLAYER_CROUCHING, maybe_print_player__fourth_if	# if (player->state != PLAYER_RUNNING)

	li	$v0, 4							# syscall 4: print_str
	la	$a0, PLAYER_CROUCHING_SPRITE				# printf(PLAYER_CROUCHING_SPRITE);
	syscall
maybe_print_player__fourth_if:
	bne	$t1, PLAYER_JUMPING, maybe_print_player__second_if_end	# if (player->state != PLAYER_JUMPING)

	li	$v0, 4							# syscall 4: print_str
	la	$a0, PLAYER_JUMPING_SPRITE				# printf(PLAYER_JUMPING_SPRITE);
	syscall
maybe_print_player__second_if_end:
	li	$v0, TRUE						# load the value TRUE into $v0

	pop	$s2							# recover $s2 from the stack
	pop	$s1							# recover $s1 from the stack
	pop	$s0							# recover $s0 from the stack
	pop	$ra							# recover $ra from the stack
	jr	$ra
maybe_print_player__epilogue:
	li	$v0, FALSE						# load the value FALSE into $v0

	pop	$s2							# recover $s2 from the stack
	pop	$s1							# recover $s1 from the stack
	pop	$s0							# recover $s0 from the stack
	pop	$ra							# recover $ra from the stack
	jr	$ra


################################################################################
# .TEXT <handle_command>
	.text
handle_command:
	# Subset:   2
	#
	# Args:
	#   - $a0: char map[MAP_HEIGHT][MAP_WIDTH]
	#   - $a1: struct Player *player
	#   - $a2: struct BlockSpawner *block_spawner
	#   - $a3: char input
	#
	# Returns:  None
	#
	# Frame:    [$ra, $s0, $s1, $s2, $s3]
	# Uses:     [$t0, $t1, $t2, $t3, $s0, $s1, $s2, $s3, $v0, $a0, $a1, $a2, $a3]
	# Clobbers: [$v0]
	#
	# Locals:
	#   - $t0: player->column
	#   - $t1: player->state
	#   - $t2: player->action_ticks_left
	#
	# Structure:
	#   handle_command
	#   -> [prologue]
	#     -> body
	#	-> handle_command__first_if
	#	   -> handle_command__first_sub_if
	#	-> handle_command__second_if
	#	   -> handle_command__second_sub_if
	#	-> handle_command__third_if
	#	   -> handle_command__third_sub_if
	#	-> handle_command__fourth_if
	#	   -> handle_command__fourth_sub_if
	#	-> handle_command__fifth_if
	#   -> [epilogue]

handle_command__prologue:
	push	$ra							# saving $ra on the stack
	push	$s0							# saving $s0 on the stack
	push	$s1							# saving $s1 on the stack
	push	$s2							# saving $s2 on the stack
	push	$s3							# saving $s3 on the stack

	move	$s0, $a0						# preserve $a0 for use after function call
	move	$s1, $a1						# preserve $a1 for use after function call
	move	$s2, $a2						# preserve $a2 for use after function call
	move	$s3, $a3						# preserve $a3 for use after function call
handle_command__body:
	lw	$t0, PLAYER_COLUMN_OFFSET($s1)				# $t0: player->column
	lw	$t1, PLAYER_STATE_OFFSET($s1)				# $t1: player->state
	lw	$t2, PLAYER_ACTION_TICKS_LEFT_OFFSET($s1)		# $t2: player->action_ticks_left


handle_command__first_if:
	bne	$s3, LEFT_KEY, handle_command__second_if		# if(input != LEFT_KEY)
handle_command__first_sub_if:
	ble	$t0, 0, handle_command__epilogue			# if(player->column <= 0)
	addi	$t0, $t0, -1						# --player->column;
	sw	$t0, PLAYER_COLUMN_OFFSET($s1)				# store the value
handle_command__second_if:
	bne	$s3, RIGHT_KEY, handle_command__third_if		# if(input != RIGHT_KEY)
handle_command__second_sub_if:
	li	$t3, MAP_WIDTH
	addi	$t3, $t3, -1
	bge	$t0, $t3, handle_command__epilogue			# if (player->column >= MAP_WIDTH - 1)

	addi	$t0, $t0, 1						# ++player->column;
	sw	$t0, PLAYER_COLUMN_OFFSET($s1)				# store the value
handle_command__third_if:
	bne	$s3, JUMP_KEY, handle_command__fourth_if		# if(input != JUMP_KEY)
handle_command__third_sub_if:
	bne	$t1, PLAYER_RUNNING, handle_command__epilogue		# if(player->state != PLAYER_RUNNING)
	li	$t1, PLAYER_JUMPING					# player->state = PLAYER_JUMPING;
	sw	$t1, PLAYER_STATE_OFFSET($s1)				# srore the value

	li	$t2, ACTION_DURATION					# player->action_ticks_left = ACTION_DURATION;
	sw	$t2, PLAYER_ACTION_TICKS_LEFT_OFFSET($s1)		# store the value
handle_command__fourth_if:
	bne	$s3, CROUCH_KEY, handle_command__fifth_if		# if(input != CROUCH_KEY)
handle_command__fourth_sub_if:
	bne	$t1, PLAYER_RUNNING, handle_command__epilogue		# if(player->state != PLAYER_RUNNING)
	li	$t1, PLAYER_CROUCHING					# player->state = PLAYER_CROUCHING;
	sw	$t1, PLAYER_STATE_OFFSET($s1)				# store the value

	li	$t2, ACTION_DURATION					# player->action_ticks_left = ACTION_DURATION;
	sw	$t2, PLAYER_ACTION_TICKS_LEFT_OFFSET($s1)		# store the value
handle_command__fifth_if:	
	bne	$s3, TICK_KEY, handle_command__epilogue			# if(input != TICK_KEY)
	move	$a0, $s0
	move	$a1, $s1
	move	$a2, $s2
	jal	do_tick



handle_command__epilogue:
	pop	$s3							# recover $s3 from the stack
	pop	$s2							# recover $s2 from the stack
	pop	$s1							# recover $s1 from the stack
	pop	$s0							# recover $s0 from the stack
	pop	$ra							# recover $ra from the stack
	jr	$ra


################################################################################
# .TEXT <handle_collision>
	.text
handle_collision:
	# Subset:   3
	#
	# Args:
	#   - $a0: char map[MAP_HEIGHT][MAP_WIDTH]
	#   - $a1: struct Player *player
	#
	# Returns:  $v0: int
	#
	# Frame:    [$ra, $s0, $s1]
	# Uses:     [$s0, $s1, $v0, $a0, $t0, $t1, $t2, $t3, $t4, $t5, $t6]
	# Clobbers: [$v0, $a0]
	#
	# Locals:
	#   - $t0: PLAYER_ROW
	#   - $t1: player->column
	#   - $t2: address of map[PLAYER_ROW][player->column]
	#   - $t3: value of map[PLAYER_ROW][player->column]
	#   - $t4: player->state
	#   - $t5: player->score
	#   - $t6: player->on_train
	#
	# Structure:
	#   handle_collision
	#   -> [prologue]
	#     -> body
	#	-> handle_collision__first_if
	#	-> handle_collision__first_if_end
	#	-> handle_collision__second_if
	#	   -> handle_collision__second_if_continue
	#	   -> handle_collision__second_if_else
	#	-> handle_collision__third_if
	#	-> handle_collision__fourth_if
	#	-> handle_collision__end
	#   -> [epilogue]

handle_collision__prologue:
	push	$ra
	push	$s0
	push	$s1

	move	$s0, $a0
	move	$s1, $a1
handle_collision__body:
	li	$t0, PLAYER_ROW						# $t0 -> PLAYER_ROW
	lw	$t1, PLAYER_COLUMN_OFFSET($s1)				# $t1: player->column
	lw	$t4, PLAYER_STATE_OFFSET($s1)				# $t4: player->state
	lw	$t5, PLAYER_SCORE_OFFSET($s1)				# $t5: player->score
	lw	$t6, PLAYER_ON_TRAIN_OFFSET($s1)			# $t6: player->on_train

	mul	$t2, $t0, MAP_WIDTH
	add	$t2, $t2, $t1
	add	$t2, $t2, $s0						# $t2:address of map[PLAYER_ROW][player->column]
	lb	$t3, 0($t2)						# $t3:value of map[PLAYER_ROW][player->column]
handle_collision__first_if:
	bne	$t3, BARRIER_CHAR, handle_collision__second_if		# if (*map_char != BARRIER_CHAR)
	beq	$t4, PLAYER_CROUCHING, handle_collision__first_if_end	# if (player->state == PLAYER_CROUCHING)

	li	$v0, 4							# syscall 4: print_str
	la	$a0, handle_collision__barrier_msg			# printf("💥 You ran into a barrier! 😵\n");
	syscall

	li	$v0, FALSE
	j	handle_collision__epilogue
handle_collision__first_if_end:
	add	$t5, $t5, BARRIER_SCORE_BONUS				# player->score += BARRIER_SCORE_BONUS;
	sw	$t5, PLAYER_SCORE_OFFSET($s1)				# store the value 
handle_collision__second_if:
	bne	$t3, TRAIN_CHAR, handle_collision__second_if_else	# if (*map_char != TRAIN_CHAR)

	beq	$t4, PLAYER_JUMPING, handle_collision__second_if_continue
	beq	$t6, TRUE, handle_collision__second_if_continue		# if (player->state == PLAYER_JUMPING || player->on_train)

	li	$v0, 4							# syscall 4: print_str
	la	$a0, handle_collision__train_msg			# printf("💥 You ran into a train! 😵\n");
	syscall

	li	$v0, FALSE
	j	handle_collision__epilogue	
handle_collision__second_if_continue:
	li	$t6, TRUE						# player->on_train = TRUE;
	sw	$t6, PLAYER_ON_TRAIN_OFFSET($s1)			# store the value

	beq	$t4, PLAYER_JUMPING, handle_collision__fourth_if	# if (player->state == PLAYER_JUMPING)
	add	$t5, $t5, TRAIN_SCORE_BONUS				# player->score += TRAIN_SCORE_BONUS;
	sw	$t5, PLAYER_SCORE_OFFSET($s1)				# store the value
	j	handle_collision__third_if	
handle_collision__second_if_else:
	li	$t6, FALSE						# player->on_train = FALSE;
	sw	$t6, PLAYER_ON_TRAIN_OFFSET($s1)			# store the value
handle_collision__third_if:
	bne	$t3, WALL_CHAR, handle_collision__fourth_if		# if (*map_char != WALL_CHAR)

	li	$v0, 4							# syscall 4: print_str
	la	$a0, handle_collision__wall_msg				# printf("💥 You ran into a wall! 😵\n");
	syscall

	li	$v0, FALSE
	j	handle_collision__epilogue
handle_collision__fourth_if:
	bne	$t3, CASH_CHAR, handle_collision__end			# if (*map_char != CASH_CHAR)
	add	$t5, $t5, CASH_SCORE_BONUS				# player->score += CASH_SCORE_BONUS;
	sw	$t5, PLAYER_SCORE_OFFSET($s1)				# store the value

	li	$t3, EMPTY_CHAR						# *map_char = EMPTY_CHAR;
	sb	$t3, 0($t2)						# store the value
handle_collision__end:
	li	$v0, TRUE
	j	handle_collision__epilogue
handle_collision__epilogue:
	pop	$s1
	pop	$s0
	pop	$ra
	jr	$ra


################################################################################
# .TEXT <maybe_pick_new_chunk>
	.text
maybe_pick_new_chunk:
	# Subset:   3
	#
	# Args:
	#   - $a0: struct BlockSpawner *block_spawner
	#
	# Returns:  None
	#
	# Frame:    [$ra, $s0]
	# Uses:     [$s0, $a0, $v0, $t0, $t1, $t2, $t3, $t4, $t5, $t6] 
	# Clobbers: [$a0, $v0]
	#
	# Locals:
	#   - $t0: new_safe_column_required
	#   - $t1: column
	#   - $t2: &block_spawner->next_block
	#   - $t3: *next_block_ptr 
	#   - $t4: chunk
	#   - $t5: **next_block_ptr
	#   - $t6: safe_column
	#
	# Structure:
	#   maybe_pick_new_chunk
	#   -> [prologue]
	#     -> body
	#	-> maybe_pick_new_chunk__while_cond
	#	   -> maybe_pick_new_chunk__while_second_stage
	#	-> maybe_pick_new_chunk__while_encrement
	#	-> maybe_pick_new_chunk__while_end
	#   -> [epilogue]

maybe_pick_new_chunk__prologue:
	push	$ra
	push	$s0

	move	$s0, $a0
maybe_pick_new_chunk__body:
	li	$t0, FALSE						# $t0 -> new_safe_column_required = FALSE;
	lw	$t5, BLOCK_SPAWNER_SAFE_COLUMN_OFFSET($s0)		# $t5 -> block_spawner->safe_column

	li	$t1, 0							# $t1 -> column = 0
maybe_pick_new_chunk__while_cond:
	la	$t2, BLOCK_SPAWNER_NEXT_BLOCK_OFFSET($s0)		# $t2 -> &block_spawner->next_block

	bge	$t1, MAP_WIDTH, maybe_pick_new_chunk__while_end		# if(column >= MAP_WIDTH)

	add	$t2, $t2, $t1						# &block_spawner->next_block[column]

	lw      $t3, 0($t2)					        # $t3: *next_block_ptr 		
	beq	$t3, $zero, maybe_pick_new_chunk__while_second_stage	# if (*next_block_ptr == FALSE)

	lb	$t5, 0($t3)						# $t5: **next_block_ptr
	beq	$t5, $zero, maybe_pick_new_chunk__while_second_stage	# if(**next_block_ptr == FALSE)
	
	j	maybe_pick_new_chunk__while_cond
maybe_pick_new_chunk__while_second_stage:

	j	rng

	rem	$t4, $v0, NUM_CHUNKS					# $t4 -> chunk = rng() % NUM_CHUNKS;

	li	$v0, 4							# printf("Column %d: %d\n", column, chunk);
	la	$a0, maybe_pick_new_chunk__column_msg_1
	syscall

	li	$v0, 1							# print colum 
	move	$a0, $t1
	syscall

	li	$v0, 4							
	la	$a0, maybe_pick_new_chunk__column_msg_2
	syscall

	li	$v0, 1							# print chunck 
	move	$a0, $t4
	syscall	

	li	$v0, 11							# syscall 11 -> print_char							
	la	$a0, '\n'						# putchar('\n');
	syscall


	lw	$t6, CHUNKS($t4)					# CHUNKS[chunk];
	sw	$t6, ($t3)						# *next_block_ptr = CHUNKS[chunk];

	bne	$t1, $t5, maybe_pick_new_chunk__while_encrement		# if (column != block_spawner->safe_column)
	li	$t0, TRUE						# new_safe_column_required = TRUE;



maybe_pick_new_chunk__while_encrement:
	add	$t1, $t1, 1						# colum++
	j	maybe_pick_new_chunk__while_cond
maybe_pick_new_chunk__while_end:
	beq	$t0, FALSE, maybe_pick_new_chunk__epilogue		# if (new_safe_column_required == FALSE)

	j	rng

	rem	$t6, $v0, MAP_WIDTH					# $t6 -> safe_column = rng() % MAP_WIDTH;

	li	$v0, 4							# printf("New safe column: %d\n", safe_column);
	la	$a0, maybe_pick_new_chunk__safe_msg
	syscall

	li	$v0, 1
	move	$a0, $t6
	syscall

	li	$v0, 11							# syscall 11 -> print_char							
	la	$a0, '\n'						# putchar('\n');
	syscall


	move	$t5, $t6
	sw	$t5, BLOCK_SPAWNER_SAFE_COLUMN_OFFSET($s1)	        # store the value 


	lw	$t2, BLOCK_SPAWNER_NEXT_BLOCK_OFFSET($s0)		# $t2: block_spawner->next_block
	add	$t2, $t2, $t6						# $t2: block_spawner->next_block[safe_column]

	li	$t7, SAFE_CHUNK_INDEX
	lw	$t8, CHUNKS($t7)					# $t8: CHUNKS[SAFE_CHUNK_INDEX];
	sw	$t8, ($t2)
maybe_pick_new_chunk__epilogue:
	pop	$s0
	pop	$ra

	jr	$ra


################################################################################
# .TEXT <do_tick>
	.text
do_tick:
	# Subset:   3
	#
	# Args:
	#   - $a0: char map[MAP_HEIGHT][MAP_WIDTH]
	#   - $a1: struct Player *player
	#   - $a2: struct BlockSpawner *block_spawner
	#
	# Returns:  None
	#
	# Frame:    [$ra, $s0, $s1, $s2]
	# Uses:     [$s0, $a0, $v0, $t0, $t1, $t2, $t3, $t4, $t5, $t6]
	# Clobbers: [$v0, $a0]
	#
	# Locals:
	#   - $t0: player->action_ticks_left
	#   - $t1: player->state
	#   - $t2: player->score
	#   - $t3: map
	#   - $t4: map[i][j]
	#   - $t5: i + 1
	#   - $t6: map[i + 1][j]
	#
	# Structure:
	#   do_tick
	#   -> [prologue]
	#     -> body
	#	-> do_tick__else
	#	-> do_tick__body_continue
	#	-> do_tick__first_for_con
	#	-> do_tick__first_for_body
	#	   -> do_tick__second_for_con
	#	   -> do_tick__second_for_body
	#	   -> do_tick__second_for_encrement
	#	-> do_tick__first_for_encrement
	#	-> do_tick__first_for_end
	#	-> do_tick__third_for_con
	#	-> do_tick__third_for_body
	#	-> do_tick__third_for_encrement
	#   -> [epilogue]

do_tick__prologue:
	push	$ra
	push	$s0
	push	$s1
	push	$s2

	move	$s0, $a0					# $s0 : char map[MAP_HEIGHT][MAP_WIDTH]
	move	$s1, $a1				        # $s1: struct Player *player
	move	$s2, $a2				        # $s2: struct BlockSpawner *block_spawner
do_tick__body:
	lw	$t0, PLAYER_ACTION_TICKS_LEFT_OFFSET($s1)	# $t0: player->action_ticks_left
	lw	$t1, PLAYER_STATE_OFFSET($s1)			# $t1: player->state
	lw	$t2, PLAYER_SCORE_OFFSET($s2)			# $t2: player->score
	
	ble	$t0, 0, do_tick__else				# if (player->action_ticks_left <= 0) 
	addi	$t0, $t0, -1					# --player->action_ticks_left;
	sw	$t0, PLAYER_ACTION_TICKS_LEFT_OFFSET($s1)	# store the value
	j	do_tick__body_continue
do_tick__else:
	li	$t1, PLAYER_RUNNING				# player->state = PLAYER_RUNNING;
	sw	$t1, PLAYER_STATE_OFFSET($s1)		        # store the value
do_tick__body_continue:
	add	$t2, $t2, SCROLL_SCORE_BONUS  			# player->score += SCROLL_SCORE_BONUS;
	sw	$t2, PLAYER_SCORE_OFFSET($s1)			# store the value

	move	$a0, $s2				        # put block_spawner as the input
	jal	maybe_pick_new_chunk				# call the function maybe_pick_new_chunk

	li	$t0, 0						# $t0: i = 0
do_tick__first_for_con:
	li	$t1, MAP_HEIGHT
	addi	$t1, $t1, -1
	bge	$t0, $t1, do_tick__first_for_end		# if(i >= MAP_HEIGHT - 1)
do_tick__first_for_body:
	li	$t2, 0						# $t2: j = 0
do_tick__second_for_con:
	bge	$t2, MAP_WIDTH, do_tick__first_for_encrement    # if (j >= MAP_WIDTH)
do_tick__second_for_body:
	move	$t3, $s0				        # $t3: map

	mul	$t4, $t0, MAP_WIDTH
	add	$t4, $t4, $t2
	add	$t4, $t4, $t3					# $t4: map[i][j]

	add	$t5, $t0, 1					# $t5: i + 1
	mul	$t6, $t5, MAP_WIDTH
	add	$t6, $t6, $t2
	add	$t6, $t6, $t3					# $t6: map[i + 1][j]


	sb	$t6, ($t4)					# map[i][j] = map[i + 1][j] 
do_tick__second_for_encrement:
	addi	$t2, $t2, 1					# j++
	j	do_tick__second_for_con


do_tick__first_for_encrement:
	addi	$t0, $t0, 1				        # i++
	j	do_tick__first_for_con
do_tick__first_for_end:


	li	$t0, 0						# $t0: column = 0
do_tick__third_for_con:
	bge	$t0, MAP_WIDTH, do_tick__epilogue		# if (column >= MAP_WIDTH)
do_tick__third_for_body:

	la	$t1, BLOCK_SPAWNER_NEXT_BLOCK_OFFSET($s2)	# $t1: block_spawner->next_block
        mul     $t6, $t0, 4                                     # $t6: column * 4
	add	$t1, $t1, $t6					# $t1: &block_spawner->next_block[column]
	lw	$t2, 0($t1)					# $t2: *next_block
        lb      $t7, 0($t2)                                     # $t7: **next_block

	move	$t3, $s0					# $t3: map
	li	$t4, MAP_HEIGHT
	addi	$t4, $t4, -1					# $t4: MAP_HEIGHT - 1

	mul	$t5, $t4, MAP_WIDTH
	add	$t5, $t5, $t0
	add	$t5, $t5, $t3					# $t5: map[MAP_HEIGHT - 1][column]

	sb	$t7, 0($t5)					# map[MAP_HEIGHT - 1][column] = **next_block;
	addi	$t2, $t2, 1					# ++*next_block;
	sb	$t2, 0($t2)					# store the value
do_tick__third_for_encrement:
	addi	$t0, $t0, 1					# ++column
	j	do_tick__third_for_con

do_tick__epilogue:
	pop	$s2
	pop	$s1
	pop	$s0
        pop     $ra
	jr	$ra

################################################################################
################################################################################
###                   PROVIDED FUNCTIONS — DO NOT CHANGE                     ###
################################################################################
################################################################################

################################################################################
# .TEXT <get_seed>
get_seed:
	# Args:     None
	#
	# Returns:  None
	#
	# Frame:    []
	# Uses:     [$v0, $a0]
	# Clobbers: [$v0, $a0]
	#
	# Locals:
	#   - $v0: seed
	#
	# Structure:
	#   get_seed
	#   -> [prologue]
	#     -> body
	#       -> invalid_seed
	#       -> seed_ok
	#   -> [epilogue]

get_seed__prologue:
get_seed__body:
	li	$v0, 4				# syscall 4: print_string
	la	$a0, get_seed__prompt_msg
	syscall					# printf("Enter a non-zero number for the seed: ")

	li	$v0, 5				# syscall 5: read_int
	syscall					# scanf("%d", &seed);
	sw	$v0, g_rng_state		# g_rng_state = seed;

	bnez	$v0, get_seed__seed_ok		# if (seed == 0) {
get_seed__invalid_seed:
	li	$v0, 4				#   syscall 4: print_string
	la	$a0, get_seed__prompt_invalid_msg
	syscall					#   printf("Invalid seed!\n");

	li	$v0, 10				#   syscall 10: exit
	li	$a0, 1
	syscall					#   exit(1);

get_seed__seed_ok:				# }
	li	$v0, 4				# sycall 4: print_string
	la	$a0, get_seed__set_msg
	syscall					# printf("Seed set to ");

	li	$v0, 1				# syscall 1: print_int
	lw	$a0, g_rng_state
	syscall					# printf("%d", g_rng_state);

	li	$v0, 11				# syscall 11: print_char
	la	$a0, '\n'
	syscall					# putchar('\n');

get_seed__epilogue:
	jr	$ra				# return;


################################################################################
# .TEXT <rng>
rng:
	# Args:     None
	#
	# Returns:  $v0: unsigned
	#
	# Frame:    []
	# Uses:     [$v0, $a0, $t0, $t1, $t2]
	# Clobbers: [$v0, $a0, $t0, $t1, $t2]
	#
	# Locals:
	#   - $t0 = copy of g_rng_state
	#   - $t1 = bit
	#   - $t2 = temporary register for bit operations
	#
	# Structure:
	#   rng
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

rng__prologue:
rng__body:
	lw	$t0, g_rng_state

	srl	$t1, $t0, 31		# g_rng_state >> 31
	srl	$t2, $t0, 30		# g_rng_state >> 30
	xor	$t1, $t2		# bit = (g_rng_state >> 31) ^ (g_rng_state >> 30)

	srl	$t2, $t0, 28		# g_rng_state >> 28
	xor	$t1, $t2		# bit ^= (g_rng_state >> 28)

	srl	$t2, $t0, 0		# g_rng_state >> 0
	xor	$t1, $t2		# bit ^= (g_rng_state >> 0)

	sll	$t1, 31			# bit << 31
	srl	$t0, 1			# g_rng_state >> 1
	or	$t0, $t1		# g_rng_state = (g_rng_state >> 1) | (bit << 31)

	sw	$t0, g_rng_state	# store g_rng_state

	move	$v0, $t0		# return g_rng_state

rng__epilogue:
	jr	$ra


################################################################################
# .TEXT <read_char>
read_char:
	# Args:     None
	#
	# Returns:  $v0: unsigned
	#
	# Frame:    []
	# Uses:     [$v0]
	# Clobbers: [$v0]
	#
	# Locals:   None
	#
	# Structure:
	#   read_char
	#   -> [prologue]
	#     -> body
	#   -> [epilogue]

read_char__prologue:
read_char__body:
	li	$v0, 12			# syscall 12: read_char
	syscall				# return getchar();

read_char__epilogue:
	jr	$ra
