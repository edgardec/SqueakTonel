"
My instances are Player objects that have not been scripted, and which hence do not require a unique scripts dictionary, etc.  As soon as the needed, I am transformed automatically into a unique subclass of Player.
"
Class {
	#name : #UnscriptedPlayer,
	#superclass : #Player,
	#instVars : [
		'patch',
		'index'
	],
	#classInstVars : [
		'ephemeralPlayerRef'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #compiling }
UnscriptedPlayer class >> acceptsLoggingOfCompilation [
	^ true
]

{ #category : #reference }
UnscriptedPlayer class >> ephemeralPlayerRef [
	"UnscriptedPlayer ephemeralPlayerRef"
	^ ephemeralPlayerRef
]

{ #category : #testing }
UnscriptedPlayer class >> isSystemDefined [
	^ true
]

{ #category : #'instance creation' }
UnscriptedPlayer class >> isUniClass [
	^ false
]

{ #category : #'instance creation' }
UnscriptedPlayer class >> newUserInstance [
	"Answer an instance of an appropriate class to serve as a user object in the containment hierarchy"

	^ self new
]

{ #category : #testing }
UnscriptedPlayer class >> officialClass [
	^ self
]

{ #category : #namespace }
UnscriptedPlayer class >> referenceSelectorFor: anObject [
	"The use of this is for immediate evaluation of lines of script in a Viewer.  The class inst var 'ephemeralPlayerRef' is constantly reused for this purpose."

	ephemeralPlayerRef := anObject.
	^ 'ephemeralPlayerRef'
]

{ #category : #compiling }
UnscriptedPlayer class >> wantsChangeSetLogging [
	^ true
]

{ #category : #viewer }
UnscriptedPlayer >> assureUniClass [
	"Create a uniclass and become the receiver into it"

	| anInstance |
	anInstance := self rootClassForUniclasses instanceOfUniqueClass.
	anInstance initializeCostumesFrom: self.
	self become: anInstance.
	^ anInstance
]

{ #category : #viewer }
UnscriptedPlayer >> belongsToUniClass [
	^ false
]

{ #category : #copying }
UnscriptedPlayer >> copyUniClassWith: deepCopier [
	
	self error: 'oops, copyUniClass sent to an UnscriptedPlayer'
]

{ #category : #'error handling' }
UnscriptedPlayer >> doesNotUnderstand: aMessage [
	"I do not attempt the special setters that Player does.
	I merely ignore not-understood messages."
	^nil
]

{ #category : #access }
UnscriptedPlayer >> getIndex [
	^ index
]

{ #category : #access }
UnscriptedPlayer >> getPatch [
	^ patch
]

{ #category : #'slots-user' }
UnscriptedPlayer >> hasUserDefinedScripts [
	^ false
]

{ #category : #viewer }
UnscriptedPlayer >> hasUserDefinedSlots [
	^ false
]

{ #category : #uniclass }
UnscriptedPlayer >> rootClassForUniclasses [
	"Answer the class that should be subclassed when the receiver is made into a uniclass"

	^ Player
]

{ #category : #access }
UnscriptedPlayer >> setIndex: t1 [ 
	index := t1
]

{ #category : #access }
UnscriptedPlayer >> setPatch: t1 [ 
	patch := t1
]

{ #category : #testing }
UnscriptedPlayer >> wantsSteps [
	"Has no scripts"
	^ false
]
