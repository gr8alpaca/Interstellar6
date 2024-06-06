extends Node3D

const ITEM_PICKUP_TIMEOUT: float = 1.6
const GRAB_SPEED: float = 5.0

@onready var ray: RayCast3D = %InteractRay
@onready var hold: Node3D = %Hold

@export var interactable_hovered: Interactable: set = set_interactable_hovered, get = get_interactable_hovered

@export var is_holding_item: bool = false

@export var held_item: Item3D: set = set_held_item

# func _ready() -> void:
# 	Events.request_hold_item.connect(_on_request_hold_item) 

func _unhandled_input(event: InputEvent) -> void:

	if Input.is_action_just_pressed("interact") and event.is_action_pressed("interact"):
		 
		if is_holding_item:
			held_item = null
			get_viewport().set_input_as_handled()
			
		elif interactable_hovered:
			interactable_hovered.on_interact()
			get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	if not is_holding_item:
		ray.force_raycast_update()
		update_ray_collision(ray.get_collider())

	else:
		move_held_item(held_item, delta, )

# TODO
func move_held_item(item: Item3D, delta: float, ) -> void:
	item.linear_velocity = (global_position - item.global_position) * GRAB_SPEED / item.mass * 60.0 * delta

func update_ray_collision(obj: Object) -> void:
	interactable_hovered = obj as Interactable if obj else null
	var s: String = obj.name if obj else ""


func on_interact(obj: Interactable) -> void:
	if not obj is Interactable: return print("NO OBJECT not Interactable")
	obj.on_interact()
	print_debug("RAN INTERACTION")

func get_interactable_hovered() -> Interactable:
	return interactable_hovered if interactable_hovered and is_instance_valid(interactable_hovered) else null
func set_interactable_hovered(inter: Interactable) -> void:
	if held_item or interactable_hovered == inter: return

	if interactable_hovered and is_instance_valid(interactable_hovered):
		interactable_hovered.is_interaction_hovered = false
	
	interactable_hovered = inter

	if inter:
		inter.is_interaction_hovered = true

func set_held_item(item: Item3D) -> void:
	if held_item == item: return

	if held_item:
		held_item.is_held = false

	if item:
		item.start_item_drag(hold)

	held_item = item
	is_holding_item = (item != null)

func _on_request_hold_item(item: Item3D) -> void:
	if not item or held_item: return
	held_item = item
	# create_tween().tween_callback(_on_pickup_timeout).set_delay(ITEM_PICKUP_TIMEOUT)

# func _on_pickup_timeout() -> void:
# 	for itm: Node3D in hold_area.get_overlapping_bodies():
# 		if itm == held_item: return
# 	held_item = null

# func _on_hold_area_body_exited(body : Node3D) -> void:
# 	# print(body.name)
# 	if body == held_item: held_item = null
