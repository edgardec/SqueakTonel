"
A HelpBrowser is used to display a hierarchy of help topics and their contents.

Instance Variables
	rootTopic: 		<HelpTopic>
	window:			<StandardWindow>	 
	treeMorph:		<PluggableTreeMorph>
	contentMorph:		<Morph>			

rootTopic
	- xxxxx

window
	- xxxxx

treeMorph 
	- xxxxx

contentMorph 
	- xxxxx


"
Class {
	#name : #HelpBrowser,
	#superclass : #Model,
	#instVars : [
		'rootTopic',
		'currentTopic',
		'currentParentTopic',
		'result',
		'searchTopic',
		'topicPath',
		'toplevelTopics',
		'oldTopic',
		'topicContentsSelection',
		'isUpdating'
	],
	#classVars : [
		'DefaultHelpBrowser'
	],
	#category : #'HelpSystem-Core-UI'
}

{ #category : #accessing }
HelpBrowser class >> defaultHelpBrowser [
	DefaultHelpBrowser isNil ifTrue: [DefaultHelpBrowser := self].
	^DefaultHelpBrowser
	
]

{ #category : #accessing }
HelpBrowser class >> defaultHelpBrowser: aClass [
	"Use a new help browser implementation"
	
	DefaultHelpBrowser := aClass
	
]

{ #category : #'class initialization' }
HelpBrowser class >> initialize [
	"Initializes the receiver class"
 
	 TheWorldMenu registerOpenCommand: {'Help Browser'. {self. #open}}. 
]

{ #category : #'instance creation' }
HelpBrowser class >> open [

	| window |
	window := self openOn: CustomHelp.
	window model showFirstTopic.
	^ window
]

{ #category : #'instance creation' }
HelpBrowser class >> openOn: aHelpTopic [
        "Open the receiver on the given help topic or any other object that can be transformed into
         a help topic by sending #asHelpTopic."
        
        ^(self defaultHelpBrowser new)
                rootTopic: aHelpTopic;
                open
]

{ #category : #styling }
HelpBrowser >> aboutToStyle: aStyler [

	^ self currentTopic
		ifNil: [false]
		ifNotNil: [:topic | topic usesCodeStyling]
]

{ #category : #actions }
HelpBrowser >> accept: text [
	"Accept edited text. Compile it into a HelpTopic"

	| parent currentKey normalizedText colorsToRemove |
	((self currentParentTopic isNil or: [self currentParentTopic isEditable not])
		or: [self currentTopic isEditable not])
			ifTrue: [^ self inform: 'This help topic cannot be edited.'].
	
	self changed: #clearUserEdits.
	
	"Remove default colors for the sake of UI themes."
	normalizedText := text.
	colorsToRemove := {Color black. Color white}.
	normalizedText runs: (normalizedText runs collect: [:attributes | attributes reject: [:attribute |
			(((attribute respondsTo: #color) and: [colorsToRemove includes: attribute color])
				or: [attribute respondsTo: #font])]]).

	parent := self currentParentTopic.
	currentKey := self currentTopic key.

	isUpdating := true.

	parent accept: normalizedText for: self currentTopic.
	parent refresh.
	parent == self rootTopic ifTrue: [self rootTopic: parent].
	
	isUpdating := false.
	
	self currentTopic: (parent subtopics detect: [:t | t key = currentKey]).
]

{ #category : #toolbuilder }
HelpBrowser >> buildCodeContentsWith: builder [

	^ builder pluggableCodePaneSpec new
		model: self;
		getText: #topicContents;
		setText: #accept:;
		menu: #codePaneMenu:shifted:;
		softLineWrap: false;
		frame: (LayoutFrame
			fractions: (0.3@0.0 corner: 1@1)
			offsets: (0@ (Preferences standardDefaultTextFont height * 2) corner: 0@0));
		yourself
]

{ #category : #toolbuilder }
HelpBrowser >> buildContentsWith: builder [

	^ builder pluggableTextSpec new
		model: self;
		getText: #topicContents;
		setText: #accept:;
		selection: #topicContentsSelection;
		menu: #codePaneMenu:shifted:;
		frame: (LayoutFrame
			fractions: (0.3@0.0 corner: 1@1)
			offsets: (0@ (Preferences standardDefaultTextFont height * 2) corner: 0@0));
		yourself
]

{ #category : #toolbuilder }
HelpBrowser >> buildSearchWith: builder [

	^ builder pluggableInputFieldSpec new
		model: self;
		getText: #searchTerm;
		setText: #searchTerm:;
		help: 'Search...';
		askBeforeDiscardingEdits: false;
		indicateUnacceptedChanges: false;
		frame: (LayoutFrame
			fractions: (0@0 corner: 1@0)
			offsets: (0@0 corner: 0@ (Preferences standardDefaultTextFont height * 2)));
		yourself
]

{ #category : #toolbuilder }
HelpBrowser >> buildTreeWith: builder [

	^ builder pluggableTreeSpec new
		model: self;
		nodeClass: HelpTopicListItemWrapper;
		roots: #toplevelTopics;
		getSelected: #currentTopic;
		setSelected: #currentTopic:;
		getSelectedPath: #currentTopicPath;
		setSelectedPath: #noteTopicPath:;
		setSelectedParent: #currentParentTopic:;
		autoDeselect: false;
		frame: (LayoutFrame
			fractions: (0@0 corner: 0.3@1)
			offsets: (0@ (Preferences standardDefaultTextFont height * 2) corner: 0@0));
		yourself
]

{ #category : #toolbuilder }
HelpBrowser >> buildWith: builder [

	| windowSpec |
	windowSpec := self buildWindowWith: builder.
	
	windowSpec children
		add: (self buildSearchWith: builder);
		add: (self buildTreeWith: builder);
		add: ( (rootTopic notNil and:[
			rootTopic usesCodeStyling])
				ifTrue:[self buildCodeContentsWith: builder]
				ifFalse:[self buildContentsWith: builder]).

	^ builder build: windowSpec
]

{ #category : #updating }
HelpBrowser >> changed: aspect [

	(isUpdating == true and: [aspect == #topicContents]) ifTrue: [^ self].
	super changed: aspect.
]

{ #category : #events }
HelpBrowser >> codePaneMenu: aMenu shifted: shifted [
	^ StringHolder basicNew codePaneMenu: aMenu shifted: shifted

]

{ #category : #accessing }
HelpBrowser >> currentParentTopic [

	^ currentParentTopic
]

{ #category : #accessing }
HelpBrowser >> currentParentTopic: aHelpTopic [

	currentParentTopic := aHelpTopic ifNil: [self rootTopic].
]

{ #category : #accessing }
HelpBrowser >> currentTopic [

	^ currentTopic
]

{ #category : #accessing }
HelpBrowser >> currentTopic: aHelpTopic [

	self okToChange ifFalse: [^ self].
	self currentTopic == aHelpTopic ifTrue: [^ self].

	((self currentTopic notNil
		and: [aHelpTopic notNil])
		and: [self currentTopic key ~= aHelpTopic key]) ifTrue: [
			"Clear selection, we have new contents."
			self topicContentsSelection: (1 to: 0)].
	
	currentTopic := aHelpTopic.
	topicPath := nil.
	topicContentsSelection := nil.
	
	self changed: #currentTopic.
	self changed: #topicContents.
	self changed: #showContents.
]

{ #category : #accessing }
HelpBrowser >> currentTopicPath [

	^ topicPath ifNil: [#()]
]

{ #category : #accessing }
HelpBrowser >> currentTopicPath: someTopics [
	"Use the tree structure to select a nested topic."
	
	topicPath := someTopics.
	self changed: #currentTopicPath.
]

{ #category : #enumerating }
HelpBrowser >> detect: block ifFound: foundBlock [

	self do: [:topic :path | (block value: topic)
		ifTrue: [foundBlock cull: topic cull: path. ^ topic]].
]

{ #category : #enumerating }
HelpBrowser >> do: block [

	self do: block in: self toplevelTopics path: #().
]

{ #category : #enumerating }
HelpBrowser >> do: block in: topics path: path [

	topics do: [:topic |
		block cull: topic cull: path.
	
		topic hasSubtopics ifTrue: [
			self do: block in: topic subtopics path: path, {topic}]].
]

{ #category : #events }
HelpBrowser >> menu: aMenu [ 
	^aMenu add: 'find...' translated action: #find.
	
	

]

{ #category : #accessing }
HelpBrowser >> noteTopicPath: someTopics [
	"Keep track of the current topic path as reported by the view through manual selection."

	topicPath := someTopics.
	self changed: #windowTitle.

]

{ #category : #updating }
HelpBrowser >> okToChange [

	self canDiscardEdits ifTrue: [^ true].
	self changed: #wantToChange.  "Solicit cancel from view"
	^ self canDiscardEdits
]

{ #category : #ui }
HelpBrowser >> open [	

	^ ToolBuilder open: self
]

{ #category : #ui }
HelpBrowser >> representsSameBrowseeAs: anotherModel [
	^ self hasUnacceptedEdits not and:
		[ (toplevelTopics collect:
			[ : e | e title ]) =
			(anotherModel toplevelTopics collect:
				[ : e | e title ]) ]
]

{ #category : #accessing }
HelpBrowser >> rootTopic [
	^rootTopic
]

{ #category : #accessing }
HelpBrowser >> rootTopic: aHelpTopic [
	"set the root topic and work out the top level sub-topics that it implies. Add the search topic at the end of the list"
	rootTopic := aHelpTopic asHelpTopic. 
	
	self toplevelTopics: ((rootTopic ifNil: [#()] ifNotNil: [rootTopic subtopics ifEmpty: [{rootTopic}]]) sorted, {self searchTopic}).
	self changed: #windowTitle.
]

{ #category : #searching }
HelpBrowser >> searchTerm [

	^ '' "Reset. Terms are cached in SearchTopic instances."
]

{ #category : #searching }
HelpBrowser >> searchTerm: aTextOrString [
	"Spawn a new search topic."	

	| topic term |
	self okToChange ifFalse: [^ self].
	
	term := aTextOrString asString.
	topic := self searchTopic subtopics
		detect: [:t | t term = term]
		ifNone: [ | newTopic |
			newTopic := SearchTopic new
				term: term;
				yourself.
			self searchTopic addSubtopic: newTopic.
			newTopic addDependent: self. "Tell me about your updates."
			newTopic].
		
	"self changed: #searchTerm."
	
	"Select results and expand searches node if necessary."
	self currentTopicPath: {self searchTopic. topic}.
	self assert: self currentTopic == topic.
	
	topic
		topicsToSearch: self toplevelTopics allButLast;
		startSearch.
]

{ #category : #searching }
HelpBrowser >> searchTopic [

	^ searchTopic ifNil: [searchTopic := HelpTopic new
		title: 'Search Results';
		addDependent: self;
		yourself]
]

{ #category : #actions }
HelpBrowser >> showFirstTopic [
	"Shows the first topic that has contents."
	
	self showTopicThat: [:topic | topic contents notEmpty].
]

{ #category : #actions }
HelpBrowser >> showTopicNamed: key [

	self showTopicThat: [:topic | topic key = key].
]

{ #category : #actions }
HelpBrowser >> showTopicThat: block [

	self
		detect: [:topic | block value: topic]
		ifFound: [:topic :path | self currentTopicPath: path, {topic}].
]

{ #category : #'accessing - ui' }
HelpBrowser >> topicContents [

	^ (self currentTopic ifNil: [self rootTopic]) ifNil: '' ifNotNil: #contents
]

{ #category : #'accessing - ui' }
HelpBrowser >> topicContentsSelection [

	^ topicContentsSelection
]

{ #category : #'accessing - ui' }
HelpBrowser >> topicContentsSelection: anInterval [

	topicContentsSelection := anInterval.
	self changed: #topicContentsSelection.
]

{ #category : #accessing }
HelpBrowser >> toplevelTopics [

	^ toplevelTopics ifNil: [#()]
]

{ #category : #accessing }
HelpBrowser >> toplevelTopics: someTopics [

	toplevelTopics := someTopics.
	self changed: #toplevelTopics.
]

{ #category : #updating }
HelpBrowser >> update: aspect with: object [

	aspect == #contents ifTrue: [
		object == self currentTopic ifTrue: [self changed: #topicContents]].
	aspect == #searchResultSelected ifTrue: [
		self currentTopicPath: object].
	aspect == #searchResultContentsSelected ifTrue: [
		self topicContentsSelection: object].
]

{ #category : #updating }
HelpBrowser >> windowIsClosing [

	super windowIsClosing.
	
	self searchTopic subtopics do: [:topic |
		topic stopSearch].
]

{ #category : #'accessing - ui' }
HelpBrowser >> windowTitle [

	^ '{1}: {2}' format: {
		self rootTopic
			ifNil: ['Help Browser' translated]
			ifNotNil: [:topic | topic title].
		(self currentTopicPath collect: [:topic | topic title])
			reversed joinSeparatedBy: ' > '}
]
