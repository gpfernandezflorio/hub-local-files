## Comandos
## Comando

# Lista los comandos cargados.

extends Node

var HUB

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	var nodo_comandos = HUB.terminal.nodo_comandos
	for comando in nodo_comandos.comandos_cargados:
		var nodo = nodo_comandos.comandos_cargados[comando]
		var mensaje = " - " + nodo.get_name()
		if nodo.has_method("descripcion"):
			mensaje += " : " + nodo.descripcion()
		HUB.mensaje(mensaje)
		

func descripcion():
	return "Lista los comandos cargados"

func man():
	var r = "[ COMANDOS ] - " + descripcion()
	r += "\nUso: comandos"
	r += "\nIgnora cualquier argumento."
	return r
