## Rm
## Comando

# Elimina un archivo.

extends Node

var HUB

var arg_map = {
	"obligatorios":1,
	"lista":[
		{"nombre":"carpeta", "codigo":"n"}
	]
}

var modulo = "Rm"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	var resultado = HUB.archivos.borrar("", argumentos["n"])
	if HUB.errores.fallo(resultado):
		return HUB.error(HUB.errores.error(
			'No se pudo borrar el archivo "' +
			argumentos["n"] + '".', resultado), modulo)

func descripcion():
	return "Elimina un archivo"

func man():
	var r = "[ RM ] - " + descripcion()
	r += "\nUso: rm ARCHIVO "
	r += "\n ARCHIVO : ruta al archivo que se quiere borrar."
	return r
