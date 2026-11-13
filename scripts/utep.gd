extends Node2D

var health := 6
const SPEED = 60
var direction = 1
var facing_right = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _process(delta: float) -> void:
	
	check_death()
	
	position.x += direction * SPEED * delta

func _on_area_entered(area: Area2D) -> void:
	health -= 1
	area.queue_free()
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0)
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 1)

func check_death():
	if health <= 0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if 'get_damage' in body:
		body.get_damage(10)

func _on_area_2d_body_entered(_body: Node2D) -> void:
	direction *= -1
	animated_sprite.flip_h = not animated_sprite.flip_h

func _on_right_cliff_area_body_exited(_body: Node2D) -> void:
	direction *= -1
	animated_sprite.flip_h = not animated_sprite.flip_h

func _on_left_cliff_area_body_exited(_body: Node2D) -> void:
	direction *= -1
	animated_sprite.flip_h = not animated_sprite.flip_h
