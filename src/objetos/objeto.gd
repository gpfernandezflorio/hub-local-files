## Objeto
## SRC

# El script de todo objeto.
# Hace de proxy al recibir mensajes.

extends Spatial

var HUB

# Nodo vacío que tiene como hijos a los nodos que representan los objetos hijos de este objeto
var hijos
# Nodo vacío que tiene como hijos a los nodos que representan los componentes de este objeto
var componentes

func inicializar(hub):
	HUB = hub
	componentes = Node.new()
	componentes.set_name("Componentes")
	add_child(componentes)
	hijos = Node.new()
	hijos.set_name("Hijos")
	add_child(hijos)
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

# Agrega un componente al objeto
func agregar_componente(componente, nombre):
	pass

# Adjunta un script al objeto
func agregar_comportamiento(nombre_script):
	pass

# Quita un componente del objeto
func quitar_componente(nombre):
	pass

# Quita un script de comportamiento
func quitar_comportamiento(nombre_script):
	pass

# Agrega a otro objeto como hijo en la jerarquía de objetos
func agregar_hijo(objeto):
	var nombre_original = objeto.get_name()
	hijos.add_child(objeto)
	objeto.nombrar(nombre_original)

# Devuelve la lista de hijos en la jerarquía de objetos
func hijos():
	return hijos.get_children()