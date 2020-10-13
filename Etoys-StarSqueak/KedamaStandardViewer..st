Class {
	#name : #KedamaStandardViewer,
	#superclass : #StandardViewer,
	#instVars : [
		'stub',
		'restrictedIndex',
		'restrictedWho'
	],
	#category : #'Etoys-StarSqueak'
}

{ #category : #categories }
KedamaStandardViewer >> categoryViewerFor: categoryInfo [ 
	"Answer a category viewer for the given category info"

	| aViewer |
	aViewer := ((categoryInfo isCollection) 
				and: [categoryInfo first == #search]) 
					ifFalse: [KedamaCategoryViewer new]
					ifTrue: [KedamaWhoSearchingViewer new].
	aViewer initializeFor: scriptedPlayer categoryChoice: categoryInfo.
	(aViewer isMemberOf: KedamaWhoSearchingViewer) ifTrue: [^ aViewer].
	restrictedWho = 0
		ifTrue: [aViewer replaceTargetWith: scriptedPlayer]
		ifFalse: [aViewer replaceTargetWith: stub].
	^aViewer.

]

{ #category : #initialization }
KedamaStandardViewer >> initializeFor: aPlayer barHeight: anInteger includeDismissButton: aBoolean showCategories: categoryInfo [

	stub := aPlayer clonedSequentialStub.
	stub who: 0.
	restrictedWho := 0.
	restrictedIndex := 0.
	super initializeFor: aPlayer barHeight: anInteger includeDismissButton: aBoolean showCategories: categoryInfo.

]

{ #category : #'turtle view' }
KedamaStandardViewer >> providePossibleRestrictedView: anInteger [

	| who |
	restrictedIndex := anInteger.
	who := scriptedPlayer whoAt: anInteger.
	restrictedWho = who ifTrue: [^ self].
	restrictedWho := who.
	stub who: who.
	who = 0 ifTrue: [self replaceTargetsWithExampler] ifFalse: [self replaceTargetsWithStub].
	self searchingViewerMorphs do: [:v | v updateWhoString].

]

{ #category : #'turtle view' }
KedamaStandardViewer >> replaceTargetsWithExampler [

	self submorphsDo: [:e |
		(e isMemberOf: KedamaCategoryViewer) ifTrue: [
			e replaceTargetWith: scriptedPlayer.
		].
	].

]

{ #category : #'turtle view' }
KedamaStandardViewer >> replaceTargetsWithStub [

	self submorphsDo: [:e |
		(e isMemberOf: KedamaCategoryViewer) ifTrue: [
			e replaceTargetWith: stub.
		].
	].

]

{ #category : #'turtle view' }
KedamaStandardViewer >> resetWhoIfNecessary [

	restrictedWho <= 0 ifTrue: [^ self].
	self providePossibleRestrictedView: 0.

]

{ #category : #'turtle view' }
KedamaStandardViewer >> restrictedIndex [

	^ restrictedIndex.

]

{ #category : #'turtle view' }
KedamaStandardViewer >> restrictedWho [

	^ restrictedWho.

]

{ #category : #'turtle view' }
KedamaStandardViewer >> searchingViewerMorphs [

	^ self submorphsSatisfying: [:m | m isKindOf: KedamaWhoSearchingViewer].
]
