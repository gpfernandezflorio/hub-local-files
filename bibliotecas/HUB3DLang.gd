## HUB3DLang
## Biblioteca

# Funciones para crear objetos parseando el lenguaje HUB3DLang.
# Requiere:
	# Biblioteca tipos
	# Biblioteca parser

extends Node

var HUB
var tipos
var parser_lib
var parser
var modulo = "HUB3DLang"

# CACHE:
var cache = {"PID":{},
			"PATH":{}}	# Sólo Variables y Meshes pero no Hobjetos
var pila_entorno = []	# Diccionarios con "path", "pid", "caching"
						# "namespace" (para objetos que todavía no se agregaron al árbol) y
						# "data" (sólo para argumentos)

func inicializar(hub):
	HUB = hub
	tipos = HUB.bibliotecas.importar("tipos")
	if HUB.errores.fallo(tipos):
		return HUB.error(HUB.errores.inicializar_fallo(self, tipos), modulo)
	parser_lib = HUB.bibliotecas.importar("parser")
	if HUB.errores.fallo(parser_lib):
		return HUB.error(HUB.errores.inicializar_fallo(self, parser_lib), modulo)
	var tds = HUB3DLangTDS.new(self)
	var regex_int = "[0-9]+"
	var regex_float = "[0-9]*\\.[0-9]+"
	var regex_num = "("+regex_float+")|("+regex_int+")"
	var regex_letr = "[a-zA-Z]|_"
	var regex_var = "("+regex_letr+")("+regex_letr+"|/|[0-9])*"
	var regex_opT = "\\+|-|!"
	var regex_num_letrs = "("+regex_num+")("+regex_letr+")+"
	var regex_letrs_float = "("+regex_letr+")+("+regex_float+")"
	var regex_valid = "("+regex_var+")|("+regex_num+")"
	var regex_ex1 = "("+regex_opT+")?"+"(("+regex_num_letrs+")|("+regex_letrs_float+"))"
	var regex_any = "(("+regex_opT+")?("+regex_valid+"))|("+regex_ex1+")"
	var regex_ex = "("+regex_any+")*"+regex_ex1+"("+regex_any+")*"
	var valid_mods = "n|p|s|ox|oy|oz|olx|oly|olz|rx|ry|rz|c|m"
	parser = parser_lib.crear_parser([
		# Un Hobjeto se define a partir de una secuencia de líneas
		# Cada línea puede ser una de estas 3:
		["I",["START","C"]],							# 0
		["I",["$","=","START","C"]],					# 1
		["I",["$","variable","=","START","C"]],			# 2
		# C es un comentario opcional, iniciado con '#'
		# START es una definición. Puede ser un número, un meshRep o un Hobjeto
		# En los primeros dos casos, un número genera un error ya que definen el Hobjeto principal
			# Si hay una línea "$=A", A es el Hobjeto principal (sólo puede haber una de estas)
			# Si hay una única línea "A", A es el Hobjeto principal
			# Si no, el objeto principal será uno que contenga a todos los que se definen de esa forma
				# A menos que la haya exactamente un elemento definido de esta forma, los Hobjetos que ya tienen padre se ignoran
		# En el tercer caso, se define una variable que puede ser accedida por su nombre más adelante
		# Como los últimos dos casos sólo definen variables, devuelven null
		["START",["HOME"]],								# 3
		# HOME es una lista
		# Si tiene más de un elemento, todos ellos deben ser Hobjetos o componentes
			# En tal caso, se devuelve un nuevo Hobjeto cuyos hijos son los Hobjetos de la lista y sus componentes, los componentes de la lista
			# A menos que la lista tenga exactamente un elemento, los Hobjetos que ya tienen padre se ignoran
		# Sólo si la lista tiene un elemento, dicho elemento puede ser un número o un meshRep
		["HOME",["HOME","&","OBJ"]],					# 4
		# En este caso, la lista ya tiene más de un elemento así OBJ debe ser un Hobjeto o un componente
		["HOME",["OBJ"]],								# 5
		# En este caso OBJ puede ser un número, un Hobjeto o un componente pero no una variable
		["OBJ",["EXPR","MODS"]],						# 6
		# Una expresión puede ser de cualquier tipo pero no puede ser null
		# Si tiene modificadores, ya no puede ser un número
		["MODS",["mod","EXPR","MODS"]],					# 7
		["MODS",[]],									# 8
		["ARGS",[]],									# 9
		["ARGS",["(","ARGN",")"]],						# 10
		["ARGN",["ARG"]],								# 11
		["ARGN",["ARGN",",","ARG"]],					# 12
		["EXPR",["EXPR","opT","TERM"]],					# 13
		# Acá me tengo que asegurar que ese TERM sea un número
		["EXPR",["TERM"]],								# 14
		["TERM",["TERM","opF","FACT"]],					# 15
		# Acá me tengo que asegurar que ese FACT sea un número
		["TERM",["FACT"]],								# 16
		["FACT",["opT","FACT"]],						# 17
		# Acá me tengo que asegurar que ese FACT sea un número
		["FACT",["(","START",")"]],						# 18
		["FACT",["PRIM","ARGS"]],						# 19
		# Si tiene argumentos, lo devuelvo como un par
		["PRIM",["variable"]],							# 20
		["PRIM",["numero"]],							# 21
		["ARG",["LARG"]],								# 22
		["ARG",["variable","=","LARG"]],				# 23
		["LARG",["LARG",";","STRING"]],					# 24
		["LARG",["STRING"]],							# 25
		["STRING",["EXPR"]],							# 26
		["STRING",["string"]],							# 27
		["ARG",["=","variable"]],						# 28 # Bool
		["C",[]],										# 29
		["C",["comentario"]]							# 30
	], {
		"variable":regex_var,		# variables
		"numero":regex_num, 		# números
		"mod":":("+valid_mods+")",	# ':' seguido de un identificador de modificador
		"comentario":"#.*",			# Cualquier cosa iniciada con un '#'
		"opT":regex_opT,			# '+', '-' y '!'
		"opF":"\\*|%",				# '*' y '%' (la diagonal '/' la uso para rutas a archivos)
		"string":regex_ex
	}, tds)

