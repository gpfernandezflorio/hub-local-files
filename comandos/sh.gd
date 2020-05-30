## Sh
## Comando

# Ejecuta un archivo de comandos.

extends Node

var HUB

var arg_map = {
	"obligatorios":1,
	"lista":[
		{"nombre":"archivo", "codigo":"i"},
		{"nombre":"modo silencioso", "codigo":"s", "validar":"BOOL", "default":false}
	]
}

var modulo = "Sh"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	var archivo = argumentos["i"]
	if not archivo.ends_with(".gd"):
		archivo += ".gd"
	var contenido = HUB.archivos.leer("shell/", archivo)
	if HUB.errores.fallo(contenido):
		HUB.error(HUB.errores.error('No se pudo ejecutar el script "'+ archivo +'"', contenido), modulo)
	else:
		for linea in contenido.split("\n"):
			if not (linea.empty() or linea.begins_with("#")):
				var comando = linea.split("#")[0]
				HUB.terminal.ejecutar(comando, not argumentos["s"])

func descripcion():
	return "Ejecuta un archivo de comandos"

func man():
	var r = "[ SH ] - " + descripcion()
	r += "\nUso: sh ARCHIVO [-s]"
	r += "\n ARCHIVO : ruta al archivo que contiene la secuencia de comandos a ejecutar."
	r += "\n s : Modo silencioso."
	return r
