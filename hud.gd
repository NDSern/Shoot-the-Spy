extends CanvasLayer
signal start_game

# Called when the node enters the scene tree for the first time.
func _ready():
	$InGameHUD.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func show_message(text):
	$Label.text = text
	$Label.show()
	$Timer.start()


func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $Timer.timeout

	$Label.text = "Shoot The Spy"
	$Label.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$Button.show()


func update_score(score):
	$InGameHUD/ScoreLabel.text = "Score: " + str(score)


func _on_button_pressed():
	$Button.hide()
	$InGameHUD.show()
	start_game.emit()


func _on_timer_timeout():
	$Label.hide()