func crear(texto, entorno={}):
	if not "pid" in entorno:
		entorno["pid"] = HUB.procesos.actual_pid()
	if not "path" in entorno:
		entorno["path"] = null
	if not "data" in entorno:
		entorno["data"] = {}
	if not "caching" in entorno:
		entorno["caching"] = true
	var nuevos_objetos = [] # El texto podría contener varias líneas
	var raiz = null
	pila_entorno.push_front(entorno)
	for linea in texto.split("\n"):
		if not linea.begins_with("#") and linea.length() > 0:
			var nuevo_objeto = parser_lib.parsear_cadena(parser, linea)
			if HUB.errores.fallo(nuevo_objeto):
				pila_entorno.pop_front()
				return HUB.error(HUB.errores.error('No se pudo generar el objeto "' + linea + '".', nuevo_objeto), modulo)
			nuevo_objeto = nuevo_objeto["valor"]
			if es_una_repH(nuevo_objeto):
				nuevos_objetos.push_back(nuevo_objeto)
	var raiz = objeto_registrado("$")
	if raiz == null:
		if nuevos_objetos.size() == 1:
			raiz = nuevos_objetos[0]
		elif nuevos_objetos.size() > 1:
			var hijos = []
			for hijo in nuevos_objetos:
				if hijo.padre == null:
					hijos.append(hijo)
			if hijos.size() == 0:
				raiz = encontrar_raiz(nuevos_objetos)
			elif hijos.size() == 1:
				raiz = nuevos_objetos[0]
			else:
				raiz = HRep.new(HUB)
				for hijo in hijos:
					raiz.hijos.append(hijo)
	pila_entorno.pop_front()
	if pila_entorno.empty() and raiz != null:
		raiz = raiz.make()
		if HUB.errores.fallo(raiz):
			return raiz
		if raiz[1] == null:
			HUB.nodo_usuario.mundo.agregar_hijo(raiz[0])
		else:
			raiz[1].agregar_hijo(raiz[0])
		raiz = raiz[0]
	return raiz

class HUB3DLangTDS:
	var modulo
	func _init(modulo):
		self.modulo = modulo
	func reduce(produccion, valores):
		return modulo.reduce(produccion, valores)

