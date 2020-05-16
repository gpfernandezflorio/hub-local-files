## Kill
## Comando

# Elimina un objeto.

extends Node

var HUB

var modulo = "Kill"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	if argumentos.size() != 1:
		return HUB.error(HUB.errores.error("Espera exactamente un argumento."), modulo)
	var resultado = HUB.objetos.borrar(argumentos[0])
	if HUB.errores.fallo(resultado):
		return HUB.error(HUB.errores.error("Comando fallido", resultado), modulo)
	return ""

func descripcion():
	return "Elimina un objeto"

func man():
	var r = "[ KILL ] - " + descripcion()
	r += "\nUso: kill OBJETO"
	r += "\n OBJETO : El nombre (path global) del objeto."
	return r