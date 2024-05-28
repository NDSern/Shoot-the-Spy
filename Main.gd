extends Node

@export var mob_scene: PackedScene
var score
var level
var newLevel
var innocent = false
var target
var timeToShoot := 0.0
var cursor = load("res://sprites/vien den.png")


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(cursor)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Stopwatch using delta
	# The faster the target is picked, the higher the score
	if newLevel || (newLevel && innocent): 
		var thisRoundScore = 1/timeToShoot * 100
		score += int(thisRoundScore)
		timeToShoot = 0
		newLevel = false
		innocent = false
		$HUD.update_score(score)
		new_round()
	if innocent && !newLevel:
		game_over()
		innocent = false
	timeToShoot += delta

# Signals from packed scene
func _on_correct_target():
	level += 1
	$CorrectSound.play()
	newLevel = true

func _on_target_escaped():
	print("Target escaped")
	innocent = true

func _on_wrong_target():
	print("Shoot the wrong target")	
	innocent = true

func spawn_mob(avoid_target, killable):
	# Instantiate the mob
	var mob = mob_scene.instantiate()
	# Get the set of locations the mob can spawn on
	var mob_spawn_location = $Spawn/PathFollow2D
	# Randomize the location
	mob_spawn_location.progress_ratio = randf()
	# Randomize the place the mob will go to
	var direction = mob_spawn_location.rotation + PI / 2
	# Place the mob in location
	mob.position = mob_spawn_location.position
	# Direct the mob
	direction += randf_range(-PI / 4, PI / 4)
	# Randomize the speed of the mob based on difficulty
	var min_speed = 100 + level * 10
	var max_speed = 200 + level * 10
	var velocity = Vector2(randf_range(min_speed, max_speed), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	# Spawn/Render the mob
	add_child(mob)
	# Handle the kill logic, whether or not the player hit the correct target
	if killable:
		mob.run_target(avoid_target)
		mob.connect("correct_target", _on_correct_target)
		mob.connect("escaped", _on_target_escaped)
	else:
		mob.run_civ(avoid_target)
		mob.connect("wrong_target", _on_wrong_target)


func spawn_dummy(target):
	var mob = mob_scene.instantiate()
	
	add_child(mob)
	mob.dummy_start($TargetHUDPosition.position, target)


# GAME START
func _on_canvas_layer_start_game():
	$HUD/GameOverHUD.hide()
	level = 0
	score = 0
	$HUD.show_message("Get Ready!")
	await $HUD/Timer.timeout
	$HUD.update_score(score)
	$HUD/InGameHUD.show()
	new_round()

# Game logic
func new_round():
	# Despawn everything, fresh start
	get_tree().call_group("mobs", "queue_free")
	# Get the target
	target = randi() % 7
	print(target)
	# Spawn the target picture
	spawn_dummy(target)
	# Spawn target
	spawn_mob(target, true)
	# Amounts of civ to spawn
	var civs = level * 2 + (randi() % 5 + 1)
	# Spawn civs here
	for i in range(civs):
		spawn_mob(target, false)


func game_over():
	get_tree().call_group("mobs", "queue_free")
	$FailedSound.play()
	$HUD.show_game_over(score)
