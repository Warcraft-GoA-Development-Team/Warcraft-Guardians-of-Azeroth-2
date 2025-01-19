# THIS IS A GENERATED FILE.
#
# Source template:
# ../GHTemplates/gfx/FX/gh_pdxmesh.fxh.jinja
#
# Please avoid manually editing this file: your changes WILL be overwritten when it gets regenerated.
# Instead, edit the source template and/or variables, then run render_templates.bat .

Effect GH_standard_NOT_desert
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_standard_NOT_desertShadow
{
	VertexShader = "GH_VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_standard_atlas_NOT_desert
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "ATLAS" "APPLY_WINTER" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_standard_atlas_NOT_desertShadow
{
	VertexShader = "GH_VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"		
	RasterizerState = ShadowRasterizerState
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_standard_NOT_desert_winter
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "APPLY_WINTER" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_standard_NOT_desert_winterShadow
{
	VertexShader = "GH_VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = ShadowRasterizerState
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_standard_NOT_desert_alpha_blend
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_blend"
	DepthStencilState = "depth_no_write"
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_standard_NOT_desert_alpha_blendShadow
{
	VertexShader = "GH_VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	
	RasterizerState = ShadowRasterizerState

	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_standard_alpha_to_coverage_NOT_desert
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"

	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_standard_alpha_to_coverage_NOT_desertShadow
{
	VertexShader = "GH_VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	
	RasterizerState = ShadowRasterizerState

	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_standard_alpha_to_coverage_NOT_desert_winter
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
	Defines = { "APPLY_WINTER" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_standard_alpha_to_coverage_NOT_desert_winterShadow
{
	VertexShader = "GH_VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"

	RasterizerState = ShadowRasterizerState

	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_snap_to_terrain_NOT_desert
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "APPLY_WINTER" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_snap_to_terrain_NOT_desertShadow
{
	VertexShader = "GH_VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
	RasterizerState = ShadowRasterizerState
}

Effect GH_snap_to_terrain_alpha_to_coverage_NOT_desert
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	
	BlendState = "alpha_to_coverage"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "APPLY_WINTER" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_snap_to_terrain_alpha_to_coverage_NOT_desertShadow
{
	VertexShader = "GH_VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshAlphaBlendShadow"
	
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_snap_to_terrain_atlas_NOT_desert
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ATLAS" "APPLY_WINTER" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_snap_to_terrain_atlas_NOT_desertShadow
{
	VertexShader = "GH_VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"		
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_snap_to_terrain_atlas_usercolor_NOT_desert
{
	VertexShader = "VS_standard"
	PixelShader = "PS_standard"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ATLAS" "USER_COLOR" "APPLY_WINTER" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_snap_to_terrain_atlas_usercolor_NOT_desertShadow
{
	VertexShader = "GH_VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"		
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_standard_NOT_desert_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_standard_NOT_desertShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_standard_alpha_to_coverage_NOT_desert_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	BlendState = "alpha_to_coverage"
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_standard_alpha_to_coverage_NOT_desertShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow_alphablend"
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
	
	RasterizerState = ShadowRasterizerState
}

Effect GH_standard_atlas_NOT_desert_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	#Defines = { "ATLAS" }
	Defines = { "ATLAS" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_standard_atlas_NOT_desertShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"
	RasterizerState = ShadowRasterizerState
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_snap_to_terrain_NOT_desert_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"

	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_snap_to_terrain_NOT_desertShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"

	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
	RasterizerState = ShadowRasterizerState
}

Effect GH_snap_to_terrain_alpha_to_coverage_NOT_desert_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	
	BlendState = "alpha_to_coverage"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_snap_to_terrain_alpha_to_coverage_NOT_desertShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow_alphablend"
	
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_snap_to_terrain_atlas_NOT_desert_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ATLAS" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_snap_to_terrain_atlas_NOT_desertShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"		
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_snap_to_terrain_atlas_usercolor_NOT_desert_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_standard"
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "ATLAS" "USER_COLOR" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}

Effect GH_snap_to_terrain_atlas_usercolor_NOT_desertShadow_mapobject
{
	VertexShader = "VS_jomini_mapobject_shadow"
	PixelShader = "PS_jomini_mapobject_shadow"		
	RasterizerState = ShadowRasterizerState
	Defines = { "PDX_MESH_SNAP_VERTICES_TO_TERRAIN" "GH_ENABLE_DYNAMIC_TERRAIN" "GH_USE_DYNAMIC_TERRAIN_FILTER" "GH_DYNAMIC_TERRAIN_FILTER_NOT_desert" }
}