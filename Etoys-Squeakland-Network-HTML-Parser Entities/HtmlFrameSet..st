Class {
	#name : #HtmlFrameSet,
	#superclass : #HtmlEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #categorization }
HtmlFrameSet >> isFrameSet [
	^true
]

{ #category : #testing }
HtmlFrameSet >> mayContain: anEntity [
	^true
]

{ #category : #lint }
HtmlFrameSet >> shouldContain: anEntity [
	^anEntity isFrame or: [ anEntity isFrameSet ]
]

{ #category : #testing }
HtmlFrameSet >> tagName [
	^'frameset'
]
