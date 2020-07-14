## SdE
## Programa

# Sala de Escape

extends Node

var HUB
var pid

var lib_map = [
	"HUB3DLang"
]

var modulo = "SdE"
var HUB3DLang

var jugador
var sala
var ventana
var ventana_rsa
var ventana_warn
var tip

var light_switch
var luz
var monitor
var morse
var tapa_cofre
var candado
var mensaje_cofre
var segundos_restantes
var colores

var rsa_encriptado = false

var textos = {
	"se_warn":"Estás enviando texto plano por un canal\nsin encriptar.\nOtras personas en esta red podrían verlo.\n¿Estás seguro de que deseás continuar?",
	"no_enviar_se":"¡Muy bien! Es importante usar encriptación al\nenviar mensajes con información sensible.",
	"si_enviar_se":"El mensaje que enviaste podría haber sido\ninterceptado.\nSi no querés que esto pase, tenés que\nabrir el chat encriptado.",
	"light_off":"Apagá la luz",
	"coloreo":"Colorear cada provincia con un color de forma que\nsi dos provincias son limítrofes, sus colores sean distintos.",
	"tsp":"Encontrar el mejor camino para pasar\npor todas las ciudades partiendo de Fortran."
}

var msgs_juan = [
	"Hola Claudia, ¿me pasás la contraseña del maletín?",
	"Qué bueno que pusiste el chat seguro, así hablamos más tranquilos. Ahora sí, pasame la contraseña que debe estar escondida por ahí.",
	"No entiendo nada de lo que pusiste. Acordate de encriptar tus mensajes con mi clave pública.",
	"Uh, no estaba lo que buscaba. Dentro sólo había un papel que decía '01011101', no sé para qué servirá.",
	"Si querés después te llamo y hablamos bien, pero ahora necesito urgente la clave de la caja de seguridad."
]

func inicializar(hub, pid, argumentos):
	HUB = hub
	self.pid = pid
	HUB3DLang = lib_map["HUB3DLang"]
	HUB.pantalla.completa()			# Pantalla completa
	HUB.terminal.cerrar()			# Ocultar terminal
	pantalla_inicio()
	return null

func pantalla_inicio():
	HUB.eventos.set_modo_mouse()	# Mostrar mouse
	var texto_intro = HUB.archivos.leer("data/sde","intro.txt")
	ventana = HUB.nodo_usuario.ventana(self,{
		"titulo":"Sala de Escape Científica - Edición Virtual",
		"tamanio":Vector2(75,75),
		"botones":[
			{"texto":"Comenzar","accion":"crear_sala"},
			{"texto":"Salir","accion":"salir"}
		],
		"cuerpo":[
			{"clase":ScrollContainer,"tamanio":Vector2(95,98),"posicion":"center","args":{"scroll/horizontal":false},
			"hijos":[{"clase":"texto","args":{"texto":texto_intro}}]}
		]
	})

