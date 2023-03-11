extends Node

enum SFX{ SHOVE, GRACE, START_DANCE, PILFER }
var _sfx = [preload("res://resources/step.wav"), \
	preload("res://resources/grace.wav"), \
	preload("res://resources/start_dance.wav"),\
	preload("res://resources/pilfer.wav")]

var music = []

var played_songs = []

onready var music_player = $MusicPlayer

const fade_time: float = 7.0
var fading = false
var time_accum = 0.0
const fade_term: float = 80.0/fade_time

func play(sfx: int):
	if sfx < 0 || sfx > _sfx.size(): return
	for c in get_children():
		var a: AudioStreamPlayer = c
		if a.playing: continue
		else:
			a.stream = _sfx[sfx]
			a.play()
			return

func start_song():
	if !music.empty():
		var song = music[randi() % music.size()]
		music_player.stream = song
		music_player.play()
		played_songs.append(song)
		music.erase(song)
	else:
		for i in range(played_songs.size()):
			music.append(played_songs.pop_back())

func end_song():
	fading = true

func _process(delta: float) -> void:
	if fading:
		time_accum += delta
		if time_accum > fade_time:
			time_accum = 0.0
			fading = false
			music_player.stop()
		else:
			music_player.volume_db -= fade_term * delta

func _ready():
	var dir = Directory.new()
	if dir.open("res://resources/music") == OK:
		dir.list_dir_begin()
		var filename = dir.get_next()
		var song
		while filename != "":
			if filename.ends_with(".mp3"):
				song = load("res://resources/music/{0}".format([filename]))
				music.append(song)
			filename = dir.get_next()
