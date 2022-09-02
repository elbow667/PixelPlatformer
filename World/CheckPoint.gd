extends Area2D

onready var animatedSprite: = $AnimatedSprite

# will only set the checkpoint if its active, by default its active
var active = true

func _on_CheckPoint_body_entered(body):
	if not body is Player: return
	if not active: return # if checkpoint is not active, ignore and exit script
	animatedSprite.play("Checked")
	active = false # once hit, set to false, no longer active
	Events.emit_signal("hit_checkpoint", position) # emit signal to update spawn_position in the world script
