extends RefCounted
class_name Entity


var id: int
var identifier: String

var account: int

var spritesheet: String

var map: int
var cell: Vector2i
var facing: Vector2i


func _init(
	id: int,
	identifier: String,
	account: int,
	spritesheet: String,
	map: int,
	cell: Vector2i,
	facing: Vector2i
) -> void:
	self.id = id
	self.identifier = identifier

	self.account = account

	self.spritesheet = spritesheet

	self.map = map
	self.cell = cell
	self.facing = facing
