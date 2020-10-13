"
A tool for browsing and managing the sound library.
Offers a self-updating, scrolling list of all the sounds in the library.  
Has a row of buttons to initiate various functions on the selected sound; the buttons are:
	Play	Play the selected sound
	Stop		Stop playing selected sound (if it is playing)
	Tile		Hand the user a tile for the selected sound.
	Rename	Rename the selected sound.
	Delete	Delete the selected sound from the ibrary
	Load	Load a sound into the sound library from a file.

Additionally, a wave-editor can be invoked via an item in the tool's halo menu.

The Sound Library tool can be launched from the Objects catalog, and also from the authoring-tools menu
"
Class {
	#name : #SoundLibraryTool,
	#superclass : #AlignmentMorph,
	#instVars : [
		'listBox',
		'button',
		'soundIndex',
		'currentSound',
		'showCompression'
	],
	#category : #'Etoys-Squeakland-Sound-Interface'
}

{ #category : #'parts bin' }
SoundLibraryTool class >> descriptionForPartsBin [
	"Answer a description of the receiver for use in a parts bin"

	^ self partName:	'Sound Library' translatedNoop
		categories:		{'Multimedia' translatedNoop}
		documentation:	'A tool for managing the sound library' translatedNoop
]

{ #category : #initialization }
SoundLibraryTool >> addButtonRow [
	"Add the row of control buttons."

	| row aButton |
	row := AlignmentMorph newRow vResizing: #shrinkWrap;
				 color: Color transparent.

	#(('Play' play 'Play the selected sound')
		('Stop' pause 'If the selected sound is playing, stop it')
		('Tile' handMeATile 'Hands you a tile representing the selected sound')
		('Rename' renameSound 'Rename the selected sound')
		('Delete' deleteSound 'Delete the selected sound from the sound library')
		('Load' loadSoundFromDisk 'Add a new sound to the sound library from a file')) 
			translatedNoop do:

		[:triplet |
			 row addVariableTransparentSpacer.
			aButton := SimpleButtonMorph new label: triplet first translated font: ScriptingSystem fontForEToyButtons;
				 target: self;
				 actionSelector: triplet second.
			aButton setBalloonText: triplet third translated.
			row addMorphBack: aButton].

	row addVariableTransparentSpacer.
	self addMorphBack: row
]

{ #category : #menu }
SoundLibraryTool >> addCustomMenuItems: aMenu hand: aHand [
	"Add custom menu items to a menu"

	super addCustomMenuItems: aMenu hand: aHand.
	aMenu addUpdating: #showCompressionString target: self action: #toggleShowCompression.
	aMenu add: 'GSM compress sound' translated target: self selector: #compressWith: argument: GSMCodec.
	aMenu add: 'Ogg Vorbis compress sound' translated target: self selector: #compressWith: argument:  OggVorbisCodec.
	aMenu add: 'Ogg Speex compress sound' translated target: self selector: #compressWith: argument:  OggSpeexCodec.
	aMenu addTranslatedList: #(
		('Wave editor' edit 'open a tool which, operating with the selected sound as a point of departure, will allow you to construct a new "instrument"')
	) translatedNoop

]

{ #category : #initialization }
SoundLibraryTool >> addHeaderRow [
	"Add the first row of the tool, containing dismiss and help icons and the interim name of the sound."

	| aMorph |
	aMorph := AlignmentMorph newRow.
	aMorph hResizing: #spaceFill.
	aMorph addMorphBack: self dismissButton.
	aMorph addVariableTransparentSpacer.
	aMorph addMorphBack: (StringMorph contents: 'Sound Library' translated font: ScriptingSystem fontForEToyButtons).
	aMorph addVariableTransparentSpacer.
	aMorph  addMorphBack: self helpButton.
	self addMorphBack: aMorph
]

{ #category : #initialization }
SoundLibraryTool >> addSoundList [
	"Add the sounds list to the tool."
	
	listBox := PluggableMultiColumnListMorph
				on: self
				list: #listing
				selected: #soundIndex
				changeSelected: #soundIndex:.
	listBox hResizing: #spaceFill.
	
	listBox hideMenuButton.
	listBox height: 240.
	listBox font: Preferences standardEToysFont.
	self  addMorphBack: listBox
]

{ #category : #menu }
SoundLibraryTool >> compressWith: aCodec [ 
	"Compress the sound."
	| newSound name writer |
	soundIndex = 0
		ifTrue: [^ self inform: 'No sound selected' translated].
	
	(SampledSound universalSoundKeys includes: self soundName)
		ifTrue: [^ self inform: 'You can not compress this sound' translated].
	newSound := currentSound compressWith: aCodec.
	writer := ByteArray new writeStream.
	newSound channels
		do: [:channel | writer nextPutAll: channel].
	name := self soundName.
	SampledSound removeSoundNamed: self soundName.
	SampledSound
		addLibrarySoundNamed: name
		bytes: writer contents
		codecSignature: newSound codecSignature.
	currentSound := SampledSound soundNamed: name.
	self update
]

{ #category : #menu }
SoundLibraryTool >> deleteSound [
	"Delete the selected sound, if appropriate."

	 
	soundIndex = 0
		ifTrue: [^ self inform: 'No sound selected' translated].
	currentSound pause.
	(SampledSound universalSoundKeys includes: self soundName)
		ifTrue: [^self inform: 'You can not delete this sound' translated]
		ifFalse: [ScriptingSystem removeFromSoundLibrary: self soundName].
	self soundIndex: 0.
	self update
]

{ #category : #menu }
SoundLibraryTool >> edit [
	"Open a WaveEditor on my samples."
	"Use the new ScratchSoundEditor if we can"
	soundIndex > 0
		ifTrue: [
			Smalltalk globals at: #ScratchSoundEditor
				ifPresent: [:c |  (c new sound: currentSound) openInWorld]
				ifAbsent: [WaveEditor openOn: currentSound samples]].

]

{ #category : #menu }
SoundLibraryTool >> handMeATile [ 
	| tile |
	soundIndex = 0 ifTrue:[^nil].
	tile := SoundTile new literal: self soundName.
		tile bounds: tile fullBounds.
		tile openInHand
]

{ #category : #accessing }
SoundLibraryTool >> handlesMouseOver: evt [
	"Do I want to receive mouseEnter: and mouseLeave: when the button is up and the hand is empty?  The default response is false, except if you have added sensitivity to mouseEnter: or mouseLeave:, using the on:send:to: mechanism."

	^ true
]

{ #category : #initialization }
SoundLibraryTool >> helpString [
	"Answer help content."

	^ 'This tool allows you to view and manage the "Sound Library", which is the list of named sounds that can be used in the tile-scripting system.

Click on a sound name in the list to select it.  The buttons at the top of the tool apply to the sound you have selected.

Play button -- press this to start playing the selected sound.

Stop button -- if the selected sound is playing, pressing this will stop it.

Tile button -- Click on this to obtain a scripting tile representing the selected sound.

Rename button -- allows you to rename the selected sound.

Delete button -- allows you to delete the selected sound from the Sound Library.  All tiles that formerly pointed to this sound will be changed to point to "croak" instead.

Load button -- allows you to load a sound into the Sound Library from a file.

You can also add sounds to the Sound library using the Sound Recorder, and also by dragging an external sound file (e.g. a file with extensions .wav or .aif)  into etoys.

Note: the "universal" sounds built in to the system cannot be renamed or deleted.

Additionally, a command for opening a "wave editor" tool on the selected sound can be found in the tool''s halo menu.'

	translated
]

{ #category : #initialization }
SoundLibraryTool >> initialize [
	"initialize the state of the receiver"

	super initialize.
	showCompression := false.
	self hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap.
	self cellPositioning: #topLeft.
	self listDirection: #topToBottom.
	self borderWidth: 2;
		 borderColor: Color black.
	self addHeaderRow.

	self addButtonRow.
	soundIndex := 1.
	self addSoundList.
	self soundIndex: 1.
	self on: #mouseEnter send: #verifyContents to: listBox
]

{ #category : #initialization }
SoundLibraryTool >> listing [
	| list newList format soundData selectorList formatList |
	list := SampledSound soundLibrary keys sort.
	selectorList := OrderedCollection new.
	formatList := OrderedCollection new.
	list
		do: [:each | 
			soundData := (SampledSound soundLibrary at: each) second.
			soundData isNumber
				ifTrue: [format := 'uncompressed']
				ifFalse: [(soundData includesSubString: 'Vorbis')
						ifTrue: [format := 'Vorbis']
						ifFalse: [(soundData includesSubString: 'Speex')
								ifTrue: [format := 'Speex']
								ifFalse: [(soundData includesSubstring: 'GSM')
										ifTrue: [format := 'GSM']]]].
			selectorList add: each.
			formatList add:  format].
	 newList := OrderedCollection new.
	newList add: selectorList asArray.
	showCompression
		ifTrue:[newList add: formatList asArray]
		ifFalse:[newList add:  (Array new: (formatList size) withAll:' ')].
	^newList
]

{ #category : #menu }
SoundLibraryTool >> loadSoundFromDisk [
	"Put up a file chooser dialog inviting the user to import a sound file; accept it"

	| aSound aName aFileStream fullName ext reply |
	fullName := UIManager default chooseFileMatchingSuffixes: #(#AIFF #aiff #Wave #wav #wave ).
	fullName
		ifNil: [^ self].

	('*.AIFF' match: fullName)
		ifTrue: [aSound := SampledSound fromAIFFfileNamed: fullName]
		ifFalse: [aSound := SampledSound fromWaveStream: (aFileStream := FileStream oldFileNamed: fullName).
			aFileStream close].

	ext := FileDirectory extensionFor: fullName.
	aName :=  FileDirectory localNameFor: fullName.
	ext size > 0 ifTrue:
		[aName := aName copyFrom: 1 to: (aName size - (ext size + 1))].
	
	[reply := FillInTheBlank request: 'Please give a name for this sound' translated initialAnswer: aName.
	reply isEmptyOrNil ifTrue: [^ self].
	(SampledSound soundLibrary includesKey:  reply)
		ifTrue:
			[self inform: 'sorry, that name is already taken' translated.
			false]
		ifFalse:
			[true]] whileFalse.
	SampledSound addLibrarySoundNamed: reply samples: aSound samples samplingRate: aSound originalSamplingRate.
	self update
]

{ #category : #menu }
SoundLibraryTool >> pause [
	soundIndex > 0
		ifTrue: [currentSound pause]
]

{ #category : #menu }
SoundLibraryTool >> play [
	soundIndex > 0
		ifTrue: [currentSound play]
]

{ #category : #initialization }
SoundLibraryTool >> presentHelp [
	"Sent when a Help button is hit; provide the user with some form of help for the tool at hand"

	| aFlapTab |
	aFlapTab := ScriptingSystem assureFlapOfLabel: 'Sound Library' translated withContents: self helpString.
	aFlapTab showFlap
]

{ #category : #menu }
SoundLibraryTool >> renameSound [
	"Rename the selected sound, if appropriate."

	| name newName |
	name := self soundName.
	soundIndex = 0
		ifTrue: [^ self inform: 'No sound selected' translated].
	(SampledSound universalSoundKeys includes: name)
		ifTrue: [^ self inform: 'You can not rename this sound' translated].

	newName := FillInTheBlank request: 'New name for ' translated, name initialAnswer: name.
	(newName isEmptyOrNil or: [newName = name]) ifTrue: [^ self].
	(SampledSound soundLibrary includesKey: newName) ifTrue:
		[^ self inform: 'sorry, that name is already used.' translated].
	ScriptingSystem renameSound: name newName: newName.
	self update.
	self soundIndex: (listBox getList indexOf: newName)
]

{ #category : #miscellaneous }
SoundLibraryTool >> setExtentFromHalo: anExtent [
	"The user has dragged the grow box such that the receiver's extent would be anExtent.  Do what's needed."

	submorphs third height: ((anExtent y - (submorphs first height + submorphs second height + 8)))
]

{ #category : #menu }
SoundLibraryTool >> showCompression [
	^showCompression
]

{ #category : #menu }
SoundLibraryTool >> showCompressionString [
	^ (self showCompression
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		, 'show compression' translated
]

{ #category : #accessing }
SoundLibraryTool >> soundIndex [
	 ^soundIndex
]

{ #category : #accessing }
SoundLibraryTool >> soundIndex: aInteger [
 	"Set the soundIndex to the given integer."

	| |
	soundIndex :=  aInteger.
	soundIndex = 0
		ifFalse:
			[
			currentSound :=  SampledSound soundNamed: self soundName]
		ifTrue:
			[currentSound := nil].
	
        self changed: #soundIndex.
]

{ #category : #accessing }
SoundLibraryTool >> soundList [
	"Answer the list of sound keys in the sound library."

	^ SampledSound soundLibrary keys sort
]

{ #category : #accessing }
SoundLibraryTool >> soundName [
	soundIndex = 0 ifTrue:[^self].
	^ (listBox getListItem: soundIndex) first
]

{ #category : #menu }
SoundLibraryTool >> toggleShowCompression [
	showCompression := showCompression not.
	self update
]

{ #category : #accessing }
SoundLibraryTool >> update [
	self listing.
	listBox updateList
]
