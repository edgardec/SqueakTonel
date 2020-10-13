"
A button intended for use with the card architecture and the user-scripting system.
"
Class {
	#name : #ScriptableButton,
	#superclass : #UpdatingSimpleButtonMorph,
	#instVars : [
		'scriptSelector'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #scripting }
ScriptableButton class >> additionsToViewerCategories [
	"Answer a list of (<categoryName> <list of category specs>) pairs that characterize the phrases this kind of morph wishes to add to various Viewer categories."

	^ #((button (

			(slot label 'The wording on the button' String readWrite Player getLabel Player setLabel:)
			(slot color 'The color of the object' Color readWrite Player getColor  Player  setColor:)
			(slot height  'The height' Number readWrite Player getHeight  Player  setHeight:) 
			(slot borderColor 'The color of the object''s border' Color readWrite Player getBorderColor Player  setBorderColor:)
			(slot borderWidth 'The width of the object''s border' Number readWrite Player getBorderWidth Player setBorderWidth:)
			(slot  height  'The height' Number readWrite Player getHeight  Player  setHeight:)
			(slot roundedCorners 'Whether corners should be rounded' Boolean readWrite Player getRoundedCorners Player setRoundedCorners:) 
			(slot actWhen 'When the script should fire' ButtonPhase  readWrite Player getActWhen Player setActWhen: ))))
]

