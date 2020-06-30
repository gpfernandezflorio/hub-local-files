extends Node

# argumentos: [quien, target, que]
func exec(HUB, args):
	args[1].mover(Vector3(0,10,-10))