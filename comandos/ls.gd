## Ls
## Comando

# Lista el contenido de una carpeta.

extends Node

var HUB

var modulo = "Ls"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	if argumentos.size() == 0:
		argumentos = [""]
	for argumento in argumentos:
		if argumento.begins_with("-"):
			pass
		var lista = HUB.archivos.listar("", argumento)
		if HUB.errores.fallo(lista):
			return HUB.error(HUB.errores.error(
				'No se pudo listar el contenido de "' + argumento + '".',
				lista), modulo)
		for archivo in lista:
			HUB.mensaje(archivo)

func descripcion():
	return "Lista el contenido de una carpeta"

func man():
	var r = "[ LS ] - " + descripcion()
	r += "\nUso: ls [DIR]"
	r += "\n DIR : ruta a la carpeta cuyo contenido se quiere listar."
	r += "\n   Por defecto, es la ruta raiz."
	return r
