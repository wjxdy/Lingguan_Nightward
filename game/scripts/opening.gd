extends Control
## 开场字卡：黑屏逐张显示旁白，按 E/空格推进。播完进村庄。文案：docs/07「开场字卡」。

const CARDS := [
	"一九九五年，六月初六。",
	"我叫名瞳，名花流村人。\n那一天，我跟着师傅的送葬队上山。",
	"师傅死得蹊跷。寿衣的针脚里，缝着我看不懂的符。",
	"我没能走下那座山。\n他们把我钉进了我爹的棺材，埋进了棺材地。",
	"棺材里有一本书。书上的字，是金色的。\n四年，我读完了它。",
	"第四年的雨夜，我引下了那道雷。",
	"轰——",
	"公元两千年。我回来了。",
]

@onready var label: Label = $Center/CardLabel

var _index := -1
var _tween: Tween

func _ready() -> void:
	GameState.reset()
	_next_card()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		if _tween and _tween.is_running():
			_tween.kill()
			label.modulate.a = 1.0
		else:
			_next_card()

func _next_card() -> void:
	_index += 1
	if _index >= CARDS.size():
		Router.change_scene("res://scenes/village.tscn", "wake_up")
		return
	label.text = CARDS[_index]
	label.modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_property(label, "modulate:a", 1.0, 1.2)
