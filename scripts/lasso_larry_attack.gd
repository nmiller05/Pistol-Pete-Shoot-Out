extends State
class_name LassoLarryAttack

@export var enemy: CharacterBody2D
@export var projectile_scene: PackedScene
@export var attack_duration := 1.0
@export var attack_range_min := 80.0
@export var attack_range_max := 100.0
@export var attack_height_tolerance := 40.0
var player: CharacterBody2D
var sprite: AnimatedSprite2D
var state_timer := 0.0

func Enter():
	player = get_tree().get_first_node_in_group("Player")
	sprite = enemy.get_node_or_null("AnimatedSprite2D")
	
	enemy.velocity.x = 0  # Stop moving
	
	# Face the player immediately when entering
	var direction = player.global_position - enemy.global_position
	if sprite and direction.x != 0:
		sprite.flip_h = direction.x < 0
	
	if sprite:
		sprite.play("attack")  # or "Attack"
	
	shoot_projectile()
	state_timer = attack_duration

func Update(delta: float):
	state_timer -= delta

func Physics_Update(_delta: float):
	enemy.velocity.x = 0  # Keep boss stopped during attack
	
	var direction = player.global_position - enemy.global_position
	var horizontal_distance = abs(direction.x)
	var vertical_distance = abs(direction.y)
	
	# Only transition after attack duration is complete
	if state_timer <= 0:
		# If player moved out of vertical range, go back to Follow (chase them)
		if vertical_distance > attack_height_tolerance:
			Transitioned.emit(self, "Follow")
		# If player is too close horizontally, chase them
		elif horizontal_distance < attack_range_min:
			Transitioned.emit(self, "Follow")
		# If player is too far horizontally, go idle or follow
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
