class_name Interactable extends Area3D

const INTERACT_LAYER: int = 3

signal hover_started
signal hover_finished

signal interaction_started
signal interaction_finished

@onready var root: Node3D: set = set_root_node

@export var is_holdable: bool

@export var debug: bool = false

var interaction_active: bool = false: set = set_interaction_active

var is_hovered: bool = false: set = set_interaction_hovered

func _ready() -> void:
	set_collision_layer_value(3, true)
	Global.cam = get_viewport().get_camera_3d()

func set_interaction_hovered(val: bool) -> void:
	if debug:	print("Hovered set: %s" % val)
	
	is_hovered = val
	if val: hover_started.emit()
	else: hover_finished.emit()

func set_interaction_active(act: bool) -> void:
	if debug:	print("Interaction set: %s" % act)	
	interaction_active = act

	if interaction_active: interaction_started.emit()
	else: interaction_finished.emit()

func ray_enter() -> void:
	is_hovered = true

func ray_exit() -> void:
	interaction_active = false
	is_hovered = false

func start_interaction() -> void:
	interaction_active = true
func end_interaction() -> void:
	interaction_active = false

## Sets root and connects all signals
func set_root_node(node: Node3D) -> void:
	root = node
	for sig: Signal in [interaction_finished, interaction_started, hover_started, hover_finished]:
		var method_name: StringName = "_on_" + sig.get_name()
		if method_name in root:
			var err: int = sig.connect(root.get(method_name))
			if debug:
				print("Signal %s -> Connected: %s" % [sig.get_name(), error_string(err)])
