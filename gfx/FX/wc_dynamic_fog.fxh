Includes = {
	"jomini/jomini.fxh"
}

Code
[[
	// Each field corresponds to the constant of the same name
	// in vanilla constant buffer defined in jomini/jomini.fxh
	struct WC_FogSettings
	{
	    float	FogMax;
        float	FogBegin2;
        float3	FogColor;
        float	FogEnd2;
	};

	WC_FogSettings WC_GetFogSettingsImpl(int TerrainVariantIndex, bool tiEnabled)
	{
	    WC_FogSettings Settings;

	    Settings.FogMax = FogMax;
	    Settings.FogBegin2 = FogBegin2;
	    Settings.FogColor = FogColor;
	    Settings.FogEnd2 = FogEnd2;

        if(tiEnabled)
        {
            Settings.FogBegin2 = 0.0;
            Settings.FogEnd2 = 180.0;
            Settings.FogMax = 0.5;
            Settings.FogColor = float3(0.468, 0.390, 0.585);
	    }

	    return Settings;
	}

	WC_FogSettings WC_GetFogSettings(int TerrainVariantIndex, int AdjacentTerrainVariantIndex, bool tiEnabled, bool adjacentTIEnabled, float AdjacentBlendAmount)
	{
	    WC_FogSettings Settings = WC_GetFogSettingsImpl(TerrainVariantIndex, tiEnabled);

        #ifndef GH_DISABLE_SMOOTH_DYNAMIC_TERRAIN_BORDERS
            if (TerrainVariantIndex == AdjacentTerrainVariantIndex || AdjacentBlendAmount < 0.01f)
                return Settings;

            WC_FogSettings AdjacentSettings = WC_GetFogSettingsImpl(AdjacentTerrainVariantIndex, adjacentTIEnabled);

            Settings.FogMax = lerp(Settings.FogMax, AdjacentSettings.FogMax, AdjacentBlendAmount);
            Settings.FogBegin2 = lerp(Settings.FogBegin2, AdjacentSettings.FogBegin2, AdjacentBlendAmount);
            Settings.FogColor.x = lerp(Settings.FogColor.x, AdjacentSettings.FogColor.x, AdjacentBlendAmount);
            Settings.FogColor.y = lerp(Settings.FogColor.y, AdjacentSettings.FogColor.y, AdjacentBlendAmount);
            Settings.FogColor.z = lerp(Settings.FogColor.z, AdjacentSettings.FogColor.z, AdjacentBlendAmount);
            Settings.FogEnd2 = lerp(Settings.FogEnd2, AdjacentSettings.FogEnd2, AdjacentBlendAmount);
        #endif // !GH_DISABLE_SMOOTH_DYNAMIC_TERRAIN_BORDERS

	    return Settings;
	}
]]