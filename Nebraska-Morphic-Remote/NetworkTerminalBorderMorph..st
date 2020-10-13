Class {
	#name : #NetworkTerminalBorderMorph,
	#superclass : #EmbeddedWorldBorderMorph,
	#category : #'Nebraska-Morphic-Remote'
}

{ #category : #boxes }
NetworkTerminalBorderMorph >> boxesAndColorsAndSelectors [

	^#()
]

{ #category : #initialization }
NetworkTerminalBorderMorph >> initialize [

	super initialize.
	self setBalloonText: nil.		"'I am a view on another Squeak'."
	self layoutInset: 0.

]

{ #category : #'as yet unclassified' }
NetworkTerminalBorderMorph >> toggleFullView [
	"Toggle the full view for network terminal"
	| fullExtent priorExtent |
	fullExtent := self worldIEnclose extent + (2 * self borderWidth).
	priorExtent := self valueOfProperty: #priorExtent.
	priorExtent ifNil:[
		self setProperty: #priorExtent toValue: self extent.
		self extent: fullExtent.
		self position: self position + self borderWidth asPoint negated.
	] ifNotNil:[
		self removeProperty: #priorExtent.
		self extent: priorExtent.
		self position: (self position max: 0@0).
	].
]
