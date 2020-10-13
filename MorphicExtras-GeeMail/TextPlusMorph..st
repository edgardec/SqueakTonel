Class {
	#name : #TextPlusMorph,
	#superclass : #TextMorph,
	#instVars : [
		'scrollerOwner',
		'ignoreNextUp'
	],
	#category : #'MorphicExtras-GeeMail'
}

{ #category : #'new-morph participation' }
TextPlusMorph class >> includeInNewMorphMenu [

	^ false
]

{ #category : #menus }
TextPlusMorph >> addAlansAnchorFor: aMorph [

	| ed attribute selRects |

	self removeAlansAnchorFor: aMorph.
	ed := self editor.
	attribute := TextAnchor new anchoredMorph: aMorph.
	aMorph setProperty: #geeMailLeftOffset toValue: aMorph left - self left.
	ed replaceSelectionWith: (ed selection addAttribute: attribute).
	selRects := self paragraph selectionRects.
	selRects isEmpty ifFalse: [
		aMorph top: selRects first top
	].
	self releaseParagraphReally.
	self layoutChanged.


]

{ #category : #menus }
TextPlusMorph >> addColumnBreak [

	| ed old new break |

	ed := self editor.
	old := ed selection.
	break := Character characterForColumnBreak asString.
	break := Text string: break attributes: {}.
	new := old ,break.
	ed replaceSelectionWith: new.
	self releaseParagraphReally.
	self layoutChanged.


]

{ #category : #'add\/remove' }
TextPlusMorph >> addItem: classAndMethod [
	"Make a linked message list and put this method in it"

	Model new addItem: classAndMethod	"let him do all the work"
]

{ #category : #menus }
TextPlusMorph >> addJumpBeginning [

	| ed attribute jumpEnd mySelection a1 ax |

	ed := self editor.
	(mySelection := ed selection) isEmpty ifTrue: [^self inform: 'Please select something first'].
	jumpEnd := self chooseOneJumpEnd.
	jumpEnd isEmptyOrNil ifTrue: [^self].

	attribute := TextPlusJumpStart new jumpLabel: jumpEnd.
	a1 := (mySelection attributesAt: 1) reject: [ :each | each isKindOf: TextPlusJumpStart].
	ax := (mySelection attributesAt: mySelection size) reject: [ :each | each isKindOf: TextPlusJumpStart].
	ed replaceSelectionWith: 
		(Text string: '*' attributes: a1),
		(mySelection addAttribute: attribute),
		(Text string: '*' attributes: ax).
	self releaseParagraphReally.
	self layoutChanged.


]

{ #category : #menus }
TextPlusMorph >> addJumpEnd [

	| ed attribute jumpLabel selectedString |

	ed := self editor.
	selectedString := ed selection asString.
	selectedString isEmpty ifTrue: [^self inform: 'Please select something first'].
	jumpLabel := UIManager default request: 'Name this place' initialAnswer: selectedString.
	jumpLabel isEmpty ifTrue: [^self].
	self removeJumpEndFor: jumpLabel.
	attribute := TextPlusJumpEnd new jumpLabel: jumpLabel.
	ed replaceSelectionWith: (ed selection addAttribute: attribute).


]

{ #category : #'linked frames' }
TextPlusMorph >> addSuccessor: evt [

	evt hand attachMorph: self makeSuccessorMorph
]

{ #category : #'private - menus' }
TextPlusMorph >> allJumpEndStrings [

	| answer |

	answer := OrderedCollection new.
	text runs withStartStopAndValueDo: [:start :stop :attributes |
		attributes do: [:att |
			(att isMemberOf: TextPlusJumpEnd) ifTrue: [
				(answer includes: att jumpLabel) ifFalse: [answer add: att jumpLabel].
			]
		]
	].
	^answer


]

{ #category : #'private - menus' }
TextPlusMorph >> chooseOneJumpEnd [

	^UIManager default
		chooseFrom: self allJumpEndStrings
		values: self allJumpEndStrings
		title: 'Possible jump ends'.
	

]

{ #category : #'objects from disk' }
TextPlusMorph >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	"Fix up misaligned entries from varDict in old project"
	varDict at: 'slotName' ifPresent: [ :x | text:= x]. "Not sure why the text is in 'slotName'"
	varDict at: 'model' ifPresent: [ :x | textStyle:= x]."Or why textStyle is in 'model'"
	self releaseParagraphReally.
	^ super convertToCurrentVersion: varDict refStream: smartRefStrm.


]

{ #category : #jumping }
TextPlusMorph >> doJumpTo: aString [

	| myStart myStop |
	myStart := myStop := nil.
	text runs withStartStopAndValueDo: [:start :stop :attributes |
		attributes do: [:att |
			((att isMemberOf: TextPlusJumpEnd) and: [att jumpLabel = aString]) ifTrue: [
				myStart 
					ifNil: [myStart := start. myStop := stop] 
					ifNotNil: [myStart := myStart min: start. myStop := myStop max: stop].
			]
		]
	].
	myStart ifNil: [^self].

	self editor selectFrom: myStart to: myStop.
	ignoreNextUp := true.
	self changed.
	self scrollSelectionToTop.

]

{ #category : #menus }
TextPlusMorph >> doYellowButtonPress: evt [

	| menu |

	menu := MenuMorph new.
	menu 
		add: 'Go to top of document'				action: [self jumpToDocumentTop];
		add: 'Move selection to top of page'		action: [self scrollSelectionToTop];
		add: 'Add column break'					action: [self addColumnBreak];
		add: 'Define as jump start'				action: [self addJumpBeginning];
		add: 'Define as jump end'				action: [self addJumpEnd].
	menu title: 'Text navigation options'.
	menu invokeModal.

]

{ #category : #'private - linked frames' }
TextPlusMorph >> fixAllLeftOffsets [

	

	text runs withStartStopAndValueDo: [:start :stop :attributes |
		attributes do: [:att | | am |
			(att isMemberOf: TextAnchor) ifTrue: [
				am := att anchoredMorph.
				(am isNil or: [am world isNil]) ifFalse: [
					am 
						valueOfProperty: #geeMailLeftOffset 
						ifAbsent: [
							am setProperty: #geeMailLeftOffset toValue: am left - self left
						]
				]
			]
		]
	].


]

{ #category : #editing }
TextPlusMorph >> handleInteraction: interactionBlock fromEvent: evt [
	
	super handleInteraction: interactionBlock fromEvent: evt.
	(self parentGeeMail ifNil: [^self])
		scrollSelectionIntoView: evt 
		alignTop: false 
		inTextMorph: self.

]

{ #category : #jumping }
TextPlusMorph >> jumpToDocumentTop [

	self editor selectFrom: 1 to: 0.
	self changed.
	self scrollSelectionToTop.

]

{ #category : #'event handling' }
TextPlusMorph >> keyboardFocusChange: aBoolean [

	| parent |

	"we basically ignore loss of focus unless it is going to one of our siblings"
	aBoolean ifFalse: [^self].

	paragraph isNil ifFalse:[paragraph focused: aBoolean].

	"A hand is wanting to send us characters..."
	self hasFocus ifFalse: [self editor "Forces install"].

	"Inform our siblings we have taken the focus"
	parent := self parentGeeMail ifNil: [^self].
	parent allTextPlusMorphs do: [ :each |
		each == self ifFalse: [each keyboardFocusLostForSure]
	].


]

{ #category : #private }
TextPlusMorph >> keyboardFocusLostForSure [

	editor ifNotNil: [
		self selectionChanged.
		self paragraph selectionStart: nil selectionStop: nil.
		editor := nil
	].



]

{ #category : #private }
TextPlusMorph >> linkNewlyDroppedMorph: aMorph [

	| ed para lineToUse |

	ed := self editor.
	para := self paragraph.
	lineToUse := para lines detect: [ :each | each bottom > aMorph top] ifNone: [para lines last].
	ed selectFrom: lineToUse first to: lineToUse last.
	self addAlansAnchorFor: aMorph.


]

{ #category : #'private - linked frames' }
TextPlusMorph >> makeSuccessorMorph [

	| newMorph |
	self fixAllLeftOffsets.
	newMorph := self copy predecessor: self successor: successor.
	newMorph extent: self width @ 100.
	successor ifNotNil: [successor setPredecessor: newMorph].
	self setSuccessor: newMorph.
	successor recomposeChain.
	^newMorph
]

{ #category : #'event handling' }
TextPlusMorph >> mouseDown: evt [

	ignoreNextUp := false.
	evt yellowButtonPressed ifTrue: [
		^self doYellowButtonPress: evt
	].
	^super mouseDown: evt

]

{ #category : #'event handling' }
TextPlusMorph >> mouseMove: evt [

	ignoreNextUp == true ifTrue: [^self].
	^super mouseMove: evt

]

{ #category : #'event handling' }
TextPlusMorph >> mouseUp: evt [

	ignoreNextUp == true ifTrue: [ignoreNextUp := false. ^self].
	^super mouseUp: evt

]

{ #category : #private }
TextPlusMorph >> parentGeeMail [
	
	^self ownerThatIsA: GeeMailMorph

]

{ #category : #private }
TextPlusMorph >> predecessorChanged [

	super predecessorChanged.
	self repositionAnchoredMorphs.

]

{ #category : #'linked frames' }
TextPlusMorph >> recomposeChain [
	"Recompose this textMorph and all that follow it."
	self withSuccessorsDo:
		[:m |  m text: text textStyle: textStyle;  "Propagate new style if any"
				releaseParagraphReally;  "Force recomposition"
				fit  "and propagate the change"]

]

{ #category : #private }
TextPlusMorph >> releaseEditor [
]

{ #category : #private }
TextPlusMorph >> releaseParagraph [
]

{ #category : #private }
TextPlusMorph >> releaseParagraphReally [
	"Paragraph instantiation is lazy -- it will be created only when needed"

	editor ifNotNil: [
		self selectionChanged.
		self paragraph selectionStart: nil selectionStop: nil.
		editor := nil].
	paragraph ifNotNil: [paragraph := nil].
	container ifNotNil: [container releaseCachedState]
]

{ #category : #menus }
TextPlusMorph >> removeAlansAnchorFor: aMorph [

	| anchors |

	anchors := OrderedCollection new.
	text runs withStartStopAndValueDo: [:start :stop :attributes |
		attributes do: [:att |
			(att isMemberOf: TextAnchor) ifTrue: [
				(att anchoredMorph isNil or: [
					att anchoredMorph == aMorph or: [att anchoredMorph world isNil]]) ifTrue: [
					anchors add: {att. start. stop}
				]
			]
		]
	].
	anchors do: [ :old |
		text removeAttribute: old first from: old second to: old third.
	].


]

{ #category : #'private - menus' }
TextPlusMorph >> removeJumpEndFor: aString [

	| anchors |

	anchors := OrderedCollection new.
	text runs withStartStopAndValueDo: [:start :stop :attributes |
		attributes do: [:att |
			(att isMemberOf: TextPlusJumpEnd) ifTrue: [
				att jumpLabel == aString ifTrue: [
					anchors add: {att. start. stop}
				]
			]
		]
	].
	anchors do: [ :old |
		text removeAttribute: old first from: old second to: old third.
	].


]

{ #category : #private }
TextPlusMorph >> repositionAnchoredMorphs [

	| firstCharacterIndex lastCharacterIndex |

	firstCharacterIndex := self paragraph firstCharacterIndex.
	lastCharacterIndex := paragraph lastCharacterIndex.
	text runs withStartStopAndValueDo: [:start :stop :attributes |
		attributes do: [:att | | leftShift am cBlock |
			(att isMemberOf: TextAnchor) ifTrue: [
				am := att anchoredMorph.
				(am isNil or: [am world isNil]) ifFalse: [
					(stop between: firstCharacterIndex and: lastCharacterIndex) ifTrue: [
						cBlock := self paragraph characterBlockForIndex: stop.
						leftShift := am valueOfProperty: #geeMailLeftOffset ifAbsent: [0].
						am position: (self left + leftShift) @ cBlock origin y.
					].
				]
			]
		]
	].

]

{ #category : #menus }
TextPlusMorph >> scrollSelectionToTop [

	(self parentGeeMail ifNil: [^self])
		scrollSelectionIntoView: nil 
		alignTop: true 
		inTextMorph: self.

]

{ #category : #menus }
TextPlusMorph >> textPlusMenuFor: aMorph [

	| menu |
	menu := MenuMorph new.
	menu 
		add: 'Link to text selection' 
		target: [self addAlansAnchorFor: aMorph]
		selector: #value;

		add: 'Unlink from text selection' 
		target: [self removeAlansAnchorFor: aMorph]
		selector: #value;

		add: 'Delete' 
		target: [
			self removeAlansAnchorFor: aMorph.
			aMorph delete.
		]
		selector: #value.
	^menu

]

{ #category : #private }
TextPlusMorph >> updateFromParagraph [

	super updateFromParagraph.
	self repositionAnchoredMorphs.

]
