Includes = {
	"cw/pdxmesh.fxh"
	"cw/camera.fxh"
	"cw/heightmap.fxh"
	"jomini/jomini_mapobject.fxh"
	# MOD(godherja)
	"gh_dynamic_terrain.fxh"
	# END MOD
}


VertexStruct VS_OUTPUT
{
    float4 Position			: PDX_POSITION;
	float2 UV0				: TEXCOORD0;
	float2 UV1				: TEXCOORD1;
	float3 WorldSpacePos	: TEXCOORD2;
	float3 Bitangent		: TEXCOORD3;
	uint InstanceIndex 		: TEXCOORD4;
	# MOD(godherja)
	int GH_TerrainVariantIndex : TEXCOORD5;
	# END MOD
};


VertexShader =
{
	Code
	[[
		VS_OUTPUT ConvertOutput( VS_OUTPUT_PDXMESH In )
		{
			VS_OUTPUT Out;
			
			Out.Position = In.Position;
			Out.UV0 = In.UV0;
			Out.UV1 = In.UV1;
			Out.WorldSpacePos = In.WorldSpacePos;
			Out.Bitangent = In.Bitangent;
			return Out;
		}
	]]
	
	MainCode VS_standard
	{
		Input = "VS_INPUT_PDXMESHSTANDARD"
		Output = "VS_OUTPUT"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT Out = ConvertOutput( PdxMeshVertexShaderStandard( Input ) );
				Out.InstanceIndex = Input.InstanceIndices.y;

			#ifdef PDX_TERRAIN_HEIGHT_MULTISAMPLE
				Out.WorldSpacePos.y = GetHeightMultisample( Out.WorldSpacePos.xz, 0.25 );
			#else
				Out.WorldSpacePos.y = GetHeight( Out.WorldSpacePos.xz );
			#endif
				Out.WorldSpacePos.y += 0.05;
				Out.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( Out.WorldSpacePos.xyz, 1.0 ) );

				// MOD(godherja)
				GH_RETRIEVE_AND_FILTER_TERRAIN_VARIANT_STANDARD;
				// END MOD

				return Out;
			}
		]]
	}
	
	MainCode VS_mapobject
	{
		Input = "VS_INPUT_PDXMESH_MAPOBJECT"
		Output = "VS_OUTPUT"
		Code
		[[
			PDX_MAIN
			{
				float4x4 WorldMatrix = UnpackAndGetMapObjectWorldMatrix( Input.InstanceIndex24_Opacity8 );
				VS_OUTPUT Out = ConvertOutput( PdxMeshVertexShader( PdxMeshConvertInput( Input ), 0/*bone offset not supported*/, WorldMatrix ) );
				Out.InstanceIndex = Input.InstanceIndex24_Opacity8;
				
			#ifdef PDX_TERRAIN_HEIGHT_MULTISAMPLE
				Out.WorldSpacePos.y = GetHeightMultisample( Out.WorldSpacePos.xz, 0.25 );
			#else
				Out.WorldSpacePos.y = GetHeight( Out.WorldSpacePos.xz );
			#endif
				Out.WorldSpacePos.y += 0.05;
				Out.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( Out.WorldSpacePos.xyz, 1.0 ) );

				// MOD(godherja)
				GH_RETRIEVE_AND_FILTER_TERRAIN_VARIANT(WorldMatrix);
				// END MOD

				return Out;
			}
		]]
	}
}


PixelShader =
{	
	Code
	[[		
		float GetOpacity( uint InstanceIndex )
		{
			#ifdef JOMINI_MAP_OBJECT
				return UnpackAndGetMapObjectOpacity( InstanceIndex );
			#else
				return PdxMeshGetOpacity( InstanceIndex );
			#endif
		}
	]]
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
}


RasterizerState RasterizerState
{
	#fillmode = wireframe
	DepthBias = -10000
	SlopeScaleDepthBias = -2
}


DepthStencilState DepthStencilState
{
	#DepthEnable = no
	DepthWriteEnable = no
}
