extends Node

# argumentos: [quien, target, que]
func exec(HUB, args):
	var quien = args[0]
	var target = args[1]
	var dir = (target.get_global_transform().origin-quien.get_global_transform().origin).normalized()
	if target.sabe("empujar"):
		target.mensaje("empujar",[dir])
	else:
		target.mover(dir)