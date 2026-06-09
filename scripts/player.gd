extends CharacterBody2D

enum Playerstate {
	idle,
	walk,
	jump,
	duck,
	fall,
	victory,
	sliding,
	dead
}
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var ani: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox_collision: CollisionShape2D = $hitbox/CollisionShape2D
@onready var reloadtime: Timer = $reloadtime

@export var max_speed = 100.0
@export var aceleration = 150
@export var deceleratio = 150
@export var sliding_decelatio = 150
const JUMP_VELOCITY = -300.0


var jump_count = 0
@export var max_jump_count = 2
var direction = 0
var status: Playerstate 

func move(delta):
	update_direction()
		
	if direction:
		velocity.x = move_toward(velocity.x,direction * max_speed, aceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleratio)
func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta 
	
	match  status:
		Playerstate.idle:
			idle_state(delta)
		Playerstate.walk:
			walk_state(delta)
		Playerstate.jump:
			jump_state(delta)
		Playerstate.duck:
			duck_state(delta)
		Playerstate.fall:
			fall_state(delta)
		Playerstate.sliding:
			sliding_state(delta)
		Playerstate.dead:
			dead_state(delta)
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
	
func go_to_fall_state():
	status = Playerstate.fall
	ani.play("fall")
	small_colision()
func exit_from_duck():
	exit_small_colision()
func go_to_sliding_state():
	status = Playerstate.sliding
	ani.play("sliding")
	small_colision()
	
func exit_to_sliding():
	exit_small_colision()
	
func go_to_dead_state():
	if status == Playerstate.dead:
		return
	status = Playerstate.dead
	ani.play("dead")
	velocity.x = 0 
	reloadtime.start()
	
func idle_state(delta):
	move(delta)
	if velocity.x != 0:
		go_to_walk_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return
		
func walk_state(delta):
	move(delta)
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
	if Input.is_action_just_pressed("duck"):
		go_to_sliding_state()
		return
func jump_state(delta):
	move(delta)
	
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return
	if velocity.y > 0:
		go_to_fall_state()
		return
func duck_state(_delta):
	update_direction()
	if Input.is_action_just_released("duck"):
		exit_from_duck()
		go_to_idle_state()
		return
func fall_state(delta):
		move(delta)
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
func sliding_state(delta):
	velocity.x = move_toward(velocity.x , 0, sliding_decelatio * delta)
		
	if Input.is_action_just_released("duck"):
		exit_to_sliding()
		go_to_walk_state()
		
		return
	if velocity.x == 0:
		exit_to_sliding()
		go_to_duck_state()
		
func dead_state(_delta):
	pass
func update_direction() -> float: 
	direction = Input.get_axis("move_left", "move_right")
	
	if direction < 0:
		ani.flip_h = true
	elif direction > 0:
		ani.flip_h = false
		
	return direction # Retorna o valor para quem chamou a função


func can_jump() -> bool:
	return jump_count < max_jump_count
func small_colision():
	collision.shape.radius = 5
	collision.shape.height = 10
	collision.position.y = 3
	
	hitbox_collision.shape.size.y = 10
	hitbox_collision.position.y = 3
func exit_small_colision():
	collision.shape.radius = 6
	collision.shape.height = 16
	collision.position.y = 0

	hitbox_collision.shape.size.y = 15
	hitbox_collision.position.y = 0.5
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		hit_enemy(area)
	elif area.is_in_group("areaLetal"):
		hit_area_letal()
func hit_enemy(area: Area2D):
	if velocity.y > 0:
		area.get_parent().take_damage()
		go_to_jump_state()
		jump_count = 1
	else:
		
			go_to_dead_state()
			
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("areaLetal"):
		go_to_dead_state()
func hit_area_letal():
	go_to_dead_state()

func _on_reloadtime_timeout() -> void:
		get_tree().reload_current_scene()
