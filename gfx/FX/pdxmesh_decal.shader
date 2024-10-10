Includes = {
	"cw/shadow.fxh"
	"cw/pdxterrain.fxh"
	"jomini/jomini_decals.fxh"
	# MOD(godherja)
	"jomini/jomini_lighting.fxh"
	#"gh_jomini_lighting.fxh"
	# END MOD
	# MOD(WC)
	#"jomini/jomini_fog.fxh"
	"wc_jomini_fog.fxh"
	# END MOD
	# MOD(godherja)
	"jomini/jomini_fog_of_war.fxh"
	#"gh_atmospheric.fxh"
	# END MOD
	"bordercolor.fxh"
	"dynamic_masks.fxh"
	"legend.fxh"
	"disease.fxh"
}

PixelShader =
{
	TextureSampler DiffuseTexture
	{
		Ref = PdxTexture0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler PropertiesTexture
	{
		Ref = PdxTexture1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler NormalTexture
	{
		Ref = PdxTexture2
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler EnvironmentMap
	{
		Ref = JominiEnvironmentMap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		Type = "Cube"
	}
	TextureSampler ShadowTexture
	{
		Ref = PdxShadowmap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		CompareFunction = less_equal
		SamplerType = "Compare"
	}
	TextureSampler FogOfWarAlpha
	{
		Ref = JominiFogOfWar
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
}

PixelShader =
{
	Code
	[[
		// MOD(godherja)
		//float3 CalcDecal( float2 UV, float3 Bitangent, float3 WorldSpacePos, float3 Diffuse )
		float3 CalcDecal( float2 UV, float3 Bitangent, float3 WorldSpacePos, float3 Diffuse, int TerrainVariantIndex )
		// END MOD
		{
			float4 Properties = PdxTex2D( PropertiesTexture, UV );
			float4 NormalPacked = PdxTex2D( NormalTexture, UV );
			float3 NormalSample = UnpackRRxGNormal( NormalPacked );
			
			float3 Normal = CalculateNormal( WorldSpacePos.xz );
			#ifdef TANGENT_SPACE_NORMALS
				float3 Tangent = cross( Bitangent, Normal );
				float3x3 TBN = Create3x3( normalize( Tangent ), normalize( Bitangent ), Normal );
				Normal = normalize( mul( NormalSample, TBN ) );
			#else
				Normal = ReorientNormal( Normal, NormalSample );
			#endif
			
			float2 ColorMapCoords = WorldSpacePos.xz * WorldSpaceToTerrain0To1;

			float SnowHighlight = 0.0f;
			Diffuse = ApplyDynamicMasksDiffuse( Diffuse, Normal, ColorMapCoords, SnowHighlight, TerrainVariantIndex);

			float3 ColorMap = PdxTex2D( ColorTexture, float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ) ).rgb;
			Diffuse = GetOverlay( Diffuse, ColorMap, 0.5 );
				
			ApplyHighlightColor( Diffuse, ColorMapCoords );
			CompensateWhiteHighlightColor( Diffuse, ColorMapCoords, SnowHighlight );
			
			SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse, Normal, Properties.a, Properties.g, Properties.b );
			SLightingProperties LightingProps = GetSunLightingProperties( WorldSpacePos, ShadowTexture );
			
			float3 Color = CalculateSunLighting( MaterialProps, LightingProps, EnvironmentMap );
			ApplyLegendDiffuse( Color, WorldSpacePos.xz * WorldSpaceToTerrain0To1 );
			ApplyDiseaseDiffuse( Color, WorldSpacePos.xz * WorldSpaceToTerrain0To1 );
			Color = ApplyFogOfWar( Color, WorldSpacePos, FogOfWarAlpha );
			Color = ApplyDistanceFog( Color, WorldSpacePos );
			
			DebugReturn( Color, MaterialProps, LightingProps, EnvironmentMap );
			return Color;
		}
	]]
	
	MainCode PS_world
	{
		TextureSampler DecalAlphaTexture
		{
			Ref = PdxTexture3
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
		}
		
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[
			static const float DECAL_TILING_SCALE = 0.15;

			PDX_MAIN
			{
				float Alpha = PdxTex2D( DecalAlphaTexture, Input.UV0 ).r;
				//return float4( vec3( 1 ), Alpha );
				
				Alpha = PdxMeshApplyOpacity( Alpha, Input.Position.xy, GetOpacity( Input.InstanceIndex ) );
				
				float2 DetailUV = Input.WorldSpacePos.xz * float2( DECAL_TILING_SCALE, -DECAL_TILING_SCALE );
				
				float4 Diffuse = PdxTex2D( DiffuseTexture, DetailUV );
				// MOD(godherja)
				//float3 Color = CalcDecal( DetailUV, Input.Bitangent, Input.WorldSpacePos, Diffuse.rgb );
				float3 Color = CalcDecal( DetailUV, Input.Bitangent, Input.WorldSpacePos, Diffuse.rgb, Input.GH_TerrainVariantIndex );
				// END MOD

				Alpha = CalcHeightBlendFactors( float4( Diffuse.a, 0.3, 0.0, 0.0 ), float4( Alpha, 1.0 - Alpha, 0.0, 0.0 ), 0.25 ).r;
				return float4( Color, Alpha );
			}
		]]
	}
	
	MainCode PS_local
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float4 Diffuse = PdxTex2D( DiffuseTexture, Input.UV0 );
				Diffuse.a = PdxMeshApplyOpacity( Diffuse.a, Input.Position.xy, GetOpacity( Input.InstanceIndex ) );
				
				float3 BorderColor;
				float BorderPreLightingBlend;
				float BorderPostLightingBlend;
				GetBorderColorAndBlendGame( Input.WorldSpacePos.xz, Diffuse.rgb, BorderColor, BorderPreLightingBlend, BorderPostLightingBlend );
				Diffuse.rgb = lerp( Diffuse.rgb, BorderColor, BorderPreLightingBlend );

				// MOD(godherja)
				//float3 Color = CalcDecal( Input.UV0, Input.Bitangent, Input.WorldSpacePos, Diffuse.rgb );
				float3 Color = CalcDecal( Input.UV0, Input.Bitangent, Input.WorldSpacePos, Diffuse.rgb, Input.GH_TerrainVariantIndex );
				// END MOD
			
				Color.rgb = lerp( Color.rgb, BorderColor, BorderPostLightingBlend );
				
				return float4( Color, Diffuse.a );
			}
		]]
	}
}


Effect decal_world
{
	VertexShader = "VS_standard"
	PixelShader = "PS_world"
	# MOD(godherja)
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" }
	# END MOD
}

Effect decal_world_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_world"
	# MOD(godherja)
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" }
	# END MOD
}

Effect decal_local
{
	VertexShader = "VS_standard"
	PixelShader = "PS_local"
	
	# MOD(godherja)
	#Defines = { "TANGENT_SPACE_NORMALS" }
	Defines = { "TANGENT_SPACE_NORMALS" "GH_ENABLE_DYNAMIC_TERRAIN" }
	# END MOD
}

Effect decal_local_mapobject
{
	VertexShader = "VS_mapobject"
	PixelShader = "PS_local"
	
	# MOD(godherja)
	#Defines = { "TANGENT_SPACE_NORMALS" }
	Defines = { "TANGENT_SPACE_NORMALS" "GH_ENABLE_DYNAMIC_TERRAIN" }
	# END MOD
}
