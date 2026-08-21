extends Node
class_name AuthHandler


var _network: Network
var _accounts: AccountModule
var _auth_repository: AuthRepository


var functions: Array[Callable] = [
	sign_in,
	sign_up
]


func _init(network: Network, database: Database, accounts: AccountModule) -> void:
	_network = network
	_accounts = accounts
	_auth_repository = AuthRepository.new(database)


func register() -> Error:
	return _network.register(functions)


func unregister() -> Error:
	return _network.unregister(functions)


func sign_in(email: String, password: String) -> void:
	var sender_id: int = _network.sender_id()

	if _accounts.has(sender_id):
		_network.exec(sender_id, &"Alert", ["ALREADY_LOGGED_IN"])
		return

	var result: Array = await _auth_repository.sign_in(email, password)
	var error_code: int = result[0]
	var data = result[1]

	if error_code != OK:
		match data:
			"INVALID_EMAIL":
				_network.exec(sender_id, &"Alert", ["INVALID_EMAIL"])
			"INVALID_PASSWORD":
				_network.exec(sender_id, &"Alert", ["INVALID_PASSWORD"])
			"ACCOUNT_NOT_FOUND":
				_network.exec(sender_id, &"Alert", ["ACCOUNT_NOT_FOUND"])
			"INCORRECT_PASSWORD":
				_network.exec(sender_id, &"Alert", ["INCORRECT_PASSWORD"])
			_:
				_network.exec(sender_id, &"Alert", ["LOGIN_FAILED"])
		return

	var account: Account = data

	if _accounts.find_by_account_id(account.id) != null:
		_network.exec(sender_id, &"Alert", ["ACCOUNT_ALREADY_ONLINE"])
		return

	_accounts.add(sender_id, account)
	await _auth_repository.update_access_at(account.id)

	_network.exec(sender_id, &"SignIn", [])


func sign_up(email: String, password: String, password_confirm: String) -> void:
	var sender_id: int = _network.sender_id()

	if _accounts.has(sender_id):
		_network.exec(sender_id, &"Alert", ["ALREADY_LOGGED_IN"])
		return

	var result: Array = await _auth_repository.sign_up(email, password, password_confirm)
	var error_code: int = result[0]
	var data = result[1]

	if error_code != OK:
		match data:
			"INVALID_EMAIL":
				_network.exec(sender_id, &"Alert", ["INVALID_EMAIL"])
			"INVALID_PASSWORD":
				_network.exec(sender_id, &"Alert", ["INVALID_PASSWORD"])
			"PASSWORDS_DO_NOT_MATCH":
				_network.exec(sender_id, &"Alert", ["PASSWORDS_DO_NOT_MATCH"])
			"EMAIL_ALREADY_REGISTERED":
				_network.exec(sender_id, &"Alert", ["EMAIL_ALREADY_REGISTERED"])
			"INTERNAL_ERROR":
				_network.exec(sender_id, &"Alert", ["INTERNAL_ERROR"])
			_:
				_network.exec(sender_id, &"Alert", ["REGISTRATION_FAILED"])
		return

	var account: Account = data
	_accounts.add(sender_id, account)

	_network.exec(sender_id, &"SignUp", [])
