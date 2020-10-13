Class {
	#name : #MCSnapshotBrowser,
	#superclass : #MCCodeTool,
	#instVars : [
		'categorySelection',
		'classSelection',
		'protocolSelection',
		'methodSelection',
		'switch'
	],
	#category : #'Monticello-UI'
}

{ #category : #'instance creation' }
MCSnapshotBrowser class >> forSnapshot: aSnapshot [
	^ self new snapshot: aSnapshot
]

{ #category : #styling }
MCSnapshotBrowser >> aboutToStyle: aStyler [
	
	| classDefinition shouldStyle |
	classSelection ifNil: [ ^false ].
	self switchIsComment ifTrue: [ ^false ].
	methodSelection 
		ifNotNil: [ 
			classDefinition := items 
				detect: [:ea | 
					ea isClassDefinition and: [ ea className = classSelection ] ]
				ifNone: [ 
					(Smalltalk at: classSelection ifAbsent: [ Object ]) asClassDefinition ].
			shouldStyle := true ]
		ifNil: [ 
			classDefinition := nil.
			shouldStyle := categorySelection ~= self extensionsCategory ].
	(Smalltalk classNamed: #SHMCClassDefinition) 
		ifNil: [ ^false ]
		ifNotNil: [ :SHMCClassDefinition |
			aStyler 
				environment: self;
				classOrMetaClass: (classDefinition ifNotNil: [
					SHMCClassDefinition 
						classDefinition: classDefinition 
						items: items 
						meta: switch = #class ]) ].
	^shouldStyle
]

{ #category : #accessing }
MCSnapshotBrowser >> allClassNames [
	^ (items 
		select: [:ea | (ea isOrganizationDefinition | ea isScriptDefinition) not] 
		thenCollect: [:ea | ea className]) asSet.

]

{ #category : #text }
MCSnapshotBrowser >> annotations [
	methodSelection ifNotNil: [^ methodSelection annotations ].
	^ ''
]

{ #category : #text }
MCSnapshotBrowser >> annotations: stuff [
	self changed: #annotations
]

{ #category : #binding }
MCSnapshotBrowser >> bindingOf: aSymbol [

	(Smalltalk bindingOf: aSymbol) ifNotNil: [ :binding | ^binding ].
	items do: [ :each |
		(each isClassDefinition and: [
			each className = aSymbol ]) ifTrue: [ ^aSymbol -> each ] ].
	^nil
]

{ #category : #'morphic ui' }
MCSnapshotBrowser >> buttonSpecs [
	^ #(('instance' switchBeInstance 'show instance' buttonEnabled switchIsInstance)
		('?' switchBeComment 'show comment' buttonEnabled switchIsComment)
		('class' switchBeClass 'show class' buttonEnabled switchIsClass))
]

{ #category : #listing }
MCSnapshotBrowser >> categoryList [
	^ self visibleCategories
]

{ #category : #menus }
MCSnapshotBrowser >> categoryListMenu: aMenu [ 
	categorySelection
		ifNotNil: [aMenu
				add: (categorySelection = '*Extensions'
						ifTrue: ['load all extension methods' translated]
						ifFalse: ['load class category {1}' translated format: {categorySelection}])
				action: #loadCategorySelection].
	^ aMenu
]

{ #category : #selecting }
MCSnapshotBrowser >> categorySelection [
	^ categorySelection ifNil: [0] ifNotNil: [self visibleCategories indexOf: categorySelection]
]

{ #category : #selecting }
MCSnapshotBrowser >> categorySelection: aNumber [
	categorySelection := aNumber = 0 ifFalse: [self visibleCategories at: aNumber].
	self classSelection: 0.
	self changed: #categorySelection;
		changed: #annotations;
		changed: #classList.

]

{ #category : #text }
MCSnapshotBrowser >> classCommentString [
	^ (items 
		detect: [:ea | ea isClassDefinition and: [ea className = classSelection]]
		ifNone: [^ '']) comment.
]

{ #category : #text }
MCSnapshotBrowser >> classDefinitionString [
	| defs |
	defs := items select: [:ea | (ea isClassDefinition or: [ea isClassDefinitionExtension])
			and: [ea className = classSelection]].

	defs isEmpty ifTrue: [^ 'This class is defined elsewhere.'].

	^ String streamContents: [:stream | 
		defs asArray sort 
			do: [:ea | ea printDefinitionOn: stream]
			separatedBy: [stream nextPut: $.; cr]
	].
]

{ #category : #listing }
MCSnapshotBrowser >> classList [
	^ categorySelection = self extensionsCategory
		ifTrue: [self labeledClassnames: self visibleClasses]
		ifFalse: [self visibleClasses]
]

{ #category : #menus }
MCSnapshotBrowser >> classListMenu: aMenu [ 
	classSelection ifNil: [ ^aMenu ].

	super classListMenu: aMenu.

	aMenu
		addLine;
				add: ('load class {1}' translated format: {classSelection})
				action: #loadClassSelection;
				add: ('load class {1} into other Environment...' translated format: {classSelection})
				action: #loadClassSelectionIntoOtherEnvironment.
	^ aMenu
]

{ #category : #selecting }
MCSnapshotBrowser >> classSelection [
	^ classSelection ifNil: [0] ifNotNil: [self visibleClasses indexOf: classSelection]
]

{ #category : #selecting }
MCSnapshotBrowser >> classSelection: aNumber [
	classSelection := aNumber = 0 ifFalse: [self visibleClasses at: aNumber].
	self protocolSelection: 0.
	self changed: #classSelection;  changed: #protocolList.
	(self protocolList size = 1
	 and: [self protocolList first first = $*])
		ifTrue:
			[self protocolSelection: 1]
		ifFalse:
			[self changed: #annotations;
				changed: #methodList]

]

{ #category : #'morphic ui' }
MCSnapshotBrowser >> defaultExtent [
	^ 650@400.
]

{ #category : #'morphic ui' }
MCSnapshotBrowser >> defaultLabel [
	^ 'Snapshot Browser'
]

{ #category : #accessing }
MCSnapshotBrowser >> extensionClassNames [
	^ (self allClassNames difference: self packageClassNames) sorted
]

{ #category : #accessing }
MCSnapshotBrowser >> extensionsCategory [
	^ '*Extensions'
]

{ #category : #menus }
MCSnapshotBrowser >> fileOutMessage [
	"Put a description of the selected message on a file"

	| definitions wildcard |
	wildcard := protocolSelection = '-- all --'.
	definitions := methodSelection
					ifNotNil: [{methodSelection}]
					ifNil: [items select:
							[:item|
							item isMethodDefinition
							and: [item className = classSelection
							and: [wildcard or: [item protocol = protocolSelection]]]]].
	definitions isEmpty ifTrue:
		[^self].
	FileStream
		writeSourceCodeFrom: ((MCStWriter on: (WriteStream on: (String new: 100)))
									writeDefinitions: (definitions);
									stream)
		baseName: (methodSelection
						ifNil: [categorySelection, '-', classSelection, (wildcard ifTrue: [''] ifFalse: ['-', protocolSelection])]
						ifNotNil: [methodSelection actualClass name, '-', (methodSelection selector copyReplaceAll: ':' with: '')])
		isSt: true
		useHtml: false
]

{ #category : #accessing }
MCSnapshotBrowser >> hasExtensions [
	^self extensionClassNames notEmpty
]

{ #category : #menus }
MCSnapshotBrowser >> inspectSelection [
	^ self methodSelection inspect
]

{ #category : #private }
MCSnapshotBrowser >> labeledClassnames: classNames [
	| methodClassification |
	methodClassification := Dictionary new.
	items do: [:def | def isMethodDefinition ifTrue: [
		(methodClassification at: def className ifAbsentPut: [Set new])
			add: (def classIsMeta ifFalse: [$i] ifTrue: [$c])]].
	^ classNames collect: [:className |
		String streamContents: [:s |
			s nextPutAll: className; space.
			(methodClassification at: className)
				do: [:each | each = $i
					ifTrue: [s nextPutAll: '*inst']
					ifFalse: [s nextPutAll: '*class']]
				separatedBy: [s nextPut: $,]]]

]

{ #category : #menus }
MCSnapshotBrowser >> loadCategorySelection [
	"Load the entire selected category"
	categorySelection ifNil: [ ^self ].
	self methodsForSelectedClassCategory do: [ :m | m load ].
]

{ #category : #menus }
MCSnapshotBrowser >> loadClassSelection [
	classSelection ifNil: [ ^self ].
	(self packageClasses detect: [ :ea | ea className = classSelection ] ifNone: [ ^self ]) load.
	self methodsForSelectedClass do: [ :m | m load ].
]

{ #category : #menus }
MCSnapshotBrowser >> loadClassSelectionIntoOtherEnvironment [
	| env |
	classSelection ifNil: [ ^self ].
	env := EnvironmentRequest signal.
	env beCurrentDuring: [
		(self packageClasses detect: [ :ea | ea className = classSelection ] ifNone: [ ^self ])
			load.
		self methodsForSelectedClass do: [ :m | m load ]].
]

{ #category : #menus }
MCSnapshotBrowser >> loadMethodSelection [
	methodSelection ifNil: [ ^self ].
	methodSelection load.
]

{ #category : #menus }
MCSnapshotBrowser >> loadProtocolSelection [
	protocolSelection ifNil: [ ^self ].
	self methodsForSelectedProtocol do: [ :m | m load ].
]

{ #category : #listing }
MCSnapshotBrowser >> methodList [
	^ self visibleMethods collect: [:ea | ea selector]
]

{ #category : #menus }
MCSnapshotBrowser >> methodListMenu: aMenu [ 
	super methodListMenu: aMenu.
	self selectedMessageName
		ifNotNil: [:msgName | aMenu addLine; add: 'load method' translated action: #loadMethodSelection].
	^ aMenu
]

{ #category : #selecting }
MCSnapshotBrowser >> methodSelection [
	^ methodSelection
			ifNil: [0] 
			ifNotNil: [self visibleMethods indexOf: methodSelection]
]

{ #category : #selecting }
MCSnapshotBrowser >> methodSelection: aNumber [
	methodSelection := aNumber = 0 ifFalse: [self visibleMethods at: aNumber].
	self changed: #methodSelection; changed: #text; changed: #annotations
]

{ #category : #accessing }
MCSnapshotBrowser >> methodsForSelectedClass [
	^ items select:
		[ : ea | ea className = classSelection and: [ ea isMethodDefinition ] ]
]

{ #category : #accessing }
MCSnapshotBrowser >> methodsForSelectedClassAndMetaSelection [
	^ self methodsForSelectedClass select:
		[ : each | each classIsMeta = self switchIsClass ]
]

{ #category : #accessing }
MCSnapshotBrowser >> methodsForSelectedClassCategory [
	^ items select:
		[ : ea | (self visibleClasses includes: ea className) and: [ ea isMethodDefinition ] ]
]

{ #category : #accessing }
MCSnapshotBrowser >> methodsForSelectedProtocol [
	| methods |
	protocolSelection ifNil: [^ Array empty].
	methods := self methodsForSelectedClassAndMetaSelection asOrderedCollection.
	(protocolSelection = '-- all --') 
		ifFalse: [methods removeAllSuchThat: [:ea | ea category ~= protocolSelection]].
	^ methods 
	
								
]

{ #category : #accessing }
MCSnapshotBrowser >> packageClassNames [
	^ self packageClasses collect: [:ea | ea className]
]

{ #category : #accessing }
MCSnapshotBrowser >> packageClasses [
	^ items select: [:ea | ea isClassDefinition]
]

{ #category : #accessing }
MCSnapshotBrowser >> packageOrganizations [
	^ items select: [:ea | ea isOrganizationDefinition]
]

{ #category : #listing }
MCSnapshotBrowser >> protocolList [
	^ self visibleProtocols
]

{ #category : #menus }
MCSnapshotBrowser >> protocolListMenu: aMenu [ 
	protocolSelection
		ifNotNil: [aMenu
				add: ('load protocol ''{1}''' translated format: {protocolSelection})
				action: #loadProtocolSelection ].
	^ aMenu
]

{ #category : #selecting }
MCSnapshotBrowser >> protocolSelection [
	^ protocolSelection 
		ifNil: [0]
		ifNotNil: [self visibleProtocols indexOf: protocolSelection]
]

{ #category : #selecting }
MCSnapshotBrowser >> protocolSelection: anInteger [
	protocolSelection := (anInteger = 0 ifFalse: [self visibleProtocols at: anInteger]).
	self methodSelection: 0.
	self changed: #protocolSelection;
		changed: #methodList;	
		changed: #annotations
]

{ #category : #text }
MCSnapshotBrowser >> scriptDefinitionString [
	| defs |
	defs := items select: [:ea | ea isScriptDefinition].
	defs isEmpty ifTrue: [^'(package defines no scripts)'].
	
	^ String streamContents: [:stream | 
		defs asArray sort 
			do: [:ea | stream nextPutAll: '---------- package ';
					nextPutAll: ea scriptSelector;
					nextPutAll: ' ----------'; cr;
					nextPutAll: ea script; cr]
			separatedBy: [stream cr]].
]

{ #category : #accessing }
MCSnapshotBrowser >> selectedClass [
	| environment |
	classSelection ifNil: [ ^nil ].
	environment := self environmentInDisplayingImage.
	^ environment at: classSelection ifAbsent: [environment valueOf: classSelection]

]

{ #category : #accessing }
MCSnapshotBrowser >> selectedClassOrMetaClass [
	| class |
	classSelection ifNil: [ ^nil ].
	class := Smalltalk at: classSelection ifAbsent: [ ^nil ].
	^self switchIsClass ifTrue: [ class class ]
		ifFalse: [ class ].
]

{ #category : #accessing }
MCSnapshotBrowser >> selectedMessageCategoryName [
	^protocolSelection
]

{ #category : #accessing }
MCSnapshotBrowser >> selectedMessageName [
	^methodSelection ifNotNil: [^ methodSelection selector ].

]

{ #category : #switch }
MCSnapshotBrowser >> signalSwitchChanged [
	self protocolSelection: 0.
	self 
		changed: #switchIsInstance;
		changed: #switchIsComment;
		changed: #switchIsClass;
		changed: #protocolList;
		changed: #methodList;
		changed: #text.
]

{ #category : #accessing }
MCSnapshotBrowser >> snapshot: aSnapshot [
	items := aSnapshot definitions sorted.
	self categorySelection: 0.
]

{ #category : #switch }
MCSnapshotBrowser >> switchBeClass [
	switch := #class.
	self signalSwitchChanged.
]

{ #category : #switch }
MCSnapshotBrowser >> switchBeComment [
	switch := #comment.
	self signalSwitchChanged.
]

{ #category : #switch }
MCSnapshotBrowser >> switchBeInstance [
	switch := #instance.
	self signalSwitchChanged.
]

{ #category : #switch }
MCSnapshotBrowser >> switchIsClass [
	^ switch = #class
]

{ #category : #switch }
MCSnapshotBrowser >> switchIsComment [
	^ switch = #comment.
]

{ #category : #switch }
MCSnapshotBrowser >> switchIsInstance [
	switch ifNil: [switch := #instance].
	^ switch = #instance.
]

{ #category : #text }
MCSnapshotBrowser >> text [
	self switchIsComment ifTrue: [^ self classCommentString].
	methodSelection ifNotNil: [^ methodSelection source].
	protocolSelection ifNotNil: [^ ''].
	classSelection ifNotNil: [^ self classDefinitionString].
	categorySelection ifNil: [^self scriptDefinitionString].
	^ ''
]

{ #category : #text }
MCSnapshotBrowser >> text: aTextOrString [
	self changed: #text
]

{ #category : #listing }
MCSnapshotBrowser >> visibleCategories [

	| visibleCategories |
	visibleCategories := Set new.
	self packageOrganizations do: [ :each | visibleCategories addAll: each categories ].
	self packageClasses do: [ :each | visibleCategories add: each category ].
	self hasExtensions ifTrue: [ visibleCategories add: self extensionsCategory ].
	^visibleCategories sorted: [:each | each ifNil: ['~(put nils to the end)']] ascending
]

{ #category : #listing }
MCSnapshotBrowser >> visibleClasses [
	^ categorySelection = self extensionsCategory
		ifTrue: [self extensionClassNames]
		ifFalse: [self packageClasses
					select: [:ea | ea category = categorySelection]
					thenCollect: [:ea | ea className]].
]

{ #category : #listing }
MCSnapshotBrowser >> visibleMethods [
	^ classSelection 
		ifNil: [#()]
		ifNotNil: [self methodsForSelectedProtocol]
]

{ #category : #listing }
MCSnapshotBrowser >> visibleProtocols [
	| methods protocols |
	self switchIsComment ifTrue: [^ Array empty].
	methods := self methodsForSelectedClassAndMetaSelection.
	protocols := methods collect: [:ea | ea category] as: Set.
	(protocols size > 1) ifTrue: [protocols add: '-- all --'].
	^ protocols sorted
]

{ #category : #'morphic ui' }
MCSnapshotBrowser >> widgetSpecs [

	Preferences annotationPanes ifFalse: [ ^#(
		((listMorph: category) (0 0 0.25 0.4))
		((listMorph: class) (0.25 0 0.50 0.4) (0 0 0 -30))
		((listMorph: protocol) (0.50 0 0.75 0.4))
		((listMorph:selection:menu:keystroke:  methodList methodSelection methodListMenu: methodListKey:from:) (0.75 0 1 0.4))
		((buttonRow) (0.25 0.4 0.5 0.4) (0 -30 0 0))
		((codePane: text) (0 0.4 1 1))
		) ].

	^#(
		((listMorph: category) (0 0 0.25 0.4))
		((listMorph: class) (0.25 0 0.50 0.4) (0 0 0 -30))
		((listMorph: protocol) (0.50 0 0.75 0.4))
		((listMorph:selection:menu:keystroke:  methodList methodSelection methodListMenu: methodListKey:from:) (0.75 0 1 0.4))

		((buttonRow) (0.25 0.4 0.5 0.4) (0 -30 0 0))

		((inputMorph: annotations) (0 0.4 1 0.4) (0 0 0 defaultInputFieldHeight))
		((codePane: text) (0 0.4 1 1) (0 defaultInputFieldHeight 0 0))
		)
]
