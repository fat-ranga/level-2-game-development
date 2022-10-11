extends Item

signal play_punch_animation

var is_hitting = false
var hit_rate = 5

func fire():
	is_hitting = true
	#emit_signal("play_punch_animation")

func fire_stop():
	is_hitting = false

func reload():
	pass
