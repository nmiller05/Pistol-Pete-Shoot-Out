extends State
class_name Follow

@export var enemy: CharacterBody2D
@export var move_speed := 50.0
@export var detection_distance := 250.0
@export var jump_check_interval := 0.3
@export var attack_range_min := 20.0  # Very close
@export var attack_range_max := 50.0  # Very close
@export var ideal_distance := 35.0  # NEW: Sweet spot for attacking
@export var attack_height_tolerance := 40.0
@export var retreat_distance := 15.0  # NEW: If closer than this, back away

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
		sprite.play("Walk")
	jump_timer = 0.0
	
func Physics_Update(delta: float):
	player = get_tree().get_first_node_in_group("Player")
	var direction = player.global_position - enemy.global_position
	var distance = direction.length()
	var horizontal_distance = abs(direction.x)
	var vertical_distance = abs(direction.y)
	
	jump_timer += delta
	
	# Only attack if player is at similar height AND in horizontal range
	if horizontal_distance >= attack_range_min and horizontal_distance <= attack_range_max and vertical_distance <= attack_height_tolerance:
		Transitioned.emit(self, "Attack")
		return
	
	# Check if too far away overall
	if distance > detection_distance:
		Transitioned.emit(self, "Idle")
		return
	
	# NEW: Distance-keeping logic
	var move_dir = 0.0
	
	# If player is too close, RETREAT (move away)
	if horizontal_distance < retreat_distance:
		move_dir = -sign(direction.x)  # Move opposite direction
		if sprite:
			sprite.flip_h = sign(direction.x) < 0  # Still face the player
	
	# If player is too far, APPROACH
	elif horizontal_distance > attack_range_max:
		move_dir = sign(direction.x)  # Move toward player
		if sprite:
			sprite.flip_h = move_dir < 0
	
	# If in ideal range but not perfect, adjust position slightly
	elif horizontal_distance < ideal_distance:
		move_dir = -sign(direction.x) * 0.5  # Slow retreat
		if sprite:
			sprite.flip_h = sign(direction.x) < 0
	
	elif horizontal_distance > ideal_distance:
		move_dir = sign(direction.x) * 0.5  # Slow approach
		if sprite:
			sprite.flip_h = move_dir < 0
	
	# If at ideal distance, stop moving horizontally
	else:
		move_dir = 0
		if sprite:
			sprite.flip_h = sign(direction.x) < 0  # Face player
	
	enemy.velocity.x = move_dir * move_speed
	
	# Jump logic - jump if player is above or if backing into wall
	if enemy.is_on_wall() and enemy.is_on_floor() and jump_timer >= jump_check_interval:
		enemy.jump()
		jump_timer = 0.0
	
	if direction.y < -50 and enemy.is_on_floor() and jump_timer >= jump_check_interval:
		enemy.jump()
		jump_timer = 0.0
