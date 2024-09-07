Includes = {
	"cw/pdxterrain.fxh"
	"jomini/jomini_colormap.fxh"
	"jomini/jomini_colormap_constants.fxh"
	"jomini/jomini_province_overlays.fxh"
	"cw/utility.fxh"
	"standardfuncsgfx.fxh"
}

PixelShader = {

	TextureSampler PatternTexture
	{
		Index = 7
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		File = "gfx/map/terrain/pattern.dds"
		srgb = yes
	}
	
	Code
	[[

		float4 GetHighlightColor( in float2 WorldSpacePosXZ )
		{
			float4 HighlightColor = BilinearColorSampleAtOffset( WorldSpacePosXZ, IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, HighlightProvinceColorsOffset );
			HighlightColor.rgb *= 0.25;
			
			float3 Desaturated = vec3( ( HighlightColor.r + HighlightColor.g + HighlightColor.b ) / 3 );
			HighlightColor.rgb = lerp( HighlightColor.rgb, Desaturated, 0.35 );

			return HighlightColor;
		}

		void ApplyHighlightColor( inout float3 Diffuse, in float2 WorldSpacePosXZ, in float Lerp )
		{
			float4 HighlightColor = GetHighlightColor( WorldSpacePosXZ );
			Diffuse = lerp( Diffuse, HighlightColor.rgb, saturate( HighlightColor.a * Lerp * MapHighlightIntensity * 2.0 ) );
		}

		void ApplyHighlightColor( inout float3 Diffuse, in float2 WorldSpacePosXZ )
		{
			ApplyHighlightColor( Diffuse, WorldSpacePosXZ, 1.0 );
		}

		void CompensateWhiteHighlightColor( inout float3 Diffuse, in float2 WorldSpacePosXZ, in float Opacity )
		{
			float4 HighlightColor = GetHighlightColor( WorldSpacePosXZ );
			float ColorMask = smoothstep( 1.0f, 0.9f, HighlightColor.a );	// Mask out opaque highlights
			HighlightColor.a = Opacity * smoothstep( 0.0f, 1.0f, HighlightColor.a );
			
			Diffuse = Add( Diffuse, HighlightColor.rgb * SnowHighlightIntensity, HighlightColor.a * ColorMask * MapHighlightIntensity );
		}
		
		void GetBorderColorAndBlendGameLerp( float2 WorldSpacePosXZ, float3 Flatmap, out float3 BorderColor, out float BorderPreLightingBlend, out float BorderPostLightingBlend, float FlatmapLerp )
		{
			float4 HighlightColor = GetHighlightColor( WorldSpacePosXZ );
			float PatternTiling = 40;		
			float2 ColorMapCoords = WorldSpacePosXZ * WorldSpaceToTerrain0To1;
			float3 PatternMap = PdxTex2D( PatternTexture, float2( ColorMapCoords.x * PatternTiling * 2.0, 1.0 - ( ColorMapCoords.y * PatternTiling ) ) ).rgb;
			
			GetProvinceOverlayAndBlend( ColorMapCoords, BorderColor, BorderPreLightingBlend, BorderPostLightingBlend );
			
			PatternMap = lerp( float3( 0.5, 0.5, 0.5 ), vec3( PatternMap.g ), 1.0 ); // paper texture influence
			
			BorderColor = lerp( BorderColor, float3( 0.5, 0.5, 0.5 ), 0.175 ); // desaturate bordercolor
			BorderColor = lerp( BorderColor, float3( 0.0, 0.0, 0.0 ), 0.55 ); // darken bordercolor
			
			BorderColor = GetOverlay( BorderColor, PatternMap, 1-FlatmapLerp); // get paper texture
					
			float3 Desaturated = vec3( ( Flatmap.r + Flatmap.g + Flatmap.b ) / 3 );
			BorderColor = GetOverlay( BorderColor, Desaturated, FlatmapLerp );
			
		}
		void GetBorderColorAndBlendGame( float2 WorldSpacePosXZ, float3 Flatmap, out float3 BorderColor, out float BorderPreLightingBlend, out float BorderPostLightingBlend )
		{
			GetBorderColorAndBlendGameLerp( WorldSpacePosXZ, Flatmap, BorderColor, BorderPreLightingBlend, BorderPostLightingBlend, 0.0f );
		}

		#define GAME_SECONDARY_COLORS_INTENSITY 0.1

		void ApplySecondaryColorGame( inout float3 Diffuse, in float2 WorldSpacePosXZ )
		{
			float4 SecondaryColor = BilinearColorSampleAtOffset( WorldSpacePosXZ, IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, SecondaryProvinceColorsOffset );
			ApplyDiagonalStripes( Diffuse, SecondaryColor.rgb, SecondaryColor.a * GAME_SECONDARY_COLORS_INTENSITY, WorldSpacePosXZ );	
		}
	]]
}
