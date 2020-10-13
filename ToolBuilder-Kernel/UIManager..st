"
UIManager is a dispatcher for various user interface requests, such as menu and dialog interactions. An instance of UIManager is associated with each Project to implement the appropriate functions for Morphic, MVC or other user interfaces.
"
Class {
	#name : #UIManager,
	#superclass : #Object,
	#instVars : [
		'builderClass'
	],
	#classVars : [
		'OpenToolsAttachedToMouseCursor'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #'class initialization' }
UIManager class >> default [
	^ Project uiManager
]

{ #category : #'class initialization' }
UIManager class >> getDefault [
	"Ensure that a more specific manager can always be made by subclassing
	a tool builder and implementing a more specific way of reacting to
	#isActiveManager. For example, a BobsUIManager can subclass
	MorphicUIManager and (if enabled, say Preferences useBobsUI) will
	be considered before the parent (generic MorphicUIManager)."

	^ (self allSubclasses
		detect: [:any | any isActiveManager
				and: [any subclasses
						noneSatisfy: [:sub | sub isActiveManager]]]
		ifNone: [])
		ifNotNil: [:mgrClass | mgrClass new]
]

{ #category : #'class initialization' }
UIManager class >> isActiveManager [
	"Answer whether I should act as the active ui manager"
	^false
]

{ #category : #preferences }
UIManager class >> openToolsAttachedToMouseCursor [

	<preference: 'Open Tools Attached to Mouse Cursor'
		categoryList: #(Tools mouse)
		description: 'If enabled, new tool windows will be attached to the mouse cursor to be positioned on screen with an additional click. Only occurs if a mouse event triggered that tool opening.'
		type: #Boolean>
	^ OpenToolsAttachedToMouseCursor ifNil: [false]
]

{ #category : #preferences }
UIManager class >> openToolsAttachedToMouseCursor: aBoolean [

	OpenToolsAttachedToMouseCursor := aBoolean.
]

{ #category : #utilities }
UIManager >> askForProvidedAnswerTo: queryString ifSupplied: supplyBlock [

	^ (ProvideAnswerNotification signal: queryString asString) ifNotNil: supplyBlock
]

{ #category : #builder }
UIManager >> builderClass [
	"Answer the kind of tool builder to use, possibly influenced by project preferences"
	^ builderClass ifNil: [ builderClass := ToolBuilder findDefault ]
]

{ #category : #accessing }
UIManager >> builderClass: aClass [
	builderClass := aClass
]

{ #category : #'ui requests - code' }
UIManager >> chooseClassOrTrait [
	"Let the user choose a Class or Trait"
	
	^self chooseClassOrTraitFrom: Smalltalk globals
]

{ #category : #'ui requests - code' }
UIManager >> chooseClassOrTrait: label [
	"Let the user choose a Class or Trait"
	
	^self chooseClassOrTrait: label from: Smalltalk environment
]

{ #category : #'ui requests - code' }
UIManager >> chooseClassOrTrait: label from: environment [
	"Let the user choose a Class or Trait."
	
	| pattern |
	pattern := self request: label.
	^ self classOrTraitFrom: environment pattern: pattern label: label
	
]

{ #category : #'ui requests - code' }
UIManager >> chooseClassOrTraitFrom: anEnvironment [
	"Let the user choose a Class or Trait from the given environment"
	
	^self chooseClassOrTrait: 'Class name or fragment?' from: anEnvironment
]

{ #category : #'ui requests - files' }
UIManager >> chooseDirectory [
	"Let the user choose a directory. Returns a proper directory."
	^self chooseDirectoryFrom: FileDirectory default
]

{ #category : #'ui requests - files' }
UIManager >> chooseDirectory: label [
	"Let the user choose a directory. Returns a proper directory."
	^self chooseDirectory: label from: FileDirectory default
]

{ #category : #'ui requests - files' }
UIManager >> chooseDirectory: label from: dir [
	"Let the user choose a directory. Returns a proper directory."
	"UIManager default chooseDirectory: 'Choose one' from: FileDirectory default"
	^self subclassResponsibility
]

{ #category : #'ui requests - files' }
UIManager >> chooseDirectoryFrom: dir [
	"Let the user choose a directory. Returns a proper directory."
	^self chooseDirectory: nil from: dir
]

{ #category : #'ui requests - files' }
UIManager >> chooseFileMatching: patterns [
	"Let the user choose a file matching the given patterns. Returns a file name."
	^self chooseFileMatching: patterns label: nil
]

{ #category : #'ui requests - files' }
UIManager >> chooseFileMatching: patterns label: labelString [
	"Let the user choose a file matching the given patterns. Returns a file name."
	^self subclassResponsibility
]

{ #category : #'ui requests - files' }
UIManager >> chooseFileMatchingSuffixes: suffixList [
	"Let the user choose a file matching the given suffixes. Returns a file name."
	^self chooseFileMatchingSuffixes: suffixList label: nil
]

{ #category : #'ui requests - files' }
UIManager >> chooseFileMatchingSuffixes: suffixList label: labelString [
	"Let the user choose a file matching the given suffixes. Returns a file name."
	^self subclassResponsibility
]

{ #category : #'ui requests - text' }
UIManager >> chooseFont: titleString for: aModel setSelector: setSelector getSelector: getSelector [
	"Open a font-chooser for the given model"
	^self subclassResponsibility
]

{ #category : #'ui requests' }
UIManager >> chooseFrom: aList [
	"Choose an item from the given list. Answer the index of the selected item."
	^self chooseFrom: aList lines: #()
]

{ #category : #'ui requests' }
UIManager >> chooseFrom: aList lines: linesArray [
	"Choose an item from the given list. Answer the index of the selected item."
	^self chooseFrom: aList lines: linesArray title: ''
]

{ #category : #'ui requests' }
UIManager >> chooseFrom: aList lines: linesArray title: aString [
	"Choose an item from the given list. Answer the index of the selected item."
	^self subclassResponsibility
]

{ #category : #'ui requests' }
UIManager >> chooseFrom: aList title: aString [
	"Choose an item from the given list. Answer the index of the selected item."
	^self chooseFrom: aList lines: #() title: aString
]

{ #category : #'ui requests' }
UIManager >> chooseFrom: labelList values: valueList [
	"Choose an item from the given list. Answer the selected item."
	^self chooseFrom: labelList values: valueList lines: #()
]

{ #category : #'ui requests' }
UIManager >> chooseFrom: labelList values: valueList lines: linesArray [
	"Choose an item from the given list. Answer the selected item."
	^self chooseFrom: labelList values: valueList lines: linesArray title: ''
]

{ #category : #'ui requests' }
UIManager >> chooseFrom: labelList values: valueList lines: linesArray title: aString [
	"Choose an item from the given list. Answer the selected item."
	^self subclassResponsibility
]

{ #category : #'ui requests' }
UIManager >> chooseFrom: labelList values: valueList title: aString [
	"Choose an item from the given list. Answer the selected item."
	^self chooseFrom: labelList values: valueList lines: #() title: aString
]

{ #category : #'ui requests' }
UIManager >> chooseFromLabeledValues: aDictionary [
	"Choose a key from the given dictionary. Answer the corresponding value."
	^self chooseFromLabeledValues: aDictionary title: ''
]

{ #category : #'ui requests' }
UIManager >> chooseFromLabeledValues: aDictionary title: aString [
	"Choose a key from the given dictionary. Answer the corresponding value."
	^self chooseFrom: aDictionary keys values: aDictionary values title: aString
]

{ #category : #'ui requests' }
UIManager >> chooseFromOrAddTo: aList lines: linesArray title: aString [

	| index |
	index := self
		chooseFrom: {'new...'}, aList
		lines: linesArray + 1
		title: aString.
	index = 0 ifTrue: [^ nil].
	index = 1 ifTrue:
		[^ self request: 'Please type new value' initialAnswer: ''].
	^ aList at: index - 1
]

{ #category : #'ui requests' }
UIManager >> chooseMultipleFrom: aList [
	"Choose one or more items from the given list. Answer the indices of the selected items."
	
	^ self chooseMultipleFrom: aList lines: #()
]

{ #category : #'ui requests' }
UIManager >> chooseMultipleFrom: aList lines: linesArray [
	"Choose one or more items from the given list. Answer the indices of the selected items."
	
	^ self chooseMultipleFrom: aList lines: linesArray title: ''
]

{ #category : #'ui requests' }
UIManager >> chooseMultipleFrom: aList lines: linesArray title: aString [
	"Choose one or more items from the given list. Answer the indices of the selected items."
	
	^ (self chooseFrom: aList lines: linesArray title: aString) in: [:result |
		result = 0 ifTrue: [#()] ifFalse: [{result}]]
]

{ #category : #'ui requests' }
UIManager >> chooseMultipleFrom: aList title: aString [
	"Choose one or more items from the given list. Answer the indices of the selected items."
	
	^self chooseMultipleFrom: aList lines: #() title: aString
]

{ #category : #'ui requests' }
UIManager >> chooseMultipleFrom: labelList values: valueList [
	"Choose one or more items from the given list. Answer the selected items."
	
	^ self chooseMultipleFrom: labelList values: valueList lines: #()
]

{ #category : #'ui requests' }
UIManager >> chooseMultipleFrom: labelList values: valueList lines: linesArray [
	"Choose one or more items from the given list. Answer the selected items."
	
	^ self chooseMultipleFrom: labelList values: valueList lines: linesArray title: ''
]

{ #category : #'ui requests' }
UIManager >> chooseMultipleFrom: labelList values: valueList lines: linesArray title: aString [
	"Choose one or more items from the given list. Answer the selected items."

	^ (self chooseFrom: labelList values: valueList lines: linesArray title: aString)
		ifNil: [#()]
		ifNotNil: [:resultValue | {resultValue}]
]

{ #category : #'ui requests' }
UIManager >> chooseMultipleFrom: labelList values: valueList title: aString [
	"Choose one or more items from the given list. Answer the selected items."
	
	^ self chooseMultipleFrom: labelList values: valueList lines: #() title: aString
]

{ #category : #'system introspecting' }
UIManager >> classFromPattern: pattern withCaption: aCaption [
	^self classFromPattern: pattern withCaption: aCaption in: Smalltalk environment
"
	self classFromPattern: 'CharRecog' withCaption: ''
	self classFromPattern: 'rRecog' withCaption: ''
	self classFromPattern: 'znak' withCaption: ''
	self classFromPattern: 'orph' withCaption: ''
	self classFromPattern: 'TCompil' withCaption: ''
"

]

{ #category : #'system introspecting' }
UIManager >> classFromPattern: pattern withCaption: aCaption in: anEnvironment [
	"If there is a class or trait whose name exactly given by pattern, return it.
	If there is only one class or trait in the system whose name matches pattern, return it.
	Otherwise, put up a menu offering the names of all classes that match pattern, and return the class chosen, else nil if nothing chosen.
	This method ignores separator characters in the pattern"

	^self classOrTraitFrom: anEnvironment pattern: pattern label: aCaption
"
	for examples, see #classFromPattern:withCaption:
"

]

{ #category : #'system introspecting' }
UIManager >> classOrTraitFrom: environment pattern: pattern label: label [
	
	^ ((SystemNavigation for: environment) allClassesAndTraitsMatching: pattern)
		ifEmpty: [nil]
		ifNotEmpty: [:results |
			results size = 1
				ifTrue: [results first]
				ifFalse: [self
							chooseFrom: (results collect: [:each | each name])
							values: results
							title: label]]
]

{ #category : #'ui requests' }
UIManager >> confirm: queryString [
	"Put up a yes/no menu with caption queryString. Answer true if the 
	response is yes, false if no. This is a modal question--the user must 
	respond yes or no."
	^self subclassResponsibility
]

{ #category : #'ui requests' }
UIManager >> confirm: aString orCancel: cancelBlock [
	"Put up a yes/no/cancel menu with caption aString. Answer true if  
	the response is yes, false if no. If cancel is chosen, evaluate  
	cancelBlock. This is a modal question--the user must respond yes or no."
	^self subclassResponsibility
]

{ #category : #'ui requests' }
UIManager >> confirm: aString orCancel: cancelBlock title: titleString [
	"Put up a yes/no/cancel menu with caption aString, and titleString to label the dialog.
	Answer true if  the response is yes, false if no. If cancel is chosen, evaluate cancelBlock.
	This is a modal question--the user must respond yes or no."
	^self subclassResponsibility
]

{ #category : #'ui requests' }
UIManager >> confirm: queryString title: titleString [
	"Put up a yes/no menu with caption queryString, and titleString to label the dialog.
	Answer true if the response is yes, false if no. This is a modal question--the user
	must respond yes or no."
	^self subclassResponsibility
]

{ #category : #'ui requests' }
UIManager >> confirm: queryString title: titleString trueChoice: trueChoice falseChoice: falseChoice [
	"Put up a yes/no menu with caption queryString, and titleString to label the dialog.
	The actual wording for the two choices will be as provided in the trueChoice and
	falseChoice parameters. Answer true if the response is the true-choice, false if it
	is the false-choice. This is a modal question -- the user must respond one way or
	the other."
	^self subclassResponsibility
]

{ #category : #'ui requests' }
UIManager >> confirm: queryString trueChoice: trueChoice falseChoice: falseChoice [ 
	"Put up a yes/no menu with caption queryString. The actual wording for the two choices will be as provided in the trueChoice and falseChoice parameters. Answer true if the response is the true-choice, false if it's the false-choice.
	This is a modal question -- the user must respond one way or the other."
	^self subclassResponsibility
]

{ #category : #'ui requests - progress' }
UIManager >> displayProgress: titleString at: aPoint from: minVal to: maxVal during: workBlock [
	"Display titleString as a caption over a progress bar while workBlock is evaluated."
	^self subclassResponsibility
]

{ #category : #'ui requests - text' }
UIManager >> edit: aText [
	"Open an editor on the given string/text"
	^self edit: aText label: nil
]

{ #category : #'ui requests - text' }
UIManager >> edit: aText label: labelString [
	"Open an editor on the given string/text"
	^self edit: aText label: labelString accept: nil
]

{ #category : #'ui requests - text' }
UIManager >> edit: aText label: labelString accept: anAction [
	"Open an editor on the given string/text"
	^self subclassResponsibility
]

{ #category : #'ui requests - text' }
UIManager >> edit: aText label: labelString shouldStyle: aBoolean [
	"Open an editor on the given string/text"
	^self edit: aText label: labelString shouldStyle: aBoolean accept: nil
]

{ #category : #'ui requests - text' }
UIManager >> edit: aText label: labelString shouldStyle: aBoolean accept: anAction [
	"Open an editor on the given string/text"
	^self edit: aText label: labelString accept: anAction
]

{ #category : #'ui requests' }
UIManager >> inform: aString [
	"Display a message for the user to read and then dismiss"
	^self subclassResponsibility
]

{ #category : #'ui requests - progress' }
UIManager >> informUser: aString during: aBlock [
	"Display a message above (or below if insufficient room) the cursor 
	during execution of the given block.
		UIManager default informUser: 'Just a sec!' during: [(Delay forSeconds: 1) wait].
	"
	^self informUserDuring:[:bar| bar value: aString. aBlock value].
]

{ #category : #'ui requests - progress' }
UIManager >> informUserDuring: aBlock [
	"Display a message above (or below if insufficient room) the cursor 
	during execution of the given block.
		UIManager default informUserDuring:[:bar|
			#(one two three) do:[:info|
				bar value: info.
				(Delay forSeconds: 1) wait]]"
	^self subclassResponsibility
]

{ #category : #'ui requests - text' }
UIManager >> multiLineRequest: queryString centerAt: aPoint initialAnswer: defaultAnswer answerHeight: answerHeight [
	"Create a multi-line instance of me whose question is queryString with
	the given initial answer. Invoke it centered at the given point, and
	answer the string the user accepts.  Answer nil if the user cancels.  An
	empty string returned means that the ussr cleared the editing area and
	then hit 'accept'.  Because multiple lines are invited, we ask that the user
	use the ENTER key, or (in morphic anyway) hit the 'accept' button, to 
	submit; that way, the return key can be typed to move to the next line."
	^self subclassResponsibility
]

{ #category : #'ui project indirecting' }
UIManager >> openPluggableFileList: aPluggableFileList label: aString in: aWorld [
	"PluggableFileList is being deprecated and this can go away soon"
	^self subclassResponsibility
]

{ #category : #accessing }
UIManager >> openToolsAttachedToMouseCursor [
	self flag: #todo. "mt: Let each instances of ui manager have its own setting."
	^ self class openToolsAttachedToMouseCursor
]

{ #category : #accessing }
UIManager >> openToolsAttachedToMouseCursor: aBoolean [
	self flag: #todo. "mt: Let each instances of ui manager have its own setting."
	self class openToolsAttachedToMouseCursor: aBoolean.
]

{ #category : #'ui requests - text' }
UIManager >> request: queryString [ 
	"Create an instance of me whose question is queryString. Invoke it 
	centered at the cursor, and answer the string the user accepts. Answer 
	the empty string if the user cancels."
	^self request: queryString initialAnswer: ''
]

{ #category : #'ui requests - text' }
UIManager >> request: queryString initialAnswer: defaultAnswer [ 
	"Create an instance of me whose question is queryString with the given initial answer. Answer the  string the user accepts. Answer the empty string if the user cancels."
	
	^ self subclassResponsibility
]

{ #category : #'ui requests - text' }
UIManager >> request: queryString initialAnswer: defaultAnswer centerAt: aPoint [ 
	"Create an instance of me whose question is queryString with the given initial answer. Invoke it centered at the given point, and answer the	string the user accepts. Answer the empty string if the user cancels."

	^ self request: queryString initialAnswer: defaultAnswer
]

{ #category : #'ui requests - text' }
UIManager >> request: queryString initialAnswer: defaultAnswer onCancelReturn: cancelResponse [
	"Create an instance of me whose question is queryString with the given initial answer. Answer the string the user accepts. Answer cancelResponse if the user cancels."

	^ self request: queryString initialAnswer: defaultAnswer
]

{ #category : #'ui requests - text' }
UIManager >> requestPassword: queryString [
	"Create an instance of me whose question is queryString. Invoke it centered
	at the cursor, and answer the string the user accepts. Answer the empty 
	string if the user cancels."
	^self subclassResponsibility
]

{ #category : #'ui requests - files' }
UIManager >> saveFilenameRequest: queryString initialAnswer: defaultAnswer [ 
	"Open a FileSaverDialog to ask for a place and filename to use for saving a file. The initial suggestion for the filename is defaultAnswer but the user may choose any existing file or type in a new name entirely. Returns a file name."

	^self subclassResponsibility
]

{ #category : #accessing }
UIManager >> screenBounds [
	^ Display boundingBox
]

{ #category : #'ui project indirecting' }
UIManager >> startUpMenu: aMenu withCaption: captionOrNil icon: aForm at: location allowKeyboard: aBoolean [
	"A menu needs to startup and depends on the current type of ui manager for what sort of startup to do. Very ugly, and really needs replacing with a much better menu system"
	
	^self subclassResponsibility
	
]

{ #category : #builder }
UIManager >> toolBuilder [
	^ self builderClass new
]
