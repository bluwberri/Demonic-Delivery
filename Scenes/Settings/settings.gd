extends Control

@onready var transition_rect: ColorRect = $ColorRect
@onready var TITLE_SCREEN = preload("uid://cdv6yrivlknp8")
@onready var label: Label = $Label

@onready var jump: Label = $jump
@onready var jButton: Button = $jump/Button
@onready var downslam: Label = $downslam
@onready var dButton: Button = $downslam/Button

var takinginputJ = false
var takinginputD = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WindowTransitions.continue_transition(transition_rect)
	jButton.text = InputMap.get_action_description("jump")
	dButton.text = InputMap.get_action_description("down")
	


func _on_backtotitle_pressed() -> void:
	await WindowTransitions.start_transition(transition_rect)
	add_sibling(TITLE_SCREEN.instantiate())
	queue_free()

func _on_button_pressed() -> void:
	print("Please give the desired key")
	takinginputJ = true
	InputMap.action_erase_events("jump")
	label.show()
	
func _input(event: InputEvent) -> void:
	if takinginputJ:
		if event is InputEventKey or event is InputEventMouseButton:
			InputMap.action_add_event("jump",event)
			jButton.text = InputMap.get_action_description("jump")
			takinginputJ = false
			label.hide()
	if takinginputD:
		if event is InputEventKey or event is InputEventMouse:
			InputMap.action_add_event("down",event)
			dButton.text = InputMap.get_action_description("down")
			takinginputD = false
			label.hide()


func _on_dbutton_pressed() -> void:
	print("Please give the desired key")
	takinginputD = true
	InputMap.action_erase_events("down")
	label.show()
