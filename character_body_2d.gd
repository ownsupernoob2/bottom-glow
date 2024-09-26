extends CharacterBody2D
#wassup gigidty gang, just remember to change the sprite for the point light to whatever u like, 
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# change time it takes for the effect to disspeaear
const GLOW_FADE_DURATION = 0.3 

@onready var glow_container = $"../GlowContainer"
@onready var tween: Tween
@onready var glow_light: PointLight2D = $"../GlowContainer/PointLight2D"

# how bright u want it?
var max_glow_energy = 2.0  
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var last_floor_position: Vector2

func _ready():
	glow_light.energy = 0 
	last_floor_position = global_position

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

	# check if wve just landed on a new floor
	if not was_on_floor and is_on_floor():
		last_floor_position = global_position
		# make sure it only follows horozontally not virtucally
		glow_container.global_position = last_floor_position

	# update horiontal position of the light
	glow_container.global_position.x = global_position.x

	# magical if condition 😱
	if is_on_floor():
		fade_glow(true)
	else:
		fade_glow(false)

# tween is basically allows you to control the rate of a value changing by selecting end value, transition duration and idk just it wortks and its cool.
func fade_glow(fade_in: bool):
	if tween and tween.is_valid():
		tween.kill()  

	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	if fade_in:
		print("oh my gyat it works!")
		tween.tween_property(glow_light, "energy", max_glow_energy, GLOW_FADE_DURATION)
	else:
		tween.tween_property(glow_light, "energy", 0, GLOW_FADE_DURATION)
