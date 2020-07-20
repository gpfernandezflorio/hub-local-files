## SDE/Cajonera
## Objeto
## HUB3DLang

$h=.8
$pata=cube(.06,h,.06)
$cajon=(body(static):cbox(.6,.15,.55)&cube(.6,.15,.55):nm&cube(!.15,.05,.02):nm:ox.3:oy.1:oz.55):nm:oyh+.025:sinteractive(cajon,m=m,p=tip,r=1)
body(static):cbox(1.6,h+.2,.5)
cube(1.6,.2,.5):oyh
cajon:ox.1:ncajon1
cajon:ox.9:ncajon2
face(.5,.5,y):mfixed(fff,t=colores):oy.16:ox.05:nmensaje:pcajon1
pata
pata:oz.44
pata:ox1.54
pata:ox1.54:oz.44