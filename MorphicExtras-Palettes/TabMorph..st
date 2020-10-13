"
A tab in a palette.  The contents is the name to be shown.  If it represents a book, that book is pointed to in my morphToInstall.
"
Class {
	#name : #TabMorph,
	#superclass : #StringButtonMorph,
	#instVars : [
		'morphToInstall'
	],
	#category : #'MorphicExtras-Palettes'
}

{ #category : #printing }
TabMorph class >> defaultNameStemForInstances [
	^ 'tab' translatedNoop
]

{ #category : #converting }
TabMorph >> convertToReferenceMorph [
	| aMorph |
	aMorph := ReferenceMorph new referent: morphToInstall.
	aMorph position: self position.
	self becomeForward: aMorph.
]

{ #category : #testing }
TabMorph >> isHighlighted [
	^ false
]

{ #category : #accessing }
TabMorph >> morphToInstall [
	^ morphToInstall
]

{ #category : #accessing }
TabMorph >> morphToInstall: m [
	morphToInstall := m.
	self contents: m externalName.
	self actionSelector: #tabSelected.
	self target: self
]

{ #category : #tabs }
TabMorph >> tabSelected [
	"Called when the receiver is hit.  First, bulletproof against someone having taken the structure apart.  My own action basically requires that my grand-owner be a TabbedPalette"
	self player ifNotNil: [self player runAllOpeningScripts ifTrue: [^ self]].
	(owner isKindOf: IndexTabs) ifFalse: [^ Beeper beep].
	(owner owner isKindOf: TabbedPalette) ifFalse: [^ Beeper beep].
	owner owner selectTab: self
]

{ #category : #copying }
TabMorph >> veryDeepFixupWith: deepCopier [
	"If target and arguments fields were weakly copied, fix them here.  If they were in the tree being copied, fix them up, otherwise point to the originals!!"

super veryDeepFixupWith: deepCopier.
morphToInstall := deepCopier references at: morphToInstall ifAbsent: [morphToInstall].
]

{ #category : #copying }
TabMorph >> veryDeepInner: deepCopier [
	"Copy all of my instance variables.  Some need to be not copied at all, but shared.  	Warning!!  Every instance variable defined in this class must be handled.  We must also implement veryDeepFixupWith:.  See DeepCopier class comment."

super veryDeepInner: deepCopier.
morphToInstall := morphToInstall.		"Weakly copied"
]
