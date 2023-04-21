extends CharacterBody3D

enum State { IDLE, WALKING, JUMPING }

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var state = State.IDLE

@onready var animation_player = $AnimationPlayer

func set_state(new_state):
	state = new_state
	match state:
		State.IDLE:
			animation_player.play("idle")
		State.WALKING:
			animation_player.play("walk")
		State.JUMPING:
			animation_player.play("jump")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	handle_state_changes(input_dir, direction)

func handle_state_changes(input_dir, direction):
	if is_on_floor():
		if input_dir.length() > 0:
			if state != State.WALKING:
				set_state(State.WALKING)
		else:
			if state != State.IDLE:
				set_state(State.IDLE)

		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_VELOCITY
			set_state(State.JUMPING)
	else:
		if state != State.JUMPING:
			set_state(State.JUMPING)
