## Terminal
## SRC

# Maneja la terminal del HUB.
# Requiere para inicializar:
	# HUB.hub_src
	# HUB.archivos
		# abrir
	# HUB.pantalla
		# resolucion
	# HUB.eventos
		# registrar_press
		# registrar_ventana_escalada
	# src/terminal/campo_entrada.gd
	# src/terminal/campo_mensajes.gd
	# src/terminal/comandos.gd

extends Node

var HUB
var modulo = "TERMINAL"
# Ruta a la carpeta de archivos fuente de la terminal
var carpeta_src = "terminal"

# Campo para ingresar comandos
var campo_entrada = LineEdit.new()
# Campo para mostrar los mensajes del HUB
var campo_mensajes = TextEdit.new()
# Nodo para ejecutar comandos
var nodo_comandos = Node.new()

# Indica el modo de visibilidad de la terminal
var modo_visible = 1
	# 0 invisible
	# 1 visible
	# 2 sólo el campo de entrada
	# 3 sólo el campo de entrada pero abre todo si salta un error
	# 4 visible pero se oculta tras lanzar un comando
	# 5 invisible pero se abre si salta un error
# Log de mensajes
var log_mensajes = ""

func inicializar(hub):
	HUB = hub
	for componente in [
		[campo_entrada,  "campo_entrada",  "Campo Entrada"],
		[campo_mensajes, "campo_mensajes", "Campo Mensajes"],
		[nodo_comandos,  "comandos",       "Nodo Comandos"]
	]:
		if not inicializar_componente(
			componente[0],
			componente[1] + ".gd",
			componente[2]
		):
			return false
	for nodo in [self, campo_entrada, campo_mensajes]:
		HUB.GC.excepcion(nodo)
	inicializar_input()
	return true

# Abre la terminal
func abrir(modo=1):
	set_modo_visible(modo)

# Cierra la terminal
func cerrar(modo=0):
	set_modo_visible(modo)

func set_modo_visible(modo):
	if modo==0 or modo==5:
		Input.set_mouse_mode(HUB.eventos.modo_mouse)
	else:
		Input.set_mouse_mode(0)
	modo_visible = modo
	if modo==0 or modo==5:
		campo_entrada.set_hidden(true)
	else:
		campo_entrada.set_hidden(false)
		campo_entrada.grab_focus()
	if modo==1 or modo==4:
		campo_mensajes.set_hidden(false)
	else:
		campo_mensajes.set_hidden(true)

# Retorna si la terminal está visible y, por lo tanto, debe capturar el input del usuario
func activa():
	return modo_visible != 0 and modo_visible != 5

# Retorna si la terminal debe abrirse ante un error
func abrir_en_error():
	return modo_visible==3 or modo_visible==5

# Ejecuta un comando
func ejecutar(comando_con_argumentos, mostrar_mensaje=false):
	if mostrar_mensaje:
		campo_mensajes.mensaje(campo_mensajes.pre_usuario + comando_con_argumentos)
		campo_mensajes.ultimo_entorno_impreso = ""
	var argumentos = parsear_argumentos(comando_con_argumentos)
	var comando = argumentos[0]
	argumentos.remove(0)
	var tmp = modo_visible
	var resultado = nodo_comandos.ejecutar(comando, argumentos)
	if tmp==4 and not HUB.errores.fallo(resultado):
		cerrar()
	return resultado

# Limpia el campo de mensajes
func borrar_mensajes():
	log_mensajes += campo_mensajes.get_text()+"\n"
	campo_mensajes.set_text("")
	campo_mensajes.ultimo_entorno_impreso = ""

# Devuelve el log completo de mensajes
func log_completo(restaurar=false):
	var resultado = log_mensajes + campo_mensajes.get_text()
	if restaurar:
		log_mensajes = ""
		campo_mensajes.set_text(resultado)
	return resultado

# Activa o desactiva la impresión del entorno al mandar mensajes
func imprimir_entorno(activado=true):
	if activado:
		campo_mensajes.imprimir_entorno = true
	else:
		campo_mensajes.imprimir_entorno = false
		campo_mensajes.ultimo_entorno_impreso = ""

# Funciones auxiliares

func inicializar_componente(nodo, script, nombre):
	add_child(nodo)
	if not HUB.archivos.existe(HUB.hub_src.plus_file(carpeta_src), script):
		return false
	nodo.set_script(HUB.archivos.abrir(HUB.hub_src.plus_file(carpeta_src), script))
	if not nodo.has_method("inicializar"):
		return false
	nodo.set_name(nombre)
	return nodo.inicializar(HUB)

func inicializar_input():
	HUB.eventos.registrar_press(KEY_TAB, self, "autocompletar_o_abrir")
	HUB.eventos.registrar_press(KEY_ESCAPE, self, "cerrar")
	HUB.eventos.registrar_press(KEY_UP, campo_entrada, "historial_arriba")
	HUB.eventos.registrar_press(KEY_DOWN, campo_entrada, "historial_abajo")
	HUB.eventos.registrar_press(KEY_RETURN, campo_entrada, "ingresar")

func autocompletar_o_abrir():
	if modo_visible == 0:
		abrir()
	else: # TODO: ¿abro si estoy en otro modo que no sea "1"?
		campo_entrada.autocompletar()

func parsear_argumentos(argumentos):
	var tokens = argumentos.split(" ")
	var resultado = []
	var tmp = ""
	for token in tokens:
		if token.begins_with('"'):
			if token.ends_with('"'):
				resultado.append(token.substr(1,token.length()-2))
			else:
				tmp = HUB.varios.str_desde(token,1)
		elif token.ends_with('"'):
			tmp += " " + token.substr(0,token.length()-1)
			resultado.append(tmp)
			tmp = ""
		elif not tmp.empty():
			tmp += " " + token
		elif not token.empty():
			resultado.append(token)
	if not tmp.empty():
		resultado.append(tmp)
	return resultado

# Errores

# Comando inexistente
func comando_inexistente(comando, stack_error=null):
	return HUB.errores.error('Comando "' + comando + '" desconocido.', stack_error)

# Error al cargar el comando
func comando_no_cargado(comando, stack_error=null):
	return HUB.errores.error('No se pudo cargar el comando "' + comando + '".', stack_error)

# Comando fallido
func comando_fallido(comando, stack_error=null):
	return HUB.errores.error('Falló la ejecución del comando "' + comando + '".', stack_error)
