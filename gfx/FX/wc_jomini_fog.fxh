Includes = {
	"cw/camera.fxh"

	"cw/pdxterrain.fxh"
	"wc_map.fxh"
	"gh_dynamic_terrain.fxh"
	"wc_dynamic_fog.fxh"
}

Code
[[
    //TODO: I have no idea why but converting the WorldSpacePos to position in here makes it inconsistent with the
    // conversion in ApplyDistanceFog, so I just pass it instead
	float CalculateDistanceFogFactor( float3 WorldSpacePos, float2 Position, WC_FogSettings Settings )
	{
		float3 Diff = CameraPosition - WorldSpacePos;
		float vFogFactor = 1.0 - abs( normalize( Diff ).y ); // abs b/c of reflections
		float vSqDistance = dot( Diff, Diff );

        //TODO: This just isn't a good way to do this
		float vMin = min( ( vSqDistance - Settings.FogBegin2 ) / ( Settings.FogEnd2 - Settings.FogBegin2 ), Settings.FogMax ) * (WC_GetTIProximityToAdjacentRegion(float2( Position.x, 1.0 - Position.y )));
		return saturate( vMin * vFogFactor );
	}

	float3 ApplyDistanceFog( float3 Color, float vFogFactor, WC_FogSettings Settings )
	{
		return lerp( Color, Settings.FogColor, vFogFactor );
	}

	float3 ApplyDistanceFog( float3 Color, float3 WorldSpacePos )
	{
        float2 GH_WorldSpacePosXZ = CameraPosition.xz;
	    float2 Position = GH_WorldSpacePosXZ * WorldSpaceToDetail;

	    bool tiEnabled = WC_GetTerraIncognitaEnabled(float2( Position.x, 1.0 - Position.y ));
        int AdjacentRegionIndex = GH_GetNearestAdjacentDynamicTerrainRegionIndex(GH_WorldSpacePosXZ);
        int AdjacentTerrainVariantIndex = GH_GetTerrainVariantIndexByRegion(AdjacentRegionIndex);
        float BlendAmount = GH_GetAdjacentRegionBlendAmount(GH_WorldSpacePosXZ, GH_ADJACENT_POSTEFFECT_BLEND_PROXIMITY_RANGE);

	    WC_FogSettings Settings = WC_GetFogSettings(GH_GetTerrainVariantIndex(GH_WorldSpacePosXZ), AdjacentTerrainVariantIndex, tiEnabled, BlendAmount);

		return ApplyDistanceFog( Color, CalculateDistanceFogFactor( WorldSpacePos, Position, Settings ), Settings );
	}
]]