"
Used by MREncoder and MRDecoder.  It associates an integer index with a number of fonts.  Fonts can be searched by index, and the index can be found for a font that isn't present.  If a font is added to the cache, sometimes the cache will discard another font to make room.
"
Class {
	#name : #FontCache,
	#superclass : #Object,
	#instVars : [
		'fonts'
	],
	#category : #'Nebraska-Morphic-Remote'
}

{ #category : #'instance creation' }
FontCache class >> new: size [
	^super new initialize: size
]

{ #category : #lookups }
FontCache >> fontAt: index [
	"return the font associated with the given index"
	^fonts at: index
]

{ #category : #lookups }
FontCache >> includesFont: aFont [
	"decide whether the given font is included in the collection"
	^fonts identityIncludes: aFont	
]

{ #category : #lookups }
FontCache >> indexForNewFont: aFont [
	"add aFont to the cache.  Return its index.  The receiver will sometimes choose an index that is already used; that means that aFont is replacing the other font"
	| index |
	index := fonts size atRandom.      "random is simpler to manage than anything else"
	fonts at: index put: aFont.
	^index
]

{ #category : #lookups }
FontCache >> indexOf: aFont [
	"return the index for a given font"
	^fonts identityIndexOf: aFont
]

{ #category : #initialization }
FontCache >> initialize: cacheSize [
	fonts := Array new: cacheSize.
]
