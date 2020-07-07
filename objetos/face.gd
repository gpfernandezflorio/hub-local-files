## FACE
## Objeto
## Funcion

extends Node

var HUB

var lib_map = [
	"HUB3DLang",
	"tipos"
]
var arg_map = {
	"lista":[
		{"nombre":"ancho", "codigo":"w", "default":"!1"},
		{"nombre":"alto", "codigo":"h", "default":"!1"},
		{"nombre":"eje", "codigo":"a", "default":"y",}
	]
}

var h3 # Biblioteca HUB3DLang
var tipos # Biblioteca tipos

func inicializar(hub):
	HUB = hub
	h3 = lib_map.HUB3DLang
	tipos = lib_map.tipos
	return null

func gen(argumentos):
	var w = argumentos["w"]
	var h = argumentos["h"]
	var eje = argumentos["a"]
	var center_x = false
	var center_y = false
	# ANCHO
	if tipos.es_un_string(w):
		if w.begins_with("!"):
			center_x = true
			w = HUB.varios.str_desde(w, 1)
		if w.is_valid_float():
			w = float(w)
		elif h3.esta_definido(w):
			w = h3.obtener(w)
		else:
			return HUB.error(h3.identificador_invalido(w), h3.modulo)
	# ALTO
	if tipos.es_un_string(h):
		if h.begins_with("!"):
			center_y = true
			h = HUB.varios.str_desde(h, 1)
		if h.is_valid_float():
			h = float(h)
		elif h3.esta_definido(h):
			h = h3.obtener(h)
		else:
			return HUB.error(h3.identificador_invalido(h), h3.modulo)
	# Posiciones sobre el plano
	var x0 = 0.0
	var x1 = w
	var y0 = 0.0
	var y1 = h
	if center_x:
		x1 *= 0.5
		x0 -= x1
	if center_y:
		y1 *= 0.5
		y0 -= y1
	var vertexes = null
	var invert = false
	if eje.begins_with("-"):
		invert = true
		eje = HUB.varios.str_desde(eje, 1)
	if eje.begins_with("x"):
		vertexes = [Vector3(0,y0,x0),Vector3(0,y1,x0),Vector3(0,y1,x1),Vector3(0,y0,x1)]
	elif eje.begins_with("y"):
		vertexes = [Vector3(x0,0,y0),Vector3(x0,0,y1),Vector3(x1,0,y1),Vector3(x1,0,y0)]
	elif eje.begins_with("z"):
		vertexes = [Vector3(x1,y0,0),Vector3(x1,y1,0),Vector3(x0,y1,0),Vector3(x0,y0,0)]
	else:
		return HUB.error(HUB.errores.error('eje "' + argumentos["a"] + '" inválido'), h3.modulo)
	if invert:
		var tmp = vertexes[1]
		vertexes[1] = vertexes[3]
		vertexes[3] = tmp
	var resultado = h3.nuevo_mesh_rep(
		vertexes,
		[h3.nueva_cara([0,1,2,3], [])],
		[],
		"cara"
	)
	var rotacion = float(HUB.varios.str_desde(eje, 1))
	resultado.call("rotate_"+eje[0], rotacion)
	return resultado
