extends Button

var _o = Vector2()

var _d = false

var _t = 0

func is_dragging():
	return self._d

func _process(delta):
	if _d:
		var mpos = get_viewport().get_mouse_pos()
		var node = self if !get_owner() else get_owner()
		node.set_pos( mpos - self._o )
	else:
		if _t >= 10:
			self._o = get_local_mouse_pos()
			self._d = true
		else:
			_t += 1

	print(_t)

func _ready():
	connect("button_down", self, "_on_button_down")
	connect("button_up", self, "_on_button_up")


func _on_button_down():
	set_process(true)
	



func _on_button_up():
	_t = 0
	_d = false
	set_process(false)





