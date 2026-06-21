extends CharacterBody2D

@export var speed := 100.0
@export var timer : Timer
@export var sprite : AnimatedSprite2D
var curRunDir := 1 

func _ready() -> void:
	sprite.play("walk")

func _physics_process(delta: float) -> void:
	velocity.x = speed * curRunDir
	move_and_slide()

func _on_timer_timeout() -> void:
	curRunDir *= -1
	sprite.flip_h = not sprite.flip_h