func reduce(produccion, valores):
	# I -> START C
	if produccion == 0:
		var resultado = valores[0]
		if tipos.es_un_numero(resultado):
			return HUB.error(HUB.errores.error("un número no puede ser la raíz"), modulo)
		if not es_una_repH(resultado):
			resultado = componente_a_objeto(resultado)
		registrar_objeto(resultado.nombre, resultado)
		return resultado
	# I -> $ = START C
	if produccion == 1:
		var resultado = valores[2]
		if tipos.es_un_numero(resultado):
			return HUB.error(HUB.errores.error("un número no puede ser la raíz"), modulo)
		if not tipos.es_una_repH(resultado):
			resultado = componente_a_objeto(resultado)
		registrar_objeto("$", resultado)
		return null
	# I -> $ variable = START C
	if produccion == 2:
		definir(valores[1], valores[3])
		return null
	# START -> HOME
	if produccion == 3:
		if valores[0].size() == 1:
			return valores[0][0]
		var objetos = []
		var componentes = []
		var meshes = []
		for elemento in valores[0]:
			if es_una_repH(elemento) and elemento.padre == null:
				objetos.append(elemento)
			elif es_una_repM(elemento):
				meshes.append(elemento)
			elif es_una_rep(elemento):
				componentes.append(elemento)
		if not meshes.empty():
			componentes.append(union_de_mesh_reps(meshes))
		var nuevo_objeto = HRep.new(HUB)
		for componente in componentes:
			nuevo_objeto.componentes.append(componente)
		for objeto in objetos:
			nuevo_objeto.hijos.append(objeto)
		return nuevo_objeto
	# HOME -> HOME & OBJ
	if produccion == 4:
		if es_una_rep(valores[2]): # HUB.objetos.es_un_objeto(valores[2]) or tipos.es_un_componente(valores[2]) or tipos.es_un_mesh_rep(valores[2]):
			valores[0].append(valores[2])
		else:
			return HUB.error(HUB.errores.error("no se pueden unir con '&'"), modulo)
		return valores[0]
	# HOME -> OBJ
	if produccion == 5:
		return [valores[0]]
	# OBJ -> EXPR MODS
	if produccion == 6:
		var resultado = valores[0]
		if tipos.es_un_string(resultado):
			resultado = base(resultado, [[],{}])
			if HUB.errores.fallo(resultado):
				return resultado
			if tipos.es_un_string(resultado):
				#var res_reg = objeto_registrado(resultado)
				#if res_reg == null:
					var res_obt = obtener(valores[0])
					if res_obt == null:
						return HUB.error(identificador_invalido(resultado), modulo)
					else:
						resultado = res_obt
				#else:
				#	resultado = res_reg
		if tipos.es_una_lista(resultado):
			resultado = base(resultado[0], resultado[1])
			if HUB.errores.fallo(resultado):
				return resultado
		if valores[1].keys().empty():
			return resultado
		if tipos.es_un_numero(resultado):
			return HUB.error(HUB.errores.error("los modificadores no se pueden aplicar a números"), modulo)
		return aplicar_modificaciones(resultado, valores[1])
	# MODS -> mod EXPR MODS
	if produccion == 7:
		var dic = valores[2]
		var i = valores[0].right(1)
		if modificador_admite_varios(i):
			if i in dic:
				dic[i].push_front(valores[1])
			else:
				dic[i] = [valores[1]]
		else:
			dic[i] = valores[1] # Por ahora, me quedo con el primero
		return dic
	# MODS -> []
	if produccion == 8:
		return {}
	# ARGS -> []
	if produccion == 9:
		return [[],{}]
	# ARGS -> ( ARGN )
	if produccion == 10:
		return valores[1]
	# ARGN -> ARG
	if produccion == 11:
		if (valores[0][0].empty()):
			return [[valores[0][1]],{}]
		else:
			return [[],{valores[0][0]:valores[0][1]}]
	# ARGN -> ARGN , ARG
	if produccion == 12:
		if (valores[2][0].empty()):
			valores[0][0].append(valores[2][1])
		else:
			valores[0][1][valores[2][0]] = valores[2][1]
		return valores[0]
	# EXPR -> EXPR op TERM
	if produccion == 13:
		var valor1 = valores[0]
		if tipos.es_un_string(valor1):
			valor1 = obtener_si_esta(valor1)
		var valor2 = valores[2]
		if tipos.es_un_string(valor2):
			valor2 = obtener_si_esta(valor2)
		if tipos.es_un_numero(valor1) and tipos.es_un_numero(valor2):
			if valores[1] == '+':
				return valor1 + valor2
			elif valores[1] == '-':
				return valor1 - valor2
			else: # !
				return HUB.error(HUB.errores.error("no se puede usar '!' como operador entre números"), modulo)
		return str(valores[0])+str(valores[1])+str(valores[2])
	# EXPR -> TERM
	if produccion == 14:
		return valores[0]
	# TERM -> TERM op FACT
	if produccion == 15:
		var valor1 = valores[0]
		if tipos.es_un_string(valor1):
			valor1 = obtener_si_esta(valor1)
		var valor2 = valores[2]
		if tipos.es_un_string(valor2):
			valor2 = obtener_si_esta(valor2)
		if tipos.es_un_numero(valor1) and tipos.es_un_numero(valor2):
			if valores[1] == '*':
				return valor1 * valor2
			elif valores[1] == '%':
				return valor1 / valor2
		return HUB.error(HUB.errores.error("no se puede operar si no son números"), modulo)
	# TERM -> FACT
	if produccion == 16:
		return valores[0]
	# FACT -> op FACT
	if produccion == 17:
		var valor = valores[1]
		if tipos.es_un_string(valor):
			valor = obtener_si_esta(valor)
		if tipos.es_un_numero(valor):
			if valores[0] == '+':
				return valor
			elif valores[0] == '-':
				return -1*valor
			else: # !
				return "!" + str(valor)
		return str(valores[0])+str(valores[1])
	# FACT -> ( START )
	if produccion == 18:
		return valores[1]
	# FACT -> PRIM ARGS
	if produccion == 19:
		if tipos.es_un_string(valores[0]) and valores[0] == "random":
			pila_entorno[0]["caching"] = false
			return random(valores[1][0])
		if valores[1][0].empty() and valores[1][1].keys().empty():
			# Lo devuelvo como texto ya que no sé para qué se va a usar
			return valores[0]
		if tipos.es_un_numero(valores[0]):
			return HUB.error(HUB.errores.error("los números no llevan argumentos"), modulo)
		return [valores[0], valores[1]]
	# PRIM -> variable
	if produccion == 20:
		return valores[0]
	# PRIM -> number
	if produccion == 21:
		return HUB.varios.num(valores[0])
	# ARG -> LARG
	if produccion == 22:
		var resultado = valores[0]
		if resultado.size() == 1:
			resultado = resultado[0]
		return ["",resultado]
	# ARG -> variable : LARG
	if produccion == 23:
		var resultado = valores[2]
		if resultado.size() == 1:
			resultado = resultado[0]
		return [valores[0],resultado]
	# LARG -> LARG ; STRING
	if produccion == 24:
		var resultado = valores[0]
		resultado.append(valores[2])
		return resultado
	# LARG -> STRING
	if produccion == 25:
		return [valores[0]]
	# STRING -> EXPR
	if produccion == 26:
		return valores[0]
	# STRING -> string
	if produccion == 27:
		return valores[0]
	# ARG -> = variable
	if produccion == 28:
		return [valores[1],""]
	return null

# Auxiliares

