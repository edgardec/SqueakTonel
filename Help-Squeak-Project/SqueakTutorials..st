Class {
	#name : #SqueakTutorials,
	#superclass : #SqueakHelp,
	#category : #'Help-Squeak-Project'
}

{ #category : #accessing }
SqueakTutorials class >> bookName [ 
	^'Tutorials'
]

{ #category : #pages }
SqueakTutorials class >> introduction [
	"This method was automatically generated. Edit it using:"
	"SqueakTutorials edit: #introduction"
	^(HelpTopic
		title: 'Introduction'
		contents: 
'Here you will some short tutorials on how to use Squeak for daily tasks. Feel free to add your own.!' readStream nextChunkText)
			key: #introduction;
			shouldStyle: false;
			yourself
]

{ #category : #accessing }
SqueakTutorials class >> pages [
	^#(introduction usefulExpressions)
]

{ #category : #pages }
SqueakTutorials class >> usefulExpressions [

	^ (HelpTopic
		title: 'Useful Expressions'
		readOnlyContents: Utilities standardWorkspaceContents)
		shouldStyle: true
]

{ #category : #testing }
SqueakTutorials class >> usesCodeStyling [
	"I want the help browser to use code based styling on my content"
	^true
]
