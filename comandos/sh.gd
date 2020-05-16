## Sh
## Comando

# Ejecuta un archivo de comandos.

extends Node

var HUB

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	if argumentos.size() == 0:
		HUB.mensaje("Error: Espera al menos un argumento.")
		return
	var verbose = false
	for argumento in argumentos:
		if argumento.begins_with("-"):
			pass
		elif not argumento.ends_with(".gd"):
			argumento += ".gd"
		var contenido = HUB.archivos.leer("shell/", argumento)
		if contenido == null:
			HUB.mensaje('Error: No se encuentra el archivo "'+ argumento +'"')
		else:
			for linea in contenido.split("\n"):
				if not (linea.empty() or linea.begins_with("#")):
					var comando = linea.split("#")[0]
					HUB.terminal.ejecutar(comando, verbose)

func descripcion():
	return "Ejecuta un archivo de comandos"

func man():
	var r = "[ SH ] - " + descripcion()
	r += "\nUso: sh ARCHIVO1 [ARCHIVO2 ... ARCHIVOn]"
	r += "\n ARCHIVOi : ruta al archivo que contiene la i-ésima secuencia de comandos a ejecutar."
	return r
