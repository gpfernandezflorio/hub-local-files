## Campo Entrada
## SRC

# Script del campo de entrada de la terminal.

extends LineEdit

var HUB
var modulo = get_parent().modulo
# Historial de mensajes ingresados
var historial = []
# Índice en el historial cuando se explora
var indice_historial = -1

func inicializar(hub):
	HUB = hub
	for hijo in get_children():
		hijo.set_name("__hidden__"+hijo.get_name())
	ventana_escalada(HUB.pantalla.resolucion)
	HUB.eventos.registrar_ventana_escalada(self, "ventana_escalada")
	grab_focus()
	return true

func historial_arriba():
	if (indice_historial < historial.size()-1):
		indice_historial += 1
		set_text(historial[indice_historial])

func historial_abajo():
	if (indice_historial > 0):
		indice_historial -= 1
		set_text(historial[indice_historial])
	elif (indice_historial == 0):
		indice_historial = -1
		set_text("")

func ingresar():
	var texto_ingresado = get_text()
	if (texto_ingresado==""):
		HUB.terminal.cerrar()
	else:
		set_text("")
		if (historial.empty() || texto_ingresado != historial[0]):
			historial.push_front(texto_ingresado)
		indice_historial = -1
		get_parent().ejecutar(texto_ingresado, true)

func ventana_escalada(nueva_resolucion):
	set_pos(Vector2(5, nueva_resolucion.y-25))
	set_size(Vector2(nueva_resolucion.x-10,0))