# THIS IS A GENERATED FILE.
#
# Source template:
# ../GHTemplates/gfx/FX/wc_dynamic_fog.fxh.jinja
#
# Please avoid manually editing this file: your changes WILL be overwritten when it gets regenerated.
# Instead, edit the source template and/or variables, then run render_templates.bat .
Includes = {
	"jomini/jomini.fxh"
}

Code
[[
	//
	// Types
	//

	// Each field corresponds to the constant of the same name
	// in vanilla constant buffer defined in jomini/jomini.fxh
	struct WC_FogSettings
	{
	    float	FogMax;
        float	FogBegin2;
        float3	FogColor;
        float	FogEnd2;
	};

	//
	// Service
	//

	WC_FogSettings WC_GetFogSettingsImpl(int TerrainVariantIndex, bool tiEnabled)
	{
	    WC_FogSettings Settings;

        // Use game-provided settings from jomini/posteffect_base.fxh as defaults
        Settings.FogColor = FogColor;
        Settings.FogMax = FogMax;
        Settings.FogBegin2 = FogBegin2;
        Settings.FogEnd2 = FogEnd2;

		#define WC_APPLY_FOG_SETTING(FIELD, VALUE) Settings.FIELD = VALUE

        if(tiEnabled)
        {
            WC_APPLY_FOG_SETTING(FogBegin2, 0.0);
            WC_APPLY_FOG_SETTING(FogEnd2, 180.0);
            WC_APPLY_FOG_SETTING(FogMax, 0.5);
            WC_APPLY_FOG_SETTING(FogColor, float3(0.468, 0.390, 0.585));
        }

		#undef WC_APPLY_FOG_SETTING

		return Settings;
	}

	//
	// Interface
	//

	WC_FogSettings WC_GetFogSettings(int TerrainVariantIndex, int AdjacentTerrainVariantIndex, bool tiEnabled, float AdjacentBlendAmount)
	{
	    WC_FogSettings Settings = WC_GetFogSettingsImpl(TerrainVariantIndex, tiEnabled);

		#ifndef GH_DISABLE_SMOOTH_DYNAMIC_TERRAIN_BORDERS
			if (TerrainVariantIndex == AdjacentTerrainVariantIndex || AdjacentBlendAmount < 0.01f)
				return Settings;

            WC_FogSettings AdjacentSettings = WC_GetFogSettingsImpl(AdjacentTerrainVariantIndex, tiEnabled);

			Settings.FogColor = lerp(Settings.FogColor, AdjacentSettings.FogColor, AdjacentBlendAmount);
			Settings.FogMax = lerp(Settings.FogMax, AdjacentSettings.FogMax, AdjacentBlendAmount);
			Settings.FogBegin2 = lerp(Settings.FogBegin2, AdjacentSettings.FogBegin2, AdjacentBlendAmount);
			Settings.FogEnd2 = lerp(Settings.FogEnd2, AdjacentSettings.FogEnd2, AdjacentBlendAmount);
		#endif // !GH_DISABLE_SMOOTH_DYNAMIC_TERRAIN_BORDERS

		return Settings;
	}
]]