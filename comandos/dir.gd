## Dir
## Comando

# Crea una carpeta.

extends Node

var HUB

var arg_map = {
	"obligatorios":1,
	"lista":[
		{"nombre":"nombre", "codigo":"n"}
	]
}

var modulo = "Dir"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	var resultado = HUB.archivos.crear_carpeta("", argumentos["n"])
	if HUB.errores.fallo(resultado):
		return HUB.error(HUB.errores.error(
			'No se pudo crear la carpeta "' +
			argumentos["n"] + '".', resultado), modulo)


func descripcion():
	return "Crea una carpeta"

func man():
	var r = "[ DIR ] - " + descripcion()
	r += "\nUso: dir CARPETA"
	r += "\n CARPETA : nombre (ruta completa) de la carpeta que se quiere crear."
	return r
