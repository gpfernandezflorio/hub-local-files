## Varios
## SRC

# Funciones y otras utilidades generales.
# Requiere para inicializar:
	# -

extends Node

var HUB
var modulo = "VARIOS"

func inicializar(hub):
	HUB = hub
	return true

func parsear_argumentos_objetos(nodo, args):
	if "arg_map" in nodo:
		return parsear_argumentos_general(nodo.arg_map, args)
	return args

func parsear_argumentos_comportamientos(nodo, args):
	if "arg_map" in nodo:
		return parsear_argumentos_general(nodo.arg_map, args)
	return args

func parsear_argumentos_general(arg_map, args):
	var resultado = args[1]
	var codigos_vistos = []
	var codigos_validos = []
	for arg in arg_map.lista:
		codigos_validos.append(arg.codigo)
		if arg.codigo in resultado:
			codigos_vistos.append(arg.codigo)
		else:
			if arg.nombre in resultado:
				resultado[arg.codigo] = resultado[arg.nombre]
				resultado.erase(arg.nombre)
			elif "default" in arg:
				resultado[arg.codigo] = arg.default
			else:
				resultado[arg.codigo] = null
	for k in resultado:
		if not k in codigos_validos:
			return HUB.error(modificador_invalido(k, k+"="+resultado[k]), modulo)
	var i_arg = 0
	var cantidad_de_argumentos = arg_map.lista.size()
	for arg in args[0]:
		while i_arg < cantidad_de_argumentos and arg_map.lista[i_arg].codigo in codigos_vistos:
			i_arg+=1
		if i_arg >= cantidad_de_argumentos:
			return HUB.error(mas_argumentos_que_los_esperados(cantidad_de_argumentos), modulo)
		resultado[arg_map.lista[i_arg].codigo] = arg
		i_arg+=1
	# Validar valores ingresados
	for arg in arg_map.lista:
		if "validar" in arg and typeof(resultado[arg.codigo])==TYPE_STRING:
			var validacion = validar_argumento(arg, resultado[arg.codigo])
			if HUB.errores.fallo(validacion):
				return validacion
			resultado[arg.codigo] = validacion
	return resultado

func parsear_argumentos_comandos(nodo, lista_de_argumentos):
	if not "arg_map" in nodo:
		return lista_de_argumentos
	var arg_map = nodo.arg_map
	var resultado = {}
	var codigos_validos = []
	for arg in arg_map.lista:
		codigos_validos.append(arg.codigo)
	var acepta_argumentos_extra = "extra" in arg_map
	var obligatorios = 0
	if "obligatorios" in arg_map:
		obligatorios = arg_map.obligatorios
	var i = obligatorios
	while i < arg_map.lista.size(): # Inicializo los opcionales con los valores default
		var arg = arg_map.lista[i]
		if "default" in arg:
			resultado[arg.codigo] = arg.default
		else:
			resultado[arg.codigo] = null
		i+=1
	var argumentos_libres = []
	var codigos_vistos = []
	for arg in lista_de_argumentos:
		if arg.begins_with("-") and not arg.is_valid_float():
			var codigo = arg[1]
			if codigo in codigos_vistos:
				return HUB.error(modificador_repetido(codigo), modulo)
			if not codigo in codigos_validos:
				return HUB.error(modificador_invalido(codigo, arg), modulo)
			resultado[codigo] = arg.substr(2,arg.length()-2)
			codigos_vistos.append(codigo)
		else:
			argumentos_libres.append(arg)
	# Verificar que se pasaron todos los argumentos obligatorios
	for i in range(obligatorios):
		var codigo = arg_map.lista[i].codigo
		if (not codigo in resultado) or resultado[codigo] == null:
			# No se pasó como modificador pero podría estar entre los libres
			if argumentos_libres.size()>0:
				resultado[codigo] = argumentos_libres[0]
				codigos_vistos.append(codigo)
				argumentos_libres.pop_front()
			else:
				return HUB.error(faltan_argumentos_obligatorios(arg_map.lista[i].nombre), modulo)
	if acepta_argumentos_extra:
		resultado.extra = argumentos_libres
	else:
		var i_arg = 0
		var cantidad_de_argumentos = arg_map.lista.size()
		for arg in argumentos_libres:
			while i_arg < cantidad_de_argumentos and arg_map.lista[i_arg].codigo in codigos_vistos:
				i_arg+=1
			if i_arg >= cantidad_de_argumentos:
				return HUB.error(mas_argumentos_que_los_esperados(cantidad_de_argumentos), modulo)
			resultado[arg_map.lista[i_arg].codigo] = arg
			i_arg+=1
	# Validar valores ingresados
	for arg in arg_map.lista:
		if "validar" in arg and typeof(resultado[arg.codigo])==TYPE_STRING:
			var validacion = validar_argumento(arg, resultado[arg.codigo])
			if HUB.errores.fallo(validacion):
				return validacion
			resultado[arg.codigo] = validacion
	return resultado

