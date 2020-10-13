Class {
	#name : #ProjectSorterMorph,
	#superclass : #BookPageSorterMorph,
	#instVars : [
		'sizeOfEachMorph'
	],
	#category : #'MorphicExtras-Navigators'
}

{ #category : #initialization }
ProjectSorterMorph >> addControls [
	"Add the control bar at the top of the tool."

	| b r partsBinButton newButton aWrapper |
	newButton := ImageMorph new image: (Project current makeThumbnail scaledToSize: 48@36).
	newButton on: #mouseDown send: #insertNewProject: to: self.
	newButton setBalloonText: 'Make a new Project' translated.
	(partsBinButton := UpdatingThreePhaseButtonMorph checkBox)
		target: self;
		actionSelector: #togglePartsBinStatus;
		arguments: #();
		getSelector: #getPartsBinStatus.
	(r := AlignmentMorph newRow)
		color: Color transparent;
		borderWidth: 0;
		layoutInset: 0;
		cellInset: 10@0;
		wrapCentering: #center;
		cellPositioning: #leftCenter;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		extent: 5@5.
	b := SimpleButtonMorph new target: self; color: self defaultColor darker;
			borderColor: Color black.
	r addMorphBack: (self wrapperFor: (b label: 'Okay' translated font: ScriptingSystem fontForEToyButtons; actionSelector: #acceptSort)).
	b := SimpleButtonMorph new target: self; color: self defaultColor darker;
			borderColor: Color black.
	r addMorphBack: (self wrapperFor: (b label: 'Cancel' translated font: ScriptingSystem fontForEToyButtons; actionSelector: #delete));
		addTransparentSpacerOfSize: 8 @ 0;
		addMorphBack: (self wrapperFor: (newButton));
		addTransparentSpacerOfSize: 8 @ 0.

	aWrapper := AlignmentMorph newRow beTransparent.
	aWrapper cellInset: 0; layoutInset: 0; borderWidth: 0.
	aWrapper
		addMorphBack: (self wrapperFor: partsBinButton);
		addMorphBack: (self wrapperFor: (StringMorph contents: 'Parts bin' translated font: ScriptingSystem fontForEToyButtons) lock).
	r addMorphBack: aWrapper.

	self addMorphFront: r.

]

{ #category : #'event handling' }
ProjectSorterMorph >> clickFromSorterEvent: evt morph: aMorph [

	| where what |
	(aMorph bounds containsPoint: evt cursorPoint) ifFalse: [^self].
	evt isMouseUp ifFalse: [
		evt shiftPressed ifFalse: [^evt hand grabMorph: aMorph].
		^self
	].

	evt shiftPressed ifTrue: [
		where := aMorph owner submorphs indexOf: aMorph ifAbsent: [nil].
		what := book threadName.
		WorldState addDeferredUIMessage: [
			InternalThreadNavigationMorph openThreadNamed: what atIndex: where
		].
		(Project named: (aMorph valueOfProperty: #nameOfThisProject)) enter.
	].

]

{ #category : #initialization }
ProjectSorterMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 0 
]

{ #category : #initialization }
ProjectSorterMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color
		r: 0.365
		g: 0.634
		b: 0.729
]

{ #category : #initialization }
ProjectSorterMorph >> initialize [
	"initialize the state of the receiver"

	super initialize.
	self useRoundedCorners.
	pageHolder useRoundedCorners; borderWidth: 0;
		color: (self
				gridFormOrigin: 0 @ 0
				grid: ScriptingSystem sorterGridSize
				background: Color white
				line: Color blue muchLighter)
]

{ #category : #controls }
ProjectSorterMorph >> insertNewProject: evt [

	| newProj |

	[newProj := MorphicProject openViewOn: nil.]
		on: ProjectViewOpenNotification
		do: [ :ex | ex resume: false].	

	Smalltalk at: #EToyProjectDetailsMorph ifPresent:[:aClass|
		aClass
			getFullInfoFor: newProj
			ifValid: [
				evt hand attachMorph: (self sorterMorphForProjectNamed: newProj name)
			]
			expandedFormat: false.
	].
]

{ #category : #private }
ProjectSorterMorph >> morphsForMyContentsFrom: listOfPages sizedTo: sz [

	| morphsForPageSorter |

	'Assembling thumbnail images...'
		displayProgressFrom: 0 to: listOfPages size
		during: [:bar |
			morphsForPageSorter := listOfPages withIndexCollect: [ :each :index | 
				bar value: index.
				self sorterMorphForProjectNamed: each first
			].
		].
	^morphsForPageSorter

]

{ #category : #initialization }
ProjectSorterMorph >> navigator: aThreadNavigator listOfPages: listOfPages [

	| morphsForPageSorter pixelsAvailable pixelsNeeded scale |

	"a bit of fudging to try to outguess the layout mechanism and get best possible scale"
	pixelsAvailable := Display extent - 130.
	pixelsAvailable := pixelsAvailable x * pixelsAvailable y.
	pixelsNeeded := 100@75.
	pixelsNeeded := pixelsNeeded x * pixelsNeeded y  * listOfPages size.
	scale := (pixelsAvailable / pixelsNeeded min: 1) sqrt.
	sizeOfEachMorph := (100@75 * scale) rounded.

	morphsForPageSorter := self morphsForMyContentsFrom: listOfPages sizedTo: sizeOfEachMorph.
	morphsForPageSorter := morphsForPageSorter reject: [ :each | each isNil].
	self changeExtent: Display extent.

	self
		book: aThreadNavigator 
		morphsToSort: morphsForPageSorter.
	pageHolder 
		cursor: aThreadNavigator currentIndex;
		fullBounds;
		hResizing: #rigid.


]

{ #category : #private }
ProjectSorterMorph >> sorterMorphForProjectNamed: projName [

	| pvm proj |

	(proj := Project named: projName) ifNil: [^nil].
	pvm := (InternalThreadNavigationMorph getThumbnailFor: proj) asMorph.
	pvm setProperty: #nameOfThisProject toValue: projName.
	pvm isOpaque: true.
	pvm setBalloonText: projName.
	pvm on: #mouseDown send: #clickFromSorterEvent:morph: to: self.
	pvm on: #mouseUp send: #clickFromSorterEvent:morph: to: self.
	^pvm


]
