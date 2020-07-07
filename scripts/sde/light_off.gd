extends Node

# argumentos: [quien, target, que]
func exec(HUB, args):
	HUB.objetos.localizar("sala/luz").mensaje("alternar")