Includes = {
	"cw/camera.fxh"

	"cw/pdxterrain.fxh"
	"wc_map.fxh"
	"gh_dynamic_terrain.fxh"
	"wc_dynamic_fog.fxh"
}

Code
[[
	float CalculateDistanceFogFactor( float3 WorldSpacePos, WC_FogSettings Settings )
	{
		float3 Diff = CameraPosition - WorldSpacePos;
		float vFogFactor = 1.0 - abs( normalize( Diff ).y ); // abs b/c of reflections
		float vSqDistance = dot( Diff, Diff );

		float vMin = min( ( vSqDistance - Settings.FogBegin2 ) / ( Settings.FogEnd2 - Settings.FogBegin2 ), Settings.FogMax ) * (WC_GetTIProximityToAdjacentRegion(CameraPosition.xy));
		return saturate( vMin * vFogFactor );
	}

	float3 ApplyDistanceFog( float3 Color, float vFogFactor, WC_FogSettings Settings )
	{
		return lerp( Color, Settings.FogColor, vFogFactor );
	}

	float3 ApplyDistanceFog( float3 Color, float3 WorldSpacePos )
	{
	    float2 Position = CameraPosition.xz * WorldSpaceToTerrain0To1;
	    bool tiEnabled = WC_GetTerraIncognitaEnabled(float2( Position.x, 1.0 - Position.y ));
        int AdjacentRegionIndex = GH_GetNearestAdjacentDynamicTerrainRegionIndex(CameraPosition);
        int AdjacentTerrainVariantIndex = GH_GetTerrainVariantIndexByRegion(AdjacentRegionIndex);
        float BlendAmount = WC_GetTIAdjacentRegionBlendAmount(CameraPosition.xy, 1.0f);
	    WC_FogSettings Settings = WC_GetFogSettings(GH_GetTerrainVariantIndex(CameraPosition), AdjacentTerrainVariantIndex, tiEnabled, BlendAmount);

		return ApplyDistanceFog( Color, CalculateDistanceFogFactor( WorldSpacePos, Settings ), Settings );
	}
]]