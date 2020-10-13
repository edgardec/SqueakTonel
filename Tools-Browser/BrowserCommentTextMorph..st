"
I am a PluggableTextMorph that knows enough to make myself invisible when necessary.
"
Class {
	#name : #BrowserCommentTextMorph,
	#superclass : #PluggableTextMorph,
	#category : #'Tools-Browser'
}

{ #category : #displaying }
BrowserCommentTextMorph >> hideOrShowPane [
	(self model editSelection == #editClass)
		ifTrue: [ self showPane ]
		ifFalse: [ self hidePane ]
]

{ #category : #displaying }
BrowserCommentTextMorph >> hidePane [
	| win |
	self window ifNotNil: [:window | window removePaneSplitters].
	
	self lowerPane ifNotNil:
		[ :lp | 
		lp layoutFrame bottomFraction: self layoutFrame bottomFraction.
		lp layoutFrame bottomOffset: SystemWindow borderWidth negated].
	win := self window ifNil: [ ^self ].
	self delete.
	win updatePanesFromSubmorphs.
	win addPaneSplitters
]

{ #category : #accessing }
BrowserCommentTextMorph >> lowerPane [
	"Answer the AlignmentMorph that I live beneath"
	^self valueOfProperty: #browserLowerPane
]

{ #category : #updating }
BrowserCommentTextMorph >> noteNewOwner: win [
	super noteNewOwner: win.
	self setProperty: #browserWindow toValue: win.
	win ifNil: [ ^self ].
	win setProperty: #browserClassCommentPane toValue: self.
	self setProperty: #browserLowerPane
		toValue: (win submorphThat: [ :m |
			m isAlignmentMorph
			and: [ m layoutFrame bottomFraction notNil
			and: [ m layoutFrame bottomFraction >= self layoutFrame topFraction ]]]
		ifNone: [])
]

{ #category : #displaying }
BrowserCommentTextMorph >> showPane [
	owner ifNil: [
		| win |
		win := self window ifNil: [ ^self ].
		win addMorph: self fullFrame: self layoutFrame.
		win updatePanesFromSubmorphs ].

	self lowerPane ifNotNil: [ :lp | lp layoutFrame bottomFraction: self layoutFrame topFraction ].
	
	self window ifNotNil: [:win | win addPaneSplitters]
]

{ #category : #updating }
BrowserCommentTextMorph >> update: anAspect [
	super update: anAspect.
	anAspect == #editSelection ifFalse: [ ^self ].
	self hideOrShowPane
]

{ #category : #accessing }
BrowserCommentTextMorph >> window [
	^self owner ifNil: [ self valueOfProperty: #browserWindow ].
]
