Class {
	#name : #ProgressMorph,
	#superclass : #RectangleMorph,
	#instVars : [
		'labelMorph',
		'subLabelMorph',
		'progress'
	],
	#category : #'MorphicExtras-Widgets'
}

{ #category : #example }
ProgressMorph class >> example [
	"ProgressMorph example"

	| progress |
	progress := ProgressMorph label: 'Test progress'.
	progress subLabel: 'this is the subheading'.
	progress openInWorld.
	[10 timesRepeat:
		[(Delay forMilliseconds: 200) wait.
		progress incrDone: 0.1].
	progress delete] fork
]

{ #category : #'instance creation' }
ProgressMorph class >> label: aString [
	^self new label: aString
]

{ #category : #accessing }
ProgressMorph >> done [
	^self progress value contents
]

{ #category : #accessing }
ProgressMorph >> done: amountDone [
	self progress value contents: ((amountDone min: 1.0) max: 0.0).
	self currentWorld displayWorld
]

{ #category : #private }
ProgressMorph >> fontOfPointSize: size [
	^ (TextConstants at: Preferences standardEToysFont familyName ifAbsent: [TextStyle default]) fontOfPointSize: size
]

{ #category : #accessing }
ProgressMorph >> incrDone: incrDone [
	self done: self done + incrDone
]

{ #category : #initialization }
ProgressMorph >> initLabelMorph [
	^ labelMorph := (StringMorph contents: '')
		font: ((UserInterfaceTheme current get: #font for: SystemProgressMorph) ifNil: [TextStyle defaultFont]);
		color: ((UserInterfaceTheme current get: #textColor for: SystemProgressMorph) ifNil: [Color black]);
		yourself
]

{ #category : #initialization }
ProgressMorph >> initProgressMorph [
	progress := ProgressBarMorph new.
	progress borderColor: ((UserInterfaceTheme current get: #borderColor for: SystemProgressBarMorph) ifNil: [Color black]).
	progress borderWidth: ((UserInterfaceTheme current get: #borderWidth for: SystemProgressBarMorph) ifNil: [1]).
	progress color: ((UserInterfaceTheme current get: #color for: SystemProgressBarMorph) ifNil: [Color white]).
	progress progressColor: ((UserInterfaceTheme current get: #barColor for: SystemProgressBarMorph) ifNil: [Color gray]).
	progress extent: 200 @ 15.

]

{ #category : #initialization }
ProgressMorph >> initSubLabelMorph [
	^ subLabelMorph := (StringMorph contents: '')
		font: ((UserInterfaceTheme current get: #font for: PluggableButtonMorph) ifNil: [TextStyle defaultFont]);
		color: ((UserInterfaceTheme current get: #textColor for: PluggableButtonMorph) ifNil: [Color black]);
		yourself
]

{ #category : #initialization }
ProgressMorph >> initialize [
	super initialize.
	self setupMorphs
]

{ #category : #accessing }
ProgressMorph >> label [
	^self labelMorph contents
]

{ #category : #accessing }
ProgressMorph >> label: aString [
	self labelMorph contents: aString.
	self currentWorld displayWorld
]

{ #category : #private }
ProgressMorph >> labelMorph [
	^labelMorph ifNil: [self initLabelMorph]
]

{ #category : #accessing }
ProgressMorph >> progress [
	^progress ifNil: [self initProgressMorph]
]

{ #category : #initialization }
ProgressMorph >> setupMorphs [
	|  |
	self initProgressMorph.
	self	
		layoutPolicy: TableLayout new;
		listDirection: #topToBottom;
		cellPositioning: #topCenter;
		listCentering: #center;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		color: Color transparent.

	self addMorphBack: self labelMorph.
	self addMorphBack: self subLabelMorph.
	self addMorphBack: self progress.

	self borderWidth: ((UserInterfaceTheme current get: #borderWidth for: SystemProgressMorph) ifNil: [2]).
	self borderColor: ((UserInterfaceTheme current get: #borderColor for: SystemProgressMorph) ifNil: [Color black]).

	self color: ((UserInterfaceTheme current get: #color for: SystemProgressMorph) ifNil: [Color veryLightGray]).
	self align: self fullBounds center with: Display boundingBox center

]

{ #category : #accessing }
ProgressMorph >> subLabel [
	^self subLabelMorph contents
]

{ #category : #accessing }
ProgressMorph >> subLabel: aString [
	self subLabelMorph contents: aString.
	self currentWorld displayWorld
]

{ #category : #private }
ProgressMorph >> subLabelMorph [
	^subLabelMorph ifNil: [self initSubLabelMorph]
]
