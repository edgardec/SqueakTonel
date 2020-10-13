"
an attempt to improve HtmlFormatter...
make it a bit more DOMish (eventually)

roadmap
-1-	support for font specs (color, size)
-2-	support for tabless
"
Class {
	#name : #DHtmlFormatter,
	#superclass : #HtmlFormatter,
	#instVars : [
		'fontSpecs'
	],
	#category : #'Etoys-Squeakland-Network-HTML-Formatter'
}

{ #category : #'formatting commands' }
DHtmlFormatter >> decreaseFontBy: relSize [
	self startFont: (TextFontChange fontNumber: ((self lastFontSize - relSize) min: 4))
]

{ #category : #'formatting commands' }
DHtmlFormatter >> endFont: aFont [
	fontSpecs isEmptyOrNil
		ifFalse: [fontSpecs removeLast].
	self setAttributes
]

{ #category : #'formatting commands' }
DHtmlFormatter >> endHeader: level [
	boldLevel := boldLevel - 1. "self decreaseBold"
	self ensureNewlines: 2.
	self endFont: nil.
]

{ #category : #'formatting commands' }
DHtmlFormatter >> headerFont: level [
	^{TextFontChange fontNumber: ((5 - level) max: 1)}
]

{ #category : #'formatting commands' }
DHtmlFormatter >> increaseFontBy: relSize [
	self startFont: (TextFontChange fontNumber: ((self lastFontSize + relSize) min: 4))
]

{ #category : #'formatting commands' }
DHtmlFormatter >> lastFontSize [
	| textAttrib |
	fontSpecs isEmptyOrNil ifTrue: [^1].

	fontSpecs reverseDo: [:specs |
		textAttrib := specs detect: [:attrib | attrib isKindOf: TextFontChange] ifNone: [].
		textAttrib ifNotNil: [^textAttrib fontNumber]].

	^1 "default font size in Squeak (1) corresponds to HTML's default 4"
]

{ #category : #'formatting commands' }
DHtmlFormatter >> resetFont [
	"probably need use document defaults"
	self startFont:
		{TextColor black.
		TextFontChange fontNumber: 1}
]

{ #category : #'private-formatting' }
DHtmlFormatter >> setAttributes [
	"set attributes on the output stream"
	| attribs |
	attribs := OrderedCollection new.
	indentLevel > 0 ifTrue: [ attribs add: (TextIndent tabs: indentLevel) ].
	boldLevel > 0 ifTrue: [ attribs add: TextEmphasis bold ].
	italicsLevel >  0 ifTrue: [ attribs add: TextEmphasis italic ].
	underlineLevel > 0 ifTrue: [ attribs add: TextEmphasis underlined ].
	strikeLevel > 0 ifTrue: [ attribs add: TextEmphasis struckOut ].
	urlLink isNil ifFalse: [ attribs add: (TextURL new url: urlLink) ].
	fontSpecs isEmptyOrNil
		ifFalse: [attribs addAll: fontSpecs last]
		ifTrue: [attribs add: (TextFontChange defaultFontChange)].
	outputStream currentAttributes: attribs
]

{ #category : #'formatting commands' }
DHtmlFormatter >> startFont: aTextAttribList [
	"aTextAttribList is a collection of TextAttributes"
	fontSpecs ifNil: [fontSpecs := OrderedCollection new].
	fontSpecs add: aTextAttribList.
	self setAttributes
]

{ #category : #'formatting commands' }
DHtmlFormatter >> startHeader: level [
	self ensureNewlines: 3.
	boldLevel := boldLevel + 1. "self increaseBold"
	self startFont: (self headerFont: level).
]
