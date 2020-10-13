"
A transparent, space-filling, halo-shy morph, for use in alignment structures.
"
Class {
	#name : #VariableSpacer,
	#superclass : #AlignmentMorph,
	#category : #'Etoys-Squeakland-Morphic-Basic'
}

{ #category : #initialization }
VariableSpacer >> initialize [
	"Initialize the receiver to be a halo-shy variable transparent spacer."

	super initialize.
	self
		hResizing: #spaceFill;
		vResizing: #spaceFill;
		layoutInset: 0;
		borderWidth: 0;
		extent: 1@1;
		color: Color transparent
]

{ #category : #'halos and balloon help' }
VariableSpacer >> wantsHaloFromClick [
	"Answer no."

	^ false
]
