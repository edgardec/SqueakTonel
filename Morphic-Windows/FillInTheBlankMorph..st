Class {
	#name : #FillInTheBlankMorph,
	#superclass : #DialogWindow,
	#instVars : [
		'response',
		'done',
		'textPane',
		'responseUponCancel'
	],
	#category : #'Morphic-Windows'
}

{ #category : #'default constants' }
FillInTheBlankMorph class >> defaultAnswerExtent [
	^  (200@ (3 * Preferences standardDefaultTextFont height))
]

{ #category : #'instance creation' }
FillInTheBlankMorph class >> request: queryString [
	"Create an instance of me whose question is queryString. Invoke it centered at the cursor, and answer the string the user accepts. Answer the empty string if the user cancels."
	"FillInTheBlankMorph request: 'What is your favorite color?'"

	^ self
		request: queryString
		initialAnswer: ''
		centerAt: (self currentHand ifNil: [Sensor]) cursorPoint
]

{ #category : #'instance creation' }
FillInTheBlankMorph class >> request: queryString initialAnswer: defaultAnswer [ 
	"Create an instance of me whose question is queryString with the given initial answer. Invoke it centered at the given point, and answer the string the user accepts. Answer the empty string if the user cancels."
	"FillInTheBlankMorph
		request: 'What is your favorite color?'
		initialAnswer: 'red, no blue. Ahhh!'"

	^ self
		request: queryString
		initialAnswer: defaultAnswer
		centerAt: (self currentHand ifNil: [Sensor]) cursorPoint
]

{ #category : #'instance creation' }
FillInTheBlankMorph class >> request: queryString initialAnswer: defaultAnswer centerAt: aPoint [
	"Create an instance of me whose question is queryString with the given initial answer. Invoke it centered at the given point, and answer the string the user accepts. Answer the empty string if the user cancels.
	This variant is only for calling from within a Morphic project."
	"FillInTheBlankMorph
		request: 'Type something, then type CR.'
		initialAnswer: 'yo ho ho!'
		centerAt: Display center"

	 ^ self 
		request: queryString 
		initialAnswer: defaultAnswer 
		centerAt: aPoint 
		inWorld: self currentWorld
]

{ #category : #'instance creation' }
FillInTheBlankMorph class >> request: queryString initialAnswer: defaultAnswer centerAt: aPoint inWorld: aWorld [
	"Create an instance of me whose question is queryString with the given initial answer. Invoke it centered at the given point, and answer the string the user accepts.  Answer the empty string if the user cancels."
	"FillInTheBlankMorph
		request: 'Type something, then type CR.'
		initialAnswer: 'yo ho ho!'
		centerAt: Display center"

	^ self request: queryString initialAnswer: defaultAnswer centerAt: aPoint inWorld: aWorld onCancelReturn: ''
]

{ #category : #'instance creation' }
FillInTheBlankMorph class >> request: queryString initialAnswer: defaultAnswer centerAt: aPoint inWorld: aWorld onCancelReturn: returnOnCancel [
	"Create an instance of me whose question is queryString with the given initial answer. Invoke it centered at the given point, and answer the string the user accepts.   If the user cancels, answer returnOnCancel.  If user hits cr, treat it as a normal accept."

	"FillInTheBlankMorph
		request: 'Type something, then type CR.'
		initialAnswer: 'yo ho ho!'
		centerAt: Display center"

	^ self request: queryString initialAnswer: defaultAnswer centerAt: aPoint inWorld: aWorld onCancelReturn: returnOnCancel acceptOnCR: true
]

{ #category : #'instance creation' }
FillInTheBlankMorph class >> request: queryString initialAnswer: defaultAnswer centerAt: aPoint inWorld: aWorld onCancelReturn: returnOnCancel acceptOnCR: acceptBoolean [
	"Create an instance of me whose question is queryString with the given initial answer. Invoke it centered at the given point, and answer the string the user accepts.   If the user cancels, answer returnOnCancel."

	^ self request: queryString initialAnswer: defaultAnswer centerAt: aPoint 
		inWorld: aWorld onCancelReturn: returnOnCancel 
		acceptOnCR: acceptBoolean answerExtent: self defaultAnswerExtent
]

{ #category : #'instance creation' }
FillInTheBlankMorph class >> request: queryString initialAnswer: defaultAnswer centerAt: aPoint inWorld: aWorld onCancelReturn: returnOnCancel acceptOnCR: acceptBoolean answerExtent: answerExtent [
	"Create an instance of me whose question is queryString with the given initial answer. Invoke it centered at the given point, and answer the string the user accepts.   If the user cancels, answer returnOnCancel."
	"FillInTheBlankMorph
		request: 'Type something, then type CR.'
		initialAnswer: 'yo ho ho!'
		centerAt: Display center"

	| aFillInTheBlankMorph |
	aFillInTheBlankMorph := self new
		setQuery: queryString
		initialAnswer: defaultAnswer
		answerExtent: answerExtent
		acceptOnCR: acceptBoolean.

	aFillInTheBlankMorph createAcceptButton
		action: [aFillInTheBlankMorph textPane accept].
	aFillInTheBlankMorph createCancelButton
		action: [aFillInTheBlankMorph closeDialog: returnOnCancel].
		
	aFillInTheBlankMorph preferredPosition: aPoint.
	^ aFillInTheBlankMorph getUserResponse

]

{ #category : #'instance creation' }
FillInTheBlankMorph class >> request: queryString initialAnswer: defaultAnswer centerAt: aPoint inWorld: aWorld onCancelReturn: returnOnCancel acceptOnCR: acceptBoolean answerHeight: answerHeight [
	"Create an instance of me whose question is queryString with the given initial answer. Invoke it centered at the given point, and answer the string the user accepts.   If the user cancels, answer returnOnCancel."
	^ self request: queryString initialAnswer: defaultAnswer centerAt: aPoint 
		inWorld: aWorld onCancelReturn: returnOnCancel acceptOnCR: acceptBoolean 
		answerExtent: self defaultAnswerExtent x @ answerHeight
]

{ #category : #'instance creation' }
FillInTheBlankMorph class >> requestPassword: queryString [
	"Create an instance of me whose question is queryString. Invoke it centered at the cursor, and answer the string the user accepts. Answer the empty string if the user cancels."
	"use password font"
	"FillInTheBlankMorph requestPassword: 'Password?'"

	^ self
		requestPassword: queryString
		initialAnswer: ''
		centerAt: Sensor cursorPoint
		inWorld: Project current world
		onCancelReturn: ''
		acceptOnCR: true

]

{ #category : #'instance creation' }
FillInTheBlankMorph class >> requestPassword: queryString initialAnswer: defaultAnswer centerAt: aPoint inWorld: aWorld onCancelReturn: returnOnCancel acceptOnCR: acceptBoolean [
	"Create an instance of me whose question is queryString with the given initial answer. Invoke it centered at the given point, and answer the string the user accepts.   If the user cancels, answer returnOnCancel."
	"FillInTheBlankMorph
		request: 'Type something, then type CR.'
		initialAnswer: 'yo ho ho!'
		centerAt: Display center"

	| aFillInTheBlankMorph |
	aFillInTheBlankMorph := self new
		setPasswordQuery: queryString
		initialAnswer: defaultAnswer
		answerHeight: 50
		acceptOnCR: acceptBoolean.

	aFillInTheBlankMorph createAcceptButton
		action: [aFillInTheBlankMorph textPane accept].
	aFillInTheBlankMorph createCancelButton
		action: [aFillInTheBlankMorph closeDialog: returnOnCancel].
		
	aFillInTheBlankMorph preferredPosition: aPoint.
	^ aFillInTheBlankMorph getUserResponse
]

{ #category : #menu }
FillInTheBlankMorph >> codePaneMenu: aMenu shifted: shifted [

	^ StringHolder codePaneMenu: aMenu shifted: shifted.

]

{ #category : #initialization }
FillInTheBlankMorph >> createTextPaneAcceptOnCR: acceptBoolean [ 

	textPane := PluggableTextMorph
				on: self
				text: #response
				accept: #response:
				readSelection: #selectionInterval
				menu: #codePaneMenu:shifted:.
	textPane 
		showScrollBarsOnlyWhenNeeded;
		wantsFrameAdornments: false;
		hasUnacceptedEdits: true;
		askBeforeDiscardingEdits: false;
		setProperty: #alwaysAccept toValue: true;
		acceptOnCR: acceptBoolean;
		setNameTo: 'textPane';
		layoutFrame: (LayoutFrame fractions: (0@0 corner: 1@1));
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		scrollToTop.
	^ textPane
]

{ #category : #events }
FillInTheBlankMorph >> filterEvent: event for: morph [

	(event isKeystroke and: [event keyCharacter = Character escape])
		ifTrue: [event ignore. self cancelDialog].
		
	^ event
]

{ #category : #initialization }
FillInTheBlankMorph >> initialize [

	super initialize.
	self addKeyboardCaptureFilter: self.
]

{ #category : #accessing }
FillInTheBlankMorph >> response [

	^ result

]

{ #category : #accessing }
FillInTheBlankMorph >> response: aText [
	"Sent when text pane accepts."

	result := aText asString.
	self delete.

]

{ #category : #accessing }
FillInTheBlankMorph >> selectionInterval [
	^ 1 to: result size

]

{ #category : #initialization }
FillInTheBlankMorph >> setDefaultParameters [

	super setDefaultParameters.
	textPane ifNotNil: [:tp | tp borderColor: self borderColor].
]

{ #category : #initialization }
FillInTheBlankMorph >> setPasswordQuery: queryString initialAnswer: initialAnswer answerHeight: answerHeight acceptOnCR: acceptBoolean [

	self setQuery: queryString 
		initialAnswer: initialAnswer 
		answerHeight: answerHeight 
		acceptOnCR: acceptBoolean.
	textPane font: (StrikeFont passwordFontSize: 12).
]

{ #category : #initialization }
FillInTheBlankMorph >> setQuery: queryString initialAnswer: initialAnswer answerExtent: answerExtent acceptOnCR: acceptBoolean [ 
	
	| text |
	
	result := initialAnswer.
	done := false.

	self paneMorph removeAllMorphs.

	self title: 'Input Requested' translated.
	self message: queryString.
	
	text := self createTextPaneAcceptOnCR: acceptBoolean.
	self paneMorph addMorphBack: text.

	self paneMorph
		wantsPaneSplitters: true;
		addCornerGrips.
	self paneMorph grips do: [:ea | ea showHandle: true].
		
	self paneMorph extent: ((initialAnswer asText asMorph extent + (20@10) max: answerExtent) min: 500@500).	
	self setDefaultParameters.
]

{ #category : #initialization }
FillInTheBlankMorph >> setQuery: queryString initialAnswer: initialAnswer answerHeight: answerHeight acceptOnCR: acceptBoolean [
	self setQuery: queryString initialAnswer: initialAnswer 
		answerExtent: (self class defaultAnswerExtent x @ answerHeight) 
		acceptOnCR: acceptBoolean

]

{ #category : #accessing }
FillInTheBlankMorph >> textPane [
	^ textPane
]
