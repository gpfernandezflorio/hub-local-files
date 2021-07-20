## Interactive
## Comportamiento

# Objeto con el cual se puede interactuar
# Requiere para inicializar:
	# -

extends Spatial

var HUB

var arg_map = {
	"lista":[
		{"nombre":"script", "codigo":"s", "default":null},
		{"nombre":"mallas", "codigo":"m", "default":[], "validar":"ARR"},
		{"nombre":"preview", "codigo":"p", "default":null},
		{"nombre":"radio", "codigo":"r", "default":2, "validar":"NUM;>0"}
	]
}

var modulo = "Interactive"
var yo
var colisionador
var mallas
var material_on
var codigo
var preview
var i = -1

func inicializar(hub, yo, args):
	HUB = hub
	self.yo = yo
	if args["s"] != null:
		var nombre_funcion = args["s"]
		var proceso = HUB.procesos.obtener()
		if yo.sabe(nombre_funcion):
			codigo = [yo, "mensaje", nombre_funcion]
		elif proceso.has_method(nombre_funcion):
			codigo = [proceso, nombre_funcion]
		elif HUB.archivos.existe("scripts", nombre_funcion+".gd"):
			var code = HUB.archivos.abrir("scripts", nombre_funcion+".gd")
			codigo = [Node.new(), "exec"]
			codigo[0].set_script(code)
			var res_ini = codigo[0].inicializar(HUB)
			if HUB.errores.fallo(res_ini):
				return HUB.error(HUB.errores.error("X", res_ini), modulo)
		else:
			return HUB.error(HUB.errores.error("X"), modulo)
	if args["p"] != null:
		var nombre_funcion = args["p"]
		var proceso = HUB.procesos.obtener()
		if yo.sabe(nombre_funcion):
			preview = [yo, "mensaje", nombre_funcion]
		elif proceso.has_method(nombre_funcion):
			preview = [proceso, nombre_funcion]
		elif HUB.archivos.existe("scripts", nombre_funcion+".gd"):
			var code = HUB.archivos.abrir("scripts", nombre_funcion+".gd")
			preview = [Node.new(), "exec"]
			preview[0].set_script(code)
			var res_ini = preview[0].inicializar(HUB)
			if HUB.errores.fallo(res_ini):
				return HUB.error(HUB.errores.error("X", res_ini), modulo)
		else:
			return HUB.error(HUB.errores.error("X"), modulo)
	mallas = []
	for m in args["m"]:
		if yo.tiene_componente_nombrado(m):
			var malla = yo.componente_nombrado(m)
#			if malla.get_type() != "MeshInstance":#@2
			if not malla is MeshInstance:#@3
				return HUB.error(HUB.errores.error("X"), modulo)
			mallas.append([malla.get_mesh(), materiales(malla.get_mesh())])
		elif yo.tiene_hijo_nombrado(m):
			var hijo = yo.hijo_nombrado(m)
			for componente in hijo.componentes():
#				if componente.get_type() == "MeshInstance":#@2
				if componente is MeshInstance:#@3
					mallas.append([componente.get_mesh(), materiales(componente.get_mesh())])
	colisionador = Area.new()
	var shape = SphereShape.new()
	shape.set_radius(args["r"])
#	colisionador.add_shape(shape)#@2
	var s_owner = colisionador.create_shape_owner(null)#@3
	colisionador.shape_owner_add_shape(s_owner, shape)#@3
	add_child(colisionador)
#	material_on = FixedMaterial.new()#@2
	material_on = SpatialMaterial.new()#@3
	material_on.set("params/emission",Color(.5,.5,.2))
	material_on.set("params/specular_exp",1)
	material_on.set("params/glow",8)
	return null

func finalizar():
	if i > -1:
		HUB.eventos.anular_periodico(self)
	for m in mallas:
		for j in range(m[0].get_surface_count()):
			m[0].set("surface_" + str(j+1) + "/material",m[1][j])

func materiales(mesh):
	var ms = []
	for j in range(mesh.get_surface_count()):
		ms.append(mesh.get("surface_" + str(j+1) + "/material"))
	return ms

func interact_in(quien):
	i = 0
	if preview != null:
		if preview.size() == 3:
			preview[0].call(preview[1], preview[2], [quien, yo, true])
		else:
			preview[0].call(preview[1], [quien, yo, true])
	HUB.eventos.registrar_periodico(self, "periodico")
func interact_out(quien):
	i = -1
	if preview != null:
		if preview.size() == 3:
			preview[0].call(preview[1], preview[2], [quien, yo, false])
		else:
			preview[0].call(preview[1], [quien, yo, false])

func interact(quien, que):
	if codigo != null:
		if codigo.size() == 3:
			codigo[0].call(codigo[1], codigo[2], [quien, yo, que])
		else:
			codigo[0].call(codigo[1], [quien, yo, que])

func periodico(delta):
	if i < 0:
		HUB.eventos.anular_periodico(self)
		for m in mallas:
			for j in range(m[0].get_surface_count()):
				m[0].set("surface_" + str(j+1) + "/material",m[1][j])
	else:
		i+=delta*2
		for m in mallas:
			for j in range(m[0].get_surface_count()):
				m[0].set("surface_" + str(j+1) + "/material",material_on)
		material_on.set("params/diffuse",Color(0.6+cos(i)/6,0.6+sin(i)/6,cos(i)/4))
