# Originally a part of the portrait decals shader code. This provides some shared functions between the old portrait decal shader and the
# texture decal code.

Code
[[		
	float3 UnpackDecalNormal( float4 NormalSample, float DecalStrength )
	{
		float3 Normal;
		//Sample format is RRxG
		Normal.xy = NormalSample.ga * 2.0 - vec2( 1.0 );
		Normal.y = -Normal.y;

		//Filter out "weak" normals. Compression/precision errors will scale with the number of decals used, so try to remove errors where artists intended the normals to be neutral
		float NormalXYSquared = dot( Normal.xy, Normal.xy );
		const float FilterMin = 0.0004f;
		const float FilterWidth = 0.05f;
		float Filter = smoothstep( FilterMin, FilterMin + FilterWidth * FilterWidth, NormalXYSquared );

		Normal.xy *= DecalStrength * Filter;
		Normal.z = sqrt( saturate( 1.0 - dot( Normal.xy, Normal.xy ) ) );
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

PixelShader =
{
	Code
	[[		
		
#define BLEND_MODE_OVERLAY 0
#define BLEND_MODE_REPLACE 1
#define BLEND_MODE_HARD_LIGHT 2
#define BLEND_MODE_MULTIPLY 3
#define BLEND_MODE_OVERLAY_SRGB 4
#define BLEND_MODE_HARD_LIGHT_SRGB 5
// Special handling of normal Overlay blend mode (in shader only)
#define BLEND_MODE_OVERLAY_NORMAL 6

// MOD(godherja)
// Additional blend modes by Buck (EK2)
#define BLEND_MODE_SCREEN 7
#define BLEND_MODE_ADDITIVE 8
// END MOD

		float OverlayDecal( float Target, float Blend ) {
			return float( Target > 0.5f ) * ( 1.0f - ( 2.0f * ( 1.0f - Target ) * ( 1.0f - Blend ) ) ) + float( Target <= 0.5f ) * ( 2.0f * Target * Blend );
		}
		
		float OverlayDecalSrgb( float Base, float Blend )
		{
			float MidPoint = ToLinear( 0.5 );
			
			if( Base < MidPoint ) 
			{
				//Multiply
				return Remap( Base, 0.0, MidPoint, 0.0, 1.0 ) * Blend;				
			}
			else
			{
				//Screen
				float InvBase = 1.0 - pow( Remap( Base, MidPoint, 1.0, 0.0, 1.0 ), RemapClamped(Blend, 0.0, MidPoint, 2.0, 1.0 ) );				
				return 1.0f - InvBase * ( 1.0f - Blend );
			}
		}
		
		float HardLightDecal( float Target, float Blend )
		{
			return float( Blend > 0.5f ) * ( 1.0f - ( 2.0f * ( 1.0f - Target ) * ( 1.0f - Blend ) ) ) + float( Blend <= 0.5f ) * ( 2.0f * Target * Blend );
		}
		
		float HardLightDecalSrgb( float Base, float Blend )
		{
			float MidPoint = ToLinear( 0.5 );
			if( Blend < MidPoint ) 
			{
				//Multiply
				return Base * Remap( Blend, 0.0, MidPoint, 0.0, 1.0 );
			}
			else
			{
				//Screen
				return 1.0f - (1.0f - Base) * Remap( Blend, MidPoint, 1.0, 1.0, 0.0 );
			}
		}
		
		float4 BlendDecal( uint BlendMode, float4 Target, float4 Blend, float Weight )
		{
			float4 Result = vec4( 0.0f );
		
			if ( BlendMode == BLEND_MODE_OVERLAY )
			{
				Result = float4( OverlayDecal( Target.r, Blend.r ), OverlayDecal( Target.g, Blend.g ), OverlayDecal( Target.b, Blend.b ), OverlayDecal( Target.a, Blend.a ) );
			}
			else if ( BlendMode == BLEND_MODE_OVERLAY_SRGB )
			{			
				Result = float4( OverlayDecalSrgb( Target.r, Blend.r ), OverlayDecalSrgb( Target.g, Blend.g ), OverlayDecalSrgb( Target.b, Blend.b ), OverlayDecalSrgb( Target.a, Blend.a ) );
			}
			else if ( BlendMode == BLEND_MODE_REPLACE )
			{
				Result = Blend;
			}
			else if ( BlendMode == BLEND_MODE_HARD_LIGHT )
			{
				Result = float4( HardLightDecal( Target.r, Blend.r ), HardLightDecal( Target.g, Blend.g ), HardLightDecal( Target.b, Blend.b ), HardLightDecal( Target.a, Blend.a ) );
			}
			else if ( BlendMode == BLEND_MODE_HARD_LIGHT_SRGB )
			{
				Result = float4( HardLightDecalSrgb( Target.r, Blend.r ), HardLightDecalSrgb( Target.g, Blend.g ), HardLightDecalSrgb( Target.b, Blend.b ), HardLightDecalSrgb( Target.a, Blend.a ) );
			}
			else if ( BlendMode == BLEND_MODE_MULTIPLY )
			{
				Result = Target * Blend;
			}
			else if ( BlendMode == BLEND_MODE_OVERLAY_NORMAL )
			{
				Result = float4( OverlayNormal( Target.xyz, Blend.xyz ), Target.a );
			}

			// MOD(godherja)
			// Additional blend modes by Buck (EK2)
			else if ( BlendMode == BLEND_MODE_SCREEN )
			{
				Result = float4(
						(1.0f - (1.0f - Target.r) * (1.0f - Blend.r) ),
						(1.0f - (1.0f - Target.g) * (1.0f - Blend.g) ),
						(1.0f - (1.0f - Target.b) * (1.0f - Blend.b) ),
						(1.0f - (1.0f - Target.a) * (1.0f - Blend.a) )
						//(Target.a)
					);
			}

			else if ( BlendMode == BLEND_MODE_ADDITIVE )
			{
				Result = float4(
						Target.r + Blend.r,
						Target.g + Blend.g,
						Target.b + Blend.b,
						Target.a + Blend.a
						//(Target.a)
					);
			}
			// END MOD

			return lerp( Target, Result, Weight );
		}
	]]
}