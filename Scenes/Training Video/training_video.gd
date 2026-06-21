extends Node2D

@onready var label: Label = $CanvasLayer/Label
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var player: Player = $Player
var slowdown = false
const timeTaken = 20

enum AreaPassed {AREA1,AREA2,AREA3,AREA4,AREA5,AREA6,NONE}
var currentArea := AreaPassed.AREA1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	backgroundSlowDown()
	changeTutorialText("Welcome to the Interactive Demonic Delivery Training Video! Please follow the instructions to ensure that you understand how to traverse as the fastest pizza delivery-boy who ever lived.")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if label.text:
	# OPTIONAL: Instead of +1 every frame, use a timer or a delta accumulator 
	# to control the speed (e.g., 1 character every 0.05 seconds).
		label.visible_characters += 1 

	# 2. Handle input during slowdown
	if slowdown and Input.is_action_just_pressed("jump") and label.text:
		if label.visible_ratio >= 1.0:
			# Text is fully displayed, so proceed
			backgroundSlowDown()
		else:
			# Text is still typing, so skip to the end
			label.visible_ratio = 1.0
			# CRITICAL: Update visible_characters so it matches the full text length
			label.visible_characters = label.text.length()

func backgroundSlowDown():
	if not slowdown:
		slowdown = true
		var tween = get_tree().create_tween()
		var tween2 = get_tree().create_tween()
		tween.tween_property(color_rect,"color",Color(0,0,0,0.5),0.5)
		tween2.tween_property(Engine,"time_scale",0.1,0.1)
		player.canMove = false
	else:
		slowdown = false
		var tween = get_tree().create_tween()
		var tween2 = get_tree().create_tween()
		tween.tween_property(color_rect,"color",Color(0,0,0,0),0.5)
		tween2.tween_property(Engine,"time_scale",1,0.1)
		player.canMove = true
		changeTutorialText("")
		
func changeTutorialText(string : String):
	label.visible_characters = 0
	label.text = string

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and currentArea == AreaPassed.AREA1:
		currentArea = AreaPassed.AREA2
		backgroundSlowDown()
		changeTutorialText("Press the [UP] arrow key to jump.
		This is an example of the many obstacles that you will be facing, specifically of the short variety.")


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body is Player and currentArea == AreaPassed.AREA2:
		currentArea = AreaPassed.AREA3
		backgroundSlowDown()
		changeTutorialText("Press the [UP] arrow key while in the air to double-jump.
		The double-jump can be used to get extra height or avoid tall obstacles.")
		
func _on_area_2d_3_body_entered(body: Node2D) -> void:
	if body is Player and currentArea == AreaPassed.AREA3:
		currentArea = AreaPassed.AREA4
		backgroundSlowDown()
		changeTutorialText("Press the [DOWN] arrow key while in the air to perform a 'Down Slam'
		By performing this stunt, your speed and height increases with every slam. Allowing you to go extremely fast and high when combining it with the double-jump.")


func _on_area_2d_4_body_entered(body: Node2D) -> void:
	var timer = get_tree().create_timer(0.25)
	backgroundSlowDown()
	changeTutorialText("Let's try that again...")
	player.global_position = Vector2(8411,4)
	await timer.timeout
	backgroundSlowDown()
	changeTutorialText("")

func _on_area_2d_5_body_entered(body: Node2D) -> void:
	if body is Player and currentArea == AreaPassed.AREA4:
		currentArea = AreaPassed.AREA5
		backgroundSlowDown()
		changeTutorialText("When sliding on a wall, press the [UP] arrow key to jump off the wall and onto another.
		When jumping off the wall, you might need some time to get back on track, so you can use the 'Drop Dash' to quickly correct yourself.")

func _on_area_2d_6_body_entered(body: Node2D) -> void:
	if body is Player and currentArea == AreaPassed.AREA5:
		currentArea = AreaPassed.AREA6
		backgroundSlowDown()
		changeTutorialText("The 'Drop Dash' can also be used to quickly go downwards.
		This saves precious time and can also prevent some unwanted collisions.")


func _on_area_2d_7_body_entered(body: Node2D) -> void:
	if body is Player and currentArea == AreaPassed.AREA6:
		currentArea = AreaPassed.NONE
		backgroundSlowDown()
		changeTutorialText("At the end of a delivery, your performance will be evaluated.
		The amount of damage the pizzas sustained during delivery and how fast the delivery was will be key factors on your evaluation.")
