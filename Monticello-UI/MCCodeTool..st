"
MCCodeTool is an abstract superclass for those Monticello browsers that display code.
It contains copies of the various CodeHolder methods that perform the various menu operations in the method list.

"
Class {
	#name : #MCCodeTool,
	#superclass : #MCTool,
	#instVars : [
		'items',
		'environmentInDisplayingImage'
	],
	#category : #'Monticello-UI'
}

{ #category : #menus }
MCCodeTool >> adoptMessageInCurrentChangeset [
	"Add the receiver's method to the current change set if not already there"

	self selectedClassOrMetaClass ifNotNil: [ :cl |
		self selectedMessageName ifNotNil: [ :sel |
			ChangeSet current adoptSelector: sel forClass: cl.
			self changed: #annotations ]]

]

{ #category : #subclassResponsibility }
MCCodeTool >> annotations [
	"Build an annotations string for the various browsers"
	^''
]

{ #category : #menus }
MCCodeTool >> browseClassHierarchy [
	"Create and schedule a class list browser on the receiver's hierarchy."

	self systemNavigation
		spawnHierarchyForClass: self selectedClassOrMetaClass
		selector: self selectedMessageName	"OK if nil"
]

{ #category : #menus }
MCCodeTool >> browseFullProtocol [
	"Open up a protocol-category browser on the value of the receiver's current selection.    If in mvc, an old-style protocol browser is opened instead.  Someone who still uses mvc might wish to make the protocol-category-browser work there too, thanks."

	(Smalltalk isMorphic and: [Smalltalk hasClassNamed: #Lexicon]) ifFalse: [^ self spawnFullProtocol].
	self selectedClassOrMetaClass ifNotNil: [:class |
		^ (Smalltalk at: #Lexicon) new
			openOnClass: class
			inWorld: self currentWorld
			showingSelector: self selectedMessageName].
	^ nil
]

{ #category : #menus }
MCCodeTool >> browseMessages [
	"Present a menu of the currently selected message, as well as all messages sent by it.  Open a message set browser of all implementors of the selector chosen."

	self systemNavigation browseAllImplementorsOf: (self selectedMessageName ifNil: [ ^nil ])
]

{ #category : #menus }
MCCodeTool >> browseMethodFull [
	"Create and schedule a full Browser and then select the current class and message, or just the current class if viewing a class definition."
	^ self selectedClassOrMetaClass ifNotNil: [ :cls |
		self selectedMessageName
			ifNil: [ToolSet browseClass: cls]
			ifNotNil: [:sel | ToolSet browse: cls selector: sel]]
]

{ #category : #menus }
MCCodeTool >> browseSendersOfMessages [
	"Present a menu of the currently selected message, as well as all messages sent by it.  Open a message set browser of all senders of the selector chosen."

	self systemNavigation browseAllCallsOn: (self selectedMessageName ifNil: [ ^nil ])
]

{ #category : #menus }
MCCodeTool >> browseVersions [
	"Create and schedule a message set browser on all versions of the currently selected message selector."
	(ToolSet
		browseVersionsOf: self selectedClassOrMetaClass
		selector: self selectedMessageName) ifNil: [self changed: #flash]
]

{ #category : #menus }
MCCodeTool >> classListMenu: aMenu [ 

	aMenu addList: #(
		-
		('browse full (b)'			browseMethodFull)
		('browse hierarchy (h)'		browseClassHierarchy)
		('browse protocol (p)'		browseFullProtocol)
"		-
		('printOut'					printOutClass)
		('fileOut'					fileOutClass)
"		-
		('show hierarchy'			methodHierarchy)
"		('show definition'			editClass)
		('show comment'			editComment)
"
"		-
		('inst var refs...'			browseInstVarRefs)
		('inst var defs...'			browseInstVarDefs)
		-
		('class var refs...'			browseClassVarRefs)
		('class vars'					browseClassVariables)
		('class refs (N)'				browseClassRefs)
		-
		('rename class ...'			renameClass)
		('copy class'				copyClass)
		('remove class (x)'			removeClass)
"
		-
		('find method...'				findMethodInChangeSets)).
							
	^aMenu
]

{ #category : #menus }
MCCodeTool >> copyReference [
	"Copy the selected selector to the clipboard"
	self selectedMessageName ifNotNil:
		[ : selector | Clipboard clipboardText:
			(self selectedClassOrMetaClass
				ifNil: [ selector asString ]
				ifNotNilDo: [ : cls | (cls >> selector) reference ]) ]
]

{ #category : #menus }
MCCodeTool >> copySelector [
	"Copy the selected selector to the clipboard"

	| selector |
	(selector := self selectedMessageName) ifNotNil:
		[Clipboard clipboardText: selector asString]
]

{ #category : #accessing }
MCCodeTool >> environmentInDisplayingImage [
	^ environmentInDisplayingImage ifNil: [Smalltalk globals]
]

{ #category : #accessing }
MCCodeTool >> environmentInDisplayingImage: anEnvironment [
	environmentInDisplayingImage := anEnvironment
]

{ #category : #menus }
MCCodeTool >> fileOutMessage [
	"Put a description of the selected message on a file"

	| fileName |
	self selectedMessageName ifNotNil:
		[Cursor write showWhile:
			[self selectedClassOrMetaClass fileOutMethod: self selectedMessageName].
		 ^self].
	items isEmpty ifTrue:
		[^self].
	fileName := UIManager default saveFilenameRequest: 'File out on which file?' initialAnswer: 'methods'.
	fileName isEmptyOrNil ifTrue: [^self].
	Cursor write showWhile:
		[| definitionStream removalInitStream |
		definitionStream := WriteStream on: (String new: 1000).
		removalInitStream := WriteStream on: (String new: 100).
		definitionStream header; timeStamp.
		items do:
			[:patchOp| | def |
			def := patchOp definition.
			def isMethodDefinition ifTrue:
				[(def actualClass notNil
				  and: [def actualClass includesSelector: def selector])
					ifTrue:
						[def actualClass
							printMethodChunk: def selector
							withPreamble: true
							on: definitionStream
							moveSource: false
							toFile: nil.
						(def selector == #initialize and: [def classIsMeta]) ifTrue:
							[removalInitStream nextChunkPut: def className, ' initialize'; cr]]
					ifFalse:
						[removalInitStream nextChunkPut: def className, (def classIsMeta ifTrue: [' class'] ifFalse: ['']), ' removeSelector: ', def selector printString; cr]].
			def isClassDefinition ifTrue:
				[def actualClass
					ifNotNil:
						[definitionStream nextChunkPut: def actualClass definition.
						 def comment ifNotNil:
							[def actualClass organization
								putCommentOnFile: definitionStream
								numbered: 1
								moveSource: false
								forClass: def actualClass]]
					ifNil:
						[removalInitStream nextChunkPut: def className, ' removeFromSystem'; cr]]].
		definitionStream nextPutAll: removalInitStream contents.
		FileStream writeSourceCodeFrom: definitionStream baseName: fileName isSt: true useHtml: false]
]

{ #category : #menus }
MCCodeTool >> findMethodInChangeSets [
	"Find and open a changeSet containing the current method."

	| aName |
	(aName := self selectedMessageName) ifNotNil: [
		ChangeSorter 
			browseChangeSetsWithClass: self selectedClassOrMetaClass
			selector: aName]
]

{ #category : #accessing }
MCCodeTool >> items [
	^ items
]

{ #category : #menus }
MCCodeTool >> methodHierarchy [
	"Create and schedule a method browser on the hierarchy of implementors."

	self systemNavigation methodHierarchyBrowserForClass: self selectedClassOrMetaClass
		selector: self selectedMessageName
]

{ #category : #menus }
MCCodeTool >> methodListKey: aKeystroke from: aListMorph [ 
	aKeystroke caseOf: {
		[$b] -> [self browseMethodFull].
		[$h] -> [self browseClassHierarchy].
		[$p] -> [self browseFullProtocol].
		[$o] -> [self fileOutMessage].
		[$c] -> [self copySelector].
		[$C] -> [self copyReference].
		[$n] -> [self browseSendersOfMessages].
		[$m] -> [self browseMessages].
		[$i] -> [self methodHierarchy].
		[$v] -> [self browseVersions]}
		 otherwise: []
]

{ #category : #menus }
MCCodeTool >> methodListMenu: aMenu [
	"Build the menu for the selected method, if any."
	
	self selectedMessageName
	ifNil: [items notEmpty ifTrue:
		[aMenu addList:#(
			('browse full (b)' 						browseMethodFull)
			('fileOut (o)'								fileOutMessage))]]
	ifNotNil: [
	aMenu addList:#(
			('browse full (b)' 						browseMethodFull)
			('browse hierarchy (h)'					browseClassHierarchy)
			('browse protocol (p)'					browseFullProtocol)
			-
			('fileOut (o)'								fileOutMessage)
			('printOut'								printOutMessage)
			('copy selector (c)'						copySelector)
			('copy reference (C)'					copyReference)).
		aMenu addList: #(
			-
			('browse senders (n)'						browseSendersOfMessages)
			('browse implementors (m)'					browseMessages)
			('inheritance (i)'						methodHierarchy)
			('versions (v)'							browseVersions)
		('change sets with this method'			findMethodInChangeSets)
"		('x revert to previous version'				revertToPreviousVersion)"
		('remove from current change set'		removeFromCurrentChanges)
"		('x revert & remove from changes'		revertAndForget)"
		('add to current change set'				adoptMessageInCurrentChangeset)
"		('x copy up or copy down...'				copyUpOrCopyDown)"
"		('x remove method (x)'					removeMessage)"
		"-"
		).
	].
"	aMenu addList: #(
			('x inst var refs...'						browseInstVarRefs)
			('x inst var defs...'						browseInstVarDefs)
			('x class var refs...'						browseClassVarRefs)
			('x class variables'						browseClassVariables)
			('x class refs (N)'							browseClassRefs)
	).
"
	^ aMenu

]

{ #category : #menus }
MCCodeTool >> perform: selector orSendTo: otherTarget [ 

	"Selector was just chosen from a menu by a user. If can respond, then  
	perform it on myself. If not, send it to otherTarget, presumably the  
	editPane from which the menu was invoked."

	(self respondsTo: selector)
		ifTrue: [^ self perform: selector]
		ifFalse: [^ super perform: selector orSendTo: otherTarget]
]

{ #category : #menus }
MCCodeTool >> printOutMessage [
	"Write a file with the text of the selected message, for printing by a web browser"

	self selectedMessageName ifNotNil: [
		self selectedClassOrMetaClass fileOutMethod: self selectedMessageName
							asHtml: true]
]

{ #category : #menus }
MCCodeTool >> removeFromCurrentChanges [
	"Tell the changes mgr to forget that the current msg was changed."

	ChangeSet current removeSelectorChanges: self selectedMessageName 
			class: self selectedClassOrMetaClass.
	self changed: #annotations
]

{ #category : #subclassResponsibility }
MCCodeTool >> selectedClass [
	"Answer the class that is selected, or nil"
	self subclassResponsibility
]

{ #category : #subclassResponsibility }
MCCodeTool >> selectedClassOrMetaClass [
	"Answer the class that is selected, or nil"
	self subclassResponsibility
]

{ #category : #subclassResponsibility }
MCCodeTool >> selectedMessageCategoryName [
	"Answer the method category of the method that is selected, or nil"
	self subclassResponsibility
]

{ #category : #subclassResponsibility }
MCCodeTool >> selectedMessageName [
	"Answer the name of the selected message"
	self subclassResponsibility
]

{ #category : #'initialize-release' }
MCCodeTool >> setItems: aCollection [
	items := aCollection
]
