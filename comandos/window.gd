## Window
## Comando

# Modifica la ventana del HUB.

extends Node

var HUB

var arg_map = {
	"lista":[
		{"nombre":"tamaño", "codigo":"s"}
	]
}

var modulo = "Window"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	var argumento = argumentos["s"]
	if argumento:
		var posicion_x = argumento.find('x')
		if posicion_x == -1:
			return HUB.error(HUB.errores.error('Argumento "'+argumento+'" inválido.'), modulo)
		var ancho_str = argumento.substr(0, posicion_x)
		posicion_x += 1
		var alto_str = argumento.substr(posicion_x, argumento.length() - posicion_x)
		if not ancho_str.is_valid_integer():
			return HUB.error(HUB.errores.error('Valor de ancho de pantalla "'+ancho_str+'" inválido.'), modulo)
		if not alto_str.is_valid_integer():
			return HUB.error(HUB.errores.error('Error: Valor de alto de pantalla "'+alto_str+'" inválido.'), modulo)
		var ancho = int(ancho_str)
		var alto = int(alto_str)
		HUB.pantalla.completa(false)
		HUB.pantalla.tamanio(Vector2(ancho,alto))
	else:
		HUB.pantalla.completa()

func descripcion():
	return "Modifica la ventana del HUB"

func man():
	var r = "[ WINDOW ] - " + descripcion()
	r += "\nUso: window [WIDTHxHEIGHT]"
	r += "\n WIDTH: Ancho de la ventana."
	r += "\n HEIGHT: Alto de la ventana."
	r += "\n Si no se le pasa ningún argumento, activa pantalla completa."
	return r
