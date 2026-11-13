extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if 'get_damage' in body:
		body.vulnerable = true
		body.get_damage(body.health)
