## Cat
## Comando

# Muestra el contenido de un archivo.

extends Node

var HUB

var arg_map = {
	"obligatorios":1,
	"lista":[
		{"nombre":"archivo", "codigo":"i", "path":"ROOT"}
	]
}

var modulo = "Cat"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	var contenido = HUB.archivos.leer("", argumentos["i"])
	if HUB.errores.fallo(contenido):
		HUB.error(HUB.errores.error('No se pudo acceder al archivo "'+ argumentos["i"] +'".', contenido), modulo)
	else:
		HUB.mensaje(contenido)

func descripcion():
	return "Muestra el contenido de un archivo"

func man():
	var r = "[ CAT ] - " + descripcion()
	r += "\nUso: cat ARCHIVO"
	r += "\n ARCHIVO : ruta al archivo que se quiere leer."
	return r
