## Nodo Comandos
## SRC

# Ejecuta los comandos ingresados en la terminal.

extends Node

var HUB
var modulo = get_parent().modulo
# Ruta a la carpeta de comandos de HUB
var carpeta_comandos = "comandos/"
# Diccionario con los comandos cargadas (en nodos)
var comandos_cargados = {} # Dicc(string : nodo)
# Código de comandos
var codigo = "Comando"

func inicializar(hub):
	HUB = hub
	HUB.archivos.codigos_script.append(codigo)
	return true

func ejecutar(comando, argumentos=[]):
	var nodo = cargar(comando)
	if HUB.errores.fallo(nodo):
		return HUB.error(HUB.terminal.comando_no_cargado(comando, nodo), modulo)
	argumentos = parsear_mapa_argumentos(nodo, argumentos)
	if HUB.errores.fallo(argumentos):
		return HUB.error(HUB.terminal.comando_fallido(comando, argumentos), modulo)
	HUB.procesos.apilar_comando(comando)
	var resultado = nodo.comando(argumentos)
	HUB.procesos.desapilar_comando()
	if HUB.errores.fallo(resultado):
		return HUB.error(HUB.terminal.comando_fallido(comando, resultado), modulo)
	return resultado

func cargar(comando):
	if comando in comandos_cargados:
		return comandos_cargados[comando]
	var script_comando = HUB.archivos.abrir(carpeta_comandos, comando + ".gd", codigo)
	if HUB.errores.fallo(script_comando):
		return HUB.error(HUB.terminal.comando_inexistente(comando, script_comando), modulo)
	var nodo = Node.new()
	add_child(nodo)
	nodo.set_name(comando)
	nodo.set_script(script_comando)
	var resultado_inicializar = nodo.inicializar(HUB)
	if HUB.errores.fallo(resultado_inicializar):
		remove_child(nodo)
		nodo.queue_free()
		return HUB.error(HUB.terminal.comando_no_cargado(comando, resultado_inicializar), modulo)
	comandos_cargados[comando] = nodo
	return nodo

func parsear_mapa_argumentos(nodo, lista_de_argumentos):
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