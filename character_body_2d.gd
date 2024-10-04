extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
# Change time it takes for the effect to disappear
const FADE_DURATION = 0.2 
# Adjust this value to control how quickly the fade effect catches up to the player (0.0 - 1.0)
const LAG_FACTOR = 0.1

@onready var fade_container = $"../GlowContainer"
@onready var tween: Tween
@onready var fade_sprite: Sprite2D = $"../GlowContainer/FadeSprite"

# How opaque you want it at maximum?
var max_opacity = 0.5 
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_floor_position: Vector2

func _ready():
	fade_sprite.modulate.a = 0  # Set initial opacity to 0
	last_floor_position = global_position
	fade_container.global_position = last_floor_position

func _physics_process(delta: float) -> void:
	var was_on_floor = is_on_floor()
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	
	# Update fade container position with lag
	if is_on_floor():
		var target_x = global_position.x
		fade_container.global_position.x = lerp(fade_container.global_position.x, target_x, LAG_FACTOR)
		last_floor_position = fade_container.global_position
		fade_spritei(true)
	else:
		fade_container.global_position = last_floor_position
		fade_spritei(false)
	
	# Check if we've just landed on a new floor
	if not was_on_floor and is_on_floor():
		fade_container.global_position.y = global_position.y

func fade_spritei(fade_in: bool):
	if tween and tween.is_valid():
		tween.kill()  
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	if fade_in:
		print("Oh my gyat it works!")
		tween.tween_property(fade_sprite, "modulate:a", max_opacity, FADE_DURATION)
	else:
		tween.tween_property(fade_sprite, "modulate:a", 0, FADE_DURATION)
