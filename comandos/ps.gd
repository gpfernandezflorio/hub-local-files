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
	var actual = HUB.procesos.actual_pid()
	for p in HUB.procesos.todos():
		var m = p
		if p == actual:
			m = "[" + m + "]"
		HUB.mensaje(m)

func descripcion():
	return "Lista los programas activos"

func man():
	var r = "[ PS ] - " + descripcion()
	r += "\nUso: ps"
	r += "\nIgnora cualquier argumento."
	return r
