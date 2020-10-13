"
A button associated with a particular player and script.  You can ""tear off"" such a button for any etoy script, using menu items available in both Viewers and Scriptors.  The button initially is given a label reflecting its player and script name, but this can be edited via the button's halo menu, as can its other appearance parameters.  Such buttons are automatically kept in synch when the object's name or the script name change.
"
Class {
	#name : #ScriptActivationButton,
	#superclass : #SimpleButtonMorph,
	#instVars : [
		'uniclassScript'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #scripting }
ScriptActivationButton class >> additionsToViewerCategories [
	"Answer a list of (<categoryName> <list of category specs>) pairs that characterize the phrases this kind of morph wishes to add to various Viewer categories."

	^ #((button (
			(slot color 'The color of the object' Color readWrite Player getColor  Player  setColor:)
			(slot height  'The height' Number readWrite Player getHeight  Player  setHeight:) 
			(slot borderColor 'The color of the object''s border' Color readWrite Player getBorderColor Player  setBorderColor:)
			(slot borderWidth 'The width of the object''s border' Number readWrite Player getBorderWidth Player setBorderWidth:)
			(slot roundedCorners 'Whether corners should be rounded' Boolean readWrite Player getRoundedCorners Player setRoundedCorners:) 
			(slot actWhen 'When the script should fire' ButtonPhase  readWrite Player getActWhen Player setActWhen: ))))
]

{ #category : #menu }
ScriptActivationButton >> addCustomMenuItems: aMenu hand: aHandMorph [
	"Add morph-specific items to the given menu which was invoked by the given hand."

	super addCustomMenuItems: aMenu hand: aHandMorph.
	aMenu addLine.
	aMenu add: 'open underlying scriptor' translated target: target selector: #openUnderlyingScriptorFor: argument: arguments first


]

{ #category : #miscellaneous }
ScriptActivationButton >> bringUpToDate [
	"The object's name, or the script name, or both, may have changed.  Make sure I continue to look and act right"

	uniclassScript ifNotNil:
		[arguments := Array with: uniclassScript selector].
	self establishLabelWording
]

{ #category : #label }
ScriptActivationButton >> establishLabelWording [
	"Set the label wording, unless it has already been manually edited"

	| itsName |
	itsName := target externalName.
	(self hasProperty: #labelManuallyEdited)
		ifFalse:
			[self label: (itsName, ' ', arguments first) font: Preferences standardEToysButtonFont].
	self setBalloonText: 
		('click to run the script "{1}" in player named "{2}"' translated format: {arguments first. itsName}).

]

{ #category : #initialization }
ScriptActivationButton >> initializeForPlayer: aPlayer uniclassScript: aUniclassScript [
	"Initialize the receiver for the given player and uniclass script"

	target := aPlayer.
	uniclassScript := aUniclassScript.
	actionSelector := #runScript:.
	arguments := Array with: uniclassScript selector.
	self establishLabelWording
	
]

{ #category : #label }
ScriptActivationButton >> isTileScriptingElement [
	^ true
]

{ #category : #'e-toy support' }
ScriptActivationButton >> localeChanged [
	"Do nothing"
]

{ #category : #miscellaneous }
ScriptActivationButton >> setLabel [
	"Allow the user to enter a new label for this button"

	| newLabel existing |
	existing := self label.
	newLabel := FillInTheBlank
		request: 'Please enter a new label for this button' translated
		initialAnswer: existing.
	(newLabel isEmptyOrNil not and: [newLabel ~= existing]) ifTrue:
		[self setProperty: #labelManuallyEdited toValue: true.
		self label: newLabel font: Preferences standardEToysButtonFont].

]

{ #category : #access }
ScriptActivationButton >> uniclassScript [
	"Answer the receiver's uniclassScript.  For old buttons, this might initially be nil but will get set, when possible herein."

	^ uniclassScript ifNil:
		[uniclassScript := target class scripts at: arguments first ifAbsent: [nil]]
]
