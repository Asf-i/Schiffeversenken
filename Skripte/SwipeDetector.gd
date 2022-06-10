extends Node

signal swipe(local_swipe, event_relative, staart)
signal swipe_done(start, end, local_swipe)

var start_pos = Vector2()
var end_pos = Vector2()
var swipe_vector = Vector2()
var start_direction = Vector2()

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			start_pos = event.position
			swipe_vector = Vector2(0, 0)
			start_direction = Vector2(0, 0)
		else:
			end_pos = event.position
			emit_signal("swipe_done", start_pos, end_pos, swipe_vector)
	
	if event is InputEventScreenDrag:
		swipe_vector += event.relative
		if swipe_vector.length() > 20:
			emit_signal("swipe", swipe_vector, event.relative, start_pos)
			if start_direction == Vector2(0, 0):
				start_direction = swipe_vector.normalized()
