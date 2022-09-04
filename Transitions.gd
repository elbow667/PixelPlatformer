extends CanvasLayer

onready var animationplayer = $AnimationPlayer

signal transition_completed

func play_exit_transition():
	animationplayer.play("ExitLevel")

func play_enter_transition():
	animationplayer.play("EntryLevel")



func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal("transition_completed")
