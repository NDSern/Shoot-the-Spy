extends RigidBody2D

var killable
signal correct_target
signal wrong_target
signal escaped

# Called when the node enters the scene tree for the first time.
func _ready():	
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Position of the target picture
func dummy_start(pos, target):
	position = pos
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(mob_types[target])
	show()


func run_target(animation):
	# Get the array of names of animations
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	# Play the selected animation
	$AnimatedSprite2D.play(mob_types[animation])
	# This is the target that need to be shot
	killable = true
	# Show the target animation
	show()

func run_civ(animation):
	# There are 7 animations
	# Choose the one that isnt the target only
	var target = animation
	while target == animation:
		target = randi() % 7
	var mob_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	var randomAnimationSpeed = randf()
	$AnimatedSprite2D.speed_scale = randomAnimationSpeed
	$AnimatedSprite2D.play(mob_types[target])
	killable = false
	show()


func _on_area_2d_input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		if killable:
			correct_target.emit()
		else:
			wrong_target.emit()

# Despawn off screen
func _on_visible_on_screen_notifier_2d_screen_exited():
	if killable:
		escaped.emit()
	queue_free()
