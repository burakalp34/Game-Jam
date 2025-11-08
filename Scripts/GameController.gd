extends Node2D

@onready var player = $Spaceship
@onready var asteroid = preload("res://Scenes/asteroid.tscn")

var asteroidSpawnRadius = 2000
var defaultCooldown = 2
var asteroidSpawnCooldown = 2
var asteroidForce = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	asteroidSpawnCooldown -= delta
	if(asteroidSpawnCooldown <= 0):
		asteroidSpawnCooldown = defaultCooldown
		spawnAsteroid(asteroidSpawnRadius)

func spawnAsteroid(radius):
	var firstAngle = randf_range(0, 2 * PI)
	var secondAngle = firstAngle + randi_range(-60, 60)
	
	if(secondAngle < 0):
		secondAngle = (2 * PI) + secondAngle
	elif(secondAngle > 2 * PI):
		secondAngle -= 2 * PI
	
	var firstPos = Vector2(cos(firstAngle), sin(firstAngle)) * radius + player.global_position
	print(firstPos)
	var secondPos = Vector2(cos(secondAngle), sin(secondAngle)) * radius + player.global_position
	
	var dirVector = (secondPos - firstPos).normalized()
	
	var go = asteroid.instantiate()
	go.apply_impulse(secondPos * asteroidForce, firstPos)
	add_child(go)
	print("Asteroid!")
