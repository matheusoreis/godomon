extends Entity
class_name Character


var _movement_offset: Vector2 = Vector2.ZERO
var _is_transitioning: bool = false
var _current_frame: int = 1
var _last_step_frame: int = 0

var _pending_moves: Queue = Queue.new(Constants.MAX_PENDING_MOVES)


func setup(
	id: int,
	identifier: String,
	spritesheet: String,
	map: int,
	cell: Vector2i,
	facing: Vector2i
) -> void:
	super.setup(id, identifier, spritesheet, map, cell, facing)

	%Sprite2D.hframes = 3
	%Sprite2D.vframes = 4
	_load_texture()

	position = Vector2(cell * Constants.CELL_SIZE)
	_sync_visuals()


func _physics_process(delta: float) -> void:
	_update_movement(delta)
	_position_sync()


func is_transitioning() -> bool:
	return _is_transitioning


func move(direction: Vector2i) -> bool:
	if not _is_transitioning:
		_start_move(direction)
		return true

	if _pending_moves.enqueue(direction):
		return false

	_pending_moves.dequeue()
	_pending_moves.enqueue(direction)
	return false


func _start_move(direction: Vector2i) -> void:
	facing = direction
	_movement_offset = Vector2(-direction) * Constants.CELL_SIZE
	cell += direction
	_is_transitioning = true
	_last_step_frame = _toggle_step_frame(_last_step_frame)
	_current_frame = 1
	_sync_visuals()


func teleport_to(new_cell: Vector2i, new_facing: Vector2i = Vector2i.ZERO) -> void:
	_pending_moves.clear()
	cell = new_cell
	if new_facing != Vector2i.ZERO:
		facing = new_facing
	_movement_offset = Vector2.ZERO
	_is_transitioning = false
	position = Vector2(cell * Constants.CELL_SIZE)
	_sync_visuals()


func _load_texture() -> void:
	var path: String = Constants.CHARACTER_SPRITE_DIRECTORY + spritesheet + ".png"
	if not ResourceLoader.exists(path):
		return

	%Sprite2D.texture = load(path)


func _position_sync() -> void:
	position = Vector2(cell * Constants.CELL_SIZE) + _movement_offset


func _update_movement(delta: float) -> void:
	if not _is_transitioning:
		return

	var speed: float = Constants.WALKING_SPEED * Constants.CELL_SIZE * delta
	_movement_offset = _movement_offset.move_toward(Vector2.ZERO, speed)

	if not _movement_offset.is_zero_approx():
		_current_frame = _resolve_walking_frame()
		_sync_visuals()
		return

	_is_transitioning = false
	_current_frame = 1
	_sync_visuals()

	if _pending_moves.is_empty():
		return

	_start_move(_pending_moves.dequeue())


func _sync_visuals() -> void:
	if %Sprite2D.texture == null:
		return

	var row: int = Constants.DIRECTION_SPRITE_ROW[facing]
	var col: int = _current_frame
	var frame_index: int = row * %Sprite2D.hframes + col

	%Sprite2D.frame = frame_index


func _resolve_walking_frame() -> int:
	var walked_enough: bool = _movement_offset.length() > (Constants.CELL_SIZE * Constants.ANIMATION_STEP_THRESHOLD)
	return _last_step_frame if walked_enough else 1


func _toggle_step_frame(previous: int) -> int:
	return 2 if previous == 0 else 0
