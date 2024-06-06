class_name Item3D extends RigidBody3D
const GROUP: StringName = &"Item3D"

const ROTATE_SENSITIVITY: float = 3.0

@export var item_name: String = "Invalid"

var is_held: bool = false:
	set(act):
		if is_held == act: return
		is_held = act
		set_process_input(is_held)
		
func _ready() -> void:
	add_to_group(GROUP)
	is_held = false

func _on_interaction_started() -> void:
	is_held = true
func _on_interaction_finished() -> void:
	is_held = false

func _on_hover_started() -> void:
	pass
func _on_hover_finished() -> void:
	pass

## Rotates held item if right click is held down and marks input as handled
func _input(event: InputEvent) -> void:
	if not is_held: return

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if event is InputEventMouseMotion:

			angular_velocity.y = event.relative.x / 10 * ROTATE_SENSITIVITY
			angular_velocity.x = event.relative.y / 10 * ROTATE_SENSITIVITY

			get_viewport().set_input_as_handled()
