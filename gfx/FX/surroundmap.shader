Includes = {
	"cw/camera.fxh"
	"cw/utility.fxh"
	"standardfuncsgfx.fxh"
	# MOD(WC)
	"wc_map.fxh"
	#"jomini/jomini_fog.fxh"
	"wc_jomini_fog.fxh"
	# END MOD
	"jomini/jomini_lighting.fxh"
	"lowspec.fxh"
}


ConstantBuffer( PdxConstantBuffer0 )
{	
	float2	BaseCloudTileFactor;
	float2	BaseCloudScrolling;
	float2	Cloud1TileFactor; 
	float2	Cloud1Scrolling;
	float2	Cloud2TileFactor;
	float2	Cloud2Scrolling;
	float	BaseCloudStrength;
	float	Cloud1Strength;
	float	Cloud2Strength;
	float	CloudHeight;

	float3	LowCloudColor;
	float	PixelSize;
	float3	HighCloudColor;
	float	MinCloudAlpha;
	float3	ShadowColor;
	float	MaxCloudAlpha;
	
	float2	TileFactor;
	float	ParallaxStrength;
	float	ParallaxFadeFactor;
}

VertexStruct VS_OUTPUT
{
    float4 position			: PDX_POSITION;
	float2 uv				: TEXCOORD0;
	float3 WorldSpacePos	: TEXCOORD1;
};


VertexShader = {

	VertexStruct VS_INPUT
	{
		float2 position	: POSITION;
	};
	
	MainCode VS_surroundmap
	{
		Input = "VS_INPUT"
		Output = "VS_OUTPUT"
		Code
		[[
			PDX_MAIN
			{			
				VS_OUTPUT VertexOut;
				
				float3 WorldSpacePos = float3( Input.position.x, FlatMapHeight, Input.position.y );
				#ifndef SURROUND_SHADOW
					WorldSpacePos.y += CloudHeight * ( 1.0 - FlatMapLerp );
				#endif
				VertexOut.position = FixProjectionAndMul( ViewProjectionMatrix, float4( WorldSpacePos, 1.0 ) );
				VertexOut.uv = Input.position / MapSize;
				VertexOut.uv.y = 1.0 - VertexOut.uv.y;
				
				VertexOut.WorldSpacePos = WorldSpacePos;

				return VertexOut;
			}
		]]
	}
}


