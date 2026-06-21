extends Control

@onready var transition_rect: ColorRect = $TransitionRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var tween = Tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	WindowTransitions.continue_transition(transition_rect)
	animation_player.play("onready")


func _on_play_pressed() -> void:
	var level_select = load("uid://vgdy4hfm0xdb")
	animation_player.play("onplay")
	await WindowTransitions.start_transition($TransitionRect)
	add_sibling(level_select.instantiate())
	queue_free()

func _on_settings_pressed() -> void:
	var SETTINGS = load("uid://clv4pnygbjyut")
	animation_player.play("onplay")
	await WindowTransitions.start_transition(transition_rect)
	add_sibling(SETTINGS.instantiate())
	queue_free()

func _on_quit_pressed() -> void:
	await WindowTransitions.quit_transition(self)
	if OS.get_name() == "Web":
		JavaScriptBridge.eval("window.close()")
	else:
		get_tree().quit()
