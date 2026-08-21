extends Node
class_name MapHandler


var _network: Network
var _accounts: AccountModule
var _characters: CharacterModule
var _maps: MapModule


var functions: Array[Callable] = [
	map_data,
	move_character,
]


func _init(network: Network, accounts: AccountModule, characters: CharacterModule, maps: MapModule) -> void:
	_network = network
	_accounts = accounts
	_characters = characters
	_maps = maps


func register() -> Error:
	return _network.register(functions)


func unregister() -> Error:
	return _network.unregister(functions)


func map_data(map_id: int) -> void:
	var sender_id: int = _network.sender_id()

	var map: Map = _maps.map(map_id)
	if map == null:
		_network.exec(sender_id, &"Alert", ["MAP_NOT_FOUND"])
		return

	var targets: Array = _characters.in_map(map_id)
	targets.erase(sender_id)

	var characters: Array = []
	for target_id in targets:
		var other: Character = _characters.character(target_id)
		if other:
			characters.append([
				target_id,
				other.identifier,
				other.spritesheet,
				other.map,
				other.cell.x,
				other.cell.y,
				other.facing.x,
				other.facing.y
			])

	_network.exec(sender_id, &"MapData", [
		map.id,
		map.identifier,
		map.bgm,
		map.bgs,
		map.size.x,
		map.size.y,
		map.characters_collide,
		map.collisions,
		characters
	])


func move_character(direction: Vector2i) -> void:
	var sender_id: int = _network.sender_id()

	if not _accounts.has(sender_id):
		_network.exec(sender_id, &"Alert", ["NOT_LOGGED_IN"])
		return

	if not _characters.has(sender_id):
		_network.exec(sender_id, &"Alert", ["NO_CHARACTER_SELECTED"])
		return

	var character: Character = _characters.character(sender_id)
	var map: Map = _maps.map(character.map)

	if map == null:
		_network.exec(sender_id, &"Alert", ["MAP_NOT_FOUND"])
		return

	if not _characters.move(sender_id, direction, map):
		_network.exec(sender_id, &"Alert", ["INVALID_MOVEMENT"])
		return

	var targets: Array = _characters.in_map(map.id)
	targets.erase(sender_id)

	if not targets.is_empty():
		_network.exec(targets, &"MoveCharacter", [sender_id, direction])
