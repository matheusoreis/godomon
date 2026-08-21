extends RefCounted
class_name AuthRepository


var _database: Database


func _init(database: Database) -> void:
	_database = database


func sign_in(email: String, password: String) -> Array:
	if not _is_email_valid(email):
		return [ERR_INVALID_PARAMETER, "INVALID_EMAIL"]

	if not _is_password_valid(password):
		return [ERR_INVALID_PARAMETER, "INVALID_PASSWORD"]

	var model: Models.AccountModel = await _database.row(
		"SELECT id, email, password, access_at, created_at, updated_at FROM accounts WHERE email = ?",
		[email],
		Models.AccountModel
	)

	if model == null:
		return [ERR_DOES_NOT_EXIST, "ACCOUNT_NOT_FOUND"]

	if not Sha256.new().verify_password(password, model.password):
		return [ERR_UNAUTHORIZED, "INCORRECT_PASSWORD"]

	var account: Account = Account.new(
		model.id,
		model.email,
		model.password,
		model.access_at,
		model.created_at,
		model.updated_at
	)

	return [OK, account]


func sign_up(email: String, password: String, password_confirm: String) -> Array:
	if not _is_email_valid(email):
		return [ERR_INVALID_PARAMETER, "INVALID_EMAIL"]

	if not _is_password_valid(password):
		return [ERR_INVALID_PARAMETER, "INVALID_PASSWORD"]

	if password != password_confirm:
		return [ERR_INVALID_DATA, "PASSWORDS_DO_NOT_MATCH"]

	var existing: Variant = await _database.scalar(
		"SELECT COUNT(*) FROM accounts WHERE email = ?",
		[email]
	)

	if existing > 0:
		return [ERR_ALREADY_EXISTS, "EMAIL_ALREADY_REGISTERED"]

	var hashed: String = Sha256.new().hash_password(password)
	var now: int = _database.now()

	var result: Error = await _database.exec(
		"INSERT INTO accounts (email, password, access_at, created_at, updated_at) VALUES (?, ?, ?, ?, ?)",
		[email, hashed, now, now, now]
	)

	if result != OK:
		return [ERR_DATABASE_CANT_WRITE, "INTERNAL_ERROR"]

	var model: Models.AccountModel = await _database.row(
		"SELECT id, email, password, access_at, created_at, updated_at FROM accounts WHERE email = ?",
		[email],
		Models.AccountModel
	)

	if model == null:
		return [ERR_DOES_NOT_EXIST, "INTERNAL_ERROR"]

	await update_updated_at(model.id)

	var account: Account = Account.new(
		model.id,
		model.email,
		model.password,
		model.access_at,
		model.created_at,
		model.updated_at
	)

	return [OK, account]


func update_access_at(account_id: int) -> void:
	await _database.exec(
		"UPDATE accounts SET access_at = ? WHERE id = ?",
		[_database.now(), account_id]
	)


func update_updated_at(account_id: int) -> void:
	await _database.exec(
		"UPDATE accounts SET updated_at = ? WHERE id = ?",
		[_database.now(), account_id]
	)


func _is_email_valid(email: String) -> bool:
	return RegEx.create_from_string(Constants.EMAIL_REGEX).search(email) != null


func _is_password_valid(password: String) -> bool:
	return RegEx.create_from_string(Constants.PASSWORD_REGEX).search(password) != null
