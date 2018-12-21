extends "vehicle.gd"

# class member variables go here, for example:
# input 
var gas = false
var brake = false
var left = false
var right = false

var brain = null
var current = 0

var path

# Start
func _ready():
	# Top Down Physics
	set_gravity_scale(0.0)
	
	brain = get_node("brain")
	
	path = get_tree().get_nodes_in_group("world")[0].get_node("proc_map/Visualizer").path
	current = path.size()-1
	brain.target = path[current]

# Fixed Process
func _physics_process(delta):
	# reset input
	var gas = false
	var braking = false
	var left = false
	var right = false
	
	# steering from boid
#	print("Brain steer: " + str(brain.steer))

#	if speed <= 50:
	if brain.steer.y < 0: # and speed <= 200:
		# brake for sharp turns
		if abs(brain.steer.x) > 7.5:
			braking = true
		else:
			gas = true
	else:
		braking = true
	
	# the y check is to prevent trying to steer in place (turn on a dime)
	if brain.steer.x < 0 and brain.steer.y < 0:
		left = true
	elif brain.steer.x > 0 and brain.steer.y < 0:
		right = true
		
	
	# drive
#	if (speed <= 80): #250):
#		gas = true
	# Break / Reverse
#	else:
#		braking = true
	
	do_physics(gas, braking, left, right, delta)
	
	# proceed
	if brain.dist <= 45:
		print("Arrived at target, next: " + str(current-1))
		if (current-1) > -1:
			# for going other way round
			current = current - 1
			brain.target = path[current]
	
	# overshoot
	if brain.dist <= 55 and brain.steer.x > 8.5:
		if (current-1) > -1:
			print("Overshot, next: " + str(current-1))
			current = current - 1
			brain.target = path[current]
