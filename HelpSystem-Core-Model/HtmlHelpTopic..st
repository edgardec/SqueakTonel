Class {
	#name : #HtmlHelpTopic,
	#superclass : #AbstractHelpTopic,
	#instVars : [
		'url',
		'document',
		'selectBlock',
		'convertBlock',
		'subtopicUrls',
		'subtopics',
		'level'
	],
	#category : #'HelpSystem-Core-Model'
}

{ #category : #accessing }
HtmlHelpTopic >> contents [

	| start end |
	start := (self document findString: '<body').
	start := (self document findString: '>' startingAt: start) + 1.
	end := self document findString: '</body>' startingAt: start.
	
	start > end ifTrue: [^ self document].
	
	^ ((self document copyFrom: start to: end - 1)
		copyReplaceAll: String cr with: '<br>') 
		asTextFromHtml
]

{ #category : #accessing }
HtmlHelpTopic >> convertBlock [

	^ convertBlock ifNil: [ [:aUrl | aUrl] ]
]

{ #category : #accessing }
HtmlHelpTopic >> convertBlock: aBlock [

	convertBlock := aBlock.
]

{ #category : #accessing }
HtmlHelpTopic >> document [

	^ document ifNil: [document := 
		[
			(HTTPSocket httpGet: self url accept: 'text/html') contents
		] on: Error do: [:err | err printString]]
]

{ #category : #caching }
HtmlHelpTopic >> fetchSubtopics [
	"If this method is called from another process than the ui process, there will be no progress shown."

	| updateBlock |
	updateBlock := [:topic | topic document; subtopicUrls].

	Project current uiProcess == Processor activeProcess
		ifFalse: [self subtopics do: updateBlock]
		ifTrue: [self subtopics
			do: updateBlock
			displayingProgress: [:topic | 'Fetching documents ... ', topic url]].
]

{ #category : #testing }
HtmlHelpTopic >> hasSubtopics [

	^ self subtopicUrls notEmpty
]

{ #category : #testing }
HtmlHelpTopic >> isSearchable [

	^ self level < 2
]

{ #category : #accessing }
HtmlHelpTopic >> level [

	^ level ifNil: [level := 1]
]

{ #category : #accessing }
HtmlHelpTopic >> level: anInteger [

	level := anInteger.
]

{ #category : #accessing }
HtmlHelpTopic >> priorityForSearch [

	^ 999 "very late"
]

{ #category : #caching }
HtmlHelpTopic >> refresh [
	"Re-fetch document and all referenced urls."
	
	document := nil.
	subtopics := nil.
	
	self changed: #contents. "See #contents. It is based on document."
	self changed: #subtopics.
]

{ #category : #accessing }
HtmlHelpTopic >> selectBlock [

	^ selectBlock ifNil: [ [:aUrl | true] ]
]

{ #category : #accessing }
HtmlHelpTopic >> selectBlock: aBlock [
	"Which urls should be followed?"

	selectBlock := aBlock.
]

{ #category : #accessing }
HtmlHelpTopic >> subtopicUrls [

	^ subtopicUrls ifNil: [
		| start end endGuard |
		subtopicUrls := OrderedCollection new.

		start := self document findString: '<a '.
		start := self document findString: 'href' startingAt: start.
		[start > 0] whileTrue: [
			start := self document findString: '"' startingAt: start.
			end := self document findString: '"' startingAt: start+1.
			endGuard := self document findString: '>' startingAt: start+1.
			end > 0 ifTrue: [
				end < endGuard
					ifTrue: [subtopicUrls addIfNotPresent: (self document copyFrom: start+1 to: end-1)].
				start := self document findString: '<a ' startingAt: end+1].
			start > 0 ifTrue: [start := self document findString: 'href' startingAt: start]].

		subtopicUrls := subtopicUrls
			select: self selectBlock
			thenCollect: self convertBlock.
		subtopicUrls]
]

{ #category : #accessing }
HtmlHelpTopic >> subtopics [

	| start end urls |
	subtopics ifNotNil: [^ subtopics].
	
	urls := OrderedCollection new.
	
	start := self document findString: '<a '.
	[start > 0] whileTrue: [
		start := self document findString: 'href' startingAt: start.
		start := (self document findString: '"' startingAt: start) + 1.
		end := self document findString: '"' startingAt: start.
		urls addIfNotPresent: (self document copyFrom: start to: end - 1).
		start := self document findString: '<a ' startingAt: start.].
	
	subtopics := (self subtopicUrls collect: [:aUrl | self class new
			level: self level + 1;
			url: aUrl;
			selectBlock: self selectBlock;
			convertBlock: self convertBlock]).
		
	Project current uiProcess == Processor activeProcess
		ifTrue: [self fetchSubtopics].
	
	^ subtopics
]

{ #category : #accessing }
HtmlHelpTopic >> title [

	| start end |
	start := (self document findString: '<title') + 6.
	start := (self document findString: '>' startingAt: start) + 1.
	end := self document findString: '</title>' startingAt: start.
	
	start > end ifTrue: [^ self url asUrl authority].
	
	^ self document copyFrom: start to: end - 1
]

{ #category : #accessing }
HtmlHelpTopic >> url [

	^ url
]

{ #category : #accessing }
HtmlHelpTopic >> url: aString [

	url := aString.
]
