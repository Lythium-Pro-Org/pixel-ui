-- https://github.com/Jaffies/paint -- version 1.10
if SERVER then return end

do
if CLIENT and BRANCH ~= 'x86-64' then
print('paint library detoured mesh.Position to support (x, y, z) overload because gmod hasn\'t updated yet on non x64-86')
local vec = Vector()
local vecSetUnpacked = vec.SetUnpacked
mesh.OldPosition = mesh.OldPosition or mesh.Position
---@param x number|Vector
---@param y? number
---@param z? number
---@overload fun(x: Vector)
function mesh.Position(x, y, z)
if y == nil then
---@cast x Vector
mesh.OldPosition(x)
return
end
---@cast y number
---@cast z number
---@cast x number
vecSetUnpacked(vec, x, y, z)
mesh.OldPosition(vec)
end
end
end

do
 ---@diagnostic disable: deprecated
---Paint library for GMod!
---
---Purpose: drop in replacement to all surface/draw functions. Now there's no need to use them
---
---	Features:
---
---		1) Enchanced lines, with support of linear gradients.
---
---		2) Enchanced rounded boxes. They support stencils, materials and outlines.
---
---		3) Circles. Super fast.
---
--- 	4) Batching. Everything here can be batched to save draw calls. Saves a lot of performance.
---
--- 	5) This library is SUPER fast. Some functions here are faster than default ones.
---
--- 	6) Rectangle support, with support of per-corner gradienting
---
--- 	7) Coordinates do not end up being rounded. Good for markers and other stuff.
---
--- Coded by [@jaffies](https://github.com/jaffies), aka [@mikhail_svetov](https://github.com/jaffies) (formely @michael_svetov) in discord.
--- Thanks to [A1steaksa](https://github.com/Jaffies/paint/pull/1), PhoenixF, [Riddle](https://github.com/Jaffies/paint/pull/2) and other people in gmod discord for various help
---
--- Please, keep in mind that this library is still in development. 
--- You can help the project by contributing to it at [github repository](https://github.com/jaffies/paint)
---@class PulsarUI.paint paint d # paint library. Provides ability to draw shapes with mesh power
---@field lines lines # lines module of paint library. Can make batched and gradient lines out of the box
---@field roundedBoxes roundedBoxes # roundedBoxes provide better rounded boxes drawing because it makes them via meshes/polygons you name it.
---@field rects rects # Rect module, gives rects with ability to batch and gradient per corner support
---@field outlines outlines # outline module, gives you ability to create hollow outlines with  
---@field batch batch Unfinished module of batching. Provides a way to create IMeshes 
---@field examples PulsarUI.paint.examples example library made for help people understand how paint library actually works. Can be opened via ``lua_run examples.showHelp()``
---@field blur blur blur library, provides a nice way to retrieve a cheap blur textures/materials
---@field circles circles Circles! killer.
local paint = {}
PulsarUI.paint = paint or {}

---@alias gradients Color | {[1] : Color, [2]: Color, [3]: Color, [4]: Color, [5]: Color?}
---@alias linearGradient Color | {[1]: Color, [2]: Color}

do
	-- this fixes rendering issues with batching

	---Internal variable made for batching to store Z pos meshes won't overlap each other
	---@deprecated Internal variable. Not meant to use outside
	PulsarUI.paint.Z = 0

	---resets PulsarUI.paint.Z to 0
	function PulsarUI.paint.resetZ()
		PulsarUI.paint.Z = 0
	end

	--- Increments Z, meaning that next draw operation will be on top of others while batching (because of it's Z position heh)
	---@return number Z # current Z position
	function PulsarUI.paint.incrementZ()
		PulsarUI.paint.Z = PulsarUI.paint.Z + 1

		if PulsarUI.paint.Z > 16384 then
			PulsarUI.paint.resetZ()
		end

		return PulsarUI.paint.getZ()
	end

	--- Calculates Z position, depending of PulsarUI.paint.Z value. Made for batching
	---@return number z # calculated Z position. Is not equal to PulsarUI.paint.Z 
	function PulsarUI.paint.getZ()
		return -1 + PulsarUI.paint.Z / 8192
	end
end

do -- Additional stuff to scissor rect.
    -- needed for panels, i.e. multiple DScrollPanels clipping.
    local tab = {}
    local len = 0

    local setScissorRect = render.SetScissorRect
    local max = math.max
    local min = math.min

    --- Pushes new scissor rect boundaries to stack. Simmilar to Push ModelMatrix/RenderTarget/Filter(Mag/Min)
    ---@see render.PushRenderTarget # A simmilar approach to render targets.
    ---@param x number # start x position
    ---@param y number # start y position
    ---@param endX number # end x position. Must be bigger than x
    ---@param endY number # end y position. Must be bigger than y
    function PulsarUI.paint.pushScissorRect(x, y, endX, endY)
        local prev = tab[len]

        if prev then
            x = max(prev[1], x)
            y = max(prev[2], y)
            endX = min(prev[3], endX)
            endY = min(prev[4], endY)
        end

        len = len + 1

        tab[len] = {x, y, endX, endY}
        setScissorRect(x, y, endX, endY, true)
    end

    --- Pops last scissor rect's boundaries from the stack. Simmilar to Pop ModelMatrix/RenderTarget/Filter(Mag/Min)
    ---@see PulsarUI.paint.pushScissorRect
    function PulsarUI.paint.popScissorRect()
        tab[len] = nil
        len = max(0, len - 1)

        local newTab = tab[len]

        if newTab then
            setScissorRect(newTab[1], newTab[2], newTab[3], newTab[4], true)
        else
            setScissorRect(0, 0, 0, 0, false)
        end
    end
end

do
	local vector = Vector()
	local paintColoredMaterial = CreateMaterial( "testMaterial" .. SysTime(), "UnlitGeneric", {
	  ["$basetexture"] = "color/white",
	  ["$model"] = 1,
	  ["$translucent"] = 1,
	  ["$vertexalpha"] = 1,
	  ["$vertexcolor"] = 1
	} )

	local recompute = paintColoredMaterial.Recompute
	local setVector = paintColoredMaterial.SetVector
	local setUnpacked = vector.SetUnpacked

	---This function provides you a material with solid color, allowing you to replicate ``render.SetColorModulation``/``surface.SetDrawColor``
	---
	---Meant to be used to have paint's shapes have animated colors without rebuilding mesh every time color changes 
	---
	---It will tint every color of shape, but not override it. Meaning that yellow color wont be overriden to blue.
	---
	---instead it will be black because red/green components will be multiplied to 0, and blue component (which is 0, because its yellow) will be mutliplied by 1. Which equeals 0
	---
	---**Note:** You will have to call this function every time the color of coloredMaterial changes, because it uses 1 material and sets its color to what you want
	---Example:
	---```lua
	---PulsarUI.paint.outlines.drawOutline(32, 100, 100, 256, 256, {color_white, color_transparent}, PulsarUI.paint.getColoredMaterial( HSVToColor(RealTime() * 100, 1, 1) ), 16 )
	-----[[It will make halo/shadow with animated color]]
	---```
	---@param color Color color that material will have
	---@return IMaterial coloredMaterial
	function PulsarUI.paint.getColoredMaterial(color)
		setUnpacked(vector, color.r, color.g, color.b)
		setVector(paintColoredMaterial, '$color', vector)
		recompute(paintColoredMaterial)

		return paintColoredMaterial
	end



end

do
	-- Helper functions
	-- startPanel - pops model matrix and pushes

	local matrix = Matrix()
	local setField = matrix.SetField

	local pushModelMatrix = cam.PushModelMatrix
	local popModelMatrix = cam.PopModelMatrix

	---@type Panel
	local panelTab = FindMetaTable('Panel')

	local localToScreen = panelTab.LocalToScreen
	local getSize = panelTab.GetSize

	local pushScissorRect = PulsarUI.paint.pushScissorRect
	local popScissorRect = PulsarUI.paint.popScissorRect

	---
	---Unfortunately, the paint library cannot integrate seamlessly with VGUI and Derma in the way that the surface and draw libraries do.
	---This is because Meshes, which are used by the paint library, can only use absolute screen coordinates whereas the surface and draw libraries are automatically provided with panel-relative coordinates by the VGUI system.
	---
	---In addition, meshes cannot be clipped with the default VGUI clipping system and will behave as though it is disabled.
	---
	---To work around these limitations, you can use this function.
	---@param panel Panel # The panel to draw on.
	---@param pos? boolean # Set to true to autoamtically adjust all future paint operations to be relative to the panel.  Default: true
	---@param boundaries? boolean # Set to true to enable ScissorRect to the size of the panel. Default: false
	function PulsarUI.paint.startPanel(panel, pos, boundaries, multiply)
		local x, y = localToScreen(panel, 0, 0)

		if pos or pos == nil then

			setField(matrix, 1, 4, x)
			setField(matrix, 2, 4, y)

			pushModelMatrix(matrix, multiply)
		end

		if boundaries then
			local w, h = getSize(panel)

			pushScissorRect(x, y, x + w, y + h)
		end
	end

	---@see PulsarUI.paint.startPanel # Note: You need to have same arguments for position and boundaries between start and end panel functions.
	---@param pos? boolean # Set to true to autoamtically adjust all future paint operations to be relative to the panel.  Default: true
	---@param boundaries? boolean # Set to true to enable ScissorRect to the size of the panel. Default: false
	function PulsarUI.paint.endPanel(pos, boundaries)
		if pos or pos == nil then
			popModelMatrix()
		end

		if boundaries then
			popScissorRect()
		end
	end

	do -- since startPanel and endPanel sound stupid and i figured it out only now, i'll make an aliases for them
		PulsarUI.paint.beginPanel = PulsarUI.paint.startPanel
		PulsarUI.paint.stopPanel = PulsarUI.paint.endPanel

		-- PulsarUI.paint.beginPanel -> PulsarUI.paint.endPanel (like in Pascal language, or mesh.Begin -> mesh.End)
		-- PulsarUI.paint.startPanel -> PulsarUI.paint.stopPanel (start/stop sound cool in pairs)
	end

	--- Simple helper function which makes bilinear interpolation
	---@deprecated Internal variable. Not meant to use outside
	---@param x number # x is fraction between 0 and 1. 0 - left side, 1 - right side
	---@param y number # y is fraction between 0 and 1. 0 - top side, 1 - bottom side
	---@param leftTop integer
	---@param rightTop integer
	---@param rightBottom integer
	---@param leftBottom integer
	---@return number result # result of bilinear interpolation
	function PulsarUI.paint.bilinearInterpolation(x, y, leftTop, rightTop, rightBottom, leftBottom)
		if leftTop == rightTop and leftTop == rightBottom and leftTop == leftBottom then return leftTop end -- Fix (sometimes 255 alpha could get 254, probably double prescision isn't enought or smth like that)
		local top = leftTop == rightTop and leftTop or ( (1 - x) * leftTop + x * rightTop)
		local bottom = leftBottom == rightBottom and leftBottom or ((1 - x) * leftBottom + x * rightBottom) -- more precise checking
		return (1 - y) * top + y * bottom
	end
end

PulsarUI.paint = paint end do ---@diagnostic disable: deprecated
---# Batching library of paint lib 
---This is a really hard to explain thing, and made for experienced lua coders
---
---This library allows you to generate IMeshes on the fly, by using default
---paint library draw functions
---
---In order to cache resulted IMesh of course!
---
---That allows you to batch your multiple shape in 1 single mesh in order to save draw calls
---@class batch
local batch = {}

batch.batching = false

---@type table # current batching table
local batchTable = {
	[0] = 0
}

--- Resets batching queue
function batch.reset()
	batchTable = {
		[0] = 0
	}

	---@type table # current batching table
	batch.batchTable = batchTable
end

--- Starts batching queue
function batch.startBatching()
	batch.batching = true
	batch.reset()
end

--[[
	I guess this function will get JIT compiled
]]

--- Internal function
---@param tab table
---@param i integer
---@return number
---@return number
---@return number
---@return Color
---@return number
---@return number
---@return Color
---@return number
---@return number
---@return Color
local function getVariables(tab, i)
	return tab[i], tab[i + 1], tab[i + 2], tab[i + 3], tab[i + 4], tab[i + 5], tab[i + 6], tab[i + 7], tab[i + 8], tab[i + 9]
end

do
	local meshBegin = mesh.Begin
	local meshEnd = mesh.End
	local meshPosition = mesh.Position
	local meshColor = mesh.Color
	local meshAdvanceVertex = mesh.AdvanceVertex

	local meshConstructor = Mesh
	local PRIMITIVE_TRIANGLES = MATERIAL_TRIANGLES

	--- Stops batching queue and returns builded mesh.
	---@return IMesh batchedMesh #batched mesh
	---@nodiscard
	function batch.stopBatching()
		local tab = batch.batchTable

		local iMesh = meshConstructor()

		meshBegin(iMesh, PRIMITIVE_TRIANGLES, tab[0] * 0.3)
			for i = 1, tab[0], 10 do
				local x, y, z, color, x1, y1, color1, x2, y2, color2 = getVariables(tab, i)

				meshPosition(x, y, z)
				meshColor(color.r, color.g, color.b, color.a)
				meshAdvanceVertex()

				meshPosition(x1, y1, z)
				meshColor(color1.r, color1.g, color1.b, color1.a)
				meshAdvanceVertex()

				meshPosition(x2, y2, z)
				meshColor(color2.r, color2.g, color2.b, color2.a)
				meshAdvanceVertex()
			end
		meshEnd()

		batch.reset()
		batch.batching = false

		return iMesh
	end
end

do
	local startPanel, endPanel = PulsarUI.paint.startPanel, PulsarUI.paint.endPanel
	local meshDraw = FindMetaTable('IMesh')--[[@as IMesh]].Draw
	local meshDestroy = FindMetaTable('IMesh')--[[@as IMesh]].Destroy
	local resetZ = PulsarUI.paint.resetZ

	local whiteMat = Material('vgui/white')
	local setMaterial = render.SetMaterial

	local startBatching = batch.startBatching
	local stopBatching = batch.stopBatching

	---@param self InjectedPanel
	---@param x number
	---@param y number
	local panelPaint = function(self, x, y)
		local iMesh = self.iMesh
		if not iMesh then return end

		do
			local beforePaint = self.BeforePaint
			if beforePaint then
				beforePaint(self, x, y)
			end
		end

		local disableBoundaries = self.DisableBoundaries

		setMaterial(whiteMat)

		startPanel(self, true, disableBoundaries ~= true)
			meshDraw(iMesh)
		endPanel(true, disableBoundaries ~= true)

		do
			local afterPaint = self.AfterPaint
			if afterPaint then
				afterPaint(self, x, y)
			end
		end
	end

	---@param self InjectedPanel
	---@param x number
	---@param y number
	local panelRebuildMesh = function(self, x, y)
		resetZ()
			local iMesh = self.iMesh
			if iMesh then
				meshDestroy(iMesh)
			end

			local drawFunc = self.PaintMesh

			if drawFunc then
				startBatching()
					drawFunc(self, x, y)
				self.iMesh = stopBatching()
			end
		resetZ()
	end

	---@param self InjectedPanel
	---@param x number
	---@param y number
	local panelOnSizeChanged = function(self, x, y)
		local rebuildMesh = self.RebuildMesh

		if rebuildMesh then
			rebuildMesh(self, x, y)
		end

		local oldOnSizeChanged = self.OldOnSizeChanged

		if oldOnSizeChanged then
			oldOnSizeChanged(self, x, y)
		end
	end

	---@class InjectedPanel : Panel # The injected panel is a supporting class that actually behaves as a wrapped pannel. Made for people who like
	---type checking, and lsp things. Used internally only.
	---@field Paint function
	---@field OnSizeChanged function
	---@field OldOnSizeChanged function?
	---@field RebuildMesh function
	---@field DisableBoundaries boolean?
	---@field BeforePaint function?
	---@field AfterPaint function?
	---@field PaintMesh function?
	---@field iMesh IMesh?

	---Wraps panel with some hacky functions that overrides paint function and OnChangeSize
	---That is made for panel to use Panel:PaintMesh() when panel is updated (size updated/etc)
	---@param panel Panel
	function batch.wrapPanel(panel)
		---@cast panel InjectedPanel
		panel.Paint = panelPaint
		panel.OldOnSizeChanged = panel.OnSizeChanged
		panel.OnSizeChanged = panelOnSizeChanged
		panel.RebuildMesh = panelRebuildMesh
	end
end

do
	---Adds triangle to batching queue. If you want to manually add some figures to paint batching, then you can use this.
	---@param z number Z position of next triangle. You want to use PulsarUI.paint.incrementZ for that
	---@param x1 number
	---@param y1 number
	---@param color1 Color color of first vertex
	---@param x2 number
	---@param y2 number
	---@param color2 Color color of second vertex
	---@param x3 number
	---@param y3 number
	---@param color3 Color color of third vertex
	function batch.addTriangle(z, x1, y1, color1, x2, y2, color2, x3, y3, color3)
		local len = batchTable[0]

		batchTable[len + 1] = x1
		batchTable[len + 2] = y1
		batchTable[len + 3] = z
---@diagnostic disable-next-line: assign-type-mismatch
		batchTable[len + 4] = color1

		batchTable[len + 5] = x2
		batchTable[len + 6] = y2
---@diagnostic disable-next-line: assign-type-mismatch
		batchTable[len + 7] = color2

		batchTable[len + 8] = x3
		batchTable[len + 9] = y3
---@diagnostic disable-next-line: assign-type-mismatch
		batchTable[len + 10] = color3

		batchTable[0] = len + 10
	end
end

---@type table current batching table
batch.batchTable = batchTable

-- used _G because lsp doesn't recognize the table

--- Batch library for paint lib
PulsarUI.paint.batch = batch end do ---@diagnostic disable: deprecated

---	Lines. Why they are good?
---	1) They support gradients. It means that you do not need to make a lot of lines to make
---	color grading smooth between start of segment and the end of it.
---
---	2) They support batching. It means that you can make a lot of lines without any performance costs
--- Examples of PulsarUI.paint.lines
---
--- Simple line example:
---
--- Drawing lines with a gradient of different colors.
---```lua
---	PulsarUI.paint.lines.drawLine( 10, 20, 34, 55, Color( 0, 255, 0 ), Color( 255, 0, 255 ) )
---	PulsarUI.paint.lines.drawLine( 40, 10, 70, 40, Color( 255, 255, 0 ) )
---```
---Batched Lines Example:
---
---Drawing 50 lines with improved performance by using batching.
---```lua
---PulsarUI.paint.lines.startBatching()
---	for i = 1, 50 do
---		PulsarUI.paint.lines.drawLine( i * 10, 10, i * 10 + 5, 55, Color( 0, i * 255 / 50, 0 ), Color( 255, 0, 255 ) )
---	end
---PulsarUI.paint.lines.stopBatching()
---```
---@class lines (exact)
---@field drawLine function
---@field startBatching function
---@field stopbatching function
local lines = {}

--- batch table
local batch = {[0] = 0}

local PRIMITIVE_LINES = MATERIAL_LINES
local PRIMITIVE_LINE_STRIP = MATERIAL_LINE_STRIP
local PRIMITIVE_LINE_LOOP = MATERIAL_LINE_LOOP

do
	-- define drawing functions
	local meshBegin = mesh.Begin
	local meshEnd = mesh.End
	local meshPosition = mesh.Position
	local meshColor = mesh.Color
	local meshAdvanceVertex = mesh.AdvanceVertex

	local renderSetColorMaterialIgnoreZ = render.SetColorMaterialIgnoreZ

	-- single line
	-- It is used when there is no any batching.

	---Draws single unbatched line. Used internally
	---@param startX number
	---@param startY number
	---@param endX number
	---@param endY number
	---@param startColor Color
	---@param endColor? Color
	---@deprecated Internal variable. Not meant to use outside
	function lines.drawSingleLine(startX, startY, endX, endY, startColor, endColor)
		if endColor == nil then
			endColor = startColor
		end

		renderSetColorMaterialIgnoreZ()

		meshBegin(PRIMITIVE_LINES, 1)
			meshColor(startColor.r, startColor.g, startColor.b, startColor.a)

			meshPosition(startX, startY, 0)

			meshAdvanceVertex()

			meshColor(endColor.r, endColor.g, endColor.b, endColor.a)

			meshPosition(endX, endY, 0)

			meshAdvanceVertex()
		meshEnd()
	end

	-- Now batched lines

	--[[
		primitiveType is either MATERIAL_LINES, MATERIAL_LINE_STRIP or MATERIAL_LINE_LOOP

		array is a one dimensional one which has this lines
		{
			x, y, color
			x1, y1, color1,
			x2, y2, color2,
			x3, y3, color3,
			x4, y4, color4,
			x5, y5, color5
		}
	--]]

	--- internal function enum, used like switch case
	local counts = {
		[PRIMITIVE_LINES] = function(len) return len / 6 end,
		[PRIMITIVE_LINE_STRIP] = function(len) return len / 6 end,
		[PRIMITIVE_LINE_LOOP] = function(len) return len / 6 - 1 end
	}

	---Draws batched lines
	---@deprecated Internal variable. Not meant to use outside
	---@param array table # array with [startX:number, startY:number, startColor:Color, endColor:Color ...]
	function lines.drawBatchedLines(array)
		---@type number
		local primitiveType = array[-1] or PRIMITIVE_LINES

		renderSetColorMaterialIgnoreZ()

		meshBegin(primitiveType, counts[primitiveType](array[0]))
		if primitiveType == PRIMITIVE_LINES then
			for i = 1, array[0], 6 do
				local startX, startY, endX, endY = array[i], array[i + 1], array[i + 3], array[i + 4]
				local startColor, endColor = array[i + 2], array[i + 5]

				meshColor(startColor.r, startColor.g, startColor.b, startColor.a)
				meshPosition(startX, startY, 0)

				meshAdvanceVertex()

				meshColor(endColor.r, endColor.g, endColor.b, endColor.a)
				meshPosition(endX, endY, 0)

				meshAdvanceVertex()
			end
		elseif primitiveType == PRIMITIVE_LINE_STRIP then
			meshPosition(array[1], array[2], 0)

			local startColor = array[3]

			meshColor(startColor.r, startColor.g, startColor.b, startColor.a)

			meshAdvanceVertex()

			for i = 4, array[0], 6 do
				local x, y, color = array[i], array[i + 1], array[i + 2]

				meshPosition(x, y, 0)
				meshColor(color.r, color.g, color.b, color.a)

				meshAdvanceVertex()
			end
		else -- PRIMITIVE_LINE_LOOP
			meshPosition(array[1], array[2], 0)

			local startColor = array[3]

			meshColor(startColor.r, startColor.g, startColor.b, startColor.a)

			meshAdvanceVertex()

			for i = 4, array[0] - 3, 6 do -- last 3 is basically a start.
				local x, y, color = array[i], array[i + 1], array[i + 2]

				meshPosition(x, y, 0)

				meshColor(color.r, color.g, color.b, color.a)

				meshAdvanceVertex()
			end
		end
		meshEnd()
	end
end

---@type boolean
local batching = false

do -- batching functions

	--- Starts line batching. All lines drawn after this function is called will be batched until stopBatching() is called.
	--- Note: Batching is not shared between different types of shapes.
	function lines.startBatching()
		batching = true

		batch[-1] = PRIMITIVE_LINE_STRIP -- set as default one
		batch[0] = 0
	end

	--- Stops batching and draws final result.
	---@see lines.startBatching
	function lines.stopBatching()
		-- last check if it is a line loop

		local len = batch[0]

		if batch[-1] == PRIMITIVE_LINE_STRIP and batch[1] == batch[len - 2] and batch[2] == batch[len - 1] and batch[3] == batch[len] then
			batch[-1] = PRIMITIVE_LINE_LOOP
		end

		lines.drawBatchedLines(batch)

		batching = false

		batch = { [0] = 0 } -- reseting queued batches
	end

	--- Adds line to batching queue
	---@param startX number
	---@param startY number
	---@param endX number
	---@param endY number
	---@param startColor Color
	---@param endColor? Color
	---@deprecated Internal variable. Not meant to use outside
	function lines.drawBatchedLine(startX, startY, endX, endY, startColor, endColor)
		if endColor == nil then
			endColor = startColor
		end

		---@type integer
		local len = batch[0]

		if batch[-1] == PRIMITIVE_LINE_STRIP and batch[0] ~= 0 then -- check if it is a line strip
			if startX ~= batch[len - 2] or startY ~= batch[len - 1] or startColor ~= batch[len] then
				batch[-1] = PRIMITIVE_LINES
			end
		end

		batch[len + 1] = startX
		batch[len + 2] = startY
---@diagnostic disable-next-line: assign-type-mismatch
		batch[len + 3] = startColor
		batch[len + 4] = endX
		batch[len + 5] = endY
---@diagnostic disable-next-line: assign-type-mismatch
		batch[len + 6] = endColor

		batch[0] = len + 6
	end
end

do -- drawing

	local drawSingleLine = lines.drawSingleLine
	local drawBatchedLine = lines.drawBatchedLine

	--- Draws a line with the specified parameters.
	---@param startX number # The X position of the start of the line
	---@param startY number # The Y position of the start of the line
	---@param endX number # The X position of the end of the line
	---@param endY number # The Y position of the end of the line
	---@param startColor Color # The color of the start of the line
	---@param endColor? Color  # The color of the end of the line.  Default: startColor
	function lines.drawLine(startX, startY, endX, endY, startColor, endColor)
		if batching then
			drawBatchedLine(startX, startY, endX, endY, startColor, endColor)
		else
			drawSingleLine(startX, startY, endX, endY, startColor, endColor)
		end
	end

end

PulsarUI.paint.lines = lines end do ---@diagnostic disable: deprecated

---	What makes paint rectangles different from surface and draw rectangles?
---	1) Support for linear, per-corner gradients!
---	2) Vastly improved performance when drawing multiple rectangles, thanks to batching!
---
--- Examples!
---
--- Simple Example:
---
---Drawing an uncolored rectangle with a material, a rectangle with a material and per-corner colors, and a rectangle with just per-color corners.
---```lua
--- 	local mat = Material( "icon16/application_xp.png" )
--- 	PulsarUI.paint.rects.drawRect( 0, 0, 64, 64, color_white, mat, 0.5, 0, 1, 0.75 )
--- 	PulsarUI.paint.rects.drawRect( 64, 0, 64, 64, { Color(255, 0, 0 ), Color( 0, 255, 0 ), Color( 0, 0, 255 ), color_white }, mat )
--- 	PulsarUI.paint.rects.drawRect( 128, 0, 64, 64, { Color(255, 0, 0 ), Color( 0, 255, 0 ), Color( 0, 0, 255 ), color_white } )
---```
---Batched Example
---
---Drawing 25 rectangles with improved performance by using batching.
---```lua
---PulsarUI.paint.rects.startBatching()
---	for i = 1, 25 do
---		PulsarUI.paint.rects.drawRect( i * 15, 0, 15, 50, { COLOR_WHITE, COLOR_BLACK, COLOR_BLACK, COLOR_WHITE } )
---	end
---PulsarUI.paint.rects.stopBatching()
---```
---@class rects
local rects = {}

do
	--[[
		Purpose: makes a table, containing Rectangular mesh.
		Same params as drawSingleRect, except:
			w, h are replaced to endX, endY.
				They are end coordinates, not width, or height.
				It means they are calculated as startX + w and startY + h in drawSingleRect
			colors can accept only table of colors.
			And there's no material parameter
	]]

--[[ 	function rects.generateRectMesh(startX, startY, endX, endY, colors, u1, v1, u2, v2)

		local leftBottom = { pos = vector(startX, endY), color = colors[4], u = u1, v = v2 }
		local rightTop = { pos = vector(endX, startY), color = colors[2], u = u2, v = v1 }

		return {
			leftBottom, -- first triangle
			{ pos = vector(startX, startY), color = colors[1], u = u1, v = v1 },
			rightTop,

			leftBottom, -- second one
			rightTop,
			{ pos = vector(endX, endY), color = colors[3], u = u2, v = v2 }
		}
	end--]]

	local meshBegin = mesh.Begin
	local meshEnd = mesh.End
	local meshPosition = mesh.Position
	local meshColor = mesh.Color
	local meshTexCoord = mesh.TexCoord
	local meshAdvanceVertex = mesh.AdvanceVertex

	local PRIMITIVE_QUADS = MATERIAL_QUADS

	--- Helper function to unpack color
	---@param color Color
	---@return integer r
	---@return integer g
	---@return integer b
	---@return integer a
	local function unpackColor(color) return color.r, color.g, color.b, color.a end -- FindMetaTable still works shitty.

	--- generates quad onto IMesh
	---@param mesh IMesh
	---@param startX number
	---@param startY number
	---@param endX number
	---@param endY number
	---@param colors gradients # Color or colors used by gradient. Can be a single color, or a table of colors.
	---@param u1 number
	---@param v1 number
	---@param u2 number
	---@param v2 number
	---@param skew number? sets skew for top side of rect.
	---@param topSize number? overrides size for top side of rect
	---@deprecated Internal variable. Not meant to use outside
	function rects.generateRectMesh(mesh, startX, startY, endX, endY, colors, u1, v1, u2, v2, skew, topSize)
		local startTopX = startX + (skew or 0)
		local endTopX = topSize and topSize > 0 and startTopX + topSize or endX + (skew or 0)

		meshBegin(mesh, PRIMITIVE_QUADS, 1)
			meshPosition(startX, endY, 0)
			meshColor(unpackColor(colors[4]))
			meshTexCoord(0, u1, v2)
			meshAdvanceVertex()

			meshPosition(startTopX, startY, 0)
			meshColor(unpackColor(colors[1]))
			meshTexCoord(0, u1, v1)
			meshAdvanceVertex()

			meshPosition(endTopX, startY, 0)
			meshColor(unpackColor(colors[2]))
			meshTexCoord(0, u2, v1)
			meshAdvanceVertex()

			meshPosition(endX, endY, 0)
			meshColor(unpackColor(colors[3]))
			meshTexCoord(0, u2, v2)
			meshAdvanceVertex()
		meshEnd()
	end

	--Quad batching (NON TRIANGLE, used for only rects!)

	local mat = Material('vgui/white')
	local renderSetMaterial = render.SetMaterial

	--- Draws batched rects (quads)
	---@param array table # {x, y, endX, endY, color1, color2, color3, color4, ...}
	---@deprecated Internal variable. Not meant to use outside
	function rects.drawBatchedRects(array)
		renderSetMaterial(mat)
		meshBegin(PRIMITIVE_QUADS, array[0] / 8)
			for i = 1, array[0], 8 do
				local x, y, endX, endY = array[i], array[i + 1], array[i + 2], array[i + 3]
				local color1, color2, color3, color4 = array[i + 4], array[i + 5], array[i + 6], array[i + 7]

				meshPosition(x, endY, 0)
				meshColor(color4.r, color4.g, color4.b, color4.a)

				meshAdvanceVertex()

				meshPosition(x, y, 0)
				meshColor(color1.r, color1.g, color1.b, color1.a)

				meshAdvanceVertex()

				meshPosition(endX, y, 0)
				meshColor(color2.r, color2.g, color2.b, color2.a)

				meshAdvanceVertex()

				meshPosition(endX, endY, 0)
				meshColor(color3.r, color3.g, color3.b, color3.a)

				meshAdvanceVertex()
			end
		meshEnd()
	end
end

do
	-- purpose: draws batched rectangle.
	local incrementZ = PulsarUI.paint.incrementZ
	local batch = PulsarUI.paint.batch

	--- Adds rect to triangle batch queue
	---@deprecated Internal variable. Not meant to use outside
	---@param startX number
	---@param startY number
	---@param endX number
	---@param endY number
	---@param colors gradients # Color or colors used by gradient. Can be a single color, or a table of colors
	function rects.drawBatchedRect(startX, startY, endX, endY, colors)
		local tab = batch.batchTable
		local len = tab[0]
		local z = incrementZ()

		tab[len + 1] = startX
		tab[len + 2] = endY
		tab[len + 3] = z
		tab[len + 4] = colors[4]

		tab[len + 5] = startX
		tab[len + 6] = startY
		tab[len + 7] = colors[1]

		tab[len + 8] = endX
		tab[len + 9] = startY
		tab[len + 10] = colors[2]

		tab[len + 11] = startX
		tab[len + 12] = endY
		tab[len + 13] = z
		tab[len + 14] = colors[4]

		tab[len + 15] = endX
		tab[len + 16] = startY
		tab[len + 17] = colors[2]

		tab[len + 18] = endX
		tab[len + 19] = endY
		tab[len + 20] = colors[3]

		tab[0] = len + 20
	end
end

do
	---@type {[string] : IMesh}
	local cachedRectMeshes = {}
	local defaultMat = Material('vgui/white')

	--[[
		Purpose: draws Rectangle on screen.
		Params:
			x - startX (absolute screen position)
			y - startY (too)
			w - width
			h - height
			colors - color table (or just color).
				if table of colors is supplied, then it will be gradient one
					Basically, color per corner. order is: left top, right top, right bottom, left bottom
				if single color supplied, then will be solid color.
			u1, v1, u2, v2 - UV's
	-- ]]

	local format = string.format

	local meshConstructor = Mesh
	local meshDraw = FindMetaTable('IMesh')--[[@as IMesh]].Draw

	local renderSetMaterial = render.SetMaterial

	local generateRectMesh = rects.generateRectMesh

	-- why is it a standalone function?
	-- This GETS JIT compiled as it does not contain any C API code and it does not have %s in them
	-- It means string.format gets compiled as native code, and speed of that will be 100 faster than default
	-- Mastermind tricks?

	--- Function used to get id of rect's IMesh. Used as tricky optimisation to make it JIT compiled
	---@param x number
	---@param y number
	---@param w number
	---@param h number
	---@param color1 Color
	---@param color2 Color
	---@param color3 Color
	---@param color4 Color
	---@param u1 number
	---@param v1 number
	---@param u2 number
	---@param v2 number
	---@param skew number sets elevation for top side of rect.
	---@param topSize number overrides size for top side of rect
	---@return string
	local function getId(x, y, w, h, color1, color2, color3, color4, u1, v1, u2, v2, skew, topSize)
		return format('%u;%u;%u;%u;%x%x%x%x;%x%x%x%x;%x%x%x%x;%x%x%x%x;%f;%f;%f;%f;%f;%f',
			x, y, w, h,
			color1.r, color1.g, color1.b, color1.a,
			color2.r, color2.g, color2.b, color2.a,
			color3.r, color3.g, color3.b, color3.a,
			color4.r, color4.g, color4.b, color4.a,
			u1, v1, u2, v2, skew, topSize
		)
	end

	--- Draws single rect (quad)
	---@deprecated Internal variable. Not meant to use outside
	---@param x number
	---@param y number
	---@param w number
	---@param h number
	---@param colors gradients # Color or colors used by gradient. Can be a single color, or a table of colors
	---@param material? IMaterial
	---@param u1 number
	---@param v1 number
	---@param u2 number
	---@param v2 number
	---@param skew number? sets elevation for top side of rect.
	---@param topSize number? overrides size for top side of rect
	---@overload fun(x : number, y : number, w : number, h : number, colors: gradients, material?: Material)
	function rects.drawSingleRect(x, y, w, h, colors, material, u1, v1, u2, v2, skew, topSize)
		skew, topSize = skew or 0, topSize or 0

		local id = getId(x, y, w, h, colors[1], colors[2], colors[3], colors[4], u1, v1, u2, v2, skew, topSize)

		local mesh = cachedRectMeshes[id]
		if mesh == nil then
			mesh = meshConstructor()

			generateRectMesh(mesh, x, y, x + w, y + h, colors, u1, v1, u2, v2, skew, topSize)

			cachedRectMeshes[id] = mesh
		end

		renderSetMaterial(material or defaultMat)
		meshDraw(mesh)
	end

	timer.Create('PulsarUI.paint.rectMeshGarbageCollector', 60, 0, function()
		for k, v in pairs(cachedRectMeshes) do
			cachedRectMeshes[k] = nil
			v:Destroy()
		end
	end)
end

do --- Rect specific batching

	---Begins batching rectangles together to draw them all at once with greatly improved performance.
	---
	---This is primarily useful when drawing a large number of rectangles.
	---
	---All rectangles drawn after this function is called will be batched until stopBatching() is called.
	---
	---Note: Batching is not shared between different types of shapes.
	function rects.startBatching()
		rects.batching = {
			[0] = 0
		}
		rects.isBatching = true
	end

	local drawBatchedRects = rects.drawBatchedRects

	---Finishes batching rects and draws all rects created bny PulsarUI.paint.rects.drawRect since startBatching() was called.
	---@see rects.startBatching
	function rects.stopBatching()
		rects.isBatching = false

		drawBatchedRects(rects.batching)
	end

	--- Adds rect (quad) to quad batching queue (rects.startBatching)
	---@param x number
	---@param y number
	---@param w number
	---@param h number
	---@param colors Color[]
	function rects.drawQuadBatchedRect(x, y, w, h, colors)
		local tab = rects.batching
		local len = tab[0]

		tab[len + 1] = x
		tab[len + 2] = y
		tab[len + 3] = x + w
		tab[len + 4] = y + h
---@diagnostic disable-next-line: assign-type-mismatch
		tab[len + 5] = colors[1]
---@diagnostic disable-next-line: assign-type-mismatch
		tab[len + 6] = colors[2]
---@diagnostic disable-next-line: assign-type-mismatch
		tab[len + 7] = colors[3]
---@diagnostic disable-next-line: assign-type-mismatch
		tab[len + 8] = colors[4]

		tab[0] = len + 8
	end
end

do
	-- batching doesn't support materials at all!
	local drawSingleRect = rects.drawSingleRect
	local drawBatchedRect = rects.drawBatchedRect

	local drawQuadBatchedRect = rects.drawQuadBatchedRect

	local batch = PulsarUI.paint.batch

	--- Main function to draw rects
	---@param x number # start X position of the rectangle
	---@param y number # start Y position of the rectangle
	---@param w number # width of the rectangle
	---@param h number # height of the rectangle
	---@param colors gradients # Either a table of Colors, or a single Color.  
		---      If it is a table, it must have 4 elements, one for each corner.
		---
		---      The order of the corners is:
		---            1. Top-Left 
		---            2. Top-Right
		---            3. Bottom-Right 
		---            4. Bottom-Left
	---@param material? IMaterial # Either a Material, or nil.  Default: vgui/white
	---@param u1 number # The texture U coordinate of the Top-Left corner of the rectangle. Default : 0
	---@param v1 number # The texture V coordinate of the Top-Left corner of the rectangle. Default : 0
	---@param u2 number # The texture U coordinate of the Bottom-Right corner of the rectangle. Default : 1
	---@param v2 number # The texture V coordinate of the Bottom-Right corner of the rectangle. Default : 1
	---@param skew number? sets elevation for top side of rect.
	---@param topSize number? overrides size for top side of rect
	---@overload fun(x : number, y : number, w : number, h : number, colors: gradients, material? : IMaterial) # Overloaded variant without UV's. They are set to 0, 0, 1, 1
	function rects.drawRect(x, y, w, h, colors, material, u1, v1, u2, v2, skew, topSize)
		if colors[4] == nil then
			colors[1] = colors
			colors[2] = colors
			colors[3] = colors
			colors[4] = colors
		end

		if u1 == nil then
			u1, v1 = 0, 0
			u2, v2 = 1, 1
		end

		if batch.batching then
			drawBatchedRect(x, y, x + w, y + h, colors)
		else
			if rects.isBatching then
				drawQuadBatchedRect(x, y, w, h, colors)
			else
				drawSingleRect(x, y, w, h, colors, material, u1, v1, u2, v2, skew, topSize)
			end
		end
	end
end

PulsarUI.paint.rects = rects end do ---@diagnostic disable: deprecated

--What makes paint rounded boxes better than the draw library's rounded boxes?
--1) Support for per-corner gradients!
--2) Improved performance when drawing multiple rounded boxes, thanks to batching!
--3) Stencil support!
--4) Material support!
--5) Curviness support (squircles/superellipses support)
--
--Simple Example
--Drawing rounded boxes with different corner radius and colors.
--```lua
-- -- A colorful rounded box
-- PulsarUI.paint.roundedBoxes.roundedBox( 20, 5, 5, 64, 64, {
-- 	Color( 255, 0, 0 ), -- Top Left
-- 	Color( 0, 255, 0 ), -- Top Right
-- 	Color( 0, 0, 255 ), -- Bottom Right
-- 	color_white,	-- Bottom Left
-- 	color_black	-- Center
-- } )
-- -- An icon with rounded corners
-- PulsarUI.paint.roundedBoxes.roundedBox( 32, 72, 5, 64, 64, COLOR_WHITE, ( Material( "icon16/application_xp.png" ) ) )
--```
--
--Asymmetrical Example
--Drawing a rounded box with only the top-right and bottom-left corners rounded.
--```lua
--PulsarUI.paint.roundedBoxes.roundedBoxEx( 16, 10, 10, 64, 64, COLOR_WHITE, false, true, false, true )
--```
--
--Stencil Masked Example
--```lua
	-- local function mask(drawMask, draw)
	-- 	render.ClearStencil()
	-- 	render.SetStencilEnable(true)
	--
	-- 	render.SetStencilWriteMask(1)
	-- 	render.SetStencilTestMask(1)
	--
	-- 	render.SetStencilFailOperation(STENCIL_REPLACE)
	-- 	render.SetStencilPassOperation( STENCIL_REPLACE)
	-- 	render.SetStencilZFailOperation(STENCIL_KEEP)
	-- 	render.SetStencilCompareFunction(STENCIL_ALWAYS)
	-- 	render.SetStencilReferenceValue(1)
	--
	-- 	drawMask()
	--
	-- 	render.SetStencilFailOperation(STENCIL_KEEP)
	-- 	render.SetStencilPassOperation(STENCIL_REPLACE)
	-- 	render.SetStencilZFailOperation(STENCIL_KEEP)
	-- 	render.SetStencilCompareFunction(STENCIL_EQUAL)
	-- 	render.SetStencilReferenceValue(1)
	--
	-- 	draw()
	--
	-- 	render.SetStencilEnable(false)
	-- 	render.ClearStencil()
	-- end
	--
	-- local RIPPLE_DIE_TIME = 1
	-- local RIPPLE_START_ALPHA = 50
	--
	-- function button:Paint(w, h)
	-- 	PulsarUI.paint.startPanel(self)
	-- 		mask(function()
	-- 			PulsarUI.paint.roundedBoxes.roundedBox( 32, 0, 0, w, h, COLOR_RED )
	-- 		end,
	-- 		function()
	-- 			local ripple = self.rippleEffect
	--
	-- 			if ripple == nil then return end
	--
	-- 			local rippleX, rippleY, rippleStartTime = ripple[1], ripple[2], ripple[3]
	--
	-- 			local percent = (RealTime() - rippleStartTime)  / RIPPLE_DIE_TIME
	--
	-- 			if percent >= 1 then
	-- 				self.rippleEffect = nil
	-- 			else
	-- 				local alpha = RIPPLE_START_ALPHA * (1 - percent)
	-- 				local radius = math.max(w, h) * percent * math.sqrt(2)
	--
	-- 				PulsarUI.paint.roundedBoxes.roundedBox(radius, rippleX - radius, rippleY - radius, radius * 2, radius * 2, ColorAlpha(COLOR_WHITE, alpha))
	-- 			end
	-- 		end)
	-- 	PulsarUI.paint.endPanel()
	-- end
--```
--
--Animated Rainbow Colors Example
--Drawing a rounded box with a rainbow gradient.
--```lua
-- local time1, time2 = RealTime() * 100, RealTime() * 100 + 30
-- local time3 = (time1 + time2) / 2
--
-- local color1, color2, color3 = HSVToColor(time1, 1, 1), HSVToColor(time2, 1, 1), HSVToColor(time3, 1, 1)
--
-- PulsarUI.paint.roundedBoxes.roundedBox(32, 10, 10, 300, 128, {color1, color3, color2, color3})
-- -- Center is color3 not nil because interpolating between colors and between HSV is different
--```
---@class roundedBoxes
local roundedBoxes = {}

