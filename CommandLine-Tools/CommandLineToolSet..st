Class {
	#name : #CommandLineToolSet,
	#superclass : #StandardToolSet,
	#classVars : [
		'SaveSnapshotOnError'
	],
	#category : #'CommandLine-Tools'
}

{ #category : #debugging }
CommandLineToolSet class >> debugException: anException [

	"Ignore."
]

{ #category : #debugging }
CommandLineToolSet class >> debugProcess: aProcess context: aContext label: aString contents: contents fullView: aBool [
	"We can't open a command line debugger, so just log the error and carry on."

	| s |
	s := FileStream stderr.
	s
		nextPutAll: self className;
		nextPutAll: ': ';
		nextPutAll: aString;
		cr;
		nextPutAll: contents;
		cr.
	(aContext stackOfSize: 20) do: [:ctx | ctx printOn: s. s cr].
	s flush.
]

{ #category : #'debugging - handlers' }
CommandLineToolSet class >> handleError: anError [ 
	"Print out a sensible stack trace and bail"
	self saveSnapshotOnError ifTrue: [ Smalltalk saveAs: 'Debug-' , Smalltalk imageEntry name ].
	anError printVerboseOn: FileStream stderr.
	FileStream stderr flush.
	Smalltalk
		snapshot: false
		andQuit: true
]

{ #category : #'debugging - handlers' }
CommandLineToolSet class >> handleSyntaxError: anError [ 
	FileStream stderr
		 nextPutAll: '----- Syntax error -----' ;
		 cr ;
		 nextPutAll: anError errorCode ;
		 cr ;
		 nextPutAll: '----- Syntax error -----' ;
		 cr ;
		 flush.
	self handleError: anError
]

{ #category : #'debugging - handlers' }
CommandLineToolSet class >> handleUserInterruptRequest: aString [

	self saveSnapshotOnError ifTrue: [ Smalltalk saveAs: 'Debug-' , Smalltalk imageEntry name ].

	FileStream stderr nextPutAll: aString.
	FileStream stderr flush.
	Smalltalk
		snapshot: false
		andQuit: true
]

{ #category : #'debugging - handlers' }
CommandLineToolSet class >> handleWarning: aWarning [

	self handleError: aWarning.
]

{ #category : #preferences }
CommandLineToolSet class >> saveSnapshotOnError [
	<preference: 'Save snapshot of image on failure'
	category: 'debug'
	description: 'If true, saves a snapshot of the failing image to the current directory under the name Debug-{current image name}'
	type: #Boolean>
	^ SaveSnapshotOnError ifNil: [SaveSnapshotOnError := false].
]

{ #category : #preferences }
CommandLineToolSet class >> saveSnapshotOnError: aBoolean [
	SaveSnapshotOnError := aBoolean.
]

{ #category : #'class initialization' }
CommandLineToolSet class >> unload [
	ToolSet unregister: self.
]