func crear_sala():
	if jugador != null:
		return
	if ventana != null:
		ventana.cerrar()
		ventana = null
	HUB.eventos.set_modo_mouse(2)
	jugador = HUB3DLang.crear("fps:ox-4:oz4:ry45")
	if HUB.errores.fallo(jugador):
		return jugador
	sala = HUB3DLang.crear("sde/sala:nsala")
	if HUB.errores.fallo(sala):
		return sala
	light_switch = sala.hijo_nombrado("switch")
	monitor = sala.hijo_nombrado("rsa").hijo_nombrado("monitor")
	luz = sala.hijo_nombrado("luz")
	morse = sala.hijo_nombrado("morse")
	var cofre = sala.hijo_nombrado("cofre")
	tapa_cofre = cofre.hijo_nombrado("tapa")
	candado = cofre.hijo_nombrado("candado")
	mensaje_cofre = cofre.hijo_nombrado("mensaje")
	colores = [
		{"actual":0,"correcto":4,"pos":Vector2(52,44)},# ALOLA
		{"actual":0,"correcto":3,"pos":Vector2(60,33)},# NORTHERN
		{"actual":0,"correcto":1,"pos":Vector2(49,61)},# JOHTO
		{"actual":0,"correcto":4,"pos":Vector2(61,12)},# ALDERAAN
		{"actual":0,"correcto":3,"pos":Vector2(45,74)},# TATOOINE
		{"actual":0,"correcto":2,"pos":Vector2(36,36)},# SCRABB
		{"actual":0,"correcto":4,"pos":Vector2(33,60)},# GONDOR
		{"actual":0,"correcto":3,"pos":Vector2(24,39)},# NABOO
		{"actual":0,"correcto":4,"pos":Vector2(27,21)},# HOTH
		{"actual":0,"correcto":2,"pos":Vector2(31,79)},# KALOS
		{"actual":0,"correcto":0,"pos":Vector2(12,54)},# RIVENDELL
		{"actual":0,"correcto":0,"pos":Vector2(22,77)},# DALARAN
		{"actual":0,"correcto":0,"pos":Vector2(25,86)},# BOOTY
		{"actual":0,"correcto":0,"pos":Vector2(61,80)},# UNOVA
		{"actual":0,"correcto":0,"pos":Vector2(75,68)},# PLUNDER
		{"actual":0,"correcto":0,"pos":Vector2(81,40)},# MORDOR
		{"actual":0,"correcto":0,"pos":Vector2(83,27)} # LUCRE
	]
	HUB.nodo_usuario.gui(self, {"componentes":[{
	"clase":Panel,"posicion":"top-center","tamanio":Vector2(15,8),
	"hijos":[{"id":"timer","clase":"texto","posicion":"center",
	"args":{"texto":"20:00","size":30}}]}]})
	segundos_restantes = 20*60
	HUB.eventos.registrar_secuencia(self, "TIMER", ["W|1000","F|timer","R"])

func timer(args):
	if segundos_restantes > 0:
		segundos_restantes -= 1
		var l = HUB.nodo_usuario.gui_id("timer")
		var m = str(int(segundos_restantes/60))
		if m.length() == 1:
			m = "0"+m
		var s = str(int(segundos_restantes%60))
		if s.length() == 1:
			s = "0"+s
		l.set_text(m+":"+s)
	else:
		pass # PERDISTE!

func salir():
	HUB.procesos.finalizar(self)

func finalizar():
	if ventana != null:
		ventana.cerrar()
	if ventana_rsa != null:
		ventana_rsa.cerrar()
	if tip != null:
		tip.cerrar()
	if ventana_warn != null:
		ventana_warn.cerrar()
	if jugador != null:
		HUB.objetos.borrar(jugador)
	if sala != null:
		HUB.objetos.borrar(sala)
	HUB.eventos.anular_periodico(self)
	HUB.eventos.set_modo_mouse()
	HUB.pantalla.completa(false)
	HUB.terminal.abrir()
	return null

# argumentos: [quien, target, que]
func tip(args):
	if args[2]:
		if tip != null:
			tip.cerrar()
		var texto = "Q: "
		var item = args[1]
		if item == light_switch:
			if luz.mensaje("encendida"):
				texto += "apagar"
			else:
				texto += "encender"
			texto += " la luz"
		#elif item == monitor:
		#	texto += "aa"
		elif item == candado:
			texto += "abrir"
		elif item == mensaje_cofre:
			texto += "leer"
		else:
			texto += "inspeccionar"
		tip = HUB.nodo_usuario.ventana(self,{
			"titulo":"",
			"tamanio":Vector2(15,7),
			"posicion":["bottom-center",Vector2(0,10)],
			"cuerpo":[
				{"clase":CenterContainer,"tamanio":Vector2(100,100),
				"hijos":[{"clase":"texto","id":"tip","args":{"texto":texto}}]}
			]
		})
	elif tip != null:
		tip.cerrar()
		tip = null

# argumentos: [quien, target, que]
func interruptor_luz(args):
	var encendida = luz.mensaje("alternar")
	if tip != null:
		var texto = "Q: "
		if luz.mensaje("encendida"):
			texto += "apagar"
		else:
			texto += "encender"
		texto += " la luz"
		var label = HUB.nodo_usuario.gui_id("tip")
		label.set_text(texto)
	if encendida:
		morse.mensaje("desactivar")
	else:
		morse.mensaje("activar")

