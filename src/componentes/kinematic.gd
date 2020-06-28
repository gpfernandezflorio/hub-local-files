## KINEMATIC
## SRC

# Script para los componentes de tipo KinematicBody

extends KinematicBody

var HUB
var yo

func inicializar(hub, yo):
	HUB = hub
	self.yo = yo
	return true