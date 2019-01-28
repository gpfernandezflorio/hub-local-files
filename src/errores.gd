## Errores
## SRC

# Script para manejar errores.
# Requiere para inicializar:
	# -

extends Node

var HUB

func inicializar(hub):
	HUB = hub
	return true

# Crea y devuelve un error genérico
func error(mensaje, stack_error = null):
	return Error.new(mensaje, stack_error)

# Retorna si el resultado de una función generó un error
func fallo(resultado):
	if typeof(resultado) == 18: # No es un built-in type
		return resultado.get_type() == "Error"
	return false

# Intenta ejecutar una función en un nodo
func try(nodo, funcion, parametros=[]):
	var verificacion_funcion = verificar_implementa_funcion(nodo, funcion, parametros.size())
	if HUB.errores.fallo(verificacion_funcion):
		return HUB.error(try_fallo(nodo, funcion, verificacion_funcion))
	return nodo.callv(funcion, parametros)

# Verifica que un nodo implemente una determinada función
func verificar_implementa_funcion(nodo, funcion, cantidad_de_parametros):
	for metodo in nodo.get_method_list():
		if metodo["name"] == funcion:
			if metodo["args"].size() == cantidad_de_parametros:
				return null
			break
	return HUB.error(funcion_no_implementada(nodo, funcion, cantidad_de_parametros))

# Errores:

# Función no implementada
func funcion_no_implementada(nodo, funcion, parametros, stack_error=null):
	return error('El nodo "' + nodo.get_name() + '" no implementa ' + \
	'la función "' + funcion + '" con ' + str(parametros) + \
	' parámetro(s)', stack_error)

# Try falló
func try_fallo(nodo, funcion, stack_error=null):
	return error('(TRY) Falló la ejecución de la función "' + \
	funcion + '" en el nodo "' + nodo.get_name() + '"', stack_error)

class Error:
	var mensaje = ""
	var stack_error = null
	func _init(mensaje, stack_error = null):
		self.mensaje = mensaje
		self.stack_error = stack_error
	func get_type():
		return "Error"