func aplicar_modificaciones(algo, mods):
	var resultado = algo
	for modificador in mods.keys():
		# NOMBRE
		if (modificador == "n"):
			resultado.nombre = mods["n"]
			if es_una_repH(resultado):
				registrar_objeto(mods["n"], resultado)
		# PARENT
		elif (modificador == "p"):
			if not es_una_repH(resultado):
				resultado = componente_a_objeto(resultado)
			var ubicacion = "L"
			var hijo_de = objeto_registrado(mods["p"])
			if hijo_de == null:
				ubicacion = "G"
				hijo_de = HUB.objetos.localizar(mods["p"])
				if HUB.errores.fallo(hijo_de):
					return HUB.error(parent_invalido(mods["p"], hijo_de), modulo)
			resultado.padre = [ubicacion, hijo_de]
		# SCRIPT
		elif (modificador == "s"):
			if not es_una_repH(resultado):
				resultado = componente_a_objeto(resultado)
			var scripts = mods["s"]
			for script in scripts:
				var args = [[],{}]
				if tipos.es_una_lista(script):
					args = script[1]
					script = script[0]
				resultado.comportamientos.append([script,args])
		# OFFSET
		elif (modificador.begins_with("o")):
			var local = false # ¿relativo a la rotación?
			var eje = modificador[1]
			if eje == "l":
				local = true
				eje = modificador[2]
			var movimiento = Vector3(0,0,0)
			var valor = mods[modificador]
			if tipos.es_un_string(valor):
				valor = obtener_como_numero(valor)
				if HUB.errores.fallo(valor):
					return valor
			if not tipos.es_un_numero(valor):
				return HUB.error(HUB.errores.error('Tipo inválido para el modificador "' + modificador + '".'), modulo)
			if eje == "x":
				movimiento.x = valor
			elif eje == "y":
				movimiento.y = valor
			elif eje == "z":
				movimiento.z = valor
			else:
				return HUB.error(HUB.errores.error('Eje inválido para el modificador "' + modificador + '".'), modulo)
			resultado.offset(movimiento, local)
		# ROTATE
		elif (modificador.begins_with("r")):
			var eje = modificador[1]
			var valor = mods[modificador]
			if tipos.es_un_string(valor):
				valor = obtener_como_numero(valor)
				if HUB.errores.fallo(valor):
					return valor
			if not tipos.es_un_numero(valor):
				return HUB.error(HUB.errores.error('Tipo inválido para el modificador "' + modificador + '".'), modulo)
			if eje == "x":
				resultado.rotate_x(valor)
			elif eje == "y":
				resultado.rotate_y(valor)
			elif eje == "z":
				resultado.rotate_z(valor)
			else:
				return HUB.error(HUB.errores.error('Eje inválido para el modificador "' + modificador + '".'), modulo)
		# COLLIDER
		elif (modificador == "c"):
			var body = null
			if es_una_repC(resultado):
				if resultado.tipo == "BODY":
					body = resultado
				else:
					return HUB.error(HUB.errores.error('No se puede agregar el colisionador si el componente no es un body'), modulo)
			else:
				# revisar si algún componente es de tipo body y si no:
				return HUB.error(HUB.errores.error('No se puede agregar el colisionador si el objeto no tiene un componente body'), modulo)
			var resultado_colision = agregar_colisionador(body, mods["c"])
			if HUB.errores.fallo(resultado_colision):
				return resultado_colision
		# MATERIAL
		elif (modificador == "m"):
			var meshes = []
			if es_una_repC(resultado):
				if resultado.tipo == "MESH":
					meshes.append(resultado)
				else:
					return HUB.error(HUB.errores.error('No se puede agregar el material si el componente no es una malla'), modulo)
			else:
				meshes = agregar_componentes_meshes(meshes, resultado)
				if meshes.empty():
					return HUB.error(HUB.errores.error('No se puede agregar el material si el objeto no tiene un componente malla'), modulo)
			var resultado_material = agregar_material(meshes, mods["m"])
			if HUB.errores.fallo(resultado_material):
				return resultado_material
		else:
			return HUB.error(modificador_invalido(modificador), modulo)
	return resultado

func encontrar_raiz(objetos):
	# Asume que todos tienen padre
	for obj in objetos:
		if not obj.padre[1] in objetos:
			return obj
	return null

func agregar_componentes_meshes(meshes, obj):
	var result = meshes
	for componente in obj.componentes:
		if es_una_repM(componente):
			result.append(componente)
	for hijo in obj.hijos:
		result = agregar_componentes_meshes(result, hijo)
	return result

func base(texto, argumentos):
	# OJO: "argumentos" es un par lista-diccionario
	if texto == "_":
		return HRep.new(HUB)
	var sin_argumentos = argumentos[0].empty() and argumentos[1].keys().empty()
	if sin_argumentos:
		var valor = obtener(texto)
		if valor != null:
			return valor
	var archivo = buscar_archivo(texto)
	if archivo != null:
		return desde_archivo(archivo, argumentos)
	if sin_argumentos:
		return texto
	return HUB.error(HUB.errores.error('primitiva "'+texto+'" no definida'), modulo)

func definir(clave, valor):
	if pila_entorno[0]["caching"]:
		var path = pila_entorno[0]["path"]
		var pid = pila_entorno[0]["pid"]
		if path != null:
			definir_path(path, clave, valor)
		else:
			definir_pid(pid, clave, valor)
	else:
		pila_entorno[0]["data"][clave] = valor

func definir_pid(pid, clave, valor):
	var dict = cache["PID"]
	if pid in cache["PID"]:
		cache["PID"][pid][clave] = valor
	else:
		cache["PID"][pid] = {clave:valor}

func definir_path(path, clave, valor):
	var recorrido = path.split("/")
	var dict = cache["PATH"]
	for d in recorrido:
		if not d in dict:
			dict[d] = {}
		dict = dict[d]
	if not clave in dict:
		dict[clave] = {}
	dict[clave]["."] = valor

func registrar_objeto(clave, objeto):
	if "namespace" in pila_entorno[0]:
		pila_entorno[0]["namespace"][clave] = objeto
	else:
		pila_entorno[0]["namespace"] = {clave:objeto}

func objeto_registrado(clave):
	for e in pila_entorno:
		if "namespace" in e and clave in e["namespace"]:
			return e["namespace"][clave]
	return null

