## Hide
## Comando

# Esconde la terminal.

extends Node

var HUB

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	HUB.terminal.cerrar()

func descripcion():
	return "Esconde la terminal"

func man():
	var r = "[ HIDE ] - " + descripcion()
	r += "\nUso: hide"
	r += "\nIgnora cualquier argumento."
	return r
