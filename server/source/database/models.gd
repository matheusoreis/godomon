extends RefCounted
class_name Models


func from_row(row: Array, cols: PackedStringArray):
	for i in cols.size():
		set(cols[i], row[i])


class AccountModel extends Models:
	var id: int

	var email: String
	var password: String

	var access_at: int

	var created_at: int
	var updated_at: int


class CharacterModel extends Models:
	var id: int

	var account: int

	var identifier: String
	var spritesheet: String

	var map: int

	var cel_x: int
	var cel_y: int

	var facing_x: int
	var facing_y: int

	var access_at: int

	var created_at: int
	var updated_at: int