---@alias createVertexFunc fun(x : number, y : number, u : number, v: number, colors : Color[], u1 : number, v1 : number, u2 : number, v2 : number)

do
	-- NOTE: it's likely implied that radius cant be 0, and can't be higher than width / 2 or height / 2
	local meshBegin = mesh.Begin
	local meshEnd = mesh.End

	local PRIMITIVE_POLYGON = MATERIAL_POLYGON
	local clamp = math.Clamp
	local halfPi = math.pi / 2

	local sin = math.sin
	local cos = math.cos

	---@param num number
	---@param power number
	---@return number
	local function fpow(num, power)
		if num > 0 then
			return num ^ power
		else
			return -((-num) ^ power)
		end
	end

	---@param radius number
	---@param rightTop boolean?
	---@param rightBottom boolean?
	---@param leftBottom boolean?
	---@param leftTop boolean?
	---@return integer vertex count 
	function roundedBoxes.getMeshVertexCount(radius, rightTop, rightBottom, leftBottom, leftTop)
		if radius > 3 then
			local vertsPerEdge = clamp(radius / 2, 3, 24)
			return 6
				+ (rightTop and vertsPerEdge or 0)
				+ (rightBottom and vertsPerEdge or 0)
				+ (leftBottom and vertsPerEdge or 0)
				+ (leftTop and vertsPerEdge or 0)
		else
			return 6
				+ (rightTop and 1 or 0)
				+ (rightBottom and 1 or 0)
				+ (leftBottom and 1 or 0)
				+ (leftTop and 1 or 0)
		end
	end

	local getMeshVertexCount = roundedBoxes.getMeshVertexCount

	---@type Color[]
	local centreTab = {}
	--- Generates roundedBox mesh, used by outlines, 
	---@param createVertex createVertexFunc # function used to create vertex.
	---@param mesh? IMesh
	---@param radius number
	---@param x number
	---@param y number
	---@param endX number
	---@param endY number
	---@param leftTop? boolean
	---@param rightTop? boolean
	---@param rightBottom? boolean
	---@param leftBottom? boolean
	---@param colors Color[]
	---@param u1 number
	---@param v1 number
	---@param u2 number
	---@param v2 number
	---@param curviness number?
	---@deprecated Internal variable. Not meant to use outside
	function roundedBoxes.generateSingleMesh(createVertex, mesh, radius, x, y, endX, endY, leftTop, rightTop, rightBottom, leftBottom, colors, u1, v1, u2, v2, curviness)
		local vertsPerEdge = clamp(radius / 2, 3, 24)

		local isRadiusBig = radius > 3

		curviness = 2 / (curviness or 2)

		local w, h = endX - x, endY - y

		if mesh then
			meshBegin(mesh, PRIMITIVE_POLYGON, getMeshVertexCount(radius, rightTop, rightBottom, leftBottom, leftTop))
		end

			local fifthColor = colors[5]
			if fifthColor == nil then
				createVertex((x + endX) * 0.5, (y + endY) * 0.5, 0.5, 0.5, colors, u1, v1, u2, v2)
			else
				centreTab[1], centreTab[2], centreTab[3], centreTab[4] = fifthColor, fifthColor, fifthColor, fifthColor
				createVertex((x + endX) * 0.5, (y + endY) * 0.5, 0.5, 0.5, centreTab, u1, v1, u2, v2)
			end

			createVertex(x + (leftTop and radius or 0), y, (leftTop and radius or 0) / w, 0, colors, u1, v1, u2, v2)

			createVertex(endX - (rightTop and radius or 0), y, 1 - (rightTop and radius or 0) / w, 0, colors, u1, v1, u2, v2)
			-- 3 vertices

			if rightTop then
				if isRadiusBig then
					local deltaX = endX - radius
					local deltaY = y + radius

					for i = 1, vertsPerEdge - 1 do
						local angle = halfPi * (i / vertsPerEdge)

						local sinn, coss = fpow(sin(angle), curviness), fpow(cos(angle), curviness)

						local newX, newY = deltaX + sinn * radius, deltaY - coss * radius

						createVertex(newX, newY, 1 - (1-sinn) * radius / w, ( 1 - coss) * radius / h, colors, u1, v1, u2, v2 )
					end
				end

				createVertex(endX, y + radius, 1, radius / h, colors, u1, v1, u2, v2)
			end

			createVertex(endX, endY - (rightBottom and radius or 0), 1, 1 - (rightBottom and radius or 0) / h, colors, u1, v1, u2, v2)

			if rightBottom then
				if isRadiusBig then
					local deltaX = endX - radius
					local deltaY = endY - radius

					for i = 1, vertsPerEdge - 1 do
						local angle = halfPi * (i / vertsPerEdge)

						local sinn, coss = fpow(sin(angle), curviness), fpow(cos(angle), curviness)

						local newX, newY = deltaX + coss * radius, deltaY + sinn * radius

						createVertex(newX, newY, 1 - ((1 - coss) * radius) / w, 1 - ( (1 - sinn) * radius ) / h, colors, u1, v1, u2, v2)
					end
				end

				createVertex(endX - radius, endY, 1 - radius / w, 1, colors, u1, v1, u2, v2)
			end

			createVertex(x + (leftBottom and radius or 0), endY, (leftBottom and radius or 0) / w, 1, colors, u1, v1, u2, v2)

			if leftBottom then
				if isRadiusBig then
					local deltaX = x + radius
					local deltaY = endY - radius

					for i = 1, vertsPerEdge - 1 do
						local angle = halfPi * (i / vertsPerEdge)

						local sinn, coss = fpow(sin(angle), curviness), fpow(cos(angle), curviness)

						local newX, newY = deltaX - sinn * radius, deltaY + coss * radius

						createVertex(newX, newY, (1 - sinn) * radius / w, 1 - (1 - coss) * radius / h, colors, u1, v1, u2, v2)
					end
				end

				createVertex(x, endY - radius, 0, 1 - radius / h, colors, u1, v1, u2, v2)
			end

			createVertex(x, y + (leftTop and radius or 0), 0, (leftTop and radius or 0) / h, colors, u1, v1, u2, v2)

			if leftTop then
				if isRadiusBig then
					local deltaX = x + radius
					local deltaY = y + radius

					for i = 1, vertsPerEdge - 1 do
						local angle = halfPi * (i / vertsPerEdge)

						local sinn, coss = fpow(sin(angle), curviness), fpow(cos(angle), curviness)

						local newX, newY = deltaX - coss * radius, deltaY - sinn * radius

						createVertex(newX, newY, (1 - coss) * radius / w, (1 - sinn) * radius / h, colors, u1, v1, u2, v2)
					end
				end

				createVertex(x + radius, y, radius / w, 0, colors, u1, v1, u2, v2)
			end

		if mesh then
			meshEnd()
		end
	end
