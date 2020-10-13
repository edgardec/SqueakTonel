Class {
	#name : #ChatButtonMorph,
	#superclass : #SimpleButtonMorph,
	#instVars : [
		'actionDownSelector',
		'actionUpSelector',
		'labelDown',
		'labelUp'
	],
	#category : #'Nebraska-Audio Chat'
}

{ #category : #accessing }
ChatButtonMorph >> actionDownSelector: aSymbolOrString [

	(nil = aSymbolOrString or:
	['nil' = aSymbolOrString or:
	[aSymbolOrString isEmpty]])
		ifTrue: [^actionDownSelector := nil].

	actionDownSelector := aSymbolOrString asSymbol.
]

{ #category : #accessing }
ChatButtonMorph >> actionUpSelector: aSymbolOrString [


	(nil = aSymbolOrString or:
	 ['nil' = aSymbolOrString or:
	 [aSymbolOrString isEmpty]])
		ifTrue: [^ actionUpSelector := nil].

	actionUpSelector := aSymbolOrString asSymbol.
]

{ #category : #events }
ChatButtonMorph >> doButtonDownAction [
	(target notNil and: [actionDownSelector notNil]) 
		ifTrue: [Cursor normal showWhile: [target perform: actionDownSelector]]
]

{ #category : #events }
ChatButtonMorph >> doButtonUpAction [
	(target notNil and: [actionUpSelector notNil]) 
		ifTrue: [Cursor normal showWhile: [target perform: actionUpSelector]]
]

{ #category : #accessing }
ChatButtonMorph >> labelDown: aString [

	labelDown := aString.
]

{ #category : #accessing }
ChatButtonMorph >> labelUp: aString [

	labelUp := aString
]

{ #category : #'event handling' }
ChatButtonMorph >> mouseDown: evt [

	oldColor := self fillStyle.
	self label: labelDown.
	self doButtonDownAction.


]

{ #category : #'event handling' }
ChatButtonMorph >> mouseUp: evt [

	"if oldColor nil, it signals that mouse had not gone DOWN inside me, e.g. because of a cmd-drag; in this case we want to avoid triggering the action!"

	oldColor ifNil: [^self].
	self color: oldColor.
	(self containsPoint: evt cursorPoint) ifTrue: [
		self label: labelUp.
		self doButtonUpAction.
	].

]
