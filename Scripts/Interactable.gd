class_name Interactable extends Area3D

const INTERACT_LAYER: int = 3

signal hover_started
signal hover_finished

signal interaction_started
signal interaction_finished

@onready var root: Node3D: set = set_root_node

var interaction_active: bool = false: set = set_interaction_active

var is_hovered: bool = false: set = set_interaction_hovered

func _ready() -> void:
	set_collision_layer_value(3, true)

func set_interaction_hovered(val: bool) -> void:
	is_hovered = val

func set_interaction_active(act: bool) -> void:
	interaction_active = act
	print("Interaction set: %s" % act)
	if interaction_active: interaction_started.emit()
	else: interaction_finished.emit()

func interact() -> void:
	interaction_active = !interaction_active

func ray_enter() -> void:
	is_hovered = true
	hover_started.emit()
	print("Ray ENTER")

func ray_exit() -> void:
	interaction_active = false
	is_hovered = false
	hover_finished.emit()
	print("Ray EXIT")
func start_interaction() -> void:
	interaction_active = true
	print("Grab ENTER")
func end_interaction() -> void:
	interaction_active = false
	print("Grab EXIT")
	
## Sets root and connects all signals
func set_root_node(node: Node3D) -> void:
	root = node
	for sig: Signal in [interaction_finished, interaction_started, hover_started, hover_finished]:
		var method_name: StringName = "_on_" + sig.get_name()
		if method_name in root:
			var err: int = sig.connect(root.get(method_name))
			print("Signal %s -> Connected: %s" % [sig.get_name(), error_string(err)])
