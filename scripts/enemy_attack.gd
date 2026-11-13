extends State
class_name EnemyAttack

@export var enemy: CharacterBody2D
@export var projectile_scene: PackedScene
@export var attack_duration := 1.0
@export var attack_range_min := 20.0  # Very close
@export var attack_range_max := 50.0  # Very close
@export var ideal_distance := 35.0  # NEW: Sweet spot distance
@export var attack_height_tolerance := 40.0
@export var move_speed := 30.0  # NEW: Slower movement while attacking

var player: CharacterBody2D
var sprite: AnimatedSprite2D
var state_timer := 0.0

func Enter():
	# Auto-find enemy if not set
	if not enemy:
		enemy = get_parent().get_parent() as CharacterBody2D
	
	player = get_tree().get_first_node_in_group("Player")
	sprite = enemy.get_node_or_null("AnimatedSprite2D") if enemy else null
	
	# Face the player immediately when entering
	var direction = player.global_position - enemy.global_position
	if sprite and direction.x != 0:
		sprite.flip_h = direction.x < 0
	
	if sprite:
		sprite.play("Attack")
	
	shoot_projectile()
	state_timer = attack_duration

func Update(delta: float):
	state_timer -= delta

func Physics_Update(_delta: float):
	# NEW: Keep adjusting position while attacking
	var direction = player.global_position - enemy.global_position
	var horizontal_distance = abs(direction.x)
	var vertical_distance = abs(direction.y)
	
	# Maintain ideal distance even while attacking
	var move_dir = 0.0
	if horizontal_distance < attack_range_min:
		# Too close, back away
		move_dir = -sign(direction.x) * 0.7
	elif horizontal_distance < ideal_distance:
		# Slightly too close, gentle retreat
		move_dir = -sign(direction.x) * 0.3
	elif horizontal_distance > ideal_distance and horizontal_distance < attack_range_max:
		# Slightly too far, gentle approach
		move_dir = sign(direction.x) * 0.3
	else:
		# At ideal distance, stay still
		move_dir = 0
	
	enemy.velocity.x = move_dir * move_speed
	
	# Always face the player
	if sprite and direction.x != 0:
		sprite.flip_h = direction.x < 0
	
	# Only transition after attack duration is complete
	if state_timer <= 0:
		# If player moved out of vertical range, go back to Follow (chase them)
		if vertical_distance > attack_height_tolerance:
			Transitioned.emit(self, "Follow")
		# If player is too close, retreat via Follow state
		elif horizontal_distance < attack_range_min * 0.8:  # Give some buffer
			Transitioned.emit(self, "Follow")
		# If player is too far, chase via Follow state
		elif horizontal_distance > attack_range_max:
			if horizontal_distance > 200:
				Transitioned.emit(self, "Idle")
			else:
				Transitioned.emit(self, "Follow")
		# If still in good range, shoot again
		else:
			shoot_projectile()
			state_timer = attack_duration

func shoot_projectile():
	if not projectile_scene:
		return
	
	var projectile = projectile_scene.instantiate()
	get_tree().root.add_child(projectile)
	projectile.global_position = enemy.global_position
	
	# Shoot based on sprite facing direction
	if sprite and sprite.flip_h:
		projectile.direction = Vector2.LEFT
		projectile.rotation = PI
	else:
		projectile.direction = Vector2.RIGHT
		projectile.rotation = 0

func Exit():
	state_timer = 0.0
