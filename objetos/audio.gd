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
		{"nombre":"volumen", "codigo":"v", "default":3, "validar":"NUM"},
		{"nombre":"loop", "codigo":"l", "default":false, "validar":"BOOL"}
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
	resultado.set("volumen", argumentos["v"])
	return resultado