extends CharacterBody2D
class_name LassoLarry

@onready var explosion: AnimatedSprite2D = $Explosion
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var death_timer: Timer = $DeathTimer
@onready var damage_timer: Timer = $DamageTimer

@onready var explosion_audio: AudioStreamPlayer2D = $ExplosionAudio
@onready var scream: AudioStreamPlayer2D = $Scream

@onready var state_machine: Node = $"State Machine"

@onready var area_2d: Area2D = $Area2D

@export var gravity := 20.0
@export var jump_velocity := -375.0
@export var damage := 10
@export var max_health := 10
var health := max_health

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
		Engine.time_scale = 0.5
		scream.play()
		area_2d.queue_free()
		state_machine.queue_free()
		damage_timer.start()
		death_timer.start()
		#After this will be the code to end the game

# This is for the boss damaging the player (keep your existing damage area)
func _on_area_2d_body_entered(body: Node2D) -> void:
	if 'get_damage' in body:
		body.get_damage(damage)


func _on_death_timer_timeout() -> void:
	queue_free()
	get_tree().change_scene_to_file("res://scenes/end_screen.tscn")


func _on_damage_timer_timeout() -> void:
	explosion.visible = true
	explosion.play()
	explosion_audio.play()
	animated_sprite_2d.visible = false
