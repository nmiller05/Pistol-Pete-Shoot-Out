extends Area2D

@onready var pickup: AudioStreamPlayer = $SFX/Pickup
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _process(delta: float) -> void:
	position.y += sin(Time.get_ticks_msec() / 150.0) * 10 * delta

func _on_body_entered(body) -> void:
	if 'ammo' in body:
		body.ammo += 1
	animation_player.play("pickup")
