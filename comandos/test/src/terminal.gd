## Test/SRC/Terminal
## Comando

# Testea el módulo Terminal.
# Requiere:
	# -

extends Node

var HUB
var carpeta

func inicializar(hub):
	HUB = hub
	carpeta = HUB.terminal.nodo_comandos.carpeta_comandos

func comando(argumentos):
	var nodo = Node.new()
	HUB.mensaje("Testeando el módulo Terminal")
	HUB.mensaje("* Testeando ejecutar comando inexistente")
	HUB.testing.comando_fallido("hola",
		HUB.archivos.archivo_inexistente(carpeta, "hola.gd"), []
	)
	HUB.mensaje("* Testeando ejecutar un comando vacío")
	HUB.archivos.crear(carpeta, "hola.gd")
	HUB.testing.test_genera_error(
		tester_comando("hola"),
		HUB.archivos.encabezado_faltante("hola.gd"), []
	)
	HUB.mensaje("* Testeando ejecutar un comando sin encabezado 1")
	HUB.archivos.escribir(carpeta, "hola.gd", "hola")
	HUB.testing.test_genera_error(
		tester_comando("hola"),
		HUB.archivos.encabezado_faltante("hola.gd"), []
	)
	HUB.mensaje("* Testeando ejecutar un comando sin encabezado 2")
	HUB.archivos.escribir(carpeta, "hola.gd", "## hola")
	HUB.testing.test_genera_error(
		tester_comando("hola"),
		HUB.archivos.encabezado_faltante("hola.gd"), []
	)
	HUB.mensaje("* Testeando ejecutar un comando sin encabezado 3")
	HUB.archivos.sobrescribir(carpeta, "hola.gd", "## hola\nhola")
	HUB.testing.test_genera_error(
		tester_comando("hola"),
		HUB.archivos.encabezado_faltante("hola.gd"), []
	)
	HUB.mensaje("* Testeando ejecutar un comando con nombre incorrecto")
	HUB.archivos.sobrescribir(carpeta, "hola.gd", "## chau\n## chau")
	HUB.testing.test_genera_error(
		tester_comando("hola"),
		HUB.archivos.encabezado_invalido_nombre("hola.gd", "hola"), []
	)
	HUB.mensaje("* Testeando ejecutar un comando con tipo incorrecto")
	HUB.archivos.sobrescribir(carpeta, "hola.gd", "## hola\n## hola")
	HUB.testing.test_genera_error(
		tester_comando("hola"),
		HUB.archivos.encabezado_invalido_tipo("hola.gd", "Comando"), []
	)
	HUB.mensaje("* Testeando ejecutar un comando sin función de inicialización")
	nodo.set_name("hola.gd")
	HUB.archivos.sobrescribir(carpeta, "hola.gd", "## hola\n## Comando")
	HUB.testing.test_genera_error(
		tester_comando("hola"),
		HUB.errores.funcion_no_implementada(nodo, "inicializar", 1), []
	)
	HUB.archivos.borrar(carpeta, "hola.gd")
	HUB.mensaje("* Testeando ejecutar un comando con función de inicialización sin parámetros")
	nodo.set_name("hoLa.gd")
	HUB.archivos.crear(carpeta, "hoLa.gd")
	HUB.archivos.escribir(carpeta, "hoLa.gd", "## hola\n## Comando\nfunc inicializar():\n\tpass")
	HUB.testing.test_genera_error(
		tester_comando("hoLa"),
		HUB.errores.funcion_no_implementada(nodo, "inicializar", 1), []
	)
	HUB.archivos.borrar(carpeta, "hoLa.gd")
	HUB.mensaje("* Testeando ejecutar un comando con función de inicialización con 2 parámetros")
	nodo.set_name("hOla.gd")
	HUB.archivos.crear(carpeta, "hOla.gd")
	HUB.archivos.escribir(carpeta, "hOla.gd", "## hola\n## Comando\n" + \
	"func inicializar(hub, x):\n\tpass")
	HUB.testing.test_genera_error(
		tester_comando("hOla"),
		HUB.errores.funcion_no_implementada(nodo, "inicializar", 1), []
	)
	HUB.archivos.borrar(carpeta, "hOla.gd")
	HUB.mensaje("* Testeando ejecutar un comando sin función de ejecución")
	nodo.set_name("Hola.gd")
	HUB.archivos.crear(carpeta, "Hola.gd")
	HUB.archivos.escribir(carpeta, "Hola.gd", "## hola\n## Comando\nfunc inicializar(a):\n\tpass")
	HUB.testing.test_genera_error(
		tester_comando("Hola"),
		HUB.errores.funcion_no_implementada(nodo, "comando", 1), []
	)
	HUB.archivos.borrar(carpeta, "Hola.gd")
	HUB.mensaje("* Testeando ejecutar un comando con función de ejecución sin parámretros")
	nodo.set_name("holA.gd")
	HUB.archivos.crear(carpeta, "holA.gd")
	HUB.archivos.escribir(carpeta, "holA.gd", "## hola\n## Comando\nfunc inicializar(a):\n\tpass\nfunc comando():\n\tpass")
	HUB.testing.test_genera_error(
		tester_comando("holA"),
		HUB.errores.funcion_no_implementada(nodo, "comando", 1), []
	)
	HUB.archivos.borrar(carpeta, "holA.gd")
	HUB.mensaje("* Testeando ejecutar un comando con función de ejecución con 2 parámretros")
	nodo.set_name("HolA.gd")
	HUB.archivos.crear(carpeta, "HolA.gd")
	HUB.archivos.escribir(carpeta, "HolA.gd", "## hola\n## Comando\nfunc inicializar(a):\n\tpass\nfunc comando(a, b):\n\tpass")
	HUB.testing.test_genera_error(
		tester_comando("HolA"),
		HUB.errores.funcion_no_implementada(nodo, "comando", 1), []
	)
	HUB.archivos.borrar(carpeta, "HolA.gd")
	HUB.mensaje("* Testeando ejecutar un comando correcto")
	nodo.set_name("hOLa.gd")
	HUB.archivos.crear(carpeta, "hOLa.gd")
	HUB.archivos.escribir(carpeta, "hOLa.gd", "## hola\n## Comando\nfunc inicializar(a):\n\tpass\nfunc comando(a):\n\treturn 95")
	HUB.testing.test(
		tester_comando("hOLa"),
		HUB.testing.verificador_por_igualdad(95), []
	)
	HUB.archivos.borrar(carpeta, "hOLa.gd")
	HUB.mensaje("Testeando el parser de argumentos")
	HUB.mensaje("* Testeando ejecutar un comando con un argumento")
	HUB.archivos.crear(carpeta, "a.gd")
	HUB.archivos.escribir(carpeta, "a.gd", "## a\n## Comando\nfunc inicializar(a):\n\tpass\nfunc comando(args):\n\tif args.size()==0:\n\t\treturn 2\n\telse:\n\t\treturn args[0]")
	HUB.testing.test(tester_comando("a"), HUB.testing.verificador_por_igualdad(2), [])
	HUB.testing.test(tester_comando("a 5"), HUB.testing.verificador_por_igualdad("5"), [])
	HUB.archivos.borrar(carpeta, "a.gd")
	HUB.mensaje("* Testeando ejecutar sin argumentos un comando que requiere un argumento")
	HUB.archivos.crear(carpeta, "b.gd")
	HUB.archivos.escribir(carpeta, "b.gd", '## b\n## Comando\nfunc inicializar(a):\n\tpass\nfunc comando(args):\n\treturn args["m"]')
	HUB.archivos.escribir(carpeta, "b.gd", 'var arg_map = {"obligatorios":1,"lista":[{"nombre":"modo","codigo":"m","default":"0"}]}')
	HUB.testing.test_genera_error(
		tester_comando("b"),
		HUB.terminal.nodo_comandos.faltan_argumentos_obligatorios("modo"), []
	)
	HUB.mensaje("* Testeando ejecutar con dos argumentos un comando que sólo admite un argumento")
	HUB.testing.test_genera_error(
		tester_comando("b 1 2"),
		HUB.terminal.nodo_comandos.mas_argumentos_que_los_esperados(1), []
	)
	HUB.mensaje("* Testeando ejecutar un comando con la cantidad correcta de argumentos")
	HUB.testing.test(tester_comando("b A"), HUB.testing.verificador_por_igualdad("A"), [])
	HUB.testing.test(tester_comando("b -mB"), HUB.testing.verificador_por_igualdad("B"), [])
	HUB.mensaje("* Testeando ejecutar un comando con un modificador no admitido")
	HUB.testing.test_genera_error(
		tester_comando("b -cC"),
		HUB.terminal.nodo_comandos.modificador_invalido("c", "-cC"), []
	)
	HUB.mensaje("* Testeando ejecutar un comando con un modificador repetido")
	HUB.testing.test_genera_error(
		tester_comando("b -mD -mE"),
		HUB.terminal.nodo_comandos.modificador_repetido("m"), []
	)
	HUB.archivos.borrar(carpeta, "b.gd")
	HUB.mensaje("* Testeando que los argumentos por defecto se cargan correctamente")
	HUB.archivos.crear(carpeta, "c.gd")
	HUB.archivos.escribir(carpeta, "c.gd", '## c\n## Comando\nfunc inicializar(a):\n\tpass\nfunc comando(args):\n\treturn args["a"] + args["b"] + args["c"] + args["d"]')
	HUB.archivos.escribir(carpeta, "c.gd", 'var arg_map = {"obligatorios":2,"lista":[{"nombre":"a","codigo":"a"},{"nombre":"b","codigo":"b"},{"nombre":"c","codigo":"c","default":"C"},{"nombre":"d","codigo":"d","default":"D"}]}')
	HUB.testing.test(tester_comando("c E R T"), HUB.testing.verificador_por_igualdad("ERTD"), [])
	HUB.mensaje("* Testeando que los argumentos se ordenan correctamente")
	HUB.testing.test(tester_comando("c -dI -bY T U"), HUB.testing.verificador_por_igualdad("TYUI"), [])
	HUB.testing.test(tester_comando("c Y U -aT I"), HUB.testing.verificador_por_igualdad("TYUI"), [])
	HUB.testing.test(tester_comando("c Y -aT"), HUB.testing.verificador_por_igualdad("TYCD"), [])
	HUB.archivos.borrar(carpeta, "c.gd")
	# TODO: Test con extras
	HUB.mensaje("* Testeando que distinguen y procesan correctamente los argumentos extras")
	HUB.archivos.crear(carpeta, "d.gd")
	HUB.archivos.escribir(carpeta, "d.gd", '## d\n## Comando\nfunc inicializar(a):\n\tpass\nfunc comando(args):\n\tvar r = ""\n\tfor i in args.extra:\n\t\tr+=i\n\treturn args["a"] + args["b"] + args["c"] + args["d"] + "|" + r')
	HUB.archivos.escribir(carpeta, "d.gd", 'var arg_map = {"obligatorios":2,"extra":true,"lista":[{"nombre":"a","codigo":"a"},{"nombre":"b","codigo":"b"},{"nombre":"c","codigo":"c","default":"C"},{"nombre":"d","codigo":"d","default":"D"}]}')
	HUB.testing.test(tester_comando("d -bW -aQ E R"), HUB.testing.verificador_por_igualdad("QWCD|ER"), [])
	HUB.testing.test(tester_comando("d -bW -aQ E -cR"), HUB.testing.verificador_por_igualdad("QWRD|E"), [])
	HUB.mensaje("* Testeando que los argumentos extras no reemplazan a los modificadores")
	HUB.testing.test(tester_comando("d Q W E R"), HUB.testing.verificador_por_igualdad("QWCD|ER"), [])
	HUB.archivos.borrar(carpeta, "d.gd")
	HUB.mensaje("* Testeando ejecutar un comando pasándole un argumento de tipo incorrecto")
	HUB.archivos.crear(carpeta, "e.gd")
	HUB.archivos.escribir(carpeta, "e.gd", '## e\n## Comando\nfunc inicializar(a):\n\tpass\nfunc comando(args):\n\treturn args.a')
	HUB.archivos.escribir(carpeta, "e.gd", 'var arg_map = {"obligatorios":0,"lista":[{"nombre":"a","codigo":"a","validar":"NUM;>=2;<10","default":"5"},{"nombre":"b","codigo":"b","validar":"INT;>=5","default":"5"},{"nombre":"c","codigo":"c","validar":"DEC;<2","default":"0.5"}]}')
	HUB.testing.test_genera_error(
		tester_comando("e hola"),
		HUB.terminal.nodo_comandos.argumento_tipo_incorrecto("a", "hola", "NUM"), []
	)
	HUB.testing.test_genera_error(
		tester_comando("e 1"),
		HUB.terminal.nodo_comandos.argumento_tipo_incorrecto("a", "1", ">=2"), []
	)
	HUB.testing.test_genera_error(
		tester_comando("e 12"),
		HUB.terminal.nodo_comandos.argumento_tipo_incorrecto("a", "12", "<10"), []
	)
	HUB.testing.test_genera_error(
		tester_comando("e 3 6.5"),
		HUB.terminal.nodo_comandos.argumento_tipo_incorrecto("b", "6.5", "INT"), []
	)
	HUB.testing.test_genera_error(
		tester_comando("e 3 6 j"),
		HUB.terminal.nodo_comandos.argumento_tipo_incorrecto("c", "j", "DEC"), []
	)
	HUB.mensaje("* Testeando que los argumentos se validan y convierten correctamente")
	HUB.testing.test(tester_comando("e"), HUB.testing.verificador_por_igualdad(5), [])
	HUB.testing.test(tester_comando("e 2.5"), HUB.testing.verificador_por_igualdad(2.5), [])
	HUB.archivos.borrar(carpeta, "e.gd")

func tester_comando(comando):
	return TesterComando.new(HUB, comando)

class TesterComando:
	var HUB
	var comando
	func _init(hub, comando):
		HUB = hub
		self.comando = comando
	func test():
		return HUB.terminal.ejecutar(comando)

func descripcion():
	return "Test"

func man():
	var r = "[ TEST ] - " + descripcion()
	return r