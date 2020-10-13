"
I represent a special type of Paragraph that is used in the list panes of a browser.  I  avoid all the composition done by more general Paragraphs, because I know the structure of my Text.
"
Class {
	#name : #ListParagraph,
	#superclass : #Paragraph,
	#category : #'ST80-Support'
}

{ #category : #initialization }
ListParagraph class >> cleanUp [
	"Re-initialize"

	self initialize.
]

{ #category : #style }
ListParagraph class >> standardListStyle [

	^ (TextStyle fontArray: { Preferences standardListFont })
			gridForFont: 1 withLead: 1;
			yourself
]

{ #category : #'instance creation' }
ListParagraph class >> withArray: anArray style: aTextStyleOrNil [
	"Convert an array of strings into a ListParagraph using the given TextStyle."

	aTextStyleOrNil
		ifNil: [^ (super withText: Text new style: self standardListStyle) withArray: anArray]
		ifNotNil: [^ (super withText: Text new style: aTextStyleOrNil) withArray: anArray].

]

{ #category : #composition }
ListParagraph >> composeAll [
	"No composition is necessary once the ListParagraph is created."
	
	lastLine isNil ifTrue: [lastLine := 0].	
		"Because composeAll is called once in the process of creating the ListParagraph."
	^compositionRectangle width
]

{ #category : #private }
ListParagraph >> trimLinesTo: lastLineInteger [
	"Since ListParagraphs are not designed to be changed, we can cut back the
		lines field to lastLineInteger."
	lastLine := lastLineInteger.
	lines := lines copyFrom: 1 to: lastLine
]

{ #category : #private }
ListParagraph >> withArray: anArray [ 
	"Modifies self to contain the list of strings in anArray"
	| startOfLine endOfLine lineIndex aString |
	lines := Array new: 20.
	lastLine := 0.
	startOfLine := 1.
	endOfLine := 1.
	lineIndex := 0.
	anArray do: 
		[:item | 
		endOfLine := startOfLine + item size.		"this computation allows for a cr after each line..."
												"...but later we will adjust for no cr after last line"
		lineIndex := lineIndex + 1.
		self lineAt: lineIndex put:
			((TextLineInterval start: startOfLine stop: endOfLine
				internalSpaces: 0 paddingWidth: 0)
				lineHeight: textStyle lineGrid baseline: textStyle baseline).
		startOfLine := endOfLine + 1].
	endOfLine := endOfLine - 1.		"endOfLine is now the total size of the text"
	self trimLinesTo: lineIndex.
	aString := String new: endOfLine.
	anArray with: lines do: 
		[:item :interval | 
		aString
			replaceFrom: interval first
			to: interval last - 1
			with: item asString
			startingAt: 1.
		interval last <= endOfLine ifTrue: [aString at: interval last put: Character cr]].
	lineIndex > 0 ifTrue: [(lines at: lineIndex) stop: endOfLine].	"adjust for no cr after last line"
	self text: aString asText.
	anArray with: lines do: 
		[:item :interval |  item isText ifTrue:
			[text replaceFrom: interval first to: interval last - 1 with: item]].
	self updateCompositionHeight
]
