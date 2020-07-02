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
# Ruta a la carpeta de scripts de componentes
var carpeta_componentes = "componentes/"
# Script genérico de un objeto
var script_objeto = "objeto.gd"
# Ruta a la carpeta de scripts de objeto
var carpeta_objetos = "objetos/"
# Ruta a la carpeta de scripts de comportamiento
var carpeta_comportamientos = "comportamiento/"
# Codigo de objetos
var codigo_objetos = "Objeto"
# Codigo de comportamientos
var codigo_comportamientos = "Comportamiento"
# Diccionario con los comportamientos cargados
var comportamientos_cargados = {} # Dicc(string : GDScript)
# Diccionario con los generadores cargados
var generadores_cargados = {} # Dicc(string : Node)

var componentes_validos = {
	# body
	"static":StaticBody,
	"rigid":Spatial, # Caso especial. Lo maneja el script 'rigid.gd'
	"kinematic":KinematicBody,
	# luz
	"omni":OmniLight,
	"spot":SpotLight,
	"dir":DirectionalLight
}

func inicializar(hub):
	HUB = hub
	HUB.archivos.codigos_script.append(codigo_objetos)
	HUB.archivos.codigos_script.append(codigo_comportamientos)
	script_objeto = HUB.archivos.abrir(HUB.hub_src.plus_file(carpeta_src), script_objeto)
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
			var siguientes = HUB.varios.str_desde(nombre_completo,offset_nombre)
			return localizar(siguientes, hijo)
	return HUB.error(objeto_inexistente(nombre_completo, desde), modulo)

# Ubica un objeto y lo elimina del mundo
func borrar(objeto_o_nombre, desde=HUB.nodo_usuario.mundo):
	var nombre = objeto_o_nombre
	var objeto = objeto_o_nombre
	if es_un_objeto(objeto_o_nombre):
		nombre = objeto.nombre()
	elif typeof(objeto_o_nombre) == TYPE_STRING:
		objeto = localizar(nombre, desde)
		if HUB.errores.fallo(objeto):
			return HUB.error(HUB.errores.error('No se pudo eliminar el objeto "' + \
				nombre + '".', objeto), modulo)
	else:
		return HUB.error(HUB.errores.error('Argumento inválido para borrar :' + HUB.varios.str(objeto_o_nombre)), modulo)
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

# Crea un nuevo componente
func crear_componente(id):
	if id in componentes_validos.keys():
		var resultado = componentes_validos[id].new()
		if HUB.archivos.existe(HUB.hub_src.plus_file(carpeta_componentes), id+".gd"):
			resultado.set_script(HUB.archivos.abrir(HUB.hub_src.plus_file(carpeta_componentes), id+".gd"))
		return resultado
	return HUB.error(HUB.errores.error('Componente desconocido: '+id), modulo)

# Adjunta un script a un objeto
func agregar_comportamiento_a_objeto(objeto, nombre_script, args=[[],{}]):
	var comportamiento = cargar_comportamiento(nombre_script)
	if HUB.errores.fallo(comportamiento):
		return HUB.error(HUB.errores.error('No se pudo agregar el comportamiento "' + nombre_script + '".', comportamiento), modulo)
	var nombre = nombre_script.replace("/","-")
	nombre = objeto.nombrar_sin_colision(comportamiento, nombre, objeto.comportamientos)
	objeto.comportamientos.add_child(comportamiento)
	var argumentos = HUB.varios.parsear_argumentos_comportamientos(comportamiento, args, modulo)
	if HUB.errores.fallo(argumentos):
		return HUB.error(HUB.errores.error('No se pudo agregar el comportamiento "' + nombre_script + '".', argumentos), modulo)
	var resultado = comportamiento.inicializar(HUB, objeto, argumentos)
	if HUB.errores.fallo(resultado):
		return HUB.error(HUB.errores.error('No se pudo agregar el comportamiento "' + nombre_script + '".', resultado), modulo)
	return nombre # Devuelve el nuevo nombre

