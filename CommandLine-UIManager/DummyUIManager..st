"
I'm an alternative UIManager used to run an the image without GUI.  I redefine methods which require user input as these requests are irrelevant in a headless environment. 
"
Class {
	#name : #DummyUIManager,
	#superclass : #UIManager,
	#category : #'CommandLine-UIManager'
}

{ #category : #'ui requests' }
DummyUIManager >> chooseDirectory: label from: dir [
	self askForProvidedAnswerTo: label ifSupplied: [:answer | 
		^ answer].

	^ nil
]

{ #category : #'ui requests' }
DummyUIManager >> chooseFrom: aList lines: linesArray title: aString [
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		(answer = #cancel or: [answer isNil]) ifTrue: [^ 0].
		^ aList indexOf: answer].

	^ 1
]

{ #category : #'ui requests' }
DummyUIManager >> chooseFrom: labelList values: valueList lines: linesArray title: aString [
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		(answer = #cancel or: [answer isNil]) ifTrue: [^ nil].
		^ valueList at: (labelList indexOf: answer) ifAbsent: [
				answer isNumber 
					ifTrue: [valueList at: answer ifAbsent: [nil]]
					ifFalse: [nil]]].
	
	^ valueList first
]

{ #category : #'ui requests' }
DummyUIManager >> confirm: queryString [
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer].

	self error: 'No user response possible'
]

{ #category : #'ui requests' }
DummyUIManager >> confirm: aString orCancel: cancelBlock [
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		^ (answer = #cancel or: [answer isNil]) 
			ifTrue: [cancelBlock value]
			ifFalse: [answer]].

	self error: 'No user response possible'
]

{ #category : #'ui requests' }
DummyUIManager >> displayProgress: titleString at: aPoint from: minVal to: maxVal during: workBlock [
	^ workBlock value: Association new
]

{ #category : #'ui requests' }
DummyUIManager >> edit: aText label: labelString accept: anAction [
	^ nil
]

{ #category : #'ui requests' }
DummyUIManager >> inform: aString [
	"Nothing to be done here"
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		^ answer].
]

{ #category : #'ui requests' }
DummyUIManager >> informUserDuring: aBlock [
	aBlock value: Association new.
]

{ #category : #'ui requests' }
DummyUIManager >> request: queryString initialAnswer: defaultAnswer [
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer = #default
				ifTrue: [defaultAnswer]
				ifFalse: [answer]].

	self error: 'No user response possible'
]

{ #category : #'ui requests' }
DummyUIManager >> requestPassword: queryString [

	^ self request: queryString initialAnswer: ''
]

{ #category : #'ui requests' }
DummyUIManager >> saveFilenameRequest: queryString initialAnswer: defaultAnswer [ 
	"Open a FileSaverDialog to ask for a place and filename to use for saving a file. The initial suggestion for the filename is defaultAnswer but the user may choose any existing file or type in a new name entirely"

	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer = #default
				ifTrue: [defaultAnswer]
				ifFalse: [answer]].

	self error: 'No user response possible'
]

{ #category : #'ui project indirecting' }
DummyUIManager >> startUpMenu: aMenu withCaption: captionOrNil icon: aForm at: location allowKeyboard: aBoolean [
	"A menu needs to startup and depends on the current type of ui manager for what sort of startup to do. Very ugly, and really needs replacing with a much better menu system"
	
	^nil
	
]
