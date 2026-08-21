extends RefCounted
class_name Models


func from_row(row: Array, cols: PackedStringArray):
	for i in cols.size():
		set(cols[i], row[i])
