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
	select_character
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
		_network.exec(sender_id, &"Alert", ["NOT_LOGGED_IN"])
		return

	var account: Account = _accounts.account(sender_id)
	var characters: Array[Models.CharacterModel] = await _account_repository.get_characters_by_account(account.id)

	_network.exec(sender_id, &"ListCharacters", [characters])


func create_character(identifier: String, spritesheet: String) -> void:
	var sender_id: int = _network.sender_id()

	if not _accounts.has(sender_id):
		_network.exec(sender_id, &"Alert", ["NOT_LOGGED_IN"])
		return

	var account: Account = _accounts.account(sender_id)

	var result: Array = await _account_repository.create_character(account.id, identifier, spritesheet)
	var error_code: int = result[0]
	var data = result[1]

	if error_code != OK:
		match data:
			"INVALID_IDENTIFIER":
				_network.exec(sender_id, &"Alert", ["INVALID_IDENTIFIER"])
			"IDENTIFIER_ALREADY_EXISTS":
				_network.exec(sender_id, &"Alert", ["IDENTIFIER_ALREADY_EXISTS"])
			"INVALID_SPRITE":
				_network.exec(sender_id, &"Alert", ["INVALID_SPRITE"])
			"DATABASE_ERROR":
				_network.exec(sender_id, &"Alert", ["DATABASE_ERROR"])
			_:
				_network.exec(sender_id, &"Alert", ["CREATE_CHARACTER_FAILED"])
		return

	var model: Models.CharacterModel = data
	_network.exec(sender_id, &"CreateCharacter", [model.id, model.identifier, model.spritesheet])


func delete_character(character_id: int) -> void:
	var sender_id: int = _network.sender_id()

	if not _accounts.has(sender_id):
		_network.exec(sender_id, &"Alert", ["NOT_LOGGED_IN"])
		return

	var account: Account = _accounts.account(sender_id)

	if _characters.has(character_id):
		_network.exec(sender_id, &"Alert", ["CHARACTER_ONLINE"])
		return

	var result: Array = await _account_repository.delete_character(character_id, account.id)
	var error_code: int = result[0]
	var data = result[1]

	if error_code != OK:
		match data:
			"NOT_OWNER":
				_network.exec(sender_id, &"Alert", ["NOT_OWNER"])
			"DATABASE_ERROR":
				_network.exec(sender_id, &"Alert", ["DATABASE_ERROR"])
			_:
				_network.exec(sender_id, &"Alert", ["DELETE_CHARACTER_FAILED"])
		return

	_network.exec(sender_id, &"DeleteCharacter", [character_id])


func select_character(character_id: int) -> void:
	var sender_id: int = _network.sender_id()

	if not _accounts.has(sender_id):
		_network.exec(sender_id, &"Alert", ["NOT_LOGGED_IN"])
		return

	var account: Account = _accounts.account(sender_id)

	if _characters.has(character_id):
		_network.exec(sender_id, &"Alert", ["CHARACTER_ALREADY_ONLINE"])
		return

	var result: Array = await _account_repository.select_character(character_id, account.id)
	var error_code: int = result[0]
	var data = result[1]

	if error_code != OK:
		match data:
			"NOT_OWNER":
				_network.exec(sender_id, &"Alert", ["NOT_OWNER"])
			"CHARACTER_NOT_FOUND":
				_network.exec(sender_id, &"Alert", ["CHARACTER_NOT_FOUND"])
			"DATABASE_ERROR":
				_network.exec(sender_id, &"Alert", ["DATABASE_ERROR"])
			_:
				_network.exec(sender_id, &"Alert", ["SELECT_CHARACTER_FAILED"])
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

	# Envia os dados do mapa
	_network.exec(sender_id, &"MapData", [character.map])

	# Envia o novo personagem para todos os outros no mapa
	var targets: Array = _characters.in_map(character.map)
	targets.erase(sender_id)

	if not targets.is_empty():
		var new_character_data: Array = [
			sender_id,
			character.identifier,
			character.spritesheet,
			character.map,
			character.cell.x,
			character.cell.y,
			character.facing.x,
			character.facing.y
		]
		_network.exec(targets, &"CharacterToCharacters", [new_character_data])

	_network.exec(sender_id, &"SelectCharacter", [character_id])
