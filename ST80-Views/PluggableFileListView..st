"
I provide aview for PluggableFileList
"
Class {
	#name : #PluggableFileListView,
	#superclass : #ModalSystemWindowView,
	#instVars : [
		'acceptButtonView'
	],
	#category : #'ST80-Views'
}

{ #category : #accessing }
PluggableFileListView >> acceptButtonView: aView [

	^acceptButtonView := aView
]

{ #category : #'label access' }
PluggableFileListView >> label: aString [

	super label: aString.
	self noLabel
]

{ #category : #'model access' }
PluggableFileListView >> update: aSymbol [
	(aSymbol = #volumeListIndex or: [aSymbol = #fileListIndex])
		ifTrue: [self updateAcceptButton].
	^super update: aSymbol
]

{ #category : #private }
PluggableFileListView >> updateAcceptButton [

	self model canAccept
		ifTrue:
			[acceptButtonView
				backgroundColor: Color green;
				borderWidth: 3;
				controller: acceptButtonView defaultController]
		ifFalse:
			[acceptButtonView
				backgroundColor: Color lightYellow;
				borderWidth: 1;
				controller: NoController new].
	acceptButtonView display.
]
