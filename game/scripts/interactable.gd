extends Area2D
class_name Interactable
## 通用可调查物：玩家靠近按 E 触发对话，可选地登记一条线索。
## 用法：场景里放 Area2D 挂本脚本，在检查器里填 lines / clue_id / one_shot。

@export var lines: PackedStringArray = []
## 留空表示纯调查文本；填写则登记线索，id 必须存在于 GameState.CLUE_TEXTS
@export var clue_id: String = ""
@export var one_shot := false  ## true 则只能调查一次

var _used := false

func _ready() -> void:
	add_to_group("interactable")

func interact() -> void:
	if one_shot and _used:
		return
	_used = true
	Ui.show_dialogue(lines)
	await Ui.dialogue_finished
	if clue_id != "" and clue_id not in GameState.clues:
		var is_first: bool = GameState.clues.is_empty()
		GameState.add_clue(clue_id)
		if is_first:
			Ui.show_dialogue(["（线索已记入笔记。按 Tab 可随时查看。）"])
