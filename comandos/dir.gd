## Dir
## Comando

# Crea una carpeta.

extends Node

var HUB

var modulo = "Dir"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	if argumentos.size() == 0:
		return HUB.error(HUB.errores.error("Espera al menos un argumento."), modulo)
	for argumento in argumentos:
		if argumento.begins_with("-"):
			pass
		var resultado = HUB.archivos.crear_carpeta("", argumento)
		if HUB.errores.fallo(resultado):
			return HUB.error(HUB.errores.error(
				'No se pudo crear la carpeta "' +
				argumento + '".', resultado), modulo)


func descripcion():
	return "Crea una careta"

func man():
	var r = "[ DIR ] - " + descripcion()
	r += "\nUso: file ARCHIVO1 [ARCHIVO2 ... ARCHIVOn]"
	r += "\n ARCHIVOi : ruta a la i-ésima carpeta que se quiere crear."
	return r
