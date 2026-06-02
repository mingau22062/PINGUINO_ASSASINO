extends CharacterBody2D

enum Playerstate {
	idle,
	walk,
	jump,
	duck,
	fall,
	victory
}
@onready var collision: CollisionShape2D = $CollisionShape2D

@onready var ani: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 80.0
const JUMP_VELOCITY = -300.0

var jump_count = 0
var max_jump_count = 2
var direction = 0
var status: Playerstate 

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta 
	
	match  status:
		Playerstate.idle:
			idle_state()
		Playerstate.walk:
			walk_state()
		Playerstate.jump:
			jump_state()
		Playerstate.duck:
			duck_state()
		Playerstate.fall:
			fall_state()
	move_and_slide()

func go_to_idle_state():
	status = Playerstate.idle
	ani.play("idle")
func go_to_walk_state():
	status = Playerstate.walk
	ani.play("walk")
func go_to_jump_state():
	status = Playerstate.jump
	ani.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1 
func go_to_duck_state():
	status = Playerstate.duck
	ani.play("duck")
	collision.shape.radius = 5
	collision.shape.height = 10
	collision.position.y = 3
func go_to_fall_state():
	status = Playerstate.fall
	ani.play("fall")
func exit_from_duck():
	collision.shape.radius = 6
	collision.shape.height = 16
	collision.position.y = 0
func idle_state():
	move()
	if velocity.x != 0:
		go_to_walk_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return
		
func walk_state():
	move()
	if velocity.x == 0:
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if !is_on_floor():
		jump_count += 1
		go_to_fall_state()
		return
func jump_state():
	move()
	
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return
	if velocity.y > 0:
		go_to_fall_state()
		return
func duck_state():
	update_direction()
	if Input.is_action_just_released("duck"):
		exit_from_duck()
		go_to_idle_state()
		return
func fall_state():
		move()
		if Input.is_action_just_pressed("jump")&& can_jump():
			go_to_jump_state()
			return
		if is_on_floor():
			jump_count = 0
			if velocity.x == 0:
				go_to_idle_state()
			else:
				go_to_walk_state()
			return
func update_direction() -> float: 
	direction = Input.get_axis("move_left", "move_right")
	
	if direction < 0:
		ani.flip_h = true
	elif direction > 0:
		ani.flip_h = false
		
	return direction # Retorna o valor para quem chamou a função

func move():
	update_direction()
		
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
func can_jump() -> bool:
	return jump_count < max_jump_count
