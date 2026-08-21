extends RefCounted
class_name AuthRepository


var _database: Database
var _accounts: Accounts


func _init(database: Database, accounts: Accounts) -> void:
	_database = database
	_accounts = accounts


func sign_in(email: String, password: String) -> Account:
	if not _is_email_valid(email):
		return null

	if not _is_password_valid(password):
		return null

	var model: Models.AccountModel = await _database.row(
		"SELECT id, email, password, access_at, created_at, updated_at FROM accounts WHERE email = ?",
		[email],
		Models.AccountModel
	)

	if model == null:
		return null

	if not Sha256.new().verify_password(password, model.password):
		return null

	var account: Account = Account.new(
		model.id,
		model.email,
		model.password,
		model.access_at,
		model.created_at,
		model.updated_at
	)

	return account


func register(email: String, password: String, password_confirm: String) -> Account:
	if not _is_email_valid(email):
		return null

	if not _is_password_valid(password):
		return null

	if password != password_confirm:
		return null

	var existing: Variant = await _database.scalar(
		"SELECT COUNT(*) FROM accounts WHERE email = ?",
		[email]
	)

	if existing > 0:
		return null

	var hashed: String = Sha256.new().hash_password(password)
	var now: int = _database.now()

	var result: Error = await _database.exec(
		"INSERT INTO accounts (email, password, access_at, created_at, updated_at) VALUES (?, ?, ?, ?, ?)",
		[email, hashed, now, now, now]
	)

	if result != OK:
		return null

	var model: Models.AccountModel = await _database.row(
		"SELECT id, email, password, access_at, created_at, updated_at FROM accounts WHERE email = ?",
		[email],
		Models.AccountModel
	)

	if model == null:
		return null

	await update_updated_at(model.id)

	var account: Account = Account.new(
		model.id,
		model.email,
		model.password,
		model.access_at,
		model.created_at,
		model.updated_at
	)

	return account


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
