# THIS IS A GENERATED FILE.
#
# Source template:
# ../GHTemplates/gfx/FX/gh_dynamic_terrain_filters.fxh.jinja
#
# Please avoid manually editing this file: your changes WILL be overwritten when it gets regenerated.
# Instead, edit the source template and/or variables, then run render_templates.bat .
Code = [[
	//
	// Defines
	//

	#ifdef GH_ENABLE_DYNAMIC_TERRAIN

		#ifdef RIVER
			#define GH_USE_DYNAMIC_TERRAIN_FILTER
			#define GH_DYNAMIC_TERRAIN_FILTER_NOT_desert
		#endif // RIVER

	#endif //  GH_ENABLE_DYNAMIC_TERRAIN

	//
	// Service
	//

	uint GH_GetDynamicTerrainFilterMask()
	{
		static const uint FULL_MASK = (1 << 3) - 1;

		#ifdef GH_USE_DYNAMIC_TERRAIN_FILTER
			uint FilterMask = 0;

			// NOT_desert
			#ifdef GH_DYNAMIC_TERRAIN_FILTER_NOT_desert
				FilterMask |= (1 << 1); // desert

				// Inverting the mask since NOT_desert is marked as a blacklist
				FilterMask = FULL_MASK & (~FilterMask);
			#endif
		#else
			uint FilterMask = FULL_MASK; // All variants enabled
		#endif // GH_USE_DYNAMIC_TERRAIN_FILTER

		return FilterMask;
	}

	//
	// Interface
	//

	bool GH_PassesDynamicTerrainFilter(int TerrainVariantIndex)
	{
		static uint FilterMask = GH_GetDynamicTerrainFilterMask();

		return ((1 << uint(TerrainVariantIndex)) & FilterMask) != 0;
	}
]]