# argumentos: [quien, target, que]
func coloreo(args):
	HUB.eventos.set_modo_mouse()
	jugador.pausa()
	if ventana != null:
		ventana.cerrar()
	var opciones_coloreo = [{"clase":TextureFrame,"tamanio":Vector2(100,100),"args":
		{"size_flags/vertical":TextureFrame.SIZE_EXPAND,"size_flags/horizontal":TextureFrame.SIZE_EXPAND,
		"expand":true,"stretch_mode":TextureFrame.STRETCH_SCALE,"texture":HUB.archivos.abrir_recurso("mapa.png")}}]
	for i in range(colores.size()):
		opciones_coloreo.append({"clase":"opcion","id":"color_"+str(i),
		"args":{"opciones":["ninguno","rojo","azul","verde","amarillo"]},"posicion":colores[i]["pos"]})
	for i in [
		["rojo", Vector2(50,27)], # LORDAERON
		["verde", Vector2(46,49)],# MIDGARD
		["azul", Vector2(61,53)], # ASGARD
		["rojo", Vector2(28,61)], # KALIMDOR
		["rojo", Vector2(22,20)]]:# KANTO
		opciones_coloreo.append({"clase":"texto","args":{"texto":i[0],"color":Color(0,0,0)},"posicion":i[1]})
	opciones_coloreo.append({"clase":"boton","args":{"texto":" ? "},"posicion":"top-right","id":"coloreo?"})
	ventana = HUB.nodo_usuario.ventana(self,{
		"titulo":"Coloreando provincias",
		"tamanio":Vector2(80,75),
		"botones":[
			{"texto":"Cerrar","accion":"cerrar_ventana"}
		],
		"cuerpo":[{"clase":Container,"tamanio":Vector2(95,98),"posicion":"center","hijos":opciones_coloreo}]
	})
	for i in range(colores.size()):
		var opt = HUB.nodo_usuario.gui_id("color_"+str(i))
		opt.select(colores[i]["actual"])
		opt.connect("item_selected", self, "colorear", [i])
	HUB.nodo_usuario.gui_id("coloreo?").connect("button_up", self, "info_colorear")

func info_colorear():
	if ventana != null:
		ventana.ocultar()
	if ventana_warn != null:
		ventana_warn.cerrar()
	ventana_warn = HUB.nodo_usuario.ventana(self, {"titulo":"Instrucciones",
	"tamanio":Vector2(40,35),"cuerpo":[{"clase":"texto",
	"posicion":"center","args":{"texto":textos["coloreo"]}}],
	"botones":[{"texto":"Aceptar","accion":"warn_ok"}]})

# argumentos: [quien, target, que]
func tsp(args):
	HUB.eventos.set_modo_mouse()
	jugador.pausa()
	if ventana != null:
		ventana.cerrar()
	ventana = HUB.nodo_usuario.ventana(self,{
		"titulo":"El camino que debo recorrer",
		"tamanio":Vector2(80,75),
		"botones":[
			{"texto":"Cerrar","accion":"cerrar_ventana"}
		],
		"cuerpo":[{"clase":Container,"tamanio":Vector2(95,98),"posicion":"center","hijos":[
			{"clase":TextureFrame,"tamanio":Vector2(100,100),"args":
			{"size_flags/vertical":TextureFrame.SIZE_EXPAND,"size_flags/horizontal":TextureFrame.SIZE_EXPAND,
			"expand":true,"stretch_mode":TextureFrame.STRETCH_SCALE,"texture":HUB.archivos.abrir_recurso("tsp.png")}},
			{"clase":"boton","args":{"texto":" ? "},"posicion":"top-right","id":"coloreo?"}]}]
	})
	HUB.nodo_usuario.gui_id("coloreo?").connect("button_up", self, "info_tsp")

func info_tsp():
	if ventana != null:
		ventana.ocultar()
	if ventana_warn != null:
		ventana_warn.cerrar()
	ventana_warn = HUB.nodo_usuario.ventana(self, {"titulo":"Instrucciones",
	"tamanio":Vector2(40,35),"cuerpo":[{"clase":"texto",
	"posicion":"center","args":{"texto":textos["tsp"]}}],
	"botones":[{"texto":"Aceptar","accion":"warn_ok"}]})

