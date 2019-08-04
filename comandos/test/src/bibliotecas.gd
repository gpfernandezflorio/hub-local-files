## Test/SRC/Bibliotecas
## Comando

# Testea el módulo Bibliotecas.
# Requiere:
	# -

extends Node

var HUB
var carpeta

func inicializar(hub):
	HUB = hub
	carpeta = HUB.bibliotecas.carpeta_bibliotecas

func comando(argumentos):
	var nodo = Node.new()
	HUB.mensaje("Testeando el módulo Bibliotecas")
	HUB.mensaje("* Testeando importar biblioteca inexistente")
	HUB.testing.test_genera_error(
		tester_biblioteca("hola"),
		HUB.archivos.archivo_inexistente(carpeta, "hola.gd"), []
	)
	HUB.mensaje("* Testeando importar biblioteca vacía")
	HUB.archivos.crear(carpeta, "hola.gd")
	HUB.testing.test_genera_error(
		tester_biblioteca("hola"),
		HUB.archivos.encabezado_faltante("hola.gd"), []
	)
	HUB.mensaje("* Testeando importar biblioteca sin encabezado 1")
	HUB.archivos.escribir(carpeta, "hola.gd", "hola")
	HUB.testing.test_genera_error(
		tester_biblioteca("hola"),
		HUB.archivos.encabezado_faltante("hola.gd"), []
	)
	HUB.mensaje("* Testeando importar biblioteca sin encabezado 2")
	HUB.archivos.escribir(carpeta, "hola.gd", "## hola")
	HUB.testing.test_genera_error(
		tester_biblioteca("hola"),
		HUB.archivos.encabezado_faltante("hola.gd"), []
	)
	HUB.mensaje("* Testeando importar biblioteca sin encabezado 3")
	HUB.archivos.sobrescribir(carpeta, "hola.gd", "## hola\nhola")
	HUB.testing.test_genera_error(
		tester_biblioteca("hola"),
		HUB.archivos.encabezado_faltante("hola.gd"), []
	)
	HUB.mensaje("* Testeando importar biblioteca con nombre incorrecto")
	HUB.archivos.sobrescribir(carpeta, "hola.gd", "## chau\n## chau")
	HUB.testing.test_genera_error(
		tester_biblioteca("hola"),
		HUB.archivos.encabezado_invalido_nombre("hola.gd", "hola"), []
	)
	HUB.mensaje("* Testeando importar biblioteca con tipo incorrecto")
	HUB.archivos.sobrescribir(carpeta, "hola.gd", "## hola\n## hola")
	HUB.testing.test_genera_error(
		tester_biblioteca("hola"),
		HUB.archivos.encabezado_invalido_tipo("hola.gd", "Biblioteca"), []
	)
	HUB.mensaje("* Testeando importar biblioteca sin función de inicialización")
	nodo.set_name("hola.gd")
	HUB.archivos.sobrescribir(carpeta, "hola.gd", "## hola\n## Biblioteca")
	HUB.testing.test_genera_error(
		tester_biblioteca("hola"),
		HUB.errores.funcion_no_implementada(nodo, "inicializar", 1), []
	)
	HUB.archivos.borrar(carpeta, "hola.gd")
	HUB.mensaje("* Testeando importar biblioteca con función de inicialización sin parámetros")
	nodo.set_name("hoLa.gd")
	HUB.archivos.crear(carpeta, "hoLa.gd")
	HUB.archivos.escribir(carpeta, "hoLa.gd", "## hola\n## Biblioteca\nfunc inicializar():\n\tpass")
	HUB.testing.test_genera_error(
		tester_biblioteca("hoLa"),
		HUB.errores.funcion_no_implementada(nodo, "inicializar", 1), []
	)
	HUB.archivos.borrar(carpeta, "hoLa.gd")
	HUB.mensaje("* Testeando importar biblioteca con función de inicialización con 2 parámetros")
	nodo.set_name("hOla.gd")
	HUB.archivos.crear(carpeta, "hOla.gd")
	HUB.archivos.escribir(carpeta, "hOla.gd", "## hola\n## Biblioteca\nfunc inicializar(a, b):\n\tpass")
	HUB.testing.test_genera_error(
		tester_biblioteca("hOla"),
		HUB.errores.funcion_no_implementada(nodo, "inicializar", 1), []
	)
	HUB.archivos.borrar(carpeta, "hOla.gd")
	HUB.mensaje("* Testeando importar biblioteca correcta")
	nodo.set_name("hOLa.gd")
	HUB.archivos.crear(carpeta, "hOLa.gd")
	HUB.archivos.escribir(carpeta, "hOLa.gd", "## hola\n## Biblioteca\nfunc inicializar(a):\n\tpass\nfunc hola():\n\treturn 95")
	HUB.testing.test(
		tester_biblioteca_funcion("hOLa", "hola"),
		HUB.testing.verificador_por_igualdad(95), []
	)
	HUB.archivos.borrar(carpeta, "hOLa.gd")

func tester_biblioteca(biblioteca):
	return TesterBiblioteca.new(HUB, biblioteca)
func tester_biblioteca_funcion(biblioteca, funcion):
	return TesterBibliotecaFuncion.new(HUB, biblioteca, funcion)

class TesterBiblioteca:
	var HUB
	var biblioteca
	func _init(hub, biblioteca):
		HUB = hub
		self.biblioteca = biblioteca
	func test():
		return HUB.bibliotecas.importar(biblioteca)

class TesterBibliotecaFuncion:
	var HUB
	var biblioteca
	var funcion
	func _init(hub, biblioteca, funcion):
		HUB = hub
		self.biblioteca = biblioteca
		self.funcion = funcion
	func test():
		var nodo_biblioteca = HUB.bibliotecas.importar(biblioteca)
		return nodo_biblioteca.callv(funcion, [])

func descripcion():
	return "Test"

func man():
	var r = "[ TEST ] - " + descripcion()
	return r