extends Area2D
## 门：玩家踏入即切换场景。

@export_file("*.tscn") var target_scene: String
@export var spawn: String = "default"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Router.change_scene(target_scene, spawn)
