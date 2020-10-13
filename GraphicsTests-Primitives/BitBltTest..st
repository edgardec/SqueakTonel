Class {
	#name : #BitBltTest,
	#superclass : #ClassTestCase,
	#category : #'GraphicsTests-Primitives'
}

{ #category : #tests }
BitBltTest >> testAllAlphasRgbAdd [
	"self run: #testAllAlphasRgbAdd"
	| sourceForm destForm blt correctAlphas |
	<timeout: 15>
     correctAlphas := 0.
     0  to: 255 do: [:sourceAlpha |
         sourceForm := Form extent: 1 @ 1 depth: 32.
         sourceForm bits at: 1 put: sourceAlpha << 24 + (33 << 16) + (25 << 8) + 27.
         0 to: 255 do: [:destAlpha |
             destForm := Form extent: 1 @ 1 depth: 32.
             destForm bits at: 1 put: destAlpha << 24 + (255 << 16) + (255 << 8) + 255.
              blt := BitBlt new.
              blt sourceForm: sourceForm.
              blt sourceOrigin: 0 @ 0.
              blt setDestForm: destForm.
              blt destOrigin: 0 @ 0.
              blt combinationRule: 20.	"rgbAdd"
              blt copyBits.
              correctAlphas := correctAlphas
                + (((blt destForm bits at: 1) digitAt: 4) = (destAlpha + sourceAlpha min: 255)
                         ifTrue: [1]
                         ifFalse: [0])
      ]].
     self assert: 65536 equals: correctAlphas
]

{ #category : #tests }
BitBltTest >> testAllAlphasRgbMax [
	"self run: #testAllAlphasRgbMax"
	| sourceForm destForm blt correctAlphas |
	<timeout: 10>
     correctAlphas := 0.
     0  to: 255 do: [:sourceAlpha |
         sourceForm := Form extent: 1 @ 1 depth: 32.
         sourceForm bits at: 1 put: sourceAlpha << 24 + (33 << 16) + (25 << 8) + 27.
         0 to: 255 do: [:destAlpha |
             destForm := Form extent: 1 @ 1 depth: 32.
             destForm bits at: 1 put: destAlpha << 24 + (255 << 16) + (255 << 8) + 255.
              blt := BitBlt new.
              blt sourceForm: sourceForm.
              blt sourceOrigin: 0 @ 0.
              blt setDestForm: destForm.
              blt destOrigin: 0 @ 0.
              blt combinationRule: 27.	"rgbMax"
              blt copyBits.
              correctAlphas := correctAlphas
                + (((blt destForm bits at: 1) digitAt: 4) = (destAlpha max: sourceAlpha)
                         ifTrue: [1]
                         ifFalse: [0])
      ]].
     self assert: 65536 equals: correctAlphas
]

{ #category : #tests }
BitBltTest >> testAllAlphasRgbMin [
	"self run: #testAllAlphasRgbMin"
	| sourceForm destForm blt correctAlphas |
	<timeout: 10>
     correctAlphas := 0.
     0  to: 255 do: [:sourceAlpha |
         sourceForm := Form extent: 1 @ 1 depth: 32.
         sourceForm bits at: 1 put: sourceAlpha << 24 + (33 << 16) + (25 << 8) + 27.
         0 to: 255 do: [:destAlpha |
             destForm := Form extent: 1 @ 1 depth: 32.
             destForm bits at: 1 put: destAlpha << 24 + (255 << 16) + (255 << 8) + 255.
              blt := BitBlt new.
              blt sourceForm: sourceForm.
              blt sourceOrigin: 0 @ 0.
              blt setDestForm: destForm.
              blt destOrigin: 0 @ 0.
              blt combinationRule: 28.	"rgbMin"
              blt copyBits.
              correctAlphas := correctAlphas
                + (((blt destForm bits at: 1) digitAt: 4) = (destAlpha min: sourceAlpha)
                         ifTrue: [1]
                         ifFalse: [0])
      ]].
     self assert: 65536 equals: correctAlphas
]

{ #category : #tests }
BitBltTest >> testAllAlphasRgbMinInvert [
	"self run: #testAllAlphasRgbMinInvert"
	| sourceForm destForm blt correctAlphas |
	<timeout: 10>
     correctAlphas := 0.
     0  to: 255 do: [:sourceAlpha |
         sourceForm := Form extent: 1 @ 1 depth: 32.
         sourceForm bits at: 1 put: sourceAlpha << 24 + (33 << 16) + (25 << 8) + 27.
         0 to: 255 do: [:destAlpha |
             destForm := Form extent: 1 @ 1 depth: 32.
             destForm bits at: 1 put: destAlpha << 24 + (255 << 16) + (255 << 8) + 255.
              blt := BitBlt new.
              blt sourceForm: sourceForm.
              blt sourceOrigin: 0 @ 0.
              blt setDestForm: destForm.
              blt destOrigin: 0 @ 0.
              blt combinationRule: 29.	"rgbMinInvert"
              blt copyBits.
              correctAlphas := correctAlphas
                + (((blt destForm bits at: 1) digitAt: 4) = (destAlpha min: 255-sourceAlpha)
                         ifTrue: [1]
                         ifFalse: [0])
      ]].
     self assert: 65536 equals: correctAlphas
]

{ #category : #tests }
BitBltTest >> testAllAlphasRgbMul [
	"self run: #testAllAlphasRgbMul"
	| sourceForm destForm blt correctAlphas |
	<timeout: 10>
     correctAlphas := 0.
     0  to: 255 do: [:sourceAlpha |
         sourceForm := Form extent: 1 @ 1 depth: 32.
         sourceForm bits at: 1 put: sourceAlpha << 24 + (33 << 16) + (25 << 8) + 27.
         0 to: 255 do: [:destAlpha |
             destForm := Form extent: 1 @ 1 depth: 32.
             destForm bits at: 1 put: destAlpha << 24 + (255 << 16) + (255 << 8) + 255.
              blt := BitBlt new.
              blt sourceForm: sourceForm.
              blt sourceOrigin: 0 @ 0.
              blt setDestForm: destForm.
              blt destOrigin: 0 @ 0.
              blt combinationRule: 37.	"rgbMul"
              blt copyBits.
              correctAlphas := correctAlphas
                + (((blt destForm bits at: 1) digitAt: 4) = ((destAlpha+1) * (sourceAlpha+1)- 1 // 256)
                         ifTrue: [1]
                         ifFalse: [0])
      ]].
     self assert: 65536 equals: correctAlphas
]

{ #category : #tests }
BitBltTest >> testAllAlphasRgbSub [
	"self run: #testAllAlphasRgbSub"
	| sourceForm destForm blt correctAlphas |
	<timeout: 10>
     correctAlphas := 0.
     0  to: 255 do: [:sourceAlpha |
         sourceForm := Form extent: 1 @ 1 depth: 32.
         sourceForm bits at: 1 put: sourceAlpha << 24 + (33 << 16) + (25 << 8) + 27.
         0 to: 255 do: [:destAlpha |
             destForm := Form extent: 1 @ 1 depth: 32.
             destForm bits at: 1 put: destAlpha << 24 + (255 << 16) + (255 << 8) + 255.
              blt := BitBlt new.
              blt sourceForm: sourceForm.
              blt sourceOrigin: 0 @ 0.
              blt setDestForm: destForm.
              blt destOrigin: 0 @ 0.
              blt combinationRule: 21.	"rgbSub"
              blt copyBits.
              correctAlphas := correctAlphas
                + (((blt destForm bits at: 1) digitAt: 4) = (destAlpha - sourceAlpha) abs
                         ifTrue: [1]
                         ifFalse: [0])
      ]].
     self assert: 65536 equals: correctAlphas
]

{ #category : #tests }
BitBltTest >> testAlphaCompositing [
	"self run: #testAlphaCompositing"

	| bb f1 f2 mixColor result eps |
	f1 := Form extent: 1@1 depth: 32.
	f2 := Form extent: 1@1 depth: 32.
	eps := 0.5 / 255.
	0 to: 255 do:[:i|
		f1 colorAt: 0@0 put: Color blue.
		mixColor := Color red alpha: i / 255.0.
		f2 colorAt: 0@0 put: mixColor.
		mixColor := f2 colorAt: 0@0.
		bb := BitBlt toForm: f1.
		bb sourceForm: f2.
		bb combinationRule: Form blend.
		bb copyBits.
		result := f1 colorAt: 0@0.
		self assert: (result red - mixColor alpha) abs < eps.
		self assert: (result blue - (1.0 - mixColor alpha)) abs < eps.
		self assert: result alpha = 1.0.
	].
]

{ #category : #tests }
BitBltTest >> testAlphaCompositing2 [
	"self run: #testAlphaCompositing2"

	| bb f1 f2 mixColor result eps |
	f1 := Form extent: 1@1 depth: 32.
	f2 := Form extent: 1@1 depth: 32.
	eps := 0.5 / 255.
	0 to: 255 do:[:i|
		f1 colorAt: 0@0 put: Color transparent.
		mixColor := Color red alpha: i / 255.0.
		f2 colorAt: 0@0 put: mixColor.
		mixColor := f2 colorAt: 0@0.
		bb := BitBlt toForm: f1.
		bb sourceForm: f2.
		bb combinationRule: Form blend.
		bb copyBits.
		result := f1 colorAt: 0@0.
		self assert: (result red - mixColor alpha) abs < eps.
		self assert: result alpha = mixColor alpha.
	].
]

{ #category : #'tests - bugs' }
BitBltTest >> testPeekerUnhibernateBug [
	"self run: #testPeekerUnhibernateBug"

	| bitBlt |
	bitBlt := BitBlt bitPeekerFromForm: Display.
	bitBlt destForm hibernate.
	
	"This should not throw an exception."
	self
		shouldnt: [bitBlt pixelAt: 1@1]
		raise: Error
]

{ #category : #tests }
BitBltTest >> testPivelValueAt [
"tests for the pixel peeking extension to bitBlt"
"	self run: #testPixelValueAt"
	|formList pixels |	
"make a Form of each depth"
	formList := #[1 2 4 8 16 32] collect:[:d| Form extent: 17@7 depth: d] as: Array.
	pixels := Dictionary new.
	pixels at: 1 put: 1; at: 2 put: 3; at:4 put: 7; at: 8 put: 16rFF; at: 16 put: 16rFFFF ; at: 32 put: 16rFFFFFFFF.

"poke pixels to 
topleft (to test handling 0)
bottomright (to test limits)
middle (just because)
peek at each location (to make sure it matches expectations)"
	formList do:[:f| |d pixval|
		d := f depth.
		pixval := pixels at: d.
		f pixelValueAt: 0@0 put: pixval.
		f pixelValueAt: 16@6 put: pixval.
		f pixelValueAt: 7@3 put: pixval.
			self assert: (f pixelValueAt: 0@0) = pixval. 
			self assert: (f pixelValueAt: 1@0) = 0. 
			self assert: (f pixelValueAt: 16@6) = pixval. 
			self assert:(f pixelValueAt: 15@6) = 0. 
			self assert: (f pixelValueAt: 7@3) = pixval.
			self assert: (f pixelValueAt: 6@3) = 0.
	]
]

{ #category : #'tests - bugs' }
BitBltTest >> testPokerUnhibernateBug [
	"self run: #testPokerUnhibernateBug"

	| bitBlt |
	bitBlt := BitBlt bitPokerToForm: Display.
	bitBlt sourceForm hibernate.
	
	self 
		shouldnt: [bitBlt pixelAt: 1@1 put: 0]
		raise: Error.
]
