extends Node2D

@onready var player = $Spaceship
@onready var asteroid = preload("res://Scenes/asteroid.tscn")
@onready var planet = preload("res://Scenes/planet.tscn")

var asteroidSpawnRadius = 6000 * 1.2** Data.mondeComp
var defaultCooldown = 1
var asteroidSpawnCooldown = 0
var asteroidForce = 2000 * 1.1 ** Data.mondeComp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print(GenerateZone(Vector2(0, 0), 25))
	zones.append(GenerateZone(Vector2(0, 0), 55))
	'''print(zones)
	print("Line break!!!")
	print(zones[0])
	print("Line break!!!")
	print(zones[0][1])
	print("Line break!!!")
	print(zones[0][1][0])
	print("Line break!!!")
	print(zones[0][1][0][0])'''
	#zones[i][j][k][l]
	#zones contains every single zone
	#zones[i] contains the ith zone
	#zones[i][j] goes between the position (0) and the planets array (1) of zone
	#zones[i][1][k] is the kth planet of zone
	#zones[1][1][k][l] gets the lth element of a planet


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#planetAttraction(player, zones[0][1][0])
	for i in zones:
		for j in i[1]:
			if(isInSOI(player, j)):
				planetAttraction(player, j)
	'''
	var insideANode = true
	var closestZonePos = Vector2.ZERO
	for i in zones:
		var zoneDist = i[0].distance_to(player.global_position)
		if(zoneDist <= zoneLimit):
			insideANode = true
		if(zoneDist < closestZonePos.distance_to(player.global_position)):
			closestZonePos = i[0]
			
	if(!insideANode):
		zones.append(GenerateZone((player.global_position - closestZonePos).normalized() * zoneLimit, 5))
	'''
	
	#print("DISTANCE TO PLANET 0:")
	#print(player.position.distance_to(zones[0][1][0][0]))
	#print("IN SOI OF PLANET 0?")
	#print(isInSOI(player, zones[0][1][0]))
	
	#print(player.global_position)
	#print(zones[0][1][0][0])
	#print(player.global_position.distance_to(zones[0][1][0][0]))
	
	asteroidSpawnCooldown -= delta
	if(asteroidSpawnCooldown <= 0):
		asteroidSpawnCooldown = defaultCooldown
		spawnAsteroid(asteroidSpawnRadius)
		spawnAsteroid(asteroidSpawnRadius)
	
	#if Input.is_action_just_pressed("esc"):
	#	get_tree().paused = true
	#	get_tree().change_scene_to_file("res://Scenes/pause.tscn")

func spawnAsteroid(radius):
	var firstAngle = randf_range(0, 2 * PI)
	var secondAngle = firstAngle + randi_range(-30, 30)
	
	if(secondAngle < 0):
		secondAngle = (2 * PI) + secondAngle
	elif(secondAngle > 2 * PI):
		secondAngle -= 2 * PI
	
	var firstPos = Vector2(cos(firstAngle), sin(firstAngle)) * radius + player.global_position
	#print(firstPos)
	var secondPos = Vector2(cos(secondAngle), sin(secondAngle)) * radius + player.global_position
	
	var dirVector = (secondPos - firstPos).normalized()
	
	var go = asteroid.instantiate()
	
	go.get_node("Sprite2D").scale *= randf_range(0.5, 2)
	var shape = CircleShape2D.new()
	shape.radius = go.get_node("CollisionShape2D").shape.radius * randf_range(0.5, 2)
	go.get_node("CollisionShape2D").shape = shape
	
	go.mass *= randf_range(0.5, 2)
	
	go.position = firstPos
	go.apply_impulse(dirVector * asteroidForce * randf_range(0.5, 2))
	add_child(go)
	#print("Asteroid!")





#Time to describe how I'll deal with our little planets!

var zones = []
#zones contains a bunch of 'zone' arrays, meant to cover wide areas

#each zone will have the following items:
#0: Position Vector2
#1: array of 'planet' arrays

#each planet array will have the following items:
#0: Position Vector2
#1: gravity of planet in g
#2: sphere of influence of planet, calculated as a function of the gravity
#3: node pointing to the object representing it
#4: surface color index
#5: cloud noise index

var zoneSize = 100000
#The size of all zones in game
var zoneLimit = 5000
#The distance where a new zone will be generated

var cloudNoise = [
	"res://Sprites/Planet Parts/noise00.png",
	"res://Sprites/Planet Parts/noise01.png",
	"res://Sprites/Planet Parts/noise02.png",
	"res://Sprites/Planet Parts/noise03.png",
	"res://Sprites/Planet Parts/noise04.png",
	"res://Sprites/Planet Parts/noise05.png",
	"res://Sprites/Planet Parts/noise06.png",
	"res://Sprites/Planet Parts/noise07.png",
	"res://Sprites/Planet Parts/noise08.png",
	"res://Sprites/Planet Parts/noise09.png",
	"res://Sprites/Planet Parts/noise10.png",
	"res://Sprites/Planet Parts/noise11.png",
	"res://Sprites/Planet Parts/noise12.png",
	"res://Sprites/Planet Parts/noise13.png",
	"res://Sprites/Planet Parts/noise14.png",
	"res://Sprites/Planet Parts/noise15.png",
	"res://Sprites/Planet Parts/noise16.png",
	"res://Sprites/Planet Parts/noise17.png",
	"res://Sprites/Planet Parts/noise18.png",
	"res://Sprites/Planet Parts/noise19.png",
	"res://Sprites/Planet Parts/noise20.png",
	"res://Sprites/Planet Parts/noise21.png",
	"res://Sprites/Planet Parts/noise22.png",
	"res://Sprites/Planet Parts/noise23.png",
	"res://Sprites/Planet Parts/noise24.png",
	"res://Sprites/Planet Parts/noise25.png",
	"res://Sprites/Planet Parts/noise26.png",
	"res://Sprites/Planet Parts/noise27.png"
]
var possibleColors = [
	Color.BLUE,
	Color.GREEN,
	Color.RED,
	Color.YELLOW,
	Color.ORANGE_RED,
	Color.BROWN,
	Color.BURLYWOOD,
	Color.DARK_GOLDENROD,
	Color.DARK_OLIVE_GREEN,
	Color.KHAKI,
	Color.PINK
]

