extends CanvasLayer

@onready var player = get_tree().get_first_node_in_group('Player')

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	player = get_tree().get_first_node_in_group('Player')
	$MarginContainer/ProgressBar.value = player.health
	$Bullets.text = str((player.loadedBullets) * 2) + "/" + str((player.ammo) * 2)
	$Coins.text = str(player.coins)
	
