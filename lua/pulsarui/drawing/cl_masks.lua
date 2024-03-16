PulsarUI = PulsarUI or {}

-- Credit to https://gitlab.com/sleeppyy/xenin-framework/-/blob/master/laux/xeninui/libs/essentials.laux?ref_type=heads#L448-504
function PulsarUI.Mask(maskFunc, drawFunc, pixel)
	pixel = pixel or 1

	render.ClearStencil()
	render.SetStencilEnable(true)

	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)

	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(STENCILOPERATION_KEEP)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
	render.SetStencilReferenceValue(pixel)

	maskFunc()

	render.SetStencilFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilReferenceValue(pixel)

	drawFunc()

	render.SetStencilEnable(false)
	render.ClearStencil()
end

function PulsarUI.InverseMask(maskFunc, drawFunc, pixel)
	pixel = pixel or 1

	render.ClearStencil()
	render.SetStencilEnable(true)

	render.SetStencilWriteMask(1)
	render.SetStencilTestMask(1)

	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_NEVER)
	render.SetStencilReferenceValue(pixel)

	maskFunc()

	render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
	render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
	render.SetStencilZFailOperation(STENCILOPERATION_KEEP)
	render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
	render.SetStencilReferenceValue(pixel - 1)

	drawFunc()

	render.SetStencilEnable(false)
	render.ClearStencil()

end