## Call
## Comando

# Ejecuta un método de un objeto.

extends Node

var HUB

var arg_map = {
	"extra":true,
	"obligatorios":2,
	"lista":[
		{"nombre":"objeto", "codigo":"o"},
		{"nombre":"método", "codigo":"m"}
	]
}

var modulo = "Call"

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	var objeto = HUB.objetos.localizar(argumentos["o"])
	if HUB.errores.fallo(objeto):
		return HUB.error(HUB.errores.error('No se pudo ubicar el objeto "' + argumentos["o"] + '".', objeto), modulo)
	objeto.mensaje(argumentos["m"], argumentos.extra)

func descripcion():
	return "Ejecuta un método de un objeto"

func man():
	var r = "[ CALL ] - " + descripcion()
	r += "\nUso: call OBJETO METODO [PARAMETRO1 PARAMETRO2 ... PARAMETROn]"
	r += "\n OBJETO : El nombre (path global) del objeto."
	r += "\n METODO : El nombre del método que se quiere ejecutar."
	r += "\n PARAMETROi : El valor del i-ésimo parámetro para pasarle al método."
	return r
