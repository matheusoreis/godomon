extends Node
class_name CharacterModule


var _characters: Dictionary[int, Character] = {}


func add(peer_id: int, character: Character) -> void:
	if has(peer_id):
		return

	_characters[peer_id] = character


func remove(peer_id: int) -> void:
	if not has(peer_id):
		return

	_characters.erase(peer_id)


func character(peer_id: int) -> Character:
	return _characters.get(peer_id)


func has(peer_id: int) -> bool:
	return _characters.has(peer_id)


func count() -> int:
	return _characters.size()


func all() -> Array[Character]:
	return _characters.values()


func in_map(map: int) -> Array:
	var result: Array = []

	for peer_id: int in _characters:
		if _characters[peer_id].map == map:
			result.append(peer_id)

	return result


func move(peer_id: int, direction: Vector2i, map: Map) -> bool:
	var character: Character = character(peer_id)
	if character == null:
		return false

	if not map.can_pass(character.cell, direction):
		return false

	character.move(direction)

	return true
