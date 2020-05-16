## Objeto
## SRC

# El script de todo objeto.
# Hace de proxy al recibir mensajes.

extends Spatial

var HUB

# Nodo vacío que tiene como hijos a los nodos que representan los objetos hijos de este objeto
var hijos = Node.new()
# Nodo vacío que tiene como hijos a los nodos que representan los componentes de este objeto
var componentes = Node.new()
# Nodo vacío que tiene como hijos a los nodos que representan los comportamientos de este objeto
var comportamientos = Node.new()

func inicializar(hub):
	HUB = hub
	hijos.set_name("Hijos")
	add_child(hijos)
	componentes.set_name("Componentes")
	add_child(componentes)
	comportamientos.set_name("Comportamientos")
	add_child(comportamientos)
	return true

# Cambiar el nombre del objeto
func nombrar(nombre_base):
	var nombre_original = false
	var try = 0
	var nombre = nombre_base
	while not nombre_original:
		if try != 0:
			nombre = nombre_base + "_" + str(try)
		try += 1
		nombre_original = true
		if get_parent() != null:
			for hermano in get_parent().get_children():
				if hermano != self and hermano.get_name() == nombre:
					nombre_original = false
	set_name(nombre)
	return nombre # Devuelve el nuevo nombre

# Agrega un componente al objeto
func agregar_componente(componente, nombre=null):
	# TODO
	componentes.add_child(componente)
	return nombre # Devuelve el nuevo nombre

# Adjunta un script al objeto
func agregar_comportamiento(nombre_script):
	# TODO
	var nombre = nombre_script
	return nombre # Devuelve el nuevo nombre

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
	var nombre_original = objeto.get_name()
	hijos.add_child(objeto)
	objeto.nombrar(nombre_original)
	return objeto.get_name() # Devuelve el nuevo nombre

# Quita un objeto hijo
func quitar_hijo(objeto):
	if not es_hijo(objeto):
		return HUB.error(hijo_inexistente(objeto.nombre()), get_name())
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

# Devuelve al hijo con ese nombre
func hijo_nombrado(nombre):
	if not tiene_hijo_nombrado(nombre):
		return HUB.error(hijo_inexistente(nombre), get_name())
	for hijo in hijos():
		if hijo.nombre() == nombre:
			return hijo

# Devuelve la lista de hijos en la jerarquía de objetos
func hijos():
	return hijos.get_children()

# Devuelve el objeto padre
func padre():
	if get_parent():
		return get_parent().get_parent()
	return null

# Devuelve el nombre del objeto
func nombre():
	return get_name()

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