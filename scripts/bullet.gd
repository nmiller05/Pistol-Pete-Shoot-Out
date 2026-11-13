extends Area2D

var direction := 1
@export var speed = 300
@export var damage = 10  # Add damage variable

func _ready():
	$Sprite2D.flip_h = direction < 0
	# Connect the body_entered signal

func _physics_process(delta: float) -> void:
	position.x += speed * direction * delta
