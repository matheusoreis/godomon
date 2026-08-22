extends Node2D
class_name Map


@export_group("Data")
@export var id: int
@export var identifier: String

@export_group("Audio")
@export var bgm: String
@export var bgs: String

@export_group("Configuration")
@export var size: Vector2i
@export var characters_collide: bool

@export_group("Layers")
@export var tilemap_layers: Array[TileMapLayer] = []

var _collisions: Dictionary[Vector2i, int]

var _characters: Dictionary[int, Character]


func setup(id: int, identifier: String, bgm: String, bgs: String, size: Vector2i, characters_collide: bool) -> void:
	self.id = id
	self.identifier = identifier

	self.bgm = bgm
	self.bgs = bgs

	self.size = size
	self.characters_collide = characters_collide


func pixel_size() -> Vector2i:
	return Vector2i(
		size.x * Constants.CELL_SIZE,
		size.y * Constants.CELL_SIZE
	)


func is_within_bounds(position: Vector2i) -> bool:
	return position.x >= 0 and position.x < size.x and position.y >= 0 and position.y < size.y


func to_screen(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * Constants.CELL_SIZE, cell.y * Constants.CELL_SIZE)


func to_cell(position: Vector2) -> Vector2i:
	return Vector2i(
		int(position.x / Constants.CELL_SIZE),
		int(position.y / Constants.CELL_SIZE)
	)


func collision_flag(cell: Vector2i) -> int:
	return _collisions.get(cell, Constants.CELL_NONE)


func is_solid(cell: Vector2i) -> bool:
	return (collision_flag(cell) & Constants.CELL_FULL_BLOCK) != 0


func add_character(character: Character) -> void:
	_characters[character.id] = character

	if character.get_parent() != self:
		add_child(character)

	character.position = to_screen(character.cell)


func remove_character(character_id: int) -> void:
	var character: Character = _characters.get(character_id)
	if not character:
		return

	_characters.erase(character_id)

	if character.get_parent() == self:
		remove_child(character)


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

	if (from_flag & Constants.CELL_FULL_BLOCK) != 0:
		return false

	if (to_flag & Constants.CELL_FULL_BLOCK) != 0:
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


func _load_collisions_from_tiles() -> void:
	_collisions.clear()

	for layer: TileMapLayer in tilemap_layers:
		if not layer:
			continue

		for cell: Vector2i in layer.get_used_cells():
			var flag: int = _get_collision_from_tile(layer, cell)
			if flag != Constants.CELL_NONE:
				var current_flag: int = _collisions.get(cell, Constants.CELL_NONE)
				_collisions[cell] = current_flag | flag


func _get_collision_from_tile(layer: TileMapLayer, cell: Vector2i) -> int:
	var tile_data: TileData = layer.get_cell_tile_data(cell)
	if not tile_data:
		return Constants.CELL_NONE
	return tile_data.get_custom_data("collision")


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
