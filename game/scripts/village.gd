extends Node2D
## 村庄外景：摆放玩家、昼夜色调、醒来旁白、夜幕过场。

const DAY_COLOR := Color("9b95ad")
const NIGHT_COLOR := Color("3a3354")

@onready var player: CharacterBody2D = $Player
@onready var tint: CanvasModulate = $Tint
@onready var spawn_points: Node2D = $SpawnPoints
@onready var night_ghost: Polygon2D = $NightGhost

func _ready() -> void:
	_place_player()
	night_ghost.visible = GameState.has_flag("night_cutscene_done")
	tint.color = NIGHT_COLOR if GameState.phase == GameState.Phase.NIGHT else DAY_COLOR
	if GameState.phase == GameState.Phase.NIGHT \
			and not GameState.has_flag("night_cutscene_done"):
		_night_cutscene()
	elif not GameState.has_flag("intro_done"):
		_intro()

func _place_player() -> void:
	var point: Node2D = spawn_points.get_node_or_null(NodePath(Router.spawn_name))
	if point == null:
		point = spawn_points.get_node("default")
	player.global_position = point.global_position

func _intro() -> void:
	GameState.set_flag("intro_done")
	Ui.show_dialogue([
		"……雨停了。",
		"土腥味。我从土里爬出来，像一根被拔出来的钉子。",
		"四年了。先回村，回家看看。",
		"（WASD 或方向键移动，E 调查，Tab 查看笔记）",
	])

func _night_cutscene() -> void:
	GameState.set_flag("night_cutscene_done")
	player.can_move = false
	tint.color = DAY_COLOR
	var t := create_tween()
	t.tween_property(tint, "color", NIGHT_COLOR, 3.0)
	await t.finished
	Ui.show_dialogue([
		"天，毫无征兆地黑了下来。",
		"这不是日落。日落没有这么快，也没有这么静。",
		"远处，祠堂的方向，立着一点白。",
		"——去祠堂。",
	])
	await Ui.dialogue_finished
	night_ghost.visible = true
	player.can_move = true
