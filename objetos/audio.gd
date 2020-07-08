## Audio
## Objeto
## Funcion

extends Node

var HUB

var lib_map = [
	"HUB3DLang"
]
var arg_map = {
	"obligatorios":1,
	"lista":[
		{"nombre":"fuentes", "codigo":"i", "validar":"ARR"},
		{"nombre":"loop", "codigo":"l", "default":false, "validar":"BOOL"}
	#	{"nombre":"tipo", "codigo":"t", "default":"omni"},
	#	{"nombre":"radio", "codigo":"r", "default":2, "validar":"NUM;>0"}, # Sólo para omni y spot
	#	{"nombre":"color", "codigo":"c", "default":Color("ffffff"), "validar":"COLOR"},
	#	{"nombre":"intensidad", "codigo":"i", "default":1, "validar":"NUM;>0"},
	#	{"nombre":"atenuación", "codigo":"a", "default":1, "validar":"NUM;>0"}
	]
}

var modulo = "Audio"
var h3 # Biblioteca HUB3DLang

func inicializar(hub):
	HUB = hub
	h3 = lib_map.HUB3DLang
	return null

func gen(argumentos):
	var resultado = h3.nuevo_audio()
	resultado.set("sonidos", argumentos["i"])
	resultado.set("loop", argumentos["l"])
	return resultado