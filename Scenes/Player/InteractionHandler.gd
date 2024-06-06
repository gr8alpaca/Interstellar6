class_name InteractionHandler extends Node3D

const ITEM_PICKUP_TIMEOUT: float = 1.6
enum {IDLE, HOVER, HOLD, ROTATE, DISABLED}
const STATE_NAMES: PackedStringArray = ["IDLE", "HOVER", "HOLD", "ROTATE", "DISABLED"]

## Max disance a carried item can sway from the hold node position
const MAX_ITEM_POSITION_DELTA: float = 2.00

signal ray_exit

@onready var ray: RayCast3D = %InteractRay

@export var debug: bool = false

@export var ui: UI

@export var item: Interactable:
	set(val):
		item = val

		if item:
			ray_exit.connect(item.ray_exit, CONNECT_ONE_SHOT)

		else:
			ray_exit.emit()

		update_ui()

@export_enum("IDLE", "HOVER", "HOLD", "ROTATE", "DISABLED") var state: int = IDLE:
	set(new_state):
		# if state == new_state: return
		if debug:
			print("State change : %s -> %s" % [STATE_NAMES[state], STATE_NAMES[new_state]])
		
		match new_state:
			IDLE:
				pass
			(HOVER)when(state == HOLD):
				item.end_interaction()
			HOVER:
				item.ray_enter()
			HOLD, ROTATE:
				if state not in [HOLD, ROTATE]:
					item.start_interaction()

		state = new_state
		update_ui()

func _ready() -> void:
	Global.interact = self

func _physics_process(delta: float) -> void:
	if state in [HOLD, ROTATE]:
		if not is_within_range(item.global_position):
			item = null
			state = IDLE
	else:
		update_item(ray.get_collider())

func update_item(inter: Interactable) -> void:
	if inter == item: return
	item = inter

	if not item:
		state = IDLE
	else:
		state = HOVER

func is_within_range(pos: Vector3) -> bool:
	return global_position.distance_to(pos) <= MAX_ITEM_POSITION_DELTA if pos else false

func update_ui() -> void:
	if not ui: return

	ui.set_cursor_index(state)

	var cursor_text: String = String(item.root.name) if item else ""
	ui.set_debug_labels(cursor_text, -1)
	ui.set_debug_labels("State: " + STATE_NAMES[state], 0)

func _unhandled_input(event: InputEvent) -> void:
	if state == IDLE or state == DISABLED: return

	if not Input.is_action_pressed("interact"):
		state = HOVER
		
	elif Input.is_action_just_pressed("interact"):
		state = HOLD
		get_viewport().set_input_as_handled()

	elif state == HOLD and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT): 
		state = ROTATE
	elif state == ROTATE and not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT): 
		state = HOLD
		