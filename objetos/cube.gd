## CUBE
## Objeto
## Funcion

extends Node

var HUB

var lib_map = [
	"HUB3DLang"
]
var arg_map = {
	"lista":[
		{"nombre":"ancho", "codigo":"w", "default":"!1"},
		{"nombre":"alto", "codigo":"h", "default":"1"},
		{"nombre":"profundidad", "codigo":"p", "default":"!1"}
	]
}

var h3 # Biblioteca HUB3DLang

func inicializar(hub):
	HUB = hub
	h3 = lib_map.HUB3DLang
	return null

func gen(argumentos):
	var resultado = h3.nuevo_mesh_rep([
		Vector3(0,0,0),Vector3(1,0,0),Vector3(1,0,1),Vector3(0,0,1),
		Vector3(0,1,0),Vector3(1,1,0),Vector3(1,1,1),Vector3(0,1,1)
	],[
		h3.nueva_cara([3,2,6,7]),h3.nueva_cara([0,3,7,4]),h3.nueva_cara([1,5,6,2]),
		h3.nueva_cara([0,4,5,1]),h3.nueva_cara([0,1,2,3]),h3.nueva_cara([7,6,5,4])
	])
	return resultado