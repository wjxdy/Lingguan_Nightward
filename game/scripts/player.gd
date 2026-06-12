extends CharacterBody2D
## 玩家：四方向移动 + 调查交互（交互对象为 group "interactable" 中最近的 Area2D）。

const SPEED := 110.0

var can_move := true

var _nearby: Array[Area2D] = []

@onready var interact_area: Area2D = $InteractArea

func _ready() -> void:
	add_to_group("player")
	interact_area.area_entered.connect(_on_area_entered)
	interact_area.area_exited.connect(_on_area_exited)

func _physics_process(_delta: float) -> void:
	if not can_move or Ui.is_dialogue_open():
		velocity = Vector2.ZERO
	else:
		velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * SPEED
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if not can_move or Ui.is_dialogue_open() or _nearby.is_empty():
		return
	var target := _nearest()
	if target != null and target.has_method("interact"):
		target.interact()

func _nearest() -> Area2D:
	var best: Area2D = null
	var best_d := INF
	for a in _nearby:
		var d := global_position.distance_squared_to(a.global_position)
		if d < best_d:
			best_d = d
			best = a
	return best

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactable"):
		_nearby.append(area)
		Ui.show_prompt("E 调查")

func _on_area_exited(area: Area2D) -> void:
	_nearby.erase(area)
	if _nearby.is_empty():
		Ui.hide_prompt()
