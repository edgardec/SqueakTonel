Class {
	#name : #NoHaloMorph,
	#superclass : #Morph,
	#category : #'Etoys-Squeakland-Sugar'
}

{ #category : #'instance creation' }
NoHaloMorph class >> inARow: aCollectionOfMorphs [
	"Answer an instance of the receiver, a row morph, with the given collection as its submorphs, and transparent in color.  Interpret the symbol #spacer in the incoming list as a request for a variable transparent spacer."

	| row |
	row := self new.
	row layoutPolicy: TableLayout new.
	row
		listDirection: #leftToRight;
		vResizing: #shrinkWrap;
		hResizing: #spaceFill;
		layoutInset: 0;
		cellPositioning: #center;
		borderWidth: 0;
		color: Color transparent.
	aCollectionOfMorphs do:
		[ :each |  | toAdd |
			toAdd := each == #spacer
				ifTrue:
					[AlignmentMorph newVariableTransparentSpacer]
				ifFalse:
					[each].
			row addMorphBack: toAdd].
	^ row

]

{ #category : #'as yet unclassified' }
NoHaloMorph >> wantsHaloFromClick [

	^ false.

]
