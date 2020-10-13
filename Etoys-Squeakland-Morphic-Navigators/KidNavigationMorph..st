Class {
	#name : #KidNavigationMorph,
	#superclass : #ProjectNavigationMorph,
	#classVars : [
		'PreExistingProjects'
	],
	#category : #'Etoys-Squeakland-Morphic-Navigators'
}

{ #category : #'as yet unclassified' }
KidNavigationMorph >> addButtons [

	(self addARow: {

		self inAColumn: {self buttonFind}.
		self transparentSpacerOfSize:6@6.
		self transparentSpacerOfSize:6@6.
		self inAColumn: {self buttonNewProject}.
	}) layoutInset: 6.
	self addARow: {
		self transparentSpacerOfSize:0@6.
	}.
	(self addARow: {
		self inAColumn: {self buttonPublish}.
	}) layoutInset: 6.
	self addARow: {
		self transparentSpacerOfSize:0@18.
	}.
	(self addARow: {
		self inAColumn: {self buttonQuit}.
	}) layoutInset: 6.


]

{ #category : #'as yet unclassified' }
KidNavigationMorph >> amountToShowWhenSmall [
	^49
]

{ #category : #accessing }
KidNavigationMorph >> balloonText [
	^ ((mouseInside
			ifNil: [false])
		ifTrue: ['Click here to see FEWER buttons.']
		ifFalse: ['Click here to see MORE buttons.'])  translated
]

{ #category : #'as yet unclassified' }
KidNavigationMorph >> colorForButtons [

	^Color r: 0.613 g: 0.71 b: 1.0 
]

{ #category : #initialization }
KidNavigationMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	| result |
	result := GradientFillStyle ramp: {0.0
					-> (Color
							r: 0.032
							g: 0.0
							b: 0.484). 1.0
					-> (Color
							r: 0.194
							g: 0.032
							b: 1.0)}.
	result origin: self bounds topLeft.
	result direction: 0 @ 200.
	result radial: false.
	^ result
]

{ #category : #'as yet unclassified' }
KidNavigationMorph >> fontForButtons [

	^Preferences standardEToysFont
]

{ #category : #'event handling' }
KidNavigationMorph >> handlesMouseDown: evt [

	^true
	
]

{ #category : #initialization }
KidNavigationMorph >> initialize [
	"initialize the state of the receiver"
	| |
	super initialize.
	""
	self layoutInset: 12.

	self removeAllMorphs.
	self addButtons
]

{ #category : #'event handling' }
KidNavigationMorph >> mouseEnter: evt [

	"kid nav doesn't care"
	
]

{ #category : #'event handling' }
KidNavigationMorph >> mouseLeave: evt [

	"kid nav doesn't care"
	
]

{ #category : #'event handling' }
KidNavigationMorph >> mouseUp: evt [

	mouseInside := (mouseInside ifNil: [false]) not.
	self positionVertically
	
]

{ #category : #'the actions' }
KidNavigationMorph >> quitSqueak [

	| newProjects limit now msg response |

	Preferences checkForUnsavedProjects ifFalse: [^super quitSqueak].
	PreExistingProjects ifNil: [^super quitSqueak].
	limit := 5 * 60.
	now := Time totalSeconds.
	newProjects := Project allProjects reject: [ :each | PreExistingProjects includes: each].
	newProjects := newProjects reject: [ :each | 
		((each lastSavedAtSeconds ifNil: [0]) - now) abs < limit
	].
	newProjects isEmpty ifTrue: [^super quitSqueak].
	msg := String streamContents: [ :strm |
		strm nextPutAll: 'There are some project(s)
that have not been saved recently:
----
'.
		newProjects do: [ :each | strm nextPutAll: each name; cr].
		strm nextPutAll: '----
What would you like to do?'
	].
	response := PopUpMenu 
		confirm: msg
		trueChoice: 'Go ahead and QUIT'
		falseChoice: 'Wait, let me save them first'.
	response ifTrue: [^super quitSqueak].


]

{ #category : #'stepping and presenter' }
KidNavigationMorph >> step [

	super step.
	PreExistingProjects ifNil: [PreExistingProjects := WeakArray withAll: Project allProjects].
]
