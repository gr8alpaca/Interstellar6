class_name Item3D extends RigidBody3D
const GROUP: StringName = &"Item3D"

const ROTATE_SENSITIVITY: float = 3.0

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var interactable_area: Interactable = $Interactable

@export var grab_speed: float = 5.0

@export var item_name: String = "Invalid"

@export var additional_hold_distance: float = 0.0

@export var hold_cursor: int = UI.CURSOR_CLOSED_HAND

@export_group("Debug")
@export var debug_material: StandardMaterial3D
@export var standard_color: Color = Color.WHITE_SMOKE
@export var hold_color: Color = Color.DARK_ORANGE
@export var hover_color: Color = Color.LIME

@export var hold_active: bool = false:
	set(val):
		hold_active = val
		set_physics_process(val)
		set_process_input(val)
		update_debug_color()

func _ready() -> void:
	add_to_group(GROUP)

	hold_active = false
	interactable_area.set_root_node(self)
	mesh.material_override = debug_material

func _on_interaction_started() -> void:
	hold_active = true
func _on_interaction_finished() -> void:
	hold_active = false

func _on_hover_started() -> void:
	update_debug_color()
func _on_hover_finished() -> void:
	hold_active = false

func _physics_process(delta: float) -> void:
	var target_global_pos: Vector3 = global_position.lerp(Global.interact.global_position, grab_speed / mass * 60.0 * delta)
	linear_velocity = target_global_pos - global_position
		
## Rotates held item if right click is held down and marks input as handled
func _input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if event is InputEventMouseMotion:

			angular_velocity.y = event.relative.x / 10 * ROTATE_SENSITIVITY
			
			angular_velocity.x = event.relative.y / 10 * ROTATE_SENSITIVITY

			get_viewport().set_input_as_handled()

func update_debug_color() -> void:
	match [interactable_area.is_hovered, interactable_area.interaction_active]:
		[true, true]:debug_material.albedo_color = hold_color
		[true, _]:debug_material.albedo_color = hover_color
		_: debug_material.albedo_color = standard_color
