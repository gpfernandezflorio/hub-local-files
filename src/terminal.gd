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
var carpeta_src = "terminal/"

# Campo para ingresar comandos
var campo_entrada = LineEdit.new()
# Campo para mostrar los mensajes del HUB
var campo_mensajes = TextEdit.new()
# Nodo para ejecutar comandos
var nodo_comandos = Node.new()

# Indica si la terminal está activa, es decir si está visible
var activa = true
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
	inicializar_input()
	return true

# Abre la terminal
func abrir():
	Input.set_mouse_mode(0)
	activa = true
	campo_entrada.set_hidden(false)
	campo_mensajes.set_hidden(false)
	campo_entrada.grab_focus()

# Cierra la terminal
func cerrar():
	Input.set_mouse_mode(HUB.eventos.modo_mouse)
	activa = false
	campo_entrada.set_hidden(true)
	campo_mensajes.set_hidden(true)

# Ejecuta un comando
func ejecutar(comando_con_argumentos, mostrar_mensaje=false):
	if mostrar_mensaje:
		campo_mensajes.mensaje("> " + comando_con_argumentos)
	var argumentos = comando_con_argumentos.split(" ")
	var comando = argumentos[0]
	argumentos.remove(0)
	return nodo_comandos.ejecutar(comando, argumentos)

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
	if not HUB.archivos.existe(HUB.hub_src+carpeta_src, script):
		return false
	nodo.set_script(HUB.archivos.abrir(HUB.hub_src+carpeta_src, script))
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
	if activa:
		campo_entrada.autocompletar()
	else:
		abrir()

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