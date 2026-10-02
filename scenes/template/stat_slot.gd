extends Control

enum StatsType {
	HP,
	ATT,
	DEF,
	SPD,
	EVA,
	ACC,
	RES,
	CC
}

@export_category("Slot UI")
@export var type: StatsType
@export var icon: Texture2D
var fx_timer: Timer
@export var amount: int = 0

func _ready() -> void:
	$HBoxContainer/Amount.set_text("00")
	$HBoxContainer/Icon.set_texture(icon)


func add(_amount: int) -> void:
	amount += _amount
	update_amount(true)


func set_amount(_amount: int) -> void:
	amount = _amount
	update_amount(true)


func remove(_amount: int) -> void:
	amount -= _amount
	update_amount(false)


func update_amount(up: bool) -> void:
	$HBoxContainer/Amount.set_text(str(amount))
	$HBoxContainer/Amount.set("theme_override_font_sizes/font_size", 60)
	if up:
		$HBoxContainer/Amount.set("theme_override_colors/font_color", Color("80ff00"))
	else:
		$HBoxContainer/Amount.set("theme_override_colors/font_color", Color.RED)
	start_fx_timer()


func start_fx_timer() -> void:
	if fx_timer == null:
		fx_timer = Timer.new()
		add_child(fx_timer)
		fx_timer.wait_time = 2
		fx_timer.timeout.connect(fx_timeout)
		fx_timer.start()


func fx_timeout() -> void:
	if fx_timer != null:
		fx_timer.stop()
		fx_timer.queue_free()
		$HBoxContainer/Amount.set("theme_override_font_sizes/font_size", 32)
		$HBoxContainer/Amount.set("theme_override_colors/font_color", Color.WHITE)
