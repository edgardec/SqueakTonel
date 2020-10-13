Class {
	#name : #EnvironmentLoader,
	#superclass : #Object,
	#instVars : [
		'environment'
	],
	#category : #'Environments-Loading'
}

{ #category : #'as yet unclassified' }
EnvironmentLoader class >> for: anEnvironment [
	^ self basicNew initializeWithEnvironment: anEnvironment
]

{ #category : #private }
EnvironmentLoader >> evaluate: chunk [
	^ [Compiler evaluate: chunk environment: environment]
		on: CurrentEnvironment
		do: [:req | req resume: environment]
]

{ #category : #private }
EnvironmentLoader >> evaluate: chunk logged: aBoolean [
	^ [Compiler evaluate: chunk environment: environment logged: aBoolean]
		on: CurrentEnvironment
		do: [:req | req resume: environment]
]

{ #category : #'fileIn\/out' }
EnvironmentLoader >> fileIn: aStream announcing: aString [
	| val |
	self logStart: aStream name.
	aString displayProgressFrom: 0 to: aStream size during: 
		[:bar | 
		[aStream atEnd] whileFalse:
			[bar value: aStream position.
			aStream skipSeparators.
			[val := self fileInChunkFrom: aStream]
				on: InMidstOfFileinNotification
				do: [:ex | ex resume: true].
			aStream skipStyleChunk].
		aStream close].	
	self logEnd: aStream name.
	^ val
]

{ #category : #'fileIn\/out' }
EnvironmentLoader >> fileInChunkFrom: aStream [
	| chunk |
	^ (aStream peekFor: $!)
		ifTrue: [ 
			| reader |
			chunk := aStream nextChunk.
			reader := self evaluate: chunk logged: false.
			reader scanFrom: aStream environment: environment]
		ifFalse: [ 
			chunk := aStream nextChunk.
			aStream checkForPreamble: chunk.
			self evaluate: chunk logged: true ]
]

{ #category : #'initialize-release' }
EnvironmentLoader >> initializeWithEnvironment: anEnvironment [
	self initialize.
	environment := anEnvironment
]

{ #category : #private }
EnvironmentLoader >> logEnd: filename [
	"Note:  The main purpose of this banner is to flush the changes file."
	Smalltalk logChange: '----End fileIn of ' , filename , ' into ', environment name, '----'	
]

{ #category : #private }
EnvironmentLoader >> logStart: filename [
	Smalltalk logChange: '----Start fileIn of ' , filename , ' into ' , environment name , '----'
]
