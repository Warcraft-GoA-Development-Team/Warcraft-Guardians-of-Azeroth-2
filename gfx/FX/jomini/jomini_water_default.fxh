Includes = {
	"cw/heightmap.fxh"
	"cw/utility.fxh"
	"cw/camera.fxh"
	# MOD(WC)
	#"jomini/jomini_fog.fxh"
	"wc_jomini_fog.fxh"
	# END MOD
	"jomini/jomini_lighting.fxh"
	"jomini/jomini_water.fxh"
}

Code
[[
	#ifndef JOMINIWATER_MapSize
		#define JOMINIWATER_MapSize MapSize
	#endif
	
	#ifndef JOMINIWATER_BorderLerpSize
		#define JOMINIWATER_BorderLerpSize 0.008
	#endif
]]

VertexShader =
{
	MainCode JominiWaterVertexShader
	{
		Input = "VS_INPUT_WATER"
		Output = "VS_OUTPUT_WATER"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT_WATER VertexOut;
				VertexOut.WorldSpacePos = float3( Input.Position.x, _WaterHeight, Input.Position.y );
				
				#ifdef JOMINIWATER_BORDER_LERP
					VertexOut.WorldSpacePos.x = JOMINIWATER_MapSize.x + Input.Position.x * JOMINIWATER_BorderLerpSize;
				#endif
				
				VertexOut.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( VertexOut.WorldSpacePos.xyz, 1.0 ) );
				
				VertexOut.UV01 = float2( VertexOut.WorldSpacePos.x / JOMINIWATER_MapSize.x, 1.0 - VertexOut.WorldSpacePos.z / JOMINIWATER_MapSize.y );
				
				return VertexOut;
			}
		]]
	}
}

