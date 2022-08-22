extends Node2D

var nur_schoen : bool = false

var ziel = Vector2()
var rotierziel = Vector2()
var rotierstart = Vector2()
var prozesszahl : float = 1.0
var check_schiffli_name
var feld

func _process(_delta):
	look_at(ziel)

func fliegen(start):
	$Swoosh.pitch_scale = rand_range(0.9, 1.15)
	$Swoosh.play()
	
	rotierstart = start
	rotierziel = ziel
	if $"/root/Welt".rect_rotation == 180:
		rotierstart.y = Autoload.actual_screen_height - start.y
		rotierziel.x = 1080 - ziel.x + $"/root/Welt/Felder/1_1".rect_size.x
		rotierziel.y = Autoload.actual_screen_height - ziel.y + $"/root/Welt/Felder/1_1".rect_size.y
		ziel = ziel - $"/root/Welt/Felder/1_1".rect_size
	
	$Tween.interpolate_property(self, "position", rotierstart, rotierziel, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _on_Tween_tween_all_completed():
	if not nur_schoen:
		feld.machen()
	queue_free()
