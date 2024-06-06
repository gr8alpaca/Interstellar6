extends Node

@onready var tree: SceneTree = get_tree()

var player: CharacterBody3D
var interact: InteractionHandler
var ui: UI


func _init() -> void:
	process_mode = PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if not event.is_pressed(): return

	if Input.is_key_pressed(KEY_ESCAPE):
		tree.paused = !tree.paused
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if tree.paused else Input.MOUSE_MODE_CAPTURED

# TODO
func _on_change_cursor(cursor: int) -> void:
	pass
	