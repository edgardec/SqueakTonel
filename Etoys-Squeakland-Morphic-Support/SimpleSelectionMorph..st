"
A morph used in the implementaiton of Karl Ramberg's omnidirectional grab-patch tool
"
Class {
	#name : #SimpleSelectionMorph,
	#superclass : #Morph,
	#category : #'Etoys-Squeakland-Morphic-Support'
}

{ #category : #extending }
SimpleSelectionMorph >> extendByHand: aHand [
	"Assumes selection has just been created and added to some pasteUp or world"

	| startPoint handle m inner |
	startPoint := Sensor cursorPoint.
	
	handle := NewHandleMorph new followHand: aHand
		forEachPointDo: [:newPoint |
					| localPt |
					Cursor crossHair show.
					localPt := (self transformFrom: self world) globalPointToLocal: newPoint.
					self bounds: (startPoint rect: localPt)]
		lastPointDo:
			 [:newPoint |
			inner := self bounds insetBy: 2@2.
			inner area >= 16
				ifTrue:
					[m := SketchMorph new form: (Form fromDisplay: inner).
					aHand attachMorph: m.
					self currentWorld fullRepaintNeeded]  "selection tracking can leave unwanted artifacts"
				ifFalse:
					[Beeper beep].  "throw minnows back"
			self delete].
	
	handle visible: false.
	aHand attachMorph: handle.
	handle startStepping
]

{ #category : #initialization }
SimpleSelectionMorph >> initialize [
	"initialize the state of the receiver"

	super initialize.
	self color: Color transparent.
        self borderColor: Color black.
	self borderWidth: 2.
	self setProperty: #ignorePartsBinDrop toValue: true
]
