## LUZ
## Objeto
## Funcion

extends Node

var HUB

var lib_map = [
	"HUB3DLang"
]
var arg_map = {
	"lista":[
		{"nombre":"tipo", "codigo":"t", "default":"omni"},
		{"nombre":"radio", "codigo":"r", "default":2, "validar":"NUM;>0"}, # Sólo para omni y spot
		{"nombre":"color", "codigo":"c", "default":Color("ffffff"), "validar":"COLOR"},
		{"nombre":"intensidad", "codigo":"i", "default":1, "validar":"NUM;>0"},
		{"nombre":"atenuación", "codigo":"a", "default":1, "validar":"NUM;>0"}
	]
}
var tipos_validos = ["omni","spot","dir"]

var modulo = "Luz"
var h3 # Biblioteca HUB3DLang

func inicializar(hub):
	HUB = hub
	h3 = lib_map.HUB3DLang
	return null

func gen(argumentos):
	var tipo = argumentos["t"]
	if tipo in tipos_validos:
		var resultado = h3.nueva_luz(tipo)
		resultado.set("params/radius", argumentos["r"])
		resultado.set("params/attenuation", argumentos["a"])
		resultado.set("params/energy", argumentos["i"])
		resultado.set("colors/diffuse", argumentos["c"])
		return resultado
	return HUB.error(HUB.errores.error("Tipo de luz inválido: "+tipo), modulo)

