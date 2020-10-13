Class {
	#name : #GeeBookMorph,
	#superclass : #BookMorph,
	#instVars : [
		'geeMail'
	],
	#category : #'MorphicExtras-GeeMail'
}

{ #category : #'new-morph participation' }
GeeBookMorph class >> includeInNewMorphMenu [

	^ false
]

{ #category : #initialization }
GeeBookMorph >> defaultColor [
	"answer the default color/fill style for the receiver"
	^ Color
		r: 0.909
		g: 0.819
		b: 0.09
]

{ #category : #accessing }
GeeBookMorph >> geeMail: aGeeMail [

	geeMail := aGeeMail.
]

{ #category : #ui }
GeeBookMorph >> geePageRectangles [

	| pageBounds allPageRects |

	pageBounds := geeMail topLeft 
			extent: geeMail width @ (geeMail height min: Display height - 50).
	allPageRects := OrderedCollection new.
	[pageBounds top <= geeMail bottom] whileTrue: [
		allPageRects add: pageBounds.
		pageBounds := pageBounds translateBy: 0 @ pageBounds height.
	].
	^allPageRects

]

{ #category : #initialization }
GeeBookMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	""
	newPagePrototype := GeeBookPageMorph new extent: Display extent // 3 
]

{ #category : #ui }
GeeBookMorph >> rebuildPages [

	pages := self geePageRectangles collect: [ :each |
		GeeBookPageMorph new 
			disableDragNDrop;
			geeMail: geeMail geeMailRectangle: each.
	].
	currentPage delete.
	currentPage := nil.
	pages isEmpty ifTrue: [^ self insertPage].
	self goToPage: 1.


]
