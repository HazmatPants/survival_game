extends Node

var time: float = randf_range(30000, 50000)
var elapsed_time: float = 0.0
var time_scale: float = 10.0
var days: int = 0

signal Tick

func _process(delta: float) -> void:
	time += delta * time_scale
	elapsed_time += delta * time_scale
	if time >= 86400:
		time = 0.0
		days += 1

	if fmod(time, 60) < 0.1:
		Tick.emit()

	var wenv: Environment = get_tree().current_scene.get_node_and_resource("WorldEnvironment:environment")[1]

	if not wenv: return

	var sky_color = get_sky_color(int(time))

	wenv.set("background_color", sky_color)

func get_time_string() -> String:
	var period = "AM"

	var seconds = int(time) % 86400

	var _days = seconds / 86400.0
	seconds %= 86400
	
	var hours = seconds / 3600.0
	seconds %= 3600
	
	var minutes = seconds / 60.0
	seconds %= 60

	if hours >= 12:
		period = "PM"

	hours = fmod(hours, 13)
	if hours == 0:
		hours = 12

	return "%02d:%02d:%02d %s" % [hours, minutes, seconds, period]

func get_time_alive_string() -> String:
	return format_duration(int(elapsed_time))

func get_sky_color(secs: int) -> Color:
	var seconds = secs

	seconds %= 60

	var night := Color(0.05, 0.05, 0.05)
	var day := Color(0.4, 0.65, 1.0) # nice sky blue

	var sunrise_start := 5.5 * 3600
	var sunrise_end := 6 * 3600
	var sunset_start := 18 * 3600
	var sunset_end := 18.5 * 3600

	# Night (before sunrise)
	if seconds < sunrise_start:
		return night

	# Sunrise
	elif seconds < sunrise_end:
		var t := float(secs - sunrise_start) / float(sunrise_end - sunrise_start)
		return night.lerp(day, t)

	# Day
	elif seconds < sunset_start:
		return day

	# Sunset
	elif seconds < sunset_end:
		var t := float(seconds - sunset_start) / float(sunset_end - sunset_start)
		return day.lerp(night, t)

	# Night (after sunset)
	else:
		return night

func format_duration(total_seconds: int) -> String:
	var seconds = total_seconds
	
	var _days = seconds / 86400.0
	seconds %= 86400
	
	var hours = seconds / 3600.0
	seconds %= 3600
	
	var minutes = seconds / 60.0
	seconds %= 60

	_days = int(_days)
	hours = int(hours)
	minutes = int(minutes)

	var parts := []
	
	if days > 0:
		parts.append("%d day%s" % [days, "" if days == 1 else "s"])
	if hours > 0:
		parts.append("%d hour%s" % [hours, "" if hours == 1 else "s"])
	if minutes > 0:
		parts.append("%d minute%s" % [minutes, "" if minutes == 1 else "s"])
	if seconds > 0 or parts.is_empty():
		parts.append("%d second%s" % [seconds, "" if seconds == 1 else "s"])
	
	return ", ".join(parts)
