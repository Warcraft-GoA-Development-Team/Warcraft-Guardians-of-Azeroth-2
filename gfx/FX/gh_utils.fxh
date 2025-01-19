includes = {
	"gh_constants.fxh"
}

Code [[
	//
	// Macros
	//

	#ifndef PDX_OPENGL
		#define GH_LOOP [loop]
		#define GH_UNROLL [unroll]
		#define GH_UNROLL_EXACT(ITERATIONS_COUNT) [unroll(ITERATIONS_COUNT)]
	#else
		#define GH_LOOP
		#define GH_UNROLL
		#define GH_UNROLL_EXACT(ITERATIONS_COUNT)
	#endif

	#ifndef PDX_OPENGL
		#define GH_PdxTex2DArrayLoad(samp,uvi,lod) (samp)._Texture.Load( int4((uvi), (lod)) )
	#else
		#define GH_PdxTex2DArrayLoad texelFetch
	#endif

	//
	// Interface
	//

	int GH_DecodeIntFromRgba(float4 Rgba)
	{
		static const float THRESHOLD = 0.5f;

		// Decode Rgba into an integer between 0 and 15 inclusive
		return (int(step(THRESHOLD, Rgba.r)) << 0)
				| (int(step(THRESHOLD, Rgba.g)) << 1)
				| (int(step(THRESHOLD, Rgba.b)) << 2)
				| (int(step(THRESHOLD, Rgba.a)) << 3);
	}

	int GH_DecodeIntFromRgb(float3 Rgb)
	{
		// Decode Rgb into an integer between 0 and 7 inclusive
		return GH_DecodeIntFromRgba(float4(Rgb, 0.0f));
	}

	uint GH_DecodeFullMaskFromDecalRawWeight(uint DecalRawWeight)
	{
		static const uint DECAL_RAW_WEIGHT_MAX = GH_VANILLA_DATA_MAX_VALUE;

		return (DecalRawWeight * GH_MAX_FULL_MARKER_MASK) / DECAL_RAW_WEIGHT_MAX;
	}

	uint GH_DecodeDataMaskFromDecalRawWeight(uint DecalRawWeight)
	{
		// Only most significant GH_DATA_BITS_PER_MARKER from the full mask contain actual data.
		static const int NON_DATA_BITS_COUNT = GH_TOTAL_BITS_PER_MARKER - GH_DATA_BITS_PER_MARKER;

		uint FullMask = GH_DecodeFullMaskFromDecalRawWeight(DecalRawWeight);

		return FullMask >> NON_DATA_BITS_COUNT;
	}

	float3 GH_ToWorldSpace(float3 LocalSpacePos, float4x4 WorldMatrix)
	{
		float3 WorldSpacePos = mul(WorldMatrix, float4(LocalSpacePos, 1.0)).xyz;
		WorldSpacePos /= WorldMatrix[3][3];

		return WorldSpacePos;
	}
]]
