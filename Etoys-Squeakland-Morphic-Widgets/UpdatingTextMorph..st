"
A TextMorph that constantly tries to show the current data from the target object.  When sent #step, it shows what the target objects has (target perform: getSelector).
"
Class {
	#name : #UpdatingTextMorph,
	#superclass : #TextMorph,
	#instVars : [
		'target',
		'getSelector',
		'growable',
		'stepTime'
	],
	#category : #'Etoys-Squeakland-Morphic-Widgets'
}

{ #category : #'instance creation' }
UpdatingTextMorph class >> on: targetObject selector: aSymbol [ 
	"answer a new instance of the receiver on a given target and selector"
	^ self new getSelector: aSymbol;
		 target: targetObject
]

{ #category : #'target access' }
UpdatingTextMorph >> contentsFromTarget [
	"private - answer the contents from the receiver's target"
	(target isNil
			or: [getSelector isNil])
		ifTrue: [^ self contents].
	""
	^ (target perform: getSelector) asString
]

{ #category : #accessing }
UpdatingTextMorph >> getSelector [
	"answer the receiver's getSelector"
	^ getSelector
]

{ #category : #accessing }
UpdatingTextMorph >> getSelector: aSymbol [ 
	"change the receiver's getSelector"
	getSelector := aSymbol
]

{ #category : #initialization }
UpdatingTextMorph >> initialize [
	"Initialie the receiver to have default values in its instance  
	variables"
	super initialize.""
	stepTime := 50
]

{ #category : #'stepping and presenter' }
UpdatingTextMorph >> step [
	"update my contents"
	| newContents |
	super step.
	""
	newContents := self contentsFromTarget.
	self visible: newContents isEmpty not.
	self contents: newContents
]

{ #category : #'stepping and presenter' }
UpdatingTextMorph >> stepTime [
	"answer the desired time between steps in milliseconds."
	^ stepTime
		ifNil: [50]
]

{ #category : #'stepping and presenter' }
UpdatingTextMorph >> stepTime: mSecsPerStep [ 
	"change the receiver's stepTime"
	stepTime := mSecsPerStep rounded
]

{ #category : #accessing }
UpdatingTextMorph >> target [
	"answer the receiver's target"
	^ target
]

{ #category : #accessing }
UpdatingTextMorph >> target: anObject [ 
	"change the receiver's target"
	target := anObject
]

{ #category : #copying }
UpdatingTextMorph >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

	super veryDeepFixupWith: deepCopier.
	target := deepCopier references at: target ifAbsent: [target].
	getSelector := deepCopier references at: getSelector ifAbsent: [getSelector].

]

{ #category : #copying }
UpdatingTextMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

super veryDeepInner: deepCopier.
"target := target.		Copy it weakly"
"getSelector := getSelector.	Symbols are shared"
growable := growable veryDeepCopyWith: deepCopier.
stepTime := stepTime veryDeepCopyWith: deepCopier.

]
