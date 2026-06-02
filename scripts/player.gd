extends CharacterBody2D

enum Playerstate {
	idle,
	walk,
	jump,
	duck
}

@onready var ani: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 80.0
const JUMP_VELOCITY = -250.0

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
func go_to_duck_state():
	status = Playerstate.duck
	ani.play("duck")
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
func jump_state():
	move()
	if is_on_floor():
		if velocity.x == 0:
			go_to_idle_state()
			return
		else:
			go_to_walk_state()
func duck_state():
	if Input.is_action_just_released("duck"):
		go_to_idle_state()
		return

		
func update_direction() -> float: 
	var dir := Input.get_axis("move_left", "move_right")
	
	if dir < 0:
		ani.flip_h = true
	elif dir > 0:
		ani.flip_h = false
		
	return dir # Retorna o valor para quem chamou a função

func move():
	# Armazena o valor retornado pela função em uma variável local
	var direction = update_direction()
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
