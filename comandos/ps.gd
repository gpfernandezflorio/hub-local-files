## PS
## Comando

# Lista los programas activos.

extends Node

var HUB

var arg_map = {
	"lista":[
	]
}

var modulo = "PS"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	for p in HUB.procesos.todos():
		HUB.mensaje(p)

func descripcion():
	return "Finaliza un programa"

func man():
	var r = "[ END ] - " + descripcion()
	r += "\nUso: end PID"
	r += "\n PID : identificador del programa que se quiere finalizar."
	return r
