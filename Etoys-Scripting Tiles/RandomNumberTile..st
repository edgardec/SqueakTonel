"
Disused; retained ""temporarily"" for backward compatibility.  The duties formerly served by the RandomNumberTile are now handled by the generic FunctionTile.
"
Class {
	#name : #RandomNumberTile,
	#superclass : #TileMorph,
	#category : #'Etoys-Scripting Tiles'
}

{ #category : #'class initialization' }
RandomNumberTile class >> initialize [

	self registerInFlapsRegistry.	
]

{ #category : #'class initialization' }
RandomNumberTile class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry.  Or, now that this class is disused, do not..."

	true ifTrue: [^ self].

	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#RandomNumberTile.	#new.	'Random' translatedNoop.		'A random-number tile for use with tile scripting' translatedNoop}
						forFlapNamed: 'PlugIn Supplies'.
						cl registerQuad: {#RandomNumberTile. #new.	 'Random' translatedNoop.		'A tile that will produce a random number in a given range' translatedNoop}
						forFlapNamed: 'Scripting'.]
]

{ #category : #'class initialization' }
RandomNumberTile class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #'code generation' }
RandomNumberTile >> basicStoreCodeOn: aStream indent: tabCount [
	aStream
			nextPut: $(;
			nextPutAll: literal printString;
			nextPutAll: ' atRandom)'.
]

{ #category : #'event handling' }
RandomNumberTile >> handlesMouseDown: evt [

	| aPoint |

	self inPartsBin ifTrue: [^false].
	aPoint := evt cursorPoint.

	"This might actually be a suitable test for the superclass, but I'll do it here to minimize the downside"

	{upArrow. downArrow. suffixArrow. retractArrow} do: [ :each |
		(each notNil and: [each bounds containsPoint: aPoint]) ifTrue: [
			^true
		]
	].

	^false		"super handlesMouseDown: evt"
]

{ #category : #initialization }
RandomNumberTile >> initialize [
	"Initialize the receiver fully, including adding all its relevant submorphs"

	| m1 m2 |
	super initialize.
	self vResizing: #shrinkWrap.
	self typeColor: (ScriptingSystem colorForType: #Number).
	self addArrows.
	m1 := StringMorph contents: 'random' translated font: ScriptingSystem fontForTiles.
	self addMorph: m1.
	m2 := UpdatingStringMorph contents: '180' font: ScriptingSystem fontForTiles.
	m2 target: self; getSelector: #literal; putSelector: #literal:.
	m2 position: m1 topRight.
	self addMorphBack: m2.
	literal := 180.
	self updateLiteralLabel.
	self makeAllTilesGreen
]

{ #category : #'code generation' }
RandomNumberTile >> kedamaStoreCodeOn: aStream indent: tabCount actualObject: obj [
	aStream
			nextPut: $(;
			nextPutAll: obj uniqueNameForReference;
			nextPutAll: ' random: ';
			nextPutAll: literal printString;
			nextPut: $).

]

{ #category : #accessing }
RandomNumberTile >> labelMorph [
	^ submorphs detect: [:m | m isKindOf: UpdatingStringMorph] ifNone: [nil].
]

{ #category : #misc }
RandomNumberTile >> numericValue [
	^ super numericValue atRandom
]

{ #category : #accessing }
RandomNumberTile >> storeCodeOn: aStream indent: tabCount [

	| phrase player costume |
	phrase := self outermostMorphThat: [:m| m isKindOf: PhraseTileMorph].
	phrase ifNil: [^ self basicStoreCodeOn: aStream indent: tabCount].

	player := phrase associatedPlayer.
	player ifNil: [^ self basicStoreCodeOn: aStream indent: tabCount].

	costume := player costume.
	costume ifNil: [^ self basicStoreCodeOn: aStream indent: tabCount].

	(player isKindOf: KedamaExamplerPlayer) ifTrue: [
		^ self kedamaStoreCodeOn: aStream indent: tabCount actualObject: player costume renderedMorph kedamaWorld player].

	(costume renderedMorph isMemberOf: KedamaMorph) ifTrue: [
		^ self kedamaStoreCodeOn: aStream indent: tabCount actualObject: self].

	^ self basicStoreCodeOn: aStream indent: tabCount.
]

{ #category : #'player viewer' }
RandomNumberTile >> updateLiteralLabel [
	| myReadout |
	(myReadout := self labelMorph) ifNil: [^ self].
	myReadout contents: literal stringForReadout.

]

{ #category : #initialization }
RandomNumberTile >> updateWordingToMatchVocabulary [

	| stringMorph |
	stringMorph := submorphs
				detect: [:morph | morph class == StringMorph]
				ifNone: [^ self].
	stringMorph contents: 'random' translated.


]
