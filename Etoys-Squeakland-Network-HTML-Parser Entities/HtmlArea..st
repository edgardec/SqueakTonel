Class {
	#name : #HtmlArea,
	#superclass : #HtmlEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlArea >> buildMorph [
	"construct a hot-spot morph"
	| coords vertices radiusX radiusY |
	coords := (self coords findTokens: ', ') collect: [:elem | elem asNumber asInteger].
	self shape isEmptyOrNil
		ifTrue: [^nil].

	(self shape asLowercase beginsWith: 'poly')
		ifTrue: [coords size even ifFalse: [^nil].
			vertices := OrderedCollection new.
			coords pairsDo: [:x :y |
				vertices add: x @ y].
			^(PolygonMorph vertices: vertices color: Color transparent
				borderWidth: 1 borderColor: Color transparent) quickFill: false; makeClosed].

	(coords size > 4 or: [coords size < 3])
		ifTrue: [^nil].

	self shape asLowercase = 'circle'
		ifTrue: [radiusX := coords third.
			radiusY := coords last.
			^(EllipseMorph newBounds:
				(((coords first - radiusX) @ (coords second - radiusY))
				extent:
				((2 * radiusX) @ (2 * radiusY)))
			color: Color transparent) borderColor: Color transparent].

	coords size = 4
		ifFalse: [^nil].

	(self shape asLowercase beginsWith: 'rect')
		ifTrue: [^(RectangleMorph newBounds:
				(Rectangle origin: (coords first @ coords second)
				corner: (coords third @ coords last))
			color: Color transparent) borderColor: Color transparent].

	^nil
]

{ #category : #accessing }
HtmlArea >> coords [
	^self getAttribute: 'coords'
]

{ #category : #accessing }
HtmlArea >> href [
	^self getAttribute: 'href'
]

{ #category : #testing }
HtmlArea >> isArea [
	^true
]

{ #category : #formatting }
HtmlArea >> linkMorphForMap: map andBrowser: browser [
	| m |
	(m := self buildMorph) ifNil: [^nil].
	m color: (Color random alpha: 0.1). "hack to ensure the morph is clickable"
	m
		on: #mouseUp
		send: #mouseUpBrowserAndUrl:event:linkMorph:
		to: map
		withValue: {browser. self href}.
	^m
]

{ #category : #testing }
HtmlArea >> mayContain: anEntity [
	^false
]

{ #category : #accessing }
HtmlArea >> shape [
	^self getAttribute: 'shape'
]

{ #category : #testing }
HtmlArea >> tagName [
	^'area'
]
