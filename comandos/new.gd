## New
## Comando

# Crea un nuevo objeto.
# Requiere:
	# Biblioteca HUB3DLang

extends Node

var HUB
var HUB3DLang

var arg_map = {
	"lista":[
		{"nombre":"que", "codigo":"i", "default":""}
	]
}

var modulo = "New"

func inicializar(hub):
	HUB = hub
	HUB3DLang = HUB.bibliotecas.importar("HUB3DLang")
	if HUB.errores.fallo(HUB3DLang):
		return HUB.error(HUB.errores.inicializar_fallo(self, HUB3DLang), modulo)
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
