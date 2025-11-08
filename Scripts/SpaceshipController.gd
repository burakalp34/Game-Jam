extends Node2D

var thrustersFiring = false
var turningRight = false
var turningLeft = false
var shooting = false

var thrust = 3000 #in newtons
var rcsThrust = 10000 #in newtons
var littleBitOfFriction = 5 #in newtons for arcady gameplay
var bulletForce = 3000

var bullet = preload("res://Scenes/bullet.tscn")
@onready var bulletPos = $"Bullet Launch Pos"
var regularCooldown = 0.05
var burstCooldown = 0.2
var shotCooldown = 0.05
var burstCount = 3
var maxBurst = 3
var canShoot = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print($".".position)
	
	if(thrustersFiring):
		$".".apply_force(-transform.y * thrust)
	
	if(turningRight):
		$".".apply_torque(rcsThrust)
		if($".".linear_velocity != Vector2.ZERO):
			$".".apply_force(-$".".linear_velocity * littleBitOfFriction)
		
	if(turningLeft):
		$".".apply_torque(-rcsThrust)
		if($".".linear_velocity != Vector2.ZERO):
			$".".apply_force(-$".".linear_velocity * littleBitOfFriction)
		
	#if($".".linear_velocity != Vector2.ZERO):
		#$".".apply_force(-$".".linear_velocity * littleBitOfFriction)
	
	if(shooting and canShoot):
		canShoot = false
		
		var go = bullet.instantiate()
		go.position = bulletPos.position
		go.apply_impulse(-transform.y * bulletForce)
		add_child(go)
		#print("Shoot!")
		
		maxBurst -= 1
	
	if(!canShoot):
		shotCooldown -= delta
	if(shotCooldown <= 0):
		shotCooldown = regularCooldown
		canShoot = true
	if(maxBurst <= 0):
		maxBurst = burstCount
		canShoot = false
		shotCooldown = burstCooldown
	
func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("Thrusters")):
		thrustersFiring = true
	
	if(event.is_action_released("Thrusters")):
		thrustersFiring = false
		
	if(event.is_action_pressed("Turn Right")):
		turningRight = true
	
	if(event.is_action_released("Turn Right")):
		turningRight = false
		
	if(event.is_action_pressed("Turn Left")):
		turningLeft = true
	
	if(event.is_action_released("Turn Left")):
		turningLeft = false
	
	if(event.is_action_pressed("Shoot")):
		shooting = true
		maxBurst = burstCount
		shotCooldown = regularCooldown
	
	if(event.is_action_released("Shoot")):
		shooting = false
