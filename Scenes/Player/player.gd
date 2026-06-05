extends CharacterBody2D

#Variables that are for the physics
var accel = 20
var deaccel = 0.2
var topSpeed = 1000
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var state : States = States.RUNNING
var jumpTime = 0.1
var jumpAllow : float
var jumpForce = 775
var gravityMultiplier = 1
var curRunDir = 1
var canMove := true
@export var knockbacktimer : Timer
@export var wallCollider : Area2D
@export var animation : AnimatedSprite2D
@export var doubleJumpTimer : Timer
@export var healthBar : TextureProgressBar

enum States { RUNNING, JUMPING, DOUBLEJUMPED, KNOCKBACK, WALLSLIDING, GROUDPOUND}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	state = States.RUNNING
	velocity.x = 0
	
func _process(delta: float) -> void:
	if curRunDir == -1:
		wallCollider.rotation_degrees = 180
	else:
		wallCollider.rotation_degrees = 0
	if is_on_floor():
		curRunDir = 1
		doubleJumpTimer.start()
	else:
		pass
	

func _physics_process(delta: float) -> void:
	#Gravity
	if not is_on_floor() and not state in [States.GROUDPOUND]:
		velocity.y += (gravity * gravityMultiplier) * delta
	#Running Motion
	if state in [States.RUNNING,States.KNOCKBACK,States.JUMPING]:
		velocity.x += accel * curRunDir
		velocity.x = clamp(velocity.x,-topSpeed,topSpeed)
	#Checking when to allow *state* to be *States.RUNNING*
	if is_on_floor() and state not in [States.KNOCKBACK, States.RUNNING]:
		set_state(States.RUNNING)
	#Jumping
	if is_on_floor() and state == States.RUNNING and Input.is_action_just_pressed("jump"):
		velocity.y = -jumpForce
		set_state(States.JUMPING)
	#Jumping on a wall
	if state == States.WALLSLIDING and Input.is_action_just_pressed("jump"):
		curRunDir *= -1
		velocity.y = -jumpForce
		velocity.x = topSpeed * curRunDir
	#Allow doublejump when in air
	if not is_on_floor() and Input.is_action_just_pressed("jump") and doubleJumpTimer.is_stopped() and not state == States.DOUBLEJUMPED:
		set_state(States.DOUBLEJUMPED)
	if not is_on_floor() and Input.is_action_just_pressed("down"):
		set_state(States.GROUDPOUND)
		
	if canMove:
		move_and_slide()
	
func set_state(new_state : States):
	var old_state = state
	state = new_state
	#Depending on the different states,
	#A certain action will be done in order to respond to the change in state.
	if new_state == States.KNOCKBACK:
		velocity.x = -5000
		healthBar.value -= 1
		knockbacktimer.start()
	if new_state == States.WALLSLIDING:
		gravityMultiplier = 0.5
	else:
		gravityMultiplier = 1
	#Ensure the Player is not softlocked when going from WALLSLIDING bugs
	if old_state == States.WALLSLIDING and new_state in [States.RUNNING, States.GROUDPOUND]:
		position.x -= 5
		set_state(States.KNOCKBACK)
	#Handle double-jumping
	if new_state == States.DOUBLEJUMPED:
		velocity.y = -jumpForce * 1.5
	if new_state == States.GROUDPOUND:
		velocity = Vector2.ZERO
		canMove = false
		var GPTimer = get_tree().create_timer(0.5)
		await GPTimer.timeout
		canMove = true
		velocity.y = 5000
	print(state)
	setAnimation(state)


func _on_wall_colider_body_entered(body: Node2D) -> void:
	if state == States.RUNNING:
		set_state(States.KNOCKBACK)
	if state in [States.JUMPING, States.DOUBLEJUMPED]:
		set_state(States.WALLSLIDING)

func _on_knockback_timeout() -> void:
	set_state(States.RUNNING)

func setAnimation(new_state):
	if new_state == States.RUNNING:
		animation.play("running")
	if new_state == States.JUMPING:
		animation.play("jumping")
	if new_state == States.KNOCKBACK:
		animation.play("knockback")
	if new_state == States.WALLSLIDING:
		animation.play("wallsliding")

func _on_wall_colider_body_exited(body: Node2D) -> void:
	if not is_on_floor():
		set_state(States.JUMPING)
