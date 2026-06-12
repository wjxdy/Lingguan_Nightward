extends Area2D
## 瞎子：夜晚出现在祠堂。对话结束后进入结局字卡。文案：docs/07「结局·瞎子」。

const LINES := [
	"瞎子：「回来了？」",
	"他坐在名册前，空洞的眼窝正对着我，像是早就等在这里。",
	"瞎子：「四年了。书，读完了吧。」",
	"我有一万句话想问。爹娘在哪，全村人去了哪，谁害的师傅——",
	"瞎子：「都会有答案。但你先得弄明白一件事。」",
	"瞎子：「你从那口棺材里爬出来的时候——」",
	"瞎子：「就已经不算活人了。」",
]

func _ready() -> void:
	add_to_group("interactable")
	var is_night: bool = GameState.phase == GameState.Phase.NIGHT
	visible = is_night
	monitorable = is_night

func interact() -> void:
	Ui.show_dialogue(LINES)
	await Ui.dialogue_finished
	GameState.set_phase(GameState.Phase.ENDING)
	Router.change_scene("res://scenes/ending.tscn")