end

do
	local meshPosition = mesh.Position
	local meshColor = mesh.Color
	local meshAdvanceVertex = mesh.AdvanceVertex
	local meshTexCoord = mesh.TexCoord

---@diagnostic disable-next-line: deprecated
	local bilinearInterpolation = PulsarUI.paint.bilinearInterpolation

	---Internal function used in pair with mesh.Begin(PRIMITIVE_POLYGON). Used for single batched rounded boxes.
	---@type createVertexFunc
	local function createVertex(x, y, u, v, colors, u1, v1, u2, v2)
		local leftTop, rightTop, rightBottom, leftBottom = colors[1], colors[2], colors[3], colors[4]
		meshPosition(x, y, 0)
		meshTexCoord(0, u * (u2 - u1) + u1, v * (v2 - v1) + v1)
		meshColor(
			bilinearInterpolation(u, v, leftTop.r, rightTop.r, rightBottom.r, leftBottom.r),
			bilinearInterpolation(u, v, leftTop.g, rightTop.g, rightBottom.g, leftBottom.g),
			bilinearInterpolation(u, v, leftTop.b, rightTop.b, rightBottom.b, leftBottom.b),
			bilinearInterpolation(u, v, leftTop.a, rightTop.a, rightBottom.a, leftBottom.a)
		)

		meshAdvanceVertex()
	end


	local meshConstructor = Mesh
	local meshDraw = FindMetaTable('IMesh')--[[@as IMesh]].Draw

	local format = string.format

	local setMaterial = render.SetMaterial

	local matrix = Matrix()
	local setField = matrix.SetField

	local pushModelMatrix = cam.PushModelMatrix
	local popModelMatrix = cam.PopModelMatrix

	local generateSingleMesh = roundedBoxes.generateSingleMesh

	--- Helper function to get ID
	---@param radius number
	---@param w number
	---@param h number
	---@param corners number
	---@param colors Color[]
	---@param u1 number
	---@param v1 number
	---@param u2 number
	---@param v2 number
	---@param curviness number
	---@return string id
	local function getId(radius, w, h, corners, colors, u1, v1, u2, v2, curviness)
		local color1, color2, color3, color4, color5 = colors[1], colors[2], colors[3], colors[4], colors[5]

		if color5 == nil then
			return format('%u;%u;%u;%u;%x%x%x%x;%x%x%x%x;%x%x%x%x;%x%x%x%x;%f;%f;%f;%f;%f',
				radius, w, h, corners,
				color1.r, color1.g, color1.b, color1.a,
				color2.r, color2.g, color2.b, color2.a,
				color3.r, color3.g, color3.b, color3.a,
				color4.r, color4.g, color4.b, color4.a,
				u1, v1, u2, v2, curviness
			)
		else
			return format('%u;%u;%u;%u;%x%x%x%x;%x%x%x%x;%x%x%x%x;%x%x%x%x;%x%x%x%x;%f;%f;%f;%f;%f',
				radius, w, h, corners,
				color1.r, color1.g, color1.b, color1.a,
				color2.r, color2.g, color2.b, color2.a,
				color3.r, color3.g, color3.b, color3.a,
				color4.r, color4.g, color4.b, color4.a,
				color5.r, color5.g, color5.b, color5.a,
				u1, v1, u2, v2, curviness
			)
		end

	end

	---@type table<string, IMesh>
	local cachedRoundedBoxMeshes = {}

	--- Draws single unbached rounded box
	---@param radius number
	---@param x number
	---@param y number
	---@param w number
	---@param h number
	---@param colors Color[]
	---@param leftTop? boolean
	---@param rightTop? boolean
	---@param rightBottom? boolean
	---@param leftBottom? boolean
	---@param material IMaterial
	---@param u1 number
	---@param v1 number
	---@param u2 number
	---@param v2 number
	---@param curviness number?
	---@deprecated Internal variable. Not meant to use outside
	function roundedBoxes.roundedBoxExSingle(radius, x, y, w, h, colors, leftTop, rightTop, rightBottom, leftBottom, material, u1, v1, u2, v2, curviness)
		curviness = curviness or 2
		local id = getId(radius, w, h, (leftTop and 8 or 0) + (rightTop and 4 or 0) + (rightBottom and 2 or 0) + (leftBottom and 1 or 0), colors, u1, v1, u2, v2, curviness)

		local meshObj = cachedRoundedBoxMeshes[id]

		if meshObj == nil then
			meshObj = meshConstructor()
			generateSingleMesh(createVertex, meshObj, radius, 0, 0, w, h, leftTop, rightTop, rightBottom, leftBottom, colors, u1, v1, u2, v2, curviness)

			cachedRoundedBoxMeshes[id] = meshObj
		end

		setField(matrix, 1, 4, x)
		setField(matrix, 2, 4, y)

		pushModelMatrix(matrix, true)
			setMaterial(material)
			meshDraw(meshObj)
		popModelMatrix()
	end

	timer.Create('PulsarUI.paint.roundedBoxesGarbageCollector', 60, 0, function()
		for k, v in pairs(cachedRoundedBoxMeshes) do
			v:Destroy()
			cachedRoundedBoxMeshes[k] = nil
		end
	end)
