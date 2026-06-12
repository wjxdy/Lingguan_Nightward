extends Node
## 全局游戏状态：剧情阶段、线索、flag。autoload 单例，名为 GameState。

signal clue_added(clue_id: String)
signal phase_changed(new_phase: Phase)

enum Phase { DAY, NIGHT, ENDING }

const TOTAL_CLUES := 5

## 线索 id → 笔记界面显示文本（文案来源：docs/07-剧情文案.md）
const CLUE_TEXTS := {
	"home_letter": "家里的饭桌还摆着没动过的饭菜，爹娘留下一封没写完的信。",
	"chen_shroud": "师傅家那件寿衣的针脚里缝着符纸——师傅的死不是意外。",
	"zhang_wedding": "张老汉家供着一张阴婚帖，落款日期，是我下葬那天。",
	"yizhuang_coffin": "义庄的棺材全空了，镇尸符早已过期发黑。",
	"citang_roster": "祠堂的全村名册上，三百多个名字被红笔一个个圈掉。",
}

var phase: Phase = Phase.DAY
var clues: Array[String] = []
var flags: Dictionary = {}

func add_clue(clue_id: String) -> void:
	if clue_id in clues:
		return
	clues.append(clue_id)
	clue_added.emit(clue_id)
	if clues.size() >= TOTAL_CLUES and phase == Phase.DAY:
		set_phase(Phase.NIGHT)

func set_phase(p: Phase) -> void:
	phase = p
	phase_changed.emit(p)

func set_flag(key: String) -> void:
	flags[key] = true

func has_flag(key: String) -> bool:
	return flags.get(key, false)

## 通关重开时重置全部状态
func reset() -> void:
	phase = Phase.DAY
	clues.clear()
	flags.clear()
