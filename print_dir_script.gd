extends Node

func _ready() -> void:
	print("=== RES DIRECTORY TREE ===")
	_print_directory_tree("res://", 0)
	print("=== END RES DIRECTORY TREE ===")

func _print_directory_tree(path: String, depth: int) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		push_error("Failed to open directory: %s" % path)
		return

	var entries: Array[String] = []
	dir.list_dir_begin()
	while true:
		var entry: String = dir.get_next()
		if entry == "":
			break

		if entry == "." or entry == "..":
			continue

		entries.append(entry)
	dir.list_dir_end()

	entries.sort()

	for entry in entries:
		var full_path: String = path.path_join(entry)
		var indent: String = "  ".repeat(depth)

		if DirAccess.dir_exists_absolute(full_path):
			print("%s[%s/]" % [indent, entry])
			_print_directory_tree(full_path, depth + 1)
		else:
			print("%s%s" % [indent, entry])
