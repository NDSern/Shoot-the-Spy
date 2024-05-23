extends Node

@export var mob_scene: PackedScene
var score
var target

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Signals from packed scene
func _on_correct_target():
	score += 1
	$HUD.update_score(score)
	new_round()

func _on_target_escaped():
	score = -1
	$HUD.update_score(score)
	game_over()

func _on_wrong_target():
	score = -2
	$HUD.update_score(score)
	game_over()


func spawn_target(chosen_target):
	var mob = mob_scene.instantiate()
	
	var mob_spawn_location = $Spawn/PathFollow2D
	mob_spawn_location.progress_ratio = randf()
	
	var direction = mob_spawn_location.rotation + PI / 2
	
	mob.position = mob_spawn_location.position
	
	direction += randf_range(-PI / 4, PI / 4)
	#mob.rotation = direction
	
	var velocity = Vector2(randf_range(50.0, 100.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	
	add_child(mob)
	mob.run_target(chosen_target)
	mob.connect("correct_target", _on_correct_target)
	mob.connect("escaped", _on_target_escaped)


func spawn_mob(avoid_target):
	var mob = mob_scene.instantiate()
	
	var mob_spawn_location = $Spawn/PathFollow2D
	mob_spawn_location.progress_ratio = randf()
	
	var direction = mob_spawn_location.rotation + PI / 2
	
	mob.position = mob_spawn_location.position
	
	direction += randf_range(-PI / 4, PI / 4)
	#mob.rotation = direction
	
	var velocity = Vector2(randf_range(100.0, 200.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	
	add_child(mob)
	mob.run_civ(avoid_target)
	mob.connect("wrong_target", _on_wrong_target)


func spawn_dummy(target):
	var mob = mob_scene.instantiate()
	
	add_child(mob)
	mob.dummy_start($TargetHUDPosition.position, target)


# GAME START
func _on_canvas_layer_start_game():
	score = 0
	$HUD.show_message("Get Ready!")
	new_round()


func new_round():
	# Despawn everything, fresh start
	get_tree().call_group("mobs", "queue_free")
	# Get the target
	target = randi() % 7
	print(target)
	# Spawn the target picture
	spawn_dummy(target)
	# Spawn target
	spawn_target(target)
	# Amounts of civ to spawn
	var civs = score * 2 + (randi() % 3 + 1)
	# Spawn civs here
	for i in range(civs):
		spawn_mob(target)


func game_over():
	pass
