Includes = {
	"cw/camera.fxh"
	# MOD(godherja)
	"gh_dynamic_terrain.fxh"
	# END MOD
}
ConstantBuffer( JominiRiver )
{
	float _TextureUvScale;
	float _FlowNormalUvScale;
	float _FlowNormalSpeed;
	float _RiverFoamFactor;
	float _NoiseScale;
	float _NoiseSpeed;
	float _FlattenMult;
	
	float _OceanFadeRate;
	float _BankAmount;
	float _BankFade;
	float _Depth;
	float _DepthWidthPower;
	float _DepthFakeFactor;
	int _ParallaxIterations;
}

VertexStruct VS_INPUT_RIVER
{
    float3  Position   		: POSITION;
	float	Transparency 	: TEXCOORD0;
	float2  UV				: TEXCOORD1;
	float3	Tangent 		: TEXCOORD2;
	float3	Normal			: TEXCOORD3;
	float	Width			: TEXCOORD4;
	float	DistanceToMain	: TEXCOORD5;
};

VertexStruct VS_OUTPUT_RIVER
{
    float4 Position	    	: PDX_POSITION;
	float2 UV			    : TEXCOORD0;
	float3 Tangent			: TEXCOORD1;
	float3 Normal			: TEXCOORD2;
	float3 WorldSpacePos	: TEXCOORD3;
	float  Transparency		: TEXCOORD4;
	float  Width			: TEXCOORD5;
	float  DistanceToMain	: TEXCOORD6;
	# MOD(godherja)
	int GH_TerrainVariantIndex : TEXCOORD7;
	# END MOD
};


VertexShader =
{
	MainCode VertexShader
	{
		Input = "VS_INPUT_RIVER"
		Output = "VS_OUTPUT_RIVER"
		Code
		[[
			#ifndef JOMINIRIVER_MapSize
			#define JOMINIRIVER_MapSize MapSize
			#endif
		
			PDX_MAIN
			{
				VS_OUTPUT_RIVER Out;
			
				Out.UV 				= Input.UV;
				Out.Tangent 		= Input.Tangent;
				Out.Normal			= Input.Normal;
				Out.WorldSpacePos 	= Input.Position;
				Out.Transparency 	= Input.Transparency;
				Out.Width 			= Input.Width * max( JOMINIRIVER_MapSize.x, JOMINIRIVER_MapSize.y );
				Out.DistanceToMain	= Input.DistanceToMain;
				
				Out.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( Input.Position, 1.0f ) );

				// MOD(godherja)
				Out.GH_TerrainVariantIndex = GH_GetTerrainVariantIndex(Out.WorldSpacePos.xz);
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
		float CalcDepth( float2 UV )
		{
			return _Depth * ( 1.0f - pow( cos( ( UV.y ) * 2.0f * PI ) * 0.5f + 0.5f, 2.0f ) );
		}

		float CalcDepth( float2 UV, PdxTextureSampler2D BottomNormal )
		{
			float ShoreAmount = 1.0f + _BankAmount;
			float CenterOffset = ( ShoreAmount - 1.0f ) / 2.0f;

			float Depth = _Depth * ( 1.0f - pow( cos( clamp( UV.y * ShoreAmount - CenterOffset, 0.0f, 1.0f ) * 2.0f * PI ) * 0.5f + 0.5f, _DepthWidthPower ) );

			float SampledDepth = 1.0f - PdxTex2D( BottomNormal, UV ).b;
			Depth *= SampledDepth;
			Depth = clamp( Depth, 0.001f, 10.0f );	// Some functions do not like 0 depth
			
			return Depth;
		}
	]]
}