Class {
	#name : #EtoyLoginMorph,
	#superclass : #AlignmentMorphBob1,
	#instVars : [
		'theName',
		'theNameMorph',
		'actionBlock',
		'cancelBlock'
	],
	#category : #'Etoys-Experimental'
}

{ #category : #'instance creation' }
EtoyLoginMorph class >> loginAndDo: aBlock ifCanceled: cancelBlock [
	"EtoyLoginMorph loginAndDo:[:n| true] ifCanceled:[]"
	| me |
	(me := self new)
		name: 'your name' actionBlock: aBlock cancelBlock: cancelBlock;
		fullBounds;
		position: Display extent - me extent // 2;
		openInWorld.
	me position: me position + (0@40).
]

{ #category : #building }
EtoyLoginMorph >> buttonColor [
	^ Color paleYellow darker
]

{ #category : #building }
EtoyLoginMorph >> buttonNamed: aString action: aSymbol color: aColor help: helpString [

	| f col |
	f := SimpleButtonMorph new
		target: self;
		label: aString font: self myFont;
		color: aColor;
		borderColor: aColor muchDarker;
		actionSelector: aSymbol;
		setBalloonText: helpString.
	col := (self inAColumn: {f}) hResizing: #spaceFill.
	^col
]

{ #category : #building }
EtoyLoginMorph >> cancelButton [
	^ self
		buttonNamed: 'Cancel'
		action: #doCancel
		color: Color lightRed
		help: 'Cancel this login operation.'
]

{ #category : #initialization }
EtoyLoginMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ Color paleYellow darker
]

{ #category : #initialization }
EtoyLoginMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 8
]

{ #category : #initialization }
EtoyLoginMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	| result |
	result := GradientFillStyle ramp: {0.0
					-> (Color
							r: 0.5
							g: 0.5
							b: 1.0). 1.0
					-> (Color
							r: 0.8
							g: 0.8
							b: 1.0)}.
	result origin: self bounds origin.
	result direction: 0 @ self bounds height.
	^ result
]

{ #category : #actions }
EtoyLoginMorph >> doCancel [

	self delete.
	cancelBlock ifNotNil:[cancelBlock value].
]

{ #category : #actions }
EtoyLoginMorph >> doOK [

	| proposed |

	proposed := theNameMorph contents string.
	proposed isEmpty ifTrue: [^self inform: 'Please enter your login name' translated].
	proposed size > 24 ifTrue: [^self inform: 'Please make the name 24 characters or less' translated].
	(Project isBadNameForStoring: proposed) ifTrue: [
		^self inform: 'Please remove any funny characters' translated
	].
	(actionBlock value: proposed) ifTrue:[self delete].
]

{ #category : #initialization }
EtoyLoginMorph >> initialize [
	"initialize the state of the receiver"
	
	super initialize.
	""
	self vResizing: #shrinkWrap;
		 hResizing: #shrinkWrap;
		 layoutInset: 4;
		 beSticky;
		 useRoundedCorners;
		 rebuild.
	
]

{ #category : #building }
EtoyLoginMorph >> myFont [

	^ Preferences standardEToysFont
]

{ #category : #initialize }
EtoyLoginMorph >> name: aString actionBlock: aBlock cancelBlock: altBlock [

	theName := aString.
	actionBlock := aBlock.
	cancelBlock := altBlock.
	theNameMorph contentsWrapped: theName.
	theNameMorph editor selectAll.
]

{ #category : #building }
EtoyLoginMorph >> okButton [
	^ self
		buttonNamed: 'OK'
		action: #doOK
		color: Color lightGreen
		help: 'Login into Squeak'
]

{ #category : #initialization }
EtoyLoginMorph >> openInWorld: aWorld [
	super openInWorld: aWorld.
	aWorld primaryHand newKeyboardFocus: theNameMorph.
]

{ #category : #initialize }
EtoyLoginMorph >> rebuild [

	self removeAllMorphs.
	self addARow: { (StringMorph contents:'') lock }.
	self addARow: {
		(StringMorph contents: 'Please enter your Squeak login name' font: self myFont) lock.
	}.
	(self addARow: {
		(theNameMorph := TextMorph new
			beAllFont: self myFont;
			crAction: (MessageSend receiver: self selector: #doOK);
			extent: 300@20;
			contentsWrapped: 'the old name';
			setBalloonText: 'Enter your name and avoid the following characters:

 : < > | / \ ? * "'

			).
	}) color: Color white; borderColor: Color black; borderWidth: 1.
	self addARow: {
		self okButton.
		self cancelButton.
	}.
	self addARow: { (StringMorph contents:'') lock }.

]
