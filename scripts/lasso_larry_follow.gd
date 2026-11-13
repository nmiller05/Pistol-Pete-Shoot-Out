extends State
class_name LassoLarryFollow

@export var enemy: CharacterBody2D
@export var move_speed := 100
@export var detection_distance := 175.0
@export var jump_check_interval := 0.3
@export var attack_range_min := 1.0
@export var attack_range_max := 5.0

var player: CharacterBody2D
var jump_timer := 0.0
var sprite: AnimatedSprite2D

func Enter():
	# Auto-find enemy if not set
	if not enemy:
		enemy = get_parent().get_parent() as CharacterBody2D
	
	player = get_tree().get_first_node_in_group("Player")
	sprite = enemy.get_node_or_null("AnimatedSprite2D") if enemy else null
	if sprite:
		sprite.play("running")
	jump_timer = 0.0
	
func Physics_Update(delta: float):
	player = get_tree().get_first_node_in_group("Player")
	var direction = player.global_position - enemy.global_position
	var distance = direction.length()
	var horizontal_distance = abs(direction.x)
	
	jump_timer += delta
	
	# Only attack if player is at similar height AND in horizontal range
	if horizontal_distance >= attack_range_min and horizontal_distance <= attack_range_max:
		Transitioned.emit(self, "attack")
		return
	
	# Check if too far away overall
	if distance > detection_distance:
		Transitioned.emit(self, "idle")
		return
	
	var move_dir = sign(direction.x)
	enemy.velocity.x = move_dir * move_speed
	
	if sprite:
		sprite.flip_h = move_dir < 0
	# Jump logic - jump if player is above or if backing into wall
	if enemy.is_on_wall() and enemy.is_on_floor() and jump_timer >= jump_check_interval:
		enemy.jump()
		jump_timer = 0.0
	
	if direction.y < -50 and enemy.is_on_floor() and jump_timer >= jump_check_interval:
		enemy.jump()
		jump_timer = 0.0
