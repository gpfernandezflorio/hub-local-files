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
	var coordenadas = HUB.varios.coordenadas_cubo(argumentos["w"],argumentos["h"],argumentos["p"], h3, tipos, true)
	if HUB.errores.fallo(coordenadas):
		return coordenadas
	var x0 = coordenadas[0]
	var x1 = coordenadas[1]
	var y0 = coordenadas[2]
	var y1 = coordenadas[3]
	var z0 = coordenadas[4]
	var z1 = coordenadas[5]
	var resultado = h3.nuevo_mesh_rep([
		Vector3(x0,y0,z0),Vector3(x1,y0,z0),Vector3(x1,y0,z1),Vector3(x0,y0,z1),
		Vector3(x0,y1,z0),Vector3(x1,y1,z0),Vector3(x1,y1,z1),Vector3(x0,y1,z1)
	],[
		h3.nueva_cara([3,2,6,7]),h3.nueva_cara([0,3,7,4]),h3.nueva_cara([1,5,6,2]),
		h3.nueva_cara([0,4,5,1]),h3.nueva_cara([0,1,2,3]),h3.nueva_cara([7,6,5,4])
	])
	return resultado