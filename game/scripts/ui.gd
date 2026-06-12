extends CanvasLayer
## 全局 UI：对话框（打字机效果）、交互提示、线索笔记。autoload 场景，名为 Ui。

signal dialogue_finished

const CHARS_PER_SEC := 25.0

@onready var prompt: Label = $Prompt
@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var dialogue_label: Label = $DialoguePanel/Margin/DialogueLabel
@onready var journal_panel: PanelContainer = $JournalPanel
@onready var journal_entries: VBoxContainer = $JournalPanel/JMargin/JList/JEntries

var _lines: Array = []
var _line_index := 0
var _typing := false
var _tween: Tween

func _ready() -> void:
	prompt.hide()
	dialogue_panel.hide()
	journal_panel.hide()

func is_dialogue_open() -> bool:
	return dialogue_panel.visible

## 显示一段旁白/对话。lines 为字符串数组，按 E/空格逐条推进。
func show_dialogue(lines: Array) -> void:
	if lines.is_empty() or is_dialogue_open():
		return
	_lines = lines
	_line_index = 0
	prompt.hide()
	dialogue_panel.show()
	_show_current_line()

func show_prompt(text: String) -> void:
	if is_dialogue_open():
		return
	prompt.text = text
	prompt.show()

func hide_prompt() -> void:
	prompt.hide()

func _show_current_line() -> void:
	var text: String = str(_lines[_line_index])
	dialogue_label.text = text
	dialogue_label.visible_characters = 0
	_typing = true
	_tween = create_tween()
	_tween.tween_property(dialogue_label, "visible_characters", text.length(),
			text.length() / CHARS_PER_SEC)
	_tween.finished.connect(func() -> void: _typing = false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("journal") and not is_dialogue_open():
		_toggle_journal()
		get_viewport().set_input_as_handled()
		return
	if not is_dialogue_open():
		return
	if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		if _typing:
			if _tween:
				_tween.kill()
			dialogue_label.visible_characters = -1
			_typing = false
		elif _line_index < _lines.size() - 1:
			_line_index += 1
			_show_current_line()
		else:
			dialogue_panel.hide()
			dialogue_finished.emit()

func _toggle_journal() -> void:
	if journal_panel.visible:
		journal_panel.hide()
		return
	for child in journal_entries.get_children():
		child.queue_free()
	if GameState.clues.is_empty():
		var empty := Label.new()
		empty.text = "（还没有发现任何线索）"
		journal_entries.add_child(empty)
	for clue_id in GameState.clues:
		var entry := Label.new()
		entry.text = "· " + str(GameState.CLUE_TEXTS.get(clue_id, clue_id))
		entry.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		entry.custom_minimum_size = Vector2(440, 0)
		journal_entries.add_child(entry)
	journal_panel.show()
