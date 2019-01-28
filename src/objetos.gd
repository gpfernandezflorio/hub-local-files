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
var carpeta_src = "objetos/"
# Script genérico de un objeto
var script_objeto = "objeto.gd"
# Script de comportamiento de un objeto
var script_comportamiento = "comportamiento.gd"
# Carpeta de scripts de comportamiento
var carpeta_comportamientos = "comportamiento/"
# Codigo de comportamientos
var codigo = "Comportamiento"

func inicializar(hub):
	HUB = hub
	HUB.archivos.codigos_script.append(codigo)
	script_objeto = HUB.archivos.abrir(HUB.hub_src + carpeta_src, script_objeto)
	script_comportamiento = HUB.archivos.abrir(HUB.hub_src + carpeta_src, script_comportamiento)
	return script_objeto != null and script_comportamiento != null

# Crea y devuelve un objeto vacío sin comportamiento
func crear(hijo_de=HUB.nodo_usuario.mundo):
	var nuevo_objeto = Spatial.new()
	nuevo_objeto.set_name("objeto sin nombre")
	var comportamiento = Node.new()
	comportamiento.set_name("Comportamiento")
	nuevo_objeto.add_child(comportamiento)
	nuevo_objeto.set_script(script_objeto)
	nuevo_objeto.inicializar(HUB)
	comportamiento.set_script(script_comportamiento)
	comportamiento.inicializar(HUB)
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
	return HUB.error(objeto_inexistente(nombre_completo, desde.get_name()))

# Errores

# Objeto inexistente
func objeto_inexistente(objeto, desde, stack_error=null):
	return HUB.errores.error('No se encontró ningún objeto con nombre "' + \
		objeto + '" en la jerarquía desde el objeto "' + desde + \
		'".', stack_error)