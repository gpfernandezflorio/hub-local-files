## Test/SRC/Procesos
## Comando

# Testea el módulo Procesos.
# Requiere:
	# -

extends Node

var HUB
var carpeta

func inicializar(hub):
	HUB = hub
	carpeta = HUB.procesos.carpeta_programas

func comando(argumentos):
	var nodo = Node.new()
	HUB.mensaje("Testeando el módulo Procesos")
	HUB.mensaje("* Testeando crear proceso con programa inexistente")
	HUB.testing.test_genera_error(
		tester_programa("hola"),
		HUB.archivos.archivo_inexistente(carpeta, "hola.gd"), []
	)
	HUB.mensaje("* Testeando crear un proceso con un programa vacío")
	HUB.archivos.crear(carpeta, "hola.gd")
	HUB.testing.test_genera_error(
		tester_programa("hola"),
		HUB.archivos.encabezado_faltante("hola.gd"), []
	)
	HUB.mensaje("* Testeando crear un proceso con un programa sin encabezado 1")
	HUB.archivos.escribir(carpeta, "hola.gd", "hola")
	HUB.testing.test_genera_error(
		tester_programa("hola"),
		HUB.archivos.encabezado_faltante("hola.gd"), []
	)
	HUB.mensaje("* Testeando crear un proceso con un programa sin encabezado 2")
	HUB.archivos.escribir(carpeta, "hola.gd", "## hola")
	HUB.testing.test_genera_error(
		tester_programa("hola"),
		HUB.archivos.encabezado_faltante("hola.gd"), []
	)
	HUB.mensaje("* Testeando crear un proceso con un programa sin encabezado 3")
	HUB.archivos.sobrescribir(carpeta, "hola.gd", "## hola\nhola")
	HUB.testing.test_genera_error(
		tester_programa("hola"),
		HUB.archivos.encabezado_faltante("hola.gd"), []
	)
	HUB.mensaje("* Testeando crear un proceso con un programa con nombre incorrecto")
	HUB.archivos.sobrescribir(carpeta, "hola.gd", "## chau\n## chau")
	HUB.testing.test_genera_error(
		tester_programa("hola"),
		HUB.archivos.encabezado_invalido_nombre("hola.gd", "hola"), []
	)
	HUB.mensaje("* Testeando crear un proceso con un programa con tipo incorrecto")
	HUB.archivos.sobrescribir(carpeta, "hola.gd", "## hola\n## hola")
	HUB.testing.test_genera_error(
		tester_programa("hola"),
		HUB.archivos.encabezado_invalido_tipo("hola.gd", "Programa"), []
	)
	HUB.mensaje("* Testeando crear un proceso con un programa sin función de inicialización")
	nodo.set_name("hola.gd")
	HUB.archivos.sobrescribir(carpeta, "hola.gd", "## hola\n## Programa")
	HUB.testing.test_genera_error(
		tester_programa("hola"),
		HUB.errores.funcion_no_implementada(nodo, "inicializar", 3), []
	)
	HUB.archivos.borrar(carpeta, "hola.gd")
	HUB.mensaje("* Testeando crear un proceso con un programa con función de inicialización sin parámetros")
	nodo.set_name("hoLa.gd")
	HUB.archivos.crear(carpeta, "hoLa.gd")
	HUB.archivos.escribir(carpeta, "hoLa.gd", "## hola\n## Programa\nfunc inicializar():\n\tpass")
	HUB.testing.test_genera_error(
		tester_programa("hoLa"),
		HUB.errores.funcion_no_implementada(nodo, "inicializar", 3), []
	)
	HUB.archivos.borrar(carpeta, "hoLa.gd")
	HUB.mensaje("* Testeando crear un proceso con un programa con función de inicialización con 1 parámetro")
	nodo.set_name("hOla.gd")
	HUB.archivos.crear(carpeta, "hOla.gd")
	HUB.archivos.escribir(carpeta, "hOla.gd", "## hola\n## Programa\n" + \
	"func inicializar(hub):\n\tpass")
	HUB.testing.test_genera_error(
		tester_programa("hOla"),
		HUB.errores.funcion_no_implementada(nodo, "inicializar", 3), []
	)
	HUB.archivos.borrar(carpeta, "hOla.gd")
	HUB.mensaje("* Testeando crear un proceso con un programa sin función de finalización")
	nodo.set_name("hOlA.gd")
	HUB.archivos.crear(carpeta, "hOlA.gd")
	HUB.archivos.escribir(carpeta, "hOlA.gd", "## hola\n## Programa\n" + \
	"func inicializar(hub, pid, argumentos):\n\tpass")
	HUB.testing.test_genera_error(
		tester_programa("hOlA"),
		HUB.errores.funcion_no_implementada(nodo, "finalizar", 0), []
	)
	HUB.archivos.borrar(carpeta, "hOlA.gd")
	HUB.mensaje("* Testeando finalizar un proceso inexistente")
	HUB.testing.test_genera_error(
		tester_fin_programa("hOLa"),
		HUB.procesos.pid_inexistente("hOLa"), []
	)
	HUB.mensaje("* Testeando finalizar el HUB")
	HUB.testing.test_genera_error(
		tester_fin_programa("HUB"),
		HUB.procesos.pid_invalido("HUB"), []
	)
	HUB.mensaje("* Testeando crear un proceso con un programa correcto")
	nodo.set_name("hOLa.gd")
	HUB.archivos.crear(carpeta, "hOLa.gd")
	HUB.archivos.escribir(carpeta, "hOLa.gd", "## hola\n## Programa\n" + \
	"func inicializar(hub, pid, argumentos):\n\tpass\nfunc finalizar():\n\tpass")
	HUB.testing.test(
		tester_programa("hOLa"),
		verificador_programa_creado("hOLa"), []
	)
	HUB.archivos.borrar(carpeta, "hOLa.gd")
	HUB.mensaje("* Testeando finalizar un proceso")
	HUB.testing.test(
		tester_fin_programa("hOLa"),
		verificador_programa_finalizado("hOLa"), []
	)

