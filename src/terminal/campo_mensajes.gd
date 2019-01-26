## Campo Mensajes
## SRC

# Script del campo de mensajes de la terminal.

extends TextEdit

var HUB

func inicializar(hub):
	HUB = hub
	for hijo in get_children():
		hijo.set_name("__hidden__"+hijo.get_name())
	ventana_escalada(HUB.pantalla.resolucion)
	set_text("Hi!")
	set_focus_mode(Control.FOCUS_NONE)
	HUB.eventos.registrar_ventana_escalada(self, "ventana_escalada")
	return true

func mensaje(texto):
	var texto_completo = get_text()
	if texto_completo == "":
		texto_completo = texto
	else:
		texto_completo += "\n" + str(texto)
	set_text(texto_completo)

func ventana_escalada(nueva_resolucion):
	set_pos(Vector2(5,5))
	set_size(Vector2(250,nueva_resolucion.y-35))