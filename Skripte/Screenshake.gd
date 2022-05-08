extends Camera2D

func _move_camera(vector):
	offset = Vector2(rand_range(-vector.x, vector. x), rand_range(-vector.y, vector.y))

func _screen_shake(shake_length, shake_power):
	$Tween.interpolate_method(self, "_move_camera", Vector2(shake_power, shake_power), Vector2(0, 0), shake_length, Tween.TRANS_SINE, Tween.EASE_OUT, 0)
	$Tween.start()
