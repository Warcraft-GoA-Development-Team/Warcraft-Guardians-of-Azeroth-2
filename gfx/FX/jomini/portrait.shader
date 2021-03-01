Includes = {
	"cw/pdxmesh.fxh"
	"cw/pdxmesh_blendshapes.fxh"
	"cw/utility.fxh"
	"cw/shadow.fxh"
	"cw/camera.fxh"
	"jomini/jomini_lighting.fxh"
	"jomini/jomini_fog.fxh"
	"constants.fxh"
	"standardfuncsgfx.fxh"
}

PixelShader =
{
	TextureSampler DiffuseMap
	{
		Index = 0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler SpecularMap
	{
		Index = 1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler NormalMap
	{
		Index = 2
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
	TextureSampler DecalDiffuseArray
	{
		Ref = JominiPortraitDecalDiffuseArray
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		type = "2darray"
	}
	TextureSampler DecalNormalArray
	{
		Ref = JominiPortraitDecalNormalArray
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		type = "2darray"
	}
	TextureSampler DecalPropertiesArray
	{
		Ref = JominiPortraitDecalPropertiesArray
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		type = "2darray"
	}
	TextureSampler DecalData
	{
		Index = 9
		MagFilter = "point"
		MinFilter = "point"
		MipFilter = "point"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	TextureSampler DiffuseMapOverride
	{
		Index = 10
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler NormalMapOverride
	{
		Index = 11
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler SpecularMapOverride
	{
		Index = 12
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
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
}

VertexShader = {
	TextureSampler BlendShapeTexture
	{
		Index = 15
		MagFilter = "Point"
		MinFilter = "Point"
		MipFilter = "Point"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
}

VertexStruct VS_OUTPUT_PDXMESHPORTRAIT
{
    float4 	Position		: PDX_POSITION;
	float3 	Normal			: TEXCOORD0;
	float3 	Tangent			: TEXCOORD1;
	float3 	Bitangent		: TEXCOORD2;
	float2 	UV0				: TEXCOORD3;
	float2 	UV1				: TEXCOORD4;
	float3 	WorldSpacePos	: TEXCOORD5;
	float4 	ShadowProj		: TEXCOORD6;
	uint 	InstanceIndex	: TEXCOORD7;
};

VertexStruct VS_INPUT_PDXMESHSTANDARD_ID
{
    float3 Position			: POSITION;
	float3 Normal      		: TEXCOORD0;
	float4 Tangent			: TEXCOORD1;
	float2 UV0				: TEXCOORD2;
@ifdef PDX_MESH_UV1     	
	float2 UV1				: TEXCOORD3;
@endif

	uint2 InstanceIndices 	: TEXCOORD4;
	
@ifdef PDX_MESH_SKINNED
	uint4 BoneIndex 		: TEXCOORD5;
	float3 BoneWeight		: TEXCOORD6;
@endif

	uint VertexID			: PDX_VertexID;
};

# Portrait constants
ConstantBuffer( 5 )
{
	float4 		vPaletteColorSkin;
	float4 		vPaletteColorEyes;
	float4 		vPaletteColorHair;
	float4		vSkinPropertyMult;
	float4		vEyesPropertyMult;
	float4		vHairPropertyMult;
	
	float4 		Light_Color_Falloff[3];
	float4 		Light_Position_Radius[3]
	float4 		Light_Direction_Type[3];
	float4 		Light_InnerCone_OuterCone_AffectedByShadows[3];
	
	int			DecalCount;
	int         PreSkinColorDecalCount
	int			TotalDecalCount;
	float		TextureOverride;
};
Code
[[
	#define LIGHT_COUNT 3
	#define LIGHT_TYPE_NONE 0
	#define LIGHT_TYPE_DIRECTIONAL 1
	#define LIGHT_TYPE_SPOTLIGHT 2
	#define LIGHT_TYPE_POINTLIGHT 3
]]

VertexShader = {

	Code
	[[
		VS_OUTPUT_PDXMESHPORTRAIT ConvertOutput( VS_OUTPUT_PDXMESH In )
		{
			VS_OUTPUT_PDXMESHPORTRAIT Out;
			
			Out.Position = In.Position;
			Out.Normal = In.Normal;
			Out.Tangent = In.Tangent;
			Out.Bitangent = In.Bitangent;
			Out.UV0 = In.UV0;
			Out.UV1 = In.UV1;
			Out.WorldSpacePos = In.WorldSpacePos;
			Out.ShadowProj = mul( ShadowMapTextureMatrix, float4( Out.WorldSpacePos, 1.0 ) );
			return Out;
		}
		
		void ProcessBlendShapes( out float3 PosDiff, out float3 NormalDiff, out float4 TangentDiff, in int nVertIndex )
		{
			PosDiff = float3(0.0, 0.0, 0.0);
			NormalDiff = float3(0.0, 0.0, 0.0);
			TangentDiff = float4(0.0, 0.0, 0.0, 0.0);
			int nVector = 0, nElement = 0;
			for ( int i = 0; i < int( nActiveBlendShapes ); ++i )
			{
				int nRow = int( blendShapeIndices[nVector][nElement] ) * 3;
				float vWeight = blendShapeWeights[nVector][nElement];
				PosDiff += PdxTex2DLoad0( BlendShapeTexture, int2(nVertIndex, nRow) ).xyz * vWeight;
				++nRow;
				NormalDiff += PdxTex2DLoad0( BlendShapeTexture, int2(nVertIndex, nRow) ).xyz * vWeight;
				++nRow;
				TangentDiff += PdxTex2DLoad0( BlendShapeTexture, int2(nVertIndex, nRow) ).xyzw * vWeight;
				++nRow;
				++nElement;
				if (nElement == 4)
				{
					nElement = 0;
					++nVector;
				}
			}
		}
		
		void ProcessBlendShapesPositionOnly( out float3 PosDiff, in int nVertIndex )
		{
			PosDiff = float3(0.0, 0.0, 0.0);
			int nVector = 0, nElement = 0;
			for ( int i = 0; i < int( nActiveBlendShapes ); ++i )
			{
				int nRow = int( blendShapeIndices[nVector][nElement] ) * 3;
				float vWeight = blendShapeWeights[nVector][nElement];
				PosDiff += PdxTex2DLoad0( BlendShapeTexture, int2(nVertIndex, nRow) ).xyz * vWeight;
				++nElement;
				if (nElement == 4)
				{
					nElement = 0;
					++nVector;
				}
			}
		}
	]]
	
	MainCode VS_portrait_blend_shapes
	{
		Input = "VS_INPUT_PDXMESHSTANDARD_ID"
		Output = "VS_OUTPUT_PDXMESHPORTRAIT"
		Code
		[[
			PDX_MAIN
			{
			  	VS_OUTPUT_PDXMESHPORTRAIT Out;
				
				float4 vPosition = float4( Input.Position.xyz, 1.0f );
				float3 vBlendPositionDiff, vBlendNormalDiff;
				float4 vBlendTangentDiff;
				int nVertIndex = int( nBlendShapesVertexOffset ) + int( Input.VertexID );
				ProcessBlendShapes( vBlendPositionDiff, vBlendNormalDiff, vBlendTangentDiff, nVertIndex );
				vPosition.xyz += vBlendPositionDiff;
				
				float4x4 WorldMatrix = PdxMeshGetWorldMatrix( Input.InstanceIndices.y );
			#ifdef PDX_MESH_SKINNED
				float4 vSkinnedPosition = float4( 0, 0, 0, 0 );
				float3 vSkinnedNormal = float3( 0, 0, 0 );
				float3 vSkinnedTangent = float3( 0, 0, 0 );
				float3 vSkinnedBitangent = float3( 0, 0, 0 );
			
				float4 vWeight = float4( Input.BoneWeight.xyz, 1.0f - Input.BoneWeight.x - Input.BoneWeight.y - Input.BoneWeight.z );
			
				for( int i = 0; i < PDXMESH_MAX_INFLUENCE; ++i )
			    {
					int nIndex = int( Input.BoneIndex[i] );
					float4x4 mat = BoneMatrices[nIndex + Input.InstanceIndices.x];
					vSkinnedPosition += mul( mat, vPosition ) * vWeight[i];
			
					float3 vNormal = mul( CastTo3x3(mat), Input.Normal + vBlendNormalDiff );
					float3 vTangent = mul( CastTo3x3(mat), Input.Tangent.xyz + vBlendTangentDiff.xyz );
					float3 vBitangent = cross( vNormal, vTangent ) * (Input.Tangent.w + vBlendTangentDiff.w);
			
					vSkinnedNormal += vNormal * vWeight[i];
					vSkinnedTangent += vTangent * vWeight[i];
					vSkinnedBitangent += vBitangent * vWeight[i];
				}
			
				Out.Position = mul( WorldMatrix, vSkinnedPosition );
				
				Out.Normal = normalize( mul( CastTo3x3(WorldMatrix), normalize( vSkinnedNormal ) ) );
				Out.Tangent = normalize( mul( CastTo3x3(WorldMatrix), normalize( vSkinnedTangent ) ) );
				Out.Bitangent = normalize( mul( CastTo3x3(WorldMatrix), normalize( vSkinnedBitangent ) ) );
			#else
				Out.Position = mul( WorldMatrix, vPosition );
				
				Out.Normal = normalize( mul( CastTo3x3( WorldMatrix ), Input.Normal + vBlendNormalDiff ) );
				Out.Tangent = normalize( mul( CastTo3x3( WorldMatrix ), Input.Tangent.xyz + vBlendTangentDiff.xyz ) );
				Out.Bitangent = normalize( cross( Out.Normal, Out.Tangent ) * (Input.Tangent.w + vBlendTangentDiff.w) );
			#endif
			
				Out.WorldSpacePos.xyz = Out.Position.xyz;
				Out.WorldSpacePos /= WorldMatrix[3][3];
				Out.Position = FixProjectionAndMul( ViewProjectionMatrix, Out.Position );
				
				Out.ShadowProj = mul( ShadowMapTextureMatrix, float4( Out.WorldSpacePos, 1.0 ) );
				
				Out.UV0 = Input.UV0;
			#ifdef PDX_MESH_UV1
				Out.UV1 = Input.UV1;
			#else
				Out.UV1 = vec2( 0.0 );
			#endif
				Out.InstanceIndex = Input.InstanceIndices.y;
				return Out;
			}
		]]
	}

	MainCode VS_portrait_blend_shapes_shadow
	{
		Input = "VS_INPUT_PDXMESHSTANDARD_ID"
		Output = "VS_OUTPUT_PDXMESHSHADOWSTANDARD"
		Code
		[[
			PDX_MAIN
			{
			  	VS_OUTPUT_PDXMESHSHADOWSTANDARD Out;
				
				float4 vPosition = float4( Input.Position.xyz, 1.0 );
				float3 vBlendPositionDiff;
				int nVertIndex = int( nBlendShapesVertexOffset ) + int( Input.VertexID );
				ProcessBlendShapesPositionOnly( vBlendPositionDiff, nVertIndex );
				vPosition.xyz += vBlendPositionDiff;
				
				float4x4 WorldMatrix = PdxMeshGetWorldMatrix( Input.InstanceIndices.y );
			#ifdef PDX_MESH_SKINNED
				float4 vSkinnedPosition = float4( 0, 0, 0, 0 );
			
				float4 vWeight = float4( Input.BoneWeight.xyz, 1.0f - Input.BoneWeight.x - Input.BoneWeight.y - Input.BoneWeight.z );
				for( int i = 0; i < PDXMESH_MAX_INFLUENCE; ++i )
			    {
					int nIndex = int( Input.BoneIndex[i] );
					float4x4 mat = BoneMatrices[nIndex + Input.InstanceIndices.x];
					vSkinnedPosition += mul( mat, vPosition ) * vWeight[i];
				}
				Out.Position = mul( WorldMatrix, vSkinnedPosition );
			#else
				Out.Position = mul( WorldMatrix, vPosition );
			#endif
			
				Out.Position = FixProjectionAndMul( ViewProjectionMatrix, Out.Position );
				Out.UV_InstanceIndex = float3( Input.UV0, Input.InstanceIndices.y );
				return Out;
			}
		]]
	}
	
	MainCode VS_standard
	{
		Input = "VS_INPUT_PDXMESHSTANDARD"
		Output = "VS_OUTPUT_PDXMESHPORTRAIT"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT_PDXMESHPORTRAIT Out = ConvertOutput( PdxMeshVertexShaderStandard( Input ) );
				Out.InstanceIndex = Input.InstanceIndices.y;
				return Out;
			}
		]]
	}
}

PixelShader =
{
	Code
	[[		
		void CalculatePortraitLights( float3 WorldSpacePos, float ShadowTerm, SMaterialProperties MaterialProps, inout float3 DiffuseLightOut, inout float3 SpecularLightOut )
		{
			for( int i = 0; i < LIGHT_COUNT; ++i )
			{
				float3 DiffuseLight = vec3(0);
				float3 SpecularLight = vec3(0);
				
				//Scale color by ShadowTerm
				float4 Color_Fallof = Light_Color_Falloff[i];
				float LightShadowTerm = Light_InnerCone_OuterCone_AffectedByShadows[i].z > 0.5 ? ShadowTerm : 1.0;
				
				if( Light_Direction_Type[i].w == LIGHT_TYPE_SPOTLIGHT )
				{
					float InnerAngle = Light_InnerCone_OuterCone_AffectedByShadows[i].x;
					float OuterAngle = Light_InnerCone_OuterCone_AffectedByShadows[i].y;
					SpotLight Spot = GetSpotLight( Light_Position_Radius[i], Color_Fallof, Light_Direction_Type[i].xyz, InnerAngle, OuterAngle );
					GGXSpotLight( Spot, WorldSpacePos, LightShadowTerm, MaterialProps, DiffuseLight, SpecularLight );
				}
				else if( Light_Direction_Type[i].w == LIGHT_TYPE_POINTLIGHT )
				{
					PointLight Light = GetPointLight( Light_Position_Radius[i], Color_Fallof );
					GGXPointLight( Light, WorldSpacePos, LightShadowTerm, MaterialProps, DiffuseLight, SpecularLight );
				}
				else if( Light_Direction_Type[i].w == LIGHT_TYPE_DIRECTIONAL )
				{
					SLightingProperties LightingProps;
					LightingProps._ToCameraDir = normalize( CameraPosition - WorldSpacePos );
					LightingProps._ToLightDir = -Light_Direction_Type[i].xyz;
					LightingProps._LightIntensity = Color_Fallof.rgb;
					LightingProps._ShadowTerm = LightShadowTerm;
					LightingProps._CubemapIntensity = 0.0;
					CalculateLightingFromLight( MaterialProps, LightingProps, DiffuseLight, SpecularLight );
				}
				
				DiffuseLightOut += DiffuseLight;
				SpecularLightOut += SpecularLight;
			}
		}

		void DebugReturn( inout float3 Out, SMaterialProperties MaterialProps, SLightingProperties LightingProps, PdxTextureSamplerCube EnvironmentMap, float3 SssColor, float SssMask )
		{
			#if defined(PDX_DEBUG_PORTRAIT_SSS_MASK)
			Out = SssMask;
			#elif defined(PDX_DEBUG_PORTRAIT_SSS_COLOR)
			Out = SssColor;
			#else
			DebugReturn( Out, MaterialProps, LightingProps, EnvironmentMap );
			#endif
		}

		float3 CommonPixelShader( float4 Diffuse, float4 Properties, float3 NormalSample, in VS_OUTPUT_PDXMESHPORTRAIT Input )
		{
			float3x3 TBN = Create3x3( normalize( Input.Tangent ), normalize( Input.Bitangent ), normalize( Input.Normal ) );
			float3 Normal = normalize( mul( NormalSample, TBN ) );
			
			SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse.rgb, Normal, saturate( Properties.a ), Properties.g, Properties.b );
			SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, ShadowTexture );
			
			float3 DiffuseIBL;
			float3 SpecularIBL;
			CalculateLightingFromIBL( MaterialProps, LightingProps, EnvironmentMap, DiffuseIBL, SpecularIBL );
			
			float3 DiffuseLight = vec3(0.0);
			float3 SpecularLight = vec3(0.0);
			CalculatePortraitLights( Input.WorldSpacePos, LightingProps._ShadowTerm, MaterialProps, DiffuseLight, SpecularLight );
			
			float3 Color = DiffuseIBL + SpecularIBL + DiffuseLight + SpecularLight;
			
			float3 SssColor = vec3(0.0f);
			float SssMask = Properties.r;
			#ifdef FAKE_SSS_EMISSIVE
				float3 SkinColor = RGBtoHSV( Diffuse.rgb );
				SkinColor.z = 1.0f;
				SssColor = HSVtoRGB(SkinColor) * SssMask * 0.5f * MaterialProps._DiffuseColor;
				Color += SssColor;
			#endif
			
			Color = ApplyDistanceFog( Color, Input.WorldSpacePos );
			
			DebugReturn( Color, MaterialProps, LightingProps, EnvironmentMap, SssColor, SssMask );			
			return Color;
		}
		float3 UnpackDecalNormal( float4 NormalSample, float DecalStrength )
		{
			float3 Normal;
			//Sample format is RRxG
			Normal.xy = NormalSample.ga * 2.0 - vec2(1.0);
			Normal.y = -Normal.y;
			
			//Filter out "weak" normals. Compression/precision errors will scale with the number of decals used, so try to remove errors where artists intended the normals to be neutral
			float NormalXYSquared = dot( Normal.xy, Normal.xy );
			const float FilterMin = 0.0004f;
			const float FilterWidth = 0.05f;
			float Filter = smoothstep( FilterMin, FilterMin+FilterWidth*FilterWidth, NormalXYSquared );
			
			Normal.xy *= DecalStrength * Filter;
			Normal.z = sqrt( saturate( 1.0 - dot(Normal.xy,Normal.xy) ) );
			return Normal;
		}
		float3 OverlayNormal( in float3 Base, in float3 Overlay )
		{
			float3 Normal = Base;
			Normal.xy += Overlay.xy;
			Normal.z *= Overlay.z;
			return Normal;
		}
	]]

	MainCode PS_skin
	{
		Input = "VS_OUTPUT_PDXMESHPORTRAIT"
		Output = "PDX_COLOR"
		Code
		[[
			// Should match SPortraitDecalTextureSet::BlendMode
			#define BLEND_MODE_OVERLAY 0
			#define BLEND_MODE_REPLACE 1
			#define BLEND_MODE_HARD_LIGHT 2
			#define BLEND_MODE_MULTIPLY 3
			// Special handling of normal Overlay blend mode (in shader only)
			#define BLEND_MODE_OVERLAY_NORMAL 4

			uint GetBodyPartIndex( uint InstanceIndex )
			{
				uint Offset = InstanceIndex + PDXMESH_USER_DATA_OFFSET;
				return uint( Data[Offset].x );
			}

			float OverlayDecal( float Target, float Blend )
			{
				return float( Target > 0.5f ) * ( 1.0f - ( 2.0f * ( 1.0f - Target ) * ( 1.0f - Blend ) ) ) +
					   float( Target <= 0.5f ) * ( 2.0f * Target * Blend );
			}

			float HardLightDecal( float Target, float Blend )
			{
				return float( Blend > 0.5f ) * ( 1.0f - ( 2.0f * ( 1.0f - Target ) * ( 1.0f - Blend ) ) ) +
					   float( Blend <= 0.5f ) * ( 2.0f * Target * Blend );
			}

			float4 BlendDecal( uint BlendMode, float4 Target, float4 Blend, float Weight )
			{
				float4 Result = vec4( 0.0f );

				if ( BlendMode == BLEND_MODE_OVERLAY )
				{
					// If Red channel is white, and blue and green are black, then colour the decal to the Hair Colour palette. Else, apply overlay blending as usual.
					if(all(Blend.rgb == float3(1.0f, 0.0f, 0.0f)))
					{
  					Result = float4( 
						OverlayDecal( Target.r, vPaletteColorHair.r ),
						OverlayDecal( Target.g, vPaletteColorHair.g ),
						OverlayDecal( Target.b, vPaletteColorHair.b ),
						OverlayDecal( Target.a, Blend.a ) 
						);
					}
					else
					{
  					Result = float4( 
						OverlayDecal( Target.r, Blend.r ),
						OverlayDecal( Target.g, Blend.g ),
						OverlayDecal( Target.b, Blend.b ),
						OverlayDecal( Target.a, Blend.a ) 
						);
					}
				}
				else if ( BlendMode == BLEND_MODE_REPLACE )
				{
					// If Red channel is white, and blue and green are black, then colour the decal to the Hair Colour palette. Else, apply replace blending as usual.
					if(all(Blend.rgb == float3(1.0f, 0.0f, 0.0f)))
					{
  					Result = float4( vPaletteColorHair.rgb, Target.a );
					}
					else
					{
 					Result = Blend;
					}
				}

				else if ( BlendMode == BLEND_MODE_HARD_LIGHT )
				{
					// If Red channel is white, and blue and green are black, then colour the decal to the Hair Colour palette. Else, apply hard light blending as usual.
					if(all(Blend.rgb == float3(1.0f, 0.0f, 0.0f)))
					{
 					Result = float4(
 				   		HardLightDecal( Target.r, vPaletteColorHair.r ),
  						HardLightDecal( Target.g, vPaletteColorHair.g ),
   						HardLightDecal( Target.b, vPaletteColorHair.b ),
   						HardLightDecal( Target.a, Blend.a )
  						);
					}
					else
					{
 					 Result = float4(
 				   		HardLightDecal( Target.r, Blend.r ),
  						HardLightDecal( Target.g, Blend.g ),
   						HardLightDecal( Target.b, Blend.b ),
   						HardLightDecal( Target.a, Blend.a )
  						);
					}
				}


				else if ( BlendMode == BLEND_MODE_MULTIPLY )
				{
					// If Red channel is white, and blue and green are black, then colour the decal to the Hair Colour palette. Else, apply multiply blending as usual.
					if(all(Blend.rgb == float3(1.0f, 0.0f, 0.0f)))
					{
 					Result = float4(( Target.r * vPaletteColorHair.r ),( Target.g * vPaletteColorHair.g ),( Target.b * vPaletteColorHair.b ),( Target.a * Blend.a ));
					}
					else
					{
 					Result = Target * Blend;
					}
				}
				else if ( BlendMode == BLEND_MODE_OVERLAY_NORMAL )
				{
					Result = float4( OverlayNormal( Target.xyz, Blend.xyz ), Target.a );
				}

				return lerp( Target, Result, Weight );
			}

			void AddDecals( inout float3 Diffuse, inout float3 Normals, inout float4 Properties, float2 UV, uint InstanceIndex, uint From, uint To )
			{
				// Body part index is scripted on the mesh asset and should match ECharacterPortraitPart
				uint BodyPartIndex = GetBodyPartIndex( InstanceIndex );

				// Data for each decal is stored in two texels
				uint DataTexelCountPerDecal = 2;
				float DecalDivisor = TotalDecalCount * DataTexelCountPerDecal;
				float Offset = 1.0f / ( DecalDivisor * DataTexelCountPerDecal );
				uint FromDataTexel = From * DataTexelCountPerDecal;
				uint ToDataTexel = To * DataTexelCountPerDecal;

				// Sorted after priority
				for ( uint i = FromDataTexel; i <= ToDataTexel; i += DataTexelCountPerDecal )
				{
					// Texel n is { diffuse_index, normal_index, properties_index, body_part_index }
					// Index 255 => unused
					float4 IndexData = PdxTex2DLod0( DecalData, float2( ( i / DecalDivisor ) + Offset, 0.0f ) );
					uint Index = uint( IndexData.a * 255.0f );

					if ( Index == BodyPartIndex )
					{
						// Texel n + 1 is { diffuse_blend_mode, normal_blend_mode, properties_blend_mode, weight }
						float4 BlendData = PdxTex2DLod0( DecalData, float2( ( ( i + 1 ) / DecalDivisor ) + Offset, 0.0f ) );
						float Weight = BlendData.a;

						float DiffuseIndex = IndexData.x * 255.0f;
						float NormalIndex = IndexData.y * 255.0f;
						float PropertiesIndex = IndexData.z * 255.0f;

						if ( DiffuseIndex < 255.0f )
						{
							uint DiffuseBlendMode = uint( BlendData.x * 255.0f );
							float4 DiffuseSample = PdxTex2D( DecalDiffuseArray, float3( UV, DiffuseIndex ) );
							Weight = DiffuseSample.a * Weight;
							Diffuse = BlendDecal( DiffuseBlendMode, float4( Diffuse, 0.0f ), DiffuseSample, Weight ).rgb;
						}

						if ( NormalIndex < 255.0f )
						{
							uint NormalBlendMode = uint( BlendData.y * 255.0f );
							if ( NormalBlendMode == BLEND_MODE_OVERLAY )
							{
								NormalBlendMode = BLEND_MODE_OVERLAY_NORMAL;
							}
							float3 NormalSample = UnpackDecalNormal( PdxTex2D( DecalNormalArray, float3( UV, NormalIndex ) ), Weight );
							Normals = BlendDecal( NormalBlendMode, float4( Normals, 0.0f ), float4( NormalSample, 0.0f ), Weight ).xyz;
						}

						if ( PropertiesIndex < 255.0f )
						{
							uint PropertiesBlendMode = uint( BlendData.z * 255.0f );
							float4 PropertiesSample = PdxTex2D( DecalPropertiesArray, float3( UV, PropertiesIndex ) );
							Properties = BlendDecal( PropertiesBlendMode, Properties, PropertiesSample, Weight );
						}
					}
				}

				Normals = normalize( Normals );
			}

			PDX_MAIN
			{			
				float2 UV0 = Input.UV0;
				float4 Diffuse;
				float4 Properties;
				float3 NormalSample;

				#ifdef ENABLE_TEXTURE_OVERRIDE
				if( TextureOverride > 0.5f )
				{
					Diffuse = PdxTex2D( DiffuseMapOverride, UV0 );						
					Properties = PdxTex2D( SpecularMapOverride, UV0 );
					NormalSample = UnpackRRxGNormal( PdxTex2D( NormalMapOverride, UV0 ) );
				}
				else
				#endif
				{
					Diffuse = PdxTex2D( DiffuseMap, UV0 );						
					Properties = PdxTex2D( SpecularMap, UV0 );
					NormalSample = UnpackRRxGNormal( PdxTex2D( NormalMap, UV0 ) );
				}
				
				AddDecals( Diffuse.rgb, NormalSample, Properties, UV0, Input.InstanceIndex, 0, PreSkinColorDecalCount );
				
				Diffuse.rgb = lerp( Diffuse.rgb, Diffuse.rgb * vPaletteColorSkin.rgb, Diffuse.a );

				AddDecals( Diffuse.rgb, NormalSample, Properties, UV0, Input.InstanceIndex, PreSkinColorDecalCount, DecalCount );
				
				float3 Color = CommonPixelShader( Diffuse, Properties, NormalSample, Input );
				
				return float4( Color, 1.0f );
			}
			
		]]
	}
	
	MainCode PS_eye
	{
		Input = "VS_OUTPUT_PDXMESHPORTRAIT"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float2 UV0 = Input.UV0;
				float4 Diffuse = PdxTex2D( DiffuseMap, UV0 );								
				float4 Properties = PdxTex2D( SpecularMap, UV0 );
				float3 NormalSample = UnpackRRxGNormal( PdxTex2D( NormalMap, UV0 ) );
				
				Diffuse.rgb = lerp( Diffuse.rgb, Diffuse.rgb * vPaletteColorEyes.rgb, Diffuse.a );
				
				float3 Color = CommonPixelShader( Diffuse, Properties, NormalSample, Input );
				
				return float4( Color, 1.0f );
			}
		]]
	}

	MainCode PS_attachment
	{		
		TextureSampler PatternMask
		{
			Ref = PdxMeshCustomTexture0
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Clamp"
			SampleModeV = "Clamp"
		}
		TextureSampler PatternColorPalette
		{
			Ref = PdxMeshCustomTexture1
			MagFilter = "Point"
			MinFilter = "Point"
			MipFilter = "Point"
			SampleModeU = "Wrap"
			SampleModeV = "Wrap"
		}
		TextureSampler PatternColorMasks
		{
			Ref = PdxMeshCustomTexture2
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Wrap"
			SampleModeV = "Wrap"
			type = "2darray"
		}
		TextureSampler PatternNormalMaps
		{
			Ref = PdxMeshCustomTexture3
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Wrap"
			SampleModeV = "Wrap"
			type = "2darray"
		}
		TextureSampler PatternPropertyMaps
		{
			Ref = PdxMeshCustomTexture4
			MagFilter = "Linear"
			MinFilter = "Linear"
			MipFilter = "Linear"
			SampleModeU = "Wrap"
			SampleModeV = "Wrap"
			type = "2darray"
		}
		
		Input = "VS_OUTPUT_PDXMESHPORTRAIT"
		Output = "PDX_COLOR"
		Code
		[[
			#ifdef VARIATIONS_ENABLED
			// C++ layout
			//	struct SVariationRenderConstants
			//	{
			//		struct STransform
			//		{
			//			float		_Scale = 1.0f;
			//			float		_Rotation = 0.0f;
			//			CVector2f	_Offset = CVector2f::Zero();
			//		};
			//		STransform	_Transforms[4];
			//		CVector4f	_ColorMaskIndices;
			//		CVector4f	_NormalMapIndices;
			//		CVector4f	_PropertyIndices;
			//		float		_RandomNumber;
			//	};
			struct SPatternDesc
			{
				float 	_Scale;
				float	_Rotation;
				float2	_Offset;
				float	_ColorMaskIndex;
				float	_NormalMapIndex;
				float	_PropertyMapIndex;
			};
			
			struct SPatternOutput
			{
				float4	_Diffuse;
				float4	_Properties;
				float3	_Normal;
			};
			
			SPatternDesc GetPatternDesc( uint InstanceIndex, uint PatternIndex )
			{
				SPatternDesc Desc;
				uint Offset = InstanceIndex + PDXMESH_USER_DATA_OFFSET;
				Desc._Scale 	= Data[Offset+PatternIndex].r;
				Desc._Rotation 	= Data[Offset+PatternIndex].g;
				Desc._Offset 	= Data[Offset+PatternIndex].ba;
				Desc._ColorMaskIndex = Data[Offset+4][PatternIndex];
				Desc._NormalMapIndex = Data[Offset+5][PatternIndex];
				Desc._PropertyMapIndex = Data[Offset+6][PatternIndex];
				return Desc;
			}
			
			float GetRandomNumber( uint InstanceIndex )
			{
				uint Offset = InstanceIndex + PDXMESH_USER_DATA_OFFSET + 7;
				return Data[Offset].r;
			}

			SPatternOutput ApplyPattern( float2 UV, float Mask, SPatternDesc Desc, float RandomNumber, float4 Diffuse, float4 Properties, float3 Normal, int MaskIndex )
			{
				// Rotate and scale around (0.5,0.5)
				float2 Rotate = float2( cos( Desc._Rotation ), sin( Desc._Rotation ) );
				UV -= vec2(0.5f);
				UV = float2( UV.x * Rotate.x - UV.y * Rotate.y, UV.x * Rotate.y + UV.y * Rotate.x );
				UV /= Desc._Scale;
				UV += vec2(0.5f);
				UV += Desc._Offset;
				
				float4 ColorMask = PdxTex2D( PatternColorMasks, float3( UV, Desc._ColorMaskIndex ) );
				
				
				float4 PatternColor = float4( 1, 1, 1, 0 );
				float4 PatternProperties = PdxTex2D( PatternPropertyMaps, float3( UV, Desc._PropertyMapIndex ) );
				float4 PatternNormalSample = PdxTex2D( PatternNormalMaps, float3( UV, Desc._NormalMapIndex ) );
				
				//Sample the color palette once for each channel in the mask
				for( int i = 0; i < 4; ++i )
				{
					if( ColorMask[i] > 0.0f )
					{
						// Select from 16-width color palette
						float HorizontalSample = ( MaskIndex * 4.0f ) + i;
						HorizontalSample = ( HorizontalSample + 0.5f ) / 16.0f;
						
						float3 Sample = PdxTex2D( PatternColorPalette, float2( HorizontalSample, RandomNumber ) ).rgb;
						PatternColor.rgb = lerp( PatternColor.rgb, Sample, ColorMask[i] );
						PatternColor.a = max( PatternColor.a, ColorMask[i] );
					}
				}
				
				SPatternOutput PatternOutput;
				PatternOutput._Diffuse 		= PatternColor;
				PatternOutput._Normal 		= UnpackDecalNormal( PatternNormalSample, PatternColor.a );
				PatternOutput._Properties 	= PatternProperties;
				
				return PatternOutput;
			}
			
			void ApplyVariationPatterns( in VS_OUTPUT_PDXMESHPORTRAIT Input, inout float4 Diffuse, inout float4 Properties, inout float3 NormalSample )
			{
				float4 Mask = PdxTex2D( PatternMask, Input.UV0 );
				float4 PatternDiffuse = float4( 1, 1, 1, 1 );
				float3 PatternNormal = float3( 0.5, 0.5, 1 );
				float4 PatternProperties = Properties;
				
				float RandomNumber = GetRandomNumber( Input.InstanceIndex );
				for( int i = 0; i < 4; ++i )
				{
					if( Mask[i] > 0.0f )
					{
						SPatternOutput PatternOutput = ApplyPattern( Input.UV1, Mask[i], GetPatternDesc( Input.InstanceIndex, i ), RandomNumber, Diffuse, Properties, NormalSample, i );
						
						PatternDiffuse.rgb	= lerp( PatternDiffuse.rgb, PatternOutput._Diffuse.rgb, Mask[i] );
						PatternNormal	 	= lerp( PatternNormal, PatternOutput._Normal.rgb, Mask[i] );
						PatternProperties	= lerp( PatternProperties, PatternOutput._Properties, Mask[i] );
					}
				}
				
				Diffuse.rgb *= PatternDiffuse.rgb;
				Diffuse.rgb *= PatternProperties.rrr; // pattern AO
				
				NormalSample = OverlayNormal( NormalSample, PatternNormal );
				Properties = PatternProperties;
			}
			#endif
			
			PDX_MAIN
			{
				float2 UV0 = Input.UV0;
				float4 Diffuse = PdxTex2D( DiffuseMap, UV0 );								
				float4 Properties = PdxTex2D( SpecularMap, UV0 );
				float3 NormalSample = UnpackRRxGNormal( PdxTex2D( NormalMap, UV0 ) );		
				Properties.r = 1.0; // wipe this clean now, ready to be modified later
				
				#ifdef VARIATIONS_ENABLED
				ApplyVariationPatterns( Input, Diffuse, Properties, NormalSample );
				#endif
				
				float3 Color = CommonPixelShader( Diffuse, Properties, NormalSample, Input );
				return float4( Color, Diffuse.a );
			}
		]]
	}
	MainCode PS_portrait_hair_backface
	{
		Input = "VS_OUTPUT_PDXMESHPORTRAIT"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{			
				return float4( vec3( 0.0f ), 1.0f );
			}
		]]
	}
	MainCode PS_hair
	{
		Input = "VS_OUTPUT_PDXMESHPORTRAIT"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{			
				float2 UV0 = Input.UV0;
				float4 Diffuse = PdxTex2D( DiffuseMap, UV0 );								
				float4 Properties = PdxTex2D( SpecularMap, UV0 );
				float4 NormalSampleRaw = PdxTex2D( NormalMap, UV0 );
				float3 NormalSample = UnpackRRxGNormal( NormalSampleRaw );
				
				Properties *= vHairPropertyMult;
				Diffuse.rgb = lerp( Diffuse.rgb, Diffuse.rgb * vPaletteColorHair.rgb, NormalSampleRaw.b );
				
				float3 Color = CommonPixelShader( Diffuse, Properties, NormalSample, Input );
				
				#ifdef WRITE_ALPHA_ONE
					return float4( Color, 1.0f );
				#else
					#ifdef HAIR_TRANSPARENCY_HACK
						// TODO [HL]: Hack to stop clothing fragments from being discarded by transparent hair,
						// proper fix is to ensure that hair is drawn after clothes
						// https://beta.paradoxplaza.com/browse/PSGE-3103
						clip( Diffuse.a - 0.5f );
					#endif
					return float4( Color, Diffuse.a );
				#endif
			}
		]]
	}
	MainCode PS_hair_double_sided
	{
		Input = "VS_OUTPUT_PDXMESHPORTRAIT"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float2 UV0 = Input.UV0;
				float4 Diffuse = PdxTex2D( DiffuseMap, UV0 );
				#ifdef ALPHA_TEST
				clip( Diffuse.a - 0.5f );
				Diffuse.a = 1.0f;
				#endif
				float4 Properties = PdxTex2D( SpecularMap, UV0 );
				float3 NormalSample = UnpackRRxGNormal( PdxTex2D( NormalMap, UV0 ) );

				Properties *= vHairPropertyMult;
				Diffuse.rgb *= vPaletteColorHair.rgb;

				float3 Color = CommonPixelShader( Diffuse, Properties, NormalSample, Input );
				return float4( Color, Diffuse.a );
			}
		]]
	}
}


