## Run
## Comando

# Ejecuta un programa.

extends Node

var HUB

var arg_map = {
	"obligatorios":1,
	"lista":[
		{"nombre":"archivo", "codigo":"i", "path":"RUN"}
	]
}

var modulo = "Run"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	var archivo = argumentos["i"]
	HUB.procesos.nuevo(archivo)

func descripcion():
	return "Ejecuta un programa"

func man():
	var r = "[ RUN ] - " + descripcion()
	r += "\nUso: run PROGRAMA"
	r += "\n PROGRAMA : ruta al script de programa que se quiere ejecutar (sin la extensión)."
	return r
