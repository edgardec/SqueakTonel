"
An HTML tag, eg <a href=""foo.html"">
"
Class {
	#name : #HtmlTag,
	#superclass : #HtmlToken,
	#instVars : [
		'isNegated',
		'name',
		'attribs'
	],
	#classVars : [
		'EntityClasses'
	],
	#category : #'Etoys-Squeakland-Network-HTML-Tokenizer'
}

{ #category : #'parser support' }
HtmlTag class >> entityClasses [
	"a Dictionary mapping tag names into the correct entity class"
	"EntityClasses := nil"

	EntityClasses isNil ifFalse: [ ^EntityClasses ].

	EntityClasses := Dictionary new.

	#( 
		frameset	HtmlFrame
		frame	HtmlFrame

		title		HtmlTitle
		style	HtmlStyle
		meta	HtmlMeta

		p		HtmlParagraph
		form	HtmlForm
		blockquote	HtmlBlockQuote

		input	HtmlInput
		textarea	HtmlTextArea
		select	HtmlSelect
		optgroup	HtmlOptionGroup
		option		HtmlOption

		img		HtmlImage
		embed	HtmlEmbedded
		noembed	HtmlNoEmbed
		a		HtmlAnchor
		br		HtmlBreak

		map	HtmlMap
		area	HtmlArea

		li		HtmlListItem
		dd		HtmlDefinitionDefinition
		dt		HtmlDefinitionTerm

		ol		HtmlOrderedList
		ul		HtmlUnorderedList
		dl		HtmlDefinitionList

		h1		HtmlHeader
		h2		HtmlHeader
		h3		HtmlHeader
		h4		HtmlHeader
		h5		HtmlHeader
		h6		HtmlHeader

		hr		HtmlHorizontalRule

		strong	HtmlBoldEntity
		b		HtmlBoldEntity

		em		HtmlItalicsEntity
		i		HtmlItalicsEntity
		dfn 	HtmlItalicsEntity

		u		HtmlUnderlineEntity 

		tt		HtmlFixedWidthEntity
		kbd		HtmlFixedWidthEntity		

		strike	HtmlStrikeEntity

		big		HtmlBiggerFontEntity
		small	HtmlSmallerFontEntity

		sub		HtmlSubscript
		sup		HtmlSuperscript

		font	HtmlFontEntity

		pre		HtmlPreformattedRegion
 
		table	HtmlTable
		tr		HtmlTableRow
		td		HtmlTableDataItem 
		th		HtmlTableHeader
		) pairsDo: [ 
			:tagName :className |
			EntityClasses at: tagName asString put: (Smalltalk at: className) ].

	^EntityClasses 
]

{ #category : #'parser support' }
HtmlTag class >> initialize [
	"HtmlTag initialize"
	EntityClasses := nil.
]

{ #category : #'instance creation' }
HtmlTag class >> source: source0  name: name0  negated: negated0 attribs: attribs0 [
	^(super forSource: source0) name: name0 negated: negated0 attribs: attribs0
]

{ #category : #access }
HtmlTag >> attribs [
	"return a dictionary mapping attribute names (in lowercase) to their values"
	^attribs

]

{ #category : #'parser support' }
HtmlTag >> entityFor [
	"return an empty entity corresponding to this tag"
	| eClass |
	eClass := self class entityClasses at: name ifAbsent: [ ^nil ].
	^eClass forTag: self 
]

{ #category : #access }
HtmlTag >> isNegated [
	^isNegated
]

{ #category : #properties }
HtmlTag >> isTag [
	^true
]

{ #category : #access }
HtmlTag >> name [
	"return the basic kind of tag, in lowercase"
	^name

]

{ #category : #'private-initialization' }
HtmlTag >> name: name0  negated: isNegated0 attribs: attribs0 [
	"initialize from the given attributes"
	name := name0.
	isNegated := isNegated0.
	attribs := attribs0 ifNil: [Dictionary new]
]
