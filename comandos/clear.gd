## Clear
## Comando

# Limpia los mensajes de la terminal.

extends Node

var HUB

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	HUB.terminal.borrar_mensajes()
	if (argumentos.size() != 1 || argumentos[0] != "s"):
		HUB.mensaje("Historial borrado")

func descripcion():
	return "Limpia los mensajes de la terminal"

func man():
	var r = "[ CLEAR ] - " + descripcion()
	r += "\nUso: clear [s]"
	r += "\n s : Modo silencioso."
	return r