PixelShader =
{	
	TextureSampler WaterColorTexture
	{
		Ref = JominiWaterTexture0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler AmbientNormalTexture
	{
		Ref = JominiWaterTexture1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler FlowMapTexture
	{
		Ref = JominiWaterTexture2
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler FlowNormalTexture
	{
		Ref = JominiWaterTexture3
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler ReflectionCubeMap
	{
		Ref = JominiWaterTexture4
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		Type = "Cube"
	}
	TextureSampler FoamTexture
	{
		Ref = JominiWaterTexture5
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler FoamRampTexture
	{
		Ref = JominiWaterTexture6
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	TextureSampler FoamMapTexture
	{
		Ref = JominiWaterTexture7
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler FoamNoiseTexture
	{
		Ref = JominiWaterTexture8
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	
	TextureSampler RefractionTexture
	{
		Ref = JominiRefraction
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}

	Code
	[[
		#ifndef JOMINIWATER_GlobalTime
			#define JOMINIWATER_GlobalTime GlobalTime
		#endif
		
		struct SWaterParameters
		{
			float4 _ScreenSpacePos;
			float3 _WorldSpacePos;
			float2 _WorldUV;
			float  _Depth;
			float3 _FlowNormal;
			float  _FlowFoamMask;
			float  _NoiseScale;
			float  _WaveSpeedScale;
			float  _WaveNoiseFlattenMult;
			#ifdef WATER_LOCAL_SPACE_NORMALS
			float3 _Tangent;
			float3 _Bitangent;
			float3 _Normal;
			#endif
		};
		
		struct SWaterOutput
		{
			float4  _Color;
			float	_Depth;
			float3	_Normal;
			float	_ReflectionAmount;
		};
		
		float CalcFoamFactor( float2 UV01, float2 WorldSpacePosXZ, float Depth, float FlowFoamMask, float3 FlowNormal )
		{
			float2 NoiseUV = WorldSpacePosXZ * _WaterFoamNoiseScale;
			float FoamNoise1 = PdxTex2DUpscaleNative( FoamNoiseTexture, NoiseUV + float2(1,1) * JOMINIWATER_GlobalTime * _WaterFoamNoiseSpeed ).r * 0.75;
			float FoamNoise2 = (PdxTex2DUpscaleNative( FoamNoiseTexture, NoiseUV * 3 + float2(1,-1) * JOMINIWATER_GlobalTime * _WaterFoamNoiseSpeed ).r - 0.5) * 0.5; // +/-0.25
			float FoamNoise3 = (PdxTex2DUpscaleNative( FoamNoiseTexture, NoiseUV * 5 + float2(-1,0) * JOMINIWATER_GlobalTime * _WaterFoamNoiseSpeed ).r - 0.5) * 0.25; // +/-0.125
			float FoamNoise = ( FoamNoise1 + FoamNoise2 + FoamNoise3 );

			float FoamMap = 1.0 - PdxTex2DUpscaleNative( FoamMapTexture, UV01 ).r;
			float FoamBase = pow( FoamMap, 2.0 ) * 2.375 - 1.0;
			
			float NoiseCeiling = 2.0;
			float FoamFactor = smoothstep( FoamBase, FoamBase + NoiseCeiling, 1.0 - FoamNoise );
			
			float FoamShoreMask = 1.0 - saturate( (_WaterFoamShoreMaskDepth - Depth) * _WaterFoamShoreMaskSharpness );
			
			FoamFactor *= _WaterFoamStrength * FoamShoreMask;
			
			float3 Foam = PdxTex2DUpscaleNative( FoamTexture, WorldSpacePosXZ * _WaterFoamScale + FlowNormal.xz * _WaterFoamDistortFactor ).rgb;
			float3 FoamRamp = PdxTex2DLod0( FoamRampTexture, float2( FoamFactor * FlowFoamMask, 0.5 ) ).rgb;
			
			FoamFactor = saturate( dot( Foam, FoamRamp ) );
			
			return FoamFactor;
		}
		
		float3 CalcTerrainUnderwaterSeeThrough( float Depth, float3 WorldSpacePos, float3 WaterColorMap, float3 Color )
		{
			float3 ToCameraDir = normalize( CameraPosition.xyz - WorldSpacePos );
			float WaterDistance = Depth / ToCameraDir.y;
			Color = lerp( WaterColorMap, Color, saturate( exp( -_WaterSeeThroughDensity * WaterDistance ) ) );
			
			float WaterSeeThroughShoreMask = 1.0 - saturate( ( _WaterSeeThroughShoreMaskDepth - Depth ) * _WaterSeeThroughShoreMaskSharpness );

			Color = lerp( Color, WaterColorMap, WaterSeeThroughShoreMask );
			
			return Color;
		}

		float3 CalcRefraction( float3 WorldSpacePos, float3 Normal, float2 ScreenPos, float3 WaterColor, float Depth )
		{
			float3 WaterColorMap = lerp( WaterColor, _WaterColorMapTint, _WaterColorMapTintFactor );
			
			#if defined( JOMINI_REFRACTION_ENABLED )
				float4 RefractionSample = PdxTex2DLod0( RefractionTexture, ScreenPos / _ScreenResolution );
				float3 RefractionWorldSpacePos = DecompressWorldSpace( WorldSpacePos, RefractionSample.a );
				float RefractionDepth = WorldSpacePos.y - RefractionWorldSpacePos.y;
				Depth = min( Depth, RefractionDepth );
				
				float RefractionShoreMask = 1.0 - saturate( ( _WaterRefractionShoreMaskDepth - Depth ) * _WaterRefractionShoreMaskSharpness );
				
				// Use 1080p as the normalizing factor for the refraction offset
				// Note, previous implementation had the refraction offset scaled by current resolution which made the effect stronger for lower resolutions and weaker for high resolutions, now the effect should stay consistent across resolutions
				float2 RefractionOffset = mul( ViewMatrix, float4( Normal.x, 0, Normal.z, 0 ) ).xy * float2( -1.0 / 1920.0, 1.0 / 1080.0 );
				RefractionOffset *= _WaterRefractionScale * RefractionShoreMask * _WaterRefractionFade;
			
				float4 OffsetRefractionSample = PdxTex2DLod0( RefractionTexture, ScreenPos / _ScreenResolution + RefractionOffset );
				float3 OffsetRefractionWorldSpacePos = DecompressWorldSpace( WorldSpacePos, OffsetRefractionSample.a );
				
				float OffsetStep = step( WorldSpacePos.y, OffsetRefractionWorldSpacePos.y );
				RefractionSample = lerp( OffsetRefractionSample, RefractionSample, OffsetStep );
				RefractionWorldSpacePos = lerp( OffsetRefractionWorldSpacePos, RefractionWorldSpacePos, OffsetStep );
				RefractionDepth = WorldSpacePos.y - RefractionWorldSpacePos.y;
				
				float2 RefractionWaterColorUV = float2( RefractionWorldSpacePos.x / JOMINIWATER_MapSize.x, 1.0 - RefractionWorldSpacePos.z / JOMINIWATER_MapSize.y );
				float3 RefractionWaterColorMap = PdxTex2D( WaterColorTexture, RefractionWaterColorUV ).rgb;
				RefractionWaterColorMap = lerp( RefractionWaterColorMap, _WaterColorMapTint, _WaterColorMapTintFactor );
			
				float3 Refraction = CalcTerrainUnderwaterSeeThrough( RefractionDepth, RefractionWorldSpacePos, RefractionWaterColorMap, RefractionSample.rgb );

				#if !defined( RIVER )
					Refraction = lerp( WaterColorMap, Refraction, pow( 1.0 - _WaterZoomedInZoomedOutFactor, 2.0 ) );
				#endif
			#else
				float3 Refraction = WaterColorMap;
			#endif
			
			return Refraction;
		}
		
		float3 CalcReflection( float3 Normal, float3 ToCameraDir )
		{
			float3 ReflectionNormal = Normal;
			ReflectionNormal.y += _WaterReflectionNormalFlatten; // TODO, decay with distance?
			ReflectionNormal = normalize( ReflectionNormal );
			float3 ReflectionVector = reflect( -ToCameraDir, ReflectionNormal );
			float3 Reflection = PdxTexCube( ReflectionCubeMap, ReflectionVector ).rgb * _WaterCubemapIntensity;
			
			return Reflection;
		}

		// This used to be the default lighting model, it has now been replaced
		// Moving it here because water is still using it and water shading is a bit special
		struct SWaterLightingProperties
		{
			float3 _WorldSpacePos;
			float3 _ToCameraDir;
			float3 _Normal;
			float3 _Diffuse;
		
			float3 _SpecularColor;
			float _Glossiness;
			float _NonLinearGlossiness;
		};
		
		#define PDX_GlossScale 11.0
		#define PDX_GlossBias 0.0
		#define PDX_MaxMipLevel 8.0
		float GetNonLinearGlossiness( float Glossiness )
		{
			return exp2( PDX_GlossScale * Glossiness + PDX_GlossBias );
		}
		
		float3 FresnelSchlick( float3 SpecularColor, float3 E, float3 H )
		{
			return SpecularColor + (vec3(1.0) - SpecularColor) * pow( 1.0 - saturate( dot(E, H) ), 5.0 );
		}
		
		SWaterLightingProperties GetLightingProperties( float3 WorldSpacePos, float3 Diffuse, float3 Normal, float4 Material )
		{
			float3 ToCameraDir = normalize( CameraPosition - WorldSpacePos );
			
			SWaterLightingProperties lightingProperties;
			lightingProperties._WorldSpacePos = WorldSpacePos;
			lightingProperties._ToCameraDir = ToCameraDir;
			lightingProperties._Normal = Normal;
			
			float SpecRemapped = Material.g * Material.g * 0.4;
			float Metalness = 1.0 - (1.0 - Material.b) * (1.0 - Material.b);
			float Glossiness = Material.a;
			lightingProperties._Diffuse = MetalnessToDiffuse( Metalness, Diffuse );
			lightingProperties._Glossiness = Glossiness;
			lightingProperties._SpecularColor = MetalnessToSpec( Metalness, Diffuse, SpecRemapped );
			lightingProperties._NonLinearGlossiness = GetNonLinearGlossiness( Glossiness );
			
			return lightingProperties;
		}
		
		float GetEnvmapMipLevel( float Glossiness )
		{
			return (1.0 - Glossiness) * (PDX_MaxMipLevel);
		}
		
		float3 FresnelGlossy( float3 SpecularColor, float3 E, float3 N, float Smoothness )
		{
			return SpecularColor + (max(vec3(Smoothness), SpecularColor) - SpecularColor) * pow(1.0 - saturate(dot(E, N)), 5.0);
		}
		
		float3 FresnelGlossy( SWaterLightingProperties Properties )
		{
			return FresnelGlossy( Properties._SpecularColor, Properties._ToCameraDir, Properties._Normal, Properties._Glossiness );
		}
		
		float3 GetReflectiveColor( SWaterLightingProperties Properties, PdxTextureSamplerCube EnvironmentMap, float EnvironmentMapIntensity, float4x4 EnvironmentMapRotation )
		{	
			float MipmapIndex = GetEnvmapMipLevel( Properties._Glossiness );
			float3 ReflectionVector = reflect( -Properties._ToCameraDir, Properties._Normal );
			float3 RotatedCubemapUV = mul( CastTo3x3( EnvironmentMapRotation ), ReflectionVector );
			float3 ReflectiveColor = PdxTexCubeLod( EnvironmentMap, RotatedCubemapUV, MipmapIndex ).rgb * EnvironmentMapIntensity;
			return ReflectiveColor * FresnelGlossy( Properties );
		}
		
		void ImprovedBlinnPhong( float3 LightColor, float3 ToLightDir, SWaterLightingProperties Properties, out float3 DiffuseLightOut, out float3 SpecularLightOut )
		{
			float3 H = normalize(Properties._ToCameraDir + ToLightDir);
			float NdotL = saturate(dot(Properties._Normal, ToLightDir));
			float NdotH = saturate(dot(Properties._Normal, H));
		
			float normalization = (Properties._NonLinearGlossiness + 2.0) / 8.0;
			float3 specColor = normalization * pow(NdotH, Properties._NonLinearGlossiness) * FresnelSchlick(Properties._SpecularColor, ToLightDir, H);
		
			DiffuseLightOut = LightColor * NdotL;
			SpecularLightOut = specColor * LightColor * NdotL;
		}
		
		void CalculateSunLight( SWaterLightingProperties Properties, float ShadowTerm, float3 ToSunDirection, out float3 DiffuseLightOut, out float3 SpecularLightOut )
		{
			float3 sunIntensity = SunDiffuse * SunIntensity * ShadowTerm;
			ImprovedBlinnPhong( sunIntensity, ToSunDirection, Properties, DiffuseLightOut, SpecularLightOut );
		}
		
		float3 AmbientLight( float3 WorldNormal, float3 AmbientColors[6] )
		{
			// add more of bottom ambient below objects
			WorldNormal = normalize(WorldNormal - smoothstep(-0.6, 0.5, dot(WorldNormal, float3(0, -1, 0))) * float3(0, 0.9, 0));
		
			float3 Squared = WorldNormal * WorldNormal;
			int3 isNegative = int3(lessThan(WorldNormal, vec3(0.0)));
			float3 Color = Squared.x * AmbientColors[isNegative.x] + Squared.y * AmbientColors[isNegative.y+2] + Squared.z * AmbientColors[isNegative.z+4];
		
			return Color;
		}
		
		float3 AmbientLight( float3 WorldNormal, float ShadowTerm ) 
		{	
			float3 AmbientColors[6];
			ShadowTerm = smoothstep( SHADOW_AMBIENT_MIN_FACTOR, SHADOW_AMBIENT_MAX_FACTOR, ShadowTerm );
			AmbientColors[0] = lerp( ShadowAmbientPosX, AmbientPosX, ShadowTerm );
			AmbientColors[1] = lerp( ShadowAmbientNegX, AmbientNegX, ShadowTerm );
			AmbientColors[2] = lerp( ShadowAmbientPosY, AmbientPosY, ShadowTerm );
			AmbientColors[3] = lerp( ShadowAmbientNegY, AmbientNegY, ShadowTerm );
			AmbientColors[4] = lerp( ShadowAmbientPosZ, AmbientPosZ, ShadowTerm );
			AmbientColors[5] = lerp( ShadowAmbientNegZ, AmbientNegZ, ShadowTerm );
		
			return AmbientLight( WorldNormal, AmbientColors );
		}
		
		float3 ComposeLight( SWaterLightingProperties Properties, float3 AmbientLight, float3 DiffuseLight, float3 SpecularLight )
		{
			float3 diffuse = ((AmbientLight + DiffuseLight) * Properties._Diffuse);
			float3 specular = SpecularLight;
			
			return diffuse + specular;
		}
		
		float3 ComposeLight( SWaterLightingProperties Properties, float ShadowTerm, float3 ToSunDirection, float3 DiffuseLight, float3 SpecularLight )
		{
			float NdotL = saturate( dot(Properties._Normal, ToSunDirection) );
			float3 AmbientColor = AmbientLight( Properties._Normal, NdotL * ShadowTerm );
			return ComposeLight( Properties, AmbientColor, DiffuseLight, SpecularLight );
		}
		
		
		SWaterOutput CalcWater( in SWaterParameters Input )
		{
			float4 WaterColorAndSpec = PdxTex2D( WaterColorTexture, Input._WorldUV );
			float GlossMap = WaterColorAndSpec.a;

			float3 ToCamera = CameraPosition.xyz - Input._WorldSpacePos;
			float3 ToCameraDir = normalize( ToCamera );

			// "Noise" normals
			float2 UVCoord = Input._WorldSpacePos.xz * float2( 1.0f , -1.0f ) * Input._NoiseScale;
			float3 NormalMap1 = SampleNormalMapTexture( AmbientNormalTexture, UVCoord, _WaterWave1Scale, _WaterWave1Rotation, JOMINIWATER_GlobalTime * _WaterWave1Speed * Input._WaveSpeedScale, _WaterWave1NormalFlatten * Input._WaveNoiseFlattenMult );
			float3 NormalMap2 = SampleNormalMapTexture( AmbientNormalTexture, UVCoord, _WaterWave2Scale, _WaterWave2Rotation, JOMINIWATER_GlobalTime * _WaterWave2Speed * Input._WaveSpeedScale, _WaterWave2NormalFlatten * Input._WaveNoiseFlattenMult );
			float3 NormalMap3 = SampleNormalMapTexture( AmbientNormalTexture, UVCoord, _WaterWave3Scale, _WaterWave3Rotation, JOMINIWATER_GlobalTime * _WaterWave3Speed * Input._WaveSpeedScale, _WaterWave3NormalFlatten * Input._WaveNoiseFlattenMult );
			
			float3 Normal = NormalMap1 + NormalMap2 + NormalMap3 + Input._FlowNormal;
			#ifdef WATER_LOCAL_SPACE_NORMALS
				float3x3 TBN = Create3x3( Input._Tangent, Input._Bitangent, Input._Normal );
				Normal = normalize( mul( Normal.xzy, TBN ) );
			#else
				Normal = normalize( Normal );
			#endif
			
			float FoamFactor = CalcFoamFactor( Input._WorldUV, Input._WorldSpacePos.xz, Input._Depth, Input._FlowFoamMask, Input._FlowNormal );
			
			float Facing = 1.0f - max( dot( Normal, ToCameraDir ), 0.0f );
			float3 WaterDiffuse = lerp( _WaterColorDeep, _WaterColorShallow, Facing );
			WaterDiffuse *= _WaterDiffuseMultiplier;
			
			SWaterLightingProperties lightingProperties;
			lightingProperties._WorldSpacePos = Input._WorldSpacePos;
			lightingProperties._ToCameraDir = ToCameraDir;
			lightingProperties._Normal = Normal;
			lightingProperties._Diffuse = WaterDiffuse + FoamFactor;
			lightingProperties._Glossiness = lerp( _WaterGlossBase, GlossMap, _WaterZoomedInZoomedOutFactor );
			lightingProperties._SpecularColor = vec3(_WaterSpecular);
			lightingProperties._NonLinearGlossiness = GetNonLinearGlossiness( lightingProperties._Glossiness ) * _WaterGlossScale;
			
			float3 DiffuseLight = vec3( 0.0f );
			float3 SpecularLight = vec3( 0.0f );
			CalculateSunLight( lightingProperties, 1.0f, _WaterToSunDir, DiffuseLight, SpecularLight );
			
			float3 FinalColor = ComposeLight( lightingProperties, 1.0f, _WaterToSunDir, DiffuseLight, SpecularLight * _WaterSpecularFactor );

			float3 Refraction = CalcRefraction( Input._WorldSpacePos, Normal, Input._ScreenSpacePos.xy, WaterColorAndSpec.rgb, Input._Depth );

			float Depth = Input._Depth;
			#if defined( RIVER ) && defined( JOMINI_REFRACTION_ENABLED ) 
				float4 RefractionSample = PdxTex2DLod0( RefractionTexture, Input._ScreenSpacePos.xy / _ScreenResolution );
				float3 RefractionWorldSpacePos = DecompressWorldSpace( Input._WorldSpacePos, RefractionSample.a );
				float RefractionDepth = Input._WorldSpacePos.y - RefractionWorldSpacePos.y;
				Depth = min( Depth, RefractionDepth );
			#endif

			float WaterFade = 1.0f - saturate( ( _WaterFadeShoreMaskDepth - Depth ) * _WaterFadeShoreMaskSharpness );
			FinalColor *= WaterFade;

			float3 Reflection = CalcReflection( Normal, ToCameraDir );
			
			float FresnelFactor = Fresnel( abs( dot( lightingProperties._ToCameraDir, Normal ) ), _WaterFresnelBias, _WaterFresnelPow ) * WaterFade;
			
			FinalColor += lerp( Refraction, Reflection, FresnelFactor );
			
			#ifdef JOMINIWATER_BORDER_LERP
				float ExtraFade = 1.0f - ( Input._WorldUV.x - 1.0f ) / JOMINIWATER_BorderLerpSize;
				WaterFade *= ExtraFade;
			#endif
			SWaterOutput Out;
			Out._Color = float4( FinalColor, WaterFade );
			Out._Depth = Input._Depth;
			Out._Normal = Normal;
			Out._ReflectionAmount = FresnelFactor;
			return Out;
		}
		
		SWaterOutput CalcWater( VS_OUTPUT_WATER Input )
		{
			float2 HeightmapCoordinate = Input.WorldSpacePos.xz;
			#ifdef JOMINIWATER_BORDER_LERP
				HeightmapCoordinate.x -= JOMINIWATER_MapSize.x;
			#endif
			float Height = GetHeightMultisample( HeightmapCoordinate, 0.65 );
			
			SWaterParameters Params;
			Params._ScreenSpacePos = Input.Position;
			Params._WorldSpacePos = Input.WorldSpacePos;
			Params._WorldUV = Input.UV01;
			Params._Depth = Input.WorldSpacePos.y - Height;
			Params._NoiseScale = 0.05f;
			Params._WaveSpeedScale = 1.0f;
			Params._WaveNoiseFlattenMult = 1.0f;
			Params._FlowNormal = CalcFlow( FlowMapTexture, FlowNormalTexture, Params._WorldUV, Params._WorldSpacePos.xz, Params._FlowFoamMask );
			
			return CalcWater( Params );
		}
	]]
	
	MainCode JominiWaterPixelShader
	{
		Input = "VS_OUTPUT_WATER"
		Output = "PDX_COLOR"
		Code
		[[			
			PDX_MAIN
			{
				float4 Water = CalcWater( Input )._Color; 
				Water.rgb = ApplyDistanceFog( Water.rgb, Input.WorldSpacePos );
				return Water;
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

RasterizerState RasterizerState
{
	DepthBias = -100
}
