extends Node
## 无头冒烟测试：加载所有场景、模拟输入走核心流程，全部通过则退出码 0。
## 运行：godot --headless --path game res://tests/smoke_test.tscn

var failures: Array[String] = []

func _ready() -> void:
	get_tree().create_timer(40.0).timeout.connect(func() -> void:
		printerr("SMOKE TEST: TIMEOUT")
		get_tree().quit(2))
	await get_tree().process_frame
	await _run()

func check(cond: bool, what: String) -> void:
	if cond:
		print("PASS: ", what)
	else:
		failures.append(what)
		printerr("FAIL: ", what)

func _press_interact() -> void:
	var ev := InputEventAction.new()
	ev.action = "interact"
	ev.pressed = true
	Input.parse_input_event(ev)
	var ev2 := InputEventAction.new()
	ev2.action = "interact"
	ev2.pressed = false
	Input.parse_input_event(ev2)

func _advance_dialogue_until_closed(max_presses: int = 40) -> void:
	var n := 0
	while Ui.is_dialogue_open() and n < max_presses:
		n += 1
		_press_interact()
		await get_tree().process_frame
		await get_tree().process_frame

func _run() -> void:
	var interior_paths := [
		"res://scenes/interiors/home.tscn", "res://scenes/interiors/chen_home.tscn",
		"res://scenes/interiors/zhang_home.tscn", "res://scenes/interiors/yizhuang.tscn",
		"res://scenes/interiors/citang.tscn",
	]
	var all_paths := [
		"res://scenes/opening.tscn", "res://scenes/ending.tscn",
		"res://scenes/village.tscn", "res://scenes/player.tscn",
	] + interior_paths

	# 1. 所有场景可加载
	for p in all_paths:
		check(load(p) != null, "load " + p)

	# 2. GameState：5 线索触发夜晚、去重、重置
	GameState.reset()
	for id in GameState.CLUE_TEXTS.keys():
		GameState.add_clue(id)
	check(GameState.phase == GameState.Phase.NIGHT, "5 clues trigger NIGHT")
	check(GameState.clues.size() == 5, "clue count is 5")
	GameState.add_clue("home_letter")
	check(GameState.clues.size() == 5, "no duplicate clue")
	GameState.reset()
	check(GameState.phase == GameState.Phase.DAY and GameState.clues.is_empty(), "reset clears state")

	# 3. 村庄实例化 + 出生点 + 模拟移动
	GameState.set_flag("intro_done")
	Router.spawn_name = "default"
	var village: Node2D = (load("res://scenes/village.tscn") as PackedScene).instantiate()
	add_child(village)
	await get_tree().physics_frame
	var player: CharacterBody2D = village.get_node("Player")
	check(absf(player.global_position.x - 640.0) < 2.0 and absf(player.global_position.y - 750.0) < 2.0,
			"player spawns at default point")
	var y0: float = player.global_position.y
	Input.action_press("move_down")
	for i in 30:
		await get_tree().physics_frame
	Input.action_release("move_down")
	check(player.global_position.y > y0 + 10.0, "player moves with input")

	# 4. 调查物：对话打开/推进/关闭
	var sign_node: Area2D = village.get_node("Interactables/VillageSign")
	check(sign_node.is_in_group("interactable"), "sign is interactable")
	sign_node.interact()
	await get_tree().process_frame
	check(Ui.is_dialogue_open(), "dialogue opens on interact")
	await _advance_dialogue_until_closed()
	check(not Ui.is_dialogue_open(), "dialogue closes after advancing")

	# 5. 线索物：对话结束后登记线索
	GameState.reset()
	var home: Node2D = (load("res://scenes/interiors/home.tscn") as PackedScene).instantiate()
	add_child(home)
	await get_tree().physics_frame
	home.get_node("ClueObject").interact()
	await get_tree().process_frame
	await _advance_dialogue_until_closed()
	check("home_letter" in GameState.clues, "clue registered after dialogue")
	home.queue_free()

	# 6. 配置校验：门目标存在、出生点齐全、线索 id 合法
	var v_spawns: Node2D = village.get_node("SpawnPoints")
	for d in village.get_node("Doors").get_children():
		check(ResourceLoader.exists(d.target_scene), "door target exists: " + d.name)
	for p in interior_paths:
		var inst: Node2D = (load(p) as PackedScene).instantiate()
		var exit_door: Area2D = inst.get_node("ExitDoor")
		check(v_spawns.has_node(exit_door.spawn), "village has spawn: " + str(exit_door.spawn))
		var co: Area2D = inst.get_node_or_null("ClueObject")
		check(co != null and GameState.CLUE_TEXTS.has(co.clue_id), "clue id valid in " + p)
		inst.free()

	# 7. 瞎子：白天隐藏、夜晚可见
	GameState.reset()
	var citang_day: Node2D = (load("res://scenes/interiors/citang.tscn") as PackedScene).instantiate()
	add_child(citang_day)
	await get_tree().process_frame
	check(not citang_day.get_node("XiaZi").visible, "xiazi hidden at day")
	citang_day.queue_free()
	GameState.set_phase(GameState.Phase.NIGHT)
	var citang_night: Node2D = (load("res://scenes/interiors/citang.tscn") as PackedScene).instantiate()
	add_child(citang_night)
	await get_tree().process_frame
	check(citang_night.get_node("XiaZi").visible, "xiazi visible at night")
	citang_night.queue_free()

	# 8. 夜幕过场：锁操作 → 旁白 → 白影出现 → 解锁
	GameState.reset()
	GameState.set_flag("intro_done")
	for id in GameState.CLUE_TEXTS.keys():
		GameState.add_clue(id)
	village.queue_free()
	await get_tree().process_frame
	var village2: Node2D = (load("res://scenes/village.tscn") as PackedScene).instantiate()
	add_child(village2)
	await get_tree().process_frame
	var p2: CharacterBody2D = village2.get_node("Player")
	check(p2.can_move == false, "night cutscene locks player")
	var waited := 0.0
	while not Ui.is_dialogue_open() and waited < 6.0:
		await get_tree().create_timer(0.2).timeout
		waited += 0.2
	check(Ui.is_dialogue_open(), "night narration appears")
	await _advance_dialogue_until_closed()
	await get_tree().process_frame
	check(village2.get_node("NightGhost").visible, "night ghost appears")
	check(p2.can_move, "player unlocked after cutscene")

	# 汇总
	if failures.is_empty():
		print("SMOKE TEST: ALL PASS")
		get_tree().quit(0)
	else:
		printerr("SMOKE TEST: %d FAILURE(S)" % failures.size())
		get_tree().quit(1)
