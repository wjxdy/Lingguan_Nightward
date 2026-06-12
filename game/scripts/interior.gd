extends Node2D
## 室内通用脚本：摆放玩家出生点 + 按剧情阶段调整色调。

const DAY_COLOR := Color("b8b2c4")
const NIGHT_COLOR := Color("46405e")

@onready var player: CharacterBody2D = $Player
@onready var tint: CanvasModulate = $Tint
@onready var spawn_points: Node2D = $SpawnPoints

func _ready() -> void:
	var point: Node2D = spawn_points.get_node_or_null(NodePath(Router.spawn_name))
	if point == null:
		point = spawn_points.get_node("default")
	player.global_position = point.global_position
	tint.color = NIGHT_COLOR if GameState.phase == GameState.Phase.NIGHT else DAY_COLOR
