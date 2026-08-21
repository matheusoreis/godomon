extends RefCounted
class_name Map


var id: int
var identifier: String

var bgm: String
var bgs: String

var width: int
var height: int

var characters_collide: bool

var collisions: Dictionary


var _characters: Dictionary


func _init(id: int, identifier: String, bgm: String, bgs: String, width: int, height: int, characters_collide: bool) -> void:
	self.id = id
	self.identifier = identifier

	self.bgm = bgm
	self.bgs = bgs

	self.width = width
	self.height = height

	self.characters_collide = characters_collide


func pixel_size() -> Vector2i:
	return Vector2i(
		width * Constants.CELL_SIZE,
		height * Constants.CELL_SIZE
	)


func is_within_bounds(position: Vector2i) -> bool:
	return position.x >= 0 and position.x < width and position.y >= 0 and position.y < height


func to_screen(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * Constants.CELL_SIZE, cell.y * Constants.CELL_SIZE)


func to_cell(position: Vector2) -> Vector2i:
	return Vector2i(
		int(position.x / Constants.CELL_SIZE),
		int(position.y / Constants.CELL_SIZE)
	)


func collision_flag(cell: Vector2i) -> int:
	return collisions.get(cell, Constants.CELL_NONE)


func is_solid(cell: Vector2i) -> bool:
	return (collision_flag(cell) & Constants.CELL_FULL_BLOCK) != 0


func add_character(character: Character) -> void:
	_characters[character.id] = character


func remove_character(character_id: int) -> void:
	var character: Character = _characters.get(character_id)
	if not character:
		return

	_characters.erase(character_id)


func get_character(character_id: int) -> Character:
	return _characters.get(character_id)


func get_characters() -> Array[Character]:
	var result: Array[Character] = []
	result.assign(_characters.values())
	return result


func has_character_at(cell: Vector2i) -> bool:
	for character: Character in _characters.values():
		if character.get_cell() == cell:
			return true
	return false


func get_characters_at(cell: Vector2i) -> Array[Character]:
	var result: Array[Character] = []
	for character: Character in _characters.values():
		if character.get_cell() == cell:
			result.append(character)
	return result


func can_pass(from: Vector2i, direction: Vector2i) -> bool:
	var to: Vector2i = from + direction

	if not is_within_bounds(from) or not is_within_bounds(to):
		return false

	if not _can_pass_tiles(from, to, direction):
		return false

	return true


func _can_pass_tiles(from: Vector2i, to: Vector2i, direction: Vector2i) -> bool:
	var from_flag: int = collision_flag(from)
	var to_flag: int = collision_flag(to)

	if (from_flag & Constants.CELL_COLLISION_FULL_BLOCK) != 0:
		return false

	if (to_flag & Constants.CELL_COLLISION_FULL_BLOCK) != 0:
		return false

	var direction_flag: int = _direction_to_flag(direction)
	var opposite_flag: int = _direction_to_flag(-direction)

	if (from_flag & direction_flag) != 0:
		return false

	if (to_flag & opposite_flag) != 0:
		return false

	if abs(direction.x) == 1 and abs(direction.y) == 1:
		var horiz_cell: Vector2i = Vector2i(from.x + direction.x, from.y)
		var vert_cell: Vector2i = Vector2i(from.x, from.y + direction.y)

		if is_solid(horiz_cell) or is_solid(vert_cell):
			return false

	return true


func _direction_to_flag(direction: Vector2i) -> int:
	match direction:
		Vector2i.DOWN:
			return Constants.CELL_DOWN
		Vector2i.LEFT:
			return Constants.CELL_LEFT
		Vector2i.RIGHT:
			return Constants.CELL_RIGHT
		Vector2i.UP:
			return Constants.CELL_UP
		_:
			return Constants.CELL_NONE
