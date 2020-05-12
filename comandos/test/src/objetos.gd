## Test/SRC/Objetos
## Comando

# Testea el módulo Objetos.
# Requiere:
	# -

extends Node

var HUB

func inicializar(hub):
	HUB = hub

func comando(argumentos):
	HUB.mensaje("Testeando el módulo Objetos")
	HUB.mensaje("* Testeando localizar un objeto inexistente")
	HUB.testing.test_genera_error(
		tester_localizar("hola"),
		HUB.objetos.objeto_inexistente("hola",HUB.nodo_usuario.mundo), []
	)
	HUB.mensaje("* Testeando crear un objeto vacío")
	HUB.testing.test(
		tester_crear("hola"),
		verificador_objeto_existe("hola"), []
	)
	HUB.mensaje("* Testeando localizar un objeto existente")
	HUB.testing.test(
		tester_localizar("hola"),
		verificador_objeto_localizado("hola"), []
	)
	HUB.mensaje("* Testeando eliminar un objeto")
	HUB.testing.test(
		tester_eliminar("hola"),
		verificador_objeto_no_existe("hola"), []
	)

func tester_localizar(objeto):
	return TesterLocalizar.new(HUB, objeto)

func tester_crear(nombre):
	return TesterCrear.new(HUB, nombre)

func tester_eliminar(nombre):
	return TesterEliminar.new(HUB, nombre)

class TesterLocalizar:
	var HUB
	var objeto
	func _init(hub, objeto):
		HUB = hub
		self.objeto = objeto
	func test():
		return HUB.objetos.localizar(objeto)

class TesterCrear:
	var HUB
	var nombre
	func _init(hub, nombre):
		HUB = hub
		self.nombre = nombre
	func test():
		var nuevo = HUB.objetos.crear()
		nuevo.nombrar(nombre)
		return nuevo

class TesterEliminar:
	var HUB
	var nombre
	func _init(hub, nombre):
		HUB = hub
		self.nombre = nombre
	func test():
		HUB.objetos.borrar(nombre)

func verificador_objeto_existe(nombre):
	return VerificadorObjetoExiste.new(HUB, nombre)

func verificador_objeto_localizado(nombre):
	return VerificadorObjetoLocalizado.new(HUB, nombre)

func verificador_objeto_no_existe(nombre):
	return VerificadorObjetoNoExiste.new(HUB, nombre)

class VerificadorObjetoExiste:
	var HUB
	var nombre
	func _init(hub, nombre):
		HUB = hub
		self.nombre = nombre
	func verificar(resultado):
		var localizado = HUB.objetos.localizar(nombre)
		if HUB.errores.fallo(localizado):
			return "Localizar el nuevo objeto generó un error inesperado."
		return ""

class VerificadorObjetoLocalizado:
	var HUB
	var nombre
	func _init(hub, nombre):
		HUB = hub
		self.nombre = nombre
	func verificar(resultado):
		if resultado.nombre() != nombre:
			return 'Se esperaba que el objeto localizado se llame "' + nombre + \
				'" pero se llama "' + resultado.nombre() + '".'
		return ""

class VerificadorObjetoNoExiste:
	var HUB
	var nombre
	func _init(hub, nombre):
		HUB = hub
		self.nombre = nombre
	func verificar(resultado):
		var mundo = HUB.nodo_usuario.mundo
		for hijo in mundo.hijos():
			print(hijo.nombre())
			if hijo.nombre() == nombre:
				return "El objeto no fue eliminado."
		return ""

func descripcion():
	return "Test"

func man():
	var r = "[ TEST ] - " + descripcion()
	return r
