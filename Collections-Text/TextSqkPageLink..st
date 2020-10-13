"
I represent a link to either a SqueakPage in a BookMorph, or a regular url.  See TextMorphEditor changeEmphasis:.  

"
Class {
	#name : #TextSqkPageLink,
	#superclass : #TextURL,
	#category : #'Collections-Text'
}

{ #category : #'fileIn\/Out' }
TextSqkPageLink class >> scanCharacter [
	"The character used to identify a subclass of TextAttribute for filein and fileout"
	^$q
]
