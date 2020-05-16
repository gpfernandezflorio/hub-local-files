## Man
## Comando

# Muestra el manual de un comando.

extends Node

var HUB

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	if argumentos.size() == 0:
		HUB.mensaje(manual_general())
		return
	var nodo_comandos = HUB.terminal.nodo_comandos
	for argumento in argumentos:
		var comando = nodo_comandos.cargar(argumento)
		if comando == null:
			HUB.mensaje('Error: Comando "' + argumento + '" desconocido.')
		elif comando.has_method("man"):
			HUB.mensaje(comando.man())
		else:
			HUB.mensaje('Error: El comando "' + argumento + '" no tiene manual.')

func descripcion():
	return "Muestra el manual de un comando"

func man():
	var r = "[ MAN ] - " + descripcion()
	r += "\nUso: man [COMANDO1 COMANDO2 ... COMANDOn]"
	r += "\n COMANDOi : El nombre del i-ésimo comando cuyo manual se quiere leer."
	r += "\n Si no se pasa ningún comando como argumento, se muestra el manual general del HUB."
	return r

func manual_general():
	var r = "[ MANUAL GENERAL ]"
	r += "\n TODO"
	return r
