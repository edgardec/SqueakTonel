Class {
	#name : #TestResource,
	#superclass : #Object,
	#instVars : [
		'name',
		'description'
	],
	#classInstVars : [
		'current'
	],
	#category : #'SUnit-Kernel'
}

{ #category : #'class initialization' }
TestResource class >> cleanUp: aggressive [

	aggressive ifTrue: [
		self withAllSubclassesDo: [:cls | cls reset]].
]

{ #category : #accessing }
TestResource class >> current [
	^ current ifNil: [ current := self new]
			
]

{ #category : #accessing }
TestResource class >> current: aTestResource [

	current := aTestResource
			
]

{ #category : #testing }
TestResource class >> isAbstract [
	"Override to true if a TestResource subclass is Abstract and should not have
	TestCase instances built from it"

	^self name = #TestResource
			
]

{ #category : #testing }
TestResource class >> isAvailable [
	^self current notNil and: [self current isAvailable]
			
]

{ #category : #testing }
TestResource class >> isUnavailable [

	^self isAvailable not
			
]

{ #category : #Creation }
TestResource class >> reset [
	current ifNotNil: [:oldCurrent |
		current := nil.
		oldCurrent tearDown]
]

{ #category : #accessing }
TestResource class >> resources [
	^#()
			
]

{ #category : #creation }
TestResource class >> signalInitializationError [
	^TestResult signalErrorWith: 'Resource ' , self name , ' could not be initialized'
			
]

{ #category : #accessing }
TestResource >> description [

	^description ifNil: [ '' ]
]

{ #category : #accessing }
TestResource >> description: aString [

	description := aString
			
]

{ #category : #initializing }
TestResource >> initialize [
	super initialize.
	self setUp

			
]

{ #category : #testing }
TestResource >> isAvailable [
	"override to provide information on the
	readiness of the resource"
	
	^true
			
]

{ #category : #testing }
TestResource >> isUnavailable [
	"override to provide information on the
	readiness of the resource"
	
	^self isAvailable not
			
]

{ #category : #accessing }
TestResource >> name [

	^name ifNil: [ self printString]
]

{ #category : #accessing }
TestResource >> name: aString [

	name := aString
			
]

{ #category : #printing }
TestResource >> printOn: aStream [

	aStream nextPutAll: self class printString
			
]

{ #category : #accessing }
TestResource >> resources [
	^self class resources
			
]

{ #category : #running }
TestResource >> setUp [
	"Does nothing. Subclasses should override this
	to initialize their resource"
			
]

{ #category : #running }
TestResource >> signalInitializationError [
	^self class signalInitializationError
			
]

{ #category : #running }
TestResource >> tearDown [
	"Does nothing. Subclasses should override this
	to tear down their resource"
			
]
