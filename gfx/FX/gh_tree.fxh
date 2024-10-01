# THIS IS A GENERATED FILE.
#
# Source template:
# ../GHTemplates/gfx/FX/gh_tree.fxh.jinja
#
# Please avoid manually editing this file: your changes WILL be overwritten when it gets regenerated.
# Instead, edit the source template and/or variables, then run render_templates.bat .

Effect GH_tree_NOT_desert # tree
{
	VertexShader = VS_standard
	PixelShader = PS_leaf
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_tree_NOT_desertshadow # treeShadow
{
	VertexShader = VertexPdxMeshStandardShadow
	PixelShader = PixelPdxMeshAlphaBlendShadow
	BlendState = BlendStateShadow
	RasterizerState = ShadowRasterizerState
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_tree_NOT_desert_mapobject # tree_mapobject
{
	VertexShader = VS_mapobject
	PixelShader = PS_leaf
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_tree_NOT_desertShadow_mapobject # treeShadow_mapobject
{
	VertexShader = VS_jomini_mapobject_shadow
	PixelShader = PS_jomini_mapobject_shadow_alphablend
	BlendState = BlendStateShadow
	RasterizerState = ShadowRasterizerState
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_tree_NOT_desert_lod # tree_lod
{
	VertexShader = VS_standard
	PixelShader = PS_leaf
	BlendState = BlendStateLod
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_tree_NOT_desert_lodShadow # tree_lodShadow
{
	VertexShader = VertexPdxMeshStandardShadow
	PixelShader = PixelPdxMeshAlphaBlendShadow
	BlendState = BlendStateShadow
	RasterizerState = ShadowRasterizerState
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_tree_NOT_desert_lod_mapobject # tree_lod_mapobject
{
	VertexShader = VS_mapobject
	PixelShader = PS_leaf
	BlendState = BlendStateLod
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_tree_NOT_desert_lodShadow_mapobject # tree_lodShadow_mapobject
{
	VertexShader = VS_jomini_mapobject_shadow
	PixelShader = PS_jomini_mapobject_shadow_alphablend
	BlendState = BlendStateShadow
	RasterizerState = ShadowRasterizerState
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}