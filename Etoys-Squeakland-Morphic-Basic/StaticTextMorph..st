"
A TextMorph that is unwilling to be edited or rotated.
"
Class {
	#name : #StaticTextMorph,
	#superclass : #TextMorph,
	#category : #'Etoys-Squeakland-Morphic-Basic'
}

{ #category : #'resisting rotation' }
StaticTextMorph >> addFlexShell [
	"Actually, don't"
]

{ #category : #'resisting rotation' }
StaticTextMorph >> addFlexShellIfNecessary [
	"For me, it never is necessary"
]

{ #category : #drawing }
StaticTextMorph >> drawNullTextOn: aCanvas [
	"Make null text frame visible"

	aCanvas isPostscriptCanvas ifFalse:
		[aCanvas fillRectangle: bounds color: Color transparent]
]

{ #category : #'event handling' }
StaticTextMorph >> handlesKeyboard: evt [
	"Don't do text editing, unless the receiver is outfitted with an explicit keyboard handler."

	editor := nil. 	"just to be sure"
	self eventHandler ifNotNil: [^ self eventHandler handlesKeyboard: evt].
	^ false
]

{ #category : #'resisting rotation' }
StaticTextMorph >> handlesMouseDown: evt [
	"Decline to handle text-editing-inducing mouse-downs, so that the receiver can be easily grabbed for relocation"
	
	| eh |
	^ (eh := self eventHandler) notNil and:
		[eh handlesMouseDown: evt]
]

{ #category : #'resisting rotation' }
StaticTextMorph >> heading: newHeading [
	"Set the receiver's heading (in eToy terms)"

	self rotationDegrees: newHeading
]

{ #category : #'e-toy support' }
StaticTextMorph >> measureContents [
	
	^ text asStringMorph measureContents
]

{ #category : #'mouse-handling' }
StaticTextMorph >> mouseDown: evt [
	"Don't do text-editing things, but dispatch to evt handler if appropriate"

	self eventHandler ifNotNil:
		[self eventHandler mouseDown: evt fromMorph: self]
]

{ #category : #'mouse-handling' }
StaticTextMorph >> mouseUp: evt [
	"Don't do text-editing things, but dispatch to evt handler if appropriate"
	
	self eventHandler ifNotNil:
		[self eventHandler mouseUp: evt fromMorph: self]
]

{ #category : #'e-toy support' }
StaticTextMorph >> printOn: aStream [
	"Print the receiver on a stream."

	super printOn: aStream.
	aStream nextPutAll: ': '.
	self contents asString printOn: aStream
]

{ #category : #'resisting rotation' }
StaticTextMorph >> rotationDegrees: degrees [ 
	"Set my rotationDegreees.  This unusual code is part of the effort to make me avoid the heartbreak of rotation"

	self forwardDirection: degrees
]

{ #category : #'e-toy support' }
StaticTextMorph >> setCharacters: chars [
	"obtain a string value from the receiver"

	super setCharacters: chars.
	self extent: (self measureContents x @ self extent y).
]

{ #category : #'event handling' }
StaticTextMorph >> wouldAcceptKeyboardFocusUponTab [
	"Since the receiver is not user-editible by conventional means, refuse to give it the selection upon tab."

	^ false
]
