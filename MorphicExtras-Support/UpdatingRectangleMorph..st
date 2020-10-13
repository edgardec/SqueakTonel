"
Intended for use as a color swatch coupled to a color obtained from the target, but made just slightly more general than that.
"
Class {
	#name : #UpdatingRectangleMorph,
	#superclass : #RectangleMorph,
	#instVars : [
		'target',
		'lastValue',
		'getSelector',
		'putSelector',
		'contents'
	],
	#category : #'MorphicExtras-Support'
}

{ #category : #accessing }
UpdatingRectangleMorph >> contents [
	^ contents
]

{ #category : #accessing }
UpdatingRectangleMorph >> contents: c [
	contents := c
]

{ #category : #initialization }
UpdatingRectangleMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ Color lightGray lighter
]

{ #category : #accessing }
UpdatingRectangleMorph >> getSelector [
	"Answer the getSelector"

	^ getSelector
]

{ #category : #accessing }
UpdatingRectangleMorph >> getSelector: aSymbol [

	getSelector := aSymbol.

]

{ #category : #'event handling' }
UpdatingRectangleMorph >> handlesMouseDown: evt [ 
	^putSelector notNil
]

{ #category : #accessing }
UpdatingRectangleMorph >> isEtoyReadout [
	"Answer whether the receiver can serve as an etoy readout"

	^ true
]

{ #category : #'event handling' }
UpdatingRectangleMorph >> mouseUp: evt [

	self changeColorTarget: self selector: #setTargetColor: originalColor: color hand: evt hand.
]

{ #category : #accessing }
UpdatingRectangleMorph >> putSelector [
	^ putSelector
]

{ #category : #accessing }
UpdatingRectangleMorph >> putSelector: aSymbol [
	putSelector := aSymbol
]

{ #category : #'target access' }
UpdatingRectangleMorph >> readFromTarget [
	"Read the color value from my target"

	| v |
	(target isNil or: [getSelector isNil]) ifTrue: [^contents].
	target isMorph ifTrue: [target isInWorld ifFalse: [^contents]].
	v := self valueProvider perform: getSelector.
	lastValue := v.
	^v
]

{ #category : #setting }
UpdatingRectangleMorph >> setTargetColor: aColor [
	"Set my target's color as indicated"

	putSelector ifNotNil:
		[self color: aColor.
		contents := aColor.
		self valueProvider perform: self putSelector withArguments: (Array with: aColor)]

]

{ #category : #'stepping and presenter' }
UpdatingRectangleMorph >> step [
	| s |
	super step.
	s := self readFromTarget.
	s = contents ifFalse:
		[self contents: s.
		self color: s]

]

{ #category : #'stepping and presenter' }
UpdatingRectangleMorph >> stepTime [

	^ 50
]

{ #category : #accessing }
UpdatingRectangleMorph >> target [

	^ target

]

{ #category : #accessing }
UpdatingRectangleMorph >> target: anObject [

	target := anObject.

]

{ #category : #accessing }
UpdatingRectangleMorph >> userEditsAllowed [
	"Answer whether it is suitable for a user to change the value represented by this readout"

	^ putSelector notNil
]

{ #category : #setting }
UpdatingRectangleMorph >> valueProvider [
	"Answer the object to which my get/set messages should be sent.  This is inefficient and contorted in order to support grandfathered content for an earlier design"

	^ target isMorph
		ifTrue:
			[target topRendererOrSelf player ifNil: [target]]
		ifFalse:
			[target]
]

{ #category : #copying }
UpdatingRectangleMorph >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
target := deepCopier references at: target ifAbsent: [target].
]

{ #category : #copying }
UpdatingRectangleMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

super veryDeepInner: deepCopier.
"target := target.		Weakly copied"
lastValue := lastValue veryDeepCopyWith: deepCopier.
"getSelector := getSelector.		a Symbol"
"putSelector := putSelector.		a Symbol"
contents := contents veryDeepCopyWith: deepCopier.
]
