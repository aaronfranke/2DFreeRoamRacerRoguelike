tool
extends "intersections2D.gd"

# class member variables go here, for example:

#var intersections = []

func _ready():

	connect_intersections(1,0)
	connect_intersections(0,2)
	connect_intersections(1,2)


func connect_intersections(one, two):
	# call the extended script
	.connect_intersections(one, two)

	