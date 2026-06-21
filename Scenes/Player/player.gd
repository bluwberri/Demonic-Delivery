class_name Player extends CharacterBody2D

#Variables that are for the physics
var accel = 20
var deaccel = 25
var topSpeed = 1000
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var state : States = States.RUNNING
var jumpTime = 0.1
var jumpAllow : float
var jumpForce = 800
var gravityMultiplier = 1
var curRunDir = 1
var canMove := true
var finishedStage := false
var bounce = 1.0
var shakingCam = false
@export var knockbacktimer : Timer
@export var animation : AnimatedSprite2D
@export var doubleJumpTimer : Timer
@export var healthBar : TextureProgressBar
@export var WallCollider : Area2D
@export var camera : Camera2D
@onready var label: Label = $CanvasLayer/UI/Speedometer/Label
@onready var transition_rect: ColorRect = $CanvasLayer/TransitionRect
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var label_2: Label = $CanvasLayer/UI/Label2
@onready var fire: GPUParticles2D = $Fire
@onready var smoke: GPUParticles2D = $Smoke
@onready var jump_effect: GPUParticles2D = $JumpEffect
@onready var walljumpFX: CPUParticles2D = $WallJump

#Sound Effects
const JUMPSOUND = preload("uid://dudy23shr2sge")
const HURTSOUND = preload("uid://q6s2q7bivp4")

#Stopwatch
var stopwatch = 0.0
var stopSW = false

#Finish Screen Elements
@onready var cover_gameplay: ColorRect = $CanvasLayer/FinishScreen/CoverGameplay
@onready var background: ColorRect = $CanvasLayer/FinishScreen/Background
@onready var finished: Label = $CanvasLayer/FinishScreen/Background/Finished
@onready var dmg: Label = $CanvasLayer/FinishScreen/Background/DMG
@onready var time: Label = $CanvasLayer/FinishScreen/Background/Time
@onready var overall: Label = $CanvasLayer/FinishScreen/Background/Overall
const PLAY_MENU = preload("uid://vgdy4hfm0xdb")

#Particle Images
const FIREY = preload("uid://bgl0kreygdmjw")
const SMOKEY = preload("uid://dkoxo2erqnqd5")
const FIRE = preload("uid://bxo6cvmpvpss6")
const SMOKE = preload("uid://b54ef0bgnfmm1")


enum States { RUNNING, JUMPING, DOUBLEJUMPED, KNOCKBACK, WALLSLIDING, GROUDPOUND}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stopwatch = 0.0
	WindowTransitions.continue_transition(transition_rect)
	healthBar.value = 5
	set_state(States.RUNNING)
	velocity.x = 0
	animation.play("running")

func _process(delta: float) -> void:
	if shakingCam:
		shakeCamera(350)
	else:
		resetCamera()
	if !stopSW:
		stopwatch += delta
	label_2.text = str( round(stopwatch) )
	bounce = clampf(bounce,1.0,2.0)
	label.text = str(int(velocity.x)/10)
	if curRunDir == -1:
		animation.flip_h = true
		WallCollider.rotation_degrees = 180
	else:
		WallCollider.rotation_degrees = 0
		animation.flip_h = false
	if is_on_floor():
		curRunDir = 1
		doubleJumpTimer.start()
	else:
		pass
	if is_on_floor():
		var smallTimer = get_tree().create_timer(0.1)
		await smallTimer.timeout
		if is_on_floor():
			bounce = 1.0
	

func _physics_process(delta: float) -> void:
	#Gravity
	if not is_on_floor():
		velocity.y += (gravity * gravityMultiplier) * delta
	#Running Motion
	if state in [States.RUNNING,States.KNOCKBACK,States.JUMPING, States.DOUBLEJUMPED] and velocity.x < topSpeed:
		velocity.x += accel * curRunDir
	elif velocity.x > topSpeed and not state in [States.JUMPING, States.DOUBLEJUMPED, States.GROUDPOUND]:
		velocity.x -= deaccel
	velocity.x = clampf(velocity.x,-topSpeed,topSpeed*10)
	#Checking when to allow *state* to be *States.RUNNING*
	if is_on_floor() and state not in [States.KNOCKBACK, States.RUNNING]:
		set_state(States.RUNNING)
		
	if canMove:
		#Jumping on a wall
		if state == States.WALLSLIDING and Input.is_action_just_pressed("jump"):
			curRunDir *= -1
			velocity.y = -jumpForce
			velocity.x = topSpeed * curRunDir
			doubleJumpTimer.start()
			set_state(States.JUMPING)
		#Allow doublejump when in air
		if not is_on_floor() and Input.is_action_just_pressed("jump") and doubleJumpTimer.is_stopped() and not state in [States.DOUBLEJUMPED, States.GROUDPOUND]:
			set_state(States.DOUBLEJUMPED)
		if not is_on_floor() and Input.is_action_just_pressed("down") and not state in [States.WALLSLIDING]:
			set_state(States.GROUDPOUND)
		#Jumping
		if is_on_floor() and state == States.RUNNING and Input.is_action_just_pressed("jump"):
			velocity.y = -jumpForce
			set_state(States.JUMPING)
	if not finishedStage:
		move_and_slide()
	
