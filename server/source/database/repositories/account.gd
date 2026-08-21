extends Node
class_name AccountRepository


var _database: Database
var _accounts: Accounts


func _init(database: Database, accounts: Accounts) -> void:
	_database = database
	_accounts = accounts


func get_characters_by_account(account_id: int) -> Array[Models.CharacterModel]:
	var rows: Array = await _database.rows(
		"SELECT id, account, identifier, spritesheet, map, cell_x, cell_y, facing_x, facing_y, access_at, created_at, updated_at FROM characters WHERE account = ? ORDER BY id",
		[account_id],
		Models.CharacterModel
	)

	return rows


func get_character_by_id(character_id: int) -> Models.CharacterModel:
	var model: Models.CharacterModel = await _database.row(
		"SELECT id, account, identifier, spritesheet, map, cell_x, cell_y, facing_x, facing_y, access_at, created_at, updated_at FROM characters WHERE id = ?",
		[character_id],
		Models.CharacterModel
	)

	return model


func is_character_owner(character_id: int, account_id: int) -> bool:
	var model: Models.CharacterModel = await _database.row(
		"SELECT id FROM characters WHERE id = ? AND account = ?",
		[character_id, account_id],
		Models.CharacterModel
	)

	return model != null


func character_identifier_exists(account_id: int, identifier: String) -> bool:
	var result: Variant = await _database.scalar(
		"SELECT COUNT(*) FROM characters WHERE account = ? AND identifier = ?",
		[account_id, identifier]
	)

	return result > 0


func get_character_count(account_id: int) -> int:
	var result: Variant = await _database.scalar(
		"SELECT COUNT(*) FROM characters WHERE account = ?",
		[account_id]
	)

	return result


func create_character(account_id: int, identifier: String, spritesheet: String) -> bool:
	if not _is_identifier_valid(identifier):
		return false

	if await character_identifier_exists(account_id, identifier):
		return false

	if not Constants.AVALIABLE_SPRITES.has(spritesheet):
		return false

	var result: Error = await _database.exec(
		"""
		INSERT INTO characters (account, identifier, spritesheet, map, cell_x, cell_y, facing_x, facing_y, access_at, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
		[
			account_id,
			identifier,
			spritesheet,
			Constants.START_MAP,
			Constants.START_MAP_POSITION.x,
			Constants.START_MAP_POSITION.y,
			Constants.START_MAP_FACING.x,
			Constants.START_MAP_FACING.y,
			_database.now(),
			_database.now(),
			_database.now()
		]
	)

	return result == OK


func delete_character(character_id: int, account_id: int) -> bool:
	if not await is_character_owner(character_id, account_id):
		return false

	var result: Error = await _database.exec(
		"DELETE FROM characters WHERE id = ? AND account = ?",
		[character_id, account_id]
	)

	return result == OK


func select_character(character_id: int, account_id: int) -> Models.CharacterModel:
	if not await is_character_owner(character_id, account_id):
		return null

	var model: Models.CharacterModel = await get_character_by_id(character_id)
	if model == null:
		return null

	await _database.exec(
		"UPDATE characters SET access_at = ? WHERE id = ?",
		[_database.now(), character_id]
	)

	return model


func update_character_position(character_id: int, cell: Vector2i, facing: Vector2i) -> void:
	await _database.exec(
		"UPDATE characters SET cell_x = ?, cell_y = ?, facing_x = ?, facing_y = ? WHERE id = ?",
		[cell.x, cell.y, facing.x, facing.y, character_id]
	)


func update_access(character_id: int) -> void:
	await _database.exec(
		"UPDATE characters SET access_at = ? WHERE id = ?",
		[_database.now(), character_id]
	)


func update_updated(character_id: int) -> void:
	await _database.exec(
		"UPDATE characters SET updated_at = ? WHERE id = ?",
		[_database.now(), character_id]
	)


func _is_identifier_valid(identifier: String) -> bool:
	return RegEx.create_from_string(Constants.IDENTIFIER_REGEX).search(identifier) != null
