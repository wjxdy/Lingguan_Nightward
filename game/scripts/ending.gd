extends Control
## 结束字卡。最后一张按 E 回到开场（状态由开场负责重置）。文案：docs/07「结束字卡」。

const CARDS := [
	"封门村的夜，才刚刚开始。",
	"《灵棺夜行 · 第一夜》\n\n—— 完 ——",
	"改编自小说《灵棺夜行》\n\n按 E 重新开始",
]

@onready var label: Label = $Center/CardLabel

var _index := -1
var _tween: Tween

func _ready() -> void:
	_next_card()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		if _tween and _tween.is_running():
			_tween.kill()
			label.modulate.a = 1.0
		elif _index >= CARDS.size() - 1:
			Router.change_scene("res://scenes/opening.tscn")
		else:
			_next_card()

func _next_card() -> void:
	_index += 1
	label.text = CARDS[_index]
	label.modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_property(label, "modulate:a", 1.0, 1.2)