BlendState BlendState
{
	BlendEnable = no
}

BlendState hair_alpha_blend
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
	SourceAlpha = "ONE"
	DestAlpha = "INV_SRC_ALPHA"
	WriteMask = "RED|GREEN|BLUE|ALPHA"
}

DepthStencilState hair_alpha_blend
{
	DepthWriteEnable = no
}

BlendState alpha_to_coverage
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
	WriteMask = "RED|GREEN|BLUE|ALPHA"
	SourceAlpha = "ONE"
	DestAlpha = "INV_SRC_ALPHA"
	AlphaToCoverage = yes
}

RasterizerState rasterizer_no_culling
{
	CullMode = "none"
}

RasterizerState rasterizer_backfaces
{
	FrontCCW = yes
}
RasterizerState ShadowRasterizerState
{
	#Don't go higher than 10000 as it will make the shadows fall through the mesh
	DepthBias = 500
	SlopeScaleDepthBias = 2
}
RasterizerState ShadowRasterizerStateBackfaces
{
	DepthBias = 1000
	SlopeScaleDepthBias = 2
	FrontCCW = yes
}

Effect portrait_skin
{
	VertexShader = "VS_portrait_blend_shapes"
	PixelShader = "PS_skin"
	Defines = { "FAKE_SSS_EMISSIVE" }
}
Effect portrait_skinShadow
{
	VertexShader = "VS_portrait_blend_shapes_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = "ShadowRasterizerState"
}

