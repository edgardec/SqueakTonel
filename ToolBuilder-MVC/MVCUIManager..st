"
MVCUIManager is a UIManager that implements user interface requests for an MVC user interface.
"
Class {
	#name : #MVCUIManager,
	#superclass : #UIManager,
	#category : #'ToolBuilder-MVC'
}

{ #category : #accessing }
MVCUIManager class >> isActiveManager [
	"Answer whether I should act as the active ui manager"
	"This is really a way of answering whether 'Smalltalk isMVC'"
	ScheduledControllers ifNil:[^false].
	^ScheduledControllers activeControllerProcess == Processor activeProcess
]

{ #category : #'ui requests' }
MVCUIManager >> chooseDirectory: label from: dir [
	"Let the user choose a directory"
	^self notYetImplemented
]

{ #category : #'ui requests' }
MVCUIManager >> chooseFileMatching: patterns label: labelString [
	"Let the user choose a file matching the given patterns. Returns a file name."
	^self notYetImplemented
]

{ #category : #'ui requests' }
MVCUIManager >> chooseFileMatchingSuffixes: suffixList label: aString [
	"Let the user choose a file matching the given suffixes. Returns a file name."
	^self notYetImplemented
]

{ #category : #'ui requests' }
MVCUIManager >> chooseFont: aPrompt for: aTarget setSelector: setSelector getSelector: getSelector [
	"MVC Only! prompt for a font and if one is provided, send it to aTarget using a message with selector aSelector."
	| aMenu aChoice aStyle namesAndSizes aFont |
	self askForProvidedAnswerTo: aPrompt ifSupplied: [:answer | 
		^ answer].
	
	aMenu := CustomMenu new.
	TextStyle actualTextStyles keysSortedSafely do:
		[:styleName |
			aMenu add: styleName action: styleName].
	aChoice := aMenu startUpWithCaption: aPrompt.
	aChoice ifNil: [^ self].
	aMenu := CustomMenu new.
	aStyle := TextStyle named: aChoice.
	(namesAndSizes := aStyle fontNamesWithPointSizes) do:
		[:aString | aMenu add: aString action: aString].
	aChoice := aMenu startUpWithCaption: nil.
	aChoice ifNil: [^ self].
	aFont := aStyle fontAt: (namesAndSizes indexOf: aChoice).
	aTarget perform: setSelector with: aFont
]

{ #category : #'ui requests' }
MVCUIManager >> chooseFrom: aList lines: linesArray title: aString [
	"Choose an item from the given list. Answer the index of the selected item."
	| menu |
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		(answer = #cancel or: [answer isNil]) ifTrue: [^ 0].
		^ aList indexOf: answer].
	
	menu := PopUpMenu labelArray: aList lines: linesArray.
	^ aString isEmpty ifTrue:[menu startUp] ifFalse:[menu startUpWithCaption: aString]
]

{ #category : #'ui requests' }
MVCUIManager >> chooseFrom: labelList values: valueList lines: linesArray title: aString [
	"Choose an item from the given list. Answer the selected item."
	| menu |
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		(answer = #cancel or: [answer isNil]) ifTrue: [^ nil].
		^ valueList at: (labelList indexOf: answer) ifAbsent: [
				answer isNumber 
					ifTrue: [valueList at: answer ifAbsent: [nil]]
					ifFalse: [nil]]].
	
	menu := SelectionMenu labels: labelList lines: linesArray selections: valueList.
	^ aString 
		ifEmpty: [menu startUp] 
		ifNotEmpty: [menu startUpWithCaption: aString]
]

{ #category : #'ui requests' }
MVCUIManager >> confirm: queryString [
	"Put up a yes/no menu with caption queryString. Answer true if the 
	response is yes, false if no. This is a modal question--the user must 
	respond yes or no."
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer].
	
	^ PopUpMenu confirm: queryString
]

{ #category : #'ui requests' }
MVCUIManager >> confirm: aString orCancel: cancelBlock [
	"Put up a yes/no/cancel menu with caption aString. Answer true if  
	the response is yes, false if no. If cancel is chosen, evaluate  
	cancelBlock. This is a modal question--the user must respond yes or no."
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		^ (answer = #cancel or: [answer isNil]) 
			ifTrue: [cancelBlock value]
			ifFalse: [answer]].
	
	^ PopUpMenu confirm: aString orCancel: cancelBlock
]

{ #category : #'ui requests' }
MVCUIManager >> confirm: aString orCancel: cancelBlock title: titleString [
	"Put up a yes/no/cancel menu with caption aString, and titleString to label the dialog.
	Answer true if  the response is yes, false if no. If cancel is chosen, evaluate cancelBlock.
	This is a modal question--the user must respond yes or no."
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		^ (answer = #cancel or: [answer isNil]) 
			ifTrue: [cancelBlock value]
			ifFalse: [answer]].
	
	^ PopUpMenu
		confirm: (self dialogStringFromQuery: aString withTitle: titleString)
		orCancel: cancelBlock
]

{ #category : #'ui requests' }
MVCUIManager >> confirm: queryString title: titleString [
	"Put up a yes/no menu with caption queryString, and titleString to label the dialog.
	Answer true if the response is yes, false if no. This is a modal question--the user
	must respond yes or no."
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer].
	
	^ PopUpMenu confirm: (self dialogStringFromQuery: queryString withTitle: titleString)

]

{ #category : #'ui requests' }
MVCUIManager >> confirm: queryString title: titleString trueChoice: trueChoice falseChoice: falseChoice [
	"Put up a yes/no menu with caption queryString, and titleString to label the dialog.
	The actual wording for the two choices will be as provided in the trueChoice and
	falseChoice parameters. Answer true if the response is the true-choice, false if it
	is the false-choice. This is a modal question -- the user must respond one way or
	the other."
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer isBoolean 
			ifTrue: [answer]
			ifFalse: [trueChoice = answer]].
	
	^ PopUpMenu
		confirm: (self dialogStringFromQuery: queryString withTitle: titleString)
		trueChoice: trueChoice
		falseChoice: falseChoice
]

{ #category : #'ui requests' }
MVCUIManager >> confirm: queryString trueChoice: trueChoice falseChoice: falseChoice [ 
	"Put up a yes/no menu with caption queryString. The actual wording for the two choices will be as provided in the trueChoice and falseChoice parameters. Answer true if the response is the true-choice, false if it's the false-choice.
	This is a modal question -- the user must respond one way or the other."
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer].
	
	^ PopUpMenu confirm: queryString trueChoice: trueChoice falseChoice: falseChoice
]

{ #category : #private }
MVCUIManager >> dialogStringFromQuery: queryString withTitle: titleString [
	"In Morphic, it is common to display a simple dialog that has a title bar. In MVC, simple
	dialogs are simple. If the UIManager requests a dialog with title, add the title as a simply
	decorated line at the top of the dialog text." 
	^String streamContents: [ :strm |
		strm nextPutAll: '- ';
			nextPutAll: titleString;
			nextPutAll: ' -';
			nextPut: Character cr;
			nextPutAll: queryString ]

]

{ #category : #'ui requests' }
MVCUIManager >> displayProgress: titleString at: aPoint from: minVal to: maxVal during: workBlock [
	"Display titleString as a caption over a progress bar while workBlock is evaluated."
	| delta savedArea captionText textFrame barFrame outerFrame result range lastW |
	barFrame := aPoint - (75@10) corner: aPoint + (75@10).
	captionText := DisplayText text: titleString asText allBold.
	captionText
		foregroundColor: Color black
		backgroundColor: Color white.
	textFrame := captionText boundingBox insetBy: -4.
	textFrame := textFrame align: textFrame bottomCenter
					with: barFrame topCenter + (0@2).
	outerFrame := barFrame merge: textFrame.
	delta := outerFrame amountToTranslateWithin: Display boundingBox.
	barFrame := barFrame translateBy: delta.
	textFrame := textFrame translateBy: delta.
	outerFrame := outerFrame translateBy: delta.
	savedArea := Form fromDisplay: outerFrame.
	Display fillBlack: barFrame; fillWhite: (barFrame insetBy: 2).
	Display fillBlack: textFrame; fillWhite: (textFrame insetBy: 2).
	captionText displayOn: Display at: textFrame topLeft + (4@4).
	range := maxVal = minVal ifTrue: [1] ifFalse: [maxVal - minVal].  "Avoid div by 0"
	lastW := 0.
	[result := workBlock value:  "Supply the bar-update block for evaluation in the work block"
		[:barVal |
		| w |
		w := ((barFrame width-4) asFloat * ((barVal-minVal) asFloat / range min: 1.0)) asInteger.
		w ~= lastW ifTrue: [
			Display fillGray: (barFrame topLeft + (2@2) extent: w@16).
			lastW := w]]]
		ensure: [savedArea displayOn: Display at: outerFrame topLeft].
	^result
]

{ #category : #'ui requests' }
MVCUIManager >> edit: aText label: labelString accept: anAction [
	"Open an editor on the given string/text"

	Workspace new
		acceptContents: aText;
		acceptAction: anAction;
		openLabel: labelString

]

{ #category : #'ui requests' }
MVCUIManager >> inform: aString [
	"Display a message for the user to read and then dismiss"
	self askForProvidedAnswerTo: aString ifSupplied: [:answer | 
		^ answer].
	
	^ PopUpMenu inform: aString
]

{ #category : #'ui requests' }
MVCUIManager >> informUser: aString during: aBlock [
	"Display a message above (or below if insufficient room) the cursor 
	during execution of the given block.
		UIManager default informUser: 'Just a sec!' during: [(Delay forSeconds: 1) wait].
	"
	(SelectionMenu labels: '')
		displayAt: Sensor cursorPoint
		withCaption: aString
		during: aBlock
]

{ #category : #'ui requests' }
MVCUIManager >> informUserDuring: aBlock [
	"Display a message above (or below if insufficient room) the cursor 
	during execution of the given block.
		UIManager default informUserDuring:[:bar|
			#(one two three) do:[:info|
				bar value: info.
				(Delay forSeconds: 1) wait]]"
	aBlock value:[:string| Transcript cr; show: string].
]

{ #category : #'ui requests' }
MVCUIManager >> multiLineRequest: queryString centerAt: aPoint initialAnswer: defaultAnswer answerHeight: answerHeight [
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
	
	^ FillInTheBlank 
		multiLineRequest: queryString 
		centerAt: aPoint 
		initialAnswer: defaultAnswer 
		answerHeight: answerHeight
]

{ #category : #'ui project indirecting' }
MVCUIManager >> openPluggableFileList: aPluggableFileList label: aString in: aWorld [
	"PluggableFileList is being deprecated and this can go away soon"
	^aPluggableFileList mvcOpenLabel: aString in: aWorld
]

{ #category : #'ui requests' }
MVCUIManager >> request: queryString initialAnswer: defaultAnswer [ 
	"Create an instance of me whose question is queryString with the given 
	initial answer. Invoke it centered at the given point, and answer the 
	string the user accepts. Answer the empty string if the user cancels."
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer = #default
				ifTrue: [defaultAnswer]
				ifFalse: [answer]].
	
	^FillInTheBlank request: queryString initialAnswer: defaultAnswer 
]

{ #category : #'ui requests' }
MVCUIManager >> request: queryString initialAnswer: defaultAnswer centerAt: aPoint [ 
	"Create an instance of me whose question is queryString with the given
	initial answer. Invoke it centered at the given point, and answer the
	string the user accepts. Answer the empty string if the user cancels."
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer = #default
				ifTrue: [defaultAnswer]
				ifFalse: [answer]].
	
	^ FillInTheBlank request: queryString initialAnswer: defaultAnswer centerAt: aPoint 
]

{ #category : #'ui requests' }
MVCUIManager >> request: queryString initialAnswer: defaultAnswer onCancelReturn: cancelResponse [
	"Create an instance of me whose question is queryString with the given initial answer. Answer the string the user accepts. Answer cancelResponse if the user cancels."

	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer = #default
				ifTrue: [defaultAnswer]
				ifFalse: [answer]].
	
	^ FillInTheBlank
		request: queryString
		initialAnswer: defaultAnswer
		onCancelReturn: cancelResponse
]

{ #category : #'ui requests' }
MVCUIManager >> requestPassword: queryString [
	"Create an instance of me whose question is queryString. Invoke it centered
	at the cursor, and answer the string the user accepts. Answer the empty 
	string if the user cancels."
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer].

	^ FillInTheBlank requestPassword: queryString
]

{ #category : #'ui requests' }
MVCUIManager >> saveFilenameRequest: queryString initialAnswer: defaultAnswer [ 
	"Open a FileSaverDialog to ask for a place and filename to use for saving a file. The initial suggestion for the filename is defaultAnswer but the user may choose any existing file or type in a new name entirely"
	"MVC has to stick with the boring way of doing it"
	| result |
	self askForProvidedAnswerTo: queryString ifSupplied: [:answer | 
		^ answer = #default
				ifTrue: [defaultAnswer]
				ifFalse: [answer]].
	
	result := self request: queryString initialAnswer: defaultAnswer.
	^result isEmpty ifTrue: [nil] ifFalse:[result]

]

{ #category : #'ui project indirecting' }
MVCUIManager >> startUpMenu: aMenu withCaption: captionOrNil icon: aForm at: location allowKeyboard: aBoolean [
	"A menu needs to startup and depends on the current type of ui manager for what sort of startup to do. Very ugly, and really needs replacing with a much better menu system"
	
	^aMenu mvcStartUpWithCaption: captionOrNil icon: aForm at: location allowKeyboard: aBoolean
	
]
