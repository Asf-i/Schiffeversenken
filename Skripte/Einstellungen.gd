extends Button

var min_swipe_distanz : int = 100
var swipe_verlangsamung : int = 240

var richtunganders : int = 1
var sonst_okay : bool = true
var swipe_event_relative

func _ready():
	$Rotieren.pressed = Autoload.savegame_data.rotier_mode
	$AudioButton.pressed = Autoload.savegame_data.sound_an
	$Vibration.pressed = Autoload.savegame_data.vibration
	$ScreenshakeSlider.value = Autoload.savegame_data.screenshake_value
	$MusicSlider.value = Autoload.savegame_data.musiklautstaerke
	#VerschiebungSlider wird in Start.gd gesetzt
	richtunganders = 1

func _on_SwipeDetector_swipe(local_swipe, event_relative, start):
	visible = true
	swipe_event_relative = event_relative
	if abs(get_parent().get_node("SwipeDetector").start_direction.y) > abs(get_parent().get_node("SwipeDetector").start_direction.x) && (get_parent().get_node("SwipeDetector").start_direction.y * richtunganders < 0 && not get_parent().get_node("SettingWegButton").visible or get_parent().get_node("SwipeDetector").start_direction.y * richtunganders > 0 && get_parent().get_node("SettingWegButton").visible) && get_parent().get_node_or_null("OnlineListe") == null && sonst_okay && start.y < Autoload.actual_screen_height - 100:
		rect_position.y += event_relative.y * richtunganders / (0.5 * abs(local_swipe.y) / swipe_verlangsamung + 1)
	if rect_position.y < Autoload.actual_screen_height - rect_size.y:
		rect_position.y = Autoload.actual_screen_height - rect_size.y
	elif rect_position.y > Autoload.actual_screen_height:
		rect_position.y = Autoload.actual_screen_height + 1

# warning-ignore:unused_argument
# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_SwipeDetector_swipe_done(start, end, local_swipe):
	var start_direction = get_parent().get_node("SwipeDetector").start_direction.y
	if abs(start_direction) > abs(get_parent().get_node("SwipeDetector").start_direction.x) && get_parent().get_node_or_null("OnlineListe") == null && sonst_okay && swipe_event_relative.y * (start_direction / abs(start_direction)) > 0 && start.y < Autoload.actual_screen_height - 100:
		if get_parent().get_node("SwipeDetector").start_direction.y * richtunganders < 0 && not get_parent().get_node("SettingWegButton").visible:
			get_parent().get_node("SettingWegButton").visible = true
			$Tween.interpolate_property(self, "rect_position:y", rect_position.y, Autoload.actual_screen_height - rect_size.y, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.start()
		elif get_parent().get_node("SwipeDetector").start_direction.y * richtunganders > 0 &&  get_parent().get_node("SettingWegButton").visible:
			get_parent().get_node("SettingWegButton").visible = false
			$Tween.interpolate_property(self, "rect_position:y", rect_position.y, Autoload.actual_screen_height + 1, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.start()
			yield($Tween, "tween_all_completed")
			visible = false
			Autoload.save()
	elif not get_parent().get_node("SettingWegButton").visible:
		$Tween.interpolate_property(self, "rect_position:y", rect_position.y, Autoload.actual_screen_height + 1, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()
		yield($Tween, "tween_all_completed")
		visible = false
	else:
		$Tween.interpolate_property(self, "rect_position:y", rect_position.y, Autoload.actual_screen_height - rect_size.y, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		$Tween.start()

func _on_SettingWegButton_pressed():
	get_parent().get_node("SettingWegButton").visible = false
	$Tween.interpolate_property(self, "rect_position:y", Autoload.actual_screen_height - rect_size.y, Autoload.actual_screen_height + 1, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	visible = false
	Autoload.save()

func on_off_switch(button, pressed):
	if pressed:
#		button.get_node("OnOff").frame = 1
		button.get_node("OnOff").rotation_degrees = 0
	else:
#		button.get_node("OnOff").frame = 0
		button.get_node("OnOff").rotation_degrees = 180

func _on_CheckButton_toggled(button_pressed):
	Autoload.savegame_data.rotier_mode = button_pressed
	Autoload.save()
	on_off_switch($Rotieren, button_pressed)

func _on_AudioButton_toggled(button_pressed):
	Autoload.savegame_data.sound_an = button_pressed
	Autoload.save()
	on_off_switch($AudioButton, button_pressed)
	AudioServer.set_bus_mute(2, not button_pressed)

func _on_Vibration_toggled(button_pressed):
	Autoload.savegame_data.vibration = button_pressed
	Autoload.save()
	on_off_switch($Vibration, button_pressed)

func _on_ScreenshakeSlider_value_changed(value):
	Autoload.savegame_data.screenshake_value = value

func _on_VerschiebungSlider_value_changed(value):
	print("VALUE CHANGED LUL")
	Autoload.savegame_data.verschiebung = value
	if get_parent().name == "Start":
		get_parent().get_node("VersionsLabel").rect_position.y = Autoload.actual_screen_height - 1920 + Autoload.default_versch_values[0] - Autoload.savegame_data.verschiebung
		for i in range(1, 6):
			get_parent().get_node(Autoload.versch_namen[i]).rect_position.y = Autoload.default_versch_values[i] + Autoload.savegame_data.verschiebung

func _on_MusicSlider_value_changed(value):
	Autoload.savegame_data.musiklautstaerke = value
	if value == 0:
		AudioServer.set_bus_volume_db(1, -80)
	else:
		AudioServer.set_bus_volume_db(1, value - 40)