Effect portrait_skin_face
{
	VertexShader = "VS_portrait_blend_shapes"
	PixelShader = "PS_skin"
	Defines = { "FAKE_SSS_EMISSIVE" "ENABLE_TEXTURE_OVERRIDE" }
}
Effect portrait_skin_faceShadow
{
	VertexShader = "VS_portrait_blend_shapes_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = "ShadowRasterizerState"
	Defines = { "PDXMESH_DISABLE_DITHERED_OPACITY" }
}

Effect portrait_eye
{
	VertexShader = "VS_standard"
	PixelShader = "PS_eye"
}

Effect portrait_eyeShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = "ShadowRasterizerState"
}

Effect portrait_attachment
{
	VertexShader = "VS_portrait_blend_shapes"
	PixelShader = "PS_attachment"
}

Effect portrait_attachmentShadow
{
	VertexShader = "VS_portrait_blend_shapes_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = "ShadowRasterizerState"
	Defines = { "PDXMESH_DISABLE_DITHERED_OPACITY" }
}

Effect portrait_attachment_pattern
{
	VertexShader = "VS_portrait_blend_shapes"
	PixelShader = "PS_attachment"
	Defines = { "VARIATIONS_ENABLED" }
}

Effect portrait_attachment_patternShadow
{
	VertexShader = "VS_portrait_blend_shapes_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = "ShadowRasterizerState"
	Defines = { "PDXMESH_DISABLE_DITHERED_OPACITY" }
}

