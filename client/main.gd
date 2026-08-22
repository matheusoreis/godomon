extends Node2D
class_name Main


var _character: Character


func _ready() -> void:
	_test_character()


func _test_character() -> void:
	var character_scene: PackedScene = load("res://source/gameplay/entity/character/character.tscn")
	if character_scene == null:
		return

	_character = character_scene.instantiate() as Character
	if _character == null:
		return

	_character.setup(
		1,
		"Teste",
		"red",
		0,
		Vector2i(0, 0),
		Vector2i.DOWN
	)

	add_child(_character)


func _physics_process(_delta: float) -> void:
	if _character == null:
		return

	if _character.is_transitioning():
		return

	var direction: Vector2i = Vector2i.ZERO

	if Input.is_key_pressed(KEY_W):
		direction = Vector2i.UP
	elif Input.is_key_pressed(KEY_S):
		direction = Vector2i.DOWN
	elif Input.is_key_pressed(KEY_A):
		direction = Vector2i.LEFT
	elif Input.is_key_pressed(KEY_D):
		direction = Vector2i.RIGHT

	if direction != Vector2i.ZERO:
		_character.move(direction)
