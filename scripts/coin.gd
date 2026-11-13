extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _process(delta: float) -> void:
	position.y += sin(Time.get_ticks_msec() / 150.0) * 10 * delta

func _on_body_entered(player: Node2D) -> void:
	
	if player.name == "Player":
		animation_player.play('pickup')
		player.update_coin_count()
	