Effect portrait_attachment_pattern_alpha_to_coverage
{
	VertexShader = "VS_portrait_blend_shapes"
	PixelShader = "PS_attachment"
	BlendState = "alpha_to_coverage"
	Defines = { "VARIATIONS_ENABLED" }
}

Effect portrait_attachment_pattern_alpha_to_coverageShadow
{
	VertexShader = "VS_portrait_blend_shapes_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = "ShadowRasterizerState"
	Defines = { "PDXMESH_DISABLE_DITHERED_OPACITY" }
}

Effect portrait_attachment_variedShadow
{
	VertexShader = "VS_portrait_blend_shapes_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = "ShadowRasterizerState"
}

Effect portrait_attachment_alpha_to_coverage
{
	VertexShader = "VS_portrait_blend_shapes"
	PixelShader = "PS_attachment"
	BlendState = "alpha_to_coverage"
}

Effect portrait_attachment_alpha_to_coverageShadow
{
	VertexShader = "VS_portrait_blend_shapes_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = "ShadowRasterizerState"
}

Effect portrait_hair
{
	VertexShader = "VS_portrait_blend_shapes"
	PixelShader = "PS_hair"
	BlendState = "alpha_to_coverage"
	RasterizerState = "rasterizer_no_culling"
}

Effect portrait_hair_transparency_hack
{
	VertexShader = "VS_portrait_blend_shapes"
	PixelShader = "PS_hair"
	BlendState = "alpha_to_coverage"
	RasterizerState = "rasterizer_no_culling"
	Defines = { "HAIR_TRANSPARENCY_HACK" }
}

