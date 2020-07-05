## End
## Comando

# Finaliza un programa.

extends Node

var HUB

var arg_map = {
	"obligatorios":1,
	"lista":[
		{"nombre":"pid", "codigo":"i", "path":"PROC"}
	]
}

var modulo = "End"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	var pid = argumentos["i"]
	HUB.procesos.finalizar(pid)

func descripcion():
	return "Finaliza un programa"

func man():
	var r = "[ END ] - " + descripcion()
	r += "\nUso: end PID"
	r += "\n PID : identificador del programa que se quiere finalizar."
	return r
