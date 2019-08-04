## Campo Mensajes
## SRC

# Script del campo de mensajes de la terminal.

extends TextEdit

var HUB
var modulo = get_parent().modulo
# Guardo el último entorno impreso para no repetir
var ultimo_entorno_impreso = ""
# Indica si al mandar un mensaje se debe imprimir también el entorno de ejecución
var imprimir_entorno = true

func inicializar(hub):
	HUB = hub
	for hijo in get_children():
		hijo.set_name("__hidden__"+hijo.get_name())
	ventana_escalada(HUB.pantalla.resolucion)
	set_text("Hi!")
	set_focus_mode(Control.FOCUS_NONE)
	HUB.eventos.registrar_ventana_escalada(self, "ventana_escalada")
	return true

func mensaje(texto, entorno=""):
	var texto_para_agregar = texto
	if imprimir_entorno and not entorno.empty() and entorno != ultimo_entorno_impreso:
		ultimo_entorno_impreso = entorno
		texto_para_agregar = entorno + texto_para_agregar
	var texto_completo = get_text()
	if texto_completo == "":
		texto_completo = texto_para_agregar
	else:
		texto_completo += "\n" + texto_para_agregar
	set_text(texto_completo)
	cursor_set_line(get_line_count(), true)

func ventana_escalada(nueva_resolucion):
	set_pos(Vector2(5,5))
	set_size(Vector2(nueva_resolucion.x-10,nueva_resolucion.y-35))