func obtener(clave):
	# Primero la busco en el entorno
	for e in pila_entorno:
		if clave in e["data"]:
			var valor = e["data"][clave]
			if es_una_rep(valor):
				return copiar_rep(valor)
			else:
				return valor
	# Si no está en el entorno, la busco en la cache
	var path = pila_entorno[0]["path"]
	if path == null:
		path = ""
	var obt_path = obtener_path(path, clave)
	if obt_path != null:
		return obt_path
	var pid = pila_entorno[0]["pid"]
	var obt_pid = obtener_pid(pid, clave)
	if obt_pid != null:
		return obt_pid
	return null

func obtener_pid(pid, clave):
	if pid in cache["PID"]:
		if clave in cache["PID"][pid]:
			var valor = cache["PID"][pid][clave]
			if es_una_rep(valor):
				return copiar_rep(valor)
			else:
				return valor
	return null

func obtener_path(path, clave):
	var recorrido = path.split("/")
	for i in range(recorrido.size()):
		var ruta = ""
		for j in range(recorrido.size()-i-1):
			ruta += recorrido[j] + "/"
		ruta += recorrido[recorrido.size()-i-1]
		var aux = obtener_path_aux(ruta, clave)
		if aux != null:
			return aux
	return null

func obtener_path_aux(path, clave):
	var recorrido = path.split("/")
	var dict = cache["PATH"]
	for d in recorrido:
		if not d in dict:
			return null
		dict = dict[d]
	if clave in dict:
		dict = dict[clave]
		if "." in dict:
			var valor = dict["."]
			if es_una_rep(valor):
				return copiar_rep(valor)
			else:
				return valor
	return null

func obtener_si_esta(clave):
	var valor = obtener(clave)
	if valor == null:
		return clave
	return valor

func obtener_como_numero(clave):
	if clave.is_valid_integer():
		return int(clave)
	if clave.is_valid_float():
		return float(clave)
	var valor = obtener(clave)
	if valor == null:
		return HUB.error(identificador_invalido(clave), modulo)
	return valor

func componente_a_objeto(componente):
	var nuevo_objeto = HRep.new(HUB)
	nuevo_objeto.componentes.append(componente)
	if componente.nombre != null and not componente.nombre.begins_with("@@"):
		nuevo_objeto.nombre = componente.nombre
	return nuevo_objeto

func buscar_archivo(nombre):
	var ruta_actual = pila_entorno[0]["path"]
	if ruta_actual != null:
		var recorrido = ruta_actual.split("/")
		for i in range(recorrido.size()):
			var ruta = ""
			for j in range(recorrido.size()-i):
				ruta += recorrido[j] + "/"
			ruta = ruta.plus_file(nombre)
			if HUB.archivos.existe("objetos", ruta + ".gd"):
				return ruta
	if HUB.archivos.existe("objetos", nombre + ".gd"):
		return nombre
	return null

func desde_archivo(ruta_completa, argumentos):
	if pila_entorno[0]["caching"] and argumentos[0].empty() and argumentos[1].keys().empty():
		var en_cache = obtener(ruta_completa)
		if en_cache != null:
			return en_cache
	var contenido_archivo = HUB.archivos.leer("objetos", ruta_completa + ".gd", "Objeto")
	if HUB.errores.fallo(contenido_archivo):
		return contenido_archivo
	# La función leer retornó ok, así que esto no puede fallar:
	var tipo_archivo = contenido_archivo.split("\n")[2]
	tipo_archivo = HUB.varios.str_desde(tipo_archivo,3)
	if tipo_archivo == "HUB3DLang":
		return desde_archivo_obj(ruta_completa, contenido_archivo, argumentos)
	if tipo_archivo == "Funcion":
		return desde_archivo_func(ruta_completa, argumentos)
	# Nunca debería llegar acá...
	return null

func desde_archivo_obj(ruta_completa, contenido_archivo, argumentos):
	var data_entorno = {}
	var i=1
	for argumento in argumentos[0]:
		data_entorno[str(i)] = argumento
		i+=1
	for argumento in argumentos[1].keys():
		data_entorno[argumento] = argumentos[1][argumento]
	var entorno = {
		"data":data_entorno,
		"pid":pila_entorno[0]["pid"],
		"path":ruta_completa,
		"caching":data_entorno.keys().size()==0
	}
	var obj = crear(contenido_archivo, entorno)
	if pila_entorno[0]["caching"] and data_entorno.keys().size()==0:
		definir_path(ruta_completa, ".", obj)
	return obj

func desde_archivo_func(nombre, argumentos):
	var resultado = HUB.objetos.generar(nombre, argumentos)
	if tipos.es_un_string(resultado):
		var entorno = {
			"data":{}, # ¿No debería pasarle también lo generado en la versión _obj?
			"pid":pila_entorno[0]["pid"],
			"path":nombre,
			"caching":false
		}
		return crear(resultado, entorno)
	return resultado

func modificador_admite_varios(mod):
	return mod in ["s","c"]

var valid_colls = {
	"plane":{"arg_map":
		{"lista":[
		]},
		"clase":PlaneShape, "nombre":"Plane Collider",
	},
	"box":{"arg_map":
		{"lista":[
			{"nombre":"ancho", "codigo":"w", "default":"!1"},
			{"nombre":"alto", "codigo":"h", "default":"1"},
			{"nombre":"profundidad", "codigo":"p", "default":"!1"}
		]},
		"clase":BoxShape, "nombre":"Box Collider"
	},
	"ball":{"arg_map":
		{"lista":[
			{"nombre":"radio", "codigo":"r", "default":"!1"}
		]},
		"clase":SphereShape, "nombre":"Ball Collider"
	},
	"capsule":{"arg_map":
		{"lista":[
			{"nombre":"radio", "codigo":"r", "default":"!1"},
			{"nombre":"alto", "codigo":"h", "default":"1"},
			{"nombre":"vertical", "codigo":"v", "validar":"BOOL","default":false}
		]},
		"clase":CapsuleShape, "nombre":"Capsule Collider"
	}
}