{ #category : #'authoring prototype' }
ScriptableButton class >> authoringPrototype [
	"Answer a scriptable button that can serve as a prototype for a parts bin"

	^ super authoringPrototype
		borderWidth: 1;
		borderColor: Color black;
		useRoundedCorners;
		color: Color yellow;
		label: 'Press me' translated;
		setNameTo: ('script{1}' translated format: {'1'});
		yourself

"ScriptableButton authoringPrototype openInHand"
]

{ #category : #printing }
ScriptableButton class >> defaultNameStemForInstances [
	"Answer the default name stem to use for instances of the receiver"

	^ 'button' translatedNoop
]

{ #category : #name }
ScriptableButton class >> descriptionForPartsBin [
	"Answer a description for use in bulding parts bins.  In latest take, this is not seen in any explicit category, but rather only in alphabetic or 'find' retrievals."

	^ self partName:	'Button' translatedNoop
		categories:		{'Scripting' translatedNoop. }
		documentation:	'A button to use with tile scripting; its script will be a method of its containing playfield' translatedNoop
]

{ #category : #'class initialization' }
ScriptableButton class >> initialize [

	self registerInFlapsRegistry.	
]

{ #category : #'class initialization' }
ScriptableButton class >> registerInFlapsRegistry [
	"Register the receiver in the system's flaps registry"
	self environment
		at: #Flaps
		ifPresent: [:cl | cl registerQuad: {#ScriptableButton. #authoringPrototype. 'Button' translatedNoop. 'A Scriptable button' translatedNoop}
						forFlapNamed: 'PlugIn Supplies'.
						cl registerQuad: {#ScriptableButton. #authoringPrototype.	'Button' translatedNoop. 	'A Scriptable button' translatedNoop}
						forFlapNamed: 'Scripting'.
						cl registerQuad: {#ScriptableButton. #authoringPrototype. 'Scriptable Button' translatedNoop. 'A button whose script will be a method of the background Player' translatedNoop}
						forFlapNamed: 'Stack Tools'.
						cl registerQuad: {#ScriptableButton. #authoringPrototype. 'Button' translatedNoop. 'A Scriptable button' translatedNoop}
						forFlapNamed: 'Supplies'.]
]

{ #category : #'class initialization' }
ScriptableButton class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #thumbnail }
ScriptableButton >> demandsThumbnailing [
	"Answer whether the receiver, if in a thumbnailable parts bin, wants to be thumbnailed whether or not size requires it.  This is set to true here because the recent event rework somehow made it possible for a scriptable button to be draggable from a parts bin otherwise, maddeningly"

	^ true
]

{ #category : #button }
ScriptableButton >> doButtonAction [
	"The user has pressed the button.  Dispatch to the actual user script, if any."

	scriptSelector ifNil: [^ super doButtonAction].
	self player performScriptIfCan: scriptSelector
]

{ #category : #script }
ScriptableButton >> editButtonsScript [
	"The user has touched my Scriptor halo-handle.  Bring up a Scriptor on the script of the button."

	| anEditor player |
	(player := self assuredPlayer) assureUniClass.
	anEditor := scriptSelector ifNil: 
					[scriptSelector := self scriptSelectorToTriggerForMe.
					player newTextualScriptorFor: scriptSelector.
					player scriptEditorFor: scriptSelector]
				ifNotNil: 
					[(player class selectors includes: scriptSelector) 
						ifTrue: [player scriptEditorFor: scriptSelector]
						ifFalse: 
							["Method somehow got removed; I guess we start afresh"
							scriptSelector := nil.
							^ self editButtonsScript]].
	anEditor showingMethodPane ifTrue: [anEditor toggleWhetherShowingTiles].
	self currentHand attachMorph: anEditor
]

{ #category : #miscellaneous }
ScriptableButton >> initializeToStandAlone [
	super initializeToStandAlone.
	self borderWidth: 1;
		borderColor: Color black;
		useRoundedCorners;
		color: Color yellow;
		label: 'Press me' translated
]

{ #category : #script }
ScriptableButton >> isLikelyRecipientForMouseOverHalos [

	self player ifNil: [^ false].
	self player getHeading = 0.0 ifTrue: [^ false].
	^ true.

]

{ #category : #accessing }
ScriptableButton >> label [
	"Answer a string representing the label of the receiver, returning an empty string if necessary"

	| aStringMorph |
	^ (aStringMorph := self findA: StringMorph)
		ifNil:		['']
		ifNotNil:	[aStringMorph contents]
]

{ #category : #accessing }
ScriptableButton >> label: aString [
	"Set the receiver's label as indicated"

	| aLabel |
	(aLabel := self findA: StringMorph)
		ifNotNil:
			[aLabel contents: aString]
		ifNil:
			[aLabel := StringMorph contents: aString font: Preferences standardEToysButtonFont.
			self addMorph: aLabel].

	self extent: aLabel extent + (self borderWidth + 6).
	aLabel position: self center - (aLabel extent // 2).

	aLabel lock
]

{ #category : #label }
ScriptableButton >> label: aString font: aFontOrNil [
	"Set the receiver's label and font as indicated"

	| oldLabel m aFont |
	(oldLabel := self findA: StringMorph)
		ifNotNil: [oldLabel delete].
	aFont := aFontOrNil ifNil: [TextStyle defaultFont].
	m := StringMorph contents: aString font: aFont.
	self extent: (m width + 6) @ (m height + 6).
	m position: self center - (m extent // 2).
	self addMorph: m.
	m lock

]

{ #category : #accessing }
ScriptableButton >> scriptSelector [
	^ scriptSelector
]

{ #category : #accessing }
ScriptableButton >> scriptSelector: aSymbol [
	scriptSelector := aSymbol
]

{ #category : #accessing }
ScriptableButton >> scriptSelectorToTriggerForMe [
	"Answer a new selector which will bear the code for myself"

	| buttonName selectorName |
	buttonName := self externalName.
	selectorName := self assuredPlayer acceptableScriptNameFrom: buttonName  forScriptCurrentlyNamed: nil.

	buttonName ~= selectorName ifTrue:
		[self setNameTo: selectorName].
	^ selectorName
]

{ #category : #menu }
ScriptableButton >> setLabel [
	"Invoked from a menu, let the user change the label of the button"

	| newLabel |
	newLabel := FillInTheBlank
		request:
'Enter a new label for this button' translated
		initialAnswer: self label.
	newLabel isEmpty ifFalse: [self label: newLabel font: nil].

]

{ #category : #'halos and balloon help' }
ScriptableButton >> wantsScriptorHaloHandle [
	"Answer whether the receiver would like to have a Scriptor halo handle put up on its behalf.  Initially, only the ScriptableButton says yes"

	^ true
]
