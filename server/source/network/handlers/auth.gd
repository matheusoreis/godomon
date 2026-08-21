extends Node
class_name AuthHandler


var _auth_repository: AuthRepository


var functions: Array[Callable] = [
	sign_in,
	sign_up
]


func _init(database: Database) -> void:
	_auth_repository = AuthRepository.new(database)


func register() -> Error:
	return Network.register(functions)


func unregister() -> Error:
	return Network.unregister(functions)


func sign_in(email: String, password: String) -> void:
	var sender_id: int = Network.sender_id()

	if Accounts.has(sender_id):
		Network.exec(sender_id, &"Alert", ["You are already logged in"])
		return

	var result: Array = await _auth_repository.sign_in(email, password)
	var error_code: int = result[0]
	var data = result[1]

	if error_code != OK:
		match data:
			"INVALID_EMAIL":
				Network.exec(sender_id, &"Alert", ["Invalid email"])
			"INVALID_PASSWORD":
				Network.exec(sender_id, &"Alert", ["Invalid password"])
			"ACCOUNT_NOT_FOUND":
				Network.exec(sender_id, &"Alert", ["Account not found"])
			"INCORRECT_PASSWORD":
				Network.exec(sender_id, &"Alert", ["Incorrect password"])
			_:
				Network.exec(sender_id, &"Alert", ["Login failed"])
		return

	var account: Account = data

	if Accounts.find_by_account_id(account.id) != null:
		Network.exec(sender_id, &"Alert", ["This account is already online"])
		return

	Accounts.add(sender_id, account)

	await _auth_repository.update_access_at(account.id)

	Network.exec(sender_id, &"SignIn", [])


func sign_up(email: String, password: String, password_confirm: String) -> void:
	var sender_id: int = Network.sender_id()

	if Accounts.has(sender_id):
		Network.exec(sender_id, &"Alert", ["You are already logged in"])
		return

	var result: Array = await _auth_repository.sign_up(email, password, password_confirm)
	var error_code: int = result[0]
	var data = result[1]

	if error_code != OK:
		match data:
			"INVALID_EMAIL":
				Network.exec(sender_id, &"Alert", ["Invalid email"])
			"INVALID_PASSWORD":
				Network.exec(sender_id, &"Alert", ["Invalid password"])
			"PASSWORDS_DO_NOT_MATCH":
				Network.exec(sender_id, &"Alert", ["Passwords do not match"])
			"EMAIL_ALREADY_REGISTERED":
				Network.exec(sender_id, &"Alert", ["Email already registered"])
			"INTERNAL_ERROR":
				Network.exec(sender_id, &"Alert", ["Internal server error"])
			_:
				Network.exec(sender_id, &"Alert", ["Registration failed"])
		return

	var account: Account = data

	Accounts.add(sender_id, account)

	Network.exec(sender_id, &"SignUp", [])
