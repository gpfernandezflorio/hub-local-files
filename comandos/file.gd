## File
## Comando

# Crea un archivo.

extends Node

var HUB

var modulo = "File"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	if argumentos.size() == 0:
		return HUB.error(HUB.errores.error("Espera al menos un argumento."), modulo)
	for argumento in argumentos:
		if argumento.begins_with("-"):
			pass
		var resultado = HUB.archivos.crear("", argumento)
		if HUB.errores.fallo(resultado):
			return HUB.error(HUB.errores.error(
				'No se pudo crear el archivo "' +
				argumento + '".', resultado), modulo)


func descripcion():
	return "Crea un archivo"

func man():
	var r = "[ FILE ] - " + descripcion()
	r += "\nUso: file ARCHIVO1 [ARCHIVO2 ... ARCHIVOn]"
	r += "\n ARCHIVOi : ruta al i-ésimo archivo que se quiere crear."
	return r
