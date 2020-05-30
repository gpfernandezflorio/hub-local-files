## New
## Comando

# Crea un nuevo objeto.
# Requiere:
	# Biblioteca HUB3DLang

extends Node

var HUB

var lib_map = [
	"HUB3DLang"
]
var arg_map = {
	"lista":[
		{"nombre":"que", "codigo":"i", "default":""}
	]
}

var modulo = "New"
var HUB3DLang

func inicializar(hub):
	HUB = hub
	HUB3DLang = lib_map["HUB3DLang"]
	return null

func comando(argumentos):
	var que = argumentos["i"]
	if que.empty():
		return HUB.objetos.crear()
	return HUB3DLang.parsear(que)

func descripcion():
	return "Crea un nuevo objeto"

func man():
	var r = "[ NEW ] - " + descripcion()
	r += "\nUso: new [QUE]"
	r += "\n QUE : Descripción del objeto a crear en el lenguaje HUB3DLang."
	r += "\n   Si no se le pasa ningún argumento, crea un objeto vacío."
	return r
