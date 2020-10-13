Class {
	#name : #HtmlMap,
	#superclass : #HtmlEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlMap >> addToFormatter: formatter [
	super addToFormatter: formatter.
	formatter addImageMap: self
]

{ #category : #morphic }
HtmlMap >> buildImageMapForImage: imageMorph andBrowser: browser [
	| areaMorph |
	contents do: [:area |
		(area isArea
		and: [(areaMorph := area linkMorphForMap: self andBrowser: browser) isNil not])
			ifTrue: [imageMorph addMorph: areaMorph]].
	^imageMorph
]

{ #category : #testing }
HtmlMap >> mayContain: anEntity [
	^anEntity isArea
]

{ #category : #morphic }
HtmlMap >> mouseUpBrowserAndUrl: browserAndUrl event: event linkMorph: linkMorph [
	"this is an image map area, just follow the link"
	| browser url |
	browser := browserAndUrl first.
	url := browserAndUrl second.
	browser jumpToUrl: url
]

{ #category : #morphic }
HtmlMap >> mouseUpEvent: arg1 linkMorph: arg2 browserAndUrl: arg3 [
	"Reorder the arguments for existing event handlers"
	(arg3 isMorph and:[arg3 eventHandler notNil]) ifTrue:[arg3 eventHandler fixReversedValueMessages].
	^self mouseUpBrowserAndUrl: arg1 event: arg2 linkMorph: arg3
]

{ #category : #accessing }
HtmlMap >> name [
	^self getAttribute: 'name'
]

{ #category : #testing }
HtmlMap >> tagName [
	^'map'
]
