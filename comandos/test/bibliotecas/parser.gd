## Test/Bibliotecas/Parser
## Comando

# Testea la biblioteca Parser.
# Requiere:
	# Biblioteca parser

extends Node

var HUB
var parser_lib

var modulo = "Test Parser"

func inicializar(hub):
	HUB = hub
	parser_lib = HUB.bibliotecas.importar("parser")
	if HUB.errores.fallo(parser_lib):
		return HUB.error(HUB.errores.inicializar_fallo(self, parser_lib), modulo)
	return null

func comando(argumentos):
	HUB.mensaje("Testeando la biblioteca parser")
	HUB.mensaje("* Testeando con el parser a^n b^n")
	var tds_lambda0 = EstadoLambda0TDS.new()
	var parser_lambda0 = parser_lib.crear_parser(
		[
			["S",["a","S","b"]],
			["S",[]]
		],{},
		tds_lambda0
	)
	HUB.mensaje("    Testeando la cadena válida \"ab\"")
	HUB.testing.test(
		TesterParser.new(parser_lib, parser_lambda0, "ab"),
		VerificadorAST.new(HUB, parser_lib, "<->",
			{"nombre":"S'","hijos":[
				{"nombre":"S","hijos":[
					{"nombre":"a","hijos":[]},
					{"nombre":"S","hijos":[]},
					{"nombre":"b","hijos":[]}
				]}
			]})
	)
	HUB.mensaje("    Testeando la cadena válida \"\"")
	HUB.testing.test(
		TesterParser.new(parser_lib, parser_lambda0, ""),
		VerificadorAST.new(HUB, parser_lib, "-",
			{"nombre":"S'","hijos":[
				{"nombre":"S","hijos":[]}
			]})
	)
	HUB.mensaje("* Testeando con el parser ( x (,x)* )")
	var tds_lambda1 = EstadoLambda1TDS.new()
	var parser_lambda1 = parser_lib.crear_parser(
		[
			["S",["(","X",")"]],
			["X",[]],
			["X",["x","T"]],
			["T",[",","x","T"]],
			["T",[]],
		],{},
		tds_lambda1
	)
	HUB.mensaje("    Testeando la cadena válida \"()\"")
	HUB.testing.test(
		TesterParser.new(parser_lib, parser_lambda1, "()"),
		VerificadorAST.new(HUB, parser_lib, 0,
			{"nombre":"S'","hijos":[
				{"nombre":"S","hijos":[
					{"nombre":"(","hijos":[]},
					{"nombre":"X","hijos":[]},
					{"nombre":")","hijos":[]}
				]}
			]})
	)
	HUB.mensaje("    Testeando la cadena válida \"(x)\"")
	HUB.testing.test(
		TesterParser.new(parser_lib, parser_lambda1, "(x)"),
		VerificadorAST.new(HUB, parser_lib, 1,
			{"nombre":"S'","hijos":[
				{"nombre":"S","hijos":[
					{"nombre":"(","hijos":[]},
					{"nombre":"X","hijos":[
						{"nombre":"x","hijos":[]},
						{"nombre":"T","hijos":[]},
					]},
					{"nombre":")","hijos":[]}
				]}
			]})
	)
	HUB.mensaje("    Testeando la cadena válida \"(x,x)\"")
	HUB.testing.test(
		TesterParser.new(parser_lib, parser_lambda1, "(x,x)"),
		VerificadorAST.new(HUB, parser_lib, 2,
			{"nombre":"S'","hijos":[
				{"nombre":"S","hijos":[
					{"nombre":"(","hijos":[]},
					{"nombre":"X","hijos":[
						{"nombre":"x","hijos":[]},
						{"nombre":"T","hijos":[
							{"nombre":",","hijos":[]},
							{"nombre":"x","hijos":[]},
							{"nombre":"T","hijos":[]},
						]},
					]},
					{"nombre":")","hijos":[]}
				]}
			]})
	)
	var tds = EstadoTDS.new()
	HUB.mensaje("* Testeando con el parser aritmético")
	var parser = parser_lib.crear_parser(
		[
			["E",["E","+","T"]],
			["E",["T"]],
			["T",["int"]],
			["T",["(","E",")"]]
		],{"int":"[0-9]+"},
		tds
	)
	HUB.mensaje("    Testeando la cadena válida \"5\"")
	HUB.testing.test(
		TesterParser.new(parser_lib, parser, "5"),
		VerificadorAST.new(HUB, parser_lib, 5,
			{"nombre":"S","hijos":[
				{"nombre":"E","hijos":[
					{"nombre":"T","hijos":[
						{"nombre":"int","hijos":[]}
					]}
				]}
			]})
	)
	HUB.mensaje("    Testeando la cadena válida \"12+155\"")
	HUB.testing.test(
		TesterParser.new(parser_lib, parser, "12+155"),
		VerificadorAST.new(HUB, parser_lib, 167,
			{"nombre":"S","hijos":[
				{"nombre":"E","hijos":[
					{"nombre":"E","hijos":[
						{"nombre":"T","hijos":[
							{"nombre":"int","hijos":[]}
						]}
					]},
					{"nombre":"+","hijos":[]},
					{"nombre":"T","hijos":[
						{"nombre":"int","hijos":[]}
					]}
				]}
			]})
	)
	HUB.mensaje("    Testeando la cadena válida \"(0+889)\"")
	HUB.testing.test(
		TesterParser.new(parser_lib, parser, "(0+889)"),
		VerificadorAST.new(HUB, parser_lib, 889,
			{"nombre":"S","hijos":[
				{"nombre":"E","hijos":[
					{"nombre":"T","hijos":[
						{"nombre":"(","hijos":[]},
						{"nombre":"E","hijos":[
							{"nombre":"E","hijos":[
								{"nombre":"T","hijos":[
									{"nombre":"int","hijos":[]}
								]}
							]},
							{"nombre":"+","hijos":[]},
							{"nombre":"T","hijos":[
								{"nombre":"int","hijos":[]}
							]}
						]},
						{"nombre":")","hijos":[]}
					]}
				]}
			]}
		)
	)
	HUB.mensaje("    Testeando la cadena inválida \"+\"")
	HUB.testing.test_genera_error(
		TesterParser.new(parser_lib, parser, "+"),
		parser_lib.token_inesperado(["+","+",0,0]))
	HUB.mensaje("    Testeando la cadena inválida \"(125)\\n+2+\\n(15+11)62\"")
	HUB.testing.test_genera_error(
		TesterParser.new(parser_lib, parser, "(125)\n+2+\n(15+11)62"),
		parser_lib.token_inesperado(["int","62",2,7]))
	HUB.mensaje("    Testeando la cadena inválida \"(13)+5)\"")
	HUB.testing.test_genera_error(
		TesterParser.new(parser_lib, parser, "(13)+5)"),
		parser_lib.token_inesperado([")",")",0,6]))
	HUB.mensaje("    Testeando la cadena inválida \"2+3+hola\"")
	HUB.testing.test_genera_error(
		TesterParser.new(parser_lib, parser, "2+3+hola"),
		parser_lib.token_invalido("2+3+hola",0,4))
	#var ast = parser_lib.parsear_cadena(parser, "(2+2)+66+(3+5+1)+85")
	#HUB.mensaje(parser_lib.imprimir_arbol(ast))

