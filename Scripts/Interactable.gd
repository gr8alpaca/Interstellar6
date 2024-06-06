class_name Interactable extends Area3D

const INTERACT_LAYER: int = 3

enum {CURSOR_CIRCLE}

signal hover_started
signal hover_finished

signal interaction_started
signal interaction_finished

## Cursor to change to when hovered
@export var hover_cursor: int = UI.CURSOR_OPEN_HAND
@export var interacting_cursor: int = UI.CURSOR_CLOSED_HAND

var interaction_active: bool = false: set = set_interaction_active
var is_interaction_hovered: bool = false: set = set_interaction_hovered

func _ready() -> void:
	if not get_collision_layer_value(INTERACT_LAYER):
		set_collision_layer_value(3, true)

	var parent_node: Node = get_parent()

	for sig: Signal in [interaction_finished, interaction_started, hover_started, hover_finished]:
		var method_name: StringName = "_on_" + sig.get_name()
		if method_name in parent_node:
			var err: int = sig.connect(Callable(parent_node, method_name))
			print("Signal %s -> Connected: %s"%[sig.get_name(), error_string(err)])
			
func set_interaction_hovered(is_hovered: bool) -> void:
	if is_interaction_hovered == is_hovered: return

	is_interaction_hovered = is_hovered

	if is_interaction_hovered:
		hover_started.emit()
		Events.change_cursor.emit(hover_cursor)
	else:
		hover_finished.emit()
		Events.change_cursor.emit(UI.CURSOR_CIRCLE)

func set_interaction_active(act: bool) -> void:
	if act == interaction_active: return

	interaction_active = act

	if act:
		interaction_started.emit()

	else:
		interaction_finished.emit()

func on_interact() -> void:
	interaction_active = !interaction_active

## Set to just emit the interaciton finished signal by default
func end_interaction() -> void:
	interaction_active = false
