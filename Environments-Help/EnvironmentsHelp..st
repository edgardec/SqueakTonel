Class {
	#name : #EnvironmentsHelp,
	#superclass : #CustomHelp,
	#category : #'Environments-Help'
}

{ #category : #accessing }
EnvironmentsHelp class >> bookName [

	^ 'Environments'
]

{ #category : #pages }
EnvironmentsHelp class >> introduction [
	"This method was automatically generated. Edit it using:"
	"EnvironmentsHelp edit: #introduction"
	^(HelpTopic
		title: 'Introduction'
		contents: 
'An Environment is an object that implements a policy for binding names to objects during compilation.

The simplest and most common use for environments is to allow two classes with the same name to peacefully co-exist.

See:
http://wiki.squeak.org/squeak/6218
http://wiki.squeak.org/squeak/6219
http://wiki.squeak.org/squeak/6220!' readStream nextChunkText)
			key: #introduction
]

{ #category : #accessing }
EnvironmentsHelp class >> pages [

	^ #(introduction)
]
