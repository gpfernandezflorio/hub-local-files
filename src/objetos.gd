## Objetos
## SRC

# Organiza la creación y manipulación de objetos.
# Requiere para inicializar:
	# HUB.hub_src
	# HUB.archivos
		# abrir
	# src/objetos/comportamiento.gd
	# src/objetos/objeto.gd

extends Node

var HUB
var modulo = "OBJETOS"
# Ruta a la carpeta de archivos fuente de este módulo
var carpeta_src = "objetos/"
# Script genérico de un objeto
var script_objeto = "objeto.gd"
# Ruta a la carpeta de scripts de comportamiento
var carpeta_comportamientos = "comportamiento/"
# Codigo de comportamientos
var codigo = "Comportamiento"
# Diccionario con los comportamientos cargadas
var comportamientos_cargados = {} # Dicc(string : GDScript)

func inicializar(hub):
	HUB = hub
	HUB.archivos.codigos_script.append(codigo)
	script_objeto = HUB.archivos.abrir(HUB.hub_src + carpeta_src, script_objeto)
	if script_objeto != null:
		script_objeto.set_name("Objeto")
		return true
	return false

# Crea y devuelve un objeto vacío sin comportamiento
func crear(hijo_de=HUB.nodo_usuario.mundo):
	var nuevo_objeto = Spatial.new()
	nuevo_objeto.set_name("objeto sin nombre")
	nuevo_objeto.set_script(script_objeto)
	nuevo_objeto.inicializar(HUB)
	if hijo_de != null:
		hijo_de.agregar_hijo(nuevo_objeto)
	return nuevo_objeto

# Ubica y devuelve a un objeto por su nombre completo (omitiendo "Mundo/")
func localizar(nombre_completo, desde=HUB.nodo_usuario.mundo):
	var nodo = nombre_completo.split("/")[0]
	for hijo in desde.hijos():
		if hijo.get_name() == nodo:
			if nodo.length() == nombre_completo.length():
				return hijo
			var offset_nombre = nodo.length()+1
			var siguientes = nombre_completo.substr(offset_nombre, nombre_completo.length() - offset_nombre)
			return localizar(siguientes, hijo)
	return HUB.error(objeto_inexistente(nombre_completo, desde), modulo)

# Ubica un objeto y lo elimina del mundo
func borrar(nombre_completo, desde=HUB.nodo_usuario.mundo):
	var objeto = localizar(nombre_completo, desde)
	if HUB.errores.fallo(objeto):
		return HUB.error(HUB.errores.error('No se pudo eliminar el objeto "' + \
			nombre_completo + '".', objeto), modulo)
	var padre = objeto.padre()
	padre.quitar_hijo(objeto)
	if objeto.is_inside_tree():
		objeto.queue_free()
	else:
		pass # ¿no debería eliminarlo igual?
	return ""

# Determina si algo es un objeto del HUB
func es_un_objeto(algo):
	if typeof(algo) == 18: # No es un built-in type
		var tipo = algo.get_type()
		if tipo == "Spatial":
			var script = algo.get_script()
			if not script == null:
				return script.get_name() == "Objeto"
	return false

# Carga un script de comportamiento
func cargar_comortamiento(nombre):
	var nodo = Node.new()
	var script = null
	if nombre in comportamientos_cargados:
		script = comportamientos_cargados[nombre]
	else:
		script = HUB.archivos.abrir(carpeta_comportamientos, nombre + ".gd", codigo)
		if (HUB.errores.fallo(script)):
			return HUB.error(comportamiento_inexistente(nombre, nombre), modulo)
		script.set_name(nombre)
		comportamientos_cargados[nombre] = script
	nodo.set_script(script)
	return nodo

# Errores

# Objeto inexistente
func objeto_inexistente(nombre_completo, desde, stack_error=null):
	return HUB.errores.error('No se encontró ningún objeto con nombre "' + \
		nombre_completo + '" en la jerarquía desde el objeto "' + desde.get_name() + \
		'".', stack_error)

# Comportamiento inexistente
func comportamiento_inexistente(nombre, stack_error=null):
	return HUB.errores.error('No se encontró ningún script de comportamiento con nombre "' + \
		nombre + '".', stack_error)