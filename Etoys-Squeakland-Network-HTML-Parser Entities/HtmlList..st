Class {
	#name : #HtmlList,
	#superclass : #HtmlBlockEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #testing }
HtmlList >> mayContain: anElement [
	"lists may only contain LI elements"
	"^anElement isListItem"

	"except that people write some sucky HTML out there!!  well, let's assume they always put the end tag.  Much safer assumption than that they only put list-items in their lists"
	^true
]

{ #category : #testing }
HtmlList >> shouldContain: anEntity [
	^anEntity isListItem
]