func cargar_bibliotecas(nodo, modulo):
	if "lib_map" in nodo:
		var new_lib_map = {}
		for lib in nodo.lib_map:
			var new_lib = HUB.bibliotecas.importar(lib)
			if HUB.errores.fallo(new_lib):
				remove_child(nodo)
				nodo.queue_free()
				return HUB.error(HUB.errores.inicializacion_fallo(nodo, new_lib), modulo)
			new_lib_map[lib] = new_lib
		nodo.lib_map = new_lib_map
	return ""

func num(s):
	if s.is_valid_integer():
		return int(s)
	elif s.is_valid_float():
		return float(s)
	return 0

func validar_argumento(arg, valor):
	var resultado = valor
	for validador in arg.validar.split(";"):
		if validador == "BOOL":
			if valor.empty():
				resultado = true
			else:
				return HUB.error(argumento_tipo_incorrecto(arg.nombre, valor, validador), modulo)
		elif validador == "NUM":
			if valor.is_valid_integer():
				resultado = int(resultado)
			elif valor.is_valid_float():
				resultado = float(resultado)
			else:
				return HUB.error(argumento_tipo_incorrecto(arg.nombre, valor, validador), modulo)
		elif validador == "INT":
			if valor.is_valid_integer():
				resultado = int(resultado)
			else:
				return HUB.error(argumento_tipo_incorrecto(arg.nombre, valor, validador), modulo)
		elif validador == "DEC":
			if valor.is_valid_float():
				resultado = float(resultado)
			else:
				return HUB.error(argumento_tipo_incorrecto(arg.nombre, valor, validador), modulo)
		elif validador.begins_with(">="):
			if resultado < num(validador.substr(2,validador.length()-2)):
				return HUB.error(argumento_tipo_incorrecto(arg.nombre, valor, validador), modulo)
		elif validador.begins_with("<="):
			if resultado > num(validador.substr(2,validador.length()-2)):
				return HUB.error(argumento_tipo_incorrecto(arg.nombre, valor, validador), modulo)
		elif validador.begins_with(">"):
			if resultado <= num(validador.substr(1,validador.length()-1)):
				return HUB.error(argumento_tipo_incorrecto(arg.nombre, valor, validador), modulo)
		elif validador.begins_with("<"):
			if resultado >= num(validador.substr(1,validador.length()-1)):
				return HUB.error(argumento_tipo_incorrecto(arg.nombre, valor, validador), modulo)
	return resultado

# Errores

# Faltan argumentos obligatorios
func faltan_argumentos_obligatorios(nombre, stack_error=null):
	return HUB.errores.error('Argumento "' + nombre + '" faltante.', stack_error)

# Más argumentos de los esperados
func mas_argumentos_que_los_esperados(cantidad, stack_error=null):
	var txt = 'No se permite'
	if cantidad != 1:
		txt += 'n'
	if cantidad == 0:
		txt += ' argumentos.'
	else:
		txt += ' más de '
		if cantidad == 1:
			txt += 'un argumento.'
		else:
			txt += str(cantidad) + ' argumentos.'
	return HUB.errores.error(txt, stack_error)

# Modificador inválido
func modificador_invalido(modificador, argumento, stack_error=null):
	return HUB.errores.error('El modificador "' + modificador + '" en el argumento "' + argumento + '" es inválido.', stack_error)

# Modificador repetido
func modificador_repetido(modificador, stack_error=null):
	return HUB.errores.error('El modificador "' + modificador + '" se asigna más de una vez.', stack_error)

func restriccion(validador):
	if validador == "BOOL":
		return "un flag"
	elif validador == "NUM":
		return "un número"
	elif validador == "INT":
		return "un entero"
	elif validador == "DEC":
		return "una fracción"
	elif validador.begins_with(">="):
		return "mayor o igual a " + validador.substr(2, validador.length()-2)
	elif validador.begins_with("<="):
		return "menor o igual a " + validador.substr(2, validador.length()-2)
	elif validador.begins_with(">"):
		return "mayor a " + validador.substr(1, validador.length()-1)
	elif validador.begins_with("<"):
		return "menor a " + validador.substr(1, validador.length()-1)

# Argumento de tipo incorrecto
func argumento_tipo_incorrecto(argumento, valor, validador, stack_error=null):
	return HUB.errores.error('Se pasa como argumento "' + argumento + \
	'" el valor "' + valor + '" pero debe ser ' + restriccion(validador) + '.', stack_error)