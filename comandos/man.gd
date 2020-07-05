## Man
## Comando

# Muestra el manual de un comando.

extends Node

var HUB

var arg_map = {
	"lista":[
		{"nombre":"comando", "codigo":"i", "default":"", "path":"CMD"}
	]
}

var modulo = "Man"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	var nombre = argumentos["i"]
	if nombre.empty():
		HUB.mensaje(manual_general())
		return
	var nodo_comandos = HUB.terminal.nodo_comandos
	var comando = nodo_comandos.cargar(nombre)
	if HUB.errores.fallo(comando):
		return HUB.error(HUB.errores.error('No se puede mostrar el manual de "' + nombre + '".', comando), modulo)
	elif comando.has_method("man"):
		HUB.mensaje(comando.man())
	else:
		return HUB.error(HUB.errores.error('El comando "' + nombre + '" no tiene manual.', comando), modulo)

func descripcion():
	return "Muestra el manual de un comando"

func man():
	var r = "[ MAN ] - " + descripcion()
	r += "\nUso: man [COMANDO]"
	r += "\n COMANDO : El nombre del comando cuyo manual se quiere leer."
	r += "\n Si no se pasa ningún comando como argumento, se muestra el manual general del HUB."
	return r

func manual_general():
	var r = "[ MANUAL GENERAL ]"
	r += "\n TODO"
	return r
