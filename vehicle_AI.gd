extends "vehicle.gd"

# class member variables go here, for example:
# input 
var gas = false
var brake = false
var left = false
var right = false
var joy = Vector2(0,0)

var brain = null
var current = 0

var path

var stop = false
var t_dot

# goes down to brain.gd
export var state = 0

# Start
func _ready():
	# Top Down Physics
	set_gravity_scale(0.0)
	
	brain = get_node("brain")
	# set state
	brain.set_state(state)
	
	if get_tree().get_nodes_in_group("world")[0].get_child(0).has_node("Visualizer"):
		path = get_tree().get_nodes_in_group("world")[0].get_child(0).get_node("Visualizer").path
		#current = 0
		current = path.size()-1
		brain.target = path[current]
		print("Setting target according to path.. " + str(brain.target))

# Fixed Process
func _physics_process(delta):
	# reset input
	gas = false
	brake = false
	left = false
	right = false
	joy = Vector2(0,0)
	
	
	# steering from boid
	#if brain.steer != Vector2(0,0):
	#	print("Brain steer: " + str(brain.steer))

	# stop
	if stop:
		if speed > 10:
			brake = true
		if reverse and speed > 10:
			gas = true

	else:
	#	if speed <= 50:
		if brain.steer.y < 0: # and speed <= 200:
			# brake for sharp turns if going at speed
			if abs(brain.steer.x) > 7.5 and speed > 30:
				if not reverse:
					brake = true
				else:
					gas = true
			else:
				gas = true
				#print(get_name() + " gas")
		else:
			if speed > 0 and speed < 100:
				brake = true
	
	# minimum speed just like with old, analog-style inputs (15 equals 1 m/s, since the car is 30 px long = 2 m)
	if brain.steer.x != 0 and speed > 15:
		joy = brain.steer

	## the y check was to prevent trying to steer in place (turn on a dime)
	# but it's better to check for some minimum speed (15 equals 1 m/s, since the car is 30 px long = 2 m)
#	if brain.steer.x < 0 and speed > 15: #and brain.steer.y < 0:
#		left = true
#	elif brain.steer.x > 0 and speed > 15: #and brain.steer.y < 0:
#		right = true
		
	
	# drive
#	if (speed <= 80): #250):
#		gas = true
	# Break / Reverse
#	else:
#		braking = true
	#if (get_name() == "copAI"):
	#	print("g: " + str(gas) + " b: " + str(brake) + " l: " + str(left) +  " r: " + str(right))
	
	do_physics(gas, brake, left, right, joy, delta)
	
	# stop
#	if brain.steer == Vector2(0,0):
#		stop = true
	
	
	# proceed
	if brain.get_state() == brain.STATE_PATH:
		#print("We're in pathing state")
		
		t_dot = forward_vec.dot(brain.marker.get_position())
		
		
		#B-A = from A to B
		#var target_vec = path[current] - get_position()
		#print("Target_v" + str(target_vec))
		#t_dot = forward_vec.dot(target_vec)
		
		
		if brain.dist <= 45 and not stop:
			# path following	
			#print("Arrived at target, next: " + str(current-1))
			if (current-1) > -1:
				# for going other way round
				current = current - 1
				brain.target = path[current]
			else:
				stop = true
	
		# overshoot
		if brain.dist <= 55 and brain.steer.x > 8.5 and not stop:
			if (current-1) > -1:
				#print("Overshot, next: " + str(current-1))
				current = current - 1
				brain.target = path[current]
			else:
				stop = true
				
		#if we passed the point, don't backtrack
		if (t_dot < 0 and not stop):
			if (current-1) > -1:
				#print("Overshot, next: " + str(current-1))
				current = current - 1
				brain.target = path[current]
			else:
				stop = true
			
			
#		# lane change
#		#print("Arrived at target, number " + str(current) + " next " + str(current+1))
#		current = current + 1
#		# if it's the first time we arrived, angle back
#		if current == 1:
#			var loc_tg = (forward_vec*brain.lane_change_dist_factor).rotated(deg2rad(-brain.lane_change_deg))
#			brain.target = to_global(loc_tg)
#		if current == 2:
#			# head to point some distance ahead
#			var loc_tg = forward_vec*2
#			brain.target = to_global(loc_tg)

		# else nothing
