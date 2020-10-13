"
A morph that allows you to view, rename, and remove elements from a dictionary whose keys are strings and whose values are forms.
"
Class {
	#name : #GraphicalDictionaryMenu,
	#superclass : #GraphicalMenu,
	#instVars : [
		'baseDictionary',
		'entryNames',
		'lastSearchString'
	],
	#category : #'MorphicExtras-AdditionalWidgets'
}

{ #category : #example }
GraphicalDictionaryMenu class >> example [
	"GraphicalDictionaryMenu example"
	| aDict |
	aDict := Dictionary new.
	#('ColorTilesOff' 'ColorTilesOn' 'Controls') do:
		[:aString | aDict at: aString put: (ScriptingSystem formAtKey: aString)].
	self openOn: aDict withLabel: 'Testing One Two Three'
]

{ #category : #example }
GraphicalDictionaryMenu class >> example2 [
	"GraphicalDictionaryMenu example2"
	| aDict |
	aDict := Dictionary new.
	self openOn: aDict withLabel: 'Testing Zero'
]

{ #category : #'instance creation' }
GraphicalDictionaryMenu class >> openOn: aFormDictionary withLabel: aLabel [
	"open a graphical dictionary in a window having the label aLabel. 
     aFormDictionary should be a dictionary containing as value a form."

	| inst aWindow |
	aFormDictionary size isZero ifTrue: [^ self inform: 'Empty!' translated].	
	inst := self new initializeFor: nil fromDictionary: aFormDictionary.

	aWindow := (SystemWindow labelled: aLabel) model: inst.
	aWindow addMorph: inst frame: (0@0 extent: 1@1).
	aWindow extent: inst fullBounds extent + (3 @ aWindow labelHeight + 3);
		minimumExtent: inst minimumExtent + (3 @ aWindow labelHeight + 3).
	
     HandMorph attach: aWindow.

	^ inst
]

{ #category : #initialization }
GraphicalDictionaryMenu >> baseDictionary: aDictionary [
	baseDictionary := aDictionary.
	entryNames := aDictionary keys asArray sort.
	formChoices := entryNames collect: [:n | aDictionary at: n].
	currentIndex := 1
]

{ #category : #'menu commands' }
GraphicalDictionaryMenu >> browseIconReferences [
	"Browse all calls on the symbol by which the currently-seen graphic is keyed"

	self systemNavigation browseAllCallsOn: self nameOfGraphic
]

{ #category : #'menu commands' }
GraphicalDictionaryMenu >> browseStringIconReferences [
	"Browse string references to the selected entry's key"

	self systemNavigation browseMethodsWithString: self nameOfGraphic asString matchCase: true
]

{ #category : #'menu commands' }
GraphicalDictionaryMenu >> copyName [
	"Copy the name of the current selection to the clipboard"

	Clipboard clipboardText: self nameOfGraphic asText
]

{ #category : #'menu commands' }
GraphicalDictionaryMenu >> encodeToWorkspace [
	| stream encodedStream pict text |
	pict := formChoices at: currentIndex.
	stream := ByteArray new writeStream.
	PNGReadWriter putForm: pict onStream: stream.
	encodedStream := stream contents base64Encoded.
	text := Workspace open model.
	text contents: 'Form fromBinaryStream: (Base64MimeConverter mimeDecodeToBytes: ''', encodedStream,''' readStream)'
]

{ #category : #'menu commands' }
GraphicalDictionaryMenu >> findAgain [
	"Look for the next occurrence of the search string"

	| toFind searchIndex |
	lastSearchString ifNil: [lastSearchString := 'controls'].
	searchIndex := currentIndex + 1.
	searchIndex > entryNames size ifTrue:
		[currentIndex := 0.
		self inform: 'not found' translated.
		^ self].
	toFind := '*', lastSearchString, '*'.
	[toFind match: (entryNames at: searchIndex) asString]
		whileFalse:
			[searchIndex := (searchIndex \\ entryNames size) + 1.
			searchIndex == currentIndex ifTrue:
				[^ (toFind match: (entryNames at: searchIndex) asString)
					ifFalse:
						[self inform: 'not found' translated]
					ifTrue:
						[self flash]]].

	currentIndex := searchIndex.
	self updateThumbnail
]

{ #category : #'menu commands' }
GraphicalDictionaryMenu >> findEntry [
	"Prompt the user for a search string and find the next match for it"

	| toFind searchIndex |
	lastSearchString ifNil: [lastSearchString := 'controls'].
	toFind := UIManager default request: 'Type name or fragment: ' initialAnswer: lastSearchString.
	toFind isEmptyOrNil ifTrue: [^ self].
	lastSearchString := toFind asLowercase.
	searchIndex := currentIndex + 1.
	toFind := '*', lastSearchString, '*'.
	[toFind match: (entryNames at: searchIndex) asString]
		whileFalse:
			[searchIndex := (searchIndex \\ entryNames size) + 1.
			searchIndex == currentIndex ifTrue: [^ self inform: 'not found']].

	currentIndex := searchIndex.
	self updateThumbnail
]

{ #category : #'menu commands' }
GraphicalDictionaryMenu >> handMeOne [
	self currentHand attachMorph: (self world drawingClass new form: (formChoices at: currentIndex))
]

{ #category : #initialization }
GraphicalDictionaryMenu >> initializeFor: aTarget fromDictionary: aDictionary [ 
	"Initialize me for a target and a dictionary."

	| anIndex aButton |
	self baseDictionary: aDictionary.
	target := aTarget.
	coexistWithOriginal := true.
	self extent: 210 @ 210.
	self clipSubmorphs: true.
	self layoutPolicy: ProportionalLayout new.
	aButton := (IconicButton new)
				borderWidth: 0;
				labelGraphic: (ScriptingSystem formAtKey: 'TinyMenu');
				color: Color transparent;
				actWhen: #buttonDown;
				actionSelector: #showMenu;
				target: self;
				setBalloonText: 'menu'.
	self addMorph: aButton
		fullFrame: (LayoutFrame fractions: (0.5 @ 0 extent: 0 @ 0)
				offsets: (-50 @ 6 extent: aButton extent)).
	aButton := (SimpleButtonMorph new)
				target: self;
				borderColor: Color black;
				label: 'Prev';
				actionSelector: #downArrowHit;
				actWhen: #whilePressed;
				setBalloonText: 'show previous picture';
				yourself.
	self addMorph: aButton
		fullFrame: (LayoutFrame fractions: (0.5 @ 0 extent: 0 @ 0)
				offsets: (-24 @ 4 extent: aButton extent)).
	aButton := (SimpleButtonMorph new)
				target: self;
				borderColor: Color black;
				label: 'Next';
				actionSelector: #upArrowHit;
				actWhen: #whilePressed;
				setBalloonText: 'show next pictutre'.
	self addMorph: aButton
		fullFrame: (LayoutFrame fractions: (0.5 @ 0 extent: 0 @ 0)
				offsets: (24 @ 4 extent: aButton extent)).
	self addMorph: ((UpdatingStringMorph new)
				contents: ' ';
				target: self;
				putSelector: #renameGraphicTo:;
				getSelector: #truncatedNameOfGraphic;
				useStringFormat;
				setBalloonText: 'The name of the current graphic';
				yourself)
		fullFrame: (LayoutFrame fractions: (0 @ 0 extent: 1 @ 0)
				offsets: (10 @ 40 corner: -10 @ 60)).
	self addMorph: ((Morph new)
				extent: 100 @ 4;
				color: Color black)
		fullFrame: (LayoutFrame fractions: (0 @ 0 extent: 1 @ 0)
				offsets: (0 @ 60 corner: 0 @ 64)).
	formDisplayMorph := (Thumbnail new)
				extent: 100 @ 100;
				useInterpolation: true;
				maxWidth: 3000 minHeight: 100;
				yourself.
	formDisplayMorph layoutFrame: 
		(LayoutFrame fractions: (0 @ 0 extent: 0@0)
				offsets: (8 @ 72 corner:  108 @ 172)).				
	self addMorph: formDisplayMorph.
	self minimumExtent: 116@180.
	target ifNotNil: 
			[(anIndex := formChoices indexOf: target form ifAbsent: []) 
				ifNotNil: [currentIndex := anIndex]].
	self updateThumbnail
]

{ #category : #private }
GraphicalDictionaryMenu >> nameOfGraphic [
	^ entryNames at: currentIndex
]

{ #category : #'menu commands' }
GraphicalDictionaryMenu >> removeEntry [
	baseDictionary removeKey: (entryNames at: currentIndex).
	self baseDictionary: baseDictionary.
	self updateThumbnail
]

{ #category : #'menu commands' }
GraphicalDictionaryMenu >> renameEntry [
	| reply curr |
	reply := UIManager default
		request: 'New key? '
		initialAnswer: (curr := entryNames at: currentIndex).
	(reply isEmptyOrNil or: [reply = curr]) ifTrue: [^ Beeper beep].
	(baseDictionary includesKey: reply) ifTrue:
		[^ self inform: 'sorry that conflicts with
the name of another
entry in this dictionary'].
	baseDictionary at: reply put: (baseDictionary at: curr).
	baseDictionary removeKey: curr.
	self baseDictionary: baseDictionary.
	self updateThumbnail
]

{ #category : #'menu commands' }
GraphicalDictionaryMenu >> renameGraphicTo: newName [
	| curr |
	curr := entryNames at: currentIndex.
	(newName isEmptyOrNil or: [newName = curr]) ifTrue: [^ Beeper beep].
	(baseDictionary includesKey: newName) ifTrue:
		[^ self inform: 'sorry that conflicts with
the name of another
entry in this dictionary' translated].
	baseDictionary at: newName put: (baseDictionary at: curr).
	baseDictionary removeKey: curr.
	self baseDictionary: baseDictionary.
	currentIndex := entryNames indexOf: newName.
	self updateThumbnail
]

{ #category : #'menu commands' }
GraphicalDictionaryMenu >> repaintEntry [
	"Let the user enter into painting mode to repaint the item and save it back."

	| aWorld bnds sketchEditor aPaintBox formToEdit |
	
	(aWorld := self world) assureNotPaintingElse: [^ self].

	aWorld prepareToPaint.
	aWorld displayWorld.
	formToEdit := formChoices at: currentIndex.
	bnds := (submorphs second boundsInWorld origin extent: formToEdit extent) intersect: aWorld bounds.
	bnds := (aWorld paintingBoundsAround: bnds center) merge: bnds.
	sketchEditor := SketchEditorMorph new.
	aWorld addMorphFront: sketchEditor.
	sketchEditor initializeFor: ((aWorld drawingClass withForm: formToEdit) position: submorphs second positionInWorld)  inBounds: bnds pasteUpMorph: aWorld paintBoxPosition: bnds topRight.
	sketchEditor
		afterNewPicDo: [:aForm :aRect |
			formChoices at: currentIndex put: aForm.
			baseDictionary at: (entryNames at: currentIndex) put: aForm.
			self updateThumbnail.
			(aPaintBox := aWorld paintBoxOrNil) ifNotNil: [aPaintBox delete]] 
		ifNoBits:
			[(aPaintBox := aWorld paintBoxOrNil) ifNotNil: [aPaintBox delete]].
	

]

{ #category : #'menu commands' }
GraphicalDictionaryMenu >> showMenu [
	"Show the receiver's menu"

	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu title: 'Graphics Library'.
	aMenu addStayUpItem.
	aMenu addList: #(
		('remove'			removeEntry			'Remove this entry from the dictionary')
		('rename'			renameEntry			'Rename this entry')
		('repaint'			repaintEntry			'Edit the actual graphic for this entry' )
		-
		('hand me one'		handMeOne				'Hand me a morph with this picture as its form')
		('encode to Workspace'	encodeToWorkspace		'Open a Workspace with the grapics encoded to be added to code')
		('browse symbol references'
							browseIconReferences	'Browse methods that refer to this icon''s name')
		('browse string references'
							browseStringIconReferences 'Browse methods that refer to string constants that contain this icon''s name')
		('copy name'		copyName				'Copy the name of this graphic to the clipboard')
		-
		('find...'			findEntry				'Find an entry by name')
		('find again'		findAgain				'Find the next match for the keyword previously searched for')).
	aMenu popUpInWorld

]

{ #category : #'menu commands' }
GraphicalDictionaryMenu >> truncatedNameOfGraphic [
	^ self nameOfGraphic truncateTo: 30
]

{ #category : #private }
GraphicalDictionaryMenu >> updateThumbnail [
	super updateThumbnail.
	(self findA: UpdatingStringMorph)
		doneWithEdits;
		contents: (entryNames at: currentIndex)

]
