extends Spatial

onready var currentRoom = $Stage
var rotateY = 0
var SPEED = 2
var file = File.new()
var textData = file.open("res://data/dialogue.json", file.READ)
var json = file.get_as_text()
var gameText = JSON.parse(json).result
var currentText = "1"
var istalking = false
var can_reset = false
var idle = true
signal nextText

func _ready():
	printText()

func _process(delta):
	if idle == true:
		rotateY = 0.1
		
	rotateRoom()
	animatePablarales()

func _input(event):
	
	idle = false
	
	if event.is_action_pressed("left"):
		rotateY = SPEED
	elif event.is_action_pressed("right"):
		rotateY = -SPEED
	elif event.is_action_released("left") or event.is_action_released("right"):
		rotateY = 0
	elif event.is_action_pressed("quit"):
		get_tree().quit()
	elif event.is_action_pressed("reset_text") and can_reset == true:
		resetText()

func rotateRoom():
	var currentAngle = currentRoom.rotation_degrees
	currentRoom.rotation_degrees = currentAngle + Vector3(0, rotateY, 0)
	angleText(currentRoom.rotation_degrees.y)
	
	
func angleText(angle):
	$UI/AngleInd/ColorRect/AngleTextLabel.text = str(int(angle))
	
func printText():
	print(gameText.size())
	if int(currentText) <= gameText.size():
		var text = gameText[currentText]["text"]
		var mood = gameText[currentText]["mood"]
		$UI/DialogBox/DialogText.text = ''
		$pablarales/pablarales_face.animation = mood
		for l in range(text.length()):
			istalking = true
			$UI/DialogBox/DialogText.text += gameText[currentText]["text"][l]
			$pablarales/Voice.play(0.4)
			yield(get_tree().create_timer(0.05), "timeout")	
			if l == text.length() - 1:
				currentText = str(int(currentText) + 1)
				emit_signal("nextText")

func animatePablarales():
	if istalking == true:
		$pablarales/pablarales_face.playing = true
		$pablarales/headtilt.play("tilthead")
	else:
		$pablarales/pablarales_face.playing = false
		$pablarales/headtilt.stop()

func resetText():
	currentText = "1"
	printText()

func _on_Main_nextText():
	print(currentText)
	istalking = false
	can_reset = true
	yield(get_tree().create_timer(2), "timeout")
	printText()
