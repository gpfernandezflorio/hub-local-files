## Exit
## Comando

# Cierra el HUB.

extends Node

var HUB

var arg_map = {
	"lista":[]
}

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	HUB.salir()

func descripcion():
	return "Cierra el HUB"

func man():
	var r = "[ EXIT ] - " + descripcion()
	r += "\nUso: exit"
	r += "\n Ignora cualquier argumento."
	return r
