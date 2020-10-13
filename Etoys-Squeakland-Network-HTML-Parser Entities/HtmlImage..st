Class {
	#name : #HtmlImage,
	#superclass : #HtmlSpecialEntity,
	#instVars : [
		'image'
	],
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlImage >> addToFormatter: formatter [
	| morph url |
	self src isNil ifTrue: [ ^self ].
	url := self src.
	formatter baseUrl ifNotNil: [ 
		url := url asUrlRelativeTo: formatter baseUrl ].


	morph := DownloadingImageMorph new.
	morph defaultExtent: self imageExtent.
	morph altText: self alt.
	morph url: url.
	self imageMapName
		ifNotNil:
			[morph imageMapName: self imageMapName.
			morph formatter: formatter].

	formatter addIncompleteMorph: morph.
]

{ #category : #attributes }
HtmlImage >> alt [
	^(self getAttribute: 'alt') ifNil: ['[image]']
]

{ #category : #downloading }
HtmlImage >> downloadState: baseUrl [ 
	|  sourceUrl imageSource |

	image ifNil: [ 
		sourceUrl := self src.
		sourceUrl ifNotNil: [ 
			imageSource := HTTPSocket httpGetDocument: (sourceUrl asUrlRelativeTo: baseUrl asUrl) toText.
			imageSource contentType = 'image/gif'  ifTrue: [
				[image := (GIFReadWriter on: (RWBinaryOrTextStream with: imageSource content) reset binary) nextImage ]
				ifError: [ :a :b |  "could not decode--ignore it"  image := nil ] ].
			 ] ].

]

{ #category : #attributes }
HtmlImage >> imageExtent [
	"the image extent, according to the WIDTH and HEIGHT attributes.  returns nil if either WIDTH or HEIGHT is not specified"
	| widthText heightText |
	widthText := self getAttribute: 'width' ifAbsent: [ ^nil ].
	heightText := self getAttribute: 'height' ifAbsent: [ ^nil ].
	^ [ widthText asNumber @ heightText asNumber ] ifError: [ :a :b | nil ]
]

{ #category : #attributes }
HtmlImage >> imageMapName [
	| imageMapName |
	(imageMapName := self getAttribute: 'usemap')
		ifNil: [^nil].
	imageMapName first = $#
		ifTrue: [imageMapName := imageMapName copyFrom: 2 to: imageMapName size].
	^imageMapName
]

{ #category : #initializing }
HtmlImage >> initialize: aTag [	
	super initialize: aTag.

]

{ #category : #testing }
HtmlImage >> mayContain: anEntity [
	^false
]

{ #category : #attributes }
HtmlImage >> src [
	^self getAttribute: 'src' default: nil
]

{ #category : #testing }
HtmlImage >> tagName [
	^'img'
]
