## Ls
## Comando

# Lista el contenido de una carpeta.

extends Node

var HUB

var arg_map = {
	"lista":[
		{"nombre":"carpeta", "codigo":"i", "default":"", "path":"ROOT"}
	]
}

var modulo = "Ls"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	var lista = HUB.archivos.listar("", argumentos["i"])
	if HUB.errores.fallo(lista):
		return HUB.error(HUB.errores.error(
			'No se pudo listar el contenido de "' + argumentos["i"] + '".',
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
