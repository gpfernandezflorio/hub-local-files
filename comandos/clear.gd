## Clear
## Comando

# Limpia los mensajes de la terminal.

extends Node

var HUB

var arg_map = {
	"lista":[
		{"nombre":"modo silencioso", "codigo":"s", "validar":"BOOL", "default":false}
	]
}

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	HUB.terminal.borrar_mensajes()
	if not argumentos["s"]:
		HUB.mensaje("Historial borrado")

func descripcion():
	return "Limpia los mensajes de la terminal"

func man():
	var r = "[ CLEAR ] - " + descripcion()
	r += "\nUso: clear [-s]"
	r += "\n s : Modo silencioso."
	return r
