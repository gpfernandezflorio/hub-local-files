## Objeto
## SRC

# El script de todo objeto.
# Hace de proxy al recibir mensajes.

extends Spatial

var HUB

# Nodo vacío que tiene como hijos a los nodos que representan los objetos hijos de este objeto
var hijos = Spatial.new()
# Nodo vacío que tiene como hijos a los nodos que representan los componentes de este objeto
var componentes = Spatial.new()
# Nodo vacío que tiene como hijos a los nodos que representan los comportamientos de este objeto
var comportamientos = Spatial.new()
# Diccionario de propiedades para que los comporamientos interactúen entre sí
var propiedades = {}
# Diccionario de funciones de los comporamientos
var interfaz = {}
# Si tengo componentes de tipo RigidBody tengo que "avisarles" cuando me muevo
var bodies = []

func inicializar(hub):
	HUB = hub
	hijos.set_name("Hijos")
	add_child(hijos)
	componentes.set_name("Componentes")
	add_child(componentes)
	comportamientos.set_name("Comportamientos")
	add_child(comportamientos)
	return true

# Recibe un mensaje
func mensaje(nombre, colaboradores=[]):
	if nombre in interfaz:
		var metodo = interfaz[nombre]
		var argumentos = HUB.varios.parsear_argumentos_general(metodo[1], [colaboradores,{}], nombre())
		if HUB.errores.fallo(argumentos):
			return HUB.error(HUB.errores.error("X", argumentos), nombre())
		return metodo[0].call(nombre, argumentos)
	return HUB.error(HUB.objetos.mensaje_desconocido(nombre), nombre())

# Cambiar el nombre del objeto
func nombrar(nombre_base):
	# Devuelve el nuevo nombre
	return nombrar_sin_colision(self, nombre_base, get_parent())

# Agrega un componente al objeto
func agregar_componente(componente, nombre=null):
	var nuevo_nombre = nombre
	if (nuevo_nombre == null or nuevo_nombre.empty()):
		nuevo_nombre = componente.get_name()
		if (nuevo_nombre == null or nuevo_nombre.empty()):
			nuevo_nombre = "componente sin nombre"
	nuevo_nombre = nombrar_sin_colision(componente, nuevo_nombre, componentes)
	componentes.add_child(componente)
	if componente.has_method("inicializar"):
		componente.inicializar(HUB, self)
	return nuevo_nombre # Devuelve el nuevo nombre

# Adjunta un script al objeto
func agregar_comportamiento(nombre_script, args=[[],{}]):
	return HUB.objetos.agregar_comportamiento_a_objeto(self, nombre_script, args)

# Quita un componente del objeto
func quitar_componente(nombre):
	for componente in componentes.get_children():
		if componente.get_name() == nombre:
			componente.remove_child(componente)
			componente.queue_free()
			return null
	return HUB.error(componente_inexistente(nombre), get_name())

# Quita un script de comportamiento
func quitar_comportamiento(nombre):
	for comportamiento in comportamientos.get_children():
		if comportamiento.get_name() == nombre:
			comportamiento.remove_child(comportamiento)
			comportamiento.queue_free()
			return null
	return HUB.error(comportamiento_inexistente(nombre), get_name())

# Agrega a otro objeto como hijo en la jerarquía de objetos
func agregar_hijo(objeto):
	# TODO: ¿error si el objeto ya tiene padre? ¿o se lo saco al otro?
	var nombre = nombrar_sin_colision(objeto, objeto.get_name(), hijos)
	hijos.add_child(objeto)
	return nombre # Devuelve el nuevo nombre

# Quita un objeto hijo
func quitar_hijo(objeto):
	if not es_hijo(objeto):
		return HUB.error(hijo_inexistente(objeto.nombre()), get_name())
	if objeto.is_inside_tree():
		hijos.remove_child(objeto)

# Quita un objeto hijo
func quitar_hijo_nombrado(nombre):
	if not tiene_hijo_nombrado(nombre):
		return HUB.error(hijo_inexistente(nombre), get_name())
	hijos.remove_child(hijo_nombrado(nombre))

# Devuelve si otro objeto es hijo de este
func es_hijo(objeto):
	return objeto in hijos()

# Devuelve si tiene un hijo con ese nombre
func tiene_hijo_nombrado(nombre):
	for hijo in hijos():
		if hijo.nombre() == nombre:
			return true
	return false

# Devuelve si tiene un componente con ese nombre
func tiene_componente_nombrado(nombre):
	for componente in componentes():
		if componente.get_name() == nombre:
			return true
	return false

# Devuelve al hijo con ese nombre
func hijo_nombrado(nombre):
	if not tiene_hijo_nombrado(nombre):
		return HUB.error(hijo_inexistente(nombre), get_name())
	for hijo in hijos():
		if hijo.nombre() == nombre:
			return hijo

# Devuelve al componente con ese nombre
func componente_nombrado(nombre):
	if not tiene_componente_nombrado(nombre):
		return HUB.error(componente_inexistente(nombre), get_name())
	for componente in componentes():
		if componente.get_name() == nombre:
			return componente

# Devuelve la lista de hijos en la jerarquía de objetos
func hijos():
	return hijos.get_children()

# Devuelve la lista de componentes
func componentes():
	return componentes.get_children()

# Devuelve la lista de comportamientos
func comportamientos():
	return comportamientos.get_children()

# Devuelve el objeto padre
func padre():
	if get_parent():
		return get_parent().get_parent()
	return null

# Devuelve el nombre del objeto
func nombre():
	return get_name()

# Mueve inmediatamente
func mover(cuanto):
	set_translation(get_transform().origin + cuanto)
	for c in bodies:
		c.mover(cuanto)

func moveme(c):
	bodies.append(c)

# Diccionario de propiedades para que los comporamientos interactúen entre sí
func dame(clave, default=null):
	var resultado = default
	if clave in propiedades:
		resultado = propiedades[clave]
	return resultado

func pone(clave, valor):
	propiedades[clave] = valor

# Agrega una función a la interfaz del objeto
func interfaz(nodo, funcion, arg_map, es_primitiva=false):
	interfaz[funcion] = [nodo, arg_map]

func sabe(funcion):
	return funcion in interfaz

# Funciones Auxiliares

func nombrar_sin_colision(nodo, nombre_base, padre):
	var nombre_original = false
	var try = 0
	var nombre = nombre_base
	while not nombre_original:
		if try != 0:
			nombre = nombre_base + "_" + str(try)
		try += 1
		nombre_original = true
		if padre != null:
			for hermano in padre.get_children():
				if hermano != self and hermano.get_name() == nombre:
					nombre_original = false
	nodo.set_name(nombre)
	return nombre

# Errores

# Componente inexistente
func componente_inexistente(componente, stack_error = null):
	return HUB.errores.error('Componente "' + componente + '" no encontrado.', stack_error)

# Comportamiento inexistente
func comportamiento_inexistente(comportamiento, stack_error = null):
	return HUB.errores.error('Comportamiento "' + comportamiento + '" no encontrado.', stack_error)

# Hijo inexistente
func hijo_inexistente(nombre, stack_error = null):
	return HUB.errores.error('El objeto "' + nombre + '" no es hijo de "' + nombre() + '".', stack_error)
