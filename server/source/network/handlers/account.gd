extends Node
class_name AccountHandler


var _network: Network

var _accounts: AccountModule
var _characters: CharacterModule
var _maps: MapModule

var _account_repository: AccountRepository



var functions: Array[Callable] = [
	list_characters,
	create_character,
	delete_character,
	select_character,
	move_character,
]


func _init(network: Network, database: Database, accounts: AccountModule, characters: CharacterModule, maps: MapModule) -> void:
	_network = network

	_accounts = accounts
	_characters = characters
	_maps = maps

	_account_repository = AccountRepository.new(database)


func register() -> Error:
	return _network.register(functions)


func unregister() -> Error:
	return _network.unregister(functions)


func list_characters() -> void:
	var sender_id: int = _network.sender_id()

	if not _accounts.has(sender_id):
		_network.exec(sender_id, &"Alert", ["You need to be logged in"])
		return

	var account: Account = _accounts.account(sender_id)

	var characters: Array[Models.CharacterModel] = await _account_repository.get_characters_by_account(account.id)

	_network.exec(sender_id, &"ListCharacters", [characters])


func create_character(identifier: String, spritesheet: String) -> void:
	var sender_id: int = _network.sender_id()

	if not _accounts.has(sender_id):
		_network.exec(sender_id, &"Alert", ["You need to be logged in"])
		return

	var account: Account = _accounts.account(sender_id)

	var result: Array = await _account_repository.create_character(account.id, identifier, spritesheet)
	var error_code: int = result[0]
	var data = result[1]

	if error_code != OK:
		match data:
			"INVALID_IDENTIFIER":
				_network.exec(sender_id, &"Alert", ["Invalid identifier"])
			"IDENTIFIER_ALREADY_EXISTS":
				_network.exec(sender_id, &"Alert", ["Identifier already exists"])
			"INVALID_SPRITE":
				_network.exec(sender_id, &"Alert", ["Invalid sprite"])
			"DATABASE_ERROR":
				_network.exec(sender_id, &"Alert", ["Database error"])
			_:
				_network.exec(sender_id, &"Alert", ["Failed to create character"])
		return

	var model: Models.CharacterModel = data
	_network.exec(sender_id, &"CreateCharacter", [model.id, model.identifier, model.spritesheet])


func delete_character(character_id: int) -> void:
	var sender_id: int = _network.sender_id()

	if not _accounts.has(sender_id):
		_network.exec(sender_id, &"Alert", ["You need to be logged in"])
		return

	var account: Account = _accounts.account(sender_id)

	if _characters.has(character_id):
		_network.exec(sender_id, &"Alert", ["Cannot delete an online character"])
		return

	var result: Array = await _account_repository.delete_character(character_id, account.id)
	var error_code: int = result[0]
	var data = result[1]

	if error_code != OK:
		match data:
			"NOT_OWNER":
				_network.exec(sender_id, &"Alert", ["Character does not belong to you"])
			"DATABASE_ERROR":
				_network.exec(sender_id, &"Alert", ["Database error"])
			_:
				_network.exec(sender_id, &"Alert", ["Failed to delete character"])
		return

	_network.exec(sender_id, &"DeleteCharacter", [character_id])


func select_character(character_id: int) -> void:
	var sender_id: int = _network.sender_id()

	if not _accounts.has(sender_id):
		_network.exec(sender_id, &"Alert", ["You need to be logged in"])
		return

	var account: Account = _accounts.account(sender_id)

	if _characters.has(character_id):
		_network.exec(sender_id, &"Alert", ["Character already online"])
		return

	var result: Array = await _account_repository.select_character(character_id, account.id)
	var error_code: int = result[0]
	var data = result[1]

	if error_code != OK:
		match data:
			"NOT_OWNER":
				_network.exec(sender_id, &"Alert", ["Character does not belong to you"])
			"CHARACTER_NOT_FOUND":
				_network.exec(sender_id, &"Alert", ["Character not found"])
			"DATABASE_ERROR":
				_network.exec(sender_id, &"Alert", ["Database error"])
			_:
				_network.exec(sender_id, &"Alert", ["Failed to select character"])
		return

	var model: Models.CharacterModel = data

	var character: Character = Character.new(
		model.id,
		model.identifier,
		model.spritesheet,
		model.map,
		Vector2i(model.cell_x, model.cell_y),
		Vector2i(model.facing_x, model.facing_y)
	)

	_characters.add(sender_id, character)

	_network.exec(sender_id, &"MapData", [])
	_network.exec(sender_id, &"MapCollisions", [])

	_network.exec(sender_id, &"CharactersToCharacter", [])
	_network.exec(sender_id, &"CharacterToCharacters", [])

	_network.exec(sender_id, &"SelectCharacter", [character_id])


func move_character(direction: Vector2i) -> void:
	var sender_id: int = _network.sender_id()

	if not _accounts.has(sender_id):
		_network.exec(sender_id, &"Alert", ["You need to be logged in"])
		return

	if not _characters.has(sender_id):
		_network.exec(sender_id, &"Alert", ["No character selected"])
		return

	var character: Character = _characters.character(sender_id)
	var map: Map = _maps.map(character.map)

	if map == null:
		_network.exec(sender_id, &"Alert", ["Map not found"])
		return

	if not _characters.move(sender_id, direction, map):
		_network.exec(sender_id, &"Alert", ["Invalid movement"])
		return

	_network.exec(sender_id, &"MoveCharacter", [direction])