end

do
	---@type {[1] : number, [2]:number, [3]: Color, [4] : number} | nil
	local prev1
	---@type {[1] : number, [2] : number, [3] : Color} | nil
	local prev2 = {}

	local batch = PulsarUI.paint.batch
	local incrementZ = PulsarUI.paint.incrementZ

	local color = Color
	local bilinearInterpolation = PulsarUI.paint.bilinearInterpolation

	---@type createVertexFunc
	local function createVertex(x, y, u, v, colors)
		if prev1 == nil then
			local z = incrementZ()
			local blendedColor = color(
				(colors[1].r + colors[2].r + colors[3].r + colors[4].r) / 4,
				(colors[1].g + colors[2].g + colors[3].g + colors[4].g) / 4,
				(colors[1].b + colors[2].b + colors[3].b + colors[4].b) / 4,
				(colors[1].a + colors[2].a + colors[3].a + colors[4].a) / 4
			)

			prev1 = {x, y, blendedColor, z}
			return
		end

		---@type Color
		local prefferedColor = color(
			bilinearInterpolation(u, v, colors[1].r, colors[2].r, colors[3].r, colors[4].r),
			bilinearInterpolation(u, v, colors[1].g, colors[2].g, colors[3].g, colors[4].g),
			bilinearInterpolation(u, v, colors[1].b, colors[2].b, colors[3].b, colors[4].b),
			bilinearInterpolation(u, v, colors[1].a, colors[2].a, colors[3].a, colors[4].a)
		)
		if prev2 == nil then
			prev2 = {x, y, prefferedColor}
			return
		end

		---@type table
		local batchTable = batch.batchTable

		local len = batchTable[0]
		batchTable[len + 1] = prev1[1]
		batchTable[len + 2] = prev1[2]
		batchTable[len + 3] = prev1[4]
		batchTable[len + 4] = prev1[3]

		batchTable[len + 5] = prev2[1]
		batchTable[len + 6] = prev2[2]
		batchTable[len + 7] = prev2[3]

		batchTable[len + 8] = x
		batchTable[len + 9] = y
		batchTable[len + 10] = prefferedColor

		batchTable[0] = len + 10

		prev2[1] = x
		prev2[2] = y
		prev2[3] = prefferedColor
	end

	local generateSingleMesh = roundedBoxes.generateSingleMesh

	--- Adds rounded box to batched queue
	---@param radius number
	---@param x number
	---@param y number
	---@param w number
	---@param colors Color[]
	---@param leftTop? boolean
	---@param rightTop? boolean
	---@param rightBottom? boolean
	---@param leftBottom? boolean
	---@param curviness number?
	---@deprecated Internal variable. Not meant to use outside
	function roundedBoxes.roundedBoxExBatched(radius, x, y, w, h, colors, leftTop, rightTop, rightBottom, leftBottom, curviness)
		prev1 = nil
		prev2 = nil
		generateSingleMesh(createVertex, nil, radius, x, y, x + w, y + h, leftTop, rightTop, rightBottom, leftBottom, colors, 0, 0, 1, 1, curviness)
	end
