## Call
## Comando

# Ejecuta un método de un objeto.

extends Node

var HUB

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	if argumentos.size() != 2:
		HUB.mensaje('Error: Espera al menos dos argumentos.')
		return
	var objeto = HUB.objetos.localizar(argumentos[0])
	if objeto == null:
		HUB.mensaje('Error: No se encuentra el objeto "'+ argumentos[0] +'"')
		return

func descripcion():
	return "Ejecuta un método de un objeto"

func man():
	var r = "[ CALL ] - " + descripcion()
	r += "\nUso: call OBJETO METODO [PARAMETRO1 PARAMETRO2 ... PARAMETROn]"
	r += "\n OBJETO : El nombre (path global) del objeto."
	r += "\n METODO : El nombre del método que se quiere ejecutar."
	r += "\n PARAMETROi : El valor del i-ésimo parámetro para pasarle al método."
	return r
