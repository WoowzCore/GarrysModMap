$scale 4

$modelname "woowz11/other/sphere.mdl"

$bodygroup "studio" {
	studio "sphere.smd"
}

$surfaceprop "metal"
$contents "solid"
$staticprop
$opaque

$cdmaterials "woowz_map\gm_garrymod_map_by_woowz_map_garry_game\woowzcore\"

$texturegroup "skinfamilies" {
	{ "crystal"  }
	{ "crystal2" }
	{ "crystal3" }
	{ "concrete_vertex" }
	{ "glow" }
	{ "black" }
	{ "wireframe" }
}

$sequence "idle" {
	"sphere.smd"
	activity "ACT_IDLE" 1
	fps 1
}

$collisionmodel "sphere.smd" {
	$mass 500
	$inertia 1
	$damping 0.2
	$rotdamping 0.5
	$concave
}