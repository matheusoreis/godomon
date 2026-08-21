extends Node2D
class_name Scene


@export_category("Interfaces")
@export var _interfaces: Dictionary[StringName, Interface]


func _ready() -> void:
	Globals.current_scene = self


func add_interface(identifier: StringName, interface: Interface) -> void:
	if is_instance_valid(interface) == false:
		return

	if _interfaces.has(identifier):
		return

	_interfaces[identifier] = interface


func remove_interface(identifier: StringName) -> void:
	var interface: Interface = get_interface(identifier)
	if interface == null:
		return

	_interfaces.erase(identifier)
	interface.queue_free()


func get_interface(identifier: StringName) -> Interface:
	return _interfaces.get(identifier, null)


func toggle_interface(identifier: StringName) -> void:
	var interface: Interface = get_interface(identifier)
	if interface == null:
		return

	interface.visible = not interface.visible

	if interface.visible and interface is Interface:
		(interface as Interface).bring_to_front()


func show_interface(identifier: StringName) -> void:
	var interface: Interface = get_interface(identifier)
	if interface == null:
		return

	interface.visible = true

	if interface is Interface:
		(interface as Interface).bring_to_front()


func hide_interface(identifier: StringName) -> void:
	var interface: Interface = get_interface(identifier)
	if interface == null:
		return

	interface.visible = false
