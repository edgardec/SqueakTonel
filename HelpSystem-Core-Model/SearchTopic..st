Class {
	#name : #SearchTopic,
	#superclass : #AbstractHelpTopic,
	#instVars : [
		'term',
		'process',
		'results',
		'resultText',
		'topicsToSearch',
		'mutex',
		'updatePending'
	],
	#category : #'HelpSystem-Core-Model'
}

{ #category : #comparing }
SearchTopic >> <= anotherHelpTopic [

	^ true "Keep insertion order in parent topic."
]

{ #category : #accessing }
SearchTopic >> contents [

	^ resultText ifNil: [self updateResultText]
]

{ #category : #searching }
SearchTopic >> find: term in: path results: results [

	| resultTemplate c topic | 
	topic := path last.
	resultTemplate := Array new: 6. 
	(topic title asString findString: term startingAt: 1 caseSensitive: false) in: [:index |
		index > 0 ifTrue: [resultTemplate at: 2 put: (index to: index + term size)]].
		
	((c := topic contents asString withSqueakLineEndings) findString: term startingAt: 1 caseSensitive: false) in: [:index |
		index > 0 ifTrue: [
			| leadingContext trailingContext i |
			leadingContext := 0.
			trailingContext := 0.
			i := index.
			[i notNil] whileTrue: [
				(leadingContext = 2 or: [i = 1])
					ifTrue: [
						leadingContext := i = 1 ifTrue: [i] ifFalse: [i+1].
						i := nil]
					ifFalse: [
						((c at: i) = Character cr) ifTrue: [
							leadingContext := leadingContext + 1].
							i := i - 1] ].
			i := index + term size.
			[i notNil] whileTrue: [
				(trailingContext = 2 or: [i >= c size])
					ifTrue: [
						trailingContext := i = c size ifTrue: [i] ifFalse: [i-1].
						i := nil]
					ifFalse: [
						((c at: i) = Character cr) ifTrue: [
							trailingContext := trailingContext + 1].
							i := i + 1] ].
			
			resultTemplate
				at: 1 put: path;
				at: 3 put: (index - leadingContext + 1 to: index - leadingContext + term size);
				at: 4 put: (c copyFrom: leadingContext to: trailingContext);
				at: 5 put: leadingContext;
				at: 6 put: (index to: index + term size - 1).
				
				self mutex critical: [ results add: resultTemplate ].
				self triggerUpdateContents.
				
				] ].
	
	topic isSearchable ifTrue: [
		topic subtopics do: [:t | self find: term in: path, {t} results: results]].
]

{ #category : #private }
SearchTopic >> mutex [

	^ mutex ifNil: [mutex := Mutex new]
]

{ #category : #private }
SearchTopic >> printResultEntry: entry [

	| resultEntry topic |
	resultEntry := '' asText.
	topic := entry first last.
	
	entry second notNil
		ifFalse: [resultEntry append: (
			(topic title) asText
				addAttribute: TextEmphasis bold)]
		ifTrue: [resultEntry append: (
			(topic title) asText
				addAttribute: TextEmphasis bold;
				addAttribute: (TextColor color: Color green muchDarker)
				from: entry second first
				to: entry second last)].

	resultEntry append: ('  (open topic)' asText
		addAttribute: (PluggableTextAttribute evalBlock: [
			self changed: #searchResultSelected with: entry first.
			self changed: #searchResultContentsSelected with: entry sixth])).
	
	resultEntry append: String cr.
	
	entry fourth in: [:contents |
		| text |
		text := contents asText.
		text
			addAttribute: (TextColor color: Color green muchDarker)
			from: entry third first
			to: entry third last;
			addAttribute: TextEmphasis bold
			from: entry third first
			to: entry third last.
		resultEntry
			append: text withBlanksTrimmed;
			append: '\\' withCRs.
		
		].
	
	^ resultEntry
]

{ #category : #private }
SearchTopic >> startSearch [

	self stopSearch.
	results := OrderedCollection new.
	
	self topicsToSearch ifEmpty: [
		self changed: #contents.
		^ self].
	
	process := [
		
		(self topicsToSearch
			sorted: [:t1 :t2 | t1 priorityForSearch <= t2 priorityForSearch])
			do: [:topic |
				| nestedResults  |
				nestedResults := OrderedCollection new.
				self mutex critical: [results add: topic -> nestedResults].
				self find: self term in: {topic} results: nestedResults].
		
		results add: 'Search finished.'.
		self triggerUpdateContents.
	
	] forkAt: 35.
]

{ #category : #private }
SearchTopic >> stopSearch [

	process ifNotNil: #terminate.
	process := nil.
]

{ #category : #accessing }
SearchTopic >> term [

	^ term
]

{ #category : #accessing }
SearchTopic >> term: aString [

	term := aString.
]

{ #category : #accessing }
SearchTopic >> title [

	^ '''', self term, ''''
]

{ #category : #accessing }
SearchTopic >> topicsToSearch [

	^ topicsToSearch ifNil: [#()]
]

{ #category : #accessing }
SearchTopic >> topicsToSearch: someTopics [

	topicsToSearch := someTopics.
]

{ #category : #private }
SearchTopic >> triggerUpdateContents [

	self mutex critical: [
		updatePending == true ifFalse: [
			updatePending := true.
			Project current addDeferredUIMessage: [Project current world
				addAlarm: #updateContents withArguments: #()
				for: self
				at: Time millisecondClockValue + 250]]].
]

{ #category : #private }
SearchTopic >> updateContents [

	self mutex critical: [ updatePending := false ].

	resultText := nil.
	self changed: #contents with: self.
]

{ #category : #private }
SearchTopic >> updateResultText [

	resultText := '' asText.
	
	self mutex critical: [
		results ifNil: [^ resultText].
		results do: [:topicToResult |
			topicToResult isString
				ifTrue: [resultText append: (
					(topicToResult, String cr) asText
						addAttribute: (TextColor color: (Color gray: 0.7));
						yourself)]
				ifFalse: [
					resultText append: (
						('\----- Matches found in ''', topicToResult key title, ''' -----\\') withCRs asText
							addAttribute: (TextColor color: (Color gray: 0.7))).
					topicToResult value do: [:entry |
						resultText append: (self printResultEntry: entry)] 
						]]].
	
	^ resultText
]
