## BODY
## Objeto
## Funcion

extends Node

var HUB

var lib_map = [
	"HUB3DLang"
]
var arg_map = {
	"lista":[
		{"nombre":"tipo", "codigo":"t", "default":"static"}
	]
}
var tipos_validos = {
	"static":StaticBody,
	"kinematic":KinematicBody
}

var modulo = "Body"
var h3 # Biblioteca HUB3DLang

func inicializar(hub):
	HUB = hub
	h3 = lib_map.HUB3DLang
	return null

func gen(argumentos):
	var tipo = argumentos["t"]
	if tipo in tipos_validos.keys():
		var resultado = tipos_validos[tipo].new()
		resultado.set_name("body")
		return resultado
	return HUB.error(HUB.errores.error("Tipo de body inválido: "+tipo), modulo)