func GenerateZone(pos, planetCount):
	var zoneArray = []
	
	zoneArray.append(pos)
	
	var planetsArray = []
	
	for i in range(planetCount):
		planetsArray.append(GeneratePlanet(pos))
	
	zoneArray.append(planetsArray)
	
	#print(planetsArray == SeperatePlanets(planetsArray, 1000))
	#var storage = planetsArray
	planetsArray = SeperatePlanets(planetsArray, 2000)
	#print(storage == planetsArray)
	
	return zoneArray
	
func GeneratePlanet(rootPos):
	var planetArray = []
	#Generating position
	planetArray.append(Vector2(randf_range(rootPos.x - zoneSize, rootPos.x + zoneSize), randf_range(rootPos.y - zoneSize, rootPos.y + zoneSize)))
	
	#Generating gravity
	planetArray.append(randf_range(0.5, 1.5))
	
	#Generating sphere of influence
	planetArray.append(planetArray[1] * 512)
	
	#Generating planet node
	var newPlanet = planet.instantiate()
	planetArray.append(newPlanet)
	newPlanet.position = planetArray[0]
	
	var surfaceTexture = newPlanet.get_node("Surface")
	var cloudTexture = newPlanet.get_node("Clouds")
	var soiTexture = newPlanet.get_node("SOI")
	
	soiTexture.scale *= 512 / (planetArray[2])
	
	var colorIndex = randi_range(0, len(possibleColors) - 1)
	var cloudIndex = randi_range(0, len(cloudNoise) - 1)
	
	surfaceTexture.modulate = possibleColors[colorIndex]
	cloudTexture.texture = load(cloudNoise[cloudIndex])
	
	add_child(newPlanet)

	#Generating surface color index
	planetArray.append(colorIndex)
	
	#Generating cloud noise index
	planetArray.append(cloudIndex)
	
	'''print("We're really doing this huh?")
	print(planetArray)
	var newIndex = 0
	for i in planetArray:
		print(str(newIndex) + ":")
		print(i)
		newIndex += 1
	'''
	
	return planetArray

func SeperatePlanets(planets, minDist):
	#Makes sure planets are a certain distance apart from each other
	var testsSucceeded = 0
	var newPlanets = planets
	var planetsToReturn = planets
	var index = 0
	var limit = 10 #how many times the function will attempt to find a solution
	
	#print("Obviously I'm here...")
	while testsSucceeded != len(planets):
		#print("I should be here too?.. index: " + str(index))
		if(index >= limit):
			#print("oh :(")
			#print(testsSucceeded)
			#print(len(planets))
			#planetsToReturn = planets
			break
		
		testsSucceeded = 0
		newPlanets = planetsToReturn
		planetsToReturn = []
		
		for i in newPlanets:
			#print("Alright, I'm in the first loop...")
			var listToAdd = i
			for j in newPlanets:
				#print("Second loop as well...")
				if i[0] != j[0]:
					if i[0].distance_to(j[0]) < minDist:
						#print(str(i[0]) + " and " + str(j[0]) + " are too close together!")
						var randAngle = randf_range(-PI / 6, PI / 6) + (j[0]  - i[0]).angle()
						var dirVector = Vector2(cos(randAngle), sin(randAngle))
						i[0] = dirVector * minDist
						#print("So we turned it into " + str(i[0]) + " :D")
						listToAdd = []
						for k in i:
							listToAdd.append(k)
			planetsToReturn.append(listToAdd)
		
		for i in planetsToReturn:
			var insiderSuccessAmount = 0
			for j in planetsToReturn:
				if i[0].distance_to(j[0]) >= minDist:
					insiderSuccessAmount += 1
			if insiderSuccessAmount == len(newPlanets):
				testsSucceeded += 1
		
		index += 1
	
	#print(planetsToReturn)
	return planetsToReturn

func planetAttraction(rbToModify, attractingPlanet):
	var g = attractingPlanet[1]	
	#print(attractingPlanet)
	#print("Line break!!!")
	#print(attractingPlanet[1])
	
	var prevAngVel = rbToModify.angular_velocity
	var force = (g / (attractingPlanet[0].distance_to(rbToModify.position) * attractingPlanet[0].distance_to(rbToModify.position))) * 10000
	#rbToModify.angular_velocity = prevAngVel
	
	rbToModify.apply_impulse((attractingPlanet[0] - rbToModify.position) * force)

func isInSOI(player, planet):
	if player.global_position.distance_to(planet[0]) <= planet[2] * 8:
		#print("IN SPHERE OF INFLUENCE WITH A DISTANCE OF:")
		#	print(player.position.distance_to(planet[0]))
		return true
	return false
