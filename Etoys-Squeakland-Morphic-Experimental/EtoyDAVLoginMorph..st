Class {
	#name : #EtoyDAVLoginMorph,
	#superclass : #AlignmentMorphBob1,
	#instVars : [
		'theName',
		'theNameMorph',
		'thePassword',
		'thePasswordMorph',
		'actionBlock',
		'cancelBlock',
		'panel'
	],
	#category : #'Etoys-Squeakland-Morphic-Experimental'
}

{ #category : #'instance creation' }
EtoyDAVLoginMorph class >> loginAndDo: aBlock ifCanceled: cancelBlock [
	"EtoyDAVLoginMorph loginAndDo:[:n :p | true] ifCanceled:[]"
	| |
	self new loginAndDo: aBlock ifCanceled: cancelBlock.

]

{ #category : #private }
EtoyDAVLoginMorph >> buildPanel [

	| title |
	self deletePanel.
	panel := AlignmentMorphBob1 new.
	panel vResizing: #shrinkWrap;
		 hResizing: #shrinkWrap;
		 layoutInset: 4;
		color: self defaultColor;
		 beSticky;
		borderWidth: self defaultBorderWidth;
		borderColor:  self defaultBorderColor.
	title := TextMorph new contents: 'Etoys is trying to open your web browser.\If it does not work, you can sign up at:\\' translated withCRs, self url; beAllFont: self myFont.
	title beSticky.
	title centered.
	panel addARow: {title}.
	panel addARow: { (StringMorph contents:'') lock }.

	panel addARow: {
		self newSpacer: Color transparent.
		self okButton2 hResizing: #rigid.
		self newSpacer: Color transparent.
	}.
	panel setProperty: #morphicLayerNumber toValue: 9.
	^ panel.


]

{ #category : #building }
EtoyDAVLoginMorph >> buttonColor [
	^ self defaultColor
]

{ #category : #building }
EtoyDAVLoginMorph >> buttonNamed: aString action: aSymbol color: aColor help: helpString [

	| f col |
	f := SimpleButtonMorph new
		target: self;
		label: aString font: self myFont;
		color: aColor;
		actionSelector: aSymbol;
		setBalloonText: helpString.
	col := (self inAColumn: {f}) hResizing: #spaceFill.
	^col
]

{ #category : #building }
EtoyDAVLoginMorph >> cancelButton [

	^self
		buttonNamed: 'Cancel' translated
		action: #doCancel 
		color: self buttonColor 
		help: 'Cancel this login operation.' translated
]

{ #category : #initialization }
EtoyDAVLoginMorph >> defaultBorderColor [
	"answer the default border color/fill style for the receiver"
	^ Color fromString: '#ECE8CC'
]

{ #category : #initialization }
EtoyDAVLoginMorph >> defaultBorderWidth [
	"answer the default border width for the receiver"
	^ 8
]

{ #category : #initialization }
EtoyDAVLoginMorph >> defaultColor [

	^ (Color fromString: '#ECE8CC') muchLighter
]

{ #category : #initialize }
EtoyDAVLoginMorph >> delete [

	self deletePanel.
	super delete.

]

{ #category : #private }
EtoyDAVLoginMorph >> deletePanel [

	panel ifNotNil: [panel delete. panel := nil].
]

{ #category : #actions }
EtoyDAVLoginMorph >> doCancel [

	self delete.
	cancelBlock ifNotNil:[cancelBlock value].
]

{ #category : #actions }
EtoyDAVLoginMorph >> doOK [

	| proposed proposedPass |

	proposed := theNameMorph contents string.
	proposed isEmpty ifTrue: [^self inform: 'Please enter your login name' translated].
	proposed size > 24 ifTrue: [^self inform: 'Please make the name 24 characters or less' translated].
	(Project isBadNameForStoring: proposed) ifTrue: [
		^self inform: 'Please remove any funny characters' translated
	].
	proposedPass := thePasswordMorph contents string.
	(actionBlock value: proposed value: proposedPass) ifTrue:[self delete].
]

{ #category : #initialization }
EtoyDAVLoginMorph >> initialize [
	"initialize the state of the receiver"
	
	super initialize.
	""
	self vResizing: #shrinkWrap;
		 hResizing: #shrinkWrap;
		 layoutInset: 4;
		 beSticky;
		 rebuild.
	self setProperty: #morphicLayerNumber toValue: 10.
]

{ #category : #actions }
EtoyDAVLoginMorph >> launchBrowser [

	self currentWorld addMorph: self buildPanel centeredNear: Sensor cursorPoint.
	(Smalltalk classNamed: #ScratchPlugin) ifNotNil: [:sp | sp primOpenURL: self url].
]

{ #category : #private }
EtoyDAVLoginMorph >> loginAndDo: aBlock ifCanceled: cb [
	"EtoyDAVLoginMorph loginAndDo:[:n :p | true] ifCanceled:[]"
	self name: '' actionBlock: aBlock cancelBlock: cb;
		fullBounds;
		position: Display extent - self extent // 2.
	self position: self position + (0@40).
	self currentWorld addMorphInLayer: self.
]

{ #category : #building }
EtoyDAVLoginMorph >> myFont [

	^ Preferences standardEToysFont
]

{ #category : #initialize }
EtoyDAVLoginMorph >> name: aString actionBlock: aBlock cancelBlock: altBlock [

	theName := aString.
	actionBlock := aBlock.
	cancelBlock := altBlock.
	theNameMorph contentsWrapped: theName.
	theNameMorph editor selectAll.
]

{ #category : #private }
EtoyDAVLoginMorph >> newSpacer: aColor [
	"Answer a space-filling instance of me of the given color."

	^ AlignmentMorph newSpacer: aColor

]

{ #category : #building }
EtoyDAVLoginMorph >> okButton [

	^self
		buttonNamed: 'OK' translated
		action: #doOK 
		color: self buttonColor 
		help: 'Login to Squeakland' translated
]

{ #category : #building }
EtoyDAVLoginMorph >> okButton2 [

	^self
		buttonNamed: 'OK'  translated
		action: #deletePanel 
		color: self buttonColor 
		help: 'Close this dialog' translated
]

{ #category : #initialization }
EtoyDAVLoginMorph >> openInWorld: aWorld [
	super openInWorld: aWorld.
	aWorld primaryHand newKeyboardFocus: theNameMorph.
]

{ #category : #initialize }
EtoyDAVLoginMorph >> rebuild [

	| title link |
	self removeAllMorphs.
	title := StringMorph contents: 'Login to Squeakland' translated font: self myFont.
	title lock.
	link :=  StringMorph contents: '(create account)' translated font: Preferences standardListFont emphasis: 4.
	link color: Color blue.
	link beSticky.
	link on: #click send: #launchBrowser to: self.
	self addARow: { title. self newSpacer: Color transparent. link}.
	self addARow: { (StringMorph contents:'') lock }.
	(self addARow: {
		(StringMorph contents: 'Username:' translated font: self myFont) lock.
		Morph new extent: 15@0; color: Color transparent.
		self newSpacer: Color transparent.
		(theNameMorph := TextMorph new
			beAllFont: self myFont;
			crAction: (MessageSend receiver: self selector: #doOK);
			extent: 250@20;
			borderStyle: (InsetBorder new color: Color black; width: 2);
			contentsWrapped: 'the old name'
			).
	}) color: self defaultColor; borderWidth: 0.

	self addARow: { (StringMorph contents:'') lock }.

	(self addARow: {
		(StringMorph contents: 'Password:' translated font: self myFont) lock.
		Morph new extent: 15@0; color: Color transparent.
		self newSpacer: Color transparent.
		(thePasswordMorph := TextMorph new
			beAllFont: (FixedFaceFont new passwordFont baseFont: self myFont copy);
			crAction: (MessageSend receiver: self selector: #doOK);
			extent: 250@20;
			borderStyle: (InsetBorder new color: Color black; width: 2);
			contentsWrapped: ''
			).
	}) color: self defaultColor.

	self addARow: { (StringMorph contents:'') lock }.

	self addARow: {
		self newSpacer: Color transparent.
		self okButton hResizing: #rigid.
		Morph new extent: 30@0; color: Color transparent.
		self cancelButton hResizing: #rigid.
	}.

]

{ #category : #private }
EtoyDAVLoginMorph >> url [

	^ 'http://squeakland.org/action/signup'.
]
