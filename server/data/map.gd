extends Resource
class_name MapData


@export var id: int
@export var identifier: String

@export var bgm: String
@export var bgs: String

@export var size: Vector2i

@export var characters_collide: bool

@export_storage var collisions: Dictionary[Vector2i, int]
