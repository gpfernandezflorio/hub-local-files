## Mouse
## Comando

# Cambia el modo de visualización del mouse

extends Node

var HUB

var arg_map = {
	"lista":[
		{"nombre":"modo", "codigo":"m", "validar":"INT;>=0;<=2", "default":0}
	]
}

var modulo = "Mouse"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	HUB.eventos.set_modo_mouse(argumentos["m"])

func descripcion():
	return "Cambia el modo de visualización del mouse"

func man():
	var r = "[ MOUSE ] - " + descripcion()
	r += "\nUso: mouse MODO"
	r += "\n MODO"
	r += "\n   0 (valor por defecto): Normal"
	r += "\n   1: Puntero invisible"
	r += "\n   2: Sin puntero (scroll infinito)"
	return r
