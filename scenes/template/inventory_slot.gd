extends Control

#enum InventoryType {
	#COIN,
	#MUSHROOM
#}

enum AmountStatus {
	SAME,
	UP,
	DOWN
}

@export_category("Slot UI")
#@export var type: InventoryType
@export var icon: Texture2D
@export var hot_list_number: int = -1

var fx_timer: Timer
var amount: int

func _ready() -> void:
	$TextureRect/HBoxContainer/Amount.set_text("")
	$TextureRect/HBoxContainer/Icon.set_texture(icon)
	if hot_list_number >= 1:
		$HotListNumber.set_text(str(hot_list_number))
	amount = 0


func set_icon(_texture: Texture2D) -> void:
	icon = _texture
	$TextureRect/HBoxContainer/Icon.set_texture(icon)


func set_amount(_amount: int) -> void:
	var status: AmountStatus = AmountStatus.SAME
	if _amount > amount:
		status = AmountStatus.UP
	elif _amount < amount:
		status = AmountStatus.DOWN
	amount = _amount
	update_amount(status)


func add(_amount: int) -> void:
	amount += _amount
	var status = AmountStatus.UP
	if _amount == 0:
		status = AmountStatus.SAME
	update_amount(status)


func remove(_amount: int) -> void:
	amount -= _amount
	var status = AmountStatus.DOWN
	if _amount == 0:
		status = AmountStatus.SAME
	update_amount(status)


func update_amount(status: AmountStatus) -> void:
	if amount == 0:
		$TextureRect/HBoxContainer/Amount.set_text("")
	else:
		$TextureRect/HBoxContainer/Amount.set_text(str(amount))
		match status:
			AmountStatus.UP:
				$TextureRect/HBoxContainer/Amount.set("theme_override_colors/font_color", Color("80ff00"))
				$TextureRect/HBoxContainer/Amount.set("theme_override_font_sizes/font_size", 60)
				start_fx_timer()
			AmountStatus.DOWN:
				$TextureRect/HBoxContainer/Amount.set("theme_override_colors/font_color", Color.RED)
				$TextureRect/HBoxContainer/Amount.set("theme_override_font_sizes/font_size", 60)
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
		$TextureRect/HBoxContainer/Amount.set("theme_override_font_sizes/font_size", 32)
		$TextureRect/HBoxContainer/Amount.set("theme_override_colors/font_color", Color.WHITE)
