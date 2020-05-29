## Hide
## Comando

# Esconde la terminal.

extends Node

var HUB

var arg_map = {
	"lista":[
		{"nombre":"modo", "codigo":"m", "validar":"INT;>=0;<=5", "default":"0"}
	]
}

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	var modo = argumentos["m"]
	HUB.terminal.cerrar(modo)

func descripcion():
	return "Esconde la terminal"

func man():
	var r = "[ HIDE ] - " + descripcion()
	r += "\nUso: hide [MODO]"
	r += "\n MODO"
	r += "\n   0 (valor por defecto): Oculta toda la terminal"
	r += "\n   1: Muestra la terminal"
	r += "\n   2: Oculta el campo de mensajes pero no el campo de entrada"
	r += "\n   3: Como el anterior pero si salta un error se abre"
	r += "\n   4: Muestra la terminal pero la cierra tras ejecutar un comando"
	r += "\n   5: Oculta la terminal pero si salta un error la abre"
	return r
