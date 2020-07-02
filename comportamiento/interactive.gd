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
		{"nombre":"radio", "codigo":"r", "default":2, "validar":"NUM;>0"}
	]
}

var modulo = "Interactive"
var yo
var colisionador
var mallas
var material_on
var script
var i = -1

func inicializar(hub, yo, args):
	HUB = hub
	self.yo = yo
	if args["s"] != null:
		var code = HUB.archivos.abrir("scripts/", args["s"]+".gd")
		if HUB.errores.fallo(code):
			return HUB.error(HUB.errores.error("X", code), modulo)
		script = Node.new()
		script.set_script(code)
	mallas = []
	for m in args["m"]:
		if yo.tiene_componente_nombrado(m):
			var malla = yo.componente_nombrado(m)
			if malla.get_type() != "MeshInstance":
				return HUB.error(HUB.errores.error("X"), modulo)
			mallas.append([malla.get_mesh(), materiales(malla.get_mesh())])
		elif yo.tiene_hijo_nombrado(m):
			var hijo = yo.hijo_nombrado(m)
			for componente in hijo.componentes():
				if componente.get_type() == "MeshInstance":
					mallas.append([componente.get_mesh(), materiales(componente.get_mesh())])
	colisionador = Area.new()
	var shape = SphereShape.new()
	shape.set_radius(args["r"])
	colisionador.add_shape(shape)
	add_child(colisionador)
	material_on = FixedMaterial.new()
	material_on.set("params/emission",Color(.5,.5,.2))
	material_on.set("params/specular_exp",1)
	material_on.set("params/glow",8)
	return null

func materiales(mesh):
	var ms = []
	for j in range(mesh.get_surface_count()):
		ms.append(mesh.get("surface_" + str(j+1) + "/material"))
	return ms

func interact_in():
	i = 0
	HUB.eventos.registrar_periodico(self, "periodico")
func interact_out():
	i = -1

func interact(quien, que):
	if script != null:
		script.exec(HUB, [quien, yo, que])

func periodico(delta):
	if i < 0:
		HUB.eventos.anular_periodico(self)
		for m in mallas:
			for j in range(m[0].get_surface_count()):
				m[0].set("surface_" + str(j+1) + "/material",m[1][j])
	else:
		i+=delta
		for m in mallas:
			for j in range(m[0].get_surface_count()):
				m[0].set("surface_" + str(j+1) + "/material",material_on)
		material_on.set("params/diffuse",Color(0.6+sin(i)/6,0.6+sin(i)/6,sin(i)/4))