extends Area2D

@export var speed := 200.0
@export var damage := 10
@export var lifetime := 5.0  # Destroy after 5 seconds
var direction := Vector2.RIGHT

func _ready():
	body_entered.connect(_on_body_entered)
	# Auto-destroy after lifetime
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body: Node2D):
	print("Projectile hit: ", body.name)
	if body.has_method("get_damage"):
		print("Dealing ", damage, " damage to player!")
		body.get_damage(damage)
		queue_free()  # Destroy projectile after hitting
	# Also destroy if hitting walls/terrain
	elif body is TileMap or body.get_collision_layer_value(1):  # Layer 1 is terrain
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()  # Clean up when off screen