func set_state(new_state : States):
	var old_state = state
	state = new_state
	#Depending on the different states,
	#A certain action will be done in order to respond to the change in state.
	if new_state == States.KNOCKBACK:
		velocity.x = -topSpeed * curRunDir
		reduceHealth(1)
		knockbacktimer.start()
	if new_state == States.WALLSLIDING:
		gravityMultiplier = 0.5
	else:
		gravityMultiplier = 1
	
	#Handle Particles/Effects
	if new_state in [States.RUNNING]:
		smoke.emitting = true
		fire.emitting = false
		
	elif new_state in [States.DOUBLEJUMPED]:
		fire.restart()
		smoke.emitting = false
		fire.emitting = true
	elif new_state in [States.JUMPING] and old_state not in [States.WALLSLIDING]:
		jump_effect.restart()
		jump_effect.emitting = true
		smoke.emitting = false
		fire.emitting = false
	elif new_state in [States.JUMPING] and old_state in [States.WALLSLIDING]:
		if curRunDir < 0:
			walljumpFX.angle_max = 90
			walljumpFX.angle_min = 90
			walljumpFX.position.x = 20
		else:
			walljumpFX.angle_max = -90
			walljumpFX.angle_min = -90
			walljumpFX.position.x = -20
		walljumpFX.restart()
		walljumpFX.emitting = true
		
	
	#Ensure the Player is not softlocked when going from WALLSLIDING bugs
	if old_state == States.WALLSLIDING and new_state in [States.RUNNING, States.GROUDPOUND]:
		position.x -= 5
		set_state(States.KNOCKBACK)
	#Handle double-jumping
	if new_state == States.DOUBLEJUMPED:
		velocity.y = -jumpForce * 1.5
	if new_state == States.GROUDPOUND:
		gravityMultiplier = 5
	if old_state == States.GROUDPOUND and new_state == States.RUNNING:
		fire.restart()
		smoke.emitting = false
		fire.emitting = true
		shakingCam = true
		state = States.JUMPING
		velocity.x += 1000 
		velocity.y -= 750 * bounce
		bounce += 0.5
		await get_tree().create_timer(0.25).timeout
		shakingCam = false
	#print current state
	#
	setAnimation(state)
	setSound(state)
	print(States.keys()[state])

func _on_knockback_timeout() -> void:
	set_state(States.RUNNING)

func setAnimation(new_state):
	if new_state == States.RUNNING:
		animation.play("running")
	if new_state == States.JUMPING:
		animation.play("jumping")
	if new_state == States.DOUBLEJUMPED:
		animation.play("doublejump")
	if new_state == States.KNOCKBACK:
		animation.play("knockback")
	if new_state == States.WALLSLIDING:
		animation.play("wallsliding")

func setSound(new_state):
	if new_state == States.JUMPING:
		audio_stream_player_2d.stream = JUMPSOUND
		audio_stream_player_2d.play()
	if new_state == States.DOUBLEJUMPED:
		audio_stream_player_2d.stream = JUMPSOUND
		audio_stream_player_2d.play()
	if new_state == States.KNOCKBACK:
		audio_stream_player_2d.stream = HURTSOUND
		audio_stream_player_2d.play()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if state == States.WALLSLIDING:
		set_state(States.JUMPING)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if state in [States.RUNNING, States.GROUDPOUND, States.KNOCKBACK]:
		set_state(States.KNOCKBACK)
	elif state in [States.JUMPING, States.DOUBLEJUMPED]:
		set_state(States.WALLSLIDING)
	

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "Winning Area":
		stopSW = true
		var tween = get_tree().create_tween()
		var tween1 = get_tree().create_tween()
		var tween3 = get_tree().create_tween()
		canMove = false
		tween.tween_property(camera,"position_smoothing_speed",0.5,0.5).set_ease(Tween.EASE_IN_OUT)
		tween1.tween_property(camera,"zoom",Vector2(2,2),0.5).set_ease(Tween.EASE_IN_OUT)
		if is_on_floor():
			velocity.y = -jumpForce * 1.75
		animation.play("victory")
		tween3.tween_property(Engine,"time_scale",0.1,0.5).set_ease(Tween.EASE_IN_OUT)
		await get_tree().create_timer(0.75).timeout
		finishedStage = true
		Engine.time_scale = 1
		calculateScore()
		await get_tree().create_timer(10).timeout
		await WindowTransitions.start_transition(transition_rect)
		get_parent().add_sibling(PLAY_MENU.instantiate())
		get_parent().queue_free()
	else:
		set_state(States.KNOCKBACK)

func calculateScore():
	WindowTransitions.showFinishScreen(cover_gameplay,background)
	var potentialScore = 0
	var potentialScore2 = 0
	var dmgtaken = 5 - healthBar.value
	time.text = "Time Taken : " + str( snapped(stopwatch, 0.1) )
	dmg.text = "Damage Taken : " + str(dmgtaken)
	
	potentialScore = (get_parent().timeTaken / stopwatch)/2
	potentialScore = clampf(potentialScore,0.0,0.5)
	for health in healthBar.value:
		potentialScore2 += 0.1
	var fullscore = snapped((potentialScore + potentialScore2) * 5,0.1)
	
	overall.text = "Overall :
		" + str(fullscore) + " / 5.0"

func reduceHealth(dmg):
	var tween = get_tree().create_tween()
	tween.tween_property(healthBar,"value",healthBar.value - dmg,0.5).set_ease(Tween.EASE_OUT)
	
func shakeCamera(intensity):
	var randomX = randf_range(-intensity,intensity)
	var randomY = randf_range(-intensity,intensity)
	camera.position.x = randomX
	camera.position.y = randomY

func resetCamera():
	camera.position = Vector2.ZERO
