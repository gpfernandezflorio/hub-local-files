## Varios
## SRC

# Funciones y otras utilidades generales.
# Requiere para inicializar:
	# -

extends Node

var HUB

func inicializar(hub):
	HUB = hub
	return true

func parsear_argumentos_objetos(nodo, args, modulo):
	if "arg_map" in nodo:
		return parsear_argumentos_general(nodo.arg_map, args, modulo)
	return args

func parsear_argumentos_comportamientos(nodo, args, modulo):
	if "arg_map" in nodo:
		return parsear_argumentos_general(nodo.arg_map, args, modulo)
	return args

func parsear_argumentos_comandos(nodo, lista_de_argumentos, modulo):
	if "arg_map" in nodo:
		var codigos_vistos = []
		var args = {}
		var argumentos_libres = []
		for arg in lista_de_argumentos:
			if arg.begins_with("-") and not arg.is_valid_float():
				var codigo = arg[1]
				var valor = str_desde(arg,2)
				var d = arg.find("=")
				if d != -1:
					codigo = arg.substr(1,d-1)
					valor = str_desde(arg,d+1)
				if codigo in codigos_vistos:
					return HUB.error(modificador_repetido(codigo), modulo)
				args[codigo] = valor
				codigos_vistos.append(codigo)
			else:
				argumentos_libres.append(arg)
		return parsear_argumentos_general(nodo.arg_map, [argumentos_libres, args], modulo)
	return lista_de_argumentos

func parsear_argumentos_general(arg_map, args, modulo):
	var resultado = args[1]
	var codigos_vistos = []
	var codigos_validos = []
	# Inicializar los valores default (y unificar código de identificación)
	for arg in arg_map.lista:
		codigos_validos.append(arg.codigo)
		if arg.codigo in resultado:
			codigos_vistos.append(arg.codigo)
			if (arg.nombre != arg.codigo) and (arg.nombre in resultado):
				return HUB.error(modificador_repetido_por_nombre(arg.codigo, arg.nombre), modulo)
		else:
			if arg.nombre in resultado:
				resultado[arg.codigo] = resultado[arg.nombre]
				resultado.erase(arg.nombre)
				codigos_vistos.append(arg.codigo)
			elif "default" in arg:
				resultado[arg.codigo] = arg.default
			else:
				resultado[arg.codigo] = null
	# Verificar modificadores/nombres válidos
	for k in resultado:
		if not k in codigos_validos:
			return HUB.error(modificador_invalido(k, resultado[k]), modulo)
	var obligatorios = 0
	if "obligatorios" in arg_map:
		obligatorios = arg_map.obligatorios
	var argumentos_libres = args[0]
	# Verificar que se pasaron todos los argumentos obligatorios
	for i in range(obligatorios):
		var codigo = arg_map.lista[i].codigo
		if not codigo in codigos_vistos:
			# No se pasó como modificador pero podría estar entre los libres
			if not argumentos_libres.empty():
				resultado[codigo] = argumentos_libres[0]
				codigos_vistos.append(codigo)
				argumentos_libres.pop_front()
			else:
				return HUB.error(faltan_argumentos_obligatorios(arg_map.lista[i].nombre), modulo)
	# Mapear los argumentos sin nombre (args[0])
	var acepta_argumentos_extra = "extra" in arg_map
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
			var validacion = validar_argumento(arg, resultado[arg.codigo], modulo)
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

func validar_argumento(arg, valor, modulo):
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
			if resultado < num(str_desde(validador,2)):
				return HUB.error(argumento_tipo_incorrecto(arg.nombre, valor, validador), modulo)
		elif validador.begins_with("<="):
			if resultado > num(str_desde(validador,2)):
				return HUB.error(argumento_tipo_incorrecto(arg.nombre, valor, validador), modulo)
		elif validador.begins_with(">"):
			if resultado <= num(str_desde(validador,1)):
				return HUB.error(argumento_tipo_incorrecto(arg.nombre, valor, validador), modulo)
		elif validador.begins_with("<"):
			if resultado >= num(str_desde(validador,1)):
				return HUB.error(argumento_tipo_incorrecto(arg.nombre, valor, validador), modulo)
	return resultado

func str_desde(s, i):
	return s.substr(i, s.length()-i)

func coordenadas_cubo(w,h,p,h3,tipos,for_mesh=false):
	var center_x = false
	var center_y = false
	var center_z = false
	# ANCHO
	if tipos.es_un_string(w):
		if w.begins_with("!"):
			center_x = true
			w = HUB.varios.str_desde(w, 1)
		if w.is_valid_float():
			w = float(w)
		elif h3.esta_definido(w):
			w = h3.obtener(w)
		else:
			return HUB.error(h3.identificador_invalido(w), h3.modulo)
	# ALTO
	if tipos.es_un_string(h):
		if h.begins_with("!"):
			center_y = true
			h = HUB.varios.str_desde(h, 1)
		if h.is_valid_float():
			h = float(h)
		elif h3.esta_definido(h):
			h = h3.obtener(h)
		else:
			return HUB.error(h3.identificador_invalido(h), h3.modulo)
	# PROF.
	if tipos.es_un_string(p):
		if p.begins_with("!"):
			center_z = true
			p = HUB.varios.str_desde(p, 1)
		if p.is_valid_float():
			p = float(p)
		elif h3.esta_definido(p):
			p = h3.obtener(p)
		else:
			return HUB.error(h3.identificador_invalido(p), h3.modulo)
	# Posiciones sobre el plano
	var x0 = 0.0
	var x1 = w
	var y0 = 0.0
	var y1 = h
	var z0 = 0.0
	var z1 = p
	if for_mesh:
		if center_x:
			x1 *= 0.5
			x0 -= x1
		if center_y:
			y1 *= 0.5
			y0 -= y1
		if center_z:
			z1 *= 0.5
			z0 -= z1
	else:
		if not center_x:
			x0 += 0.5*x1
		if not center_y:
			y0 += 0.5*y1
		if not center_z:
			z0 += 0.5*z1
	return [x0,x1,y0,y1,z0,z1]

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
func modificador_invalido(modificador, valor, stack_error=null):
	return HUB.errores.error('El modificador "' + modificador + '" con valor "' + valor + '" es inválido.', stack_error)

# Modificador repetido
func modificador_repetido(modificador, stack_error=null):
	return HUB.errores.error('El modificador "' + modificador + '" se asigna más de una vez.', stack_error)

# Modificador repetido (por nombre)
func modificador_repetido_por_nombre(codigo, nombre, stack_error=null):
	return HUB.errores.error('El modificador con nombre "' + nombre + '" se asigna también con "' + codigo + '".', stack_error)

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
		return "mayor o igual a " + str_desde(validador,2)
	elif validador.begins_with("<="):
		return "menor o igual a " + str_desde(validador,2)
	elif validador.begins_with(">"):
		return "mayor a " + str_desde(validador,1)
	elif validador.begins_with("<"):
		return "menor a " + str_desde(validador,1)

# Argumento de tipo incorrecto
func argumento_tipo_incorrecto(argumento, valor, validador, stack_error=null):
	return HUB.errores.error('Se pasa como argumento "' + argumento + \
	'" el valor "' + valor + '" pero debe ser ' + restriccion(validador) + '.', stack_error)
