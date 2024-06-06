extends Node

# UI Events
signal change_cursor(cursor_type: int)
signal debug_label(text: String, label_index: int) # # -1->Cursor, 0-2 standard