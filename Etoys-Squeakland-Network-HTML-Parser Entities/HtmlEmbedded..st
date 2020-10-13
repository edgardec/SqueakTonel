Class {
	#name : #HtmlEmbedded,
	#superclass : #HtmlSpecialEntity,
	#classVars : [
		'ExtensionList'
	],
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #initialize }
HtmlEmbedded class >> initialize [
	"HtmlEmbedded initialize"
	ExtensionList := Dictionary new.
	#(
		('swf'	FlashPlayerMorph)
	) do:[:spec| ExtensionList at: spec first put: spec last].
]

{ #category : #formatting }
HtmlEmbedded >> addToFormatter: formatter [
	| url embeddedMorph |
	self src isNil ifTrue:[^self].
	url := self src.
	embeddedMorph := self embeddedMorphFor: url.
	embeddedMorph isNil ifTrue:[^self].
	formatter baseUrl ifNotNil:[url := url asUrlRelativeTo: formatter baseUrl].
	embeddedMorph extent: self extent.
	embeddedMorph sourceUrl: url.
	embeddedMorph setProperty: #embedded toValue: true.
	formatter addIncompleteMorph: embeddedMorph.
]

{ #category : #formatting }
HtmlEmbedded >> embeddedMorphClassFor: url [
	| lastIndex extension className |
	lastIndex := url findLast:[:c| c = $.].
	lastIndex = 0 ifTrue:[^nil].
	extension := url copyFrom: lastIndex+1 to: url size.
	className := ExtensionList at: extension asLowercase ifAbsent:[^nil].
	^Smalltalk at: className ifAbsent:[nil]
	
]

{ #category : #formatting }
HtmlEmbedded >> embeddedMorphFor: url [
	| morphClass |
	morphClass := self embeddedMorphClassFor: url.
	^morphClass ifNotNil:[morphClass new]
]

{ #category : #attributes }
HtmlEmbedded >> extent [
	"the image extent, according to the WIDTH and HEIGHT attributes.  returns nil if either WIDTH or HEIGHT is not specified"
	| widthText heightText |
	widthText := self getAttribute: 'width' ifAbsent: [ ^nil ].
	heightText := self getAttribute: 'height' ifAbsent: [ ^nil ].
	^ widthText asNumber @ heightText asNumber
]

{ #category : #testing }
HtmlEmbedded >> mayContain: anEntity [
	^false
]

{ #category : #attributes }
HtmlEmbedded >> src [
	^self getAttribute: 'src' default: nil
]

{ #category : #testing }
HtmlEmbedded >> tagName [
	^'embed'
]