class EstadoTDS:
	func reduce(produccion, valores):
		if produccion == 0: # E -> E + T
			return valores[0] + valores[2]
		if produccion == 1: # E -> T
			return valores[0]
		if produccion == 2: # T -> int
			return int(valores[0])
		if produccion == 3: # T -> ( E )
			return valores[1]

class EstadoLambda0TDS:
	func reduce(produccion, valores):
		if produccion == 0: # S -> a S b
			return "<" + valores[1] + ">"
		if produccion == 1: # S -> []
			return "-"

class EstadoLambda1TDS:
	func reduce(produccion, valores):
		if produccion == 0: # S -> ( X )
			return valores[1]
		if produccion == 1: # X -> []
			return 0
		if produccion == 2: # X -> x T
			return valores[1] + 1
		if produccion == 3: # T -> , x T
			return valores[2] + 1
		if produccion == 4: # T -> []
			return 0

class TesterParser:
	var parser_lib
	var parser
	var cadena
	func _init(parser_lib, parser, cadena):
		self.parser_lib = parser_lib
		self.parser = parser
		self.cadena = cadena
	func test():
		return parser_lib.parsear_cadena(parser, cadena)

class VerificadorAST:
	var HUB
	var parser_lib
	var suma
	var AST
	func _init(hub, parser_lib, suma, AST):
		HUB = hub
		self.parser_lib = parser_lib
		self.suma = suma
		self.AST = AST
	func verificar(resultado):
		var AST_recibido = resultado
		if AST["hijos"].size() != resultado["hijos"].size():
			return mensaje_falla(AST_recibido)
		for i in range(AST["hijos"].size()):
			if not verificar_recursivo(AST["hijos"][i], resultado["hijos"][i]):
				return mensaje_falla(AST_recibido)
		var suma_recibida = resultado["valor"]
		if suma == suma_recibida:
			return ""
		return 'Se esperaba que el valor final sea "' + str(suma) + \
		'" pero resultó ser "' + str(suma_recibida) + '".'
	func verificar_recursivo(A1, A2):
		if A1["hijos"].size() != A2["hijos"].size():
			return false
		for i in range(A1["hijos"].size()):
			if not verificar_recursivo(A1["hijos"][i], A2["hijos"][i]):
				return false
		return A1["nombre"] == A2["nombre"]
	func mensaje_falla(AST_recibido):
		return "Se esperaba\n\t" + parser_lib.imprimir_arbol(AST, false).replace("\n","\n\t") + \
		"\nPero se obtuvo\n\t" + parser_lib.imprimir_arbol(AST_recibido, false).replace("\n","\n\t")

func descripcion():
	return "Testea la biblioteca parser"

func man():
	var r = "[ TEST/PARSER ] - " + descripcion()
	r += "\nUso: test/parser"
	r += "\nIgnora cualquier argumento."
	return r
