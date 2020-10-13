Class {
	#name : #ComponentLayout,
	#superclass : #PasteUpMorph,
	#category : #'Etoys-Squeakland-Morphic-Components'
}

{ #category : #layout }
ComponentLayout >> acceptDroppingMorph: aMorph event: evt [
	"Eschew all of PasteUp's mechanism for now"

	self addMorph: aMorph.

]

{ #category : #menus }
ComponentLayout >> addCustomMenuItems: menu hand: aHandMorph [

	super addCustomMenuItems: menu hand: aHandMorph.
	menu addLine.
	menu add: 'inspect model in morphic' translated action: #inspectModelInMorphic
]

{ #category : #'submorphs-accessing' }
ComponentLayout >> allKnownNames [
	^super allKnownNames 
		, (self submorphs collect: [:m | m knownName] thenSelect: [:m | m notNil])
]

{ #category : #model }
ComponentLayout >> createCustomModel [
	"Create a model object for this world if it does not yet have one.
	The default model for an EditView is a Component."

	model isNil ifFalse: [^self].	"already has a model"
	model := Component newSubclass new
]

{ #category : #initialization }
ComponentLayout >> initialize [
	super initialize.
	self createCustomModel.
	self extent: 384@256
]

{ #category : #'as yet unclassified' }
ComponentLayout >> inspectModelInMorphic [
	| insp |
	insp := InspectorBrowser openAsMorphOn: self model.
	self world addMorph: insp; startStepping: insp
]
