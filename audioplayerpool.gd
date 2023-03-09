extends Node

enum SFX{ SHOVE, GRACE, START_DANCE }
var _sfx = [preload("res://resources/step.wav"), preload("res://resources/grace.wav"), preload("res://resources/start_dance.wav")] 

func play(sfx: int):
	if sfx < 0 || sfx > _sfx.size(): return
	for c in get_children():
		var a: AudioStreamPlayer = c
		if a.playing: continue
		else:
			a.stream = _sfx[sfx]
			a.play()
			return
