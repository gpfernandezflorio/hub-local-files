## Parser
## Biblioteca

# Clases y funciones para crear parsers.
# Requiere:
	# Biblioteca estructuras
	# Biblioteca printer

extends Node

var HUB
var estructuras
var printer

var modulo = "Parser"

# caracteres a escapear cuando se genera el regex para un token
var regex_escape = ['+','\\','(',')','.','*','$']

func inicializar(hub):
	HUB = hub
	estructuras = HUB.bibliotecas.importar("estructuras")
	printer = HUB.bibliotecas.importar("printer")

# Crea un parser a partir de:
	# La lista de producciones P, donde cada produccion
		# es una lista de dos elementos. El primero, el no terminal
		# a la izquierda de la produccion y el segundo, la lista de
		# símbolos a la derecha de la produccion.
	# Un diccionario de expresiones regulares para tokens. No es
		# necesario que estén todos los terminales, sólo los que
		# requieren expresiones regulares. Las que no estén, matchearán
		# el string idéntico al terminal
func crear_parser(P, regexes_para_tokens, tds):
	var G = crear_gramatica(P)
	var A = construir_automata(G)
	var tabla = construir_tabla(G, A)
	var token_rules = construir_token_rules(G, regexes_para_tokens)
	return Parser.new(tabla, G, token_rules, tds)

func parsear_cadena(parser, cadena):
	var AST = {"nombre":parser.G.S, "hijos":[]}
	var tokens = tokenizar_cadena(parser.token_rules, cadena)
	if HUB.errores.fallo(tokens):
		return HUB.error(cadena_invalida(cadena, tokens), modulo)
	tokens.append([parser.G.fin,parser.G.fin,0,0])
	AST["hijos"].append({})
	var lookahead = 0
	var pila = [[0,tokens[0][0]]]
	var aceptado = false
	var acciones = []
	while not aceptado:
		var estado = pila[0][0]
		var simbolo = tokens[lookahead][0]
		if not simbolo in parser.tabla_action_goto[estado].keys():
			return HUB.error(token_inesperado(tokens[lookahead]), modulo)
		var accion = parser.tabla_action_goto[estado][simbolo]
		if accion == "A!": # Aceptar
			aceptado = true
		elif accion.begins_with("S"): # Shift
			var shift_a = str_desde(accion,1)
			pila.push_front([int(shift_a),simbolo])
			lookahead += 1
		elif accion.begins_with("R"): # Reduce
			var p = int(str_desde(accion,1))
			acciones.push_front(p)
			p = parser.G.P[p]
			for i in range(p[1].size()):
				pila.pop_front()
			estado = pila[0][0]
			accion = parser.tabla_action_goto[estado][p[0]]
			var shift_a = str_desde(accion,1)
			pila.push_front([int(shift_a),p[1]])
	for accion in acciones:
		var reduccion = parser.G.P[accion]
		var nodo = buscar_proximo_lugar(AST)
		nodo["nombre"] = reduccion[0]
		nodo["hijos"] = []
		nodo["valor"] = accion
		for i in reduccion[1]:
			if i in parser.G.VT:
				nodo["hijos"].append({"nombre":i,"hijos":[]})
			else:
				nodo["hijos"].append({})
	var resultado = calcular_tds(parser, AST["hijos"][0], tokens, 0)
	if HUB.errores.fallo(resultado):
		tokens.pop_back()
		return HUB.error(error_semantico(str(
			estructuras.map(F.new(), tokens)
		), resultado), modulo)
	AST["valor"] = AST["hijos"][0]["valor"]
	return AST

class F:
	func exec(x):
		return x[0]

func calcular_tds(parser, AST, tokens, i_token):
	if AST["nombre"] in parser.G.VT:
		AST["valor"] = tokens[i_token][1]
		return 1
	else:
		var token_actual = i_token
		var valores_hijos = []
		for hijo in AST["hijos"]:
			var resultado = calcular_tds(parser, hijo, tokens, token_actual)
			if HUB.errores.fallo(resultado):
				return resultado
			token_actual += resultado
			valores_hijos.append(hijo["valor"])
		var resultado = parser.tds.reduce(AST["valor"], valores_hijos)
		if HUB.errores.fallo(resultado):
			return resultado
		AST["valor"] = resultado
		return token_actual - i_token

