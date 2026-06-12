extends Node
## 场景路由：切场景时记录目标出生点名，由目标场景在 _ready 里读取并摆放玩家。

var spawn_name: String = "default"

func change_scene(scene_path: String, spawn: String = "default") -> void:
	spawn_name = spawn
	get_tree().change_scene_to_file.call_deferred(scene_path)
