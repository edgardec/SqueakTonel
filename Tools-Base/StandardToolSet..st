"
Main comment stating the purpose of this class and relevant relationship to other classes.

Possible useful expressions for doIt or printIt.

Structure:
 instVar1		type -- comment about the purpose of instVar1
 instVar2		type -- comment about the purpose of instVar2

Any further useful comments about the general approach of this implementation.
"
Class {
	#name : #StandardToolSet,
	#superclass : #Object,
	#category : #'Tools-Base'
}

{ #category : #inspecting }
StandardToolSet class >> basicInspect: anObject [
	"Open a basic inspector on the given object."
	^ BasicInspector openOn: anObject
]

{ #category : #browsing }
StandardToolSet class >> browse: aClass selector: aSelector [
	"Open a browser"
	^SystemBrowser default fullOnClass: aClass selector: aSelector
]

{ #category : #browsing }
StandardToolSet class >> browseCategory: aCategory [
	
	^ SystemBrowser default fullOnCategory: aCategory
]

{ #category : #browsing }
StandardToolSet class >> browseChangeSetsWithClass: aClass selector: aSelector [
	"Browse all the change sets with the given class/selector"
	^ChangeSorter browseChangeSetsWithClass: aClass selector: aSelector
]

{ #category : #browsing }
StandardToolSet class >> browseClass: aClass [
	"Open a browser"
	^SystemBrowser default fullOnClass: aClass.
]

{ #category : #browsing }
StandardToolSet class >> browseClass: aClass category: aCategory [
	"Open a browser for a class selecting a given message category."
	
	^ SystemBrowser default
		fullOnClass: aClass
		category: aCategory
]

{ #category : #browsing }
StandardToolSet class >> browseHierarchy: aClass selector: aSelector [
	"Open a browser"
	
	^ HierarchyBrowser fullOnClass: aClass selector: aSelector.
]

{ #category : #browsing }
StandardToolSet class >> browseMessageCategory: aCategory inClass: aClass [
	"Open a message category browser."
	
	^ SystemBrowser default
		newOnClass: aClass messageCategory: aCategory
]

{ #category : #browsing }
StandardToolSet class >> browseMessageNames: aString [
	^(MessageNames methodBrowserSearchingFor: aString) openInWorld
]

{ #category : #browsing }
StandardToolSet class >> browseMessageSet: messageList name: title autoSelect: autoSelectString [
	"Open a message set or message-trace browser, depending on the #traceMessages setting."
	^ Preferences traceMessages
		ifTrue:
			[ MessageTrace
				openMessageList: messageList 
				name: title 
				autoSelect: autoSelectString ]
		ifFalse:
			[ MessageSet
				openMessageList: messageList 
				name: title 
				autoSelect: autoSelectString ]
]

{ #category : #browsing }
StandardToolSet class >> browseMethod: aCompiledMethod [
	"Browse aCompiledMethod on the most convenient possible way, using a System Browser, a Versions Browser, or an Inspector."

	aCompiledMethod isInstalled
		ifTrue: [^ self browse: aCompiledMethod methodClass selector: aCompiledMethod selector].
	(aCompiledMethod methodClass changeRecordsAt: aCompiledMethod selector)
		ifNotNil: [^ self browseMethodVersion: aCompiledMethod].
	^ self inspect: aCompiledMethod
]

{ #category : #browsing }
StandardToolSet class >> browseMethodVersion: aCompiledMethod [
	
	^ VersionsBrowser browseMethod: aCompiledMethod
]

{ #category : #browsing }
StandardToolSet class >> browsePackage: aPackageInfo [
	
	self flag: #discuss. "mt: Maybe use the package-pane browser?"
	"PackagePaneBrowser fullOnCategory: aPackageInfo name"
	
	^ self browseCategory: aPackageInfo systemCategories first
	

]

{ #category : #browsing }
StandardToolSet class >> browseVersionsOf: class selector: selector [
	"Open and answer a browser on versions of the method.
	 If the method doesn't exist try and find version from the current change set.
	 If not found there, answer nil."
	| methodOrNil methodCategory |
	methodOrNil := class compiledMethodAt: selector ifAbsent: [].
	methodOrNil ifNil:
		[(ChangeSet current methodInfoFromRemoval: {class name. selector})
			ifNil: [^nil]
			ifNotNil:
				[:pair|
				methodOrNil := CompiledMethod toReturnSelfTrailerBytes:
									(CompiledMethodTrailer new sourcePointer: pair first).
				methodCategory := pair last]].
	^VersionsBrowser
		browseVersionsOf: methodOrNil
		class: class theNonMetaClass
		meta: class isMeta
		category: (methodCategory ifNil: [class organization categoryOfElement: selector])
		selector: selector
]

{ #category : #completion }
StandardToolSet class >> codeCompletionAround: aBlock textMorph: aTextMorph keyStroke: evt [
	^ aBlock value
]

{ #category : #debugging }
StandardToolSet class >> debugException: anException [
	"For convenience. Construct a helper process to debug an exception that occurred in the active process later on so that the active process can (try to) resume. Uses a temporary variable to access and copy the signaler context now before it gets GC'ed."
	
	| helperProcess |
	helperProcess := (Process
		forContext: anException signalerContext copyStack
		priority: Processor activeProcess priority)
			shouldResumeFromDebugger: false;
			yourself.

	Project current addDeferredUIMessage: [
		helperProcess
			debugWithTitle: anException description
			full: false].
]

{ #category : #debugging }
StandardToolSet class >> debugProcess: aProcess context: aContext label: aString contents: contents fullView: aBool [

	(aProcess isTerminated and: [aString beginsWith: 'Debug it']) ifTrue: [
		^ Project uiManager inform: 'Nothing to debug. Process has terminated.\Expression optimized.' withCRs].

	^ Debugger
		openOn: aProcess
		context: aContext
		label: aString
		contents: contents
		fullView: aBool
]

{ #category : #debugging }
StandardToolSet class >> debugSyntaxError: aSyntaxErrorNotification [
	
	^ SyntaxError open: aSyntaxErrorNotification
]

{ #category : #inspecting }
StandardToolSet class >> explore: anObject [

	^ ObjectExplorer openOn: anObject
]

{ #category : #inspecting }
StandardToolSet class >> explore: anObject label: label [

	^ ObjectExplorer openOn: anObject withLabel: label
]

{ #category : #'debugging - handlers' }
StandardToolSet class >> handleError: anError [
	"Double dispatch. Let the active process take care of that error, which usually calls back here to #debugProcess:..."

	^ Processor activeProcess
		debug: anError signalerContext
		title: anError description
]

{ #category : #'debugging - handlers' }
StandardToolSet class >> handleRecursiveError: description [

	^ Project current recursiveError: description
]

{ #category : #'debugging - handlers' }
StandardToolSet class >> handleSyntaxError: aSyntaxErrorNotification [
	"Double dispatch. Let the current project manage processes, which usually calls back into #debugSyntaxError:."
	
	^ Project current syntaxError: aSyntaxErrorNotification
]

{ #category : #'debugging - handlers' }
StandardToolSet class >> handleUserInterruptRequest: aString [
	"Double dispatch. Let the current project manage processes, which usually calls back here eventually into #debugProcess..."
	
	Preferences cmdDotEnabled ifFalse: [^ self].
	^ Project current interruptName: aString
]

{ #category : #'debugging - handlers' }
StandardToolSet class >> handleWarning: aWarning [
	"Double dispatch. Let the active process take care of that warning, which usually calls back here to #debugProcess:..."

	| message |
	message := '{1}\\{2}' withCRs asText format: {
		"First, show the actual text of this warning."
		aWarning messageText.
		"Second, append some helpful information that apply to all kinds of warnings."
		('{1} {2}' asText format: {
			'Select "Proceed" to continue or close this window to cancel the operation.' translated.
			'If you do not want to be interrupted anymore, you can {1} this kind of warning. You can also {2}, which resets such warnings on the next image startup.' translated asText format: {
				"Provide clickable text links so that the user can directly suppress warnings."
				'always suppress' asText
					addAttribute: (PluggableTextAttribute evalBlock: [
						aWarning class suppressWarnings.
						self inform: ('All ''{1}'' warnings will be suppressed.' translated format: {aWarning class name})]).
				'suppress temporarily' asText
					addAttribute: (PluggableTextAttribute evalBlock: [
						aWarning class suppressAndResetOnStartUp.
						self inform: ('All ''{1}'' warnings will be suppressed\and reset on the next image startup.' withCRs translated format: {aWarning class name})])}.
			}) addAttribute: (
				"Show this helpful information in a smaller font."
				TextFontReference toFont: Preferences standardButtonFont)}.
	
	^ Processor activeProcess
		debug: aWarning signalerContext
		title: 'Warning' translated
		full: false
		contents: message
]

{ #category : #'class initialization' }
StandardToolSet class >> initialize [
	ToolSet register: self.
]

{ #category : #inspecting }
StandardToolSet class >> inspect: anObject [
	"Open an inspector on the given object. The tool set must know which inspector type to use for which object - the object cannot possibly know what kind of inspectors the toolset provides."
	^ anObject inspectorClass openOn: anObject
]

{ #category : #inspecting }
StandardToolSet class >> inspect: anObject label: aString [
	"Open an inspector on the given object. The tool set must know which inspector type to use for which object - the object cannot possibly know what kind of inspectors the toolset provides."
	^ anObject inspectorClass openOn: anObject withLabel: aString
]

{ #category : #menu }
StandardToolSet class >> menuItems [
	"Answer the menu items available for this tool set"
	^#(
		('class browser' 			#openClassBrowser)
		('workspace'				#openWorkspace)
		('file list'					#openFileList)
		('package pane browser' 	#openPackagePaneBrowser)
		('process browser' 			#openProcessBrowser)
		-
		('method finder'				#openSelectorBrowser)
		('message names'			#openMessageNames)
		-
		('simple change sorter'		#openChangeSorter)
		('dual change sorter'		#openDualChangeSorter)
	)

]

{ #category : #menu }
StandardToolSet class >> openChangeSorter [
	ToolBuilder open: ChangeSorter new
]

{ #category : #browsing }
StandardToolSet class >> openChangedMessageSet: aChangeSet [
	"Open a ChangedMessageSet for aChangeSet"
	ChangedMessageSet openFor: aChangeSet
]

{ #category : #menu }
StandardToolSet class >> openClassBrowser [
	SystemBrowser default open
]

{ #category : #browsing }
StandardToolSet class >> openClassListBrowser: anArray title: aString [
	"Open a class list browser on the list of classes named"

	^ClassListBrowser newOnClassesNamed: anArray label: aString

]

{ #category : #menu }
StandardToolSet class >> openDualChangeSorter [
	ToolBuilder open: DualChangeSorter new
]

{ #category : #menu }
StandardToolSet class >> openFileList [
	FileList open
]

{ #category : #menu }
StandardToolSet class >> openMessageNames [
	"Bring a MessageNames tool to the front"
	MessageNames openMessageNames
]

{ #category : #menu }
StandardToolSet class >> openPackagePaneBrowser [
	PackagePaneBrowser openBrowser.
]

{ #category : #menu }
StandardToolSet class >> openProcessBrowser [
	ProcessBrowser open
]

{ #category : #menu }
StandardToolSet class >> openSelectorBrowser [
	ToolBuilder open: SelectorBrowser new
]

{ #category : #menu }
StandardToolSet class >> openWorkspace [
	Workspace open
]

{ #category : #'class initialization' }
StandardToolSet class >> unload [
	ToolSet unregister: self.
]
