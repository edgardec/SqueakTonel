Class {
	#name : #PaintBoxMorph,
	#superclass : #ImageMorph,
	#instVars : [
		'action',
		'tool',
		'currentCursor',
		'thumbnail',
		'currentColor',
		'currentBrush',
		'colorMemory',
		'stampHolder',
		'rotationTabForm',
		'scaleTabForm',
		'colorMemoryThin',
		'brushes',
		'focusMorph',
		'weakDependents',
		'recentColors'
	],
	#classVars : [
		'ColorChart',
		'ImageLibrary',
		'Prototype',
		'RecentColors',
		'UseLargeColorPicker'
	],
	#category : #'MorphicExtras-Support'
}

{ #category : #'class initialization' }
PaintBoxMorph class >> cleanUp [
	"Flush caches"

	ColorChart := nil.

]

{ #category : #resources }
PaintBoxMorph class >> colorChart [
	^ColorChart ifNil:
		[ColorChart := self useLargeColorPicker
			ifTrue: [ColorPickerMorph colorPaletteForDepth: 32 extent: (360+10)@(180+10)]
			ifFalse: [ColorPickerMorph colorPaletteForDepth: 16 extent: 120 @ 89]]
]

{ #category : #resources }
PaintBoxMorph class >> colorMemoryImage [
	^self imageLibrary at: #colorMemoryImage ifAbsentPut:
		[| offset chart spec fillStyle colorMemoryImage |
		offset := 7@6.
		chart := self colorChart.
		colorMemoryImage := Form extent: chart extent+(offset*2) depth: chart depth.
		spec := #(
			(1.00 #(0.4 0.6 0.8))
			(0.67 #(0.6 0.6 0.8))
			(0.33 #(0.6 0.8 0.8))
			(0.00 #(0.6 0.8 0.9))).
		fillStyle := GradientFillStyle ramp: (spec collect: [:e | e first -> (Color fromRgbTriplet: e second)]).
		fillStyle origin: 0@(colorMemoryImage extent y //2); direction: colorMemoryImage extent x @0.

		(colorMemoryImage getCanvas copyOrigin: 0@0 clipRect: (0@0 extent: colorMemoryImage extent))
			fillRectangle: (0@0 extent: colorMemoryImage extent) fillStyle: fillStyle;
			frameAndFillRectangle: (0@0 extent: colorMemoryImage extent) fillColor: Color transparent borderWidth: 1 borderColor: Color black.
		colorMemoryImage copy: (0@0 extent: chart extent) from: chart to: offset rule: Form over.
		colorMemoryImage]
]

{ #category : #resources }
PaintBoxMorph class >> colorMemoryThinImage [
	^self imageLibrary at: #colorMemoryThinImage ifAbsentPut:
		[| offset chart spec fillStyle thinImage |
		offset := 7@6.
		chart := self colorChart.
		thinImage := Form extent: 42@101 depth: chart depth.
		spec := #(
			(1.00 #(0.4 0.6 0.8))
			(0.67 #(0.6 0.6 0.8))
			(0.33 #(0.6 0.8 0.8))
			(0.00 #(0.6 0.8 0.9))).
		fillStyle := GradientFillStyle ramp: (spec collect: [:e | e first -> (Color fromRgbTriplet: e second)]).
		fillStyle origin: 0@(thinImage extent y //2); direction: thinImage extent x @0.
		(thinImage getCanvas copyOrigin: 0@0 clipRect: (0@0 extent: thinImage extent))
			fillRectangle: (0@0 extent: thinImage extent) fillStyle: fillStyle;
			frameAndFillRectangle: (0@0 extent: thinImage extent) fillColor: Color transparent borderWidth: 1 borderColor: Color black.
		thinImage copy: (chart extent x - thinImage extent x + (2*offset x)@0 corner: chart extent x @ (chart extent y min: thinImage extent y - (2 * offset y))) from: chart to: offset rule: Form over.
		thinImage]
]

{ #category : #resources }
PaintBoxMorph class >> ellipseIcon [
	^self imageLibrary at: #ellipseIcon ifAbsentPut: [(Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAABsAAAAVCAMAAACAAGUXAAADAFBMVEX///8AAAD///9/f3//AAAA/wAAAP8A/////wAAAAAfHx8/Pz9fX1+enp6+vr7e3t4HBwcPDw8XFxcnJycvLy83NzdHR0dPT09XV1dnZ2dvb293d3eGhoaOjo6Wlpampqaurq62trbGxsbOzs7W1tbm5ubu7u729vYAAAAAMgAAZQAAmAAAywAA/wAAADIAMjIAZTIAmDIAyzIA/zIAAGUAMmUAZWUAmGUAy2UA/2UAAJgAMpgAZZgAmJgAy5gA/5gAAMsAMssAZcsAmMsAy8sA/8sAAP8AMv8AZf8AmP8Ay/8A//8yAAAyMgAyZQAymAAyywAy/wAyADIyMjIyZTIymDIyyzIy/zIyAGUyMmUyZWUymGUyy2Uy/2UyAJgyMpgyZZgymJgyy5gy/5gyAMsyMssyZcsymMsyy8sy/8syAP8yMv8yZf8ymP8yy/8y//9lAABlMgBlZQBlmABlywBl/wBlADJlMjJlZTJlmDJlyzJl/zJlAGVlMmVlZWVlmGVly2Vl/2VlAJhlMphlZZhlmJhly5hl/5hlAMtlMstlZctlmMtly8tl/8tlAP9lMv9lZf9lmP9ly/9l//+YAACYMgCYZQCYmACYywCY/wCYADKYMjKYZTKYmDKYyzKY/zKYAGWYMmWYZWWYmGWYy2WY/2WYAJiYMpiYZZiYmJiYy5iY/5iYAMuYMsuYZcuYmMuYy8uY/8uYAP+YMv+YZf+YmP+Yy/+Y///LAADLMgDLZQDLmADLywDL/wDLADLLMjLLZTLLmDLLyzLL/zLLAGXLMmXLZWXLmGXLy2XL/2XLAJjLMpjLZZjLmJjLy5jL/5jLAMvLMsvLZcvLmMvLy8vL/8vLAP/LMv/LZf/LmP/Ly//L////AAD/MgD/ZQD/mAD/ywD//wD/ADL/MjL/ZTL/mDL/yzL//zL/AGX/MmX/ZWX/mGX/y2X//2X/AJj/Mpj/ZZj/mJj/y5j//5j/AMv/Msv/Zcv/mMv/y8v//8sAAAD/Mv//Zf//mP//y//////eTOgfAAABAHRSTlP///////////8A////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AP//////OE00OwAAALJJREFUeF6N0U0OgyAQBWDfFm0ygGLk73rteTzurCpIBIxN+lYTvpmEgYE5ZeeHDPyXRWeFlHLeWttz3g5QWhMgXD8XPcGEVFoN8p15KgdH1oLFPrFSQtGYh2lvqGGrLYitTRgvi1L0q5G+zMqxt9x7mqPl5xyT6g11jkV/F4u12oS5NYFQ7aVyZ0k8ty3G6TlLGQJU+54ZpbEc3AZo7o3jAoCOL6KV73boNOrZbPd/f8wXgWSq2Ol/ETUAAAAASUVORK5CYII=' readStream)) offset: -5@ -4; yourself]
]

{ #category : #resources }
PaintBoxMorph class >> ellipseIconImage [
	^self imageLibrary at: #ellipseIcon ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAABsAAAAVCAMAAACAAGUXAAADAFBMVEX///8AAAD///9/f3//AAAA/wAAAP8A/////wAAAAAfHx8/Pz9fX1+enp6+vr7e3t4HBwcPDw8XFxcnJycvLy83NzdHR0dPT09XV1dnZ2dvb293d3eGhoaOjo6Wlpampqaurq62trbGxsbOzs7W1tbm5ubu7u729vYAAAAAMgAAZQAAmAAAywAA/wAAADIAMjIAZTIAmDIAyzIA/zIAAGUAMmUAZWUAmGUAy2UA/2UAAJgAMpgAZZgAmJgAy5gA/5gAAMsAMssAZcsAmMsAy8sA/8sAAP8AMv8AZf8AmP8Ay/8A//8yAAAyMgAyZQAymAAyywAy/wAyADIyMjIyZTIymDIyyzIy/zIyAGUyMmUyZWUymGUyy2Uy/2UyAJgyMpgyZZgymJgyy5gy/5gyAMsyMssyZcsymMsyy8sy/8syAP8yMv8yZf8ymP8yy/8y//9lAABlMgBlZQBlmABlywBl/wBlADJlMjJlZTJlmDJlyzJl/zJlAGVlMmVlZWVlmGVly2Vl/2VlAJhlMphlZZhlmJhly5hl/5hlAMtlMstlZctlmMtly8tl/8tlAP9lMv9lZf9lmP9ly/9l//+YAACYMgCYZQCYmACYywCY/wCYADKYMjKYZTKYmDKYyzKY/zKYAGWYMmWYZWWYmGWYy2WY/2WYAJiYMpiYZZiYmJiYy5iY/5iYAMuYMsuYZcuYmMuYy8uY/8uYAP+YMv+YZf+YmP+Yy/+Y///LAADLMgDLZQDLmADLywDL/wDLADLLMjLLZTLLmDLLyzLL/zLLAGXLMmXLZWXLmGXLy2XL/2XLAJjLMpjLZZjLmJjLy5jL/5jLAMvLMsvLZcvLmMvLy8vL/8vLAP/LMv/LZf/LmP/Ly//L////AAD/MgD/ZQD/mAD/ywD//wD/ADL/MjL/ZTL/mDL/yzL//zL/AGX/MmX/ZWX/mGX/y2X//2X/AJj/Mpj/ZZj/mJj/y5j//5j/AMv/Msv/Zcv/mMv/y8v//8sAAAD/Mv//Zf//mP//y//////eTOgfAAABAHRSTlP///////////8A////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AP//////OE00OwAAALJJREFUeF6N0U0OgyAQBWDfFm0ygGLk73rteTzurCpIBIxN+lYTvpmEgYE5ZeeHDPyXRWeFlHLeWttz3g5QWhMgXD8XPcGEVFoN8p15KgdH1oLFPrFSQtGYh2lvqGGrLYitTRgvi1L0q5G+zMqxt9x7mqPl5xyT6g11jkV/F4u12oS5NYFQ7aVyZ0k8ty3G6TlLGQJU+54ZpbEc3AZo7o3jAoCOL6KV73boNOrZbPd/f8wXgWSq2Ol/ETUAAAAASUVORK5CYII=' readStream)]
]

{ #category : #resources }
PaintBoxMorph class >> eraseIcon [
	^self imageLibrary at: #eraseIcon ifAbsentPut: [(Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAAC8AAAAjCAMAAAAzO6PlAAADAFBMVEUAAAAAAAD//+V/f3//AAAA/wAAAP8A/////wD/AP8fHx8/Pz9fX1+enp6+vr7e3t4HBwcPDw8XFxcnJycvLy83NzdHR0dPT09XV1dnZ2dvb293d3eGhoaOjo6Wlpampqaurq62trbGxsbOzs7W1tbm5ubu7u729vYAAAAAMgAAZQAAmAAAywAA/wAAADIAMjIAZTIAmDIAyzIA/zIAAGUAMmUAZWUAmGUAy2UA/2UAAJgAMpgAZZgAmJgAy5gA/5gAAMsAMssAZcsAmMsAy8sA/8sAAP8AMv8AZf8AmP8Ay/8A//8yAAAyMgAyZQAymAAyywAy/wAyADIyMjIyZTIymDIyyzIy/zIyAGUyMmUyZWUymGUyy2Uy/2UyAJgyMpgyZZgymJgyy5gy/5gyAMsyMssyZcsymMsyy8sy/8syAP8yMv8yZf8ymP8yy/8y//9lAABlMgBlZQBlmABlywBl/wBlADJlMjJlZTJlmDJlyzJl/zJlAGVlMmVlZWVlmGVly2Vl/2VlAJhlMphlZZhlmJhly5hl/5hlAMtlMstlZctlmMtly8tl/8tlAP9lMv9lZf9lmP9ly/9l//+YAACYMgCYZQCYmACYywCY/wCYADKYMjKYZTKYmDKYyzKY/zKYAGWYMmWYZWWYmGWYy2WY/2WYAJiYMpiYZZiYmJiYy5iY/5iYAMuYMsuYZcuYmMuYy8uY/8uYAP+YMv+YZf+YmP+Yy/+Y///LAADLMgDLZQDLmADLywDL/wDLADLLMjLLZTLLmDLLyzLL/zLLAGXLMmXLZWXLmGXLy2XL/2XLAJjLMpjLZZjLmJjLy5jL/5jLAMvLMsvLZcvLmMvLy8vL/8vLAP/LMv/LZf/LmP/Ly//L////AAD/MgD/ZQD/mAD/ywD//wD/ADL/MjL/ZTL/mDL/yzL//zL/AGX/MmX/ZWX/mGX/y2X//2X/AJj/Mpj/ZZj/mJj/y5j//5j/AMv/Msv/Zcv/mMv/y8v//8v/AP//Mv//Zf//mP//y////+Vs9r+lAAABAHRSTlMA////////////////////////////////////////////////////AP//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////2hiZ4AAAATlJREFUeF7l1DFuhDAQBVA0bST7AFmJzsfci9Cl4xSWVgodVHsDJJBWWMJ2AW4yGRsWJYWxt0qRoaF4Y/4YQ/GXBY7qRZ7f8eTuNW5NNgevjcnmShnTXanN5PFRdcaV750FOB8CNz4aAwjXt9TQTz5auqFIiV1CpMiej5TIACR2tUYSgfsOa1Nv4YFw8L3FWqViXGuEn3wcqG5DNLxe0f3iN6opPqtff5dT4HTZGBfeC7QbVyqsPkRnFd73GnHbTRV0dFLiwfd3EHaPPsSzeE6e99QguAtZhsmdcf610gOklC1jrOsmc3ZsiK/LwgX4BvlxuZQcz04ZcfLUIFgjZVVV9fmZ96svi9Z3zlhZt0wkvhG+8Xlua58l/Q16TbxpPhudwQt+8DXvF8L1/CA989w/GtfEl+L/11Hf/SVoHyShmoYAAAAASUVORK5CYII=' readStream)) offset: -16@ -34; yourself]
]

{ #category : #resources }
PaintBoxMorph class >> eraseIconImage [
	^self imageLibrary at: #eraseIcon ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAAC8AAAAjCAMAAAAzO6PlAAADAFBMVEUAAAAAAAD//+V/f3//AAAA/wAAAP8A/////wD/AP8fHx8/Pz9fX1+enp6+vr7e3t4HBwcPDw8XFxcnJycvLy83NzdHR0dPT09XV1dnZ2dvb293d3eGhoaOjo6Wlpampqaurq62trbGxsbOzs7W1tbm5ubu7u729vYAAAAAMgAAZQAAmAAAywAA/wAAADIAMjIAZTIAmDIAyzIA/zIAAGUAMmUAZWUAmGUAy2UA/2UAAJgAMpgAZZgAmJgAy5gA/5gAAMsAMssAZcsAmMsAy8sA/8sAAP8AMv8AZf8AmP8Ay/8A//8yAAAyMgAyZQAymAAyywAy/wAyADIyMjIyZTIymDIyyzIy/zIyAGUyMmUyZWUymGUyy2Uy/2UyAJgyMpgyZZgymJgyy5gy/5gyAMsyMssyZcsymMsyy8sy/8syAP8yMv8yZf8ymP8yy/8y//9lAABlMgBlZQBlmABlywBl/wBlADJlMjJlZTJlmDJlyzJl/zJlAGVlMmVlZWVlmGVly2Vl/2VlAJhlMphlZZhlmJhly5hl/5hlAMtlMstlZctlmMtly8tl/8tlAP9lMv9lZf9lmP9ly/9l//+YAACYMgCYZQCYmACYywCY/wCYADKYMjKYZTKYmDKYyzKY/zKYAGWYMmWYZWWYmGWYy2WY/2WYAJiYMpiYZZiYmJiYy5iY/5iYAMuYMsuYZcuYmMuYy8uY/8uYAP+YMv+YZf+YmP+Yy/+Y///LAADLMgDLZQDLmADLywDL/wDLADLLMjLLZTLLmDLLyzLL/zLLAGXLMmXLZWXLmGXLy2XL/2XLAJjLMpjLZZjLmJjLy5jL/5jLAMvLMsvLZcvLmMvLy8vL/8vLAP/LMv/LZf/LmP/Ly//L////AAD/MgD/ZQD/mAD/ywD//wD/ADL/MjL/ZTL/mDL/yzL//zL/AGX/MmX/ZWX/mGX/y2X//2X/AJj/Mpj/ZZj/mJj/y5j//5j/AMv/Msv/Zcv/mMv/y8v//8v/AP//Mv//Zf//mP//y////+Vs9r+lAAABAHRSTlMA////////////////////////////////////////////////////AP//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////2hiZ4AAAATlJREFUeF7l1DFuhDAQBVA0bST7AFmJzsfci9Cl4xSWVgodVHsDJJBWWMJ2AW4yGRsWJYWxt0qRoaF4Y/4YQ/GXBY7qRZ7f8eTuNW5NNgevjcnmShnTXanN5PFRdcaV750FOB8CNz4aAwjXt9TQTz5auqFIiV1CpMiej5TIACR2tUYSgfsOa1Nv4YFw8L3FWqViXGuEn3wcqG5DNLxe0f3iN6opPqtff5dT4HTZGBfeC7QbVyqsPkRnFd73GnHbTRV0dFLiwfd3EHaPPsSzeE6e99QguAtZhsmdcf610gOklC1jrOsmc3ZsiK/LwgX4BvlxuZQcz04ZcfLUIFgjZVVV9fmZ96svi9Z3zlhZt0wkvhG+8Xlua58l/Q16TbxpPhudwQt+8DXvF8L1/CA989w/GtfEl+L/11Hf/SVoHyShmoYAAAAASUVORK5CYII=' readStream)]
]

{ #category : #resources }
PaintBoxMorph class >> eyedropperIcon [
	^self imageLibrary at: #eyedropperIcon ifAbsentPut: [(Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAACYAAAAkCAMAAADSK7iXAAADAFBMVEX///8AAAD///9/f3//AAAA/wAAAP8A/////wAAAAAfHx8/Pz9fX1+enp6+vr7e3t4HBwcPDw8XFxcnJycvLy83NzdHR0dPT09XV1dnZ2dvb293d3eGhoaOjo6Wlpampqaurq62trbGxsbOzs7W1tbm5ubu7u729vYAAAAAMgAAZQAAmAAAywAA/wAAADIAMjIAZTIAmDIAyzIA/zIAAGUAMmUAZWUAmGUAy2UA/2UAAJgAMpgAZZgAmJgAy5gA/5gAAMsAMssAZcsAmMsAy8sA/8sAAP8AMv8AZf8AmP8Ay/8A//8yAAAyMgAyZQAymAAyywAy/wAyADIyMjIyZTIymDIyyzIy/zIyAGUyMmUyZWUymGUyy2Uy/2UyAJgyMpgyZZgymJgyy5gy/5gyAMsyMssyZcsymMsyy8sy/8syAP8yMv8yZf8ymP8yy/8y//9lAABlMgBlZQBlmABlywBl/wBlADJlMjJlZTJlmDJlyzJl/zJlAGVlMmVlZWVlmGVly2Vl/2VlAJhlMphlZZhlmJhly5hl/5hlAMtlMstlZctlmMtly8tl/8tlAP9lMv9lZf9lmP9ly/9l//+YAACYMgCYZQCYmACYywCY/wCYADKYMjKYZTKYmDKYyzKY/zKYAGWYMmWYZWWYmGWYy2WY/2WYAJiYMpiYZZiYmJiYy5iY/5iYAMuYMsuYZcuYmMuYy8uY/8uYAP+YMv+YZf+YmP+Yy/+Y///LAADLMgDLZQDLmADLywDL/wDLADLLMjLLZTLLmDLLyzLL/zLLAGXLMmXLZWXLmGXLy2XL/2XLAJjLMpjLZZjLmJjLy5jL/5jLAMvLMsvLZcvLmMvLy8vL/8vLAP/LMv/LZf/LmP/Ly//L////AAD/MgD/ZQD/mAD/ywD//wD/ADL/MjL/ZTL/mDL/yzL//zL/AGX/MmX/ZWX/mGX/y2X//2X/AJj/Mpj/ZZj/mJj/y5j//5j/AMv/Msv/Zcv/mMv/y8v//8sAAAD/Mv//Zf//mP//y//////eTOgfAAABAHRSTlP///////////8A////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AP//////OE00OwAAAR5JREFUeF6t1DGygjAQBmCHVkYroplhFBjzwmHouAidF8ALZOzSeYF4g1Smeu8CtlRJR5vqJejTV0CWwq2/2QnL/ruwdk4t7CfYj5IXmKnOaMkhdjO+5DHMlDF93xvZ4BD71oNyrAmx7ql4VQbYSzXlFFNK6f9qgslOaq/0U02wi2tjetPJYzWoqbdxZaQcWpWBn7Vfcfeqtxpn2ToquB/Enxpl2VdED7g5Vy81xpwi91Od1m81wnLqVJtYe64DLKeUXFsErKXvdcU1sL2riBKxXQJLnrtPFNsYyELhFUJAZJy6CxQDySr8uBAGAph7lcRATjM/riQF4rxfExEvUyD1rCACbcDjwA4t2sE3hKUYPDXsUTMuEpt3uD7LoPoFh1uzvVTXHQoAAAAASUVORK5CYII=' readStream)) offset: -12@ -35; yourself]
]

{ #category : #resources }
PaintBoxMorph class >> eyedropperIconImage [
	^self imageLibrary at: #eyedropperIcon ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAACYAAAAkCAMAAADSK7iXAAADAFBMVEX///8AAAD///9/f3//AAAA/wAAAP8A/////wAAAAAfHx8/Pz9fX1+enp6+vr7e3t4HBwcPDw8XFxcnJycvLy83NzdHR0dPT09XV1dnZ2dvb293d3eGhoaOjo6Wlpampqaurq62trbGxsbOzs7W1tbm5ubu7u729vYAAAAAMgAAZQAAmAAAywAA/wAAADIAMjIAZTIAmDIAyzIA/zIAAGUAMmUAZWUAmGUAy2UA/2UAAJgAMpgAZZgAmJgAy5gA/5gAAMsAMssAZcsAmMsAy8sA/8sAAP8AMv8AZf8AmP8Ay/8A//8yAAAyMgAyZQAymAAyywAy/wAyADIyMjIyZTIymDIyyzIy/zIyAGUyMmUyZWUymGUyy2Uy/2UyAJgyMpgyZZgymJgyy5gy/5gyAMsyMssyZcsymMsyy8sy/8syAP8yMv8yZf8ymP8yy/8y//9lAABlMgBlZQBlmABlywBl/wBlADJlMjJlZTJlmDJlyzJl/zJlAGVlMmVlZWVlmGVly2Vl/2VlAJhlMphlZZhlmJhly5hl/5hlAMtlMstlZctlmMtly8tl/8tlAP9lMv9lZf9lmP9ly/9l//+YAACYMgCYZQCYmACYywCY/wCYADKYMjKYZTKYmDKYyzKY/zKYAGWYMmWYZWWYmGWYy2WY/2WYAJiYMpiYZZiYmJiYy5iY/5iYAMuYMsuYZcuYmMuYy8uY/8uYAP+YMv+YZf+YmP+Yy/+Y///LAADLMgDLZQDLmADLywDL/wDLADLLMjLLZTLLmDLLyzLL/zLLAGXLMmXLZWXLmGXLy2XL/2XLAJjLMpjLZZjLmJjLy5jL/5jLAMvLMsvLZcvLmMvLy8vL/8vLAP/LMv/LZf/LmP/Ly//L////AAD/MgD/ZQD/mAD/ywD//wD/ADL/MjL/ZTL/mDL/yzL//zL/AGX/MmX/ZWX/mGX/y2X//2X/AJj/Mpj/ZZj/mJj/y5j//5j/AMv/Msv/Zcv/mMv/y8v//8sAAAD/Mv//Zf//mP//y//////eTOgfAAABAHRSTlP///////////8A////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AP//////OE00OwAAAR5JREFUeF6t1DGygjAQBmCHVkYroplhFBjzwmHouAidF8ALZOzSeYF4g1Smeu8CtlRJR5vqJejTV0CWwq2/2QnL/ruwdk4t7CfYj5IXmKnOaMkhdjO+5DHMlDF93xvZ4BD71oNyrAmx7ql4VQbYSzXlFFNK6f9qgslOaq/0U02wi2tjetPJYzWoqbdxZaQcWpWBn7Vfcfeqtxpn2ToquB/Enxpl2VdED7g5Vy81xpwi91Od1m81wnLqVJtYe64DLKeUXFsErKXvdcU1sL2riBKxXQJLnrtPFNsYyELhFUJAZJy6CxQDySr8uBAGAph7lcRATjM/riQF4rxfExEvUyD1rCACbcDjwA4t2sE3hKUYPDXsUTMuEpt3uD7LoPoFh1uzvVTXHQoAAAAASUVORK5CYII=' readStream)]
]

{ #category : #resources }
PaintBoxMorph class >> fillIcon [
	^self imageLibrary at: #fillIcon ifAbsentPut: [(Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAACEAAAAxCAMAAABj7DDGAAADAFBMVEX///8AAAD///9/f3//AAAA/wAAAP8A/////wAAAAAfHx8/Pz9fX1+enp6+vr7e3t4HBwcPDw8XFxcnJycvLy83NzdHR0dPT09XV1dnZ2dvb293d3eGhoaOjo6Wlpampqaurq62trbGxsbOzs7W1tbm5ubu7u729vYAAAAAMgAAZQAAmAAAywAA/wAAADIAMjIAZTIAmDIAyzIA/zIAAGUAMmUAZWUAmGUAy2UA/2UAAJgAMpgAZZgAmJgAy5gA/5gAAMsAMssAZcsAmMsAy8sA/8sAAP8AMv8AZf8AmP8Ay/8A//8yAAAyMgAyZQAymAAyywAy/wAyADIyMjIyZTIymDIyyzIy/zIyAGUyMmUyZWUymGUyy2Uy/2UyAJgyMpgyZZgymJgyy5gy/5gyAMsyMssyZcsymMsyy8sy/8syAP8yMv8yZf8ymP8yy/8y//9lAABlMgBlZQBlmABlywBl/wBlADJlMjJlZTJlmDJlyzJl/zJlAGVlMmVlZWVlmGVly2Vl/2VlAJhlMphlZZhlmJhly5hl/5hlAMtlMstlZctlmMtly8tl/8tlAP9lMv9lZf9lmP9ly/9l//+YAACYMgCYZQCYmACYywCY/wCYADKYMjKYZTKYmDKYyzKY/zKYAGWYMmWYZWWYmGWYy2WY/2WYAJiYMpiYZZiYmJiYy5iY/5iYAMuYMsuYZcuYmMuYy8uY/8uYAP+YMv+YZf+YmP+Yy/+Y///LAADLMgDLZQDLmADLywDL/wDLADLLMjLLZTLLmDLLyzLL/zLLAGXLMmXLZWXLmGXLy2XL/2XLAJjLMpjLZZjLmJjLy5jL/5jLAMvLMsvLZcvLmMvLy8vL/8vLAP/LMv/LZf/LmP/Ly//L////AAD/MgD/ZQD/mAD/ywD//wD/ADL/MjL/ZTL/mDL/yzL//zL/AGX/MmX/ZWX/mGX/y2X//2X/AJj/Mpj/ZZj/mJj/y5j//5j/AMv/Msv/Zcv/mMv/y8v//8sAAAD/Mv//Zf//mP//y//////eTOgfAAABAHRSTlP///////////8A////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AP//////OE00OwAAAglJREFUeF6tlN2aoyAMhsfTitIZJSugCX/67PXO5Xq0AdpOZ7a2J8ORJC/Jlwh52/cX623/VcL5mDwdE9R7RB+3SAeE87jsO2InpXtIkFuuFimJyNEPouvxZiFGUgrOfSPcV2QDuPnY9zH13R1xLYFYbM9SMMgUg/siuksB5IOUqwwbmhBD6N2NcKH6OXTis1zyZBjw5K6Ej9XPzhiTTFJqsAwQ3hHE/j4E9ksm1nmCmQGkSnQx9DF4HyKrWNcU49YJAMTZ2kowizkJu7dVphDc1llQwhotukIgHwDtt7UECD15mYlWazHZQkytUuPQIheaYhEoOyOUAjGByAQqBhgZZ8lqKAuUi5nYCqAgE2JUAzOM1ArRznIWkI3qQvDnULbKUi4AaTEChjFbShY7jGWj2uHEgDFhMQZUiayK0mWsG1BN085Ga88U1KBT7cckBKsGdW6as8gVcgx1BQphtck9+2h4jZp7IzSUvPr2b23uqckABwHuTlHZ2q/7gUQ+QiGaFmoCBXh3C/nmpDRU4lQTtAK/3VPPDX+vxN/czLbVP+46pTWem4sQBsD+/15iuBDNxL9jefjmrjE0TPj43V6IDy0OXjZW4iTwcDqcMgBIx/Mj90PTk/mRY0D3dAaNTWOfT6k/jXoxx+bHIe4n3Vnsr7KMLwj1Wsf7cx2fdT1X+vlyav8GcbD+Ab0bxRv8puClAAAAAElFTkSuQmCC' readStream)) offset: -10@ -44; yourself]
]

{ #category : #resources }
PaintBoxMorph class >> fillIconImage [
	^self imageLibrary at: #fillIcon ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAACEAAAAxCAMAAABj7DDGAAADAFBMVEX///8AAAD///9/f3//AAAA/wAAAP8A/////wAAAAAfHx8/Pz9fX1+enp6+vr7e3t4HBwcPDw8XFxcnJycvLy83NzdHR0dPT09XV1dnZ2dvb293d3eGhoaOjo6Wlpampqaurq62trbGxsbOzs7W1tbm5ubu7u729vYAAAAAMgAAZQAAmAAAywAA/wAAADIAMjIAZTIAmDIAyzIA/zIAAGUAMmUAZWUAmGUAy2UA/2UAAJgAMpgAZZgAmJgAy5gA/5gAAMsAMssAZcsAmMsAy8sA/8sAAP8AMv8AZf8AmP8Ay/8A//8yAAAyMgAyZQAymAAyywAy/wAyADIyMjIyZTIymDIyyzIy/zIyAGUyMmUyZWUymGUyy2Uy/2UyAJgyMpgyZZgymJgyy5gy/5gyAMsyMssyZcsymMsyy8sy/8syAP8yMv8yZf8ymP8yy/8y//9lAABlMgBlZQBlmABlywBl/wBlADJlMjJlZTJlmDJlyzJl/zJlAGVlMmVlZWVlmGVly2Vl/2VlAJhlMphlZZhlmJhly5hl/5hlAMtlMstlZctlmMtly8tl/8tlAP9lMv9lZf9lmP9ly/9l//+YAACYMgCYZQCYmACYywCY/wCYADKYMjKYZTKYmDKYyzKY/zKYAGWYMmWYZWWYmGWYy2WY/2WYAJiYMpiYZZiYmJiYy5iY/5iYAMuYMsuYZcuYmMuYy8uY/8uYAP+YMv+YZf+YmP+Yy/+Y///LAADLMgDLZQDLmADLywDL/wDLADLLMjLLZTLLmDLLyzLL/zLLAGXLMmXLZWXLmGXLy2XL/2XLAJjLMpjLZZjLmJjLy5jL/5jLAMvLMsvLZcvLmMvLy8vL/8vLAP/LMv/LZf/LmP/Ly//L////AAD/MgD/ZQD/mAD/ywD//wD/ADL/MjL/ZTL/mDL/yzL//zL/AGX/MmX/ZWX/mGX/y2X//2X/AJj/Mpj/ZZj/mJj/y5j//5j/AMv/Msv/Zcv/mMv/y8v//8sAAAD/Mv//Zf//mP//y//////eTOgfAAABAHRSTlP///////////8A////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AP//////OE00OwAAAglJREFUeF6tlN2aoyAMhsfTitIZJSugCX/67PXO5Xq0AdpOZ7a2J8ORJC/Jlwh52/cX623/VcL5mDwdE9R7RB+3SAeE87jsO2InpXtIkFuuFimJyNEPouvxZiFGUgrOfSPcV2QDuPnY9zH13R1xLYFYbM9SMMgUg/siuksB5IOUqwwbmhBD6N2NcKH6OXTis1zyZBjw5K6Ej9XPzhiTTFJqsAwQ3hHE/j4E9ksm1nmCmQGkSnQx9DF4HyKrWNcU49YJAMTZ2kowizkJu7dVphDc1llQwhotukIgHwDtt7UECD15mYlWazHZQkytUuPQIheaYhEoOyOUAjGByAQqBhgZZ8lqKAuUi5nYCqAgE2JUAzOM1ArRznIWkI3qQvDnULbKUi4AaTEChjFbShY7jGWj2uHEgDFhMQZUiayK0mWsG1BN085Ga88U1KBT7cckBKsGdW6as8gVcgx1BQphtck9+2h4jZp7IzSUvPr2b23uqckABwHuTlHZ2q/7gUQ+QiGaFmoCBXh3C/nmpDRU4lQTtAK/3VPPDX+vxN/czLbVP+46pTWem4sQBsD+/15iuBDNxL9jefjmrjE0TPj43V6IDy0OXjZW4iTwcDqcMgBIx/Mj90PTk/mRY0D3dAaNTWOfT6k/jXoxx+bHIe4n3Vnsr7KMLwj1Wsf7cx2fdT1X+vlyav8GcbD+Ab0bxRv8puClAAAAAElFTkSuQmCC' readStream)]
]

{ #category : #resources }
PaintBoxMorph class >> imageLibrary [
	^ImageLibrary ifNil: [ImageLibrary := IdentityDictionary new]
]

{ #category : #'class initialization' }
PaintBoxMorph class >> initialize [
	"PaintBoxMorph initialize"

	Prototype := ColorChart := ImageLibrary := nil.


]

{ #category : #resources }
PaintBoxMorph class >> lineIcon [
	^self imageLibrary at: #lineIcon ifAbsentPut: [(Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAABYAAAAVCAMAAAB1/u6nAAADAFBMVEX///8AAAD///9/f3//AAAA/wAAAP8A/////wAAAAAfHx8/Pz9fX1+enp6+vr7e3t4HBwcPDw8XFxcnJycvLy83NzdHR0dPT09XV1dnZ2dvb293d3eGhoaOjo6Wlpampqaurq62trbGxsbOzs7W1tbm5ubu7u729vYAAAAAMgAAZQAAmAAAywAA/wAAADIAMjIAZTIAmDIAyzIA/zIAAGUAMmUAZWUAmGUAy2UA/2UAAJgAMpgAZZgAmJgAy5gA/5gAAMsAMssAZcsAmMsAy8sA/8sAAP8AMv8AZf8AmP8Ay/8A//8yAAAyMgAyZQAymAAyywAy/wAyADIyMjIyZTIymDIyyzIy/zIyAGUyMmUyZWUymGUyy2Uy/2UyAJgyMpgyZZgymJgyy5gy/5gyAMsyMssyZcsymMsyy8sy/8syAP8yMv8yZf8ymP8yy/8y//9lAABlMgBlZQBlmABlywBl/wBlADJlMjJlZTJlmDJlyzJl/zJlAGVlMmVlZWVlmGVly2Vl/2VlAJhlMphlZZhlmJhly5hl/5hlAMtlMstlZctlmMtly8tl/8tlAP9lMv9lZf9lmP9ly/9l//+YAACYMgCYZQCYmACYywCY/wCYADKYMjKYZTKYmDKYyzKY/zKYAGWYMmWYZWWYmGWYy2WY/2WYAJiYMpiYZZiYmJiYy5iY/5iYAMuYMsuYZcuYmMuYy8uY/8uYAP+YMv+YZf+YmP+Yy/+Y///LAADLMgDLZQDLmADLywDL/wDLADLLMjLLZTLLmDLLyzLL/zLLAGXLMmXLZWXLmGXLy2XL/2XLAJjLMpjLZZjLmJjLy5jL/5jLAMvLMsvLZcvLmMvLy8vL/8vLAP/LMv/LZf/LmP/Ly//L////AAD/MgD/ZQD/mAD/ywD//wD/ADL/MjL/ZTL/mDL/yzL//zL/AGX/MmX/ZWX/mGX/y2X//2X/AJj/Mpj/ZZj/mJj/y5j//5j/AMv/Msv/Zcv/mMv/y8v//8sAAAD/Mv//Zf//mP//y//////eTOgfAAABAHRSTlP///////////8A////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AP//////OE00OwAAAF5JREFUeF6V0LEOgDAIBNB2dmmiSRPhq/ncTlbRSuEGvfGFELjUGkpqn3mviGktgLty5EsD03aqZ531zFnV8aMz50LgnTE7sdGbpd9gdXB991rmhV2DogHFCu77H4cc4R6SttzoBIUAAAAASUVORK5CYII=' readStream)) offset: -5@ -17; yourself]
]

{ #category : #resources }
PaintBoxMorph class >> lineIconImage [
	^self imageLibrary at: #lineIcon ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAABYAAAAVCAMAAAB1/u6nAAADAFBMVEX///8AAAD///9/f3//AAAA/wAAAP8A/////wAAAAAfHx8/Pz9fX1+enp6+vr7e3t4HBwcPDw8XFxcnJycvLy83NzdHR0dPT09XV1dnZ2dvb293d3eGhoaOjo6Wlpampqaurq62trbGxsbOzs7W1tbm5ubu7u729vYAAAAAMgAAZQAAmAAAywAA/wAAADIAMjIAZTIAmDIAyzIA/zIAAGUAMmUAZWUAmGUAy2UA/2UAAJgAMpgAZZgAmJgAy5gA/5gAAMsAMssAZcsAmMsAy8sA/8sAAP8AMv8AZf8AmP8Ay/8A//8yAAAyMgAyZQAymAAyywAy/wAyADIyMjIyZTIymDIyyzIy/zIyAGUyMmUyZWUymGUyy2Uy/2UyAJgyMpgyZZgymJgyy5gy/5gyAMsyMssyZcsymMsyy8sy/8syAP8yMv8yZf8ymP8yy/8y//9lAABlMgBlZQBlmABlywBl/wBlADJlMjJlZTJlmDJlyzJl/zJlAGVlMmVlZWVlmGVly2Vl/2VlAJhlMphlZZhlmJhly5hl/5hlAMtlMstlZctlmMtly8tl/8tlAP9lMv9lZf9lmP9ly/9l//+YAACYMgCYZQCYmACYywCY/wCYADKYMjKYZTKYmDKYyzKY/zKYAGWYMmWYZWWYmGWYy2WY/2WYAJiYMpiYZZiYmJiYy5iY/5iYAMuYMsuYZcuYmMuYy8uY/8uYAP+YMv+YZf+YmP+Yy/+Y///LAADLMgDLZQDLmADLywDL/wDLADLLMjLLZTLLmDLLyzLL/zLLAGXLMmXLZWXLmGXLy2XL/2XLAJjLMpjLZZjLmJjLy5jL/5jLAMvLMsvLZcvLmMvLy8vL/8vLAP/LMv/LZf/LmP/Ly//L////AAD/MgD/ZQD/mAD/ywD//wD/ADL/MjL/ZTL/mDL/yzL//zL/AGX/MmX/ZWX/mGX/y2X//2X/AJj/Mpj/ZZj/mJj/y5j//5j/AMv/Msv/Zcv/mMv/y8v//8sAAAD/Mv//Zf//mP//y//////eTOgfAAABAHRSTlP///////////8A////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AP//////OE00OwAAAF5JREFUeF6V0LEOgDAIBNB2dmmiSRPhq/ncTlbRSuEGvfGFELjUGkpqn3mviGktgLty5EsD03aqZ531zFnV8aMz50LgnTE7sdGbpd9gdXB991rmhV2DogHFCu77H4cc4R6SttzoBIUAAAAASUVORK5CYII=' readStream)]
]

{ #category : #notification }
PaintBoxMorph class >> localeChanged [
	| caption |
	caption := ColorPickerMorph noColorCaption.
	ColorChart ifNotNil: [
		caption displayOn: ColorChart at: ColorChart boundingBox topCenter - (caption width // 2 @ 0)].
]

{ #category : #'instance creation' }
PaintBoxMorph class >> new [

	| pb |
	pb := self prototype veryDeepCopy.
		"Assume that the PaintBox does not contain any scripted Players!"
	pb stampHolder normalize.	"Get the stamps to show"
	"Get my own copies of the brushes so I can modify them"
	#(brush1: brush2: brush3: brush4: brush5: brush6:) do: [:sel | | dualUse button |
		button := pb submorphNamed: sel.
		button offImage: button offImage deepCopy.
		dualUse := button onImage == button pressedImage.	"sometimes shared"
		button onImage: button onImage deepCopy.
		dualUse
			ifTrue: [button pressedImage: button onImage]
			ifFalse: [button pressedImage: button pressedImage deepCopy].
		].
	pb showColor.
	pb fixUpRecentColors.
	pb addLabels.
	^ pb
]

{ #category : #'instance creation' }
PaintBoxMorph class >> newPrototype [
	^self basicNew buildAPrototype
]

{ #category : #resources }
PaintBoxMorph class >> paintIcon [
	^self imageLibrary at: #paintIcon ifAbsentPut: [(Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAACwAAAAnCAMAAABDnVrwAAADAFBMVEX///8AAAD///9/f3//AAAA/wAAAP8A/////wAAAAAfHx8/Pz9fX1+enp6+vr7e3t4HBwcPDw8XFxcnJycvLy83NzdHR0dPT09XV1dnZ2dvb293d3eGhoaOjo6Wlpampqaurq62trbGxsbOzs7W1tbm5ubu7u729vYAAAAAMgAAZQAAmAAAywAA/wAAADIAMjIAZTIAmDIAyzIA/zIAAGUAMmUAZWUAmGUAy2UA/2UAAJgAMpgAZZgAmJgAy5gA/5gAAMsAMssAZcsAmMsAy8sA/8sAAP8AMv8AZf8AmP8Ay/8A//8yAAAyMgAyZQAymAAyywAy/wAyADIyMjIyZTIymDIyyzIy/zIyAGUyMmUyZWUymGUyy2Uy/2UyAJgyMpgyZZgymJgyy5gy/5gyAMsyMssyZcsymMsyy8sy/8syAP8yMv8yZf8ymP8yy/8y//9lAABlMgBlZQBlmABlywBl/wBlADJlMjJlZTJlmDJlyzJl/zJlAGVlMmVlZWVlmGVly2Vl/2VlAJhlMphlZZhlmJhly5hl/5hlAMtlMstlZctlmMtly8tl/8tlAP9lMv9lZf9lmP9ly/9l//+YAACYMgCYZQCYmACYywCY/wCYADKYMjKYZTKYmDKYyzKY/zKYAGWYMmWYZWWYmGWYy2WY/2WYAJiYMpiYZZiYmJiYy5iY/5iYAMuYMsuYZcuYmMuYy8uY/8uYAP+YMv+YZf+YmP+Yy/+Y///LAADLMgDLZQDLmADLywDL/wDLADLLMjLLZTLLmDLLyzLL/zLLAGXLMmXLZWXLmGXLy2XL/2XLAJjLMpjLZZjLmJjLy5jL/5jLAMvLMsvLZcvLmMvLy8vL/8vLAP/LMv/LZf/LmP/Ly//L////AAD/MgD/ZQD/mAD/ywD//wD/ADL/MjL/ZTL/mDL/yzL//zL/AGX/MmX/ZWX/mGX/y2X//2X/AJj/Mpj/ZZj/mJj/y5j//5j/AMv/Msv/Zcv/mMv/y8v//8sAAAD/Mv//Zf//mP//y//////eTOgfAAABAHRSTlP///////////8A////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AP//////OE00OwAAATNJREFUeF7d1KFywzAMBuCN9griLLnF7Rxs5DcJcZDZYKmRQ8pSVBZsFFS2ZwgK6mMUJU9QNMXLunV3sTwwMuHvdDrZ+h8er+H1f7EpaTA2WhcmEFfaWl2UQXiyXWeKKgC3YG03jDYAb7WBvv04Xs44Bmu7EWyPz1xN9vJhMWy+WwS7RdysH7duaTBwH/Dczg7QOMex/hz4jH8kZ4fbwF5czQMPPf5Ft7P96ruMmXvle7uEaVTcLc2H11FEyp99F/AKLOGge/wGnY1jzlvsYPPNc+osIQly3XmmklSCJYI85X68kUpJKMEJT5g/N/I4AalUTWW8ZkjIpEKArU9vJ8X8idRcM07EbCkSXw3jHKza13uZYVl3EICnMaR68Qdj0+wOx+NrpqA3DUjR5jeR+3c4oN4B/GzJ0c+GFaAAAAAASUVORK5CYII=' readStream)) offset: 0@0; yourself]
]

{ #category : #resources }
PaintBoxMorph class >> paintIconImage [
	^self imageLibrary at: #paintIcon ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAACwAAAAnCAMAAABDnVrwAAADAFBMVEX///8AAAD///9/f3//AAAA/wAAAP8A/////wAAAAAfHx8/Pz9fX1+enp6+vr7e3t4HBwcPDw8XFxcnJycvLy83NzdHR0dPT09XV1dnZ2dvb293d3eGhoaOjo6Wlpampqaurq62trbGxsbOzs7W1tbm5ubu7u729vYAAAAAMgAAZQAAmAAAywAA/wAAADIAMjIAZTIAmDIAyzIA/zIAAGUAMmUAZWUAmGUAy2UA/2UAAJgAMpgAZZgAmJgAy5gA/5gAAMsAMssAZcsAmMsAy8sA/8sAAP8AMv8AZf8AmP8Ay/8A//8yAAAyMgAyZQAymAAyywAy/wAyADIyMjIyZTIymDIyyzIy/zIyAGUyMmUyZWUymGUyy2Uy/2UyAJgyMpgyZZgymJgyy5gy/5gyAMsyMssyZcsymMsyy8sy/8syAP8yMv8yZf8ymP8yy/8y//9lAABlMgBlZQBlmABlywBl/wBlADJlMjJlZTJlmDJlyzJl/zJlAGVlMmVlZWVlmGVly2Vl/2VlAJhlMphlZZhlmJhly5hl/5hlAMtlMstlZctlmMtly8tl/8tlAP9lMv9lZf9lmP9ly/9l//+YAACYMgCYZQCYmACYywCY/wCYADKYMjKYZTKYmDKYyzKY/zKYAGWYMmWYZWWYmGWYy2WY/2WYAJiYMpiYZZiYmJiYy5iY/5iYAMuYMsuYZcuYmMuYy8uY/8uYAP+YMv+YZf+YmP+Yy/+Y///LAADLMgDLZQDLmADLywDL/wDLADLLMjLLZTLLmDLLyzLL/zLLAGXLMmXLZWXLmGXLy2XL/2XLAJjLMpjLZZjLmJjLy5jL/5jLAMvLMsvLZcvLmMvLy8vL/8vLAP/LMv/LZf/LmP/Ly//L////AAD/MgD/ZQD/mAD/ywD//wD/ADL/MjL/ZTL/mDL/yzL//zL/AGX/MmX/ZWX/mGX/y2X//2X/AJj/Mpj/ZZj/mJj/y5j//5j/AMv/Msv/Zcv/mMv/y8v//8sAAAD/Mv//Zf//mP//y//////eTOgfAAABAHRSTlP///////////8A////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AP//////OE00OwAAATNJREFUeF7d1KFywzAMBuCN9griLLnF7Rxs5DcJcZDZYKmRQ8pSVBZsFFS2ZwgK6mMUJU9QNMXLunV3sTwwMuHvdDrZ+h8er+H1f7EpaTA2WhcmEFfaWl2UQXiyXWeKKgC3YG03jDYAb7WBvv04Xs44Bmu7EWyPz1xN9vJhMWy+WwS7RdysH7duaTBwH/Dczg7QOMex/hz4jH8kZ4fbwF5czQMPPf5Ft7P96ruMmXvle7uEaVTcLc2H11FEyp99F/AKLOGge/wGnY1jzlvsYPPNc+osIQly3XmmklSCJYI85X68kUpJKMEJT5g/N/I4AalUTWW8ZkjIpEKArU9vJ8X8idRcM07EbCkSXw3jHKza13uZYVl3EICnMaR68Qdj0+wOx+NrpqA3DUjR5jeR+3c4oN4B/GzJ0c+GFaAAAAAASUVORK5CYII=' readStream)]
]

{ #category : #resources }
PaintBoxMorph class >> paletteImage [
	^self imageLibrary at: #paletteImage ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'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' readStream)]
]

{ #category : #resources }
PaintBoxMorph class >> paletteOnImage [
	^self imageLibrary at: #paletteOnImage ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'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' readStream)]
]

{ #category : #resources }
PaintBoxMorph class >> polygonIcon [
	^self imageLibrary at: #polygonIcon ifAbsentPut: [(Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAABsAAAAVCAMAAACAAGUXAAADAFBMVEX///8AAAD///9/f3//AAAA/wAAAP8A/////wAAAAAfHx8/Pz9fX1+enp6+vr7e3t4HBwcPDw8XFxcnJycvLy83NzdHR0dPT09XV1dnZ2dvb293d3eGhoaOjo6Wlpampqaurq62trbGxsbOzs7W1tbm5ubu7u729vYAAAAAMgAAZQAAmAAAywAA/wAAADIAMjIAZTIAmDIAyzIA/zIAAGUAMmUAZWUAmGUAy2UA/2UAAJgAMpgAZZgAmJgAy5gA/5gAAMsAMssAZcsAmMsAy8sA/8sAAP8AMv8AZf8AmP8Ay/8A//8yAAAyMgAyZQAymAAyywAy/wAyADIyMjIyZTIymDIyyzIy/zIyAGUyMmUyZWUymGUyy2Uy/2UyAJgyMpgyZZgymJgyy5gy/5gyAMsyMssyZcsymMsyy8sy/8syAP8yMv8yZf8ymP8yy/8y//9lAABlMgBlZQBlmABlywBl/wBlADJlMjJlZTJlmDJlyzJl/zJlAGVlMmVlZWVlmGVly2Vl/2VlAJhlMphlZZhlmJhly5hl/5hlAMtlMstlZctlmMtly8tl/8tlAP9lMv9lZf9lmP9ly/9l//+YAACYMgCYZQCYmACYywCY/wCYADKYMjKYZTKYmDKYyzKY/zKYAGWYMmWYZWWYmGWYy2WY/2WYAJiYMpiYZZiYmJiYy5iY/5iYAMuYMsuYZcuYmMuYy8uY/8uYAP+YMv+YZf+YmP+Yy/+Y///LAADLMgDLZQDLmADLywDL/wDLADLLMjLLZTLLmDLLyzLL/zLLAGXLMmXLZWXLmGXLy2XL/2XLAJjLMpjLZZjLmJjLy5jL/5jLAMvLMsvLZcvLmMvLy8vL/8vLAP/LMv/LZf/LmP/Ly//L////AAD/MgD/ZQD/mAD/ywD//wD/ADL/MjL/ZTL/mDL/yzL//zL/AGX/MmX/ZWX/mGX/y2X//2X/AJj/Mpj/ZZj/mJj/y5j//5j/AMv/Msv/Zcv/mMv/y8v//8sAAAD/Mv//Zf//mP//y//////eTOgfAAABAHRSTlP///////////8A////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AP//////OE00OwAAAI9JREFUeF6dkU0OhCAMhWXrOAmo0IxM5lIeQs/jcbvyp7appOPCBwuSj34vgQpxz4JGKnzOFsq/ufkNsad0sWATeCf5FqxOfBvc68qGIAxdKJgHYT1LT5YVa1hqOEXKc5qx1OgTqdEnUqsPR5LyXKvZh6Q8V8c8ZAlJpW97Rx8o7XZW7JfgWLQBkmJ48+9mVvybrBthz+e6AAAAAElFTkSuQmCC' readStream)) offset: -5@ -4; yourself]
]

{ #category : #resources }
PaintBoxMorph class >> polygonIconImage [
	^self imageLibrary at: #polygonIcon ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAABsAAAAVCAMAAACAAGUXAAADAFBMVEX///8AAAD///9/f3//AAAA/wAAAP8A/////wAAAAAfHx8/Pz9fX1+enp6+vr7e3t4HBwcPDw8XFxcnJycvLy83NzdHR0dPT09XV1dnZ2dvb293d3eGhoaOjo6Wlpampqaurq62trbGxsbOzs7W1tbm5ubu7u729vYAAAAAMgAAZQAAmAAAywAA/wAAADIAMjIAZTIAmDIAyzIA/zIAAGUAMmUAZWUAmGUAy2UA/2UAAJgAMpgAZZgAmJgAy5gA/5gAAMsAMssAZcsAmMsAy8sA/8sAAP8AMv8AZf8AmP8Ay/8A//8yAAAyMgAyZQAymAAyywAy/wAyADIyMjIyZTIymDIyyzIy/zIyAGUyMmUyZWUymGUyy2Uy/2UyAJgyMpgyZZgymJgyy5gy/5gyAMsyMssyZcsymMsyy8sy/8syAP8yMv8yZf8ymP8yy/8y//9lAABlMgBlZQBlmABlywBl/wBlADJlMjJlZTJlmDJlyzJl/zJlAGVlMmVlZWVlmGVly2Vl/2VlAJhlMphlZZhlmJhly5hl/5hlAMtlMstlZctlmMtly8tl/8tlAP9lMv9lZf9lmP9ly/9l//+YAACYMgCYZQCYmACYywCY/wCYADKYMjKYZTKYmDKYyzKY/zKYAGWYMmWYZWWYmGWYy2WY/2WYAJiYMpiYZZiYmJiYy5iY/5iYAMuYMsuYZcuYmMuYy8uY/8uYAP+YMv+YZf+YmP+Yy/+Y///LAADLMgDLZQDLmADLywDL/wDLADLLMjLLZTLLmDLLyzLL/zLLAGXLMmXLZWXLmGXLy2XL/2XLAJjLMpjLZZjLmJjLy5jL/5jLAMvLMsvLZcvLmMvLy8vL/8vLAP/LMv/LZf/LmP/Ly//L////AAD/MgD/ZQD/mAD/ywD//wD/ADL/MjL/ZTL/mDL/yzL//zL/AGX/MmX/ZWX/mGX/y2X//2X/AJj/Mpj/ZZj/mJj/y5j//5j/AMv/Msv/Zcv/mMv/y8v//8sAAAD/Mv//Zf//mP//y//////eTOgfAAABAHRSTlP///////////8A////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AP//////OE00OwAAAI9JREFUeF6dkU0OhCAMhWXrOAmo0IxM5lIeQs/jcbvyp7appOPCBwuSj34vgQpxz4JGKnzOFsq/ufkNsad0sWATeCf5FqxOfBvc68qGIAxdKJgHYT1LT5YVa1hqOEXKc5qx1OgTqdEnUqsPR5LyXKvZh6Q8V8c8ZAlJpW97Rx8o7XZW7JfgWLQBkmJ48+9mVvybrBthz+e6AAAAAElFTkSuQmCC' readStream)]
]

{ #category : #'instance creation' }
PaintBoxMorph class >> prototype [
	"Later we will be a subclass of Model, and it will have a general version of this"
	^ Prototype ifNil: [Prototype := self newPrototype]
]

{ #category : #resources }
PaintBoxMorph class >> rectIcon [
	^self imageLibrary at: #rectIcon ifAbsentPut: [(Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAABUAAAAUCAMAAABVlYYBAAADAFBMVEX///8AAAD///9/f3//AAAA/wAAAP8A/////wAAAAAfHx8/Pz9fX1+enp6+vr7e3t4HBwcPDw8XFxcnJycvLy83NzdHR0dPT09XV1dnZ2dvb293d3eGhoaOjo6Wlpampqaurq62trbGxsbOzs7W1tbm5ubu7u729vYAAAAAMgAAZQAAmAAAywAA/wAAADIAMjIAZTIAmDIAyzIA/zIAAGUAMmUAZWUAmGUAy2UA/2UAAJgAMpgAZZgAmJgAy5gA/5gAAMsAMssAZcsAmMsAy8sA/8sAAP8AMv8AZf8AmP8Ay/8A//8yAAAyMgAyZQAymAAyywAy/wAyADIyMjIyZTIymDIyyzIy/zIyAGUyMmUyZWUymGUyy2Uy/2UyAJgyMpgyZZgymJgyy5gy/5gyAMsyMssyZcsymMsyy8sy/8syAP8yMv8yZf8ymP8yy/8y//9lAABlMgBlZQBlmABlywBl/wBlADJlMjJlZTJlmDJlyzJl/zJlAGVlMmVlZWVlmGVly2Vl/2VlAJhlMphlZZhlmJhly5hl/5hlAMtlMstlZctlmMtly8tl/8tlAP9lMv9lZf9lmP9ly/9l//+YAACYMgCYZQCYmACYywCY/wCYADKYMjKYZTKYmDKYyzKY/zKYAGWYMmWYZWWYmGWYy2WY/2WYAJiYMpiYZZiYmJiYy5iY/5iYAMuYMsuYZcuYmMuYy8uY/8uYAP+YMv+YZf+YmP+Yy/+Y///LAADLMgDLZQDLmADLywDL/wDLADLLMjLLZTLLmDLLyzLL/zLLAGXLMmXLZWXLmGXLy2XL/2XLAJjLMpjLZZjLmJjLy5jL/5jLAMvLMsvLZcvLmMvLy8vL/8vLAP/LMv/LZf/LmP/Ly//L////AAD/MgD/ZQD/mAD/ywD//wD/ADL/MjL/ZTL/mDL/yzL//zL/AGX/MmX/ZWX/mGX/y2X//2X/AJj/Mpj/ZZj/mJj/y5j//5j/AMv/Msv/Zcv/mMv/y8v//8sAAAD/Mv//Zf//mP//y//////eTOgfAAABAHRSTlP///////////8A////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AP//////OE00OwAAAG5JREFUeF6VkNEKgCAMRfV1L7mMRhZ9tJ+7p+ZyZCCIRxhyuNyH65gL99mQTqeSlwMwoLLG4KslpL08PWgWIn9Eswg9G8bZbZCNE9lub7+hm80IKdk4F5j1gq0j32pJVtFtdB4Sm1+aYq5Z/jNjH9oIHun4V1LxAAAAAElFTkSuQmCC' readStream)) offset: -6@ -17; yourself]
]

{ #category : #resources }
PaintBoxMorph class >> rectIconImage [
	^self imageLibrary at: #rectIcon ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAABUAAAAUCAMAAABVlYYBAAADAFBMVEX///8AAAD///9/f3//AAAA/wAAAP8A/////wAAAAAfHx8/Pz9fX1+enp6+vr7e3t4HBwcPDw8XFxcnJycvLy83NzdHR0dPT09XV1dnZ2dvb293d3eGhoaOjo6Wlpampqaurq62trbGxsbOzs7W1tbm5ubu7u729vYAAAAAMgAAZQAAmAAAywAA/wAAADIAMjIAZTIAmDIAyzIA/zIAAGUAMmUAZWUAmGUAy2UA/2UAAJgAMpgAZZgAmJgAy5gA/5gAAMsAMssAZcsAmMsAy8sA/8sAAP8AMv8AZf8AmP8Ay/8A//8yAAAyMgAyZQAymAAyywAy/wAyADIyMjIyZTIymDIyyzIy/zIyAGUyMmUyZWUymGUyy2Uy/2UyAJgyMpgyZZgymJgyy5gy/5gyAMsyMssyZcsymMsyy8sy/8syAP8yMv8yZf8ymP8yy/8y//9lAABlMgBlZQBlmABlywBl/wBlADJlMjJlZTJlmDJlyzJl/zJlAGVlMmVlZWVlmGVly2Vl/2VlAJhlMphlZZhlmJhly5hl/5hlAMtlMstlZctlmMtly8tl/8tlAP9lMv9lZf9lmP9ly/9l//+YAACYMgCYZQCYmACYywCY/wCYADKYMjKYZTKYmDKYyzKY/zKYAGWYMmWYZWWYmGWYy2WY/2WYAJiYMpiYZZiYmJiYy5iY/5iYAMuYMsuYZcuYmMuYy8uY/8uYAP+YMv+YZf+YmP+Yy/+Y///LAADLMgDLZQDLmADLywDL/wDLADLLMjLLZTLLmDLLyzLL/zLLAGXLMmXLZWXLmGXLy2XL/2XLAJjLMpjLZZjLmJjLy5jL/5jLAMvLMsvLZcvLmMvLy8vL/8vLAP/LMv/LZf/LmP/Ly//L////AAD/MgD/ZQD/mAD/ywD//wD/ADL/MjL/ZTL/mDL/yzL//zL/AGX/MmX/ZWX/mGX/y2X//2X/AJj/Mpj/ZZj/mJj/y5j//5j/AMv/Msv/Zcv/mMv/y8v//8sAAAD/Mv//Zf//mP//y//////eTOgfAAABAHRSTlP///////////8A////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AP//////OE00OwAAAG5JREFUeF6VkNEKgCAMRfV1L7mMRhZ9tJ+7p+ZyZCCIRxhyuNyH65gL99mQTqeSlwMwoLLG4KslpL08PWgWIn9Eswg9G8bZbZCNE9lub7+hm80IKdk4F5j1gq0j32pJVtFtdB4Sm1+aYq5Z/jNjH9oIHun4V1LxAAAAAElFTkSuQmCC' readStream)]
]

{ #category : #resources }
PaintBoxMorph class >> rotationTabImage [
	^self imageLibrary at: #rotationTabImage ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAABcAAAAXCAYAAADgKtSgAAAABHNCSVQFBQUBSsjp7wAAAwZJREFUeF6VlS2UpDAQhCORSCQSiUQikUgkEolEIpFIJBKJRCKRSOTIkchxfVX5Ydnd2b27vNdvZjbJ19WVTlb9Np7rKkfbypplskSRTEEgUxjKlCSy1JXs8yzqf8e577IXuWxhIFtgYkUsiJkJECOiD3wZkOifkzynSXao3AHWEZhwCVySjwSBtEgyNc3vCR59r4HH17gl2L5UMCA635cG0Zel/KiYoIeOUAdBNTZFnicRqonjWEL8TvGbwNmpx/cWUTFBXcs3j4840uAnAGdRyJSmElERyt0xf56njsfjITM8TuA1kwwEBgZOIYXvyTyOHwmOPDdgqD2rUuau00q3bZPX6/VjMHGklIZ3Fl4iclRDEercVu2zhkewAxsytN5xHBeECwkqUFEJX0coc3P8nVubGgvPWBEEqkfbXF4TPqCKu+IVvR5Z70co7K3nFECbns+neFDfXMo9Da/BUTtVXnC0FZTcS8/g/dbUOvFh25P9T7U1Dk+vAYNeOzjnctiqNrvJeI6TRzkOzApaHPSZJXrewdeQrejrzuG6FreY1dQAO+UJ5tRqN7gEXOjgPfqeXt7Bs+2MKTAtSmu4LsH3CuDCwmOEWqB8u12YlK2IDYQPwyAlFl122K7w8Deq9vHJdVVVaWBp4awipvIlTXSZLgEXsY+5iYcVoT0HQDm/Br5WzgPmQbuDZ7LUwnP7PcU+teF1W+xmBkG8IM4aqo89dYFpR3IT4OzjfQnQNdpvRIFGUAcWcQMTrCGTmD5lX7tOaHnrLJjtSG/Z37SPyXnhCI6tan527iGbklhvnG2SWatTkiI7VTsoq+JtbACn37QstGpph1MdYX6HZeb6L7PeOFp1Luhhh3BgHqa5iQZW3Hy+wHfVbiy4qb2F3KPXt9IkoT2Nb/pZW2MTOHDsvH43RvhIQHcDvoXalss/gWEP2lg/WD+NCVe6trDmBv0E9r6Diyz9HezGilevxmGVFuaU3tWmFhr7bzz+6/9SqJjwzrR43Uq0WhaY1zDh9WZiKCX06oo34w9N0ZSkQD6ZeQAAAABJRU5ErkJggg==' readStream)]
]

{ #category : #resources }
PaintBoxMorph class >> scaleTabImage [
	^self imageLibrary at: #scaleTabImage ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAABcAAAAXCAYAAADgKtSgAAAABHNCSVQFBQUBSsjp7wAAAr9JREFUeF6VlSGUo0AQRJHISCQSiUQikUgkEolEIpHISCQSGYlEIpFIJBLXVzVpcvOyZHPHe7UDZPOrp6e74/x27eMoS13LnCQyBoEMnie970sfRfIoC5mHQZz/vfZ5liVLZfa9p7ynRsgYQB3Ueje5w+ifTba+lzUMZAV0Ua0ALdCkBg81MQa3m9RQX1W/G2xta6AbtJvVN/cr1kWjtw3MDgCmQeW60mbZtcHOiC3wAeCuosl6ATcpUngNeOE40haF/MgxU2HAgS9HFMoRhsbgNDFpuooe4DvUAF4CnkLD/f7XYE1TBSPiOJKjLKEC97Hk+GKGSslgFgMW4ZkKKQADyAcwhypdE3y2rqs4+zSaQyP8YNSokqPrnsIWE0Bn7gz/vCyLubfFdymCSy14zPQ0jThrXb1y/YLjg6Op5UgTqfJc9n2X4zg+qkAQNjzhit5wFvxZ9RBNWpjvJJYd4n2DJvoGzxHAOzzGOTkTol2sKqEBD/VUi/r9Bs9Qgu9wnoczno1iGTzQeT1XHGSOfA7oQKpHuW7b9gPOnBPIask05wHkjIhutgwoVgLz2KKpGuS/Rmr4HOJw+fwJXig8esFRepPOkLPdWXJX26dZhTRdwWNNSarwEAxnQj0zDTQ4FeGDq+2fu7jKeaRRJxp1ih5xFuYScBqMPoT1N3iML9GgRKMxVVw9NpcVNZuqxnvToT1KjgaDmoTQFZxpCTXCVBUrMNH7UOHzND3hy2OQO4Adq8R7tjY7kiVoi5ET2DAyrY7cMjnBzfv4feBFe3MxhDArXOQNZcjqsMXtn/VcfACn+PG4HLtdnmHwu9Lc4O5a0kgrK9rsAhwjIDOwPl0dDqlQyLsKC5pY9expdawYYl9/6h6Yx2bUKswGngd4RuujzetvP3HvF6PocIAlBluKIRRxdjNSrCxVRkrodFbFxfUHM1HXoyHv+TYAAAAASUVORK5CYII=' readStream)]
]

{ #category : #resources }
PaintBoxMorph class >> shapeTabImage [
	^self imageLibrary at: #shapeTabImage ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAACUAAAAXCAYAAACMLIalAAAABHNCSVQFBQUBSsjp7wAAAmFJREFUeF7FlCGQpDAQRZHIkStPjkSuHHlyJRKJRCKRSCQSiYyMRCKRSGQkclxf/w4ZAlu3M2zVsqn6RRFI5/XvTgKtChqHlqaxJTMpuhstmkZFfVdT2xbU1Dm1TUFBEFJWdw/lTS8q2sETz9Wa0rJ9zGHd0DeicWi+3MuYiQ5DORCBcVpg3HucFhS9/2W4jt+7X4JalDNAkld0eXujK0NllRLXToVa1QlAnOYCdItThqulhJg/Hwq9xQLQNXpnh24Us1sWqvkFKAHSlBWlfAMQYJIFKmOn8uqM8i3OWClKMjt/+0gozsrVpaI5safclcAOAOjPNeKy3SxQVgmUAMElBjrl9Nk7SlNZN7Zkke0hAcosUFoq+QfXRHnGPZWwAzhdm5ItDiWFPXFwCD0HoFKNPw8V88bR7UPuIQeDpwVa+mi5t0p1EhR6KeWN4QhArJrHneRueOdSdTaU9I8HZBt7KdujdBg/DHUJLxuFYfhUWKdV9TrUMGgvC/vzjJ9nLU8swLyfqS/Vllaq5I1X4d19QwwIsffx8Y64+A/JG2MomGezs3ZdhCwcGLID3F5u7VcyO6Bt0i11eq3IPM+25NPUi33/c8tlBCHIUfkws9kmiz3hLNpjmlwP8gAdoByYH+juBfHhjsgH8uMMXJlOVw+XpHT+MGbcgPmO+Rl+R3sY5xCA0EufXPLHNA1S3xVscW1Un5w7CuVgbB/WrwH5jmEBtHVude+o3IHoBaaW60FOJZvwFMjvMSzAYr0AOshXTtteXWed2cIMhJMfHB33+8zWG852tIFGqP+GLATizOY5yD+ABou9MdPjbQAAAABJRU5ErkJggg==' readStream)]
]

{ #category : #resources }
PaintBoxMorph class >> shapesImage [
	^self imageLibrary at: #shapesImage ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'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' readStream)]
]

{ #category : #resources }
PaintBoxMorph class >> shapesOnImage [
	^self imageLibrary at: #shapesOnImage ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'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' readStream)]
]

{ #category : #resources }
PaintBoxMorph class >> stampTabImage [
	^self imageLibrary at: #stampTabImage ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAADMAAAAWCAYAAABtwKSvAAAABHNCSVQFBQUBSsjp7wAAA6tJREFUeF69ViuwqzAURFYikUgkEhkZiUQiI5FIJLISWYlEIisrkUhkJLLuvLNJU0J75777PoWZnbTAJmd3T9IG49DQPPW0zD3pZaC7Hg2WeaDbtaO+b+jS1dRfGgqCExVVYVEXVNblDrjnYO41JSmgVTtU54rBn8/q7ZkPrDfdLgbzdPm2Rq0X+jsxLwVjbHjszznVSvA7uX3uCUHxVoQF7p353tAVdK4llRXm2zh45/Ni6pdUHmJ0J+k+KhqrjPIspryUT0G+CIe2LWk9C8OZGkkqi54c1ZZHi9mSQVpKRNTIxIxpdKJMpJSr/CFGvQuCCWlItYwNRHyiJLGCnAGHiFEQ4vYOI+e2UqUgyQXFYUDhKWAxGUlXGLdNDUHP/VAaM5TieTgRcCLmxHFEspDGJBjwcTEVF7HUKS2t4PYQNHCLFEVGV/5cipjiBIh2yXRtQbrJDOfWSurRViz+xmPDqaRpYjgpc+SRyZScQhOHNGQhTVVKMxeJtkKbpFxQnMaUZAmJQtj2w2bmsY0CusqIZjbiUqbMCUgmoUkFYt44h7QZ2ordy+OYFBdScVECe4TFZCwm4cIyuTnsTrOSUyq4jSrmlMzJnpzQiDFJeqkck0xt9wiKFZL3RRRSwf2ehyiQwakJrzD12Pz4vSlYkMSzkE3h94vIcThZTmY7MFhMd4SYxm5el5DIM8rY2fwhSqJt0HZpZIrffiQhSBme5HYSHudphDnNxHFtZsQ4GFGPlCAKG5j3TM7pSEbORTun60tNNc+Dz7iHFHBygSeRCgsBB8nZ0+wAMXDX/8vhhJmkXIEsAu4/24ZbpmF+01tAmPsXYLm5SRmm+JyPiwlP4Q6n0+kPERqEPwDWG4fzz8VM0+ipty+veHkdzQgC7vsO+Rj61mJoeeEN+P585j2/jmdTALCfr7emPoy1GAxQ02td+A4+5obZWmsK1lW/RLmRoN4JwuRuQR+O+z26By5fmLKfzxeiX4TsTe7ZmK1z1nXlJPlalpvn1Hs6zglgW+wT2Cfhi1j13lzUiqTR/ssyWyG4oMqP3vWmm+Cu30X9f/D8y7gr/iuY9uJE0a4uFdNi/qX1/NLL/ZfOfBzrhlcRLhEIwV55S8W/lmUyfehvTpPSPLwl9b/xXRLbIdT9TIifEAhfnzr9B9tseBbuHzhY+2ZEdOaYhhCY/lsh/h4CAeTxIcyJ+9np9W9wJl6vNom9iIlwAgd/et3vK0et2bHZTjQDtwNhi8f6q/69gF+MUOdTGgYgKwAAAABJRU5ErkJggg==' readStream)]
]

{ #category : #resources }
PaintBoxMorph class >> stampsImage [
	^self imageLibrary at: #stampsImage ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAAGgAAABOCAYAAADM6VOKAAAABHNCSVQFBQUBSsjp7wAADypJREFUeF7lXSuUqz4Tr6xEVlZWIpGRSGQkMhIZiaxEIiuRlZUrV1ZWVlZW1uWbyQOSEB7d+y/7nWXPmbP3tiGTmd+8EpLs5nIuxe3aiPutEY/7WbweF0n321l8f9WiaUpxqrloTqXYbLYi2kZv01bS9scUbX/Gd3pc2/+IlIxzeKIOL+dKXL9PoPfTqN4fj7t4GyBaZEDUJd5R7pH8XLfL4NmMjRNFMjzafnKRl7lgkphgR5eKqmiJVf3vgwT9YJ+SsH9vrMNkjdXXhT1ehzr9oA4RnP8coFMLUBic4MDK4YEGnyvHgRgDpkBg5oLzExoCdIBMm+73hwFqQgD1BuQqug/SCEAGGF8xFZPKV1SMkP2cNQYH9HwE4KG+XOpkm/C4QDTJFwVoCBwfIKACBLvXVLzOQKdMfBWxONJY5Bgq7HDmec44IC5h+8upEK8mA6LifiSiyQ+Cs9RSmAbrjf59L+LwWStL3clC80Do64X9fKEQx2d4jwXS1Qj0zcXrUojHMZXKY/EWQKKdUAaktwFioobfr5qI1xf8/gI+Jyq+eSKO6U4wSnRu04rSPKa90gMJnrtJWXItCxgeyHICWXKUBUBK89QCakGAWg+akUP80HLnsVQYgvNqALAyFRVFoXYi3m2l9aFgCJJt5UGF1R5pgC5lJp5VCspjkh4VFWeWCE72ItltRJomImt50DbcvQMQx0hQWrKccvFdEikLjSMpS4ayUAQp9UDKfwcgOgaQ/pyTSNTZXlxAYRdOwOJiUYDi0kMkDtFGJEksCFi5EWjUwnvgKAWWoJAq3UvP/CqIOBfgPRkqbieS/VbstgBSRjRIdNwIBgAqIMSVE7IQArIAHwXSEgCd5njQcJEglQFKkVYMQqDCkDKwOLKPxB6EiuODSMDCbS96J8TJtkAx8CAABvZt+CBPtGwESPLQipvNw6viKEVZtq4sByXLzpJFGpyWZ3GA8sCcpw+WVeWgQshBChZbdACKNqBUEEgpj3jKm1+5ybBV5KCoTcdjv23BiYBibd3SsmWYG+LBOmDs6s3II8NmX5YtyJKQpOVj8pHKfX2AkD7qQSUMmqOgCMpAuYkDxIFijqghVmMYiLYWaaGCAB1V1VQBlZXKAf35ifJW5MXgWcxvaN073bcBZxdtHYAkoJYRVBAyj8jDgKPzpx8N8NnLMRNVpmXZdLIogOI+QL8R4nDwT0iYj2MiblDSXqGa+cLqDIA48gysOVOJEgZ5O6nyGqud+LAXMeScA/zeYYjbQ6GQDIU4Jr5qBnwS4EPEDYqAKyjnAgVAXaKBKONAxZ1g7vMAPtguBc/BvIaE/SOfQ2KFnkAYVbIQWZXdKiifgU9zpOIIPAquVhAwEhhZ0Nji2JJlp2Rx+PghrlwAIBO6GgDhxg7iAcp7gmDPiqjfABj++wVUQNLOwJJQmDMkbk52sprag0BIBxCwFcgJPXlbNV0h2WMV+ND9Kj6KJ/K4wncpWCzPYtFA4sakLRM25ALZv+bReo8uEvwq7lb4siSdLPAZg7BGUZZcyVIkKAtpZZHyWHzsIsHOy4sAJMMDMC9gQBW4eXPYiq9sJ64A2I0ra8c5iInPqUyiW1kQYJWzDyguNdWVnX8QJPi8hD5qKADOUEFd6R6UGUO5m8iymspSfSMrtbYg0JWhBGmUh5V3jCyxKwsC9lW4siStLIljaMgnyRIPnF8CyCR/CkKnsKLLIP4eQVE1JOlLshFUJ+hkrwRCIiAEhgMFkFGcXVnRdiXBKXExx4AyKPDgoJhqh0YBvECZicdD/pvErtKGqjerXJeFAEya+7Jsg7KkOrS1siSxE9oyL7SZnLYsQJhnECAQHgecRpHIQDgKCZOBgDmWvT5Ih52y7pBlB+YmLUDIEyeBEOdTzSOPFJ9Ue5BNOB6pNC+0OTwAHG4DpIuNjFiyRO/IEvCedsLOlgLIWvi0qjS0HCyXMxgwCpZrBaJgFBW408rbKUpBKGJyz8TkUZXReWcQEPszUCB6lOSh+SBQscWHQDhKR3hwkAtJeVFnCFImfOYNWVQeTfqltQMQ+3yZba8QUN69HzEgyYEi7ZQCW0sHSiNLOC1gRrtyVIaf0qxgu0s5cqKoQZK80PNQgRCSkIexdOrwiNQEGRSISzB+9cZrA1LAi5gxOuAzVxZZHISrNwPS5z2ot5TTeZIKd0RaEgKF7p/tdo5wSERPIlGBcvYPcZwOhCAHpNaTqF7zUl6bQg6Q4cjyqCzqWzoqsO9FYyBlrTzEk4UNyJKCLJlei+utoi8OkDeJ80MegiRjMwhHIXdIS7eE61kgtB0KQ74C0TAyy5sMUHm07Vl63HqTCntyZSPIg7fLOy0P1vGQ0YH0ZaEDsoRy0WIAmaTXAyoU9tCjiErYMixBcs1BYQwXMLebLpajJzE/DIHiThZpJfYs3VIizosohDVUJNspwJJIFRIxKhQsfIxHMehNHQ8jCx2SJdkH89EiAA2+ku4B1SlPhQotnBFQK5JhZQa/zbuhbhmmU14J/A31gOJ5kBfR+ZACH4ZhEPhkaeytxfk8LEOoi26hlA8D5ctCtCyhig51+P1dfw6gufsFnFfDJkf5Csx0fNfJtSsWLICM4hqPNFBFIPQ5OVHzU6SWnmjACBAYu/8hj80HDM8s+JpqjlAy6EEfBojNAqi/Eux6laPAXCmu9z6o1gAZxcFYj+ejJB+orlwuXJ69nTjUWU7q8QgYwVjfSg4DVtoaQgeO9aZ4MYCGwKi6EpmFNl+UbHSbk/s6um/ZBpwWpLOvUGP1/rucwAYSP4SGALJBsry1rSgDBZKzhazwXrN/pIpr3gAouGOGhXfJlGOK05YdUt65dIE5h5TahSfuKdXeIcSN94x4UOkXKHX/Tas/5Qjuk9OyLQPQkHLLn+85C4FrV1fBPDTD6n2l2q/OexViiOwyvx7eTBLaXpb3JqoL7EkI7TnIp159zyRn31rFensQWmXX7twlREVAobM2ofggVDM2Mto5lg9t7PxUmR0AKNZvDT9JS/FBZS/Bx4D1eYC4Ulxzfn6MYj0LX4IPKm4JPqaq+zMA4TxiEcUtxMfMixbZF7eEQIb+Ch/zWn+RvdlLCIRvKpfgY97sfpyPfmf0ZwDa4W6fP8THGMKfASiCl2R/iQ9uLlk/QOsHaEGAouhP8dnrDZvrB2j9AK0foPUDtH6A1g/Q+gFaP0DrB2j9AK0foPUDtH6A1g/Q+gFaP0DrB2j9a3HrXyxdP0Drfx+0JECfJvNG9a/wWe6NqndmxjBHC7GPpM+i2CVzKtuc+exRYvEyz0302Ws3xCcN8zlM9Tchn+G13J4Ee3e/dQzjx9aVxt2RlPZ0gD4xQC3K3OMrXR9gJGka6DdRFOSreemTFQ4fc0wmS3rjMsdN3pXRyLTIrp7w2Z/UUWJQwRapUwBpewrAJ2cTunfPqToUpk/VsUpk1UMkRQMKJZIUD9UGP8fvSVG13yfW2BS/4ftTQ2PrTjF0pxnIBNmnHZbZ+muBRGdcFJu1Nytmg9dH+ltk84HTexm0R4WT40Nk9Uvkpxf8v5GASOW1PKlIy7P8Htth+4QdW/AMMIp/+KbI3tVrQ/cRFdn4hbnWDYzL7c3mI4LMuOgvH9tsX3V3lXYnCJhI+VHE/Cb2/CWi4iWS40tQUD56SmqUrhWOlJYX9f1Rtcfn8Pkk5xogDc67G//9fdnB/er+pbIL7s2e3gQ/foZoaiM79zay0yMXO/YtNuwlNvlTEfw7Ll8irRRA0iukRxijYBIg/B7b+c9G+Zcgee5cDcOOUzc7Bu6qqyZObZTuzVmLAjR52q6avjWxdzLBOvbBqlIc8pPYpGdNF7HJAKjsCop+SI8gCAA7QV5RHiQBKpXHEQhx+D22w/byOXwe+9F97rJKpAXzjv/z4OHl3smJ+n3QFgNoDJgxD+E+KAPnchCcbQZKTGqxiUtFyVFsSK2UC8reQtiKIXwd8hoqJUzIKsQZDyL8LL/HdhIcfA6fx37aPmvJJysUqIMATYE159bgpQBikwCxkfDFh73m5HsQFwdqlFmIzQEo5hqoRmzoXeUWWsuSmshT1SavMJEAQPg9tpPtJTBc91PIfiPCO2DLLsyNjcul/0OAJkGq2GSOmQOQERCte5/yTrkHpVzpEQhSWsm5jQ/QoVDfy3bY/tCBvI2hz0RfTqGfG72fYQCg8XD3iyHuR2FuCKB6HCBUHFp4THOxTTRQxpNA+REpwwAxHQ6N50hgCrGLCczyzf1u+rh8MQOgt07x/XIOmvKiovoHkGoboEIq20yMEYRDChO+BPNHBaHrBB7EdQ5K2zJbApSr72U7AGlPMlh2iSW1M3z7sgk/xNVD4PQrzbl/WmDxMjv49xZmgjR11nToSha5SgCWv09B4LSBSqzsJp9WFRczLAAayGNcPZMSmavUMg/xwPHvkZtx/rV+/28//Mo86O2C4V9Aahdrs25Jh1JnkmoAopzL/+PndntnJYEH7qkbHE8x43Dy+LxokbU4f3VgumCYA1IxeVq7d2+O9ChNFjhm0mlWIAxIblva3U/ngDNmMP8GzjIT1YHlm9FJ64zVgzGQeOBPAeTOrSVmHIZf0dFE29E5Wshz3iipQxdN/RpAc9azin8EKvQ3G1xDGJrZj7Rt+RX/FtaqseWeT9766wG0fvp3egug6/ViPaAaP7Hx8yJ/4wP4uX0Rqs1gjEw7ZPiFdKnE5XwU58ZQKYHHwSCde3SU7fGP8uGz2Me3pqu+MWrOOPzxmDF96zGpcfljAzob/orOA9/j8924bJ6NMn7tAIrOklDPvq7x//g89o1O8XjA+uHz+fAQ7R5CRA1I2Lli6AveTJBWzvUUALm2KPRZHTSMsJHMG8fteprscx71xzc0FhuchweO6wwNgN1FrecTVt7x537/ttDve5FBF8mAtX6aS67H2MA8H64ToP7RIzGq3O83BQ7+IFK2i5q4aDp4WR22dL84TNdPIVJ6ej7GSYY28DwMlcZ7ZHizfx6PmxdHmyDaMvQ9L/3P10/D9AzrzUQk1DeCg7mn5z32z/1+lTHQTnbSm25911w/QNM05jFd8VXPA8f2JFPZ9CsTL+GtP4zNIpOHTKElq0gJTC2rRwQHnWMSHDsn4QOy9NRg2YAZ0NZP86kt69vphg3MVWA1vXn35/V6gks+wApuqqPbVf/+Xj/9mJQOUafPxzQo/wMcEe7O1bJ7FwAAAABJRU5ErkJggg==' readStream)]
]

{ #category : #resources }
PaintBoxMorph class >> stampsOnImage [
	^self imageLibrary at: #stampsOnImage ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'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' readStream)]
]

{ #category : #resources }
PaintBoxMorph class >> starIcon [
	^self imageLibrary at: #starIcon ifAbsentPut: [(Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAABgAAAAUCAMAAACgaw2xAAADAFBMVEX///8AAAD///9/f3//AAAA/wAAAP8A/////wAAAAAfHx8/Pz9fX1+enp6+vr7e3t4HBwcPDw8XFxcnJycvLy83NzdHR0dPT09XV1dnZ2dvb293d3eGhoaOjo6Wlpampqaurq62trbGxsbOzs7W1tbm5ubu7u729vYAAAAAMgAAZQAAmAAAywAA/wAAADIAMjIAZTIAmDIAyzIA/zIAAGUAMmUAZWUAmGUAy2UA/2UAAJgAMpgAZZgAmJgAy5gA/5gAAMsAMssAZcsAmMsAy8sA/8sAAP8AMv8AZf8AmP8Ay/8A//8yAAAyMgAyZQAymAAyywAy/wAyADIyMjIyZTIymDIyyzIy/zIyAGUyMmUyZWUymGUyy2Uy/2UyAJgyMpgyZZgymJgyy5gy/5gyAMsyMssyZcsymMsyy8sy/8syAP8yMv8yZf8ymP8yy/8y//9lAABlMgBlZQBlmABlywBl/wBlADJlMjJlZTJlmDJlyzJl/zJlAGVlMmVlZWVlmGVly2Vl/2VlAJhlMphlZZhlmJhly5hl/5hlAMtlMstlZctlmMtly8tl/8tlAP9lMv9lZf9lmP9ly/9l//+YAACYMgCYZQCYmACYywCY/wCYADKYMjKYZTKYmDKYyzKY/zKYAGWYMmWYZWWYmGWYy2WY/2WYAJiYMpiYZZiYmJiYy5iY/5iYAMuYMsuYZcuYmMuYy8uY/8uYAP+YMv+YZf+YmP+Yy/+Y///LAADLMgDLZQDLmADLywDL/wDLADLLMjLLZTLLmDLLyzLL/zLLAGXLMmXLZWXLmGXLy2XL/2XLAJjLMpjLZZjLmJjLy5jL/5jLAMvLMsvLZcvLmMvLy8vL/8vLAP/LMv/LZf/LmP/Ly//L////AAD/MgD/ZQD/mAD/ywD//wD/ADL/MjL/ZTL/mDL/yzL//zL/AGX/MmX/ZWX/mGX/y2X//2X/AJj/Mpj/ZZj/mJj/y5j//5j/AMv/Msv/Zcv/mMv/y8v//8sAAAD/Mv//Zf//mP//y//////eTOgfAAABAHRSTlP///////////8A////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AP//////OE00OwAAAKlJREFUeF51kTsSwyAMRNkWU8gQrOEzuV5yHh+XKsIEE2aIqkVPQlpQpaxDTSc3g7MfGHEJIsEtAdiNFnW2EGmpxNFydaQU2QMs00Fu45AaeJWyA/YhMjlRBDTw1kR5LBoA331Y2Dufj5rvBv1NMtdZw7nH1kSCmZ4k4OgVzwkYhCaOr0d1P1NOrGmTCi7zDA1UE+7aaQBISu4wFU2A9u8MQ3rxUX9/8Cc+919bKkV5meQAAAAASUVORK5CYII=' readStream)) offset: -2@ -5; yourself]
]

{ #category : #resources }
PaintBoxMorph class >> starIconImage [
	^self imageLibrary at: #starIcon ifAbsentPut: [Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes:
		'iVBORw0KGgoAAAANSUhEUgAAABgAAAAUCAMAAACgaw2xAAADAFBMVEX///8AAAD///9/f3//AAAA/wAAAP8A/////wAAAAAfHx8/Pz9fX1+enp6+vr7e3t4HBwcPDw8XFxcnJycvLy83NzdHR0dPT09XV1dnZ2dvb293d3eGhoaOjo6Wlpampqaurq62trbGxsbOzs7W1tbm5ubu7u729vYAAAAAMgAAZQAAmAAAywAA/wAAADIAMjIAZTIAmDIAyzIA/zIAAGUAMmUAZWUAmGUAy2UA/2UAAJgAMpgAZZgAmJgAy5gA/5gAAMsAMssAZcsAmMsAy8sA/8sAAP8AMv8AZf8AmP8Ay/8A//8yAAAyMgAyZQAymAAyywAy/wAyADIyMjIyZTIymDIyyzIy/zIyAGUyMmUyZWUymGUyy2Uy/2UyAJgyMpgyZZgymJgyy5gy/5gyAMsyMssyZcsymMsyy8sy/8syAP8yMv8yZf8ymP8yy/8y//9lAABlMgBlZQBlmABlywBl/wBlADJlMjJlZTJlmDJlyzJl/zJlAGVlMmVlZWVlmGVly2Vl/2VlAJhlMphlZZhlmJhly5hl/5hlAMtlMstlZctlmMtly8tl/8tlAP9lMv9lZf9lmP9ly/9l//+YAACYMgCYZQCYmACYywCY/wCYADKYMjKYZTKYmDKYyzKY/zKYAGWYMmWYZWWYmGWYy2WY/2WYAJiYMpiYZZiYmJiYy5iY/5iYAMuYMsuYZcuYmMuYy8uY/8uYAP+YMv+YZf+YmP+Yy/+Y///LAADLMgDLZQDLmADLywDL/wDLADLLMjLLZTLLmDLLyzLL/zLLAGXLMmXLZWXLmGXLy2XL/2XLAJjLMpjLZZjLmJjLy5jL/5jLAMvLMsvLZcvLmMvLy8vL/8vLAP/LMv/LZf/LmP/Ly//L////AAD/MgD/ZQD/mAD/ywD//wD/ADL/MjL/ZTL/mDL/yzL//zL/AGX/MmX/ZWX/mGX/y2X//2X/AJj/Mpj/ZZj/mJj/y5j//5j/AMv/Msv/Zcv/mMv/y8v//8sAAAD/Mv//Zf//mP//y//////eTOgfAAABAHRSTlP///////////8A////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////AP//////OE00OwAAAKlJREFUeF51kTsSwyAMRNkWU8gQrOEzuV5yHh+XKsIEE2aIqkVPQlpQpaxDTSc3g7MfGHEJIsEtAdiNFnW2EGmpxNFydaQU2QMs00Fu45AaeJWyA/YhMjlRBDTw1kR5LBoA331Y2Dufj5rvBv1NMtdZw7nH1kSCmZ4k4OgVzwkYhCaOr0d1P1NOrGmTCi7zDA1UE+7aaQBISu4wFU2A9u8MQ3rxUX9/8Cc+919bKkV5meQAAAAASUVORK5CYII=' readStream)]
]

{ #category : #preferences }
PaintBoxMorph class >> useLargeColorPicker [
	<preference: 'Use large color picker'
	category: 'Morphic'
	description: 'If true, then the color picker of the paint box will be large and 32bits deep.'
	type: #Boolean>
	^UseLargeColorPicker ifNil: [ false ]
]

{ #category : #preferences }
PaintBoxMorph class >> useLargeColorPicker: aBoolean [
	UseLargeColorPicker = aBoolean
		ifFalse:
			[ColorChart := nil.
			ImageLibrary ifNotNil: [ImageLibrary
				removeKey: #colorMemoryImage ifAbsent: [];
				removeKey: #colorMemoryThinImage ifAbsent: []]].
	UseLargeColorPicker := aBoolean
]

{ #category : #actions }
PaintBoxMorph >> action [
	^ action	
]

{ #category : #actions }
PaintBoxMorph >> actionCursor [
	"Return the cursor to use with this painting action/tool. Offset of the form must be set."

	^self
		cursorFor: action
		oldCursor: currentCursor
		currentNib: self getNib
		color: currentColor

]

{ #category : #initialization }
PaintBoxMorph >> addActionsOffImage: offImage onImage: onImage [
	| posSpec actionSpec |
	posSpec := #(
		(53 53 53 53) "offset X"
		(154 178 202 226) "offset Y"
		(39 39 39 39) "width"
		(23 23 23 23) "height").
	actionSpec := #(undo:with:evt: keep:with:evt: clear:with:evt: toss:with:evt:).
	#(undo: keep: clear: toss:) keysAndValuesDo: [:index :name |
		| button rect |
		(self submorphNamed: name) ifNil:
			[rect := ((posSpec at: 1) at: index) @ ((posSpec at: 2) at: index)
					extent: ((posSpec at: 3) at: index) @ ((posSpec at: 4) at: index).
			(button := ThreePhaseButtonMorph new)
				onImage: (onImage copy: rect);
				offImage: (offImage copy: rect);
				pressedImage: (onImage copy: rect);
				bounds: (rect translateBy: self position);
				setNamePropertyTo: name;
				actionSelector: (actionSpec at: index); 
					arguments: (Array with: button with: name);
				actWhen: #buttonUp; target: self.
			self addMorph: button.]].
]

{ #category : #initialization }
PaintBoxMorph >> addBrushesOffImage: offImage [
	| posSpec |
	posSpec := #(
		(13 37 64 13 37 64) "offset X"
		(107 107 107 124 124 124) "offset Y"
		(21 24 27 21 24 27) "width"
		(18 18 18 25 25 25) "height").
	#(brush1: brush2: brush3: brush4: brush5: brush6: ) keysAndValuesDo: [:index :name |
		| button nib rect on off |
		(self submorphNamed: name) ifNil:
			[nib := Form dotOfSize: (#(1 2 3 6 11 26) at: index).
			rect := ((posSpec at: 1) at: index) @ ((posSpec at: 2) at: index)
					extent: ((posSpec at: 3) at: index) @ ((posSpec at: 4) at: index).
			off := (offImage copy: rect) as8BitColorForm.
			"highlight a frame"
			on := off deepCopy.
			(on getCanvas copyOrigin: 0@0 clipRect: (0@0 extent: rect extent))
				frameAndFillRectangle: (0@0 extent: rect extent) fillColor: Color transparent
				borderWidth: 2 borderColor: (Color r: 0.6 g: 0.8 b: 1.0).
			(button := ThreePhaseButtonMorph new)
				onImage: on;
				offImage: off;
				pressedImage: on;
				bounds: (rect translateBy: self position);
				setNamePropertyTo: name;
				actionSelector: #brush:action:nib:evt:; 
					arguments: (Array with: button with: name with: nib);
				actWhen: #buttonUp; target: self.
			self addMorph: button.]].
	brushes := #(brush1: brush2: brush3: brush4: brush5: brush6: ) collect: [:name | self submorphNamed: name].
	currentBrush := brushes at: 3.
	currentBrush state: #on.


]

{ #category : #other }
PaintBoxMorph >> addCustomMenuItems: aCustomMenu hand: aHandMorph [

	"super addCustomMenuItems: aCustomMenu hand: aHandMorph."
		"don't want the ones from ImageMorph"
	aCustomMenu add: 'grab stamp from screen' translated action: #grabFromScreen:.


]

{ #category : #initialization }
PaintBoxMorph >> addGraphicLabels [
	"translate button labels"

	| formTranslator |
	formTranslator := NaturalLanguageFormTranslator localeID: (Locale current localeID).

	#('KEEP' 'UNDO' 'CLEAR' 'TOSS') do: [:label |
		(formTranslator translate: label, '-off') ifNil: [^ false].
		(formTranslator translate: label, '-pressed') ifNil: [^ false].
	].
	
	#('keep:' 'undo:' 'clear:' 'toss:') with: #('KEEP' 'UNDO' 'CLEAR' 'TOSS') do: [:extName :label |
		| button newForm ext pos |
		button := submorphs detect: [:m | m externalName = extName] ifNone: [nil].
		button ifNotNil: [
			button removeAllMorphs.
			ext := button extent.
			pos := button position.
			(newForm := formTranslator translate: label, '-off') ifNotNil: [
				button offImage: newForm.

			].
			(newForm := formTranslator translate: label, '-pressed') ifNotNil: [
				button pressedImage: newForm.
			].
			button extent: ext.
			button position: pos.
		].
	].

	^ true.

]

{ #category : #initialization }
PaintBoxMorph >> addLabels [

	Preferences useFormsInPaintBox ifFalse: [
		self addTextualLabels.
	] ifTrue: [
		self addGraphicLabels ifFalse: [self addTextualLabels].
	].

]

{ #category : #initialization }
PaintBoxMorph >> addShapeButtonsOffImage: offImage onImage: onImage [
	| shapes posSpec iconSpec |
	posSpec := #(
		(17 17 17 17 17) "offset X"
		(0 22 44 66 88) "offset Y"
		(30 30 30 30 30) "width"
		(21 21 21 21 21) "height").
	shapes := self submorphNamed: 'shapes'.
	iconSpec := #(lineIcon rectIcon ellipseIcon polygonIcon starIcon).
	#(line: rect: ellipse: polygon: star:) keysAndValuesDo: [:index :name |
		| button rect |
		(self submorphNamed: name) ifNil:
			[rect := ((posSpec at: 1) at: index) @ ((posSpec at: 2) at: index)
					extent: ((posSpec at: 3) at: index) @ ((posSpec at: 4) at: index).
			(button := ThreePhaseButtonMorph new)
				onImage: (onImage copy: rect);
				offImage: (offImage copy: rect);
				pressedImage: (onImage copy: rect);
				bounds: (rect translateBy: shapes position);
				setNamePropertyTo: name;
				actionSelector: #tool:action:cursor:evt:; 
					arguments: (Array with: button with: name with: (self class perform: (iconSpec at: index)));
				actWhen: #buttonUp; target: self.
			shapes addMorph: button.]].
]

{ #category : #initialization }
PaintBoxMorph >> addStampButtonsOffImage: offImage onImage: onImage [
	| stamps posSpec actionSpec argSpec names |
	posSpec := #(
		(13 38 63 13 38 63 37 55) "offset X"
		(0 0 0 25 25 25 51 51) "offset Y"
		(25 25 25 25 25 25 15 15) "width"
		(25 25 25 25 25 25 15 15) "height").
	actionSpec := #(
		pickup:action:cursor:evt: pickup:action:cursor:evt: pickup:action:cursor:evt:
		pickup:action:cursor:evt: pickup:action:cursor:evt: pickup:action:cursor:evt:
		scrollStamps:action:evt: scrollStamps:action:evt:).
	argSpec := #(
		stamp: stamp: stamp:
		stamp: stamp: stamp:
		prevStamp: nextStamp:).
	names := #(
		pickup: pickup: pickup:
		stamp: stamp: stamp:
		prevStamp: nextStamp:).
	stamps := self submorphNamed: 'stamps'.
	names keysAndValuesDo: [:index :name |
		| button rect |
		(self submorphNamed: name) ifNil:
			[rect := ((posSpec at: 1) at: index) @ ((posSpec at: 2) at: index)
					extent: ((posSpec at: 3) at: index) @ ((posSpec at: 4) at: index).
			(button := ThreePhaseButtonMorph new)
				onImage: (onImage copy: rect);
				offImage: (offImage copy: rect);
				pressedImage: (onImage copy: rect);
				bounds: (rect translateBy: stamps position);
				setNamePropertyTo: name;
				actionSelector: (actionSpec at: index); 
					arguments: ((Array with: button with: (argSpec at: index) with: Cursor origin) first: (actionSpec at: index) numArgs - 1);
				actWhen: #buttonUp; target: self.
			stamps addMorph: button.]].
]

{ #category : #initialization }
PaintBoxMorph >> addStampsAndShapes [
	| shapeTab shapes stampTab stamps |
	(stampTab := ThreePhaseButtonMorph new)
		onImage: self class stampTabImage;
		offImage: self class stampTabImage;
		pressedImage: self class stampTabImage;
		setNamePropertyTo: 'stampTab';
		actionSelector: #toggleStamps; target: self;
		position: self position + (9@image height);
		bounds: (stampTab position extent: stampTab onImage extent).
	self addMorph: stampTab.
	
	(shapeTab := ThreePhaseButtonMorph new)
		onImage: self class shapeTabImage;
		offImage: self class shapeTabImage;
		pressedImage: self class shapeTabImage;
		setNamePropertyTo: 'shapeTab';
		actionSelector: #toggleShapes; target: self;
		position: self position + (image width - shapeTab onImage width-9@image height);
		bounds: (shapeTab position extent: shapeTab onImage extent).
	self addMorph: shapeTab.
	
	self layoutChanged.
	
	(stamps := self class stampsImage asMorph)
		setNamePropertyTo: 'stamps';
		visible: false;
		position: self position + (0@(image height - stamps image height)).
	self addMorph: stamps.
	
	(shapes := self class shapesImage asMorph)
		setNamePropertyTo: 'shapes';
		visible: false;
		position: self position + (image width - shapes image width@image height).
	self addMorph: shapes.
]

{ #category : #initialization }
PaintBoxMorph >> addTextualLabels [
	"Translate button labels. Use unscaled font because of #beSupersized."

	#('keep:' 'undo:' 'clear:' 'toss:') with: #('KEEP' 'UNDO' 'CLEAR' 'TOSS') do: [:extName :label |
		| button |
		button := submorphs detect: [:m | m externalName = extName] ifNone: [nil].
		button ifNotNil: [
			button removeAllMorphs.
			button addMorph: (TextMorph new 
				contentsWrapped: (Text string: label translated
					attributes: {
						TextAlignment centered. 
						TextEmphasis bold.
						TextFontReference toFont: (StrikeFont familyName: 'Bitmap DejaVu Sans' size: 12)
							});
				bounds: (button bounds translateBy: 0@3);
				lock)]]
]

{ #category : #initialization }
PaintBoxMorph >> addToolsOffImage: offImage onImage: onImage [
	| posSpec actionSpec iconSpec |
	posSpec := #(
		(13 53 13 53) "offset X"
		(13 13 61 61) "offset Y"
		(40 40 40 40) "width"
		(48 48 44 44) "height").
	actionSpec := #(tool:action:cursor:evt: tool:action:cursor:evt: eyedropper:action:cursor:evt: tool:action:cursor:evt:).
	iconSpec := #(paintIcon fillIcon eyedropperIcon eraseIcon).
	#(paint: fill: eyedropper: erase:) keysAndValuesDo: [:index :name |
		| button rect |
		(self submorphNamed: name) ifNil:
			[rect := ((posSpec at: 1) at: index) @ ((posSpec at: 2) at: index)
					extent: ((posSpec at: 3) at: index) @ ((posSpec at: 4) at: index).
			(button := ThreePhaseButtonMorph new)
				onImage: (onImage copy: rect);
				offImage: (offImage copy: rect);
				pressedImage: (onImage copy: rect);
				bounds: (rect translateBy: self position);
				setNamePropertyTo: name;
				actionSelector: (actionSpec at: index); 
					arguments: (Array with: button with: name with: (self class perform: (iconSpec at: index)));
				actWhen: #buttonUp; target: self.
			index = 1
				ifTrue:
					[action := name.
					tool := button.
					currentCursor := button arguments at: 3].
			self addMorph: button.]].


]

{ #category : #initialization }
PaintBoxMorph >> addWeakDependent: anObject [

	weakDependents ifNil: [^weakDependents := WeakArray with: anObject].
	weakDependents := weakDependents,{anObject} reject: [ :each | each isNil].
]

{ #category : #initialization }
PaintBoxMorph >> beStatic [

	colorMemory ifNotNil: [colorMemory beStatic].
]

{ #category : #initialization }
PaintBoxMorph >> beSupersized [
	| scaleFactor |
	scaleFactor := RealEstateAgent scaleFactor.
	self isFlexed
		ifFalse: [self scaleFactor: scaleFactor.
			self position: self position / scaleFactor.
			self changed]
]

{ #category : #actions }
PaintBoxMorph >> brush: brushButton action: aSelector nib: aMask evt: evt [ 
	"Set the current tool and action for the paintBox.  "

	currentBrush 
		ifNotNil: [currentBrush == brushButton ifFalse: [currentBrush state: #off]].
	currentBrush := brushButton.	"A ThreePhaseButtonMorph"

	"currentBrush state: #on.	already done"
	"aSelector is like brush3:.  Don't save it.  Can always say (currentBrush arguments at: 2)
	aMask is the brush shape.  Don't save it.  Can always say (currentBrush arguments at: 3)"
	self notifyWeakDependentsWith: { 
				#currentNib.
				evt.
				currentBrush arguments third}.
	self brushable ifFalse: [self setAction: #paint: evt: evt]	"User now thinking of painting"
]

{ #category : #actions }
PaintBoxMorph >> brushable [
	"Return true if the current tool uses a brush."
	^ (#("non-brushable" eyedropper: fill: pickup: stamp:) indexOf: action) = 0
]

{ #category : #initialization }
PaintBoxMorph >> buildAPrototype [
	| onImage |
	self initialize.
	self image: self class paletteImage.
	rotationTabForm := self class rotationTabImage.
	scaleTabForm := self class scaleTabImage.
	(colorMemoryThin := self class colorMemoryThinImage asMorph)
		setNamePropertyTo: 'ColorPickerClosed';
		position: self position + (11@150);
		on: #mouseEnter send: #showColorPalette: to: self.
	self addMorph: colorMemoryThin.
	(colorMemory := PaintBoxColorPicker new image: self class colorMemoryImage)
		setNamePropertyTo: 'ColorPickerOpened';
		on: #mouseDown send: #takeColorEvt:from: to: self.
	currentColor := Color black.
	
	onImage := self class paletteOnImage.
	self
		addToolsOffImage: image onImage: onImage;
		addBrushesOffImage: image;
		addActionsOffImage: image onImage: onImage;
		addStampsAndShapes;
		addShapeButtonsOffImage: self class shapesImage onImage: self class shapesOnImage;
		addStampButtonsOffImage: self class stampsImage onImage: self class stampsOnImage.
	stampHolder := ScrollingToolHolder newPrototypeFor: self.
]

{ #category : #actions }
PaintBoxMorph >> clear: clearButton with: clearSelector evt: evt [

	| ss |
	(ss := self focusMorph) 
		ifNotNil: [ss clearPainting: self]
		ifNil: [self notCurrentlyPainting].
	clearButton state: #off.
]

{ #category : #other }
PaintBoxMorph >> colorMemory [

	^ colorMemory
]

{ #category : #other }
PaintBoxMorph >> colorMemory: aMorph [

	colorMemory := aMorph
]

{ #category : #actions }
PaintBoxMorph >> colorable [
	"Return true if the current tool uses a color."
	^ (#("These use no color" erase: eyedropper: "fill: does" pickup: stamp:) indexOf: action) = 0
]

{ #category : #actions }
PaintBoxMorph >> currentColor: aColor evt: evt [
	"Accept a color from the outside.  (my colorMemoryMorph must call takeColorEvt: evt from: colorPicker instead)"

	currentColor := aColor.
	colorMemory currentColor: aColor.
	self notifyWeakDependentsWith: {#currentColor. evt. currentColor}.
	self showColor.
	self colorable ifFalse: [self setAction: #paint: evt: evt].	"User now thinking of painting"
]

{ #category : #actions }
PaintBoxMorph >> cursorFor: anAction oldCursor: oldCursor currentNib: aNibForm color: aColor [ 
	"Return the cursor to use with this painting action/tool. Offset of the 
	form must be set."

	| ff width co larger c box |

	anAction == #paint:
		ifTrue: ["Make a cursor from the brush and the color"
			width := aNibForm width.
			c := self ringColorFor: aColor.
			co := oldCursor offset - (width // 4 @ 34 - (width // 6)) min: 0 @ 0.
			larger := width negated + 10 @ 0 extent: oldCursor extent + (width @ width).
			ff := oldCursor copy: larger.
			ff colors at: 1 put: Color transparent.
			ff colors at: 2 put: Color transparent.
			ff offset: co - (width @ width // 2).
			ff getCanvas
				fillOval: (Rectangle center: ff offset negated extent: width @ width)
				color: Color transparent
				borderWidth: 1
				borderColor: c.
			^ ff].
	anAction == #erase:
		ifTrue: ["Make a cursor from the cursor and the color"
			width := aNibForm width.
			co := oldCursor offset + (width // 2 @ 4) min: 0 @ 0.
			larger := 0 @ 0 extent: oldCursor extent + (width @ width).
			ff := oldCursor copy: larger.
			ff offset: co - (width @ width // 2).
			ff
				fill: (box := co negated extent: width @ width)
				fillColor: (Color r: 0.5 g: 0.5 b: 1.0).
			ff
				fill: (box insetBy: 1 @ 1)
				fillColor: Color transparent.
			^ ff].
	^ oldCursor
]

{ #category : #actions }
PaintBoxMorph >> delete [
			
	^ self isSupersized
		ifTrue: [self owner delete]
		ifFalse: [super delete]
]

{ #category : #actions }
PaintBoxMorph >> deleteCurrentStamp: evt [ 
	"The trash is telling us to delete the currently selected stamp"

	(tool arguments second) == #stamp: 
		ifTrue: 
			[stampHolder remove: tool.
			self setAction: #paint: evt: evt]	"no use stamping with a blank stamp"
]

{ #category : #actions }
PaintBoxMorph >> eyedropper: aButton action: aSelector cursor: aCursor evt: evt [ 
	"Take total control and pick up a color!!"

	| pt feedbackColor delay |
	delay := Delay forMilliseconds: 10.
	aButton state: #on.
	tool ifNotNil: [tool state: #off].
	currentCursor := aCursor.
	evt hand showTemporaryCursor: currentCursor
		hotSpotOffset: 6 negated @ 4 negated.
	"<<<< the form was changed a bit??"
	feedbackColor := Display colorAt: Sensor cursorPoint.
	colorMemory align: colorMemory bounds topRight
		with: colorMemoryThin bounds topRight.
	self addMorphFront: colorMemory.

	"Full color picker"
	[Sensor anyButtonPressed] whileFalse: 
			[pt := Sensor cursorPoint.
			"deal with the fact that 32 bit displays may have garbage in the 
			alpha bits"
			feedbackColor := Display depth = 32 
						ifTrue: 
							[Color colorFromPixelValue: ((Display pixelValueAt: pt) bitOr: 16rFF000000)
								depth: 32]
						ifFalse: [Display colorAt: pt].
			"the hand needs to be drawn"
			evt hand position: pt.
			currentColor ~= feedbackColor ifTrue: [
				currentColor := feedbackColor.
				self showColor ].
			self refreshWorld.
			delay wait].

	"Now wait for the button to be released."
	[Sensor anyButtonPressed] whileTrue:
		[ pt := Sensor cursorPoint.
		"the hand needs to be drawn"
		evt hand position: pt.
		self refreshWorld.
		delay wait].

	evt hand showTemporaryCursor: nil hotSpotOffset: 0 @ 0.
	self currentColor: feedbackColor evt: evt.
	colorMemory delete.
	tool ifNotNil: 
			[tool state: #on.
			currentCursor := tool arguments third].
	aButton state: #off

]

{ #category : #'recent colors' }
PaintBoxMorph >> fixUpColorPicker [
	| chart picker |
	chart := self class colorChart.
	chart getCanvas frameRectangle: chart boundingBox color: Color black.
	picker := Form extent: (chart extent + (14 @ 12)) depth: 16.
	picker fillWhite.
	"top"
	picker copy: (0 @ 0 extent: picker width @ 6)
			from: (colorMemory image width - picker width) @ 0 
			in: colorMemory image rule: Form over.
	"bottom"
	picker copy: (0 @  (picker height - 6) extent: picker width @ 6) 
			from: (colorMemory image width - picker width) @ (colorMemory image height - 7)
			in: colorMemory image rule: Form over.
	"left"
	picker copy: (0 @ 6 corner: 8 @ (picker height - 6))
			from: (colorMemory image boundingBox topLeft + (0 @ 6)) 
			in: colorMemory image rule: Form over.
	"right"
	picker copy: (picker width-6 @ 6 corner: picker width @ (picker height - 6))
			from: (colorMemory image boundingBox topRight - (6 @ -6)) 
			in: colorMemory image rule: Form over.
	chart displayOn: picker at: 8 @ 6.
	picker getCanvas frameRectangle: picker boundingBox color: Color black.
	colorMemory image: picker.

]

{ #category : #'recent colors' }
PaintBoxMorph >> fixUpRecentColors [
	| inner outer border box form newImage canvas morph |
	self fixUpColorPicker.
	recentColors := WriteStream on: Array new.
	form := image.
	newImage := Form extent: form extent + (0 @ 41) depth: form depth.
	form displayOn: newImage.
	newImage 
		copy: (0 @ (form height - 10) 
				extent: form width @ (newImage height - form height + 10))
		from: 0 @ (form height - (newImage height - form height + 10))
		in: form
		rule: Form over.
	canvas := newImage getCanvas.
	canvas 
		line: 12 @ (form height - 10)
		to: 92 @ (form height - 10)
		width: 1
		color: Color black.
	canvas := canvas copyOffset: 12 @ (form height - 9).
	inner := Color 
				r: 0.677
				g: 0.71
				b: 0.968.
	outer := inner darker darker.
	border := Color 
				r: 0.194
				g: 0.258
				b: 0.194.
	0 to: 1
		do: 
			[:y | 
			0 to: 3
				do: 
					[:x | 
					box := (x * 20) @ (y * 20) extent: 20 @ 20.
					morph := BorderedMorph new 
								bounds: ((box insetBy: 1) translateBy: canvas origin + bounds origin).
					morph
						borderWidth: 1;
						borderColor: border.
					morph color: Color white.
					morph 
						on: #mouseDown
						send: #mouseDownRecent:with:
						to: self.
					morph 
						on: #mouseMove
						send: #mouseStillDownRecent:with:
						to: self.
					morph 
						on: #mouseUp
						send: #mouseUpRecent:with:
						to: self.
					self addMorphFront: morph.
					recentColors nextPut: morph.
					canvas fillRectangle: box color: Color white.
					canvas frameRectangle: (box insetBy: 1) color: border.
					canvas frameRectangle: box color: inner.
					box := box insetBy: 1.
					canvas 
						line: box topRight
						to: box bottomRight
						width: 1
						color: outer.
					canvas 
						line: box bottomLeft
						to: box bottomRight
						width: 1
						color: outer]].
	recentColors := recentColors contents.
	(RecentColors isNil or: [RecentColors size ~= recentColors size]) 
		ifTrue: [RecentColors := recentColors collect: [:each | each color]]
		ifFalse: 
			[RecentColors 
				keysAndValuesDo: [:idx :aColor | (recentColors at: idx) color: aColor]].
	self image: newImage.
	self toggleStamps.
	self toggleStamps
]

{ #category : #other }
PaintBoxMorph >> focusMorph [
	"Note: For backward compatibility we search the world for a SketchEditorMorph if the current focus morph is nil"
	^focusMorph ifNil:[focusMorph := self world findA: SketchEditorMorph]
]

{ #category : #other }
PaintBoxMorph >> focusMorph: newFocus [
	"Set the new focus morph"
	focusMorph ifNotNil:[focusMorph paletteDetached: self]. "In case the morph is interested"
	focusMorph := newFocus.
	focusMorph ifNotNil:[focusMorph paletteAttached: self]. "In case the morph is interested"
]

{ #category : #actions }
PaintBoxMorph >> getColor [
	^ currentColor
]

{ #category : #actions }
PaintBoxMorph >> getNib [
	^currentBrush arguments third
]

{ #category : #actions }
PaintBoxMorph >> getSpecial [
	^ action		"a selector like #paint:"
]

{ #category : #actions }
PaintBoxMorph >> grabFromScreen: evt [ 
	"Allow the user to grab a picture from the screen OUTSIDE THE PAINTING AREA and install it in a blank stamp.  To get a stamp in the painting area, click on the stamp tool in a blank stamp."

	"scroll to blank stamp"

	| stampButton form |
	stampButton := stampHolder stampButtons first.
	[(stampHolder stampFormFor: stampButton) isNil] 
		whileFalse: [stampHolder scroll: 1].
	form := Form fromUser.
	tool state: #off.
	tool := stampHolder otherButtonFor: stampButton.
	stampHolder stampForm: form for: tool.	"install it"
	stampButton state: #on.
	stampButton doButtonAction: evt.
	evt hand showTemporaryCursor: (focusMorph getCursorFor: evt)
]

{ #category : #initialization }
PaintBoxMorph >> initialize [
	super initialize.
	colorMemory ifNotNil: [colorMemory on: #mouseDown send: #takeColorEvt:from: to: self].
]

{ #category : #initialization }
PaintBoxMorph >> isSupersized [
	
	^ self isFlexed
]

{ #category : #actions }
PaintBoxMorph >> keep: keepButton with: keepSelector evt: evt [
	"Showing of the corrent palette (viewer or noPalette) is done by the block submitted to the SketchMorphEditor, see (EToyHand makeNewDrawing) and (SketchMorph editDrawingInWorld:forBackground:)."
	| ss |
	owner ifNil: [^ self].
	keepButton ifNotNil: [keepButton state: #off].
	(ss := self focusMorph) 
		ifNotNil: [ss savePainting: self evt: evt]
		ifNil:
		[keepSelector == #silent ifTrue: [^ self].
		self notCurrentlyPainting].
]

{ #category : #initialization }
PaintBoxMorph >> loadJapanesePaintBoxBitmaps [
"
	PaintBoxMorph new loadJapanesePaintBoxBitmaps.
"

	| formTranslator form bb |
	self position: 0@0.
	formTranslator := NaturalLanguageFormTranslator localeID: (LocaleID isoString: 'ja').
	form := Form fromFileNamed: 'offPaletteJapanese(children).form'.

	#('keep:' 'undo:' 'clear:' 'toss:') with: #('KEEP' 'UNDO' 'CLEAR' 'TOSS') do: [:extName :label |
		bb := (self submorphs detect: [:e | e externalName = extName]) bounds.
		formTranslator name: label, '-off' form: (form copy: bb)
	].


	form := Form fromFileNamed: 'pressedPaletteJapanese(children).form'.
	#('keep:' 'undo:' 'clear:' 'toss:') with: #('KEEP' 'UNDO' 'CLEAR' 'TOSS') do: [:extName :label |
		bb := (self submorphs detect: [:e | e externalName = extName]) bounds.
		formTranslator name: label, '-pressed' form: (form copy: bb)
	].

]

{ #category : #other }
PaintBoxMorph >> maxBounds [
	| rr |
	"fullBounds if all flop-out parts of the paintBox were showing."

	rr := bounds merge: colorMemory bounds.
	rr := rr merge: (self submorphNamed: 'stamps') bounds.
	rr := rr origin corner: rr corner + (0@ (self submorphNamed: 'shapes') height 
				+ 10 "what is showing of (self submorphNamed: #toggleShapes) height").
	^ rr
]

{ #category : #'recent colors' }
PaintBoxMorph >> mouseDownRecent: evt with: aMorph [
	aMorph borderColor: Color white.

]

{ #category : #'recent colors' }
PaintBoxMorph >> mouseStillDownRecent: evt with: aMorph [
	(aMorph containsPoint: evt cursorPoint)
		ifTrue:[aMorph borderColor: Color white]
		ifFalse:[aMorph borderColor: (Color r: 0.194 g: 0.258 b: 0.194)]

]

{ #category : #'user interface' }
PaintBoxMorph >> mouseUpBalk: evt [
	"A button I own got a mouseDown, but the user moved out before letting up.  Prevent this for the current tool.  Some tool must stay selected."

	tool state: #on.	"keep current one, even if user balked on it"
	currentBrush ifNotNil: [currentBrush state: #on].
]

{ #category : #'recent colors' }
PaintBoxMorph >> mouseUpRecent: evt with: aMorph [
	aMorph borderColor: (Color r: 0.194 g: 0.258 b: 0.194).
	(aMorph containsPoint: evt cursorPoint) ifTrue:[
		self takeColor: aMorph color event: evt.
	].
]

{ #category : #actions }
PaintBoxMorph >> notCurrentlyPainting [
	self inform: 'You are not currently painting'
]

{ #category : #actions }
PaintBoxMorph >> notifyWeakDependentsWith: arguments [

	weakDependents ifNil: [^self].
	weakDependents do: [ :each |
		each ifNotNil: [
			each paintBoxChanged: arguments.
			each paintBoxChanged: {#changed. arguments second. true}.
		].
	].
]

{ #category : #other }
PaintBoxMorph >> offsetFromMaxBounds [
	"location of normal PaintBox within maxBounds."
	| left |
	left := self left.
	((Preferences canUnderstand: #useBiggerPaintingBox) and: [ Preferences useBiggerPaintingBox ]) ifTrue: [left := left  - (( self width * 1.5)- self width)].
	^ left - colorMemory left @ 0
]

{ #category : #actions }
PaintBoxMorph >> pickup: actionButton action: aSelector cursor: aCursor evt: evt [ 
	"Special version for pickup: and stamp:, because of these tests"

	| ss picker old map stamper |
	self 
		tool: actionButton
		action: aSelector
		cursor: aCursor
		evt: evt.
	aSelector == #stamp: 
		ifTrue: 
			[(stampHolder pickupButtons includes: actionButton) 
				ifTrue: 
					[stamper := stampHolder otherButtonFor: actionButton.
					^self 
						pickup: stamper
						action: #stamp:
						cursor: (stamper arguments third)
						evt: evt].
			(stampHolder stampFormFor: actionButton) ifNil: 
					["If not stamp there, go to pickup mode"

					picker := stampHolder otherButtonFor: actionButton.
					picker state: #on.
					^self 
						pickup: picker
						action: #pickup:
						cursor: (picker arguments third)
						evt: evt]
				ifNotNil: 
					[old := stampHolder stampFormFor: actionButton.
					currentCursor := ColorForm extent: old extent depth: 8.
					old displayOn: currentCursor.
					map := Color indexedColors copy.
					map at: 1 put: Color transparent.
					currentCursor colors: map.
					currentCursor offset: currentCursor extent // -2.
					"Emphisize the stamp button"
					actionButton owner borderColor: (Color 
								r: 0.65
								g: 0.599
								b: 0.8)	"layoutMorph"	"color: (Color r: 1.0 g: 0.645 b: 0.419);"]].
	aSelector == #pickup: 
		ifTrue: 
			[ss := self focusMorph.
			ss ifNotNil: [currentCursor := aCursor]
				ifNil: 
					[self notCurrentlyPainting.
					self setAction: #paint: evt: evt]]
]

{ #category : #actions }
PaintBoxMorph >> pickupForm: stampForm [
	"Install the new picture in this stamp"

	| stampButton |
	stampHolder stampForm: stampForm for: tool.
	stampButton := action == #pickup: 
		ifTrue: [stampHolder otherButtonFor: tool]
		ifFalse: [tool].	"was a nil stampForm"
	stampButton state: #on.
	stampButton doButtonAction.
]

{ #category : #actions }
PaintBoxMorph >> pickupForm: stampForm evt: evt [
	"Install the new picture in this stamp"

	| stampButton |
	stampHolder stampForm: stampForm for: tool.
	stampButton := action == #pickup: 
		ifTrue: [stampHolder otherButtonFor: tool]
		ifFalse: [tool].	"was a nil stampForm"
	stampButton state: #on.
	stampButton doButtonAction: evt.
]

{ #category : #actions }
PaintBoxMorph >> plainCursor [
	"Return the cursor to use with this painting action/tool. Offset of the form must be set."

	^currentCursor

]

{ #category : #actions }
PaintBoxMorph >> plainCursor: aCursor event: anEvent [
	"Set the cursor to use with this painting action/tool. Offset of the form must be set."

	currentCursor := aCursor.
	anEvent hand showTemporaryCursor: aCursor.
	self notifyWeakDependentsWith: {#currentCursor. anEvent. currentCursor}.
]

{ #category : #'recent colors' }
PaintBoxMorph >> recentColor: aColor [ 
	"Remember the color as one of our recent colors"
	Prototype currentColor: aColor.
	(recentColors anySatisfy: [:any | any color = aColor])
		ifTrue: [^self].	"already remembered"
	RecentColors := {aColor}, RecentColors allButLast.
	RecentColors keysAndValuesDo: [:i :each |
		(recentColors at: i) color: each]
]

{ #category : #actions }
PaintBoxMorph >> ringColor [
	"Choose a color that contrasts with my current color. If that color isn't redish, return red. Otherwise, return green"

	^self ringColorFor: currentColor

]

{ #category : #actions }
PaintBoxMorph >> ringColorFor: aColor [
	"Choose a color that contrasts with my current color. If that color isn't redish, return red. Otherwise, return green"

	aColor isTransparent ifTrue: [^ Color red].
	aColor red < 0.5 ifTrue: [^ Color red].
	aColor red > (aColor green + (aColor blue * 0.5))
		ifTrue: [^ Color green]
		ifFalse: [^ Color red].

]

{ #category : #other }
PaintBoxMorph >> rotationTabForm [
	^ rotationTabForm
]

{ #category : #other }
PaintBoxMorph >> scaleTabForm [
	^ scaleTabForm
]

{ #category : #actions }
PaintBoxMorph >> scrollStamps: actionButton action: aSelector evt: evt [
	"Move the stamps over"

	aSelector == #prevStamp:
		ifTrue: [stampHolder scroll: -1]
		ifFalse: [stampHolder scroll: 1].
	actionButton state: #off.
	action == #stamp: ifTrue: ["reselect the stamp and compute the cursor"
		self stampForm 
			ifNil: [self setAction: #paint: evt: evt]
			ifNotNil: [tool doButtonAction: evt]].
		
]

{ #category : #actions }
PaintBoxMorph >> setAction: aSelector evt: evt [
	"Find this button and turn it on.  Does not work for stamps or pickups"

	| button |
	button := self submorphNamed: aSelector.
 
	button ifNotNil: [
		button state: #on.
		button doButtonAction: evt].	"select it!"
]

{ #category : #actions }
PaintBoxMorph >> showColor [
	"Display the current color in all brushes, both on and off."

	| offIndex onIndex center |
	currentColor ifNil: [^self].
	"colorPatch color: currentColor.	May delete later"
	(brushes isNil or: [brushes first owner ~~ self]) 
		ifTrue: 
			[brushes := OrderedCollection new.
			#(#brush1: #brush2: #brush3: #brush4: #brush5: #brush6:) 
				do: [:sel | brushes addLast: (self submorphNamed: sel)]].
	brushes last offImage unhibernate.
	brushes last onImage unhibernate.
	brushes last pressedImage unhibernate.
	center := brushes last offImage extent // 2.
	offIndex := brushes last offImage pixelValueAt: center.
	onIndex := brushes last onImage pixelValueAt: center.
	brushes do: 
			[:bb | 
			bb offImage colors at: offIndex + 1 put: currentColor.
			bb offImage clearColormapCache.
			bb onImage colors at: onIndex + 1 put: currentColor.
			bb onImage clearColormapCache.
			bb invalidRect: bb bounds].
	self invalidRect: (brushes first topLeft rect: brushes last bottomRight)
]

{ #category : #actions }
PaintBoxMorph >> showColorPalette: evt [

	| w box |
	self comeToFront.
	colorMemory align: colorMemory bounds topRight 
			with: colorMemoryThin bounds topRight.
	"make sure color memory fits or else align with left"
	w := self world.
	box := self bounds: colorMemory fullBounds in: w.
	box left < 0 ifTrue:[
		colorMemory align: colorMemory bounds topLeft
			with: colorMemoryThin bounds topLeft].
	self addMorphFront: colorMemory.
	self changed
]

{ #category : #actions }
PaintBoxMorph >> stampCursorBeCursorFor: anAction [
	"User just chose a stamp.  Take that stamp picture and make it be the cursor for the tool named."
	"self stampCursorBeCursorFor: #star:.
	currentCursor offset: -9@-3.			Has side effect on the saved cursor."

	(self submorphNamed: anAction) arguments at: 3 put: currentCursor.
		"Already converted to 8 bits and in the right form"
]

{ #category : #actions }
PaintBoxMorph >> stampDeEmphasize [
	"Turn off an emphasized stamp.  Was turned on in pickup:action:cursor:"

	tool owner class == AlignmentMorph ifTrue: [
		tool "actionButton" owner "layoutMorph" color: Color transparent; 
					borderColor: Color transparent].
]

{ #category : #actions }
PaintBoxMorph >> stampForm [
	"Return the selected stamp"

	^ stampHolder stampFormFor: tool.

]

{ #category : #actions }
PaintBoxMorph >> stampHolder [

	^ stampHolder
]

{ #category : #actions }
PaintBoxMorph >> stampHolder: newOne [

	stampHolder := newOne
]

{ #category : #actions }
PaintBoxMorph >> takeColor: aColor event: evt [
	"Accept the given color programmatically"
	currentColor := aColor.
	self notifyWeakDependentsWith: {#currentColor. evt. currentColor}.
	self showColor.
	self colorable ifFalse: [self setAction: #paint: evt: evt].	"User now thinking of painting"
]

{ #category : #actions }
PaintBoxMorph >> takeColorEvt: evt from: colorPicker [
	"Accept a new color from the colorMemory.  Programs use currentColor: instead.  Do not do this before the picker has a chance to set its own color!"
	^self takeColor: colorPicker currentColor event: evt
]

{ #category : #actions }
PaintBoxMorph >> toggleShapes [
	| tab sh stamps |
	"The sub panel that has the shape tools on it.  Rect, line..."
	stamps := self submorphNamed: 'stamps'.
	tab := self submorphNamed: 'shapeTab'.
	(sh := self submorphNamed: 'shapes') visible
		ifTrue: [sh hide.  tab top: stamps bottom-1]
		ifFalse: [sh comeToFront.  sh top: stamps bottom-9.  
				sh show.  tab top: sh bottom - tab height + 10].
	self layoutChanged.
	self changed

]

{ #category : #actions }
PaintBoxMorph >> toggleStamps [
	| tab otherTab st shapes |
	"The sub panel that has the stamps in it.  For saving and moving parts of an image."
	shapes := self submorphNamed: 'shapes'.
	otherTab := self submorphNamed: 'shapeTab'.
	tab := self submorphNamed: 'stampTab'.
	(st := self submorphNamed: 'stamps') visible
		ifTrue: [st hide.  st bottom: self bottom.  tab top: self bottom-1.
				shapes top: self bottom-9.
				otherTab top: (shapes visible ifTrue: [shapes bottom - otherTab height + 10] 
									ifFalse: [self bottom-1])]
		ifFalse: [st top: self bottom-10.  st show.  tab top: st bottom-0.
				shapes top: st bottom-9.
				otherTab top: (shapes visible ifTrue: [shapes bottom - otherTab height + 10] 
									ifFalse: [st bottom-0])].
	self layoutChanged.
	self changed
]

{ #category : #actions }
PaintBoxMorph >> tool [
	^ tool
]

{ #category : #actions }
PaintBoxMorph >> tool: actionButton action: aSelector cursor: aCursor evt: evt [
	"Set the current tool and action for the paintBox.  "

	tool ifNotNil: [
		tool == actionButton ifFalse: [
			tool state: #off.
			action == #stamp: ifTrue: [self stampDeEmphasize]]].
	tool := actionButton.		"A ThreePhaseButtonMorph"
	"tool state: #on.	already done"
	action := aSelector.		"paint:"
	currentCursor := aCursor.
	self notifyWeakDependentsWith: {#action. evt. action}.
	self notifyWeakDependentsWith: {#currentCursor. evt. currentCursor}.

]

{ #category : #actions }
PaintBoxMorph >> toss: cancelButton with: cancelSelector evt: evt [
	"Reject the painting.  Showing noPalette is done by the block submitted to the SketchEditorMorph"

	| focus |
	owner ifNil: ["it happens"  ^ self].
	(focus := self focusMorph) 
		ifNotNil: [focus cancelPainting: self evt: evt]
		ifNil:
			[self delete].
	cancelButton state: #off.

]

{ #category : #actions }
PaintBoxMorph >> undo: undoButton with: undoSelector evt: evt [
	| ss |
	(ss := self focusMorph) 
		ifNotNil: [ss undoPainting: self evt: evt]
		ifNil: [self notCurrentlyPainting].
	undoButton state: #off.
]

{ #category : #copying }
PaintBoxMorph >> updateReferencesUsing: aDictionary [
	"Fix up stampHolder which is a ScrollingToolHolder, which is not a Morph"

	super updateReferencesUsing: aDictionary.
	stampHolder updateReferencesUsing: aDictionary.
	colorMemory updateReferencesUsing: aDictionary.
]
