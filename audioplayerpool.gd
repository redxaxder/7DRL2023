extends Node

enum SFX{ SHOVE, GRACE, START_DANCE, PILFER, CHANGE_FACTION }
var _sfx = [preload("res://resources/step.wav"), \
	preload("res://resources/grace.wav"), \
	preload("res://resources/start_dance.wav"),\
	preload("res://resources/pilfer.wav"),\
	preload("res://resources/flip.wav")\
	]

var music = [\
preload("res://resources/music/010136ORIGINALTAENZEWaltzesOp9D365.mp3"),\
preload("res://resources/music/020217LAENDLER.mp3"),\
preload("res://resources/music/IMSLP84538-PMLP07952-T01_ravel_menuet_antique.mp3"),\
preload("res://resources/music/IMSLP99594-PMLP15559-09-Valzer_I.mp3"),\
preload("res://resources/music/IMSLP99595-PMLP15559-10-Valzer_II.mp3"),\
preload("res://resources/music/IMSLP256034-PMLP98016-kiel_op78walzes.mp3"),\
preload("res://resources/music/IMSLP293773-PMLP07329-Beethoven-6_Ecossaises-Stephan.mp3"),\
preload("res://resources/music/IMSLP421665-PMLP06107-AMB3.mp3"),\
preload("res://resources/music/IMSLP427125-PMLP30960-Minuet_in_E-flat_Maj._WoO_82.mp3"),\
preload("res://resources/music/IMSLP473831-PMLP02370-Waltz_Op._34_No.1_in_A-flat_major.mp3"),\
preload("res://resources/music/IMSLP473833-PMLP02370-Waltz_Op._34_No.3_in_F_major.mp3"),\
preload("res://resources/music/IMSLP473850-PMLP02373-Waltz_Op._64_no._1_in_D_flat_major.mp3"),\
preload("res://resources/music/laendler1.mp3"),\
preload("res://resources/music/laendler2.mp3"),\
preload("res://resources/music/originaldancewaltz1.mp3"),\
preload("res://resources/music/originaldancewaltz2.mp3"),\
preload("res://resources/music/originaldancewaltz3.mp3"),\
]

var played_songs = []

onready var music_player = $MusicPlayer
onready var pool = [$AudioStreamPlayer,$AudioStreamPlayer2,$AudioStreamPlayer3]

const fade_time: float = 2.0
var fading = false
var time_accum = 0.0
const fade_term: float = 80.0/fade_time
const orig_volume: float = 0.0
var target_volume = orig_volume


var toggle_music_delta = 0

func _ready():
# warning-ignore:return_value_discarded
	Globals.connect("music_toggled", self, "_music_toggled")
	_music_toggled()

func play(sfx: int):
	if sfx < 0 || sfx > _sfx.size(): return
	for c in pool:
		var a: AudioStreamPlayer = c
		if a.playing: continue
		else:
			a.stream = _sfx[sfx]
			a.play()
			return

func start_song(ix: int = -1):
	music_player.stop()
	if ix < 0 || ix > music.size():
		ix = randi() % music.size()
	if !music.empty():
		var song = music[ix]
		music_player.stream = song
		music_player.play()
		played_songs.append(song)
		music.erase(song)
		target_volume = orig_volume
	else:
		for _i in range(played_songs.size()):
			music.append(played_songs.pop_back())
		start_song()

func end_song():
	fading = true

func _process(delta: float) -> void:
	if fading:
		time_accum += delta
		if time_accum > fade_time:
			time_accum = 0.0
			fading = false
			music_player.stop()
			target_volume = orig_volume
		else:
			target_volume -= fade_term * delta
	music_player.volume_db = target_volume + toggle_music_delta

func _music_toggled():
	toggle_music_delta = 0
	if !Globals.music_on:
		toggle_music_delta -= 10000.0

