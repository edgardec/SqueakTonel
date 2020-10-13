"
MorphicUIManager is a UIManager that implements user interface requests for a Morphic user interface.
"
Class {
	#name : #MorphicUIManager,
	#superclass : #UIManager,
	#category : #'ToolBuilder-Morphic'
}

{ #category : #accessing }
MorphicUIManager class >> isActiveManager [
	"Answer whether I should act as the active ui manager"
	^Smalltalk isMorphic
]

{ #category : #'ui requests' }
MorphicUIManager >> chooseClassOrTrait: label from: environment [
	"Let the user choose a Class or Trait. Use ListChooser in Morphic."
	
	| names index |
	names := environment classAndTraitNames.
	index := self
		chooseFrom: names
		lines: #()
		title: label.
	index = 0 ifTrue: [ ^nil ].
	^environment
		at: (names at: index)
		ifAbsent: [ nil ]
]

{ #category : #'ui requests' }
MorphicUIManager >> chooseDirectory: label from: dir [
	"Let the user choose a file matching the given patterns. Returns a file name."
	self askForProvidedAnswerTo: label ifSupplied: [:answer | 
		^ answer].
		
	^ DirectoryChooserDialog openOn: dir label: label
]

{ #category : #'ui requests' }
MorphicUIManager >> chooseFileMatching: patterns label: aString [
	"Let the user choose a file matching the given patterns. Returns a file name."
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		^ answer].
	
	^ FileChooserDialog openOnPattern: patterns label: aString
]

{ #category : #'ui requests' }
MorphicUIManager >> chooseFileMatchingSuffixes: suffixList label: aString [
	"Let the user choose a file matching the given suffixes. Returns a file name."
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		^ answer].
	
	^ FileChooserDialog openOnSuffixList: suffixList label: aString.
	
]

{ #category : #'ui requests' }
MorphicUIManager >> chooseFont: titleString for: aModel setSelector: setSelector getSelector: getSelector [
	"Open a font-chooser for the given model"
	self askForProvidedAnswerTo: titleString ifSupplied: [:answer | 
		^ answer].
	
	^FontChooserTool default
		openWithWindowTitle: titleString 
		for: aModel 
		setSelector: setSelector 
		getSelector: getSelector
]

{ #category : #'ui requests' }
MorphicUIManager >> chooseFrom: aList lines: linesArray title: aString [ 
	"Choose an item from the given list. Answer the index of the selected item. Cancel value is 0.
	
	There are several (historical) reasons for building a button dialog instead of a list chooser for small lists:
	1) Unfortunately, there is existing code that uses this call to create simple confirmation dialogs with a list of #(yes no cancel).
	2) Unfortunately, there is existing code that uses this call to mimick a drop-down menu with a (compact) pop-up menu."
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		(answer = #cancel or: [answer isNil]) ifTrue: [^ 0].
		^ aList indexOf: answer].
	
	aList ifEmpty: [^ 0].
	aList size <= 7 ifTrue: [
		| dialog |
		dialog := DialogWindow new
			title: 'Please Choose';
			message: aString;
			filterEnabled: true;
			autoCancel: true; "Like a pop-up menu, click anywhere to dismiss."
			yourself.
		aList doWithIndex: [:ea :index |
			dialog createButton: ea value: index].
		dialog selectedButtonIndex: 1.
		^ dialog getUserResponseAtHand ifNil: [0]].
	
	^ ListChooser chooseFrom: aList title: aString
]

{ #category : #'ui requests' }
MorphicUIManager >> chooseFrom: labelList values: valueList lines: linesArray title: aString [ 
	"Choose an item from the given list. Answer the selected item."
	
	| index |
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		(answer = #cancel or: [answer isNil]) ifTrue: [^ nil].
		^ valueList at: (labelList indexOf: answer) ifAbsent: [
				answer isNumber 
					ifTrue: [valueList at: answer ifAbsent: [nil]]
					ifFalse: [nil]]].
	
	index := self chooseFrom: labelList lines: linesArray title: aString.
	^ index = 0
		ifTrue: [ nil ]
		ifFalse: [ valueList at: index ]
]

{ #category : #'ui requests' }
MorphicUIManager >> chooseFromOrAddTo: aList lines: linesArray title: aString [

	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		^ answer].

	^ ListChooser
		chooseItemFrom: aList
		title: aString
		addAllowed: true
]

{ #category : #'ui requests' }
MorphicUIManager >> chooseMultipleFrom: aList lines: linesArray title: aString [
	"Choose one or more items from the given list. Answer the indices of the selected items."
	
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		^ answer].
	
	^ ListMultipleChooser
		chooseFrom: aList
		title: aString
]

{ #category : #'ui requests' }
MorphicUIManager >> chooseMultipleFrom: labelList values: valueList lines: linesArray title: aString [
	"Choose one or more items from the given list. Answer the selected items."

	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		^ answer].

	^ (ListMultipleChooser
		chooseFrom: labelList
		title: aString) ifNotNil: [:indexList |
			indexList collect: [:index | valueList at: index]]
]

{ #category : #'ui requests' }
MorphicUIManager >> confirm: queryString [
	"Put up a yes/no menu with caption queryString. Answer true if the 
	response is yes, false if no. This is a modal question--the user must 
	respond yes or no."
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer].
	
	^ UserDialogBoxMorph confirm: queryString
]

{ #category : #'ui requests' }
MorphicUIManager >> confirm: aString orCancel: cancelBlock [
	"Put up a yes/no/cancel menu with caption aString. Answer true if  
	the response is yes, false if no. If cancel is chosen, evaluate  
	cancelBlock. This is a modal question--the user must respond yes or no."
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		^ (answer = #cancel or: [answer isNil]) 
			ifTrue: [cancelBlock value]
			ifFalse: [answer]].
	
	^ UserDialogBoxMorph confirm: aString orCancel: cancelBlock
]

{ #category : #'ui requests' }
MorphicUIManager >> confirm: aString orCancel: cancelBlock title: titleString [
	"Put up a yes/no/cancel menu with caption aString, and titleString to label the dialog.
	Answer true if  the response is yes, false if no. If cancel is chosen, evaluate cancelBlock.
	This is a modal question--the user must respond yes or no."
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		^ (answer = #cancel or: [answer isNil]) 
			ifTrue: [cancelBlock value]
			ifFalse: [answer]].
	
	^ UserDialogBoxMorph
		confirm: aString
		orCancel: cancelBlock
		title: titleString
		at: nil
]

{ #category : #'ui requests' }
MorphicUIManager >> confirm: queryString title: titleString [
	"Put up a yes/no menu with caption queryString, and titleString to label the dialog.
	Answer true if the response is yes, false if no. This is a modal question--the user
	must respond yes or no."
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer].
	
	^ UserDialogBoxMorph confirm: queryString title: titleString
]

{ #category : #'ui requests' }
MorphicUIManager >> confirm: queryString title: titleString trueChoice: trueChoice falseChoice: falseChoice [
	"Put up a yes/no menu with caption queryString, and titleString to label the dialog.
	The actual wording for the two choices will be as provided in the trueChoice and
	falseChoice parameters. Answer true if the response is the true-choice, false if it
	is the false-choice. This is a modal question -- the user must respond one way or
	the other."
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer isBoolean 
			ifTrue: [answer]
			ifFalse: [trueChoice = answer]].
	
	^ UserDialogBoxMorph confirm: queryString title: titleString trueChoice: trueChoice falseChoice: falseChoice 
]

{ #category : #'ui requests' }
MorphicUIManager >> confirm: queryString trueChoice: trueChoice falseChoice: falseChoice [ 
	"Put up a yes/no menu with caption queryString. The actual wording for the two choices will be as provided in the trueChoice and falseChoice parameters. Answer true if the response is the true-choice, false if it's the false-choice.
	This is a modal question -- the user must respond one way or the other."
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer].
	
	^ UserDialogBoxMorph confirm: queryString trueChoice: trueChoice falseChoice: falseChoice 
]

{ #category : #'ui requests' }
MorphicUIManager >> displayProgress: titleString at: aPoint from: minVal to: maxVal during: workBlock [ 
	"Display titleString as a caption over a progress bar while workBlock is evaluated."
	| result progress |
	progress := SystemProgressMorph
		position: aPoint
		label: titleString
		min: minVal
		max: maxVal.
	[ [ result := workBlock value: progress ]
		on: ProgressNotification
		do:
			[ : ex | ex extraParam isString ifTrue:
				[ SystemProgressMorph uniqueInstance
					labelAt: progress
					put: ex extraParam ].
			ex resume ] ] ensure: [ SystemProgressMorph close: progress ].
	^ result
]

{ #category : #'ui requests' }
MorphicUIManager >> edit: aText label: labelString accept: anAction [
	"Open an editor on the given string/text. By default, don't style in such edit: requests."
	
	^ self edit: aText label: labelString shouldStyle: false accept: anAction
]

{ #category : #'ui requests' }
MorphicUIManager >> edit: aText label: labelString shouldStyle: aBoolean accept: anAction [
	"Open an editor on the given string/text"
	| window |
	window := Workspace open.
	labelString ifNotNil: [ window setLabel: labelString ].
	window model
		shouldStyle: aBoolean;
		acceptContents:  aText;
		acceptAction: anAction.
	^ window
]

{ #category : #'ui requests' }
MorphicUIManager >> inform: aString [
	"Display a message for the user to read and then dismiss"
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		^ answer].
	
	^ UserDialogBoxMorph inform: aString
]

{ #category : #'ui requests' }
MorphicUIManager >> informUserDuring: aBlock [
	"Display a message above (or below if insufficient room) the cursor 
	during execution of the given block.
		UIManager default informUserDuring:[:bar|
			#(one two three) do:[:info|
				bar value: info.
				(Delay forSeconds: 1) wait]]"
	SystemProgressMorph
		informUserAt: nil during: aBlock.
]

{ #category : #'ui requests' }
MorphicUIManager >> multiLineRequest: queryString centerAt: aPoint initialAnswer: defaultAnswer answerHeight: answerHeight [
	"Create a multi-line instance of me whose question is queryString with
	the given initial answer. Invoke it centered at the given point, and
	answer the string the user accepts.  Answer nil if the user cancels.  An
	empty string returned means that the ussr cleared the editing area and
	then hit 'accept'.  Because multiple lines are invited, we ask that the user
	use the ENTER key, or (in morphic anyway) hit the 'accept' button, to 
	submit; that way, the return key can be typed to move to the next line."
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer = #default
				ifTrue: [defaultAnswer]
				ifFalse: [answer]].
	
	^ FillInTheBlankMorph 
		request: queryString 
		initialAnswer: defaultAnswer 
		centerAt: aPoint 
		inWorld: self currentWorld
		onCancelReturn: nil
		acceptOnCR: false
]

{ #category : #'ui project indirecting' }
MorphicUIManager >> openPluggableFileList: aPluggableFileList label: aString in: aWorld [
	"PluggableFileList is being deprecated and this can go away soon"
	^aPluggableFileList morphicOpenLabel: aString in: aWorld
]

{ #category : #'ui requests' }
MorphicUIManager >> request: queryString initialAnswer: defaultAnswer [ 
	"Create an instance of me whose question is queryString with the given 
	initial answer. Invoke it centered at the given point, and answer the 
	string the user accepts. Answer the empty string if the user cancels."
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer = #default
				ifTrue: [defaultAnswer]
				ifFalse: [answer]].
	
	^FillInTheBlankMorph request: queryString initialAnswer: defaultAnswer 
]

{ #category : #'ui requests' }
MorphicUIManager >> request: queryString initialAnswer: defaultAnswer centerAt: aPoint [ 
	"Create an instance of me whose question is queryString with the given
	initial answer. Invoke it centered at the given point, and answer the
	string the user accepts. Answer the empty string if the user cancels."
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer = #default
				ifTrue: [defaultAnswer]
				ifFalse: [answer]].
	
	^ FillInTheBlankMorph request: queryString initialAnswer: defaultAnswer centerAt: aPoint
]

{ #category : #'ui requests' }
MorphicUIManager >> request: queryString initialAnswer: defaultAnswer onCancelReturn: cancelResponse [
	"Create an instance of me whose question is queryString with the given initial answer. Answer the string the user accepts. Answer cancelResponse if the user cancels."
	
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer = #default
				ifTrue: [defaultAnswer]
				ifFalse: [answer]].
	
	^ FillInTheBlankMorph
		request: queryString
		initialAnswer: defaultAnswer
		onCancelReturn: cancelResponse
]

{ #category : #'ui requests' }
MorphicUIManager >> requestPassword: queryString [
	"Create an instance of me whose question is queryString. Invoke it centered
	at the cursor, and answer the string the user accepts. Answer the empty 
	string if the user cancels."
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer].
			
	^ FillInTheBlankMorph requestPassword: queryString
]

{ #category : #'ui requests' }
MorphicUIManager >> saveFilenameRequest: queryString initialAnswer: defaultAnswer [ 
	"Open a FileSaverDialog to ask for a place and filename to use for saving a file. The initial suggestion for the filename is defaultAnswer but the user may choose any existing file or type in a new name entirely"
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer = #default
				ifTrue: [defaultAnswer]
				ifFalse: [answer]].

	^ FileSaverDialog openOnInitialFilename: defaultAnswer label: queryString

]

{ #category : #'ui project indirecting' }
MorphicUIManager >> startUpMenu: aMenu withCaption: captionOrNil icon: aForm at: location allowKeyboard: aBoolean [
	"A menu needs to startup and depends on the current type of ui manager for what sort of startup to do. Very ugly, and really needs replacing with a much better menu system"
	
	^aMenu morphicStartUpWithCaption: captionOrNil icon: aForm at: location allowKeyboard: aBoolean
	
]
