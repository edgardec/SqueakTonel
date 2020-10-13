"
A SystemWindow with a single extra button in its title bar.
"
Class {
	#name : #SystemWindowWithButton,
	#superclass : #SystemWindow,
	#instVars : [
		'buttonInTitle'
	],
	#category : #'Morphic-Windows'
}

{ #category : #preferences }
SystemWindowWithButton class >> hideExpandButton [

	^ true
]

{ #category : #geometry }
SystemWindowWithButton >> adjustExtraButton [
	| leftMargin |
	buttonInTitle ifNil: [^ self].
	leftMargin := self boxExtent x + 3.
	self class moveMenuButtonRight ifTrue: [leftMargin := leftMargin * 2].
	buttonInTitle align: buttonInTitle topRight with: self innerBounds topRight - (leftMargin@0)
]

{ #category : #label }
SystemWindowWithButton >> buttonInTitle: aButton [
	buttonInTitle := aButton.
	self addMorphFront: aButton
]

{ #category : #geometry }
SystemWindowWithButton >> extent: newExtent [
	super extent: (newExtent max: 120 @ 50).
	self adjustExtraButton
]

{ #category : #label }
SystemWindowWithButton >> setLabelWidgetAllowance [
	^ labelWidgetAllowance := 115
]

{ #category : #'resize\/collapse' }
SystemWindowWithButton >> wantsExpandBox [
	"Answer whether I'd like an expand box"

	^ false
]
