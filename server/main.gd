extends Node2D
class_name Main


func _ready() -> void:
	if not _setup_database():
		return

	if not _setup_network():
		return

	if not _setup_handlers():
		return

	Network.client_connected.connect(
		_on_client_connected
	)

	Network.client_disconnected.connect(
		_on_client_disconnected
	)


func _setup_database() -> bool:
	print("Iniciando SQLite...")

	var err: Error = Database.create(
		Constants.DATABASE_PATH,
		Constants.DATABASE_FILENAME
	)

	if err!= OK:
		push_error("Erro ao iniciar o sqlite (%s)." % error_string(err))
		return false

	print("SQLite iniciado com sucesso!")
	return true


func _setup_network() -> bool:
	print("Iniciando servidor em %s:%d (máx. %d clientes)..." % [
		Constants.NETWORK_HOST,
		Constants.NETWORK_PORT,
		Constants.MAX_PEERS,
	])

	var err: Error = Network.start()
	if err != OK:
		push_error("Erro ao iniciar o servidor (%s)." % error_string(err))
		return false

	print("Servidor iniciado com sucesso!")
	return true


func _setup_handlers() -> bool:
	return true


func _on_client_connected() -> void:
	pass


func _on_client_disconnected() -> void:
	pass
