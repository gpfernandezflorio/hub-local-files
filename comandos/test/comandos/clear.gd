## Test/Comandos/Clear
## Comando

# Testea el comando clear.
# Requiere:
	# -

extends Node

var HUB

func inicializar(hub):
	HUB = hub
	return null

func comando(argumentos):
	HUB.mensaje("Testeando el comando clear")
	HUB.testing.resultado_comando(
		"clear",
		VerificadorMensajesBorrados.new(HUB),
		["Historial borrado"]
	)
	HUB.terminal.log_completo(true)
	HUB.mensaje("Testeando el comando clear en modo silencioso")
	HUB.testing.resultado_comando(
		"clear s",
		VerificadorMensajesBorrados.new(HUB),
		[]
	)
	HUB.terminal.log_completo(true)
	return null

class VerificadorMensajesBorrados:
	var HUB
	func _init(hub):
		HUB = hub
	func verificar(resultado):
		if HUB.errores.fallo(resultado):
			return "El resultado generó un error inesperado."
		if HUB.terminal.campo_mensajes.get_text() == "":
			return ""
		return "El campo de mensajes no está vacío."

func descripcion():
	return "Testea el comando clear"

func man():
	var r = "[ TEST/CLEAR ] - " + descripcion()
	r += "\nUso: test/clear"
	r += "\nIgnora cualquier argumento."
	return r