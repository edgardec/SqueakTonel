Class {
	#name : #MCTool,
	#superclass : #Model,
	#instVars : [
		'morph',
		'label',
		'modalProcess',
		'modalValue'
	],
	#category : #'Monticello-UI'
}

{ #category : #'morphic ui' }
MCTool >> answer: anObject [
	(modalProcess notNil and: [modalProcess ~~ Processor activeProcess])
		ifTrue: [^self inform: 'This modal dialog was interrupted, please close it'].
	modalValue := anObject.
	self close.
]

{ #category : #toolbuilder }
MCTool >> buildWindow [
	^ ToolBuilder build: self
]

{ #category : #toolbuilder }
MCTool >> buildWith: builder [
	|  windowBuilder |

	windowBuilder := MCToolWindowBuilder builder: builder tool: self.
	self widgetSpecs do:
		[:spec | | send fractions offsets |
		send := spec first.
		fractions := (spec at: 2 ifAbsent: [#(0 0 1 1)]) copy.
		offsets := (spec at: 3 ifAbsent: [#(0 0 0 0)]) copy.
		
		fractions withIndexDo: [:numberOrSymbol :index |
			numberOrSymbol isSymbol
				ifTrue: [fractions at: index put: (self perform: numberOrSymbol)]].
		offsets withIndexDo: [:numberOrSymbol :index |
			numberOrSymbol isSymbol
				ifTrue: [offsets at: index put: (self perform: numberOrSymbol)]].
					
		windowBuilder frame: (LayoutFrame
			fractions: (fractions first @ fractions second corner: fractions third @ fractions fourth)
			offsets: (offsets first @ offsets second corner: offsets third @ offsets fourth)).
		windowBuilder perform: send first withArguments: send allButFirst].

	^ windowBuilder build

]

{ #category : #'morphic ui' }
MCTool >> buttonEnabled [
	^ true
]

{ #category : #'morphic ui' }
MCTool >> buttonSelected [
	^ false
]

{ #category : #'morphic ui' }
MCTool >> buttonSpecs [
	^ #()
]

{ #category : #'morphic ui' }
MCTool >> buttonState [
	^ true
]

{ #category : #'morphic ui' }
MCTool >> close [
	self window delete
]

{ #category : #'morphic ui' }
MCTool >> defaultAnnotationPaneHeight [ 
	"Answer the receiver's preferred default height for new annotation panes.
	Since MC compares two annotations, reserve a bit less than a double the traditional height."
	
	^ Preferences standardDefaultTextFont height * 3
]

{ #category : #'morphic ui' }
MCTool >> defaultButtonPaneHeight [
	"Answer the user's preferred default height for new button panes."

	^ (Preferences standardButtonFont height * 2.5) rounded
]

{ #category : #'morphic ui' }
MCTool >> defaultExtent [
	^ 500@500
]

{ #category : #'morphic ui' }
MCTool >> defaultInputFieldHeight [

	^ Preferences standardDefaultTextFont height * 2
]

{ #category : #'morphic ui' }
MCTool >> defaultLabel [
	^ self class name
]

{ #category : #'user interface' }
MCTool >> defaultWindowColor [
	^ (Color r: 0.65 g: 0.691 b: 0.876)
]

{ #category : #'morphic ui' }
MCTool >> fillMenu: aMenu fromSpecs: anArray [
	anArray do:
		[:spec |
		spec == #addLine
			ifTrue: [aMenu addLine]
			ifFalse:
				[aMenu
					add: spec first
					target: self
					selector: spec second
					argumentList: (spec allButFirst: 2)]].
	^aMenu
]

{ #category : #'morphic ui' }
MCTool >> findListMorph: aSymbol [
	^ morph submorphs detect: [:ea | (ea respondsTo: #getListSelector) and: [ea getListSelector = aSymbol]] ifNone: []
]

{ #category : #'morphic ui' }
MCTool >> findTextMorph: aSymbol [
	^ morph submorphs detect: [:ea | (ea respondsTo: #getTextSelector) and: [ea getTextSelector = aSymbol]] ifNone: []
]

{ #category : #'morphic ui' }
MCTool >> getMenu: aMenu [
	^aMenu
]

{ #category : #'morphic ui' }
MCTool >> label [
	^ label ifNil: [self defaultLabel]
]

{ #category : #'morphic ui' }
MCTool >> label: aString [
	label := aString
]

{ #category : #'morphic ui' }
MCTool >> perform: selector orSendTo: otherTarget [
	"Selector was just chosen from a menu by a user.  If can respond, then
perform it on myself. If not, send it to otherTarget, presumably the
editPane from which the menu was invoked."

	(self respondsTo: selector)
		ifTrue: [^ self perform: selector]
		ifFalse: [^ otherTarget perform: selector]
]

{ #category : #'morphic ui' }
MCTool >> performButtonAction: anActionSelector enabled: anEnabledSelector [
	(self perform: anEnabledSelector) 
		ifTrue: [ self perform: anActionSelector ]
]

{ #category : #'morphic ui' }
MCTool >> refresh [
	"Do nothing by default."
]

{ #category : #'morphic ui' }
MCTool >> show [
	modalProcess := nil.
	Smalltalk at: #ToolBuilder ifPresent: [:tb | tb open: self. ^ self].
	^self window openInWorldExtent: self defaultExtent; yourself
]

{ #category : #'morphic ui' }
MCTool >> showLabelled: labelString [
	modalProcess := nil.
	self label: labelString.
	^(self window)
		openInWorldExtent: self defaultExtent;
		yourself
]

{ #category : #'morphic ui' }
MCTool >> showModally [
	modalProcess := Processor activeProcess.
	self window openInWorldExtent: self defaultExtent.
	ToolBuilder default runModal: self window.
	morph := nil.
	^ modalValue
]

{ #category : #'morphic ui' }
MCTool >> widgetSpecs [
	^ #()
]

{ #category : #'morphic ui' }
MCTool >> window [
	^ morph ifNil: [morph := self buildWindow]
]