func agregar_colisionador(body, cs):
	for c in cs:
		var id = c
		var args = [[],{}]
		if tipos.es_una_lista(c):
			id = c[0]
			args = c[1]
		if id in valid_colls.keys():
			args = HUB.varios.parsear_argumentos_general(valid_colls[id]["arg_map"], args, modulo)
			if HUB.errores.fallo(args):
				return args
			var shape = valid_colls[id]["clase"].new()
			var t = Transform()
			var pos = Vector3(0,0,0)
			if id == "box":
				var coordenadas = HUB.varios.coordenadas_cubo(args["w"],args["h"],args["p"], self, tipos, false)
				if HUB.errores.fallo(coordenadas):
					return coordenadas
				pos.x = coordenadas[0]
				var w = coordenadas[1]
				pos.y = coordenadas[2]
				var h = coordenadas[3]
				pos.z = coordenadas[4]
				var p = coordenadas[5]
				shape.set_extents(Vector3(w/2.0,h/2.0,p/2.0))
			elif id in ["ball","capsule"]:
				var r = args["r"]
				var center_r = false
				if tipos.es_un_string(r):
					if r[0] == "!":
						center_r = true
						r = HUB.varios.str_desde(r,1)
					r = obtener_como_numero(r)
					if HUB.errores.fallo(r):
						return r
				if tipos.es_un_numero(r):
					shape.set_radius(r)
				else:
					return HUB.error(HUB.errores.error('Argumento inválido: '+r), modulo)
				if not center_r:
					pos.y = r/2
				if id == "capsule":
					var rotated = args["v"]
					var h = args["h"]
					var center_h = false
					if tipos.es_un_string(h):
						if h[0] == "!":
							center_h = true
							h = HUB.varios.str_desde(h,1)
						h = obtener_como_numero(h)
						if HUB.errores.fallo(h):
							return h
					if tipos.es_un_numero(h):
						shape.set_height(h-2*r)
						if not center_h:
							if rotated:
								pos.z = h/2
							else:
								pos.x = h/2
					else:
						return HUB.error(HUB.errores.error('Argumento inválido: '+h), modulo)
					if rotated:
						t = t.rotated(Vector3(1,0,0),PI/2)
			t = t.translated(pos)
			body.shapes.append(
				{"nombre":valid_colls[id]["nombre"],
				"shape":shape,
				"transform":t}
			)
		else:
			return HUB.error(HUB.errores.error('Identificador de colisionador inválido: '+id), modulo)

var material_arg_map = {"lista":[
	{"nombre":"color", "codigo":"c", "default":Color("ffffff"), "validar":"COLOR"}
]}

func agregar_material(meshes, mat):
	var id = mat
	var args = [[],{}]
	if tipos.es_una_lista(mat):
		id = mat[0]
		args = mat[1]
	var material = obtener(id)
	if material != null:
		if typeof(material) != 18 or material.get_type() != "FixedMaterial":
			return HUB.error(HUB.errores.error('No es un material: '+id), modulo)
	elif id != "fixed":
		return HUB.error(HUB.errores.error('Identificador de material inválido: '+id), modulo)
	args = HUB.varios.parsear_argumentos_general(material_arg_map, args, modulo)
	if HUB.errores.fallo(args):
		return HUB.error(HUB.errores.error('No se pudo generar el material', args), modulo)
	if material == null:
		material = FixedMaterial.new()
	material.set("params/diffuse", args["c"])
	for mi in meshes:
		mi.material = material

func union_de_mesh_reps(meshes):
	var resultado = meshes[0]
	meshes.pop_front()
	while(not meshes.empty()):
		resultado.merge(meshes[0])
		meshes.pop_front()
	return resultado

func random(argumentos):
	var tipo = "f"
	var rango = [0,1]
	if not argumentos.empty():
		if tipos.es_un_string(argumentos[0]):
			tipo = argumentos[0]
			argumentos.pop_front()
		else:
			tipo = "i"
	if tipo == "f":
		if argumentos.size() == 1:
			rango[1] = argumentos[0]
		else:
			if argumentos.size() > 1:
				rango[0] = argumentos[0]
				rango[1] = argumentos[1]
		return rango[0] + randf()*(rango[1]-rango[0])
	if tipo == "i":
		var step = 1
		if argumentos.size() == 1:
			rango[0] = 1
			rango[1] = argumentos[0]
		else:
			if argumentos.size() > 1:
				rango[0] = argumentos[0]
				rango[1] = argumentos[1]
			if argumentos.size() > 2:
				step = argumentos[2]
		return rango[0] + step*(randi() % ((rango[1]+step-rango[0])/step))
	if tipo == "h":
		return random_hex(argumentos)
	if tipo == "c":
		var args_r = []
		var args_g = []
		var args_b = []
		if argumentos.size() > 0:
			args_r = argumentos[0]
		if argumentos.size() > 1:
			args_g = argumentos[1]
		if argumentos.size() > 2:
			args_b = argumentos[2]
		var r = random_hex(args_r)
		var g = random_hex(args_g)
		var b = random_hex(args_b)
		return r+g+b

func random_hex(argumentos):
	var rango = [0,15]
	if argumentos.size() == 1:
		rango[1] = argumentos[0]
	elif argumentos.size() > 1:
		rango[0] = argumentos[0]
		rango[1] = argumentos[1]
	return int_to_hex(rango[0] + randi() % (rango[1]+1-rango[0]))

