## RIGID
## SRC

# Script para los componentes de tipo RigidBody

extends RigidBody

var HUB
var yo

func inicializar(hub, yo):
	HUB = hub
	self.yo = yo
	HUB.eventos.registrar_periodico(self, "periodico")
	return true

func periodico(delta):
	yo.set_transform(get_global_transform())
	set_translation(Vector3(0,0,0))
	set_rotation(Vector3(0,0,0))