func crear_gramatica(P):
	var G = Gramatica.new()
	var conjunto_VN = estructuras.conjunto_vacio()
	for p in P:
		conjunto_VN.agregar(p[0])
	G.VN = conjunto_VN.elementos
	var conjunto_VT = estructuras.conjunto_vacio()
	for p in P:
		for v in p[1]:
			if not v in G.VN:
				conjunto_VT.agregar(v)
	G.VT = conjunto_VT.elementos
	G.P = P
	while G.S in G.VN or G.S in G.VT:
		G.S += "'"
	while G.fin in G.VN or G.fin in G.VT:
		G.fin += "'"
	while G.lambda in G.VN or G.lambda in G.VT:
		G.lambda += "'"
	return G

func construir_automata(G):
	var V = estructuras.conjunto_con_elementos(G.VN)
	V.union(estructuras.conjunto_con_elementos(G.VT))
	var kernel = estructuras.conjunto_con_elementos(
		[[G.S,[],[G.VN[0]],estructuras.conjunto_con_elementos([G.fin])]]
	)
	var automata = [Estado.new(kernel)]
	var estados_pendientes = [0]
	while not estados_pendientes.empty():
		var estado_actual = automata[estados_pendientes[0]]
		estados_pendientes.pop_front()
		var items = clausura(estado_actual.kernel, G)
		items.union(estado_actual.kernel)
		for simbolo in V.elementos:
			var nuevo_estado = shift(items.elementos, simbolo)
			if not nuevo_estado.kernel.elementos.empty():
				var indice_nuevo_estado = buscar_indice(nuevo_estado, automata)
				if indice_nuevo_estado == -1: # estado nuevo
					indice_nuevo_estado = automata.size()
					automata.append(nuevo_estado)
					estados_pendientes.append(indice_nuevo_estado)
				else:
					# Fusiona y devuelve si hay que actualizar
					if fusionar_estados(automata[indice_nuevo_estado], nuevo_estado):
						estados_pendientes.append(indice_nuevo_estado)
				estado_actual.agregar_transicion(simbolo, indice_nuevo_estado)
	return automata

func construir_tabla(G, A):
	var tabla_action_goto = []
	for estado in A:
		var action_goto = {}
		for transicion in estado.transiciones.keys():
			action_goto[transicion] = "S"+str(estado.transiciones[transicion])
		var VT = estructuras.copiar_array(G.VT)
		VT.append(G.fin)
		var items = clausura(estado.kernel, G)
		items.union(estado.kernel)
		for vt in VT:
			for item in items.elementos:
				if item[2].empty() and vt in item[3].elementos:
					for i in range(G.P.size()):
						var p = G.P[i]
						if p[0] == item[0] and p[1] == item[1]:
							action_goto[vt] = "R"+str(i)
					if not action_goto.has(vt):
						action_goto[vt] = "A!"
		tabla_action_goto.append(action_goto)
	return tabla_action_goto

func construir_token_rules(G, regexes_para_tokens):
	var token_rules = {}
	for vt in G.VT:
		var rule = ""
		if vt in regexes_para_tokens.keys():
			rule = regexes_para_tokens[vt]
		else:
			for c in vt:
				if c in regex_escape:
					rule += "\\"
				rule += c
		var regex = RegEx.new()
		regex.compile(rule)
		token_rules[vt] = regex
	return token_rules

func tokenizar_cadena(token_rules, cadena):
	var tokens = []
	var linea = 0
	for reglon in cadena.split("\n"):
		var i = 0
		while i < reglon.length():
			var token_candidato = null
			var j = 0
			for token in token_rules.keys():
				var regex = token_rules[token]
				var token_encontrado = regex.find(reglon, i)
				if token_encontrado == i:
					token_encontrado = regex.get_capture(0)
					if token_encontrado.length() > j:
						j = token_encontrado.length()
						token_candidato = token
			if token_candidato == null:
				return HUB.error(token_invalido(reglon, linea, i), modulo)
			tokens.append([token_candidato,reglon.substr(i,j),linea,i])
			i += j
		linea += 1
	return tokens

func buscar_proximo_lugar(nodo):
	for i in range(nodo["hijos"].size()-1,-1,-1):
		var hijo = nodo["hijos"][i]
		if hijo.has("nombre"):
			var proximo = buscar_proximo_lugar(hijo)
			if proximo != null:
				return proximo
		else:
			return hijo
	return null

