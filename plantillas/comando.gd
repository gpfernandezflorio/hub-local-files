## NOMBRE_DEL_ARCHIVO
## Comando

# DESCRIPCIÓN

extends Node

var HUB

func inicializar(hub):
	HUB = hub

func comando(argumentos):
	pass

func descripcion():
	return "DESCRIPCIÓN"

func man():
	var r = "[ COMANDO ] - " + descripcion()
	r += "\nUso: comando"
	r += "\nIgnora cualquier parámetro."
	return r