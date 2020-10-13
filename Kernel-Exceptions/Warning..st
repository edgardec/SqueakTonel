"
A Warning is a Notification which by default should be brought to the attention of the user.
"
Class {
	#name : #Warning,
	#superclass : #Notification,
	#classInstVars : [
		'suppressed',
		'resetOnStartUp'
	],
	#category : #'Kernel-Exceptions'
}

{ #category : #'class initialization' }
Warning class >> cleanUp: aggressive [

	aggressive ifTrue: [self resetAllWarnings].
]

{ #category : #'class initialization' }
Warning class >> initialize [

	Smalltalk addToStartUpList: self.
]

{ #category : #'suppress and reset' }
Warning class >> resetAllWarnings [

	self withAllSubclassesDo: [:warningClass |
		warningClass resetWarnings].
]

{ #category : #accessing }
Warning class >> resetOnStartUp [
	"If true, do not suppress this kind of warning anymore after image start up. This flag will be reset to false after doing this."
	
	^ resetOnStartUp ifNil: [false]
]

{ #category : #accessing }
Warning class >> resetOnStartUp: aBoolean [

	resetOnStartUp := aBoolean.
]

{ #category : #'suppress and reset' }
Warning class >> resetWarnings [

	self suppressed: false.
	self resetOnStartUp: false.
]

{ #category : #'instance creation' }
Warning class >> signal [

	^ self signal: nil
]

{ #category : #'instance creation' }
Warning class >> signal: signalerText [

	^ self suppressed
		ifTrue: [nil]
		ifFalse: [self new signal: signalerText]
]

{ #category : #'class initialization' }
Warning class >> startUp: resuming [

	resuming ifTrue: [
		self withAllSubclassesDo: [:warningClass |
			warningClass resetOnStartUp ifTrue: [warningClass resetWarnings]]].
]

{ #category : #'suppress and reset' }
Warning class >> suppressAndResetOnStartUp [
	"Suppress this kind of warning but reset that after the next image start up."
	
	self suppressed: true.
	self resetOnStartUp: true.
]

{ #category : #'suppress and reset' }
Warning class >> suppressWarnings [
	"Suppress this kind of warning."
	
	self suppressed: true.
]

{ #category : #accessing }
Warning class >> suppressed [

	^ suppressed ifNil: [false]
]

{ #category : #accessing }
Warning class >> suppressed: aBoolean [

	suppressed := aBoolean.
]

{ #category : #'priv handling' }
Warning >> defaultAction [
	"Inform the user of a Warning, giving them the choice of ignoring the warning (proceeding), debugging, or terminating the computation."
	UnhandledWarning signalForException: self
]
