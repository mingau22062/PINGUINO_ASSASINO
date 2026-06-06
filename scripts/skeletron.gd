extends CharacterBody2D

enum skeletronState {
	walk,
	dead,
	attack
}
@onready var ani: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $hitbox
@onready var walldetector: RayCast2D = $walldetector
@onready var grounddetctor: RayCast2D = $grounddetctor
@onready var player_detector: RayCast2D = $playerDetector
@onready var bone_start: Node2D = $boneStart
const BONE = preload("uid://ck8vii4fsih1k")

var direction = 1
var can_shot = true
const SPEED = 25.0
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
		skeletronState.attack:
			attack_state(delta)
		
	move_and_slide()

func go_to_walk_state():
	status = skeletronState.walk
	ani.play("walk")
	
func go_to_attack_state():
	status = skeletronState.attack
	ani.play("attack")
	velocity = Vector2.ZERO
	can_shot = true
	
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
	if player_detector.is_colliding():

		go_to_attack_state()
	
func dead_state(_delta):
	pass
func attack_state(_delta):
	if ani.frame == 0:
		can_shot = true

	if ani.frame == 2 and can_shot:
		shot_bone()
		can_shot = false
		return
func take_damage():
	go_to_dead_state()
func shot_bone():
	var new_bone = BONE.instantiate()
	add_sibling(new_bone)
	new_bone.position = bone_start.global_position
	new_bone.set_direction(direction)
		


func _on_animated_sprite_2d_animation_finished() -> void:
	if ani.animation == "attack":
		go_to_walk_state()
		return
