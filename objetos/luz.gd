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
		{"nombre":"radio", "codigo":"r", "default":"2", "validar":"NUM;>0"}, # Sólo para omni y spot
		{"nombre":"color", "codigo":"c", "default":"fff"},
		{"nombre":"intensidad", "codigo":"i", "default":"1", "validar":"NUM;>0"}
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
		var color = parsear_color(argumentos["c"])
		if HUB.errores.fallo(color):
			return color
		var resultado = HUB.objetos.crear_componente(tipo)
		resultado.set_name("luz")
		resultado.set("params/radius", argumentos["r"])
		resultado.set("params/energy", argumentos["i"])
		resultado.set("colors/diffuse", color)
		return resultado
	return HUB.error(HUB.errores.error("Tipo de luz inválido: "+tipo), modulo)

func parsear_color(c):
	var s = c
	if s.length() == 3:
		s = c[0]+c[0]+c[1]+c[1]+c[2]+c[2]
	if s.is_valid_html_color():
		return Color(s)
	return HUB.error(HUB.errores.error('Color inválido: '+c), modulo)