func clausura(kernel, G):
	var items_clausurados=estructuras.conjunto_vacio()
	var resultado = estructuras.conjunto_vacio()
	var items_pendientes = estructuras.copiar_array(kernel.elementos)
	while not items_pendientes.empty():
		var item = items_pendientes[0]
		items_pendientes.pop_front()
		items_clausurados.agregar(item)
		if not item[2].empty() and item[2][0] in G.VN:
			var vn = item[2][0]
			for lookahead in item[3].elementos:
				var next = estructuras.copiar_array(item[2])
				next.pop_front()
				next.append(lookahead)
				for p in G.P:
					if p[0] == vn:
						var nuevo_item = [vn,[],p[1],FIRST(next, G)]
						var agregado = false
						for item_agregado in resultado.elementos:
							if mismo_core(item_agregado, nuevo_item):
								item_agregado[3].union(nuevo_item[3])
								agregado = true
						if not agregado:
							resultado.agregar(nuevo_item)
							var clausurado = false
							for item_clausurado in items_clausurados.elementos:
								if mismo_core(item_clausurado, nuevo_item):
									clausurado = true
							if not clausurado:
								items_pendientes.append(nuevo_item)
	return resultado

func mismo_core(item_1, item_2):
	return \
		item_1[0] == item_2[0] and \
		item_1[1] == item_2[1] and \
		item_1[2] == item_2[2]

func mismo_estado(estado_1, estado_2):
	for item in estado_1.kernel.elementos:
		var esta = false
		for otro_item in estado_2.kernel.elementos:
			if mismo_core(item, otro_item):
				esta = true
		if not esta:
			return false
	for item in estado_2.kernel.elementos:
		var esta = false
		for otro_item in estado_1.kernel.elementos:
			if mismo_core(item, otro_item):
				esta = true
		if not esta:
			return false
	return estado_1.kernel.elementos.size() == estado_2.kernel.elementos.size()

func fusionar_estados(estado_1, estado_2):
	var hay_que_actualizar = false
	for item_2 in estado_2.kernel.elementos:
		for item_1 in estado_1.kernel.elementos:
			if mismo_core(item_1, item_2):
				if not item_2[3].es_subconjunto_de(item_1[3]):
					hay_que_actualizar = true
					item_1[3].union(item_2[3])
	return hay_que_actualizar

func FIRST(w, G):
	var n = w.size()
	if n == 0:
		return estructuras.conjunto_vacio()
	var resultado = FIRST_1(w[0], G)
	if n == 1:
		return resultado
	resultado.quitar(G.lambda)
	var i=1
	while i < n and se_deriva_en_lambda(estructuras.sub_array(w, 0, i), G):
		var next = FIRST_1(w[i], G)
		next.quitar(G.lambda)
		resultado.union(next)
		i += 1
	if se_deriva_en_lambda(w, G):
		resultado.agregar(G.lambda)
	return resultado

func FIRST_1(X, G):
	if X in G.VT or X == G.fin:
		return estructuras.conjunto_con_elementos([X])
	var resultado = estructuras.conjunto_vacio()
	for p in G.P:
		if p[0] == X:
			var k = p[1].size()
			if (k > 0):
				resultado.union(FIRST_1(p[1][0], G))
				var i = 1
				while i < k and se_deriva_en_lambda(estructuras.sub_array(p[1], 0, i), G):
					resultado.union(FIRST_1(p[1][i], G))
					i += 1
			if se_deriva_en_lambda(p[1], G):
				resultado.agregar(G.lambda)
	return resultado

func se_deriva_en_lambda(w, G):
	for i in w:
		if i in G.VT:
			return false
	if w.size() == 1:
		if w[0] == G.lambda:
			return true
		if w[0] == G.fin:
			return true
		for p in G.P:
			if p[0] == w[0] and p[1].empty():
				return true
	var resultado = true
	for i in w:
		resultado = resultado and se_deriva_en_lambda([i], G)
	return resultado

