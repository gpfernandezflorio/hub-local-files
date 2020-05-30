## Echo
## Comando

# Escribe un mensaje.

extends Node

var HUB

var arg_map = {
	"obligatorios":1,
	"lista":[
		{"nombre":"texto", "codigo":"t"},
		{"nombre":"archivo", "codigo":"o"}
	]
}

var modulo = "Echo"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	if argumentos["o"]:
		var resultado = HUB.archivos.escribir("", argumentos["o"], argumentos["t"])
		if HUB.errores.fallo(resultado):
			return HUB.error(HUB.errores.error(
				'No se pudo escribir en el archivo "' +
				argumentos["o"] + '".', resultado), modulo)
	else:
		HUB.mensaje(argumentos["t"])

func descripcion():
	return "Escribe un mensaje"

func man():
	var r = "[ ECHO ] - " + descripcion()
	r += "\nUso: echo TEXTO [ARCHIVO]"
	r += "\n TEXTO : mensaje que se quiere escribir."
	r += "\n ARCHIVO : archivo donde guardar el mensaje."
	r += "\n   Si no se le pasa ningún archivo, lo escribe en la terminal"
	return r
