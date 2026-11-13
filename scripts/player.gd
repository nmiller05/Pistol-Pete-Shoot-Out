extends CharacterBody2D

var health := 100
var vulnerable := true
var direction_x := 0.0
var facing_right = true
@export var speed = 130
var can_shoot := true
var can_buy = true

var maxAmmo = 6
var loadedBullets = maxAmmo
var ammo = 0
var coins = 0

@onready var death: AudioStreamPlayer = $SFX/Death
@onready var damage: AudioStreamPlayer = $SFX/Damage
@onready var jump: AudioStreamPlayer = $SFX/Jump
@onready var gun_shot: AudioStreamPlayer = $SFX/GunShot
@onready var reload: AudioStreamPlayer = $SFX/Reload
@onready var empty_gun: AudioStreamPlayer = $SFX/EmptyGun


signal shoot(pos: Vector2, direction: bool)
signal purchase(text: String)

func _physics_process(_delta):
	
	get_input()
	apply_gravity()
	get_facing_direction()
	get_animation()
	
	velocity.x = direction_x * speed
	move_and_slide()

# All input handling
func get_input():
	direction_x = Input.get_axis("left", "right")
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -375.0
		jump.play()
	
	if Input.is_action_just_pressed("shoot") and loadedBullets  == 0:
		empty_gun.play()
	
	if Input.is_action_just_pressed("shoot") and can_shoot:
		can_shoot = false
		gun_shot.play(0.12)
		shoot.emit(global_position, facing_right)
		$Timers/SecondShotTimer.start()
		$Timers/CooldownTimer.start()
		$Timers/FireTimer.start()
		$Fire.get_child(int(facing_right)).show()
		loadedBullets -= 1
	
	if Input.is_action_just_pressed("reload") and ammo > 0 and loadedBullets < maxAmmo:
		if ammo + loadedBullets > maxAmmo:
			ammo -= maxAmmo - loadedBullets
			loadedBullets = maxAmmo
			can_shoot = true
		else:
			loadedBullets += ammo
			ammo = 0
			can_shoot = true
		
		reload.play()
	if Input.is_action_just_pressed("purchase_health") and can_buy:
		purchase_health()
		
	if Input.is_action_just_pressed("purchase_ammo") and can_buy:
		purchase_ammo()

func apply_gravity():
	velocity.y += 20

func get_facing_direction():
	if direction_x != 0:
		facing_right = direction_x >= 0

func get_animation():
	var animation = 'idle'
	if not is_on_floor():
		animation = 'jump'
	elif direction_x != 0:
		animation = 'walk'
	$AnimatedSprite2D.animation = animation
	$AnimatedSprite2D.flip_h = not facing_right

func _on_cooldown_timer_timeout() -> void:
	if loadedBullets <= 0:
			can_shoot = false
	else:
		can_shoot = true

func _on_wait_timer_timeout() -> void:
	shoot.emit(global_position, facing_right)
	gun_shot.play(0.12)
	$Timers/FireTimer.start()
	$Fire.get_child(int(facing_right) + 2).show()

func _on_fire_timer_timeout() -> void:
	for child in $Fire.get_children():
		child.hide()

func get_damage(amount):
	if vulnerable:
		health -= amount
		# This tween handles the flashing color when getting hit
		# Tweens between the damage color (white) and orignial color
		var tween = create_tween()
		tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 1.0, 0)
		tween.tween_property($AnimatedSprite2D, "material:shader_parameter/amount", 0.0, 1)
		vulnerable = false
		$Timers/InvincibilityTimer.start()
		
		if health - amount <= 0:
			health = 0
			can_buy = false
			death.play()
			Engine.time_scale = 0.5
			get_node("CollisionShape2D").queue_free()
			$Timers/DeathTimer.start()
		
		damage.play()

func _on_invincibility_timer_timeout() -> void:
	vulnerable = true

func _on_death_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().get_first_node_in_group('game').level_load()

func update_coin_count():
	coins += 1
	
func purchase_health():
	if coins >= 1:
		if health < 100:
			coins -= 1
			health += 10
			#print("Purchased 10 health!")
			purchase.emit("Purchased 10 health!")
			
			#print("You have ", coins, " coin(s) remaining.")
		else:
			#print("Already at max health.")
			purchase.emit("Already at max health.")
	else:
		#print("Not enough coins.")
		purchase.emit("Not enough coins.")
		
func purchase_ammo():
	if coins >= 1:
		coins -= 1
		ammo += 3
		#print("Purchased 6 ammo!")
		purchase.emit("Purchased 6 ammo!")
		#print("You have ", coins, " coin(s) remaining.")
	else:
		#print("Not enough coins.")
		purchase.emit("Not enough coins.")
