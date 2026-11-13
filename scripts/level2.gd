extends Node2D

const bullet_scene: PackedScene = preload("res://scenes/bullet.tscn")
signal purchase(text: String)
@warning_ignore("unused_signal")
signal onEnd;

func _on_player_shoot(pos: Vector2, facing_right: bool) -> void:
	var bullet = bullet_scene.instantiate()
	var direction = 1 if facing_right else -1
	bullet.direction = direction
	$Bullets.add_child(bullet)
	bullet.position = pos + Vector2(14 * direction, -13)


func _on_player_purchase(text: String) -> void:
	purchase.emit(text)
