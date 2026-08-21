extends Node2D
class_name Main


var _database: Database
var _network: Network

var _accounts: AccountModule
var _characters: CharacterModule
var _maps: MapModule


func _ready() -> void:
	_accounts = AccountModule.new()
	_characters = CharacterModule.new()
	_maps = MapModule.new()

	if not _setup_database():
		return

	if not _setup_network():
		return

	if not _setup_handlers():
		return

	_network.client_connected.connect(
		_on_client_connected
	)

	_network.client_disconnected.connect(
		_on_client_disconnected
	)

	_maps.load_all_from_disk()


func _physics_process(_delta: float) -> void:
	if _database:
		_database.poll()

	if _network:
		_network.poll()


func _setup_database() -> bool:
	_database = Database.new()

	print("Iniciando SQLite...")

	var err: Error = _database.create(
		Constants.DATABASE_PATH,
		Constants.DATABASE_FILENAME
	)

	if err!= OK:
		push_error("Erro ao iniciar o sqlite (%s)." % error_string(err))
		return false

	print("SQLite iniciado com sucesso!")
	return true


func _setup_network() -> bool:
	_network = Network.new()

	print("Iniciando servidor em %s:%d (máx. %d clientes)..." % [
		Constants.NETWORK_HOST,
		Constants.NETWORK_PORT,
		Constants.MAX_PEERS,
	])

	var err: Error = _network.start()
	if err != OK:
		push_error("Erro ao iniciar o servidor (%s)." % error_string(err))
		return false

	print("Servidor iniciado com sucesso!")
	return true


func _setup_handlers() -> bool:
	var auth: AuthHandler = AuthHandler.new(
		_network, _database, _accounts
	)

	var auth_err: Error = auth.register()
	if auth_err != OK:
		return false

	var account: AccountHandler = AccountHandler.new(
		_network, _database, _accounts, _characters, _maps
	)

	var account_err: Error = account.register()
	if account_err != OK:
		return false

	return true


func _on_client_connected(peer_id: int) -> void:
	print("[NETWORK] Cliente %d conectado." % peer_id)


func _on_client_disconnected(peer_id: int) -> void:
	print("[NETWORK] Cliente %d desconectado." % peer_id)