# Generar un objeto a partir de un generador tipo función
func generar(nombre, args=[[],{}]):
	if not nombre in generadores_cargados:
		var script = HUB.archivos.abrir(carpeta_objetos, nombre + ".gd", codigo_objetos)
		if HUB.errores.fallo(script):
			return HUB.error(generador_inexistente(nombre, script), modulo)
		var nodo = Node.new()
		nodo.set_script(script)
		var resultado = HUB.varios.cargar_bibliotecas(nodo, modulo)
		if HUB.errores.fallo(resultado):
			return HUB.error(HUB.errores.error("X", resultado), modulo)
		resultado = nodo.inicializar(HUB)
		if HUB.errores.fallo(resultado):
			return HUB.error(HUB.errores.error("X", resultado), modulo)
		generadores_cargados[nombre] = nodo
	var generador = generadores_cargados[nombre]
	var argumentos = HUB.varios.parsear_argumentos_objetos(generador, args, modulo)
	if HUB.errores.fallo(argumentos):
		return HUB.error(HUB.errores.error("X", argumentos), modulo)
	return generador.gen(argumentos)

# Usada para que los scripts de comportamiento accedan a los componentes del objeto
func componente_candidato(objeto, nombre, tipo_o_requisitos):
	var condicion = "es_de_tipo"
	if typeof(tipo_o_requisitos) == TYPE_ARRAY:
		condicion = "implementa_metodos"
	if objeto.tiene_componente_nombrado(nombre):
		var candidato = objeto.componente_nombrado(nombre)
		if cumple_condicion(candidato, condicion, tipo_o_requisitos):
			return candidato
	var candidatos = []
	for componente in objeto.componentes():
		if cumple_condicion(componente, condicion, tipo_o_requisitos):
			candidatos.append(componente)
	if candidatos.empty():
		return HUB.error(HUB.errores.error("No hay candidato"), modulo)
	if candidatos.size()==1:
		return candidatos[0]
	# ¿Qué hago si hay más de uno?
	return candidatos[0] # Por ahora, devuelvo el primero

# Funciones auxiliares

func cargar_comportamiento(nombre):
	var nodo = Spatial.new()
	var script = null
	if nombre in comportamientos_cargados:
		script = comportamientos_cargados[nombre]
	else:
		script = HUB.archivos.abrir(carpeta_comportamientos, nombre + ".gd", codigo_comportamientos)
		if (HUB.errores.fallo(script)):
			return HUB.error(comportamiento_inexistente(nombre, script), modulo)
		script.set_name(nombre)
		comportamientos_cargados[nombre] = script
	nodo.set_script(script)
	var resultado = HUB.varios.cargar_bibliotecas(nodo, modulo)
	if HUB.errores.fallo(resultado):
		return HUB.error(HUB.errores.error('X', resultado), modulo)
	return nodo

func cumple_condicion(candidato, condicion, tipo_o_requisitos):
	return call(condicion, candidato, tipo_o_requisitos)
func es_de_tipo(candidato, tipo):
	return candidato.get_type() == tipo
func implementa_metodos(candidato, metodos):
	for m in metodos:
		if not candidato.has_method(m):
			return false
	return true

# Errores

# Objeto inexistente
func objeto_inexistente(nombre_completo, desde, stack_error=null):
	return HUB.errores.error('No se encontró ningún objeto con nombre "' + \
		nombre_completo + '" en la jerarquía desde el objeto "' + desde.get_name() + \
		'".', stack_error)

# Generador inexistente
func generador_inexistente(nombre, desde, stack_error=null):
	return HUB.errores.error('No se encontró ningún generador de objetos con nombre "' + \
		nombre + '".', stack_error)

# Comportamiento inexistente
func comportamiento_inexistente(nombre, stack_error=null):
	return HUB.errores.error('No se encontró ningún script de comportamiento con nombre "' + \
		nombre + '".', stack_error)

# Mensaje desconocido
func mensaje_desconocido(nombre, stack_error=null):
	return HUB.errores.error('No entiendo el mensaje "' + \
		nombre + '".', stack_error)
