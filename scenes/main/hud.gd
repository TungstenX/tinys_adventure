extends Control

var fx_f_keys_timer: Timer
var fx_level_timer: Timer
var cursor_arrow = load("res://assets/ui/pointers/01.png")
var declutter: bool = false


func _ready() -> void:
	Input.set_custom_mouse_cursor(cursor_arrow)
	print("Viewport size: ", get_viewport().size)
	get_viewport().connect("size_changed", _on_viewport_resize)
	_on_viewport_resize()
	update_level_indicator()
	start_fx_f_keys_timer()
	update_stats()


func _on_viewport_resize() -> void:
	var factor_1 = 1.0
	var factor_2 = 1.0
	if not declutter:
		factor_1 = 0.75
		factor_2 = 0.5
	get_node("InventoryPanel").position.x = (get_viewport().size.x * factor_1) - (get_node("InventoryPanel").size.x * factor_2)
	get_node("InventoryPanel").size.y = get_viewport().size.y / 2.0 - (get_node("InventoryPanel").size.x) # 50%
	get_node("InventoryPanel").position.y = get_viewport().size.y / 4.0 + (get_node("InventoryPanel").size.x / 2.0)# 25%
	get_node("Inventory").position = get_node("InventoryPanel").position
	get_node("Inventory").size.y = get_node("InventoryPanel").size.y 
	
	
	get_node("StatsPanel").position.y = (get_viewport().size.y * factor_1) - (get_node("StatsPanel").size.y * factor_2)
	get_node("StatsPanel").size.x = get_viewport().size.x / 2.0 - (get_node("StatsPanel").size.y) # 50%
	get_node("StatsPanel").position.x = get_viewport().size.x / 4.0 + (get_node("StatsPanel").size.y / 2.0)# 25%
	get_node("Stats").position = get_node("StatsPanel").position
	get_node("Stats").size.x = get_node("StatsPanel").size.x
	
	get_node("HirePanel").position.x = (get_viewport().size.x * (1 - factor_1)) - (get_node("HirePanel").size.x * (1 - factor_2))
	get_node("HirePanel").size.y = get_viewport().size.y / 2.0 - (get_node("HirePanel").size.x) # 50%
	get_node("HirePanel").position.y = get_viewport().size.y / 4.0 + (get_node("HirePanel").size.x / 2.0)# 25%
	get_node("Hire").position = get_node("HirePanel").position
	get_node("Hire").size.y = get_node("HirePanel").size.y 
	#print("Viewport size: ", get_viewport().size)
	
	get_node("DevilResponse").position.y = get_viewport().size.y - get_node("DevilResponse").size.y
	



func  set_declutter(_declutter: bool) -> void:
	declutter = _declutter
	_on_viewport_resize()

func start_fx_level_timer() -> void:
	if fx_level_timer == null:
		%CurrentLevel.set("theme_override_font_sizes/font_size", 120)
		%CurrentLevel.set("theme_override_colors/font_color",Color("80ff00"))
		fx_level_timer = Timer.new()
		add_child(fx_level_timer)
		fx_level_timer.wait_time = 1
		fx_level_timer.timeout.connect(fx_level_timeout)
		fx_level_timer.start()


func start_fx_f_keys_timer() -> void:
	if fx_f_keys_timer == null:
		fx_f_keys_timer = Timer.new()
		add_child(fx_f_keys_timer)
		#fx_f_keys_timer.autostart = true
		fx_f_keys_timer.wait_time = 3
		fx_f_keys_timer.timeout.connect(fx_f_keys_timeout)
		fx_f_keys_timer.start()


func fx_f_keys_timeout() -> void:
	if fx_f_keys_timer != null:
		fx_f_keys_timer.stop()
		fx_f_keys_timer.queue_free()
		if get_node("FKeys").is_visible():
			get_node("FKeys").set_visible(false)


func fx_level_timeout() -> void:
	if fx_level_timer != null:
		fx_level_timer.stop()
		fx_level_timer.queue_free()
		%CurrentLevel.set("theme_override_font_sizes/font_size", 60)
		%CurrentLevel.set("theme_override_colors/font_color", Color.WHITE)


func update_hp_bar(new_value: int) -> void:
	%HitpointsBar.value = new_value
	if %HitpointsBar.value <= 25:
		%HitpointsBar.set("tint_progress", Color("970000ff"))
	elif %HitpointsBar.value <= 50:
		%HitpointsBar.set("tint_progress", Color("ff8000"))
	else:
		%HitpointsBar.set("tint_progress", Color("80ff00"))


func update_level_indicator() -> void:
	if %CurrentLevel.get_text() != str(PlayerData.get_player_level()):
		start_fx_level_timer()
	%CurrentLevel.set_text(str(PlayerData.get_player_level()))


func _on_container_mouse_entered() -> void:
	get_node("FKeys").set_visible(true)


func _on_container_mouse_exited() -> void:
	get_node("FKeys").set_visible(false)


func add_selected_npc(which: Node2D, face_icon: Texture2D) -> void:	
	var scene: PackedScene = load("res://scenes/template/hire_slot.tscn")
	var scene_instance = scene.instantiate()
	scene_instance.set_avatar(face_icon)
	scene_instance.npc = which
	get_node("Hire").add_child(scene_instance)
	if get_node("Hire").get_child_count() == 1:
		scene_instance.set_selected(true)


func get_selected_npc() -> Variant:
	for i in get_node("Hire").get_children():
		if i.is_selected():
			return i.npc
	return null


func update_stats() -> void:
	for stat in get_node("Stats").get_children():
		var stat_name = stat.get_name()
		var amount = PlayerData.get_derived_stat(stat_name.to_lower())
		stat.set_amount(amount)