func warn_ok():
	if ventana_warn != null:
		ventana_warn.cerrar()
	if ventana != null:
		ventana.mostrar()

func colorear(color,nodo):
	colores[nodo]["actual"] = color

# argumentos: [quien, target, que]
func rsa(args):
	HUB.eventos.set_modo_mouse()
	jugador.pausa()
	monitor.mensaje("silencio")
	if ventana_rsa == null:
		ventana_rsa()
	else:
		ventana_rsa.mostrar()

# argumentos: [quien, target, que]
func candado(args):
	HUB.eventos.set_modo_mouse()
	jugador.pausa()
	if ventana != null:
		ventana.cerrar()
	var botones = []
	for i in range(9):
		botones.append({"clase":"boton","args":{"texto":" "+str(i+1)+" ","size":60},"id":"btn_"+str(i+1)})
	ventana = HUB.nodo_usuario.ventana(self,{
		"titulo":"Clave del candado",
		"tamanio":Vector2(30,50),
		"botones":[
			{"texto":"Cerrar","accion":"cerrar_ventana"}
		],
		"cuerpo":[{"clase":CenterContainer,"tamanio":Vector2(95,98),"hijos":[
			{"clase":GridContainer,"tamanio":Vector2(95,98),"posicion":"center",
			"args":{"columns":3},"hijos":botones}]},
			{"clase":HBoxContainer,"posicion":"bottom","hijos":
			[{"clase":"boton","id":"candado_clear","args":{"texto":"Borrar"}},
			{"clase":"texto","id":"clave_candado","args":{"texto":"___","size":25}},
			{"clase":"boton","id":"candado_enter","args":{"texto":"Aceptar"}}]}
		]
	})
	var btn = HUB.nodo_usuario.gui_id("candado_clear")
	btn.connect("button_up", self, "boton_candado", [0])
	btn.set_disabled(true)
	btn = HUB.nodo_usuario.gui_id("candado_enter")
	btn.connect("button_up", self, "boton_candado", [10])
	btn.set_disabled(true)
	for i in range(9):
		btn = HUB.nodo_usuario.gui_id("btn_"+str(i+1))
		btn.connect("button_up", self, "boton_candado", [i+1])

func boton_candado(x):
	var clave = HUB.nodo_usuario.gui_id("clave_candado")
	var texto = clave.get_text()
	var enter = HUB.nodo_usuario.gui_id("candado_enter")
	var clear = HUB.nodo_usuario.gui_id("candado_clear")
	if x==0:
		clave.set_text("___")
		enter.set_disabled(true)
		clear.set_disabled(true)
		return
	elif x==10:
		if texto == "856":
			candado.quitar_comportamiento("interactive")
			cerrar_ventana()
			abrir_cofre()
			mensaje_cofre.agregar_comportamiento("interactive",[[],{"s":"mensaje_cofre","m":"mensaje","p":"tip","r":0.5}])
		else:
			clave.set_text("___")
			enter.set_disabled(true)
			clear.set_disabled(true)
		return
	candado.mensaje("sonar")
	clear.set_disabled(false)
	var i = 0
	while i<3 and texto[i] != "_":
		i += 1
	if i==3:
		return
	if i==2:
		enter.set_disabled(false)
	texto[i] = str(x)
	clave.set_text(texto)

func abrir_cofre():
	HUB.eventos.registrar_periodico(self, "abrir_cofre_step")

func abrir_cofre_step(delta):
	if tapa_cofre.get_rotation_deg().x > -60:
		tapa_cofre.rotate_x(delta/3.0)
	else:
		HUB.eventos.anular_periodico(self)

# argumentos: [quien, target, que]
func mensaje_cofre(args):
	HUB.eventos.set_modo_mouse()
	jugador.pausa()
	if ventana_warn != null:
		ventana_warn.cerrar()
	ventana = HUB.nodo_usuario.ventana(self, {"titulo":"Mensaje",
	"tamanio":Vector2(30,30),"cuerpo":[{"clase":"texto",
	"posicion":"center","args":{"texto":textos["light_off"]}}],
	"botones":[{"texto":"Cerrar","accion":"cerrar_ventana"}]})

