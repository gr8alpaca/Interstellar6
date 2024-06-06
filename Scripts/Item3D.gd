class_name Item3D extends RigidBody3D
const GROUP: StringName = &"Item3D"

const GRAB_SPEED: float = 5.0
const ROTATE_SENSITIVITY: float = 3.0

@onready var mesh: MeshInstance3D = $MeshInstance3D

@export var item_name: String = "Invalid"

@export_group("Debug")
@export var debug_material: StandardMaterial3D
@export var standard_color: Color = Color.WHITE_SMOKE
@export var hold_color: Color = Color.DARK_ORANGE
@export var hover_color: Color = Color.LIME

var is_held: bool = false:
	set(val):
		is_held = val
		set_process_input(is_held)
		set_physics_process(is_held)
		if not debug_material: return
		debug_material.albedo_color = hold_color if is_held else standard_color

var is_hovered: bool = false:
	set(val):
		is_hovered = val
		if not debug_material or is_held: return
		debug_material.albedo_color = hover_color if is_hovered else standard_color

func _ready() -> void:
	add_to_group(GROUP)
	is_held = false

	if not debug_material: return
	mesh.material_override = debug_material
	debug_material.albedo_color = standard_color

func _on_interaction_started() -> void:
	is_held = true
func _on_interaction_finished() -> void:
	is_held = false
func _on_hover_started() -> void:
	is_hovered = true
func _on_hover_finished() -> void:
	is_hovered = false

func _physics_process(delta: float) -> void:
	if not is_held: return
	linear_velocity = (Global.hold.global_position - global_position) * GRAB_SPEED / mass * 60.0 * delta

## Rotates held item if right click is held down and marks input as handled
func _input(event: InputEvent) -> void:
	if not is_held: return

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if event is InputEventMouseMotion:

			angular_velocity.y = event.relative.x / 10 * ROTATE_SENSITIVITY
			angular_velocity.x = event.relative.y / 10 * ROTATE_SENSITIVITY

			get_viewport().set_input_as_handled()
