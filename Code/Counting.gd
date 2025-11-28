extends Node2D
var rng =  RandomNumberGenerator.new()
var elements = []
@export var difficulty = 1
@export var difficultyMax = 50
var answer = []
var elementId
var buttonId = ["1", "2", "3", "4"]
var points = 0
var wrongAnswer
var offMargin = 50
var maxHealth = 5
var health = maxHealth

func _ready():
	$Game/ProgressBar.max_value = maxHealth
	$Game/ProgressBar.value = health
	makeMath()
	
#func _process(_delta):

func die():
	$Game.visible = !$Game.visible
	$Death.visible = !$Death.visible
	$Death/PointText.text = "you had " + str(points) + " points"

func randomButton():
	buttonId.shuffle()
	match buttonId.pop_front():
		"1":
			return $Game/Button1
		"2":
			return $Game/Button2
		"3":
			return $Game/Button3
		"4":
			return $Game/Button4
		_:
			print("failsafe tripped, restarting...")
			buttonId = ["1", "2", "3", "4"]
			randomButton()
			
func randomElement():
	
	elementId = str(roundf(rng.randf_range(-0.49, roundf(difficulty/(difficultyMax/3.49)))))
	var elements = ["+", "-", "*", "/"]
	
	match elementId:
		"0","1","2","3":
			return elements[int(elementId)]
		_:
			print("failsafe activated")
			return elements[0]
			
func makeMath():
	
	buttonId = ["1", "2", "3", "4"]
	print("\ngenerating a new math problem")
	elements.clear()
	elements.push_back(roundf(rng.randf_range(1, 10)))
	var i = difficultyMax
	
	while i == difficultyMax:
		
		elements.push_back(randomElement())
		elements.push_back(round(rng.randf_range(1, 10)))
		i = roundf(rng.randf_range(difficulty, difficultyMax))
		print(elements)
		
	answer = elements.duplicate()
	
	while answer.find("*") != -1 || answer.find("/") != -1:
		
		if (answer.find("*") < answer.find("/") && answer.find("*") != -1)|| answer.find("/") == -1:
			
			answer[answer.find("*")-1] = float(answer[answer.find("*")-1]) * float(answer.pop_at(answer.find("*")+1))
			answer.pop_at(answer.find("*"))
			print(answer)
			
		elif (answer.find("/") < answer.find("*") && answer.find("/") != -1) || answer.find("*") == -1:
			
			answer[answer.find("/")-1] = float(answer[answer.find("/")-1]) / float(answer.pop_at(answer.find("/")+1))
			answer.pop_at(answer.find("/"))
			print(answer)
			
	while answer.find("+") != -1 || answer.find("-") != -1:
		
		if (answer.find("+") < answer.find("-") && answer.find("+") != -1) || answer.find("-") == -1:
			
			answer[answer.find("+")-1] = float(answer[answer.find("+")-1]) + float(answer.pop_at(answer.find("+")+1))
			answer.pop_at(answer.find("+"))
			print(answer)
			
		elif (answer.find("-") < answer.find("+") && answer.find("-") != -1) || answer.find("+") == -1:
			
			answer[answer.find("-")-1] = float(answer[answer.find("-")-1]) - float(answer.pop_at(answer.find("-")+1))
			answer.pop_at(answer.find("-"))
			print(answer)
	if snappedf(answer[0], 0.1) != float(answer[0]):
		
		print("Too difficult of a problem, restarting")
		makeMath()
		
	elif (answer[0] < 0) && (difficulty < 20):
		
		print("Too difficult of a problem, restarting")
		makeMath()
		
	else:
		randomButton().text = str(answer[0])
		makeWrongAnswers()
		var problem = ""
		i = 0
		while i < elements.size():
			problem = problem + " " + str(elements[i])
			i = i + 1
		$Game/MathProblem.text = problem
	#elif str(answer[0]).length() >= 3:
		#print("Too long of an answer, restarting")
		#makeMath()

func makeWrongAnswers():
	var i = 0
	while i < 3:
		wrongAnswer = snappedf(rng.randf_range(answer[0]-10, answer[0]+10), 1)
		print(wrongAnswer)
		randomButton().text = str(wrongAnswer)
		i = i + 1
		

func _on_button_pressed(id):
	if get_node("Game/Button"+str(id)).text == str(answer[0]):
		points = points + elements.size()
		$Game/Points.text = " " + str(points)
		if (difficulty + elements.size()) < difficultyMax:
			difficulty = difficulty + elements.size()
		else:
			difficulty = difficultyMax - 1
	else:
		points = points - elements.size()
		$Game/Points.text = " " + str(points)
		health = health - 1
		if (difficulty - elements.size()) > 0:
			difficulty = difficulty - elements.size()
		else:
			difficulty = 1
	if health < 1:
		die()
	else:
		$Game/ProgressBar.value = health
		makeMath()

func _on_retry_button_pressed():
	points = 0
	difficulty = 1
	health = maxHealth
	die()
	$Game/Points.text = " " + str(points)
	$Game/ProgressBar.value = health
	makeMath()

func _on_quit_button_pressed():
	get_tree().quit()
