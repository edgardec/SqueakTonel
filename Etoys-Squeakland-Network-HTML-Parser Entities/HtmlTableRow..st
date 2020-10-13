Class {
	#name : #HtmlTableRow,
	#superclass : #HtmlEntity,
	#category : #'Etoys-Squeakland-Network-HTML-Parser Entities'
}

{ #category : #formatting }
HtmlTableRow >> addToFormatter: formatter [
	super addToFormatter: formatter.
	formatter ensureNewlines: 1.
]

{ #category : #accessing }
HtmlTableRow >> asArrayOfData [
	"Return an Array of the table row, removing all html.  This is only the text and numbers that the user would see on a web page.  Remove all comments and formatting."

	| cc |
	cc := contents select: [:ent | ent isTableDataItem].
	^ cc collect: [:ent | ent asHtml asUnHtml withBlanksTrimmed]
		"for now, leave the numbers as strings.  User will know which to convert"
]

{ #category : #testing }
HtmlTableRow >> isTableRow [
	^true
]

{ #category : #testing }
HtmlTableRow >> mayContain: anEntity [
	^anEntity isTableDataItem
]

{ #category : #testing }
HtmlTableRow >> tagName [
	^'tr'
]
