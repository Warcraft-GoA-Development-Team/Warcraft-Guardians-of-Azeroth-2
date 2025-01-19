# THIS IS A GENERATED FILE.
#
# Source template:
# ../GHTemplates/gfx/FX/gh_dynamic_masks_params.fxh.jinja
#
# Please avoid manually editing this file: your changes WILL be overwritten when it gets regenerated.
# Instead, edit the source template and/or variables, then run render_templates.bat .
Code = [[
	bool GH_TryGetForcedWinterSeverityForTerrainVariant(in int TerrainVariantIndex, inout float WinterSeverity)
	{
		switch (TerrainVariantIndex)
		{
			default: return false;

			case 1: // desert
				WinterSeverity = 0.0f;
				break;

			case 2: // arctic
				WinterSeverity = 1.0f;
				break;

		}

		return true;
	}
]]