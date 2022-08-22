extends KinematicBody2D

class_name Player

enum {MOVE, CLIMB}

export(Resource) var moveData = preload("res://DefaultPlayerMovementData.tres") as PlayerMovementData

var velocity := Vector2.ZERO
var state := MOVE
var double_jump = 1
var buffered_jump = false
var coyote_jump = false


#use onready to make sure the resource is loaded before trying to be used
onready var animatedSprite: = $AnimatedSprite
onready var ladderCheck: = $LadderCheck
onready var jumpBufferTimer: = $JumpBufferTimer
onready var coyoteJumpTimer: = $CoyoteJumpTimer
onready var remoteTransform2D: = $RemoteTransform2D

	# load the default sprite frames
	#animatedSprite.frames = load("res://PlayerGreenSkin.tres")
	
func _physics_process(_delta):
	
	var input = Vector2.ZERO
	#input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.x = Input.get_axis("ui_left", "ui_right") # same as above
	input.y = Input.get_axis("ui_up", "ui_down")
	
	match state:
		MOVE: move_state(input)
		CLIMB: climb_state(input)
	
	# check if hotkey was pressed	
	hot_key_pressed()


func connect_camera(camera):
	var camera_path = camera.get_path()
	remoteTransform2D.remote_path = camera_path


func move_state(input):
	
	if is_on_ladder() and Input.is_action_pressed("ui_up"):
		state = CLIMB
		
	
	apply_gravity()
	if not horizontal_move(input):
		apply_friction()
		animatedSprite.animation = "Idle"
	else:
		apply_acceleration(input.x)
		animatedSprite.animation = "Run"
		
		animatedSprite.flip_h = input.x > 0 #flip the sprite depending on input direction
	
	if is_on_floor():
		reset_double_jump()
	else:
		animatedSprite.animation = "Jump"		
		
	if can_jump():
		input_jump()
		
	else:
		input_jump_release()
		input_double_jump()
		buffer_jump()
		fast_fall()

	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()
	
	velocity = move_and_slide(velocity, Vector2.UP)
	var just_landed = is_on_floor() and was_in_air
	if just_landed:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1
	var just_left_ground = not is_on_floor() and was_on_floor
	if just_left_ground and velocity.y >= 0:
		coyote_jump = true
		coyoteJumpTimer.start()

func player_die():
	SoundPlayer.play_sound(SoundPlayer.HURT)
	queue_free()
	Events.emit_signal("player_died")
	
func input_jump():
	if Input.is_action_just_pressed("ui_jump") or buffered_jump:
		SoundPlayer.play_sound(SoundPlayer.JUMP)
		velocity.y = moveData.JUMP_FORCE
		buffered_jump = false
		
func input_jump_release():
	if Input.is_action_just_released("ui_jump") and velocity.y < moveData.JUMP_RELEASE_FORCE:
		velocity.y = moveData.JUMP_RELEASE_FORCE

func input_double_jump():
	if Input.is_action_just_pressed("ui_jump") and double_jump > 0:
		SoundPlayer.play_sound(SoundPlayer.JUMP)
		velocity.y = moveData.JUMP_FORCE
		double_jump -= 1

func buffer_jump():
	if Input.is_action_just_pressed("ui_jump"):
		buffered_jump = true
		jumpBufferTimer.start()

func fast_fall():
	if velocity.y > 0:
		velocity.y += moveData.ADDITIONAL_FALL_GRAVITY

func horizontal_move(input):
	return input.x != 0
	
func hot_key_pressed():
	if Input.is_action_just_pressed("die"):
		player_die()
	
func can_jump():
	return is_on_floor() or coyote_jump

func reset_double_jump():
	double_jump = moveData.DOUBLE_JUMP_COUNT
	
func climb_state(input):
	if not is_on_ladder(): state = MOVE
	if input.length() != 0:
		animatedSprite.animation = "Run"
	else:
		animatedSprite.animation = "Idle"
	velocity = input * 50
	velocity = move_and_slide(velocity, Vector2.UP)	

func is_on_ladder() -> bool:
	if not ladderCheck.is_colliding(): return false
	var collider = ladderCheck.get_collider()
	if not collider is Ladder: return false
	return true
	

		
func apply_gravity():
	velocity.y += moveData.GRAVITY	
	velocity.y = min(velocity.y, 300)

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, moveData.FRICTION)

func apply_acceleration(amount):
	velocity.x = move_toward(velocity.x, moveData.MAX_SPEED * amount, moveData.ACCELERATION)

func _on_JumpBufferTimer_timeout():
	buffered_jump = false

func _on_CoyoteJumpTimer_timeout():
	coyote_jump = false