func int_to_hex(i):
	if i <= 0:
		return "0"
	if i < 10:
		return str(i)
	if i < 16:
		return ["a","b","c","d","e","f"][i-10]
	return "0"

func es_una_rep(algo):
	return typeof(algo) == TYPE_OBJECT and algo.has_method("make")

func es_una_repH(algo):
	return es_una_rep(algo) and "tipo" in algo and algo.tipo == "HOBJ"

func es_una_repC(algo):
	return es_una_rep(algo) and not es_una_repH(algo)

func es_una_repM(algo):
	return es_una_rep(algo) and "tipo" in algo and algo.tipo == "MESH"

func copiar_rep(original):
	if es_una_repH(original):
		return copiar_rep_h(original)
	return copiar_rep_c(original)

func copiar_rep_h(original):
	var copia = HRep.new(HUB)
	copia.nombre = original.nombre
	copia.padre = original.padre
	for c in original.componentes:
		copia.componentes.append(copiar_rep_c(c))
	for c in original.comportamientos:
		var args = [[],{}]
		for a in c[1][0]:
			args[0].append(a)
		for a in c[1][1].keys():
			args[1][a] = c[1][1][a]
		var c2 = [c[0],args]
		copia.comportamientos.append(c2)
	for h in original.hijos:
		copia.hijos.append(copiar_rep_h(h))
	copia.transform = Spatial.new()
	copia.transform.set_transform(original.transform.get_transform())
	return copia

class HRep:			# Hobjeto
	var tipo = "HOBJ"
	var nombre			# String
	var padre			# Par String-referencia (el string indica si el Local o Global) o null
	var componentes		# Lista de otros Rep que tengan "make"
	var comportamientos	# Lista de pares String-arg_map
	var hijos			# Lista de HRep
	var transform		# Spatial
	var HUB
	var pi_180 = PI/180.0
	func _init(HUB):
		nombre = null
		componentes = []
		comportamientos = []
		hijos = []
		transform = Spatial.new()
		self.HUB = HUB
		padre = null
	func offset(movimiento, local):
		if local:
			transform.translate(movimiento)
		else:
			transform.set_translation(transform.get_transform().origin + movimiento)
	func rotate_x(a):
		transform.rotate_x(a*pi_180)
	func rotate_y(a):
		transform.rotate_y(a*pi_180)
	func rotate_z(a):
		transform.rotate_z(a*pi_180)
	func make():
		var resultado = HUB.objetos.crear(null)
		if nombre != null:
			resultado.nombrar(nombre)
		for hijo in hijos:
			var res = hijo.make()
			if HUB.errores.fallo(res):
				return res
			resultado.agregar_hijo(res[0])
		for componente in componentes:
			resultado.agregar_componente(componente.make())
		for comportamiento in comportamientos:
			var c = resultado.agregar_comportamiento(comportamiento[0], comportamiento[1])
			if HUB.errores.fallo(c):
				return HUB.error(HUB.errores.error('No se pudo agregar el comportamiento "' + comportamiento[0] + '".', c))
		resultado.set_transform(transform.get_transform())
		return [resultado, padre]

class CRep:			# Componente genérico
	var tipo
	var nombre
	var clase			# Class
	var script			# String
	var transform		# Spatial
	var params			# Dict
	var HUB
	var pi_180 = PI/180.0
	func _init(HUB, tipo, clase, script, nombre):
		self.tipo = tipo
		self.nombre = nombre
		self.clase = clase
		self.script = script
		transform = Spatial.new()
		params = {}
		self.HUB = HUB
	func rotate_x(a):
		transform.rotate_x(a*pi_180)
	func rotate_y(a):
		transform.rotate_y(a*pi_180)
	func rotate_z(a):
		transform.rotate_z(a*pi_180)
	func offset(movimiento, local):
		if local:
			transform.translate(movimiento)
		else:
			transform.set_translation(transform.get_transform().origin + movimiento)
	func set(arg, val):
		params[arg] = val
	func make():
		var resultado = HUB.GC.crear_nodo(clase)
		if nombre != null:
			resultado.set_name(nombre)
		if script != null:
			resultado.set_script(script)
		for p in params.keys():
			if p in resultado:
				resultado.set(p, params[p])
		resultado.set_transform(transform.get_transform())
		return resultado

class BodyRep extends CRep:
	var shapes
	func _init(H,t,c,s,n).(H,t,c,s,n):
		shapes = []
	func make():
		var resultado = .make()
		for shape in shapes:
			var collider = CollisionShape.new()
			var forma = shape["shape"].duplicate()
			collider.set_name(shape["nombre"])
			collider.set_shape(forma)
			var t = shape["transform"]
			resultado.add_shape(forma, t)
			resultado.add_child(collider)	# DEBUG
			collider.set_transform(t)		# DEBUG
		return resultado

func copiar_rep_c(original):
	if es_una_repM(original):
		return copiar_rep_m(original)
	var clase = CRep
	if original.tipo == "BODY":
		clase = BodyRep
	var copia = clase.new(HUB, original.tipo, original.clase, original.script, original.nombre)
	copia.transform = Spatial.new()
	copia.transform.set_transform(original.transform.get_transform())
	for p in original.params:
		copia.params[p] = original.params[p]
	if original.tipo == "BODY":
		for shape in original.shapes:
			copia.shapes.append({
				"nombre":shape["nombre"],
				"shape":shape["shape"].duplicate(),
				"transform":Transform(shape["transform"])
			})
	return copia

func copiar_rep_m(original):
	var vs = []
	var fs = []
	var uvs = []
	for v in original.vertexes:
		vs.push_back(v)
	for f in original.faces:
		fs.push_back(f)
	for uv in original.uvs:
		uvs.push_back(uv)
	return MeshRep.new(vs, fs, uvs, original.nombre)

