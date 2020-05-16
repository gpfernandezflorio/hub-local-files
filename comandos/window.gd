## Window
## Comando

# Modifica la ventana del HUB.

extends Node

var HUB

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	if argumentos.size() == 0:
		HUB.pantalla.completa()
		return
	var posicion_x = argumentos[0].find('x')
	if posicion_x == -1:
		HUB.mensaje('Error: Argumento "'+argumentos[0]+'" inválido.')
		return
	var ancho_str = argumentos[0].substr(0, posicion_x)
	posicion_x += 1
	var alto_str = argumentos[0].substr(posicion_x, argumentos[0].length() - posicion_x)
	var ancho = int(ancho_str)
	if str(ancho) != ancho_str:
		HUB.mensaje('Error: Valor de ancho de pantalla "'+ancho_str+'" inválido.')
		return
	var alto = int(alto_str)
	if str(alto) != alto_str:
		HUB.mensaje('Error: Valor de alto de pantalla "'+alto_str+'" inválido.')
		return
	HUB.pantalla.completa(false)
	HUB.pantalla.tamanio(Vector2(ancho,alto))

func descripcion():
	return "Modifica la ventana del HUB"

func man():
	var r = "[ WINDOW ] - " + descripcion()
	r += "\nUso: window [WIDTHxHEIGHT]"
	r += "\n WIDTH: Ancho de la ventana."
	r += "\n HEIGHT: Alto de la ventana."
	r += "\n Si no se le pasa ningún argumento, activa pantalla completa."
	return r
