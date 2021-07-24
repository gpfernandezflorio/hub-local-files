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
var nodo_comandos

func inicializar(hub):
	HUB = hub
	for hijo in get_children():
		hijo.set_name("__hidden__"+hijo.get_name())
	ventana_escalada(HUB.pantalla.resolucion)
	HUB.eventos.registrar_ventana_escalada(self, "ventana_escalada")
	nodo_comandos = get_parent().nodo_comandos
	grab_focus()
	return true

#func set_cursor_pos(i):#@3
#	caret_position = i#@3

#func get_cursor_pos():#@3
#	return caret_position#@3

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
	var pos_cursor = get_cursor_pos()
	var resto = todo_el_texto.right(pos_cursor)
	todo_el_texto = todo_el_texto.left(pos_cursor)
	var argumentos = get_parent().parsear_argumentos(todo_el_texto)
	if todo_el_texto.empty() or todo_el_texto.ends_with(" "):
		argumentos.push_back("")
	var preludio = argumentos[argumentos.size()-1]
	var inicio = todo_el_texto
	if not preludio.empty():
		inicio = todo_el_texto.left(todo_el_texto.find_last(preludio)-1)
	var arg_pre = ""
	var i_igual = preludio.find("=")
	if i_igual != -1:
		arg_pre = preludio.left(i_igual+1)
		preludio = preludio.right(i_igual+1)
	elif preludio.begins_with("-"):
		arg_pre = preludio.left(2)
		preludio = preludio.right(2)
	var ultima_diagonal = preludio.find_last("/")
	var carpeta = preludio.substr(0,ultima_diagonal+1)
	if ultima_diagonal != -1:
		preludio = preludio.right(ultima_diagonal+1)
	var posibilidades = []
	if inicio.empty(): # Estoy escribiendo el comando
		posibilidades = posibilidades_por_argumento("CMD", carpeta, preludio)
	else:
		posibilidades = posibilidades_por_comando_por_argumento(carpeta, argumentos, preludio)
		if not inicio.ends_with(" "):
			inicio += " "
	if HUB.errores.fallo(posibilidades):
		return posibilidades
	if posibilidades.size() == 1:
		i_igual = preludio.find("=")
		var opt = posibilidades[0]
		if (carpeta+opt).find(" ") != -1 and not inicio.ends_with('"'):
			inicio += '"'
			if not opt.ends_with("/"):
				opt += '"'
		if not opt.ends_with("/"):
			opt += " "
		var autocompletado = \
			carpeta + \
			opt
		inicio += arg_pre
		set_text(inicio + autocompletado + resto)
		set_cursor_pos(inicio.length() + autocompletado.length())
	elif posibilidades.size() > 1:
		var msg = ""
		for archivo in posibilidades:
			msg += " " + archivo
		HUB.mensaje(msg)

func posibilidades_por_comando_por_argumento(carpeta, todo_el_texto, preludio):
	var comando = todo_el_texto[0]
	if not nodo_comandos.comando_valido(comando):
		return []
	var nodo = nodo_comandos.cargar(comando)
	if not "arg_map" in nodo:
		return []
	var arg_map = nodo.arg_map.lista
	todo_el_texto.remove(0)
	var argumentos = HUB.varios.parsear_argumentos_comandos(nodo, todo_el_texto)
	if argumentos == null:
		return []
	var arg_real = preludio
	if not carpeta.empty():
		arg_real = carpeta.plus_file(preludio)
	for a in argumentos:
		var arg = str(argumentos[a])
		for b in arg_map:
			if b.codigo == a and (arg == arg_real):
				if "path" in b:
					return posibilidades_por_argumento(b["path"], carpeta, arg)
	return []

func posibilidades_por_argumento(filtro, carpeta, preludio):
	if filtro == "OBJ":
		return posibilidades_OBJ(preludio)
	if filtro == "HOBJ":
		return posibilidades_HOBJ(preludio)
	if filtro == "PROC":
		return posibilidades_PROC(preludio)
	var incluir_extension = true
	if filtro == "ROOT":
		filtro = ""
	elif filtro in ["RUN","CMD","SH"]:
		incluir_extension = false
		if filtro == "RUN":
			filtro = "programas"
		elif filtro == "CMD":
			filtro = "comandos"
		elif filtro == "SH":
			filtro = "shell"
	if HUB.archivos.existe_directorio(filtro, carpeta):
		var posibilidades = HUB.archivos.listar(filtro, carpeta)
		if HUB.errores.fallo(posibilidades):
			return posibilidades
		posibilidades = filtrar_posibilidades_ruta(filtro, preludio, carpeta, posibilidades, incluir_extension)
		return posibilidades
	return []

func filtrar_posibilidades_ruta(ruta, preludio, carpeta, posibilidades, incluir_extension):
	var archivos_posibles = []
	for archivo in posibilidades:
		var opt = archivo
		if not carpeta.empty():
			opt = carpeta.plus_file(archivo)
		if opt.begins_with(preludio):
			if HUB.archivos.es_archivo(ruta.plus_file(carpeta), archivo):
				opt = archivo
				if not incluir_extension:
					opt = archivo.split(".")[0]
				if incluir_extension or (not incluir_extension and archivo.ends_with(".gd")):
					archivos_posibles.append(opt)
			elif HUB.archivos.es_directorio(ruta.plus_file(carpeta), archivo):
				archivos_posibles.append(archivo+"/")
	return archivos_posibles

func posibilidades_OBJ(preludio):
	var nombre = preludio
	var padre
	var ultima_diagonal = preludio.find_last("/")
	if ultima_diagonal != -1:
		nombre = preludio.right(ultima_diagonal+1)
		var nombre_padre = preludio.left(ultima_diagonal)
		if HUB.objetos.existe(nombre_padre):
			padre = HUB.objetos.localizar(nombre_padre)
		else:
			return []
	else:
		padre = HUB.nodo_usuario.mundo
	var hijos = []
	for hijo in padre.hijos():
		if hijo.nombre() == nombre and not hijo.hijos().empty():
			return [hijo.nombre()+"/"]
		if hijo.nombre().begins_with(nombre):
			hijos.append(hijo.nombre())
	return hijos

func posibilidades_HOBJ(preludio):
	var nombre = preludio
	var padre
	var ultima_diagonal = preludio.find_last("/")
	if ultima_diagonal != -1:
		nombre = preludio.right(ultima_diagonal+1)
		var nombre_padre = preludio.left(ultima_diagonal)
		padre = get_node(str(HUB.get_path()).plus_file(nombre_padre))
		if padre == null:
			return []
	else:
		padre = get_node(str(HUB.get_path()))
	var hijos = []
	for hijo in padre.get_children():
		if hijo.get_name() == nombre and not hijo.get_children().empty():
			return [hijo.get_name()+"/"]
		if hijo.get_name().begins_with(nombre):
			hijos.append(hijo.get_name())
	return hijos

func posibilidades_PROC(preludio):
	var ps = []
	for p in HUB.procesos.todos():
		if p!="HUB" and p.begins_with(preludio):
			ps.append(p)
	return ps

func ventana_escalada(nueva_resolucion):
	set_pos(Vector2(5, nueva_resolucion.y-25))
	set_size(Vector2(nueva_resolucion.x-10,0))

#func set_hidden(h):#@3
#	if h:#@3
#		hide()#@3
#	else:#@3
#		show()#@3
