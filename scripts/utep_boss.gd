extends CharacterBody2D
class_name UTEP

@export var gravity := 20.0
@export var jump_velocity := -375.0
@export var damage := 10
@export var max_health := 10
var health := max_health

@onready var collision_shape_2d: CollisionShape2D = $"../Borders/EndBorder/CollisionShape2D"
@onready var collision_shape_2d_b: CollisionShape2D = $"../Borders/BossBorder/CollisionShape2D"

@onready var state_machine: Node = $"State Machine"

@onready var scream: AudioStreamPlayer2D = $Scream

@onready var death_timer: Timer = $DeathTimer

func apply_gravity(_delta: float):
	if not is_on_floor():
		velocity.y += gravity

func jump():
	if is_on_floor():
		velocity.y = jump_velocity

# This detects bullets (Area2D) hitting the boss
func _on_area_2d_area_entered(area: Area2D) -> void:
	health -= 1
	check_death()
	area.queue_free()
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0)
	tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 1)

func check_death():
	if health <= 0:
		#print("Boss defeated!")
		collision_shape_2d.set_deferred("disabled", true)
		collision_shape_2d_b.set_deferred("disabled", true)
		scream.play(0.88)
		death_timer.start()

# This is for the boss damaging the player (keep your existing damage area)
func _on_area_2d_body_entered(body: Node2D) -> void:
	if 'get_damage' in body:
		body.get_damage(damage)


func _on_death_timer_timeout() -> void:
	queue_free()
