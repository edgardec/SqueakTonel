Class {
	#name : #SqueakToolsTranscriptHelp,
	#superclass : #SqueakToolsHelp,
	#category : #'Help-Squeak-Project'
}

{ #category : #accessing }
SqueakToolsTranscriptHelp class >> bookName [
	^'Transcript'
]

{ #category : #accessing }
SqueakToolsTranscriptHelp class >> pages [
	^# (transcript)
]

{ #category : #pages }
SqueakToolsTranscriptHelp class >> priority [

	^ 20
]

{ #category : #pages }
SqueakToolsTranscriptHelp class >> transcript [
	"This method was automatically generated. Edit it using:"
	"SqueakToolsTranscriptHelp edit: #transcript"
	^(HelpTopic
		title: 'The Transcript window'
		contents: 
'The Transcript window is often used for logging or printing results from text only code. 
To open the Transcript use TheWorldMenu and choose ''open...''. Then choose ''Transcript''.
You can also type

   Transcript open

in a Workspace and doIt.
!
]style[(222 9 11),Rcode://Workspace open;,!' readStream nextChunkText)
			key: #transcript
]
