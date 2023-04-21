extends Node3D

@export var target: NodePath
@export var camera_distance: float = 10.0
@export var camera_height: float = 2.0
@export var rotation_speed: float = 2.0
@export var follow_smoothness: float = 5.0

@onready var camera: Camera3D = $Camera3D
@onready var target_node: Node3D = get_node(target)

var vertical_rotation: float = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			return

		var horizontal_rotation = -event.relative.x * rotation_speed * get_process_delta_time()
		var vertical_rotation_delta = event.relative.y * rotation_speed * get_process_delta_time()
		
		target_node.rotate_y(deg_to_rad(horizontal_rotation))
		vertical_rotation += deg_to_rad(vertical_rotation_delta)
		vertical_rotation = clamp(vertical_rotation, deg_to_rad(-80), deg_to_rad(80))

func _process(delta):
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return

	var target_position = target_node.global_transform.origin
	var target_direction = -target_node.global_transform.basis.z
	var target_height = Vector3.UP * camera_height

	var side_direction = target_node.global_transform.basis.x
	var up_direction = target_node.global_transform.basis.y
	var camera_offset = -target_direction.normalized() * camera_distance * cos(vertical_rotation) + up_direction * camera_distance * sin(vertical_rotation)
	var desired_position = target_position + camera_offset + target_height
	camera.global_transform.origin = camera.global_transform.origin.lerp(desired_position, follow_smoothness * delta)

	var look_at_position = target_position + target_height
	camera.look_at(look_at_position, Vector3.UP)
