extends ColorRect

var start : bool = true
var sp2_dran : bool = true

signal start_done()
signal end_done(s2dran)

func _ready():
	$TransitionPlayer.play("Black")

func black(spieler2_ist_dran : bool = true): #spieler2_ist_dran für online
	sp2_dran = spieler2_ist_dran
	$TransitionPlayer.play_backwards("Black")
	visible = true

func black_reverse():
	start = true
	$TransitionPlayer.play("Black")

func _on_TransitionPlayer_animation_finished(_anim_name):
	if start:
		visible = false
		emit_signal("start_done")
		start = false
	else:
		emit_signal("end_done", sp2_dran)
