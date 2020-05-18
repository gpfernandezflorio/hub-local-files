## Cat
## Comando

# Muestra el contenido de un archivo.

extends Node

var HUB

var modulo = "Cat"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	if argumentos.size() == 0:
		return HUB.error(HUB.errores.error("Espera al menos un argumento."), modulo)
	for argumento in argumentos:
		if argumento.begins_with("-"):
			pass
		var contenido = HUB.archivos.leer("", argumento)
		if HUB.errores.fallo(contenido):
			HUB.error(HUB.errores.error('No se pudo acceder al archivo "'+ argumento +'".', contenido), modulo)
		else:
			HUB.mensaje(contenido)

func descripcion():
	return "Muestra el contenido de un archivo"

func man():
	var r = "[ CAT ] - " + descripcion()
	r += "\nUso: cat ARCHIVO1 [ARCHIVO2 ... ARCHIVOn]"
	r += "\n ARCHIVOi : ruta al i-ésimo archivo que se quiere leer."
	return r