func rsa_enviar():
	if rsa_encriptado:
		pass
	else:
		if ventana_rsa != null:
			ventana_rsa.ocultar()
		ventana_warn = HUB.nodo_usuario.ventana(self, {"titulo":"Advertencia",
		"tamanio":Vector2(30,30),"cuerpo":[{"clase":"texto",
		"posicion":"center","args":{"texto":textos["se_warn"]}}],
		"botones":[{"texto":"Sí","accion":"rsa_warn_si"},{"texto":"No","accion":"rsa_warn_no"}]})

func rsa_warn_si():
	if ventana_warn != null:
		ventana_warn.cerrar()
	ventana_warn = HUB.nodo_usuario.ventana(self, {"titulo":"Notificación",
	"tamanio":Vector2(30,30),"cuerpo":[{"clase":"texto",
	"posicion":"center","args":{"texto":textos["si_enviar_se"]}}],
	"botones":[{"texto":"Aceptar","accion":"rsa_warn_ok"}]})

func rsa_warn_no():
	if ventana_warn != null:
		ventana_warn.cerrar()
	ventana_warn = HUB.nodo_usuario.ventana(self, {"titulo":"Notificación",
	"tamanio":Vector2(30,30),"cuerpo":[{"clase":"texto",
	"posicion":"center","args":{"texto":textos["no_enviar_se"]}}],
	"botones":[{"texto":"Aceptar","accion":"rsa_warn_ok"}]})

func rsa_warn_ok():
	if ventana_warn != null:
		ventana_warn.cerrar()
	if ventana_rsa != null:
		ventana_rsa.mostrar()

func rsa_modo():
	if ventana_rsa != null:
		ventana_rsa.cerrar()
	rsa_encriptado = not rsa_encriptado
	ventana_rsa()

func ventana_rsa():
	if rsa_encriptado:
		rsa_encriptado()
	else:
		rsa_sin_encriptar()

func rsa_sin_encriptar():
	ventana_rsa = HUB.nodo_usuario.ventana(self,{
		"tamanio":Vector2(50,40),
		"titulo":"Chat sin encriptar",
		"cuerpo":[
			{"clase":"boton","id":"boton_rsa","posicion":["top-right",Vector2(5,-12)],
				"args":{"texto":"Activar encripción"}},
			{"clase":VBoxContainer,"tamanio":Vector2(96,90),"posicion":["top-left",Vector2(3,0)],
			"hijos":[{"clase":VBoxContainer,"tamanio":Vector2(96,50),"hijos":[
			{"clase":"texto","id":"rsa_msg_h","args":{"texto":"Recibiendo mensaje..."}},
			{"clase":"texto_entrada","id":"rsa_msg_r","args":{"edit":false}}]},
			{"clase":VBoxContainer,"tamanio":Vector2(96,50),
			"hijos":[{"clase":"texto","args":{"texto":"Responder:"}},
			{"clase":"texto_entrada","id":"rsa_msg_s"},
			{"clase":"boton","id":"boton_enviar","args":{"texto":"Enviar"}}]}]}],
		"botones":[{"texto":"Cerrar","accion":"cerrar_rsa"}]
	})
	HUB.eventos.registrar_secuencia(self, "RSA", ["W|1500","F|recibir_mensaje_rsa"])
	HUB.nodo_usuario.gui_id("boton_enviar").connect("button_up", self, "rsa_enviar")
	HUB.nodo_usuario.gui_id("boton_rsa").connect("button_up", self, "rsa_modo")

