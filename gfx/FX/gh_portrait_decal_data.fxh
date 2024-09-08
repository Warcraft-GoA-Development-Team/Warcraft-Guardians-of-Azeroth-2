# NOTE: The following sampler and buffer definitions are originally from PixelShader section of vanilla jomini/portrait_decals.fxh .
#       They were moved here to be shared between pixel and vertex shader code across multiple files.
#       Must be kept in sync with vanilla as future game patches come out.

TextureSampler DecalDiffuseArray
{
	Ref = JominiPortraitDecalDiffuseArray
	MagFilter = "Linear"
	MinFilter = "Linear"
	MipFilter = "Linear"
	SampleModeU = "Wrap"
	SampleModeV = "Wrap"
	type = "2darray"
}

TextureSampler DecalNormalArray
{
	Ref = JominiPortraitDecalNormalArray
	MagFilter = "Linear"
	MinFilter = "Linear"
	MipFilter = "Linear"
	SampleModeU = "Wrap"
	SampleModeV = "Wrap"
	type = "2darray"
}

TextureSampler DecalPropertiesArray
{
	Ref = JominiPortraitDecalPropertiesArray
	MagFilter = "Linear"
	MinFilter = "Linear"
	MipFilter = "Linear"
	SampleModeU = "Wrap"
	SampleModeV = "Wrap"
	type = "2darray"
}

BufferTexture DecalDataBuffer
{
	Ref = JominiPortraitDecalData
	type = uint
}

# END NOTE

Code
[[
	// This is a vanilla definition originally from jomini/portrait_decals.fxh that was extracted here
	// because custom Godherja code from gh_portrait_effects.fxh also depends on it.
	// Any vanilla patches' changes to this definition need to be merged here and should also be merged
	// into its original (now commented-out) location inside jomini/portrait_decals.fxh .

	struct DecalData
	{
		uint _DiffuseIndex;
		uint _NormalIndex;
		uint _PropertiesIndex;
		uint _BodyPartIndex;

		uint _DiffuseBlendMode;
		uint _NormalBlendMode;
		uint _PropertiesBlendMode;
		float _Weight;

		uint2 _AtlasPos;
		float2 _UVOffset;
		uint2 _UVTiling;

		uint _AtlasSize;
	};
]]
