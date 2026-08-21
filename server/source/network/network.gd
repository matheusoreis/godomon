extends Node


var network: Multiplayer.Server


func _ready() -> void:
	network = Multiplayer.Server.new()


func start() -> Error:
	return network.start(Constants.NETWORK_HOST, Constants.NETWORK_PORT, Constants.MAX_PEERS)


func stop() -> Error:
	return network.stop()


func exec(target: Variant, fn_path: StringName, args: Array = []) -> Error:
	return network.exec(target, fn_path, args)


func get_peers() -> Array[int]:
	return network.get_peers()


func get_peer_count() -> int:
	return network.get_peer_count()


func has_peer(peer_id: int) -> bool:
	return network.has_peer(peer_id)


func sender_id() -> int:
	return network.sender_id()


func peer_address(peer_id: int) -> String:
	return network.peer_address(peer_id)


func kick(peer_id: int) -> void:
	network.kick(peer_id)


func _physics_process(_delta: float) -> void:
	if network == null:
		return

	network.poll()
