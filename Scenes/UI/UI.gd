class_name UI extends CanvasLayer

@onready var interact_label: Label = %InteractLabel
@onready var cursor_node: Control = %Cursor
@onready var debug: HBoxContainer = %HBoxDebug

@export var cursor_size: Vector2 = Vector2(8, 8)

const CURSOR_TEXTURE: Texture2D = preload ("res://Assets/UI_Icon_Map.png")
const CURSOR_REGION_SIZE: Vector2 = Vector2(16, 16)

enum {CURSOR_CIRCLE, CURSOR_OPEN_HAND, CURSOR_CLOSED_HAND, CURSOR_ROTATE}
const CURSOR_REGIONS: PackedVector2Array = [Vector2(448, 352), Vector2(48, 272), Vector2(64, 272), Vector2(448, 304), ]
const DEFAULT_CURSOR: int = CURSOR_CIRCLE

@onready var cursor_rid: RID = cursor_node.get_canvas_item()
@onready var texture_rid: RID = CURSOR_TEXTURE.get_rid()

@export var cursor_index: int = CURSOR_CIRCLE:
	set(val):
		cursor_index = val
		if cursor_node: cursor_node.queue_redraw()

@export_group("Cursor Details")
@export var cursor_circle_color: Color = Color.WHITE_SMOKE:
	set(val):
		cursor_circle_color = val
		if cursor_node: cursor_node.queue_redraw()
@export var cursor_radius: float = 5.0:
	set(val):
		cursor_radius = val
		if cursor_node: cursor_node.queue_redraw()
@export var cursor_outline_size: float = 2.00:
	set(val):
		cursor_outline_size = val
		if cursor_node: cursor_node.queue_redraw()
@export var cursor_outline_color: Color = Color.BLACK:
	set(val):
		cursor_outline_color = val
		if cursor_node: cursor_node.queue_redraw()

func _init() -> void:
	Global.ui = self

func _ready() -> void:
	# var center_pos := get_viewport().get_visible_rect().get_center()
	
	clear_debug_labels()
	cursor_node.draw.connect(_on_cursor_draw)
	cursor_node.queue_redraw()

	Events.debug_label.connect(set_debug_labels)

func _on_cursor_draw() -> void:
	match cursor_index:
		CURSOR_CIRCLE:
			cursor_node.draw_circle(Vector2.ZERO, cursor_radius + cursor_outline_size, cursor_outline_color)
			cursor_node.draw_circle(Vector2.ZERO, cursor_radius, cursor_circle_color)
		
		_:
			RenderingServer.canvas_item_add_texture_rect_region(
				cursor_rid,
				Rect2( - cursor_size / 2, cursor_size),
				texture_rid,
				Rect2(CURSOR_REGIONS[cursor_index], CURSOR_REGION_SIZE),
				Color.WHITE,
				false,
				true, )
	
func set_cursor_index(val: int) -> void:
	cursor_index = val

func _process(delta: float) -> void:
	if cursor_node:
		cursor_node.queue_redraw()

func set_debug_labels(txt: String, index: int=- 1) -> void:
	if index == - 1:
		interact_label.text = txt
	else:
		debug.get_child(index).text = txt

func clear_debug_labels() -> void:
	interact_label.text = ""
	for c: Label in debug.get_children():
		c.text = ""