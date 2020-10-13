Class {
	#name : #ScriptingDomain,
	#superclass : #Model,
	#category : #'Etoys-Scripting'
}

{ #category : #'user interface' }
ScriptingDomain >> addModelMenuItemsTo: aCustomMenu forMorph: aMorph hand: aHandMorph [ 
	super addModelMenuItemsTo: aCustomMenu forMorph: self hand: aHandMorph.  "nominally nothing"
	aCustomMenu add: 'take out of window' translated action: #takeOutOfWindow

	
]

{ #category : #'user interface' }
ScriptingDomain >> defaultWindowColor [
	^ (Color r: 0.91 g: 0.91 b: 0.91)
]

{ #category : #'user interface' }
ScriptingDomain >> initialExtent [
	^ 640 @ 480
]
