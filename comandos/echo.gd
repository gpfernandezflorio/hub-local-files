## Echo
## Comando

# Escribe un mensaje.

extends Node

var HUB

var modulo = "Echo"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	if argumentos.size() == 1:
		HUB.mensaje(argumentos[0])
	elif argumentos.size() == 2:
		var resultado = HUB.archivos.escribir("", argumentos[1], argumentos[0])
		if HUB.errores.fallo(resultado):
			return HUB.error(HUB.errores.error(
				'No se pudo escribir en el archivo "' +
				argumentos[0] + '".', resultado), modulo)
	else:
		return HUB.error(HUB.errores.error("Espera al menos un argumento."), modulo)

func descripcion():
	return "Escribe un mensaje"

func man():
	var r = "[ ECHO ] - " + descripcion()
	r += "\nUso: echo TEXTO [ARCHIVO]"
	r += "\n TEXTO : mensaje que se quiere escribir."
	r += "\n ARCHIVO : archivo donde guardar el mensaje."
	r += "\n   Si no se le pasa ningún archivo, lo escribe en la terminal"
	return r
