extends Control



signal textbox_closed

@export var enemy: Resource = null

@export var players: Array 
@export var player_data: PlayerStats

var current_player_health = 0
var current_enemy_health = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	update_health()
	$EnemyContainer/Enemy.texture = enemy.texture
	
	$Textbox.hide()
	$ActionPanel.hide()
	display_text("A wild %s enemy appears!" % enemy.name)
	await "textbox_closed"
	$ActionPanel.show()
	$Camera2D.make_current()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


#Textbox is hidden by default, when called this function will show the text box + whatever text you pass in as an argument
func display_text(text):
	$Textbox.show()
	$Textbox/Label.text = text
	
	
#Closes the text box based on whether or not you press enter or left mouse button
func _input(event):
	if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and $Textbox.visible:
		$Textbox.hide()
		emit_signal("textbox_closed")
		
#This function is used to update the progress bar to reflect the current health of an entity(player/enemy)
func set_health(progress_bar,health, max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text ="HP: %d/%d" % [health, max_health]
	
#This function utilizes set_health() to update the health bar of each player and enemy
func update_health():
	
	set_health($EnemyContainer/ProgressBar, enemy.health, enemy.health)
	for player in $PlayerPanel/HBoxContainer.get_children():
		var health_bar = player.get_node("VBoxContainer/ProgressBar")
		set_health(health_bar,State.current_health,State.max_health)
	current_player_health = State.current_health
	current_enemy_health = enemy.health
		
		
#when you pick the run option it closes the game
func _on_run_pressed() -> void:
	display_text("Got away safely!")
	await "textbox_closed"
	await get_tree().create_timer(.25).timeout
	get_tree().quit()


#This function defines what happens when you press the attack option ingame
func _on_attack_pressed():
	display_text("You swung at the enemy")  
	await "textbox_closed"
	
	current_enemy_health = max(0, current_enemy_health - State.damage)
	set_health($EnemyContainer/ProgressBar, current_enemy_health, enemy.health)
	
	$AnimationPlayer.play("EnemyDamaged")
	await $AnimationPlayer.animation_finished
	
	display_text("You dealt %d damage!" %State.damage)
	await "textbox_closed"

#currently the turns are managed in a way where the player always goes first and after they pick an option the enemy_turn() is called
	enemy_turn()
	
# Almost the same as the _on_attack_pressed(): function except we use a for loop to iterate over all the children in the child node of Player Panel
# this gives us all the "players" which are panel containers. From there we can called .get_node() where we specify the path to the progress bar
# Right now I'm trying to get the enemy to attack one of the players randomly, by adding each player container to an array and then picking one randomly
# to get damaged in the set_health() function 
func enemy_turn():
	display_text("%s lunges at you" %enemy.name)
	await "textbox_closed"
	var players: Array

	
	current_player_health = max(0, current_player_health - enemy.damage)
#Currently bugged? enemy will sometimes deal double damage or tripple damage will figure this out later
	for player in $PlayerPanel/HBoxContainer.get_children():
		var health_bar = player.get_node("VBoxContainer/ProgressBar")
		players.append(health_bar)
		
	set_health(players.pick_random(), current_player_health, State.max_health)
		
	$AnimationPlayer.play("Shake")
	await $AnimationPlayer.animation_finished
		
	display_text("%s dealt %d damage" %[enemy.name, enemy.damage])

	
	