Effect portrait_hairShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = "ShadowRasterizerState"
	Defines = { "PDXMESH_DISABLE_DITHERED_OPACITY" }
}

Effect portrait_hair_double_sided
{
	VertexShader = "VS_portrait_blend_shapes"
	PixelShader = "PS_hair_double_sided"
	BlendState = "alpha_to_coverage"
	#DepthStencilState = "test_and_write"
	RasterizerState = "rasterizer_no_culling"
}

Effect portrait_hair_alpha
{
	VertexShader = "VS_standard"
	PixelShader = "PS_hair"
	BlendState = "hair_alpha_blend"
	DepthStencilState = "hair_alpha_blend"
}

Effect portrait_hair_opaque
{
	VertexShader = "VS_standard"
	PixelShader = "PS_hair"
	
	Defines = { "WRITE_ALPHA_ONE" }
}

Effect portrait_hair_opaqueShadow
{
	VertexShader = "VertexPdxMeshStandardShadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = "ShadowRasterizerState"
	Defines = { "PDXMESH_DISABLE_DITHERED_OPACITY" }
}

Effect portrait_attachment_alpha
{
	VertexShader = "VS_standard"
	PixelShader = "PS_attachment"
	BlendState = "hair_alpha_blend"
	DepthStencilState = "hair_alpha_blend"
}

Effect portrait_attachment_alphaShadow
{
	VertexShader = "VS_portrait_blend_shapes_shadow"
	PixelShader = "PixelPdxMeshStandardShadow"
	RasterizerState = "ShadowRasterizerState"
}

Effect portrait_hair_backside
{
	VertexShader = "VS_standard"
	PixelShader = "PS_portrait_hair_backface"
	RasterizerState = "rasterizer_backfaces"
}
