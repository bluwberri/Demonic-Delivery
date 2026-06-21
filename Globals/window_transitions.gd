extends Node

func start_transition(transition_rect : ColorRect):
	transition_rect.position.x = transition_rect.size.x
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(transition_rect,"position",Vector2.ZERO,0.5)
	await get_tree().create_timer(0.5).timeout
	
	
func continue_transition(transition_rect):
	transition_rect.position.x = 0
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(transition_rect,"position",Vector2(-transition_rect.size.x,0),0.5)
	await tween.finished

func quit_transition(me):
	var tween = get_tree().create_tween()
	tween.tween_property(me,"modulate",Color(0,0,0),1.0)
	await tween.finished

func showFinishScreen(cover,bg):
	var tween = get_tree().create_tween()
	var tween2 = get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween2.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tween.tween_property(bg,"position",Vector2.ZERO,0.5)
	tween2.tween_property(cover,"color",Color(0,0,0,0.85),0.5)
