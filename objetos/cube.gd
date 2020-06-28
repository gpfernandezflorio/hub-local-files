## CUBE
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
		{"nombre":"alto", "codigo":"h", "default":"1"},
		{"nombre":"profundidad", "codigo":"p", "default":"!1"}
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
	var p = argumentos["p"]
	var center_x = false
	var center_y = false
	var center_z = false
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
	# PROF.
	if tipos.es_un_string(p):
		if p.begins_with("!"):
			center_z = true
			p = HUB.varios.str_desde(p, 1)
		if p.is_valid_float():
			p = float(h)
		elif h3.esta_definido(p):
			p = h3.obtener(p)
		else:
			return HUB.error(h3.identificador_invalido(p), h3.modulo)
	# Posiciones sobre el plano
	var x0 = 0.0
	var x1 = w
	var y0 = 0.0
	var y1 = h
	var z0 = 0.0
	var z1 = p
	if center_x:
		x1 *= 0.5
		x0 -= x1
	if center_y:
		y1 *= 0.5
		y0 -= y1
	if center_z:
		z1 *= 0.5
		z0 -= z1
	var resultado = h3.nuevo_mesh_rep([
		Vector3(x0,y0,z0),Vector3(x1,y0,z0),Vector3(x1,y0,z1),Vector3(x0,y0,z1),
		Vector3(x0,y1,z0),Vector3(x1,y1,z0),Vector3(x1,y1,z1),Vector3(x0,y1,z1)
	],[
		h3.nueva_cara([3,2,6,7]),h3.nueva_cara([0,3,7,4]),h3.nueva_cara([1,5,6,2]),
		h3.nueva_cara([0,4,5,1]),h3.nueva_cara([0,1,2,3]),h3.nueva_cara([7,6,5,4])
	])
	return resultado