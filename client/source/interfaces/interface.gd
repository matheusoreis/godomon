extends Control
class_name Interface


func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		bring_to_front()


func _on_gui_focus_changed(node: Control) -> void:
	if node != null and is_ancestor_of(node):
		bring_to_front()


func bring_to_front() -> void:
	var parent: Node = get_parent()
	if parent == null:
		return
	parent.move_child(self, parent.get_child_count() - 1)


func clamp_to_viewport(pos: Vector2) -> Vector2:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var max_x: float = viewport_size.x - size.x
	var max_y: float = viewport_size.y - size.y
	pos.x = clamp(pos.x, 0.0, max_x)
	pos.y = clamp(pos.y, 0.0, max_y)
	return pos
