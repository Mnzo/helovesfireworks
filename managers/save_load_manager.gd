extends Node

const SAVE_FOLDER: String = "user://save/"

func verify_save_folder() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_FOLDER):
		DirAccess.make_dir_recursive_absolute(SAVE_FOLDER)
		
func save_resource(resource: Resource, path: String) -> void:
	verify_save_folder()
	if resource != null:
		var err: int = ResourceSaver.save(resource, path)
		if err != OK:
			push_error("Failed to save resource in %s, error code: %s" % [path, err])

func try_load_resource(path: String) -> Resource:
	if not ResourceLoader.exists(path):
		return null
	var res: Resource = ResourceLoader.load(path)
	if res == null:
		push_error("Failed to load resource in %s" % path)
	return res
