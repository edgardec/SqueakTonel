"
Optionally associated with a PasteUpMorph, provides a local scope for the running of scripts.

Once more valuable, may be again, but at present occupies primarily a historical niche.

Maintains a playerList cache.

Holds, optionally three 'standard items' -- standardPlayer standardPlayfield standardPalette -- originally providing idiomatic support of ongoing squeak-team internal work, but now extended to more general applicability.

   
"
Class {
	#name : #Presenter,
	#superclass : #Object,
	#classVars : [
		'DefaultPresenterClass'
	],
	#category : #'Morphic-Worlds'
}

{ #category : #accessing }
Presenter class >> defaultPresenterClass [
	"The default presenter class to use"
	^DefaultPresenterClass ifNil:[self]
]

{ #category : #accessing }
Presenter class >> defaultPresenterClass: aPresenterClass [
	"The default presenter class to use"
	DefaultPresenterClass := aPresenterClass
]

{ #category : #stubs }
Presenter >> allCurrentlyTickingScriptInstantiations [
	"Answer a list of ScriptInstantiation objects representing all the scripts within the scope of the receiver which are currently ticking."

	^ Array streamContents:
		[:aStream | 
			self allExtantPlayers do:
				[:aPlayer | aPlayer instantiatedUserScriptsDo:
					[:aScriptInstantiation |
						aScriptInstantiation status == #ticking ifTrue:
							[aStream nextPut: aScriptInstantiation]]]]
]

{ #category : #stubs }
Presenter >> allExtantPlayers [
	^#()
]

{ #category : #accessing }
Presenter >> associatedMorph: m [
]

{ #category : #stubs }
Presenter >> browseAllScriptsTextually [
	"Open a method-list browser on all the scripts in the project"

	| aList aMethodList |
	self flushPlayerListCache.  "Just to be certain we get everything"

	(aList := self uniclassesAndCounts) size == 0 ifTrue: [^ self inform: 'there are no scripted players' translated].
	aMethodList := OrderedCollection new.
	aList do:
		[:aPair | aPair first addMethodReferencesTo: aMethodList].
	aMethodList size > 0 ifFalse: [^ self inform: 'there are no scripts in this project!' translated].
	
	SystemNavigation new 
		browseMessageList: aMethodList 
		name: 'All scripts in this project' 
		autoSelect: nil

"
ActiveWorld presenter browseAllScriptsTextually
"
]

{ #category : #stubs }
Presenter >> currentlyViewing: aPlayer [
	^false
]

{ #category : #stubs }
Presenter >> drawingJustCompleted: aSketch [
]

{ #category : #stubs }
Presenter >> flushPlayerListCache [
]

{ #category : #stubs }
Presenter >> morph: aMorph droppedIntoPasteUpMorph: aPasteUpMorph [
]

{ #category : #stubs }
Presenter >> ownStandardPalette [
	^nil
]

{ #category : #stubs }
Presenter >> positionStandardPlayer [
]

{ #category : #stubs }
Presenter >> viewMorph: aMorph [
	aMorph inspect.

]

{ #category : #stubs }
Presenter >> viewObjectDirectly: aMorph [
	aMorph inspect.

]
