class_name Interactable extends CollisionObject3D

const INTERACT_LAYER: int = 3

enum Cursor {CIRCLE, POINT, HAND, GRAB, ROTATE, HIDDEN}

signal hover_started
signal hover_finished

signal interaction_started
signal interaction_finished

## Cursor to change to when hovered
@export var cursor_type: Cursor = Cursor.HAND

var interaction_active: bool = false: set = set_interaction_active
var is_interaction_hovered: bool = false: set = set_interaction_hovered

func _ready() -> void:
	if not get_collision_layer_value(INTERACT_LAYER): set_collision_layer_value(3, true)

	var hub_node: Node = get_parent()
	interaction_started.connect(hub_node._on_interaction_started)
	interaction_started.connect(hub_node._on_interaction_finished)

	hover_started.connect(hub_node._on_hover_started)
	hover_finished.connect(hub_node._on_hover_finished)

func set_interaction_hovered(is_hovered: bool) -> void:
	if is_interaction_hovered == is_hovered: return

	is_interaction_hovered = is_hovered

	if is_interaction_hovered:
		hover_started.emit()
		# Events.change_cursor.emit(cursor_type)
	else:
		hover_finished.emit()

func set_interaction_active(act: bool) -> void:
	if act == interaction_active: return

	interaction_active = act

	if act: interaction_started.emit()
	else: interaction_finished.emit()

func on_interact() -> void:
	interaction_active = !interaction_active

## Set to just emit the interaciton finished signal by default
func end_interaction() -> void:
	interaction_active = false