end

do
	local defaultMat = Material('vgui/white')

	local roundedBoxExSingle = roundedBoxes.roundedBoxExSingle
	local roundedBoxExBatched = roundedBoxes.roundedBoxExBatched

	local batch = PulsarUI.paint.batch

	-- Identical to roundedBox other than that it allows you to specify specific corners to be rounded.
	-- For brevity, arguments duplicated from roundedBox are not repeated here.
	---@param radius number # radius of the rounded corners
	---@param x number #start X position of rounded box (upper left corner)
	---@param y number #start X position of rounded box (upper left corner)
	---@param w number #width of rounded box
	---@param h number #height of rounded box
	---@param colors gradients #colors of rounded box. Either a table of Colors, or a single Color.
	---@param material? IMaterial #Either a Material, or nil.  Default: vgui/white
	---@param u1 number #The texture U coordinate of the Top-Left corner of the rounded box.
	---@param v1 number #The texture V coordinate of the Top-Left corner of the rounded box.
	---@param u2 number #The texture U coordinate of the Bottom-Right corner of the rounded box.
	---@param v2 number #The texture V coordinate of the Bottom-Right corner of the rounded box.
	---@param curviness number? Curviness of rounded box. Default is 2. Makes rounded box behave as with formula ``x^curviness+y^curviness=radius^curviness`` (this is circle formula btw. Rounded boxes are superellipses)
	---@overload fun(radius : number, x : number, y : number, w : number, h : number, colors : gradients, material? : IMaterial)
	---@param leftTop? boolean
	---@param rightTop? boolean
	---@param rightBottom? boolean
	---@param leftBottom? boolean
	---@overload fun(radius : number, x : number, y : number, w : number, h : number, colors : gradients, leftTop? : boolean, rightTop? : boolean, rightBottom? : boolean, leftBottom? : boolean, material? : IMaterial)
	function roundedBoxes.roundedBoxEx(radius, x, y, w, h, colors, leftTop, rightTop, rightBottom, leftBottom, material, u1, v1, u2, v2, curviness)
		if colors[4] == nil then
			colors[1] = colors
			colors[2] = colors
			colors[3] = colors
			colors[4] = colors
		end

		if u1 == nil then
			u1, v1, u2, v2 = 0, 0, 1, 1
		end

		curviness = curviness or 2

		if radius == 0 then
			leftTop, rightTop, rightBottom, leftBottom = false, false, false, false
		end

		material = material or defaultMat

		if batch.batching then
			roundedBoxExBatched(radius, x, y, w, h, colors, leftTop, rightTop, rightBottom, leftBottom, curviness)
		else
			roundedBoxExSingle(radius, x, y, w, h, colors, leftTop, rightTop, rightBottom, leftBottom, material, u1, v1, u2, v2, curviness)
		end
	end

	local roundedBoxEx = roundedBoxes.roundedBoxEx

	---Draws a rounded box with the specified parameters.
	---@param radius number # radius of the rounded corners
	---@param x number #start X position of rounded box (upper left corner)
	---@param y number #start X position of rounded box (upper left corner)
	---@param w number #width of rounded box
	---@param h number #height of rounded box
	---@param colors gradients #colors of rounded box. Either a table of Colors, or a single Color.
	---@param material? IMaterial #Either a Material, or nil.  Default: vgui/white
	---@param u1 number #The texture U coordinate of the Top-Left corner of the rounded box.
	---@param v1 number #The texture V coordinate of the Top-Left corner of the rounded box.
	---@param u2 number #The texture U coordinate of the Bottom-Right corner of the rounded box.
	---@param v2 number #The texture V coordinate of the Bottom-Right corner of the rounded box.
	---@param curviness number? Curviness of rounded box. Default is 2. Makes rounded box behave as with formula ``x^curviness+y^curviness=radius^curviness`` (this is circle formula btw. Rounded boxes are superellipses)
	---@overload fun(radius : number, x : number, y : number, w : number, h : number, colors : gradients, material? : IMaterial)
	---@overload fun(radius : number, x : number, y : number, w : number, h : number, colors : gradients, material? : IMaterial, _ : nil, _ : nil, _: nil, _: nil, curviness : number)
	function roundedBoxes.roundedBox(radius, x, y, w, h, colors, material, u1, v1, u2, v2, curviness)
		roundedBoxEx(radius, x, y, w, h, colors, true, true, true, true, material, u1, v1, u2, v2, curviness)
	end
end

do
	local generateSingleMesh = roundedBoxes.generateSingleMesh
	local createdTable
	local len

	local function createVertex(x, y, u, v, _, u1, v1, u2, v2)
		if createdTable == nil then return end

		len = len + 1
		createdTable[len] = {x = x, y = y, u = u1 + u * (u2 - u1), v = v1 + v * (v2 - v1)}
	end

	local emptyTab = {} -- We do not use colors, so fuck them and place empty table here

	---@param radius number
	---@param x number
	---@param y number
	---@param w number
	---@param h number
	---@param leftTop boolean?
	---@param rightTop  boolean?
	---@param rightBottom boolean?
	---@param leftBottom boolean?
	---@param u1 number
	---@param v1 number
	---@param u2 number
	---@param v2 number
	---@param curviness number? Curviness of rounded box. Default is 2. Makes rounded box behave as with formula ``x^curviness+y^curviness=radius^curviness`` (this is circle formula btw. Rounded boxes are superellipses)
	function roundedBoxes.generateDrawPoly(radius, x, y, w, h, leftTop, rightTop, rightBottom, leftBottom, u1, v1, u2, v2, curviness)
		createdTable = {}
		len = 0
		generateSingleMesh(createVertex, nil, radius, x, y, w, h, leftTop, rightTop, rightBottom, leftBottom, emptyTab, u1, v1, u2, v2, curviness)

		local tab = createdTable

		createdTable = nil
		len = nil
		return tab
	end
end

PulsarUI.paint.roundedBoxes = roundedBoxes end do ---@diagnostic disable: deprecated

--```
--What makes paint outlines better than stencils:
--1) Support for materials!
--2) Support for gradients within the outline!
--3) Curviness!
--```
--# Simple example:
---
--Drawing outlines with different thicknesses on each side.
--```lua
--PulsarUI.paint.outlines.drawOutline( 32, 16, 10, 64, 64, { COLOR_WHITE, COLOR_BLACK }, nil, 8 )
--PulsarUI.paint.outlines.drawOutline( 32, 102, 10, 64, 64, { COLOR_WHITE, color_transparent }, nil, 8 )
--PulsarUI.paint.outlines.drawOutline( 32, 192, 10, 64, 64, { COLOR_BLACK, ColorAlpha( COLOR_BLACK, 0 ) }, nil, 8 )
---```
---# Asymmetrical Example
---
---Drawing outlines with a different inner and outer color.
---```lua
-- PulsarUI.paint.outlines.drawOutline( 32, 16, 10, 64, 64, { COLOR_WHITE, COLOR_BLACK }, nil, 8 )
-- PulsarUI.paint.outlines.drawOutline( 32, 102, 10, 64, 64, { COLOR_WHITE, color_transparent }, nil, 8 )
-- PulsarUI.paint.outlines.drawOutline( 32, 192, 10, 64, 64, { COLOR_BLACK, ColorAlpha( COLOR_BLACK, 0 ) }, nil, 8 )
---```
---# Draw Outline Animated Gradient Example
---
---Drawing an animated, colorful outline with a gradient.
---```lua
-- local color1, color2 = HSVToColor( RealTime() * 120, 1, 1 ), HSVToColor( RealTime() * 120 + 30, 1, 1 )
-- PulsarUI.paint.outlines.drawOutline( 32, 32, 18, 64, 64, { color1, color2 }, nil, 16 )
---```
---@class outlines
local outlines = {}

do
	local meshPosition = mesh.Position
	local meshColor = mesh.Color
	local meshTexCoord = mesh.TexCoord
	local meshAdvanceVertex = mesh.AdvanceVertex

	---@type boolean
	local isFirst = true
	---@type number?
	local prevU
	---@type boolean?
	local isInside

	---@type number
	local outlineLeft = 0
	---@type number
	local outlineRight = 0
	---@type number
	local outlineTop = 0
	---@type number
	local outlineBottom = 0

	local atan2 = math.atan2

	---@type createVertexFunc
	local function createVertex(x, y, u, v, colors)
		if isFirst then
			isFirst = false
			return
		end

		local texU = 1 - (atan2( (1 - v) - 0.5, u - 0.5) / (2 * math.pi) + 0.5)

		if prevU and prevU > texU then
			texU = texU + 1
		else
			prevU = texU
		end


		local newX, newY

		if u < 0.5 then
			newX = x - outlineLeft * ((1 - u) - 0.5) * 2
		elseif u ~= 0.5 then
			newX = x + outlineRight * (u - 0.5) * 2
		else
			newX = x
		end

		if v < 0.5 then
			newY = y - outlineTop * ((1 - v) - 0.5) * 2
		elseif v ~= 0.5 then
			newY = y + outlineBottom * (v - 0.5) * 2
		else
			newY = y
		end

		if isInside then
			meshPosition(newX, newY, 0)
			meshColor(colors[2].r, colors[2].g, colors[2].b, colors[2].a)
			meshTexCoord(0, texU, 0.02)
			meshAdvanceVertex()

			meshPosition(x, y, 0)
			meshColor(colors[1].r, colors[1].g, colors[1].b, colors[1].a)
			meshTexCoord(0, texU, 1)
			meshAdvanceVertex()
		else
			meshPosition(x, y, 0)
			meshColor(colors[1].r, colors[1].g, colors[1].b, colors[1].a)
			meshTexCoord(0, texU, 1)
			meshAdvanceVertex()

			meshPosition(newX, newY, 0)
			meshColor(colors[2].r, colors[2].g, colors[2].b, colors[2].a)
			meshTexCoord(0, texU, 0.02)
			meshAdvanceVertex()
		end
	end

	local generateSingleMesh = PulsarUI.paint.roundedBoxes.generateSingleMesh

	local meshBegin = mesh.Begin
	local meshEnd = mesh.End


	local PRIMITIVE_TRIANGLE_STRIP = MATERIAL_TRIANGLE_STRIP

	local getMeshVertexCount = PulsarUI.paint.roundedBoxes.getMeshVertexCount
	--- draw single outline

	--- Generates outline mesh
	---@param mesh IMesh
	---@param radius number
	---@param x number
	---@param y number
	---@param w number
	---@param h number
	---@param leftTop? boolean
	---@param rightTop? boolean
	---@param rightBottom? boolean
	---@param leftBottom? boolean
	---@param colors {[1]: Color, [2]: Color}
	---@param l number
	---@param t number
	---@param r number
	---@param b number
	---@param curviness number?
	---@param inside boolean?
	---@deprecated Internal variable, not meant to be used outside.
	function outlines.generateOutlineSingle(mesh, radius, x, y, w, h, leftTop, rightTop, rightBottom, leftBottom, colors, l, t, r, b, curviness, inside)
		isInside = inside or false
		outlineTop, outlineRight, outlineBottom, outlineLeft = t or 0, r or 0, b or 0, l or 0
		curviness = curviness or 2

		isFirst = true
		prevU = nil

		meshBegin(mesh, PRIMITIVE_TRIANGLE_STRIP, getMeshVertexCount(radius, rightTop, rightBottom, leftBottom, leftTop) * 2)
			generateSingleMesh(createVertex, nil, radius, x, y, w, h, leftTop, rightTop, rightBottom, leftBottom, colors, 0, 0, 1, 1, curviness)
		meshEnd()
	end
end

