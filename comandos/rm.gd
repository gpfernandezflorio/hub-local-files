## Rm
## Comando

# Elimina un archivo.

extends Node

var HUB

var modulo = "Rm"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	if argumentos.size() == 0:
		return HUB.error(HUB.errores.error("Espera al menos un argumento."), modulo)
	for argumento in argumentos:
		if argumento.begins_with("-"):
			pass
		var resultado = HUB.archivos.borrar("", argumento)
		if HUB.errores.fallo(resultado):
			return HUB.error(HUB.errores.error(
				'No se pudo borrar el archivo "' +
				argumento + '".', resultado), modulo)

func descripcion():
	return "Elimina un archivo"

func man():
	var r = "[ RM ] - " + descripcion()
	r += "\nUso: rm ARCHIVO1 [ARCHIVO2 ... ARCHIVOn]"
	r += "\n ARCHIVOi : ruta al i-ésimo archivo que se quiere borrar."
	return r
