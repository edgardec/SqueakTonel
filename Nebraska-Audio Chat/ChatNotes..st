Class {
	#name : #ChatNotes,
	#superclass : #StringHolder,
	#instVars : [
		'name',
		'notesIndex',
		'names',
		'notes',
		'recorder',
		'player',
		'sound',
		'isPlaying',
		'isRecording',
		'isSaving',
		'nameTextMorph'
	],
	#category : #'Nebraska-Audio Chat'
}

{ #category : #'instance creation' }
ChatNotes class >> openAsMorph [

	^self new openAsMorph
]

{ #category : #'file i\/o' }
ChatNotes >> audioDirectory [

	(FileDirectory default directoryExists: 'audio')
		ifFalse: [FileDirectory default createDirectory: 'audio'].
	^FileDirectory default directoryNamed: 'audio'
]

{ #category : #'user interface' }
ChatNotes >> defaultWindowColor [
	^ (Color r: 1 g: 0.7 b: 0.8)
]

{ #category : #'file i\/o' }
ChatNotes >> deleteSelection [
	"Delete the selection in the list"
	| dir |

	notesIndex <= 0 ifTrue: [^self].
	dir := self audioDirectory.
	dir deleteFileNamed: ((notes at: notesIndex), 'name') ifAbsent: [].
	dir deleteFileNamed: ((notes at: notesIndex), 'aiff') ifAbsent: [].
	names removeAt: notesIndex.
	notes removeAt: notesIndex.
	self notesListIndex: 0.
	self changed: #notesList.
	self changed: #name.
]

{ #category : #'file i\/o' }
ChatNotes >> getNextName [
	"Return the next name available.
	All names are of the form '#.name' and '#.aiff'."
	| dir num |

	dir := self audioDirectory.
	num := 1.
	[dir fileExists: (num asString, '.name')] whileTrue: [num := num + 1].
	^(num asString, '.')
]

{ #category : #morphic }
ChatNotes >> initialExtent [
	"Nice and small--that was the idea.
	It shouldn't take up much screen real estate."
	^200@100
]

{ #category : #initialization }
ChatNotes >> initialize [

	self loadNotes.
	notesIndex := 0.
	recorder := ChatRecorder new.
	recorder initialize.
]

{ #category : #testing }
ChatNotes >> isPlaying [

	^isPlaying ifNil: [isPlaying := false]
]

{ #category : #testing }
ChatNotes >> isPlaying: aBoolean [

	isPlaying = aBoolean ifTrue: [^self].
	isPlaying := aBoolean.
	self changed: #isPlaying	
]

{ #category : #testing }
ChatNotes >> isRecording [

	^isRecording ifNil: [isRecording := false]
]

{ #category : #testing }
ChatNotes >> isRecording: aBoolean [
	
	isRecording = aBoolean ifTrue: [^self].
	isRecording := aBoolean.
	self changed: #isRecording	
]

{ #category : #testing }
ChatNotes >> isSaving [

	^isSaving ifNil: [isSaving := false]
]

{ #category : #testing }
ChatNotes >> isSaving: aBoolean [

	isSaving = aBoolean ifTrue: [^self].
	isSaving := aBoolean.
	self changed: #isSaving
]

{ #category : #testing }
ChatNotes >> isStopped [

	^false
]

{ #category : #initialization }
ChatNotes >> loadNotes [
	"Load notes from the files"
	| dir |

	names := OrderedCollection new.
	notes := OrderedCollection new.
	(FileDirectory default directoryExists: 'audio')
		ifFalse: [^self].
	dir := self audioDirectory.
	dir fileNames do: [:fname |
		(fname endsWith: '.name') ifTrue: [
			names add: ((dir fileNamed: fname) contentsOfEntireFile).
			notes add: (fname copyFrom: 1 to: (fname size - 4))]].
]

{ #category : #accessing }
ChatNotes >> name [

	^name ifNil: [name := '']
]

{ #category : #accessing }
ChatNotes >> name: aString [
	name := aString.
	self changed: #name.
]

{ #category : #accessing }
ChatNotes >> notesList [
	
	self flag: #why.
	^names copy asArray
]

{ #category : #accessing }
ChatNotes >> notesListIndex [

	^notesIndex ifNil: [notesIndex := 0]
]

{ #category : #accessing }
ChatNotes >> notesListIndex: index [
	
	notesIndex := index = notesIndex ifTrue: [0] ifFalse: [index].
	self name: (self notesList at: notesIndex ifAbsent: ['']).
	self changed: #notesListIndex.
]

{ #category : #morphic }
ChatNotes >> notesMenu: aMenu [
	"Simple menu to delete notes"
	^(notesIndex = 0)
		ifTrue: [aMenu labels: 'update notes' lines: #() selections: #(updateNotes)]
		ifFalse: [aMenu labels: ('delete', String cr, 'update notes') lines: #() selections: #(deleteSelection updateNotes)]
]

{ #category : #initialization }
ChatNotes >> openAsMorph [
	| window aColor recordButton stopButton playButton saveButton |

	window := (SystemWindow labelled: 'Audio Notes') model: self.

	window addMorph: (
		(PluggableListMorph 
			on: self 
			list: #notesList 
			selected: #notesListIndex 
			changeSelected: #notesListIndex: 
			menu: #notesMenu:
		) autoDeselect: false) frame: (0@0 corner: 0.5@1.0).

	nameTextMorph := PluggableTextMorph on: self text: #name accept: nil.
	nameTextMorph askBeforeDiscardingEdits: false.
	window addMorph: nameTextMorph frame: (0.5@0 corner: 1.0@0.4).

	aColor := Color colorFrom: self defaultBackgroundColor.

	(recordButton := PluggableButtonMorph on: self getState: #isRecording action: #record)
		label: 'record';
		askBeforeChanging: true;
		color: aColor;
		onColor: aColor darker offColor: aColor.
	window addMorph: recordButton frame: (0.5@0.4 corner: 0.75@0.7).

	(stopButton := PluggableButtonMorph on: self getState: #isStopped action: #stop)
		label: 'stop';
		askBeforeChanging: true;
		color: aColor;
		onColor: aColor darker offColor: aColor.
	window addMorph: stopButton frame: (0.75@0.4 corner: 1.0@0.7).

	(playButton := PluggableButtonMorph on: self getState: #isPlaying action: #play)
		label: 'play';
		askBeforeChanging: true;
		color: aColor;
		onColor: aColor darker offColor: aColor.
	window addMorph: playButton frame: (0.5@0.7 corner: 0.75@1.0).

	(saveButton := PluggableButtonMorph on: self getState: #isSaving action: #save)
		label: 'save';
		askBeforeChanging: true;
		color: aColor;
		onColor: aColor darker offColor: aColor.
	window addMorph: saveButton frame: (0.75@0.7 corner: 1.0@1.0).

	window openInWorld.
]

{ #category : #'file i\/o' }
ChatNotes >> play [
	| separator |
	self isPlaying: true.
	notesIndex = 0 ifTrue: [
		recorder pause.
		recorder playback.
		self isPlaying: false.
		^self
	].
	separator := FileDirectory pathNameDelimiter asString.
	sound := (AIFFFileReader new readFromFile: (
		FileDirectory default pathName, 
		separator, 'audio', separator, (notes at: notesIndex), 'aiff')) sound.
	[
		sound playAndWaitUntilDone.
		self isPlaying: false
	] fork
]

{ #category : #'button commands' }
ChatNotes >> record [

	self isRecording: true.
	notesIndex = 0 ifFalse: [self notesListIndex: 0].
	sound := nil.
	recorder clearRecordedSound.
	recorder resumeRecording.
]

{ #category : #accessing }
ChatNotes >> recorder [
	^recorder
]

{ #category : #'button commands' }
ChatNotes >> save [

	self isSaving: true.
	notesIndex = 0
		ifTrue: [self saveSound]
		ifFalse: [self saveName].
	self isSaving: false.
]

{ #category : #'file i\/o' }
ChatNotes >> saveName [
	"Save the name to the '.name' file."
	| dir file |

	self name: self textMorphString.
	dir := self audioDirectory.
	file := (notes at: notesIndex), 'name'.
	(dir fileExists: file) ifTrue: [dir deleteFileNamed: file].
	file := dir newFileNamed: file.
	file nextPutAll: name.
	file close.
	names at: notesIndex put: name.
	self changed: #notesList.
]

{ #category : #'file i\/o' }
ChatNotes >> saveSound [
	"Move the sound from the recorder to the files."
	| fname file |
	
	recorder recordedSound ifNil: [^self].
	self isSaving: true.
	fname := self getNextName.
	"Create .name file"
	file := self audioDirectory newFileNamed: (fname, 'name').
	file nextPutAll: self textMorphString.
	file close.
	"Create .aiff file"
	file := (self audioDirectory newFileNamed: (fname, 'aiff')) binary.
	self storeAIFFOnFile: file.
	file close.
	"Add to names and notes"
	names add: self textMorphString.
	notes add: fname.
	self changed: #notesList.
	self notesListIndex: (notes size).
	"Clear Recorder"
	recorder := SoundRecorder new.
	"Stop Button"
	self isSaving: false
]

{ #category : #'button commands' }
ChatNotes >> stop [
	recorder pause.
	self isRecording: false
]

{ #category : #'file i\/o' }
ChatNotes >> storeAIFFOnFile: file [
	"In a better design, this would be handled by SequentialSound,
	but I figure you will need a new primitive anyway, so it can
	be implemented at that time."
	| sampleCount |
	sampleCount := recorder recordedSound sounds inject: 0 into: [ :sum :rsound |
		sum + rsound samples monoSampleCount
	].
	file nextPutAll: 'FORM' asByteArray.
	file nextInt32Put: (2 * sampleCount) + 46.
	file nextPutAll: 'AIFF' asByteArray.
	file nextPutAll: 'COMM' asByteArray.
	file nextInt32Put: 18.
	file nextNumber: 2 put: 1. "channels"
	file nextInt32Put: sampleCount.
	file nextNumber: 2 put: 16. "bits/sample"
	(AbstractSound new) storeExtendedFloat: (recorder samplingRate) on: file.
	file nextPutAll: 'SSND' asByteArray.
	file nextInt32Put: (2 * sampleCount) + 8.
	file nextInt32Put: 0.
	file nextInt32Put: 0.
	(recorder recordedSound sounds) do: [:rsound |
		1 to: (rsound samples monoSampleCount) do: [:i |
			| s |
			s := rsound samples at: i.
			file nextPut: ((s bitShift: -8) bitAnd: 16rFF).
			file nextPut: (s bitAnd: 16rFF)]].
]

{ #category : #morphic }
ChatNotes >> textMorphString [

	^nameTextMorph text string
]

{ #category : #'file i\/o' }
ChatNotes >> updateNotes [
	"Probably not necessary unless several audio notes are
	open at the same time"

	"Clear Notes"
	self loadNotes.
	self changed: #notesList.
	self notesListIndex: 0.
	self name: ''.
]