func rsa_encriptado():
	ventana_rsa = HUB.nodo_usuario.ventana(self,{
		"tamanio":Vector2(65,60),
		"titulo":"Chat encriptado",
		"cuerpo":[
			{"clase":"boton","id":"boton_rsa","posicion":["top-right",Vector2(5,-7)],
				"args":{"texto":"Desactivar encripción"}},
			{"clase":Container,"tamanio":Vector2(96,90),
			"hijos":[
			{"clase":VBoxContainer,"posicion":["center",Vector2(3,0)],"tamanio":Vector2(100,100),"hijos":[
				{"clase":VBoxContainer,"posicion":["left",Vector2(3,0)],"hijos":[
				{"clase":"texto","id":"rsa_msg_h","args":{"texto":"Recibiendo mensaje..."}},
				{"clase":"texto_entrada","id":"rsa_msg_r","args":{"edit":false}}]},
			{"clase":VBoxContainer,"hijos":[
#			{"clase":TabContainer,"tamanio":Vector2(96,50),"hijos":[
			{"clase":HBoxContainer,"tamanio":Vector2(96,50),"hijos":[
				{"clase":VBoxContainer,"args":{"size_flags/horizontal":Container.SIZE_EXPAND_FILL},"hijos":[
					{"clase":"texto","args":{"texto":"DESENCRIPTAR MENSAJE ENTRANTE:"},"posicion":"top-center"},
					{"clase":GridContainer,"args":{"columns":2},"hijos":[
						{"clase":"texto","args":{"texto":"mensaje para desencriptar"}},
						{"clase":"texto_entrada","id":"rsa_dcrypt_msg_in"},
						{"clase":"texto","args":{"texto":"clave para desencriptar"}},
						{"clase":"texto_entrada","id":"rsa_dcrypt_key"},
					]},
					{"clase":"boton","args":{"texto":"desencriptar"}},
					{"clase":"texto","args":{"texto":"mensaje desencriptado"}},
					{"clase":"texto_entrada","id":"rsa_dcrypt_msg_out","args":{"edit":false}}
				]},
				{"clase":VBoxContainer,"args":{"size_flags/horizontal":Container.SIZE_EXPAND_FILL},"hijos":[
					{"clase":"texto","args":{"texto":"ENCRIPTAR MENSAJE SALIENTE:"}},
					{"clase":GridContainer,"args":{"columns":2},"hijos":[
						{"clase":"texto","args":{"texto":"mensaje para encriptar"}},
						{"clase":"texto_entrada","id":"rsa_crypt_msg_in"},
						{"clase":"texto","args":{"texto":"clave para encriptar"}},
						{"clase":"texto_entrada","id":"rsa_crypt_key"},
					]},
					{"clase":"boton","args":{"texto":"encriptar"}},
					{"clase":"texto","args":{"texto":"mensaje encriptado"}},
					{"clase":"texto_entrada","id":"rsa_crypt_msg_out","args":{"edit":false}}
				]}
			]}]},
			{"clase":VBoxContainer,"tamanio":Vector2(96,10),
			"posicion":["bottom-left",Vector2(3,0)],
			"hijos":[{"clase":"texto","args":{"texto":"Responder:"}},
			{"clase":"texto_entrada","id":"rsa_msg_s"},
			{"clase":"boton","id":"boton_enviar","args":{"texto":"Enviar"}}]}]}]}],
		"botones":[{"texto":"Cerrar","accion":"cerrar_rsa"}]
	})
	HUB.eventos.registrar_secuencia(self, "RSA", ["W|1500","F|recibir_mensaje_rsa"])
	HUB.nodo_usuario.gui_id("boton_enviar").connect("button_up", self, "rsa_enviar")
	HUB.nodo_usuario.gui_id("boton_rsa").connect("button_up", self, "rsa_modo")

func recibir_mensaje_rsa(args):
	monitor.mensaje("sonar", ["whatsapp"])
	if ventana_rsa != null:
		HUB.nodo_usuario.gui_id("rsa_msg_h").set_text("Mensaje de juanchi:")
		HUB.nodo_usuario.gui_id("rsa_msg_r").set_text(msgs_juan[0])

func cerrar_ventana():
	if ventana != null:
		ventana.cerrar()
		ventana = null
	jugador.pausa(false)
	HUB.eventos.set_modo_mouse(2)

func cerrar_rsa():
	if ventana_rsa != null:
		ventana_rsa.ocultar()
	jugador.pausa(false)
	HUB.eventos.set_modo_mouse(2)