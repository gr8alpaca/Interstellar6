extends CharacterBody3D

const RUN_SPEED_MULT: float = 1.5
const DEFAULT_SPEED: float = 5.0
const CROUCH_SPEED: float = 2.5

const JUMP_VELOCITY: float = 4.5
const GRAVITY: float = 9.8

var speed_mult: float = 1.0
var speed: float = DEFAULT_SPEED
var acceleration: float = 0.05

@export var sensitivity: float = 3.0

@export_group("Node References")
# @export var cam: Camera3D
@export var bone: BoneAttachment3D
@export var tree: AnimationTree
@export var ray: RayCast3D

@export var interact_handler: Node3D

## Disables all input for characterbody
var input_active: bool = true: set = set_input_active

var is_crouched: bool = false:
	set(act):
		if act == is_crouched: return
		is_crouched = act
		speed = CROUCH_SPEED if is_crouched else DEFAULT_SPEED

var is_running: bool = false:
	set(act):
		is_running = act
		speed_mult = RUN_SPEED_MULT if is_running else 1.0

var input_dir: Vector2 = Vector2.ZERO:
	set(val):
		if input_dir == val: return
		input_dir = val
		tree.set("parameters/moving/blend_position", input_dir.y)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Global.player = self

func _on_interaction_transtion(obj: Node3D, is_active: bool) -> void:
	input_active = !is_active

func _physics_process(delta: float) -> void:

	if Input.is_action_just_pressed("interact") and input_active:

		if ray.is_colliding():
			# print("ENGAGING INTERACT with %s" % ray.get_collider().name)
			on_interact(ray.get_collider())
			move_and_slide()
			return

	velocity.y -= GRAVITY * delta * int(not is_on_floor())

	# if not input_active: return

	if is_on_floor() and Input.is_action_just_pressed("jump") and input_active:
		velocity.y = JUMP_VELOCITY

	is_crouched = Input.is_action_pressed("crouch")

	is_running = Input.is_action_pressed("run")

	input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:

		velocity.x = direction.x * speed * speed_mult
		velocity.z = direction.z * speed * speed_mult

	else:

		velocity.x = move_toward(velocity.x, 0, speed * speed_mult)
		velocity.z = move_toward(velocity.z, 0, speed * speed_mult)
	
	move_and_slide()

func on_interact(obj: Object) -> void:
	return
	# obj.toggle_interact()

func _unhandled_input(event: InputEvent) -> void:
	if not input_active: return

	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / 1000 * sensitivity
		if bone: bone.rotation.x -= event.relative.y / 1000 * sensitivity

		rotation.x = clamp(rotation.x, PI / - 2, PI / 2)
		if bone: bone.rotation.x = clamp(bone.rotation.x, -PI / 2, PI / 2)
		ray.force_raycast_update()

func set_input_active(act: bool) -> void:
		print("\nsetting input -> %s" % act)
		input_active = act
		set_process_unhandled_input(input_active)
		set_process_input(input_active)
		set_process_unhandled_input(input_active)
		reset_inputs()

func reset_inputs() -> void:
	input_dir = Vector2.ZERO
	is_crouched = false
	is_running = false

func _on_animation_started(anim_name: StringName) -> void:
	pass

	# print("=>Started animation:\t%s" % anim_name)

func _on_animation_finished(anim_name: StringName) -> void:
	pass

	# print("Finished animation:\t%s" % anim_name)

func _on_animation_tree_mixer_updated() -> void:
	pass

	# print("updated mixer...")
