extends CharacterBody2D

enum skeletronState {
	walk,
	dead,
	spawn
}
@onready var ani: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var walldetector: RayCast2D = $walldetector
@onready var grounddetctor: RayCast2D = $grounddetctor

var direction = 1

const SPEED = 30.0
const JUMP_VELOCITY = -400.0

var status : skeletronState

func _ready() -> void:
	go_to_walk_state()
	return
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	match  status:
		skeletronState.walk:
			walk_state(delta)
		skeletronState.dead:
			dead_state(delta)
		
	move_and_slide()

func go_to_walk_state():
	status = skeletronState.walk
	ani.play("walk")
func go_to_dead_state():
	status = skeletronState.dead
	ani.play("dead")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO
	

func walk_state(_delta):
	velocity.x = SPEED * direction
	
	if walldetector.is_colliding():
		scale.x *= -1
		direction *= -1
	if !grounddetctor.is_colliding():
		scale.x *= -1
		direction *= -1
func dead_state(_delta):
	pass
	
func take_damage():
	go_to_dead_state()
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
