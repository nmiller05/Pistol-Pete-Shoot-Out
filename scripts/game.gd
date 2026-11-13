extends Node

var level = 1;
const FILE_BEGIN = "res://scenes/level"
var current_level
var global_coins = 0

@onready var player = get_tree().get_first_node_in_group('Player')
@onready var ui: CanvasLayer = $UI
@onready var purchase_timer: Timer = $PurchaseTimer

func _ready() -> void:
	current_level = $"Level 1"

func on_level_end() -> void:
	level = level + 1
	global_coins = player.coins
	level_load()

func level_load() -> void:
	current_level.queue_free()
	
	var next_level_path = FILE_BEGIN + str(level) + ".tscn"
	current_level = load(next_level_path).instantiate()
	current_level.onEnd.connect(on_level_end)
	add_child.call_deferred(current_level)
	await get_tree().create_timer(0.01).timeout
	player = get_tree().get_first_node_in_group('Player')
	player.coins = global_coins
	$UI/Coins.text = str(global_coins)
	count_down.call_deferred()
	current_level.purchase.connect(_on_level_purchase)


func count_down() -> void:
	get_tree().paused = true
	var count_time = 0.5
	$UI/CountDown.text = "3"
	await get_tree().create_timer(count_time).timeout
	$UI/CountDown.text = "2"
	await get_tree().create_timer(count_time).timeout
	$UI/CountDown.text = "1"
	await get_tree().create_timer(count_time).timeout
	$UI/CountDown.text = "GO!"
	await get_tree().create_timer(0.3).timeout
	$UI/CountDown.text = ""
	get_tree().paused = false

func _on_level_1_purchase(text: String) -> void:
	$UI/Purchase.text = text
	purchase_timer.start()

func _on_level_purchase(text: String) -> void:
	$UI/Purchase.text = text
	purchase_timer.start()

func _on_purchase_timer_timeout() -> void:
	$UI/Purchase.text = ""
