## Exit
## Comando

# Cierra el HUB.

extends Node

var HUB

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
	r += "\nIgnora cualquier argumento."
	return r
