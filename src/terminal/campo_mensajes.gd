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

var pre_usuario = "> "
var pre_entorno = " . "

func inicializar(hub):
	HUB = hub
	for hijo in get_children():
		hijo.set_name("__hidden__"+hijo.get_name())
	ventana_escalada(HUB.pantalla.resolucion)
	set_text("Hi!")
	set_focus_mode(Control.FOCUS_NONE)
	# COLORES -->
	var color_principal = Color(1,1,1)
	var color_fondo = Color(1,1,1,0)
	var color_entorno = Color(.2,.5,.8)
	var color_usuario = Color(.9,.4,.2)
	var color_string = Color(.5,.8,.2)
	var color_sender = Color(.8,.8,.2)
	set_syntax_coloring(true)
#	set_symbol_color(color_principal)#@2
	add_color_override("symbol_color", color_principal)#@3
	for p in ["member_variable","function","symbol","caret_background","selection","caret","breakpoint","font","line_number","completion_font","completion_scroll","number","brace","completion_background","brace_mismatch","completion_selected","mark","word_highlighted","completion_existing"]:
		set("custom_colors/"+p+"_color", color_principal)
#	set_custom_bg_color(color_fondo)#@2
	add_color_override("background_color", color_fondo)#@3
	set("custom_colors/current_line_color", Color(1,1,1,0))
	add_color_region(pre_entorno,"\n", color_entorno, true)
	add_color_region(pre_usuario,"\n", color_usuario, true)
	add_color_region('"','"', color_string, false)
	add_color_region('[',']', color_sender, false)
	# <--
	HUB.eventos.registrar_ventana_escalada(self, "ventana_escalada")
	return true

func mensaje(texto, entorno=""):
	var texto_para_agregar = texto
	if imprimir_entorno and not entorno.empty() and entorno != ultimo_entorno_impreso:
		ultimo_entorno_impreso = entorno
		texto_para_agregar = pre_entorno + entorno + texto_para_agregar
	var texto_completo = get_text()
	if texto_completo == "":
		texto_completo = texto_para_agregar
	else:
		texto_completo += "\n" + texto_para_agregar
	set_text(texto_completo)
	cursor_set_line(get_line_count(), true)

func ventana_escalada(nueva_resolucion):
	set_position(Vector2(5,5))
	set_size(Vector2(nueva_resolucion.x-10,nueva_resolucion.y-35))

func set_hidden(h):#@3
	if h:#@3
		hide()#@3
	else:#@3
		show()#@3
