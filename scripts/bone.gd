extends Area2D

@onready var ani: AnimatedSprite2D = $AnimatedSprite2D
@onready var detrution_timer: Timer = $detrutionTimer

var speed = 100
var dir = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += speed * delta * dir

func set_direction(direction):
	dir = direction
	ani.flip_h = dir < 0


func _on_detrution_timer_timeout() -> void:
	queue_free()


func _on_area_entered(_area: Area2D) -> void:
	queue_free()


func _on_body_entered(_body: Node2D) -> void:
	queue_free()
