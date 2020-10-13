Class {
	#name : #HtmlBody,
	#superclass : #HtmlEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #attributes }
HtmlBody >> background [
	^self getAttribute: 'background' default: nil
]

{ #category : #attributes }
HtmlBody >> bgcolor [
	^self getAttribute: 'bgcolor' default: 'white'
]

{ #category : #testing }
HtmlBody >> mayContain: anEntity [
	"Body's can contain anything, so that even if we screw up the parsing, all the text will end up actually being included"
	^true
]

{ #category : #lint }
HtmlBody >> shouldContain: anEntity [
	"I don't *think* there are any elements that can be in both the header and the body..."
	^anEntity isHeadElement not
]

{ #category : #testing }
HtmlBody >> tagName [
	^'body'
]