func tester_programa(programa):
	return TesterPrograma.new(HUB, programa)
func tester_fin_programa(programa):
	return TesterFinPrograma.new(HUB, programa)

class TesterPrograma:
	var HUB
	var programa
	func _init(hub, programa):
		HUB = hub
		self.programa = programa
	func test():
		return HUB.procesos.nuevo(programa)

class TesterFinPrograma:
	var HUB
	var programa
	func _init(hub, programa):
		HUB = hub
		self.programa = programa
	func test():
		return HUB.procesos.finalizar(programa)

func verificador_programa_creado(nombre):
	return VerificadorProgramaCreado.new(HUB, nombre)
func verificador_programa_finalizado(nombre):
	return VerificadorProgramaFinalizado.new(HUB, nombre)

class VerificadorProgramaCreado:
	var HUB
	var nombre
	func _init(hub, nombre):
		HUB = hub
		self.nombre = nombre
	func verificar(resultado):
		if nombre in HUB.procesos.todos():
			return ""
		return 'Se esperaba que existiera un proceso con identificador "' + \
			nombre + '" pero no hay ninguno.'

class VerificadorProgramaFinalizado:
	var HUB
	var nombre
	func _init(hub, nombre):
		HUB = hub
		self.nombre = nombre
	func verificar(resultado):
		if nombre in HUB.procesos.todos():
			return 'Se esperaba que el proceso con pid "' + nombre + \
			'" hubiese finalizado pero aún existe.'
		if HUB.procesos.actual_pid() != "HUB":
			return 'Se esperaba que el proceso actual fuese el HUB pero es "' + \
			HUB.procesos.actual_pid() + '".'
		return ""

func descripcion():
	return "Test"

func man():
	var r = "[ TEST ] - " + descripcion()
	return r
