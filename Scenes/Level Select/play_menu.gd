extends Control

var levels =[{"name" : "Tutorial",
			"image_card" : "res://Assets/Menu/Tutorial Card.png",
			"scene" : "uid://6u3dfkkiueb7"},
			{"name" : "UNFINISHED",
			"image_card" : "res://Assets/Menu/UNFINISHED.jpg",
			"scene" : "uid://6u3dfkkiueb7"},
			{"name" : "UNFINISHED",
			"image_card" : "res://Assets/Menu/UNFINISHED.jpg",
			"scene" : "uid://6u3dfkkiueb7"}]

@onready var lvlCard = preload("uid://qmgxqxmru0w4")
@onready var transition_rect: ColorRect = $ColorRect
@onready var v_flow_container: HFlowContainer = $ScrollContainer/VFlowContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WindowTransitions.continue_transition(transition_rect)
	for level in levels:
		var cardmaker = lvlCard.instantiate()
		cardmaker.get_child(3).text = level["name"]
		cardmaker.get_child(2).texture = load(level["image_card"])
		cardmaker.get_child(1).pressed.connect(changeLevel.bind( load(level["scene"]) ))
		v_flow_container.add_child(cardmaker)
		
func changeLevel(newLevel):
	await WindowTransitions.start_transition(transition_rect)
	transition_rect.position.x = 0
	add_sibling(newLevel.instantiate())
	queue_free()
	


func _on_button_pressed() -> void:
	var TITLE_SCREEN = preload("uid://cdv6yrivlknp8")
	await WindowTransitions.start_transition(transition_rect)
	add_sibling(TITLE_SCREEN.instantiate())
	queue_free()
