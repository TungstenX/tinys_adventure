extends Node2D

var dir: float
var hit: bool
var fx_timer: Timer

func _ready() -> void:
	if hit:
		get_node("Sprite2D").frame = 1
	else:
		get_node("Sprite2D").frame = 0
	
	get_node(".").rotation = dir
	fx_timer = Timer.new()
	add_child(fx_timer)
	fx_timer.wait_time = 3
	fx_timer.timeout.connect(fx_timeout)
	fx_timer.start()


func fx_timeout() -> void:
	if fx_timer != null:
		fx_timer.stop()
	queue_free()
