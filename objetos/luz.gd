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
		{"nombre":"radio", "codigo":"r", "default":"2", "validar":"NUM;>0"} # Sólo para omni y spot
	]
}
var tipos_validos = {
	"omni":OmniLight,
	"spot":SpotLight,
	"dir":DirectionalLight
}

var modulo = "Luz"
var h3 # Biblioteca HUB3DLang

func inicializar(hub):
	HUB = hub
	h3 = lib_map.HUB3DLang
	return null

func gen(argumentos):
	var tipo = argumentos["t"]
	if tipo in tipos_validos.keys():
		var resultado = tipos_validos[tipo].new()
		resultado.set_name("luz")
		resultado.set("params/radius", argumentos["r"])
		return resultado
	return HUB.error(HUB.errores.error("Tipo de luz inválido: "+tipo), modulo)