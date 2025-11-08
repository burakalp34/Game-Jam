extends Node2D

@onready var player = $Spaceship
@onready var asteroid = preload("res://Scenes/asteroid.tscn")

var asteroidSpawnRadius = 3000
var defaultCooldown = 1
var asteroidSpawnCooldown = 0
var asteroidForce = 2000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	asteroidSpawnCooldown -= delta
	if(asteroidSpawnCooldown <= 0):
		asteroidSpawnCooldown = defaultCooldown
		spawnAsteroid(asteroidSpawnRadius)
		spawnAsteroid(asteroidSpawnRadius)

func spawnAsteroid(radius):
	var firstAngle = randf_range(0, 2 * PI)
	var secondAngle = firstAngle + randi_range(-30, 30)
	
	if(secondAngle < 0):
		secondAngle = (2 * PI) + secondAngle
	elif(secondAngle > 2 * PI):
		secondAngle -= 2 * PI
	
	var firstPos = Vector2(cos(firstAngle), sin(firstAngle)) * radius + player.global_position
	print(firstPos)
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

func generatePlanet():
	pass