func shift(items, simbolo):
	var nuevo_estado = Estado.new(estructuras.conjunto_vacio())
	for item in items:
		if not item[2].empty() and item[2][0] == simbolo:
			var nuevo_item = [item[0],
				estructuras.copiar_array(item[1]),
				estructuras.copiar_array(item[2]),
				estructuras.conjunto_con_elementos(item[3].elementos)
			]
			nuevo_item[1].append(simbolo)
			nuevo_item[2].pop_front()
			nuevo_estado.kernel.agregar(nuevo_item)
	return nuevo_estado

func buscar_indice(nuevo_estado, automata):
	for i in range(automata.size()):
		if mismo_estado(nuevo_estado, automata[i]):
			return i
	return -1

func imprimir_automata(automata, G):
	for i in range(automata.size()):
		var estado = automata[i]
		HUB.mensaje("\nEstado " + str(i))
		for item in estado.kernel.elementos:
			HUB.mensaje("| " + item[0] + " -> " + como_string(item[1]) + " . " + como_string(item[2]) + " ["+como_string(item[3].elementos)+"]")
		for item in clausura(estado.kernel, G).elementos:
			HUB.mensaje("  " + item[0] + " -> " + como_string(item[1]) + " . " + como_string(item[2]) + " ["+como_string(item[3].elementos)+"]")
		for transicion in estado.transiciones.keys():
			HUB.mensaje(transicion + " --> " + str(estado.transiciones[transicion]))

func como_string(lista):
	var resultado = ""
	for i in lista:
		resultado += i
	return resultado

func imprimir_arbol(AST, mostrar_valores=true):
	var function_object = AtributosNodo.new(mostrar_valores)
	return printer.imprimir_arbol(AST, function_object)

# Errores

# No se pudo tokenizar
func token_invalido(reglon, linea, i, stack_error = null):
	return HUB.errores.error('Cadena "'+str_desde(reglon,i) + \
	'" inesperada en la línea ' + str(linea+1) + ' columna ' + str(i+1) + '.', stack_error)

# Se encontró un token inesperado
func token_inesperado(token, stack_error = null):
	return HUB.errores.error('Token "'+token[0]+'" con valor "' + \
	token[1] + '" inesperado en la línea ' + str(token[2]+1) + \
	' columna ' + str(token[3]+1) + '.', stack_error)

# No se pudo parsear
func cadena_invalida(cadena, stack_error = null):
	return HUB.errores.error('No se pudo parsear la cadena "' +\
	cadena + '" debido a un error sintáctico.', stack_error)

# Error semántico (falló TDS)
func error_semantico(cadena, stack_error = null):
	return HUB.errores.error('No se pudo calcular el valor de ' +\
	cadena + ' debido a un error semántico.', stack_error)

class AtributosNodo:
	var mostrar_valores
	func _init(mostrar_valores):
		self.mostrar_valores = mostrar_valores
	func nombre_de_nodo(nodo):
		return nodo["nombre"]+ ("    ( " + \
		(str(nodo["valor"]) if nodo.has("valor") else "?") + " )" \
		if mostrar_valores else "")
	func hijos_de_nodo(nodo):
		return nodo["hijos"]

class Parser:
	var tabla_action_goto = []
	var G
	var token_rules = {}
	var tds = null
	func _init(tabla_action_goto, G, token_rules, tds):
		self.tabla_action_goto = tabla_action_goto
		self.G = G
		self.token_rules = token_rules
		self.tds = tds
	func tabla():
		var fila = [" "]
		for vt in G.VT:
			fila.append(vt)
		fila.append(G.fin)
		for vn in G.VN:
			fila.append(vn)
		var filas = [fila]
		for i in range(tabla_action_goto.size()):
			var estado = tabla_action_goto[i]
			fila = [str(i)]
			var V = []
			for vt in G.VT:
				V.append(vt)
			V.append(G.fin)
			for vn in G.VN:
				V.append(vn)
			for v in V:
				var s = "-"
				if estado.has(v):
					s = estado[v]
				fila.append(s)
			filas.append(fila)
		return filas

class Gramatica:
	var VN = []
	var VT = []
	var P = []
	var S = "S"
	var fin = "$"
	var lambda = "LAMBDA"

class Estado:
	var kernel
	var transiciones
	func _init(kernel):
		self.kernel = kernel
		self.transiciones = {}
	func agregar_transicion(simbolo, indice):
		transiciones[simbolo] = indice

func str_desde(s, i):
	return HUB.varios.str_desde(s, i)
