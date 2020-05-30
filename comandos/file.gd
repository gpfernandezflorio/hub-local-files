## File
## Comando

# Crea un archivo.

extends Node

var HUB

var arg_map = {
	"obligatorios":1,
	"lista":[
		{"nombre":"nombre", "codigo":"n"}
	]
}

var modulo = "File"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	var resultado = HUB.archivos.crear("", argumentos["n"])
	if HUB.errores.fallo(resultado):
		return HUB.error(HUB.errores.error(
			'No se pudo crear el archivo "' +
			argumentos["n"] + '".', resultado), modulo)


func descripcion():
	return "Crea un archivo"

func man():
	var r = "[ FILE ] - " + descripcion()
	r += "\nUso: file ARCHIVO"
	r += "\n ARCHIVO : nombre (ruta completa) del archivo que se quiere crear."
	return r
