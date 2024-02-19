extends Area2D

const POT = preload("res://pot.tscn")

func _on_body_entered(_body):
	print("Room " + str(position) + " Was Entered")




func _on_body_exited(_body):
	print("Room " + str(position) + " Was Exited")