do
	---@type {[string]: IMesh}
	local cachedOutlinedMeshes = {}

	local format = string.format
	--- Helper function to get id
	---@param radius number
	---@param w number
	---@param h number
	---@param corners number
	---@param color1 Color
	---@param color2 Color
	---@param l number
	---@param t number
	---@param r number
	---@param b number
	---@param curviness number?
	---@param inside boolean?
	---@return string id
	local function getId(radius, w, h, corners, color1, color2, l, t, r, b, curviness, inside)
		return format('%u;%u;%u;%u;%x%x%x%x;%x%x%x%x;%u;%u;%u;%u;%f;%u',
			radius, w, h, corners,
			color1.r, color1.g, color1.b, color1.a,
			color2.r, color2.g, color2.b, color2.a,
			l, t, r, b, curviness or 2, inside and 1 or 0
		)
	end

	local pushModelMatrix = cam.PushModelMatrix
	local popModelMatrix = cam.PopModelMatrix

	local meshConstructor = Mesh
	local generateOutlineSingle = outlines.generateOutlineSingle

	local matrix = Matrix()
	local setField = matrix.SetField

	local setMaterial = render.SetMaterial
	local defaultMat = Material('vgui/white')

	local meshDraw = FindMetaTable('IMesh')--[[@as IMesh]].Draw

	---Draws outline. Unbatched
	---@param radius number
	---@param x number
	---@param y number
	---@param w number
	---@param h number
	---@param leftTop? boolean
	---@param rightTop? boolean
	---@param rightBottom? boolean
	---@param leftBottom? boolean
	---@param colors {[1]: Color, [2]: Color}
	---@param material? IMaterial # Default material is vgui/white
	---@param l number
	---@param t number
	---@param r number
	---@param b number
	---@param curviness number?
	---@param inside boolean
	---@overload fun(radius : number, x : number, y : number, w : number, h : number, leftTop? : boolean, rightTop? : boolean, rightBottom? : boolean, leftBottom? : boolean, colors: Color[], material?: IMaterial, outlineThickness: number)
	---@overload fun(radius : number, x : number, y : number, w : number, h : number, leftTop? : boolean, rightTop? : boolean, rightBottom? : boolean, leftBottom? : boolean, colors: Color[], material?: IMaterial, outlineWidth: number, outlineHeight: number)
	function outlines.drawOutlineSingle(radius, x, y, w, h, leftTop, rightTop, rightBottom, leftBottom, colors, material, l, t, r, b, curviness, inside)
		curviness = curviness or 2
		inside = inside or false

		local id = getId(radius, w, h, (leftTop and 8 or 0) + (rightTop and 4 or 0) + (rightBottom and 2 or 0) + (leftBottom and 1 or 0), colors[1], colors[2], l, t, r, b, curviness, inside)

		local meshObj = cachedOutlinedMeshes[id]

		if meshObj == nil then
			meshObj = meshConstructor()
			generateOutlineSingle(meshObj, radius, 0, 0, w, h, leftTop, rightTop, rightBottom, leftBottom, colors, l, t, r, b, curviness, inside)

			cachedOutlinedMeshes[id] = meshObj
		end

		setField(matrix, 1, 4, x)
		setField(matrix, 2, 4, y)

		pushModelMatrix(matrix, true)
			setMaterial(material or defaultMat)
			meshDraw(meshObj)
		popModelMatrix()
	end

	timer.Create('PulsarUI.paint.outlinesGarbageCollector', 60, 0, function()
		for k, v in pairs(cachedOutlinedMeshes) do
			v:Destroy()
			cachedOutlinedMeshes[k] = nil
		end
	end)
end

do
	local generateSingleMesh = PulsarUI.paint.roundedBoxes.generateSingleMesh

	---@type number?, number?, number?, number?
	local outlineL, outlineT, outlineR, outlineB -- use it to get outline widths per side
	---@type boolean?
	local first -- to skip first vertex since it is center of rounded box
	---@type number?, number?, number?, number?
	local prevX, prevY, prevU, prevV
	---@type number?
	local z

	local isInside

	local batch = PulsarUI.paint.batch

	---@param x number
	---@param y number
	---@param u number
	---@param v number
	---@param colors {[1] : Color, [2]: Color}
	local function createVertex(x, y, u, v, colors)
		if first then
			first = false
			return
		elseif first == false then
			prevX, prevY, prevU, prevV = x, y, u, v
			first = nil
			return
		end

		local batchTable = batch.batchTable
		local len = batchTable[0]

		local color1, color2 = colors[1], colors[2]

		batchTable[len + 1] = prevX
		batchTable[len + 2] = prevY
		batchTable[len + 3] = z
		batchTable[len + 4] = color1

		do -- make some calculations to get outer border
			if prevU < 0.5 then
				prevX = prevX - outlineL * ((1 - prevU) - 0.5) * 2
			elseif prevU ~= 0.5 then
				prevX = prevX + outlineR * (prevU - 0.5) * 2
			end

			if prevV < 0.5 then
				prevY = prevY - outlineT * ((1 - prevV) - 0.5) * 2
			elseif prevV ~= 0.5 then
				prevY = prevY + outlineB * (prevV - 0.5) * 2
			end
		end

		batchTable[len + 5] = prevX
		batchTable[len + 6] = prevY
		batchTable[len + 7] = color2

		batchTable[len + 8] = x
		batchTable[len + 9] = y
		batchTable[len + 10] = color1

		batchTable[len + 11] = x
		batchTable[len + 12] = y
		batchTable[len + 13] = z
		batchTable[len + 14] = color1

		batchTable[len + 15] = prevX
		batchTable[len + 16] = prevY
		batchTable[len + 17] = color2

		prevX, prevY, prevU, prevV = x, y, u, v
		do
			if u < 0.5 then
				x = x - outlineL * ((1 - u) - 0.5) * 2
			elseif u ~= 0.5 then
				x = x + outlineR * (u - 0.5) * 2
			end

			if v < 0.5 then
				y = y - outlineT * ((1 - v) - 0.5) * 2
			elseif v ~= 0.5 then
				y = y + outlineB * (v - 0.5) * 2
			end
		end

		batchTable[len + 18] = x
		batchTable[len + 19] = y
		batchTable[len + 20] = color2

		batchTable[0] = len + 20
	end

	local incrementZ = PulsarUI.paint.incrementZ

	---Draws outline. Batched
	---@param radius number
	---@param x number
	---@param y number
	---@param w number
	---@param h number
	---@param leftTop? boolean
	---@param rightTop? boolean
	---@param rightBottom? boolean
	---@param leftBottom? boolean
	---@param colors {[1]: Color, [2]: Color}
	---@param l number
	---@param t number
	---@param r number
	---@param b number
	---@param curviness number?
	---@param inside boolean?
	function outlines.drawOutlineBatched(radius, x, y, w, h, leftTop, rightTop, rightBottom, leftBottom, colors, _, l, t, r, b, curviness, inside)
		outlineL, outlineT, outlineR, outlineB = l, t, r, b
		first = true
		curviness = curviness or 2

		isInside = inside or false

		z = incrementZ()
		generateSingleMesh(createVertex, nil, radius, x, y, x + w, y + h, leftTop, rightTop, rightBottom, leftBottom, colors, 0, 0, 1, 1, curviness)
	end
end

do
	local batch = PulsarUI.paint.batch
	local drawOutlineSingle = outlines.drawOutlineSingle
	local drawOutlineBatched = outlines.drawOutlineBatched

	---Identical to drawOutline other than that it allows you to specify specific corners to be rounded.
	---@param radius number
	---@param x number start X position of outline
	---@param y number start Y position of outline
	---@param w number width of outline
	---@param h number height of outline
	---@param colors linearGradient Colors of outline. Either a color, or table with 2 colors inside.
	---@param material? IMaterial # Default material is vgui/white
	---@param leftTop? boolean
	---@param rightTop? boolean
	---@param rightBottom? boolean
	---@param leftBottom? boolean
	---@param l number Left outline width
	---@param t number Top outline width 
	---@param r number Right outline width
	---@param b number Botton outline width
	---@param curviness number? Curviness of rounded box. Default is 2. Makes rounded box behave as with formula ``x^curviness+y^curviness=radius^curviness`` (this is circle formula btw. Rounded boxes are superellipses)
	---@param inside boolean? Revert vertex order to make outlines visible only on inside (when outline thickness is below 0.). Default - false
	---@overload fun(radius : number, x : number, y : number, w : number, h : number, leftTop? : boolean, rightTop? : boolean, rightBottom? : boolean, leftBottom? : boolean, colors: Color[], material?: IMaterial, outlineThickness: number)
	---@overload fun(radius : number, x : number, y : number, w : number, h : number, leftTop? : boolean, rightTop? : boolean, rightBottom? : boolean, leftBottom? : boolean, colors: Color[], material?: IMaterial, outlineWidth: number, outlineHeight: number)
	function outlines.drawOutlineEx(radius, x, y, w, h, leftTop, rightTop, rightBottom, leftBottom, colors, material, l, t, r, b, curviness, inside)
		if colors[2] == nil then
			colors[1] = colors
			colors[2] = colors
		end

		if radius == 0 then
			leftTop, rightTop, rightBottom, leftBottom = false, false, false, false
		end

		if t == nil then
			t, r, b = l, l, l
		elseif r == nil then
			r, b = l, t
		end

		inside = inside or false
		curviness = curviness or 2

		if batch.batching then
			drawOutlineBatched(radius, x, y, w, h, leftTop, rightTop, rightBottom, leftBottom, colors, material, l, t, r, b, curviness, inside)
		else
			drawOutlineSingle(radius, x, y, w, h, leftTop, rightTop, rightBottom, leftBottom, colors, material, l, t, r, b, curviness, inside)
		end
	end

	local drawOutlineEx = outlines.drawOutlineEx

	---Draws an outline with the specified parameters. Bases on rounded box, but makes outline of them.
	---@param radius number radius of roundedBox the outline will 'outline'
	---@param x number start X position of outline
	---@param y number start Y position of outline
	---@param w number width of outline
	---@param h number height of outline
	---@param colors linearGradient Colors of outline. Either a color, or table with 2 colors inside.
	---@param material? IMaterial # Default material is vgui/white
	---@param l number Left outline width
	---@param t number Top outline width 
	---@param r number Right outline width
	---@param b number Botton outline width
	---@param curviness number? Curviness of rounded box. Default is 2. Makes rounded box behave as with formula ``x^curviness+y^curviness=radius^curviness`` (this is circle formula btw. Rounded boxes are superellipses)
	---@param inside boolean?
	---@overload fun(radius : number, x : number, y : number, w : number, h : number, colors: gradients, material?: IMaterial, outlineThickness: number)
	---@overload fun(radius : number, x : number, y : number, w : number, h : number, colors: gradients, material?: IMaterial, outlineThickness: number, _: nil, _: nil, _: nil, curviness: number)
	---@overload fun(radius : number, x : number, y : number, w : number, h : number, colors: gradients, material?: IMaterial, outlineWidth: number, outlineHeight: number)
	---@overload fun(radius : number, x : number, y : number, w : number, h : number, colors: gradients, material?: IMaterial, outlineWidth: number, outlineHeight: number, _: nil, _: nil, curviness: number)
	function outlines.drawOutline(radius, x, y, w, h, colors, material, l, t, r, b, curviness, inside)
		drawOutlineEx(radius, x, y, w, h, true, true, true, true, colors, material, l, t, r, b, curviness, inside)
	end
end

do
	local meshConstructor = Mesh
	local meshBegin = mesh.Begin
	local meshEnd = mesh.End

	local meshPosition = mesh.Position
	local meshColor = mesh.Color
	local meshAdvanceVertex = mesh.AdvanceVertex

	local PRIMITIVE_TRIANGLE_STRIP = MATERIAL_TRIANGLE_STRIP

	---Creates mesh for box outline
	---@param x number
	---@param y number
	---@param endX number
	---@param endY number
	---@param colors {[1]: Color, [2]: Color}
	---@param outlineL number
	---@param outlineT number
	---@param outlineR number
	---@param outlineB number
	---@return IMesh
	function outlines.generateBoxOutline(x, y, endX, endY, colors, outlineL, outlineT, outlineR, outlineB)
		local meshObj = meshConstructor()

		local innerR, innerG, innerB, innerA = colors[1].r, colors[1].g, colors[1].b, colors[1].a
		local outerR, outerG, outerB, outerA = colors[2].r, colors[2].g, colors[2].b, colors[2].a

		meshBegin(meshObj, PRIMITIVE_TRIANGLE_STRIP, 17)
			meshPosition(x, y, 0)
			meshColor(innerR, innerG, innerB, innerA)
			meshAdvanceVertex()

			meshPosition(x, y - outlineT, 0)
			meshColor(outerR, outerG, outerB, outerA)
			meshAdvanceVertex()

			meshPosition(endX, y, 0)
			meshColor(innerR, innerG, innerB, innerA)
			meshAdvanceVertex()

			meshPosition(endX, y - outlineT, 0)
			meshColor(outerR, outerG, outerB, outerA)
			meshAdvanceVertex()

			meshPosition(endX, y, 0)
			meshColor(innerR, innerG, innerB, innerA)
			meshAdvanceVertex()

			meshPosition(endX + outlineR, y, 0)
			meshColor(outerR, outerG, outerB, outerA)
			meshAdvanceVertex()

			meshPosition(endX, endY, 0)
			meshColor(innerR, innerG, innerB, innerA)
			meshAdvanceVertex()

			meshPosition(endX + outlineR, endY, 0)
			meshColor(outerR, outerG, outerB, outerA)
			meshAdvanceVertex()

			meshPosition(endX, endY, 0)
			meshColor(innerR, innerB, innerB, innerA)
			meshAdvanceVertex()

			meshPosition(endX, endY + outlineB, 0)
			meshColor(outerR, outerB, outerB, outerA)
			meshAdvanceVertex()

			meshPosition(x, endY, 0)
			meshColor(innerR, innerG, innerB, innerA)
			meshAdvanceVertex()

			meshPosition(x, endY + outlineB, 0)
			meshColor(outerR, outerG, outerB, outerA)
			meshAdvanceVertex()

			meshPosition(x, endY, 0)
			meshColor(innerR, innerG, innerB, innerA)
			meshAdvanceVertex()

			meshPosition(x - outlineL, endY, 0)
			meshColor(outerR, outerG, outerB, outerA)
			meshAdvanceVertex()

			meshPosition(x, y, 0)
			meshColor(innerR, innerG, innerB, innerA)
			meshAdvanceVertex()

			meshPosition(x - outlineL, y, 0)
			meshColor(outerR, outerG, outerB, outerA)
			meshAdvanceVertex()

			meshPosition(x, y - outlineL, 0)
			meshColor(outerR, outerG, outerB, outerA)
			meshAdvanceVertex()
		meshEnd()

		return meshObj
	end

	local format = string.format

	---@param w number
	---@param h number
	---@param color1 Color
	---@param color2 Color
	---@param outlineL number
	---@param outlineT number
	---@param outlineR number
	---@param outlineB number
	local function getId(w, h, color1, color2, outlineL, outlineT, outlineR, outlineB)
		return format('%f;%f;%x%x%x%x;%x%x%x%x;%f;%f;%f;%f',
			w, h,
			color1.r, color1.g, color1.b, color1.a,
			color2.r, color2.g, color2.b, color2.a,
			outlineL, outlineT, outlineR, outlineB
		)
	end

	local generateBoxOutline = outlines.generateBoxOutline

	---@type {[string]: IMesh}
	local cachedBoxOutlineMeshes = {}

	local camPushModelMatrix = cam.PushModelMatrix
	local camPopModelMatrix = cam.PopModelMatrix

	local matrix = Matrix()
	local setField = matrix.SetField

	local meshDraw = FindMetaTable('IMesh')--[[@as IMesh]].Draw

	local defaultMat = Material('vgui/white')
	local renderSetMaterial = render.SetMaterial

	---@param x number start X position
	---@param y number start Y position
	---@param w number width
	---@param h number height
	---@param colors Color | {[1]: Color,[2]: Color}
	---@param outlineL number
	---@param outlineT number
	---@param outlineR number
	---@param outlineB number
	---@overload fun(x : number, y: number, w: number, h: number, colors: linearGradient, outlineThickness: number)
	---@overload fun(x : number, y: number, w: number, h: number, colors: linearGradient, outlineX: number, outlineY: number)
	function outlines.drawBoxOutline(x, y, w, h, colors, outlineL, outlineT, outlineR, outlineB)
		if colors[2] == nil then
			colors[1] = colors
			colors[2] = colors
		end

		if outlineT == nil then
			outlineT, outlineR, outlineB = outlineL, outlineL, outlineL
		elseif outlineR == nil then
			outlineR, outlineB = outlineL, outlineT
		end

		local id = getId(w, h, colors[1], colors[2], outlineL, outlineT, outlineR, outlineB)

		local mesh = cachedBoxOutlineMeshes[id]

		if mesh == nil then
			mesh = generateBoxOutline(0, 0, w, h, colors, outlineL, outlineT, outlineR, outlineB)
			cachedBoxOutlineMeshes[id] = mesh
		end

		setField(matrix, 1, 4, x)
		setField(matrix, 2, 4, y)

		renderSetMaterial(defaultMat)

		camPushModelMatrix(matrix, true)
			meshDraw(mesh)
		camPopModelMatrix()
	end

	timer.Create('PulsarUI.paint.cachedBoxOutlineGarbageCollector', 60, 0, function()
		for k, v in pairs(cachedBoxOutlineMeshes) do
			v:Destroy()
			cachedBoxOutlineMeshes[k] = nil
		end
	end)