PixelShader =
{
	TextureSampler SurroundMask
	{
		Ref = PdxTexture0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Border"
		SampleModeV = "Border"
		Border_Color = { 1 1 1 1 }
		File = "gfx/map/surround_map/surround_mask.dds"
	}
	TextureSampler SurroundTile
	{
		Ref = PdxTexture1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "gfx/map/surround_map/surround_tile.dds"
		srgb = yes
	}
	TextureSampler CloudTexture
	{
		Ref = PdxTexture2
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		#File = "gfx/map/surround_map/test2.dds"
	}
	TextureSampler BlackMask
	{
		Ref = PdxTexture3
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		File = "gfx/map/surround_map/surround_fade.dds"
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
	
	Code
	[[
		float4 GetFlatMapSurround( float2 UV )
		{				
			float Mask = PdxTex2D( SurroundMask, UV ).b;

			// We no longer use the surround 'woodgrain' tiling (keeping this here for some mods backward compat hint)
			// float3 Tile = PdxTex2D( SurroundTile, UV * TileFactor ).rgb;
			float3 Tile = float3(0, 0, 0);
			
			return float4( Tile, Mask );
		}
		
		float3 CalculateNormal( PdxTextureSampler2D Texture, float2 UV, float Scale )
		{
			float3 n;
			
			//float4 h;
			//h[0] = PdxTex2DLod0( Texture, UV + float2(-PixelSize, 0) ).r;
			//h[1] = PdxTex2DLod0( Texture, UV + float2(PixelSize, 0) ).r;
			//h[2] = PdxTex2DLod0( Texture, UV + float2(0, -PixelSize) ).r;
			//h[3] = PdxTex2DLod0( Texture, UV + float2(0, PixelSize) ).r;
			//
			//n.z = h[3] - h[2];
			//n.x = h[0] - h[1];
			//n.y = Scale;
			
			
			float h00 = PdxTex2DLod0( Texture, UV + float2(-PixelSize, -PixelSize) ).r;
			float h10 = PdxTex2DLod0( Texture, UV + float2(PixelSize, -PixelSize) ).r;
			float h01 = PdxTex2DLod0( Texture, UV + float2(-PixelSize, PixelSize) ).r;
			
			n.z = h01 - h00;
			n.x = h00 - h10;
			n.y = Scale;
			
			return normalize(n);
		}
		
		float2 CalculateParallaxOffset( float3 TangentSpaceCameraDir, float2 UV, float ParallaxScale )
		{
			float Height = 1.0 - PdxTex2DLod0( CloudTexture, UV ).r;
			
			float Scale = Height / TangentSpaceCameraDir.y;
			Scale = Height;
			
			float2 Offset = -TangentSpaceCameraDir.xz * Scale * ParallaxStrength;
			return Offset * ParallaxScale;
		}
		
		float2 CalculateParallaxOffsetSteep( float3 TangentSpaceCameraDir, float2 UV, float ParallaxScale )
		{
			static const float MinNumLayers = 2;
			static const float MaxNumLayers = 10;
			
			float NumLayers = lerp( MaxNumLayers, MinNumLayers, TangentSpaceCameraDir.y );
			float LayerHeight = 1.0 / NumLayers;
			float CurrentHeight = 0.0;
			
			float2 Offset = vec2(0.0);
			float2 DV = -TangentSpaceCameraDir.xz * ParallaxStrength / TangentSpaceCameraDir.y / NumLayers;
			//float2 DV = -TangentSpaceCameraDir.xz * ParallaxStrength / NumLayers;
			
			float Height = 1.0 - PdxTex2DLod0( CloudTexture, UV ).r;
			
			while( Height > CurrentHeight )
			{
				CurrentHeight += LayerHeight;
				Offset += DV;
				
				Height = 1.0 - PdxTex2DLod0( CloudTexture, UV + Offset ).r;
			}
			
			float2 PrevOffset = Offset - DV;
			float PrevHeight = 1.0 - PdxTex2DLod0( CloudTexture, UV + PrevOffset ).r - CurrentHeight + LayerHeight;
			
			float NextHeight = Height - CurrentHeight;
			
			float Weight = NextHeight / (NextHeight - PrevHeight);
			Offset = lerp( Offset, PrevOffset, Weight );
			
			return Offset * ParallaxScale;
		}
	]]

	MainCode PS_surroundmap
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float2 UV = Input.uv;

				float3 SurroundMaskChannels = PdxTex2D( SurroundMask, UV ).rgb;
				float FlatMapMask = 1 - SurroundMaskChannels.b; // to remove some artifacts when blending with the water shader
				float CloudMask = SurroundMaskChannels.g; // don't draw clouds over map
				float Mask = ( 1 - ( FlatMapMask * FlatMapLerp ) ) * CloudMask;

				float2 BaseCloudUV = UV * BaseCloudTileFactor;
				float2 BaseCloudOffset = GlobalTime * BaseCloudScrolling;
				float2 AnimatedBaseCloudUV = BaseCloudUV + BaseCloudOffset;

				float3 ToCamera = CameraPosition - Input.WorldSpacePos;
				float3 ToCameraDir = normalize( ToCamera );
				float3 TangentSpaceCameraDir = ToCameraDir;
				TangentSpaceCameraDir.xz /= MapSize;
				TangentSpaceCameraDir.xz *= TileFactor;
				TangentSpaceCameraDir.z = -TangentSpaceCameraDir.z;
				
				float ParallaxScale = saturate( length(ToCamera) / ParallaxFadeFactor + 0.35 );
				//float2 ParallaxOffset = CalculateParallaxOffset( TangentSpaceCameraDir, AnimatedBaseCloudUV, ParallaxScale );
				float2 ParallaxOffset = CalculateParallaxOffsetSteep( TangentSpaceCameraDir, AnimatedBaseCloudUV, ParallaxScale );
				AnimatedBaseCloudUV += ParallaxOffset;
				
				float3 Normal1 = CalculateNormal( CloudTexture, AnimatedBaseCloudUV, BaseCloudStrength );
				float3 Normal2 = CalculateNormal( CloudTexture, (AnimatedBaseCloudUV + GlobalTime * Cloud1Scrolling) * Cloud1TileFactor, Cloud1Strength );
				float3 Normal3 = CalculateNormal( CloudTexture, (AnimatedBaseCloudUV + GlobalTime * Cloud2Scrolling) * Cloud2TileFactor, Cloud2Strength );
				float3 Normal = normalize( Normal1 + Normal2 + Normal3 );
				
				float Alpha = PdxTex2D( CloudTexture, AnimatedBaseCloudUV ).r;				
				float3 CloudColor = lerp( LowCloudColor, HighCloudColor, Alpha );
				
				SMaterialProperties MaterialProps = GetMaterialProperties( CloudColor, Normal, 0.9, 0.5, 0.0 );
				SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, 1.0 );
				
				float3 Color = CalculateSunLighting( MaterialProps, LightingProps, EnvironmentMap );
				
				Color = ApplyDistanceFog( Color, Input.WorldSpacePos );
				
				DebugReturn( Color, MaterialProps, LightingProps, EnvironmentMap );
				
				Color *= 0.25;
				
				float FinalAlpha = smoothstep( MinCloudAlpha, MaxCloudAlpha, Alpha ) * Mask;

				float2 BlackUV = Input.uv * 0.75;
				BlackUV += float2( 0.125, 0.125);
				float3 Black = PdxTex2D( BlackMask, BlackUV ).rgb;
				Color *= vec3( Black.g * ( 1 - FlatMapLerp ) );
				
				return float4( Color, saturate( FinalAlpha ) );
			}
		]]
	}
	
	MainCode PS_surroundmapLowSpec
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float2 UV = Input.uv;
				
				float3 SurroundMaskChannels = PdxTex2D( SurroundMask, UV ).rgb;
				float FlatMapMask = 1 - SurroundMaskChannels.b; // to remove some artifacts when blending with the water shader
				float CloudMask = SurroundMaskChannels.g; // don't draw clouds over map
				float Mask = ( 1 - ( FlatMapMask * FlatMapLerp ) ) * CloudMask;
				if ( Mask <= 0.0 )
				{
					discard;
				}

				float2 BaseCloudUV = UV * BaseCloudTileFactor;
				float2 BaseCloudOffset = GlobalTime * BaseCloudScrolling;
				float2 AnimatedBaseCloudUV = BaseCloudUV + BaseCloudOffset;

				float3 ToCamera = CameraPosition - Input.WorldSpacePos;
				float3 ToCameraDir = normalize( ToCamera );
				float3 TangentSpaceCameraDir = ToCameraDir;
				TangentSpaceCameraDir.xz /= MapSize;
				TangentSpaceCameraDir.xz *= TileFactor;
				TangentSpaceCameraDir.z = -TangentSpaceCameraDir.z;
				
				float ParallaxScale = saturate( length(ToCamera) / ParallaxFadeFactor + 0.35 );
				//float2 ParallaxOffset = CalculateParallaxOffset( TangentSpaceCameraDir, AnimatedBaseCloudUV, ParallaxScale );
				float2 ParallaxOffset = CalculateParallaxOffsetSteep( TangentSpaceCameraDir, AnimatedBaseCloudUV, ParallaxScale );
				AnimatedBaseCloudUV += ParallaxOffset;
				
				float3 Normal = CalculateNormal( CloudTexture, AnimatedBaseCloudUV, BaseCloudStrength );
				
				float Alpha = PdxTex2D( CloudTexture, AnimatedBaseCloudUV ).r;				
				float3 CloudColor = lerp( LowCloudColor, HighCloudColor, Alpha );
				
				SMaterialProperties MaterialProps = GetMaterialProperties( CloudColor, Normal, 0.9, 0.5, 0.0 );
				SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, 1.0 );
				
				float3 Color = CalculateSunLightingLowSpec( MaterialProps, LightingProps );
				
				Color = ApplyDistanceFog( Color, Input.WorldSpacePos );
				
				DebugReturn( Color, MaterialProps, LightingProps, EnvironmentMap );
				
				Color *= 0.25;
				
				float FinalAlpha = smoothstep( MinCloudAlpha, MaxCloudAlpha, Alpha ) * Mask;
				
				float2 BlackUV = Input.uv * 0.75;
				BlackUV += float2( 0.125, 0.125);
				float3 Black = PdxTex2D( BlackMask, BlackUV ).rgb;
				Color *= vec3( Black.g * ( 1 - FlatMapLerp ) );
				
				return float4( Color, saturate( FinalAlpha ) );
			}
		]]
	}
	
	MainCode PS_surroundmap_shadow
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[			
			PDX_MAIN
			{
				float2 UV = Input.uv;
				float Mask = PdxTex2D( SurroundMask, UV ).r;
			
				return float4( ShadowColor, Mask * ( 1.0 - FlatMapLerp ) );
			}
		]]
	}
	
	MainCode PS_surroundmap_flat
	{
		Input = "VS_OUTPUT"
		Output = "PDX_COLOR"
		Code
		[[			
			PDX_MAIN
			{
				float4 Ret = GetFlatMapSurround( Input.uv );
				Ret.a *= FlatMapLerp;

				float2 BlackUV = Input.uv * 0.75;
				BlackUV += float2( 0.125, 0.125);
				float Black = PdxTex2D( BlackMask, BlackUV ).r;
				Ret.rgb *= vec3( Black );
				
				return Ret;
			}
		]]
	}
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "src_alpha"
	DestBlend = "inv_src_alpha"
	WriteMask = "RED|GREEN|BLUE"
}

DepthStencilState DepthStencilState
{
	DepthEnable = no
	DepthWriteEnable = no
}

RasterizerState RasterizerState
{
	frontccw = yes
}


Effect surroundmap
{
	VertexShader = VS_surroundmap
	PixelShader = PS_surroundmap
}

Effect surroundmapLowSpec
{
	VertexShader = VS_surroundmap
	PixelShader = PS_surroundmapLowSpec
}

Effect surroundmap_shadow
{
	VertexShader = VS_surroundmap
	PixelShader = PS_surroundmap_shadow
	
	Defines = { "SURROUND_SHADOW" }
}

Effect surroundmap_flat
{
	VertexShader = VS_surroundmap
	PixelShader = PS_surroundmap_flat
}