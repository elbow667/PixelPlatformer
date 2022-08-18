extends Path2D


enum ANIMATION_TYPE {
	LOOP,
	BOUNCE
}

export (ANIMATION_TYPE) var animation_type

onready var animationPlayer: = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	play_updated_animation()

func play_updated_animation():
	match animation_type:
		ANIMATION_TYPE.LOOP: animationPlayer.play("MoveAlongPathLoop")
		ANIMATION_TYPE.BOUNCE: animationPlayer.play("MoveAlongPathBounce")
	
			