end

PulsarUI.paint.outlines = outlines end do ---@diagnostic disable: deprecated
---The paint library has a built-in blur effect!
---
---This works by taking a copy of the screen, lowering its resolution, blurring it, then returning that as a material.
---
---You can then use that material with any of the paint functions to draw a blurred shape.
---
---It's a simple, cheap, and cool effect!
---
---Simple example:
---```lua
---local x, y = panel:LocalToScreen( 0, 0 ) -- getting absolute position
---local scrW, scrH = ScrW(), ScrH() -- it will be used to get UV coordinates
---local mat = PulsarUI.paint.blur.getBlurMaterial()
---PulsarUI.paint.rects.drawRect( 0, 0, 100, 64, color_white, mat, x / scrW, y / scrH, (x + 100) / scrW, (y + 64) / scrH )
---PulsarUI.paint.roundedBoxes.roundedBox( 32, 120, 0, 120, 64, color_white, mat, (x + 120) / scrW, y / scrH, (x + 240) / scrW, (y + 64) / scrH )
---``` 

---@class blur
local blur = {}
local paint = PulsarUI.paint

--[[
	Library that gets blured frame texture.
	It doesn't ocupy smalltex1 now. Use it freely)
]]

local RT_SIZE = 256

local BLUR = 10
local BLUR_PASSES = 1
local BLUR_TIME = 1 / 30

local BLUR_EXPENSIVE = true -- This is set to true because default gmodscreenspace shader actually sucks and makes noise on some devices

local RT_FLAGS = 2 + 256 + 32768
local TEXTURE_PREFIX = 'paint_library_rt_'
local MATERIAL_PREFIX = 'paint_library_material_'

---@type {[string] : ITexture}
local textures = {
	default = GetRenderTargetEx(TEXTURE_PREFIX .. 'default', RT_SIZE, RT_SIZE, 1, 2, RT_FLAGS, 0, 3)
}

---@type {[string] : number}
local textureTimes = {
	default = 0
}

---@type {[string] : IMaterial}
local textureMaterials = {
	default = CreateMaterial(MATERIAL_PREFIX .. 'default', 'UnlitGeneric', {
		['$basetexture'] = TEXTURE_PREFIX .. 'default',
		['$vertexalpha'] = 1,
		['$vertexcolor'] = 1,
	})
}


do
	local copyRTToTex = render.CopyRenderTargetToTexture

	local pushRenderTarget = render.PushRenderTarget
	local popRenderTarget = render.PopRenderTarget

	local start2D = cam.Start2D
	local end2D = cam.End2D

	local overrideColorWriteEnable = render.OverrideColorWriteEnable
	local overrideAlphaWriteEnable = render.OverrideAlphaWriteEnable
	local drawScreenQuad = render.DrawScreenQuad
	local updateScreenEffectTexture = render.UpdateScreenEffectTexture
	local setMaterial = render.SetMaterial

	local blurMaterial = Material('pp/blurscreen')

	local setTexture = blurMaterial.SetTexture
	local setFloat = blurMaterial.SetFloat
	local recompute = blurMaterial.Recompute

	local screenEffectTexture = render.GetScreenEffectTexture()
	local whiteMaterial = Material('vgui/white')

	local blurRTExpensive = render.BlurRenderTarget

	---@param rt ITexture
	---@param _ number
	---@param blurStrength number
	---@param passes number
	local function blurRTCheap(rt, _, blurStrength, passes)
		setMaterial(blurMaterial)
		setTexture(blurMaterial, '$basetexture', rt)

		for i = 1, passes do
 			setFloat(blurMaterial, '$blur', (i / passes) * blurStrength)
 			recompute(blurMaterial)

 			-- if you don't update screenEffect texture
 			-- Then for whatever reason gmodscreenspace
 			-- shader won't update it's $basetexture
 			-- resulting in broken passes
 			-- and picture like it was only single pass instead of multiple.

 			--ScreenEffect texutre is not used by blur at all.
 			--Like literally, i have to update it only for gmodscreenspace shader to work.
 			--That's tottally retarded.
			updateScreenEffectTexture()
			drawScreenQuad()
		end

		--Reseting it's basetexture to default one
		setTexture(blurMaterial, '$basetexture', screenEffectTexture)
	end


	---Blurs texture with specified parameters
	---@param blurStrength number? How much blur strength the result texture will have. Overrides BLUR
	---@param passes number? How much bluring passes texture will have. More passes will result in better bluring quality, but worse performace. Affects performance a lot.
	---@param expensive boolean? If set to true, it will try to blur texture with defualt Source Engine shaders called BlurX, BlurY. They are expensive. If unset or false, it will try to blur stuff with gmodscreenspace shader.
	function blur.generateBlur(id, blurStrength, passes, expensive) -- used right before drawing 2D shit
		local texToBlur = textures[id or 'default']

		blurStrength = blurStrength or BLUR
		passes = passes or BLUR_PASSES
		expensive = expensive or BLUR_EXPENSIVE

		copyRTToTex(texToBlur)

 		pushRenderTarget(texToBlur)
 			start2D()
 				---@type fun(texture: ITexture, blurX: number, blurY: number, passes: number)
 				local blurRT = expensive and blurRTExpensive or blurRTCheap
 				blurRT(texToBlur, blurStrength, blurStrength, passes)

	 			overrideAlphaWriteEnable(true, true)
	 			overrideColorWriteEnable(true, false)

	 			setMaterial(whiteMaterial)
	 			drawScreenQuad()

	 			overrideAlphaWriteEnable(false, true)
	 			overrideColorWriteEnable(false, true)
	  		end2D()
		popRenderTarget()

		-- Even if this RT doesn't use alpha channel (IMAGE_FORMAT), it stil somehow uses alpha... BAD!
		-- At least no clearDepth

	end
end

do
	local clock = os.clock
	local generateBlur = blur.generateBlur

	---Tries to blur texture with specified id and parameters according to it's last time being blurred
	---@param id string Identifier of blur texture. If set to nil or 'default', then default blur texture will be asked to be blurred with legacy logic
	---If it is set, and not set to 'default', then it tries to blur texture if needs to and enables other arguments as well. Use with caution!
	---@param time number? How much time needs to be passed for next texture's bluring? You usually want it to set to ``1 / blurFPS``. Overrides BLUR_FPS. Affects performance a lot.
	---@param blurStrength number? How much blur strength the result texture will have. Overrides BLUR
	---@param passes number? How much bluring passes texture will have. More passes will result in better bluring quality, but worse performace. Affects performance a lot.
	---@param expensive boolean? If set to true, it will try to blur texture with defualt Source Engine shaders called BlurX, BlurY. They are expensive. If unset or false, it will try to blur stuff with gmodscreenspace shader.
	---@overload fun(id : 'default'?): IMaterial
	function blur.requestBlur(id, time, blurStrength, passes, expensive)
		id = id or 'default'
		time = time or BLUR_TIME

		if textureTimes[id] == nil then
			textureTimes[id] = clock() + time
			return
		end

		if id ~= 'default' and textureTimes[id] < clock() then
			generateBlur(id, blurStrength, passes, expensive)

			if time > 0 then
				textureTimes[id] = nil
			else
				textureTimes[id] = 0
			end
		end
	end

	hook.Add('RenderScreenspaceEffects', 'PulsarUI.paint.blur', function()
		local time = textureTimes['default']
		if time == nil then return end

		if time < clock() then
			generateBlur()
			textureTimes['default'] = nil
		end
	end)
end

do
	local requestBlur = blur.requestBlur
	local getRenderTargetEx = GetRenderTargetEx

	local createMaterial = CreateMaterial

	local pushRenderTarget = render.PushRenderTarget
	local popRenderTarget = render.PopRenderTarget
	local clear = render.Clear

	---Returns a Texture with the blurred image from the screen.
	---@param id string Identifier of blur texture. If set to nil or 'default', then default blur texture will be returned with legacy logic
	---If it is set, and not set to 'default', then it tries to blur texture if needs to and enables other arguments as well. Use with caution!
	---@param time number? How much time needs to be passed for next texture's bluring? You usually want it to set to ``1 / blurFPS``. Overrides BLUR_FPS. Affects performance a lot.
	---@param blurStrength number? How much blur strength the result texture will have. Overrides BLUR
	---@param passes number? How much bluring passes texture will have. More passes will result in better bluring quality, but worse performace. Affects performance a lot.
	---@param expensive boolean? If set to true, it will try to blur texture with defualt Source Engine shaders called BlurX, BlurY. They are expensive. If unset or false, it will try to blur stuff with gmodscreenspace shader.
	---@nodiscard
	---@overload fun(id : 'default'?): ITexture
	---@return ITexture
	function blur.getBlurTexture(id, time, blurStrength, passes, expensive)
		id = id or 'default'

		if textures[id] == nil then
			local tex = getRenderTargetEx(TEXTURE_PREFIX .. id, RT_SIZE, RT_SIZE, 1, 2, RT_FLAGS, 0, 3)
			textures[id] = tex
			textureTimes[id] = 0

			pushRenderTarget(tex)
				clear(0, 0, 0, 255)
			popRenderTarget()
		end

		requestBlur(id, time, blurStrength, passes, expensive)

		return textures[id]
	end

	local getBlurTexture = blur.getBlurTexture

	---Returns a Material with the blurred image from the screen.
	---@param id string Identifier of blur material. If set to nil or 'default', then default blur material will be returned with legacy logic
	---If it is set, and not set to 'default', then it tries to blur material if needs to and enables other arguments as well. Use with caution!
	---@param time number? How much time needs to be passed for next material's bluring? You usually want it to set to ``1 / blurFPS``. Overrides BLUR_FPS. Affects performance a lot.
	---@param blurStrength number? How much blur strength the result material will have. Overrides BLUR
	---@param passes number? How much bluring passes material will have. More passes will result in better bluring quality, but worse performace. Affects performance a lot.
	---@param expensive boolean? If set to true, it will try to blur material with defualt Source Engine shaders called BlurX, BlurY. They are expensive. If unset or false, it will try to blur stuff with gmodscreenspace shader.
	---@nodiscard
	---@overload fun(id : 'default'?): IMaterial
	---@return IMaterial # Blurred screen image
	function blur.getBlurMaterial(id, time, blurStrength, passes, expensive)
		id = id or 'default'
		local mat = textureMaterials[id]

		if mat == nil then
			mat = createMaterial(MATERIAL_PREFIX .. id, 'UnlitGeneric', {
				['$basetexture'] = getBlurTexture(id, time, blurStrength, passes, expensive):GetName(),
				['$vertexalpha'] = 1,
				['$vertexcolor'] = 1,
				['$model'] = 1,
				['$translucent'] = 1,
			})
			textureMaterials[id] = mat

			return mat-- requestBlur is arleady done.
		end

		requestBlur(id, time, blurStrength, passes, expensive)

		return mat
	end
end

