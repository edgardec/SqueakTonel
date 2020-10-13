Class {
	#name : #CurrentProjectRefactoring,
	#superclass : #Object,
	#category : #'Etoys-Squeakland-System-Support'
}

{ #category : #'revectoring to current' }
CurrentProjectRefactoring class >> currentAddGuard: anObject [
"
CurrentProjectRefactoring currentAddGuard:
"
	^self xxxCurrent addGuard: anObject
]

{ #category : #'revectoring to current' }
CurrentProjectRefactoring class >> currentBeParentTo: anotherProject [
"
CurrentProjectRefactoring currentBeParentTo:
"
	^anotherProject setParent: self xxxCurrent
]

{ #category : #'revectoring to current' }
CurrentProjectRefactoring class >> currentBeParentToCurrent [
"
CurrentProjectRefactoring currentBeParentToCurrent
"
	^self xxxCurrent setParent: self xxxCurrent
]

{ #category : #'revectoring to current' }
CurrentProjectRefactoring class >> currentFlapsSuppressed [
"
CurrentProjectRefactoring currentFlapsSuppressed
"
	^self xxxCurrent flapsSuppressed
]

{ #category : #'revectoring to current' }
CurrentProjectRefactoring class >> currentFromMyServerLoad: aProjectName [
"
CurrentProjectRefactoring currentFromMyServerLoad:
"
	^self xxxCurrent fromMyServerLoad: aProjectName
]

{ #category : #'revectoring to current' }
CurrentProjectRefactoring class >> currentInterruptName: aString [
"
CurrentProjectRefactoring currentInterruptName:
"
	^ self xxxCurrent interruptName: aString
]

{ #category : #'revectoring to current' }
CurrentProjectRefactoring class >> currentInterruptName: aString preemptedProcess: theInterruptedProcess [

	^ self xxxCurrent interruptName: aString preemptedProcess: theInterruptedProcess
]

{ #category : #'revectoring to current' }
CurrentProjectRefactoring class >> currentIsolationHead [
"
CurrentProjectRefactoring currentIsolationHead
"
	^self xxxCurrent isolationHead
]

{ #category : #'revectoring to current' }
CurrentProjectRefactoring class >> currentProjectName [
"
CurrentProjectRefactoring currentProjectName
"
	^self xxxCurrent name
]

{ #category : #'revectoring to current' }
CurrentProjectRefactoring class >> currentPropagateChanges [
"
CurrentProjectRefactoring currentPropagateChanges
"
	^self xxxCurrent propagateChanges
]

{ #category : #'revectoring to current' }
CurrentProjectRefactoring class >> currentSpawnNewProcessAndTerminateOld: aBoolean [
"
CurrentProjectRefactoring currentSpawnNewProcessAndTerminateOld:
"
	^self xxxCurrent spawnNewProcessAndTerminateOld: aBoolean


]

{ #category : #'revectoring to current' }
CurrentProjectRefactoring class >> currentToggleFlapsSuppressed [
"
CurrentProjectRefactoring currentToggleFlapsSuppressed
"
	^self xxxCurrent flapsSuppressed: self xxxCurrent flapsSuppressed not.



]

{ #category : #miscellaneous }
CurrentProjectRefactoring class >> exitCurrentProject [
"
CurrentProjectRefactoring exitCurrentProject
"
	^self xxxCurrent exit

]

{ #category : #flaps }
CurrentProjectRefactoring class >> isFlapEnabled: aFlapTab [
	"Answer whether the given flap tab is enabled in the current project"

	^ self xxxCurrent isFlapEnabled: aFlapTab
]

{ #category : #miscellaneous }
CurrentProjectRefactoring class >> newProcessIfUI: aDeadOrDyingProcess [
"
CurrentProjectRefactoring newProcessIfUI:
used ONLY for Morphic
"
	^ self xxxCurrent spawnNewProcessIfThisIsUI: aDeadOrDyingProcess
]

{ #category : #miscellaneous }
CurrentProjectRefactoring class >> projectWithNameOrCurrent: aString [
"
CurrentProjectRefactoring projectWithNameOrCurrent:
"
	^(Project named: aString) ifNil: [self xxxCurrent]
]

{ #category : #flaps }
CurrentProjectRefactoring class >> showSharedFlaps [
	"Answer whether shared flaps are currently showing (true) or suppressed (false).  The CurrentProjectRefactoring circumlocution is in service of making it possible for shared flaps to appear on the edges of an interior subworld, I believe."

	^ self xxxCurrent showSharedFlaps
]

{ #category : #flaps }
CurrentProjectRefactoring class >> showTabsString [
	"Answer a string characterizing whether global flap tabs are showing (true) or suppressed (false)."

	^ (self currentFlapsSuppressed
		ifTrue: ['<no>']
		ifFalse: ['<yes>']), 'show flaps (F)' translated
]

{ #category : #flaps }
CurrentProjectRefactoring class >> suppressFlapsString [
	"Answer a string characterizing whether flaps are suppressed 
	at the moment or not"
	^ (self currentFlapsSuppressed
		ifTrue: ['<no>']
		ifFalse: ['<yes>']), 'show shared tabs (F)' translated
]

{ #category : #'revectoring to current' }
CurrentProjectRefactoring class >> xxxCurrent [

	^Project current
]
