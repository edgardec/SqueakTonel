Class {
	#name : #FishEyeMorph,
	#superclass : #MagnifierMorph,
	#instVars : [
		'gridNum',
		'd',
		'clipRects',
		'toRects',
		'quads',
		'savedExtent'
	],
	#category : #'Etoys-Squeakland-Morphic-Demo'
}

{ #category : #'parts bin' }
FishEyeMorph class >> descriptionForPartsBin [
	^ self partName:	'FishEye' translatedNoop
		categories:		#()
		documentation:	'An extreme-wide-angle lens' translatedNoop
]

{ #category : #initialization }
FishEyeMorph >> calculateTransform [
	| stepX stepY rect tx ty arrayX arrayY |
	(gridNum x = 0 or: [gridNum y = 0]) ifTrue: [^self].
	stepX := srcExtent x // gridNum x.
	stepY := srcExtent y // gridNum y.

	arrayX := (1 to: gridNum y + 1) collect: [:j | Float32Array new: gridNum x + 1].
	arrayY := (1 to: gridNum y + 1) collect: [:j |  Float32Array new: gridNum x + 1].

	0 to: gridNum y do: [:j |
		0 to: gridNum x do: [:i |
			(arrayX at: (j + 1)) at: (i + 1) put: i*stepX.
			(arrayY at: (j + 1)) at: (i + 1) put: j*stepY.
		].
	].

	0 to: gridNum y do: [:j |
		self transformX: (arrayX at: (j+1)).
		self transformY: (arrayY at: (j+1)).
	].

	0 to: gridNum y do: [:j |
		arrayX at: (j+1) put: ((1 to: gridNum x +1) collect: [:i | ((arrayX at: (j+1)) at: i) asInteger]).
		arrayY at: (j+1) put: ((1 to: gridNum x +1) collect: [:i | ((arrayY at: (j+1)) at: i) asInteger]).
	].


	clipRects := (1 to: gridNum y) collect: [:j | Array new: gridNum x].
	toRects := (1 to: gridNum y) collect: [:j |  Array new: gridNum x].
	quads := (1 to: gridNum y) collect: [:j |  Array new: gridNum x].
	0 to: gridNum y - 1 do: [:j |
		0 to: gridNum x- 1 do: [:i |
			rect := (((arrayX at: (j+1)) at: (i+1))@((arrayY at: (j+1)) at: (i+1)))
						corner: ((arrayX at: (j+2)) at: (i+2))@((arrayY at: (j+2)) at: (i+2)).
			(clipRects at: j+1) at: i+1 put: rect.

			rect width >= stepX ifTrue: [rect := rect expandBy: (1@0)].
			rect height >= stepY ifTrue: [rect := rect expandBy: (0@1)].
			(toRects at: j+1) at: i+1 put: rect.

			tx := (i)*stepX.
			ty := (j)*stepY.
			(quads at: j+1) at: i+1
						put: {(tx)@(ty). (tx)@(ty+stepY). (tx+stepX)@(ty+stepY). (tx+stepX)@(ty)}.
		].
	].


]

{ #category : #menus }
FishEyeMorph >> chooseMagnification [
	self inform: 'Magnification is fixed, sorry.' translated
]

{ #category : #menu }
FishEyeMorph >> chooseMagnification: evt [

]

{ #category : #geometry }
FishEyeMorph >> extent: aPoint [
	"Round to a number divisible by grid.  Note that the superclass has its own implementation."
	| g gridSize |
	gridSize := self gridSizeFor: aPoint.
	"self halt."
	g := (aPoint - (2 * self borderWidth)) // gridSize.
	srcExtent := g * gridSize.
	gridNum := g.
	^super extent: self defaultExtent
]

{ #category : #initialization }
FishEyeMorph >> g: aFloatArray max: max focus: focus [
	| dNormX array |

	dNormX := aFloatArray - focus.
	
	array := dNormX / max.
	array *= d.
	array += 1.0.
	array := 1.0 / array.
	dNormX *= (d+1.0).
	array *= dNormX.
	^array += focus.

]

{ #category : #private }
FishEyeMorph >> gridSizeFor: aPoint [
	"returns appropriate size for specified argument"
	| g |
	g := aPoint x min: aPoint y.
	g <= 256 ifTrue: [^8].
	^16.
]

{ #category : #initialization }
FishEyeMorph >> initialize [
"initialize the state of the receiver"
	super initialize.
""
	"magnification should be always 1"
	magnification := 1.
	d := 1.3.
	self extent: 130 @ 130
]

{ #category : #'parts bin' }
FishEyeMorph >> initializeToStandAlone [
	super initializeToStandAlone.
	"magnification should be always 1"
	magnification := 1.
	d := 1.3.
	self extent: 130@130.

]

{ #category : #magnifying }
FishEyeMorph >> magnifiedForm [
	| warp warpForm fromForm |

	savedExtent ~= srcExtent ifTrue: [
		savedExtent := srcExtent.
		self calculateTransform].

	warpForm := Form extent: srcExtent depth: Display depth.
	fromForm := super magnifiedForm.

	warp :=  (WarpBlt current toForm: warpForm)
		sourceForm: fromForm;
		colorMap: nil;
		cellSize: 2;
		combinationRule: Form over.

	1 to: gridNum y do: [:j |
		1 to: gridNum x do: [:i |
			warp
				clipRect: ((clipRects at: j) at: i);
				copyQuad: ((quads at: j) at: i)
					toRect: ((toRects at: j) at: i).
		].
	].
	^warpForm

]

{ #category : #initialization }
FishEyeMorph >> transformX: aFloatArray [
	| focus gridNum2 subArray dMaxX |

	focus := srcExtent x asFloat / 2.

	gridNum2 := (aFloatArray findFirst: [:x | x > focus]) - 1.

	dMaxX := 0.0 - focus.
	subArray := self g: (aFloatArray copyFrom: 1 to: gridNum2) max: dMaxX focus: focus.

	aFloatArray replaceFrom: 1 to: gridNum2 with: subArray startingAt: 1.


	dMaxX := focus.    " = (size - focus)"
	subArray := self g: (aFloatArray copyFrom: gridNum2 + 1 to: gridNum x + 1)
		max: dMaxX focus: focus.

	aFloatArray replaceFrom: gridNum2 + 1 to: gridNum x + 1 with: subArray startingAt: 1.

]

{ #category : #initialization }
FishEyeMorph >> transformY: aFloatArray [ 
	| focus subArray dMaxY |
	focus := srcExtent y asFloat / 2.
	dMaxY := (aFloatArray first) <= focus 
				ifTrue: [0.0 - focus]
				ifFalse: [focus].
	subArray := self 
				g: (aFloatArray copyFrom: 1 to: gridNum x + 1)
				max: dMaxY
				focus: focus.
	aFloatArray 
		replaceFrom: 1
		to: gridNum x + 1
		with: subArray
		startingAt: 1
]