PulsarUI.paint.blur = blur end do ---@diagnostic disable: deprecated
---# PulsarUI.paint.circles!
---### Forget about Circles! from sneakysquid
---he's a f***** btw ;)
---
---This library allows you to create and draw circles and ellipses
---```
---But with a twist:
---1) They have gradients of course
---2) They can be sliced
---3) They support stencils 
---4) They can have various curviness (squircles/SwiftUI/IOS rounded square )
---@class circles
local circles = {}
local paint = PulsarUI.paint

---@param num number
---@param power number
---@return number
local function fpow( num, power )
	if num > 0 then
		return num ^ power
	else
		return -((-num) ^ power)
	end
end

do
	local meshConstructor = Mesh

	local meshBegin = mesh.Begin
	local meshEnd = mesh.End
	local meshPosition = mesh.Position
	local meshColor = mesh.Color
	local meshTexCoord = mesh.TexCoord
	local meshAdvanceVertex = mesh.AdvanceVertex

	local PRIMITIVE_POLYGON = MATERIAL_POLYGON

	local originVector = Vector(0, 0, 0)

	local sin, cos = math.sin, math.cos


	---Generates single circle mesh, unbatched
	---@param vertexCount integer
	---@param startAngle number
	---@param endAngle number
	---@param colors {[1]: Color, [2]: Color}
	---@param curviness number
	---@param rotation number
	---@deprecated Internal variable, not meant to be used outside.
	---@return IMesh
	function circles.generateSingleMesh(vertexCount, startAngle, endAngle, colors, rotation, curviness)
		local meshObj = meshConstructor()

		local r, g, b, a = colors[2].r, colors[2].g, colors[2].b, colors[2].a
		local deltaAngle = endAngle - startAngle

		meshBegin(meshObj, PRIMITIVE_POLYGON, vertexCount + 2) -- vertexcount + center vertex
			meshPosition(originVector)
			meshColor(colors[1].r, colors[1].g, colors[1].b, colors[1].a)
			meshTexCoord(0, 0.5, 0.5)
			meshAdvanceVertex()

			for i = 0, vertexCount do
				local angle = startAngle + deltaAngle * i / vertexCount

				meshPosition(fpow(cos(angle), curviness), fpow(sin(angle), curviness), 0)
				meshColor(r, g, b, a)
				meshTexCoord(0, fpow(sin(angle + rotation), curviness) / 2 + 0.5, fpow(cos(angle + rotation), curviness) / 2 + 0.5)
				meshAdvanceVertex()
			end
		meshEnd()

		return meshObj
	end
end

do
	local batch = PulsarUI.paint.batch
	local incrementZ = PulsarUI.paint.incrementZ

	local sin, cos = math.sin, math.cos

	---Generates circle mesh with batching being used. Since it's batched, we can't use matrices, so there are also x, y, and radius arguments
	---@param x number
	---@param y number
	---@param vertexCount integer
	---@param startAngle number
	---@param endAngle number
	---@param colors {[1]: Color, [2]: Color}
	---@param curviness number
	---@deprecated Internal variable, not meant to be used outside.
	function circles.generateMeshBatched(x, y, w, h, vertexCount, startAngle, endAngle, colors, curviness)
		local startColor, endColor = colors[1], colors[2]

		local batchTable = batch.batchTable
		local len = batchTable[0]

		local z = incrementZ()

		local deltaAngle = endAngle - startAngle
		for i = 0, vertexCount - 1 do -- we make a triangle each time, we need to get next point, so yeah...
			local indexI = i * 10

			do -- 1st vertex (middle)
				batchTable[len + 1 + indexI] = x
				batchTable[len + 2 + indexI] = y
				batchTable[len + 3 + indexI] = z
				batchTable[len + 4 + indexI] = startColor
			end

			do -- 2nd vertex (current point)
				local angle = startAngle + deltaAngle * i / vertexCount

				batchTable[len + 5 + indexI] = x + fpow(cos(angle), curviness) * w -- second vertex
				batchTable[len + 6 + indexI] = y + fpow(sin(angle),curviness) * h
				batchTable[len + 7 + indexI] = endColor
			end

			do -- 3rd vertex (next point)
				local angle = startAngle + deltaAngle * (i + 1) / vertexCount

				batchTable[len + 8 + indexI] = x + fpow(cos(angle), curviness) * w -- second vertex
				batchTable[len + 9 + indexI] = y + fpow(sin(angle), curviness) * h
				batchTable[len + 10+ indexI] = endColor
			end
		end

		batchTable[0] = len + 10 * vertexCount
	end
end

do
	local angleConverter = math.pi / 180

	local batch = PulsarUI.paint.batch

	local matrix = Matrix()
	local setUnpacked = matrix.SetUnpacked

	local pushModelMatrix = cam.PushModelMatrix
	local popModelMatrix = cam.PopModelMatrix

	---@type {[string] : IMesh}
	local cachedCircleMeshes = {}

	local format = string.format

	---@param color1 Color
	---@param color2 Color
	---@param vertexCount integer
	---@param startAngle number
	---@param curviness number
	---@return string id
	local function getId(color1, color2, vertexCount, startAngle, endAngle, rotation, curviness)
		return format('%x%x%x%x;%x%x%x%x;%u;%f;%f;%f;%f',
			color1.r, color1.g, color1.b, color1.a,
			color2.r, color2.g, color2.b, color2.a,
			vertexCount, startAngle, endAngle, rotation, curviness
		)
	end

	local defaultMat = Material('vgui/white')
	local renderSetMaterial = render.SetMaterial

	local generateSingleMesh = circles.generateSingleMesh
	local generateMeshBatched = circles.generateMeshBatched

	local meshDraw = FindMetaTable('IMesh')--[[@as IMesh]].Draw

	---@param x number # CENTER X coordinate of circle
	---@param y number # CENTER Y coordinate of circle
	---@param w number x xradius # Width/X radius of circle
	---@param h number y radius # Height/Y radius of circle
	---@param vertexCount integer Vertex count that circle will have
	---@param startAngle number Starting angle of sliced circle. Default is 0. MUST BE LOWER THAN END ANGLE
	---@param endAngle  number Ending angle of sliced circle. Default is 360. MUST BE HIGHER THAN START ANGLE
	---@param colors Color | {[1]: Color, [2]: Color} Color of circle. Can be a Color, or table with 2 colors inside.
	---@param curviness number? Curviness ratio of circle. Think of circle defined as a formula like ``x^2+y^2=1``. But replace 2 with curviness.
	---For squircle like in IOS, curviness is 4, resulting in ``x^4+y^4=1``
	function circles.drawCircle(x, y, w, h, colors, vertexCount, startAngle, endAngle, material, rotation, curviness)
		if colors[2] == nil then
			colors[1] = colors
			colors[2] = colors
		end

		curviness = 2 / (curviness or 2)

		if vertexCount == nil then
			vertexCount = 24
		end

		if startAngle == nil then
			startAngle = 0
			endAngle = 360
		end

		if rotation == nil then
			rotation = 0
		end

		rotation = rotation * angleConverter
		startAngle = startAngle * angleConverter
		endAngle = endAngle * angleConverter

		if batch.batching then
			generateMeshBatched(x, y, w, h, vertexCount, startAngle, endAngle, colors, curviness)
		else
			local id = getId(colors[1], colors[2], vertexCount, startAngle, endAngle, rotation, curviness)

			local meshObj = cachedCircleMeshes[id]

			if meshObj == nil then
				meshObj = generateSingleMesh(vertexCount, startAngle, endAngle, colors, rotation, curviness)
				cachedCircleMeshes[id] = meshObj
			end

			material = material or defaultMat

			setUnpacked(matrix,
                w, 0, 0, x,
                0, h, 0, y,
                0, 0, 1, 0,
                0, 0, 0, 1
            )

            renderSetMaterial(material)

			pushModelMatrix(matrix, true)
				meshDraw(meshObj)
			popModelMatrix()
		end
	end

	timer.Create('PulsarUI.paint.circlesGarbageCollector' .. SysTime(), 60, 0, function()
		for k, v in pairs(cachedCircleMeshes) do
			v:Destroy()
			cachedCircleMeshes[k] = nil
		end
	end)
end

-- Now circled outlines!

do
	local meshConstructor = Mesh

	local meshBegin = mesh.Begin
	local meshEnd = mesh.End
	local meshPosition = mesh.Position
	local meshColor = mesh.Color
	local meshTexCoord = mesh.TexCoord
	local meshAdvanceVertex = mesh.AdvanceVertex

	local PRIMITIVE_TRIANGLE_STRIP = MATERIAL_TRIANGLE_STRIP
	local sin, cos = math.sin, math.cos


	---Generates single circle mesh, unbatched
	---@param vertexCount integer
	---@param startAngle number
	---@param endAngle number
	---@param colors {[1]: Color, [2]: Color}
	---@param startU number
	---@param endU number
	---@param outlineWidth number # note, that this outlineWidth is between 0-1, cuz it's basically a percentage of radius
	---@param curviness number
	---@deprecated Internal variable, not meant to be used outside .
	---@return IMesh
	function circles.generateOutlineMeshSingle(vertexCount, startAngle, endAngle, colors, startU, endU, outlineWidth, curviness)
		local meshObj = meshConstructor()

		local startR, startG, startB, startA = colors[1].r, colors[1].g, colors[1].b, colors[1].a
		local endR, endG, endB, endA = colors[2].r, colors[2].g, colors[2].b, colors[2].a

		local deltaAngle = endAngle - startAngle

		local startRadius = 1 - outlineWidth
		meshBegin(meshObj, PRIMITIVE_TRIANGLE_STRIP, vertexCount * 2) -- result vertexcount = innerVertexes + outerVertexes. Count of inner veretxes = count of outer veretxes
			for i = 0, vertexCount do
				local percent = i / vertexCount
				local angle = startAngle + deltaAngle * percent
				local sinn, coss = fpow(sin(angle), curviness), fpow(cos(angle), curviness)

				local u = startU + percent * (endU - startU)

				meshPosition(coss * startRadius, sinn * startRadius, 0)
				meshColor(startR, startG, startB, startA)
				meshTexCoord(0, u, 0)
				meshAdvanceVertex()

				meshPosition(coss, sinn, 0)
				meshColor(endR, endG, endB, endA)
				meshTexCoord(0, u, 1)
				meshAdvanceVertex()
			end
		meshEnd()

		return meshObj
	end
end

do
	local format = string.format

	local meshDraw = FindMetaTable('IMesh')--[[@as IMesh]].Draw
	local pushModelMatrix = cam.PushModelMatrix
	local popModelMatrix = cam.PopModelMatrix

	local generateOutlineMeshSingle = circles.generateOutlineMeshSingle

	local matrix = Matrix()
	local setUnpacked = matrix.SetUnpacked

	local renderSetMaterial = render.SetMaterial

	local cachedCircleOutlineMeshes = {}

	---@param vertexCount integer
	---@param startAngle number
	---@param endAngle number
	---@param startU number
	---@param endU number
	---@param outlineWidth number
	---@param curviness number
	---@return string id 
	local function getId(color1, color2, vertexCount, startAngle, endAngle, startU, endU, outlineWidth, curviness)
		return format('%x%x%x%x;%x%x%x%x;%u;%f;%f;%f;%f;%e', color1.r, color1.g, color1.b, color1.a, color2.r, color2.g, color2.b, color2.a, vertexCount, startAngle, endAngle, startU, endU, outlineWidth, curviness)
	end

	---@param x number
	---@param y number
	---@param w number
	---@param h number
	---@param vertexCount integer
	---@param startAngle number
	---@param endAngle number
	---@param colors {[1]: Color, [2]: Color}
	---@param startU number
	---@param endU number
	---@param curviness number
	---@param outlineWidth number # note, that this outlineWidth is between 0-1, cuz it's basically a percentage of radius
	---@deprecated Internal variable, not meant to be used outside.
	function circles.drawOutlineSingle(x, y, w, h, colors, vertexCount, startAngle, endAngle, material, startU, endU, outlineWidth, curviness)
		local id = getId(colors[1], colors[2], vertexCount, startAngle, endAngle, startU, endU, outlineWidth, curviness)

		local meshObj = cachedCircleOutlineMeshes[id]

		if meshObj == nil then
			meshObj = generateOutlineMeshSingle(vertexCount, startAngle, endAngle, colors, startU, endU, outlineWidth, curviness)
			cachedCircleOutlineMeshes[id] = meshObj
		end

		setUnpacked(matrix,
            w, 0, 0, x,
            0, h, 0, y,
            0, 0, 1, 0,
            0, 0, 0, 1
		)

		renderSetMaterial(material)

		pushModelMatrix(matrix, true)
			meshDraw(meshObj)
		popModelMatrix()
	end

	timer.Create('PulsarUI.paint.circleOutlinesGarbageCollector' .. SysTime(), 60, 0, function()
		for k, v in pairs(cachedCircleOutlineMeshes) do
			v:Destroy()
			cachedCircleOutlineMeshes[k] = nil
		end
	end)
end

do
	local defaultMat = Material('vgui/white')
	local angleConverter = math.pi / 180

	local drawOutlineSingle = circles.drawOutlineSingle
	local max = math.max
	---Draws circled outline. UNBATCHED ONLY.
	---@param x number # CENTER X coordinate of circled outline
	---@param y number # CENTER Y coordinate of circled outline
	---@param w number x xradius # Width/X radius of circled outline
	---@param h number y radius # Height/Y radius of circled outline
	---@param vertexCount integer Vertex count that circled outline will have
	---@param startAngle number Starting angle of sliced circled outline. Default is 0. MUST BE LOWER THAN END ANGLE
	---@param endAngle  number Ending angle of sliced circled outline. Default is 360. MUST BE HIGHER THAN START ANGLE
	---@param colors Color | {[1]: Color, [2]: Color} Color of circledOutline. Can be a Color, or table with 2 colors inside.
	---@param curviness number? Curviness ratio of circledOutline. Think of circledOutline defined as a formula like ``outlineRatio^2<=x^2+y^2<=1``. But replace 2 with curviness.
	---For squircle like in IOS, curviness is 4, resulting in ``outlineRatio^4<=x^4+y^4<=1``
	---@param startU number
	---@param endU number
	---@param outlineWidth number
	function circles.drawOutline(x, y, w, h, colors, outlineWidth, vertexCount, startAngle, endAngle, material, startU, endU, curviness)
		if colors[2] == nil then
			colors[1] = colors
			colors[2] = colors
		end

		if vertexCount == nil then
			vertexCount = 24
		end

		curviness = 2 / (curviness or 2)

		if startAngle == nil then
			startAngle = 0
			endAngle = 360
		end

		if startU == nil then
			startU = 0
			endU = 1
		end

		material = material or defaultMat

		startAngle = startAngle * angleConverter
		endAngle = endAngle * angleConverter

		outlineWidth = 1 / (1 + max(w, h) / outlineWidth)
		drawOutlineSingle(x, y, w, h, colors, vertexCount, startAngle, endAngle, material, startU, endU, outlineWidth, curviness)
	end
end

PulsarUI.paint.circles = circles end

print("paint library loaded! Version is 1.1!")