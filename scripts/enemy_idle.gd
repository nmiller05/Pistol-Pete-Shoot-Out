extends State
class_name EnemyIdle

@export var enemy: CharacterBody2D
@export var move_speed := 50.0  # Increased for ground movement
var player: CharacterBody2D	
var sprite: AnimatedSprite2D
var move_direction : float  # Changed to float for X only
var wander_time : float

func randomize_wander():
	move_direction = randf_range(-1, 1)  # Only X direction
	wander_time = randf_range(1, 3)
	
func Enter():
	player = get_tree().get_first_node_in_group("Player")
	if enemy.has_node("AnimatedSprite2D"):
		enemy.get_node("AnimatedSprite2D").play("Idle")
	randomize_wander()

func Update(delta: float):
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()

func Physics_Update(_delta: float):
	if enemy:
		# Only set X velocity, preserve Y for gravity
		enemy.velocity.x = move_direction * move_speed
	
	var direction = player.global_position - enemy.global_position
	
	if direction.length() < 200:
		Transitioned.emit(self, "Follow")