class MeshRep:
	var tipo = "MESH"
	var nombre
	var vertexes	# Vector3
	var uvs			# Vector2
	var faces		# FaceRep
	var pi_180 = PI/180.0
	var material = null
	func _init(vs, fs, uvs, nombre="malla"):
		self.nombre = nombre
		self.vertexes = vs
		self.faces = fs
		self.uvs = uvs
	func merge(otro):
		for f in otro.faces:
			f.plus(vertexes.size(),uvs.size())
			faces.append(f)
		for v in otro.vertexes:
			vertexes.append(v)
		for uv in otro.uvs:
			uvs.append(uv)
		# TODO: Eliminar vértices repetidos
	func rotate_x(a):
		for i in range(vertexes.size()):
			vertexes[i] = vertexes[i].rotated(Vector3(1.0,0.0,0.0),a*pi_180)
	func rotate_y(a):
		for i in range(vertexes.size()):
			vertexes[i] = vertexes[i].rotated(Vector3(0.0,1.0,0.0),a*pi_180)
	func rotate_z(a):
		for i in range(vertexes.size()):
			vertexes[i] = vertexes[i].rotated(Vector3(0.0,0.0,1.0),a*pi_180)
	func offset(a, local): # IGNORO argumento "local"
		for i in range(vertexes.size()):
			vertexes[i] += a
	func make():
		var mesh = Mesh.new()
		var st = SurfaceTool.new()
		st.begin(VS.PRIMITIVE_TRIANGLES)
		for f in faces:
			if (f.size()==3 or f.size()==4):
				if (f.uvs[2] > -1):
					st.add_uv(uvs[f.uvs[2]])
				st.add_vertex(vertexes[f.vertexes[2]])
				if (f.uvs[1] > -1):
					st.add_uv(uvs[f.uvs[1]])
				st.add_vertex(vertexes[f.vertexes[1]])
				if (f.uvs[0] > -1):
					st.add_uv(uvs[f.uvs[0]])
				st.add_vertex(vertexes[f.vertexes[0]])
			if (f.size()==4):
				if (f.uvs[0] > -1):
					st.add_uv(uvs[f.uvs[0]])
				st.add_vertex(vertexes[f.vertexes[0]])
				if (f.uvs[3] > -1):
					st.add_uv(uvs[f.uvs[3]])
				st.add_vertex(vertexes[f.vertexes[3]])
				if (f.uvs[2] > -1):
					st.add_uv(uvs[f.uvs[2]])
				st.add_vertex(vertexes[f.vertexes[2]])
		st.generate_normals()
		st.index()
		st.commit(mesh)
		if material != null:
			for i in range(mesh.get_surface_count()):
				mesh.surface_set_material(i, material)
		var resultado = MeshInstance.new()
		resultado.set_name(nombre)
		resultado.set_mesh(mesh)
		return resultado

class FaceRep:
	var vertexes	# int
	var uvs			# int
	#var groups		# ??
	func _init(vs, uvs):
		self.vertexes = vs
		self.uvs = uvs
		# Me aseguro que los tamaños coincidan:
		for i in range(vs.size() - uvs.size()):
			self.uvs.append(-1)
	func plus(v, u):
		for i in range(vertexes.size()):
			vertexes[i] += v
		for i in range(uvs.size()):
			uvs[i] += u
	func size():
		return vertexes.size()

func nuevo_mesh_rep(vs, fs, uvs, nombre=null):
	return MeshRep.new(vs, fs, uvs, nombre)

func nueva_cara(vs, uvs):
	return FaceRep.new(vs, uvs)

func nueva_camara():
	return nuevo_componente("camara", "OTROS", "cámara")

func nuevo_body(tipo):
	return nuevo_componente(tipo, "BODY", "body", BodyRep)

func nueva_luz(tipo):
	return nuevo_componente(tipo, "OTROS", "luz")

func nuevo_audio():
	return nuevo_componente("audio", "OTROS", "audio")

func nuevo_componente(tipo, grupo, nombre, baseRep = CRep):
	if tipo in componentes_validos.keys():
		var script = null
		var ruta_componentes = HUB.objetos.ruta_componentes()
		if HUB.archivos.existe(ruta_componentes, tipo+".gd"):
			script = HUB.archivos.abrir(ruta_componentes, tipo+".gd")
		return baseRep.new(HUB, grupo, componentes_validos[tipo], script, nombre)
	return HUB.error(HUB.errores.error('Componente desconocido: '+tipo), modulo)

var componentes_validos = {
	# body
	"static":StaticBody,
	"rigid":Spatial, # Caso especial. Lo maneja el script 'rigid.gd'
	"kinematic":Spatial, # Caso especial. Lo maneja el script 'kinematic.gd'
	# luz
	"omni":OmniLight,
	"spot":SpotLight,
	"dir":DirectionalLight,
	"ambient":WorldEnvironment,
	# otros
	"camara":Camera,
	"audio":Spatial # Caso especial. Lo maneja el script 'audio.gd'
}

# Errores

# identificador invalido
func identificador_invalido(id, stack_error = null):
	return HUB.errores.error('El identificador "' +\
	id + '" no está definido.', stack_error)

# modificador invalido
func modificador_invalido(modificador, stack_error = null):
	return HUB.errores.error('El modificador "' +\
	modificador + '" no está definido.', stack_error)

# parent invalido
func parent_invalido(parent, stack_error = null):
	return HUB.errores.error('No se puede anidar el nuevo objeto bajo el padre "' +\
	parent + '".', stack_error)