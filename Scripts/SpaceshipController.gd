extends Node2D

var thrustersFiring = false
var turningRight = false
var turningLeft = false

var thrust = 5000 #in newtons
var rcsThrust = 10000 #in newtons

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(thrustersFiring):
		$".".apply_force(-transform.y * thrust)
	
	if(turningRight):
		$".".apply_torque(rcsThrust)
		
	if(turningLeft):
		$".".apply_torque(-rcsThrust)
	
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
