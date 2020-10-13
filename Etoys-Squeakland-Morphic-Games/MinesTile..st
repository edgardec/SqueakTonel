Class {
	#name : #MinesTile,
	#superclass : #SimpleSwitchMorph,
	#instVars : [
		'switchState',
		'disabled',
		'oldSwitchState',
		'isMine',
		'nearMines',
		'palette',
		'mineFlag'
	],
	#classVars : [
		'PreferredColor'
	],
	#category : #'Etoys-Squeakland-Morphic-Games'
}

{ #category : #'new-morph participation' }
MinesTile class >> includeInNewMorphMenu [

	^false
]

{ #category : #accessing }
MinesTile >> color: aColor [ 
	super color: aColor.
	onColor := aColor.
	offColor := aColor.
	self changed
]

{ #category : #accessing }
MinesTile >> disabled [

	^ disabled

]

{ #category : #accessing }
MinesTile >> disabled: aBoolean [

	disabled := aBoolean.
	disabled
		ifTrue:
			[self color: owner color.
			self borderColor: owner color]
		ifFalse:
			[self setSwitchState: self switchState]
]

{ #category : #accessing }
MinesTile >> doButtonAction: modifier [ 
	"Perform the action of this button. The first argument of the message sent to the target is the current state of this switch, 
	the second argument is the modifier button state."

	(target notNil and: [actionSelector notNil]) 
		ifTrue: 
			[^target perform: actionSelector
				withArguments: ((arguments copyWith: switchState) copyWith: modifier)]
]

{ #category : #drawing }
MinesTile >> drawOn: aCanvas [ 
	"Draw a rectangle with a solid, inset, or raised border.
	Note: the raised border color *and* the inset border color are generated
	from the receiver's own color, instead of having the inset border color
	generated from the owner's color, as in BorderedMorph."

	| font rct |
	super drawOn: aCanvas.
	
	self borderStyle style == #inset ifTrue: [
		self isMine ifTrue: [  
			font  := StrikeFont familyName: 'Atlanta' size: 22 emphasized: 1.
			rct := self bounds insetBy: ((self bounds width) - (font widthOfString: '*'))/2@0.
			rct := rct top: rct top + 1.
			aCanvas drawString: '*' in: (rct translateBy: 1@1) font: font color: Color black.
			^ aCanvas drawString: '*' in: rct font: font color: Color red .].
		self nearMines > 0 ifTrue: [ 
			font := StrikeFont familyName: 'ComicBold' size: 22 emphasized: 1.
			rct := self bounds insetBy: ((self bounds width) - (font widthOfString: nearMines asString))/2@0.
			rct := rct top: rct top + 1.
			aCanvas drawString: nearMines asString in: (rct translateBy: 1@1) font: font color: Color black.
			^ aCanvas drawString: nearMines asString in: rct font: font color: ((palette at: nearMines) ) .]].
]

{ #category : #initialization }
MinesTile >> initialize [

	super initialize.
	self label: ''.
	self borderWidth: 3.
	bounds := 0@0 corner: 20@20.
	offColor := self preferredColor.
	onColor := self preferredColor.
	switchState := false.
	oldSwitchState := false.
	disabled := false.
	isMine := false.
	nearMines := 0.
	self useSquareCorners.
	palette := (Color wheel: 8) asOrderedCollection reverse.
"	flashColor := palette removeLast."

]

{ #category : #accessing }
MinesTile >> isMine [

	^ isMine
]

{ #category : #accessing }
MinesTile >> isMine: aBoolean [

	isMine := aBoolean.

]

{ #category : #accessing }
MinesTile >> mineFlag [

	^ mineFlag.

]

{ #category : #accessing }
MinesTile >> mineFlag: boolean [

	mineFlag := boolean.
	mineFlag ifTrue: [
		self color: Color red lighter lighter lighter lighter.]
		ifFalse: [
		self color: self preferredColor.].
	^ mineFlag.

]

{ #category : #'event handling' }
MinesTile >> mouseDown: evt [
 	"The only real alternative mouse clicks are the yellow button or the shift key. I will treat them as the same thing, and ignore two button presses for now. I am keeping this code around, because it is the only documentation I have of MouseButtonEvent."
	| mod |
"	Transcript show: 'anyModifierKeyPressed - '; show: evt anyModifierKeyPressed printString ; cr;
			 show: 'commandKeyPressed - '; show: evt commandKeyPressed printString ;  cr;
			 show: 'controlKeyPressed - '; show:evt controlKeyPressed printString ; cr;
			 show: 'shiftPressed - '; show: evt shiftPressed printString ; cr;
			 show: 'buttons - '; show: evt buttons printString ; cr;
			 show: 'handler - '; show: evt handler printString ;  cr;
			 show: 'position - '; show: evt position printString ; cr;
			 show: 'type - '; show: evt type printString ; cr;
			 show: 'anyButtonPressed - '; show: evt anyButtonPressed printString ; cr;
			 show: 'blueButtonPressed - '; show: evt blueButtonPressed printString ; cr;
			 show: 'redButtonPressed - '; show: evt redButtonPressed printString ; cr;
			 show: 'yellowButtonPressed - '; show: evt yellowButtonPressed printString ; cr; cr; cr."
			
	
	mod :=  (evt yellowButtonPressed) | (evt shiftPressed). 
	switchState ifFalse:[
		(self doButtonAction: mod) ifTrue:
			[mod ifFalse: [ self setSwitchState: true. ].].
	] ifTrue: [
			self doButtonAction: mod.].
]

{ #category : #'event handling' }
MinesTile >> mouseMove: evt [

	"don't do anything, here"
]

{ #category : #'event handling' }
MinesTile >> mouseUp: evt [

	"don't do anything, here"
]

{ #category : #accessing }
MinesTile >> nearMines [

	^ nearMines.

]

{ #category : #accessing }
MinesTile >> nearMines: nMines [

	nearMines := nMines.

]

{ #category : #initialization }
MinesTile >> preferredColor [
		"PreferredColor := nil  <-- to reset cache"
	PreferredColor ifNil:
		["This actually takes a while to compute..."
		PreferredColor := Color gray lighter lighter lighter].
	^ PreferredColor
]

{ #category : #accessing }
MinesTile >> switchState [

	^ switchState
]

{ #category : #accessing }
MinesTile >> switchState: aBoolean [

	switchState := aBoolean.
	disabled ifFalse:
		[switchState
			ifTrue:[
				"flag ifTrue: [self setFlag]." "if this is a flagged tile, unflag it."
				self borderStyle: (BorderStyle inset width: 1).
				self color: onColor]
			ifFalse:[
				self borderStyle: (BorderStyle raised width: 3).
				self color: offColor]]
]
