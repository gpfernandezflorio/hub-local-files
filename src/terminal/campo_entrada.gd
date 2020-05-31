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
		set_cursor_pos(historial[indice_historial].length())

func historial_abajo():
	if (indice_historial > 0):
		indice_historial -= 1
		set_text(historial[indice_historial])
		set_cursor_pos(historial[indice_historial].length())
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

func autocompletar():
	var todo_el_texto = get_text()
	var ultimo_espacio = todo_el_texto.find_last(" ")
	var inicio = todo_el_texto.substr(0,ultimo_espacio)
	if not inicio.empty():
		inicio += " "
	var preludio = todo_el_texto.substr(ultimo_espacio+1,get_cursor_pos())
	var ultima_diagonal = preludio.find_last("/")
	var carpeta = preludio.substr(0,ultima_diagonal+1)
	var archivos = HUB.archivos.listar("comandos/", carpeta)
	if HUB.errores.fallo(archivos):
		return archivos
	if ultima_diagonal != -1:
		preludio = preludio.substr(ultima_diagonal+1,preludio.length())
	var archivos_posibles = []
	for archivo in archivos:
		if archivo.begins_with(preludio):
			if archivo.ends_with(".gd"):
				archivos_posibles.append(archivo.substr(0,archivo.length()-3)+" ")
			elif HUB.archivos.es_directorio("comandos/" + carpeta, archivo):
				archivos_posibles.append(archivo+"/")
	if archivos_posibles.size() == 1:
		var autocompletado = \
			carpeta + \
			archivos_posibles[0]
		var resto = todo_el_texto.substr(get_cursor_pos(),todo_el_texto.length())
		set_text(inicio + autocompletado + resto)
		set_cursor_pos(inicio.length() + autocompletado.length())
	elif archivos_posibles.size() > 1:
		var msg = ""
		for archivo in archivos_posibles:
			msg += " " + archivo
		HUB.mensaje(msg)

func ventana_escalada(nueva_resolucion):
	set_pos(Vector2(5, nueva_resolucion.y-25))
	set_size(Vector2(nueva_resolucion.x-10,0))
