"
I represent the machine state at the time of an interrupted process. I also represent a query path into the state of the process. The debugger is typically viewed through a window that views the stack of suspended contexts, the code for, and execution point in, the currently selected message, and inspectors on both the receiver of the currently selected message, and the variables in the current context.

Special note on recursive errors:
Some errors affect Squeak's ability to present a debugger.  This is normally an unrecoverable situation.  However, if such an error occurs in an isolation layer, Squeak will attempt to exit from the isolation layer and then present a debugger.  Here is the chain of events in such a recovery.

	* A recursive error is detected.
	* The current project is queried for an isolationHead
	* Changes in the isolationHead are revoked
	* The parent project of isolated project is returned to
	* The debugger is opened there and execution resumes.

If the user closes that debugger, execution continues in the outer project and layer.  If, after repairing some damage, the user proceeds from the debugger, then the isolationHead is re-invoked, the failed project is re-entered, and execution resumes in that world. 

---

In September 2019, we added MorphicDebugger and MVCDebugger to untangle framework-specific features in our debugger infrastructure. However, this is just an intermediate step. The overall goal would be to remove those two subclasses again while preserving their functionality. Mostly, MVC and Morphic differ in their GUI-process management. This means that ""proceed"" and ""close"" work differently depending on the process that is being debugged. --- One idea is to attach that framework-specific information to the process objects. See Process >> #environmentAt: and #environmentAt:put:. Also see ToolSet's #handle* and #debug* methods.
"
Class {
	#name : #Debugger,
	#superclass : #CodeHolder,
	#instVars : [
		'interruptedProcess',
		'contextStack',
		'contextStackIndex',
		'contextStackList',
		'receiverInspector',
		'receiverInspectorState',
		'contextVariablesInspector',
		'contextVariablesInspectorState',
		'externalInterrupt',
		'proceedValue',
		'selectingPC',
		'savedCursor',
		'isolationHead',
		'failedProject',
		'labelString',
		'message',
		'untilExpression'
	],
	#classVars : [
		'ContextStackKeystrokes',
		'ErrorReportServer',
		'FullStackSize',
		'InterruptUIProcessIfBlockedOnErrorInBackgroundProcess',
		'NotifierStackSize',
		'SavedExtent',
		'StackSizeLimit',
		'WantsAnnotationPane'
	],
	#category : #'Tools-Debugger'
}

{ #category : #preferences }
Debugger class >> errorReportServer [
	<preference: 'Server to send error reports to'
		category: 'debug'
		description: 'When eToyFriendly is enabled, the debugger offers to send an error report to the developers of the system. This variable controls where this error report is sent to.'
		type: #String>
	^ErrorReportServer ifNil: ['']
]

{ #category : #preferences }
Debugger class >> errorReportServer: aString [

	ErrorReportServer := aString
]

{ #category : #preferences }
Debugger class >> fullStackSize [

	<preference: 'Stack Size in Full Debugger'
		categoryList: #(debug tools)
		description: 'The number of stack frames to be shown in the full debugger. You can always expand the full stack there.'
		type: #Number>
		
	^ FullStackSize ifNil: [20]
]

{ #category : #preferences }
Debugger class >> fullStackSize: aNumber [

	FullStackSize := aNumber max: self notifierStackSize.
]

{ #category : #private }
Debugger class >> ifPreferredInterruptUIProcessIfBlocked: errorWasInUIProcess [
	| sema |
	errorWasInUIProcess ifTrue:
		[^self].
	self interruptUIProcessIfBlockedOnErrorInBackgroundProcess ifFalse:
		[^self].
	"Only interrupt the UI if it is unresponsive (and so is doing something that needs
	 interrupting).  Test using addDeferredUIMessage: to see if it is running UI activities."
	sema := Semaphore new.
	Project current addDeferredUIMessage: [sema signal].
	(sema waitTimeoutMSecs: 100) ifTrue:
		[[Project current interruptName: 'Interrupt from Background Error'] fork]

	"| s |
	s := Semaphore new.
	[self assert: 0 > 1000. s signal] fork.
	s wait"
]

{ #category : #'instance creation' }
Debugger class >> informExistingDebugger: aContext label: aString [
	"Walking the context chain, we try to find out if we're in a debugger stepping situation.
	 If we find the relevant contexts, we must rearrange them so they look just like they would
	 if the methods were executed outside of the debugger.
	 hmm 8/3/2001 13:05"
	| ctx quickStepMethod oldSender baseContext |
	ctx := thisContext.
	quickStepMethod := Context
							compiledMethodAt: #quickSend:to:with:lookupIn:
							ifAbsent: [Context compiledMethodAt: #quickSend:to:with:super:].
	[ctx sender == nil or: [ctx sender method == quickStepMethod]] whileFalse:
		[ctx := ctx sender].
	ctx sender ifNil: [^self].
	baseContext := ctx.
	"baseContext is now the context created by the #quickSend... method."
	oldSender := ctx := ctx sender home sender.
	"oldSender is the context which originally sent the #quickSend... method"
	[ctx == nil or: [(ctx objectClass: ctx receiver) includesBehavior: self]] whileFalse:
		[ctx := ctx sender].
	ctx ifNil: [^self].
	"ctx is the context of the Debugger method #doStep"
	ctx receiver
		labelString: aString;
		proceedValue: aContext receiver.
	baseContext swapSender: baseContext sender sender sender.	"remove intervening contexts"
	thisContext swapSender: oldSender.	"make myself return to debugger"
	^ aContext
]

{ #category : #'class initialization' }
Debugger class >> initialize [
	ContextStackKeystrokes := Dictionary new
		at: $e put: #send;
		at: $t put: #doStep;
		at: $T put: #stepIntoBlock;
		at: $p put: #proceed;
		at: $r put: #restart;
		at: $f put: #fullStack;
		at: $w put: #where;
		yourself.
	SavedExtent := self new initialExtent

	"Debugger initialize"
]

{ #category : #preferences }
Debugger class >> interruptUIProcessIfBlockedOnErrorInBackgroundProcess [
	<preference: 'Interrupt UI process on background error'
		category: 'debug'
		description: 'When enabled, the debugger will interrupt the UI process if an error occurs in a background process and the UI process is blocked.'
		type: #Boolean>
	^InterruptUIProcessIfBlockedOnErrorInBackgroundProcess ifNil: [false]
]

{ #category : #preferences }
Debugger class >> interruptUIProcessIfBlockedOnErrorInBackgroundProcess: aBoolean [
	InterruptUIProcessIfBlockedOnErrorInBackgroundProcess := aBoolean
]

{ #category : #preferences }
Debugger class >> notifierStackSize [

	<preference: 'Stack Size in Notifier Debugger'
		categoryList: #(debug tools)
		description: 'If there is no message to be displayed in the notifier, how many stack frames should be visible?'
		type: #Number>
		
	^ NotifierStackSize ifNil: [10]
]

{ #category : #preferences }
Debugger class >> notifierStackSize: anInteger [

	NotifierStackSize := anInteger.
]

{ #category : #opening }
Debugger class >> openOn: process context: context label: title contents: contentsStringOrNil fullView: bool [
	"Kind of private. Open a notifier or a full debugger in response to an error, halt, or notify. Opens a project-specific debugger. Decorates that invocation with (1) recursive-error detection and (2) error logging, which are both independent from the active GUI framework, that is, MVC or Morphic.
	
	Note that clients should debug processes through Process >> #debug instead of calling this method directly."

	| ap |
	ap := Processor activeProcess.
	
	"If the active process re-enters this method again, something went wrong with invoking the debugger."
	ap hasRecursiveError ifTrue: [
		ap clearErrorRecursionFlag.
		^ ToolSet handleRecursiveError: title].
	
	"Explicitely handle logging exceptions. No need to bother the recursion mechanism here."
	[Preferences logDebuggerStackToFile
		ifTrue: [Smalltalk logSqueakError: title inContext: context]
	] on: Error do: [:ex |
		Preferences disable: #logDebuggerStackToFile.
		ToolSet debugException: ex].

	"If project-specific debuggers mess up, we have to flag that recursion here. Se above."
	[ap setErrorRecursionFlag.

		self informExistingDebugger: context label: title.

		^ Project current debuggerClass
			openOn: process context: context label: title contents: contentsStringOrNil fullView: bool

	] ensure: [ap clearErrorRecursionFlag].
]

{ #category : #preferences }
Debugger class >> stackSizeLimit [

	<preference: 'Stack Size Limit'
		categoryList: #(debug tools)
		description: 'Even when expanding the entire stack, there should be a limit to avoid low-space errors.'
		type: #Number>
		
	^ StackSizeLimit ifNil: [100000]
]

{ #category : #preferences }
Debugger class >> stackSizeLimit: aNumber [

	StackSizeLimit := aNumber max: self fullStackSize.
]

{ #category : #preferences }
Debugger class >> wantsAnnotationPane [
	<preference: 'Show annotation pane in the debugger.'
		categoryList: #(debug tools)
		description: 'If true, a small horizontal annotation pane shows information about the selected method.'
		type: #Boolean>
	^ WantsAnnotationPane ifNil: [false]
]

{ #category : #preferences }
Debugger class >> wantsAnnotationPane: boolean [

	WantsAnnotationPane := boolean.
]

{ #category : #'context stack menu' }
Debugger >> abandon [
	"abandon the debugger from its pre-debug notifier"
	
	self close.
]

{ #category : #'code pane' }
Debugger >> aboutToStyle: aStyler [
	"This is a notification that aStyler is about to re-style its text.
	Set the classOrMetaClass in aStyler, so that identifiers
	will be resolved correctly.
	Answer true to allow styling to proceed, or false to veto the styling"
	
	self isModeStyleable ifFalse: [^false].
	aStyler 
		classOrMetaClass: self selectedClassOrMetaClass;
		sourceMap: self debuggerMap.
	^true
]

{ #category : #'notifier support' }
Debugger >> askForCategoryIn: aClass default: aString [

	^ (Project uiManager
		chooseFromOrAddTo: (aClass allMethodCategoriesIntegratedThrough: Object)
		lines: #()
		title: 'Please provide a good category for the new method' translated)
			ifNil: [aString]
			ifNotNil: [:newCategory | newCategory ifEmpty: [aString]]
]

{ #category : #'notifier support' }
Debugger >> askForSuperclassOf: aClass toImplement: aSelector ifCancel: cancelBlock [
	| classes chosenClassIndex |
	classes := aClass withAllSuperclasses.
	chosenClassIndex := UIManager default 
		chooseFrom: (classes collect: [:c | c name])
		title: 'Define #', aSelector, ' in which class?'.
	chosenClassIndex = 0 ifTrue: [^ cancelBlock value].
	^ classes at: chosenClassIndex
]

{ #category : #'notifier support' }
Debugger >> askForSuperclassOf: aClass upTo: superclass toImplement: aSelector ifCancel: cancelBlock [
	| classes chosenClassIndex |
	classes := aClass withAllSuperclasses reject: [:cls | aClass isKindOf: cls].
	chosenClassIndex := UIManager default 
		chooseFrom: (classes collect: [:c | c name])
		title: 'Define #', aSelector, ' in which class?'.
	chosenClassIndex = 0 ifTrue: [^ cancelBlock value].
	^ classes at: chosenClassIndex
]

{ #category : #toolbuilder }
Debugger >> browseClassHierarchy [
	"Create and schedule a class list browser on the receiver's hierarchy."
	
	(self selectedMessageName = #doesNotUnderstand: and: [ self selectedClassOrMetaClass = Object ])
		ifTrue:
			[ self systemNavigation
				spawnHierarchyForClass: self receiverClass
				selector: self selectedMessageName ]
		ifFalse: [ super browseClassHierarchy ]
]

{ #category : #'context stack menu' }
Debugger >> browseMessages [
	"Present a menu of all messages sent by the currently selected message.
	Open a message set browser of all implementors of the message chosen.
	Do nothing if no message is chosen."

	contextStackIndex = 0 ifTrue: [^ self].
	self withSelectorAndMessagesIn: self selectedContext method
		evaluate: [:selector| self systemNavigation browseAllImplementorsOf: selector]
]

{ #category : #'context stack menu' }
Debugger >> browseSendersOfMessages [
	"Present a menu of the currently selected message, as well as all
	messages sent by it.  Open a message set browser of all senders
	of the message chosen."

	contextStackIndex = 0 ifTrue: [^ self].
	self withSelectorAndMessagesIn: self selectedContext method
		evaluate: [:selector| self systemNavigation browseAllCallsOn: selector]
]

{ #category : #'context stack menu' }
Debugger >> browseVersions [
	"Create and schedule a message set browser on all versions of the currently selected message selector."
	(ToolSet
		browseVersionsOf: self selectedClassOrMetaClass
		selector: self selectedMessageName) ifNil: [self changed: #flash]
]

{ #category : #toolbuilder }
Debugger >> buildCodePaneWith: builder [
	
	| textSpec top controlButtons browseButtons annoSpec |
	top := builder pluggablePanelSpec new.
	top children: OrderedCollection new.
	
	controlButtons := self buildControlButtonsWith: builder.
	controlButtons frame: self controlButtonsFrame.
	top children add: controlButtons.
	
	self wantsOptionalButtons ifTrue: [
		browseButtons := self buildOptionalButtonsWith: builder.
		browseButtons frame: self optionalButtonsFrame.
		top children add: browseButtons].

	textSpec := builder pluggableCodePaneSpec new.
	textSpec 
		model: self;
		getText: #contents; 
		setText: #contents:notifying:; 
		selection: #contentsSelection; 
		menu: #codePaneMenu:shifted:;
		frame: self textFrame.
	top children add: textSpec.

	self wantsAnnotationPane ifTrue: [
		annoSpec := self buildAnnotationPaneWith: builder.
		annoSpec frame: self annotationFrame.
		top children add: annoSpec].
	.
	^ top
]

{ #category : #toolbuilder }
Debugger >> buildControlButtonsWith: builder [

	| panelSpec |
	panelSpec := builder pluggablePanelSpec new.
	panelSpec children: OrderedCollection new.
	self customButtonSpecs do:[:spec|
		| buttonSpec |
		buttonSpec := builder pluggableActionButtonSpec new.
		buttonSpec model: self.
		buttonSpec label: spec first.
		buttonSpec action: spec second.
		spec second == #methodHierarchy ifTrue:[
			buttonSpec color: #inheritanceButtonColor.
		]. 
		spec size > 2 ifTrue:
			[buttonSpec help: spec third.
			 spec size > 3 ifTrue:
				[buttonSpec enabled: spec fourth]].
		panelSpec children add: buttonSpec.
	].

	panelSpec layout: #horizontal. "buttons"
	^panelSpec
]

{ #category : #toolbuilder }
Debugger >> buildFullWith: builder [
	| windowSpec listSpec textSpec |
	windowSpec := builder pluggableWindowSpec new
		model: self;
		label: 'Debugger';
		children: OrderedCollection new.

	listSpec := builder pluggableListSpec new.
	listSpec 
		model: self;
		list: #contextStackList; 
		getIndex: #contextStackIndex; 
		setIndex: #toggleContextStackIndex:; 
		menu: #contextStackMenu:shifted:; 
		icon: #messageIconAt:;
		helpItem: #messageHelpAt:;
		keyPress: #contextStackKey:from:;
		frame: (0@0 corner: 1@0.22).
	windowSpec children add: listSpec.


	textSpec := self buildCodePaneWith: builder.
	textSpec frame: (0@0.22corner: 1@0.8).
	windowSpec children add: textSpec.

	listSpec := self receiverInspector buildFieldListWith: builder.
	listSpec 
		frame: (0@0.8 corner: 0.2@1);
		help: 'Receiver''s\Instance\Variables' withCRs.
	windowSpec children add: listSpec.

	textSpec := self receiverInspector buildValuePaneWith: builder.
	textSpec 
		help: '<- Select receiver''s field' translated;
		frame: (0.2@0.8 corner: 0.5@1).
	windowSpec children add: textSpec.

	listSpec := self contextVariablesInspector buildFieldListWith: builder.
	listSpec 
		frame: (0.5@0.8 corner: 0.7@1);
		help: 'Other\Context\Bindings' withCRs.
	windowSpec children add: listSpec.

	textSpec := self contextVariablesInspector buildValuePaneWith: builder.
	textSpec 
		help: '<- Select context''s field' translated;
		frame: (0.7@0.8 corner: 1@1).
	windowSpec children add: textSpec.

	^builder build: windowSpec
]

{ #category : #toolbuilder }
Debugger >> buildNotifierWith: builder label: label message: messageString [
	| windowSpec listSpec textSpec panelSpec quads |
	windowSpec := builder pluggableWindowSpec new
		model: self;
		extent: self initialExtentForNotifier;
		label: label;
		children: OrderedCollection new.

	panelSpec := builder pluggablePanelSpec new.
	panelSpec children: OrderedCollection new.
	quads := self preDebugButtonQuads.
	(self interruptedContext selector == #doesNotUnderstand:) ifTrue: [
		quads := quads copyWith: 
			{ 'Create'. #createMethod. #magenta. 'create the missing method' }
	].
	(#(#notYetImplemented #shouldBeImplemented #requirement) includes: self interruptedContext selector) ifTrue: [
		quads := quads copyWith: 
			{ 'Create'. #createImplementingMethod. #magenta. 'implement the marked method' }
	].
	(self interruptedContext selector == #subclassResponsibility) ifTrue: [
		quads := quads copyWith: 
			{ 'Create'. #createOverridingMethod. #magenta. 'create the missing overriding method' }
	].
	quads do:[:spec| | buttonSpec |
		buttonSpec := builder pluggableButtonSpec new.
		buttonSpec model: self.
		buttonSpec label: spec first.
		buttonSpec action: spec second.
		buttonSpec help: spec fourth.
		spec size >= 5 ifTrue: [buttonSpec enabled: spec fifth].
		panelSpec children add: buttonSpec.
	].
	panelSpec layout: #horizontal. "buttons"
	panelSpec frame: self preDebugButtonQuadFrame.
	windowSpec children add: panelSpec.

	Preferences eToyFriendly | messageString notNil ifFalse:[
		listSpec := builder pluggableListSpec new.
		listSpec 
			model: self;
			list: #contextStackList; 
			getIndex: #contextStackIndex; 
			setIndex: #debugAt:; 
			icon: #messageIconAt:;
			helpItem: #messageHelpAt:; 
			frame: self contextStackFrame.
		windowSpec children add: listSpec.
	] ifTrue:[
		message := messageString.
		textSpec := builder pluggableTextSpec new.
		textSpec 
			model: self;
			getText: #preDebugMessageString; 
			setText: nil; 
			selection: nil; 
			menu: #debugProceedMenu:;
			frame: self contextStackFrame.
		windowSpec children add: textSpec.
	].

	^windowSpec
]

{ #category : #toolbuilder }
Debugger >> buildWith: aBuilder [
	^self buildFullWith: aBuilder
]

{ #category : #private }
Debugger >> checkContextSelection [

	contextStackIndex = 0 ifTrue: [self contextStackIndex: 1 oldContextWas: nil].

]

{ #category : #initialize }
Debugger >> close [
	"Close and delete this debugger. Try to trigger the close request through the UI first, do manually of not in the UI."

	self flag: #refactor. "mt: Maybe move this up to model?"
	self topView
		ifNotNil: [self changed: #close]
		ifNil: [
			self okToClose ifTrue: [
				self windowIsClosing; release]].
]

{ #category : #'code pane' }
Debugger >> codePaneSelectionInterval [

	^ self codeTextMorph
		ifNotNil: [:cp | cp selectionInterval]
		ifNil: [Interval from: 0 to: 0]
]

{ #category : #accessing }
Debugger >> contents [ 
	"Depending on the current selection, different information is retrieved.
	Answer a string description of that information.  This information is the
	method in the currently selected context."

	^contents ifNil:
		[self selectedContext
			ifNotNil: [self selectedMessage]
			ifNil: [String new]] 
]

{ #category : #accessing }
Debugger >> contents: aText notifying: aController [
	"Accept new method source of the selected context."

	| selector classOfMethod category ctxt newMethod |
	contextStackIndex = 0 ifTrue: [^ false].
	
	"First, handle some edge cases"
	selector := self selectedClass newParser parseSelector: aText.
	"selector isDoIt ifTrue: [
		currentCompiledMethod := self compileDoIt: aText]."
	self flag: #todo. "ct: Recompile doIt method *without* creating method litters! See Compiler>>#evaluateCue:ifFail:."
	selector = self selectedMessageName ifFalse: [
		"Different message compiled, delegating to super"
		^ super contents: aText notifying: aController].
	
	self selectedContext isExecutingBlock ifTrue: [
		"If we are in a block context, we need to rewind the stack before ."
		| home |
		home := self selectedContext activeHome.
		home ifNil: [
			self inform: 'Method for block not found on stack, can''t edit and continue' translated.
			^ false].
		(self confirm: 'I will have to revert to the method from\which this block originated. Is that OK?' withCRs translated) ifFalse: [
			^ false].
		
		self resetContext: home changeContents: false.
		"N.B. Only reset the contents if the compilation succeeds. If contents would be reset when compilation fails, both compiler error message and modifications were lost."
		^ (self contents: aText notifying: aController)
			ifTrue: [self contentsChanged];
			yourself].
	
	classOfMethod := self selectedClass.
	category := self selectedMessageCategoryName.
	
	"Do the actual compilation"
	selector := classOfMethod
		compile: aText
		classified: category
		notifying: aController.
	selector ifNil: [^ false]. "compilation cancelled"
	
	"Update views"
	contents := aText.
	newMethod := classOfMethod compiledMethodAt: selector.
	newMethod isQuick ifTrue: [
		self cutBackExecutionToSenderContext].
	ctxt := interruptedProcess popTo: self selectedContext.
	ctxt == self selectedContext
		ifFalse: [self inform: 'Method saved, but current context unchanged\because of unwind error. Click OK to see error' withCRs translated]
		ifTrue: [
			newMethod isQuick ifFalse: [
				interruptedProcess restartTopWith: newMethod.
				interruptedProcess stepToSendOrReturn].
			contextVariablesInspector object: nil].
	self resetContext: ctxt.
	
	Project current addDeferredUIMessage: [
		self changed: #contentsSelection].
	^ true
]

{ #category : #'code pane' }
Debugger >> contentsSelection [
	"Reverse the selection (i.e., point block and mark block) to put the text cursor at the beginning to ensure visibility of the beginning in small windows."
	
	self flag: #tofix. "mt: See http://forum.world.st/The-Inbox-Morphic-cmm-1615-mcz-td5109271.html and http://forum.world.st/stepping-in-small-panes-td5109239.html."
	^ self pcRange in: [:interval |
		interval last + 1 to: interval first - 1]
]

{ #category : #initialize }
Debugger >> context: aContext [

	self
		process: Processor activeProcess
		context: aContext.
]

{ #category : #toolbuilder }
Debugger >> contextStackFrame [

	^LayoutFrame new
		leftFraction: 0 offset: 0;
		topFraction: 0 offset: self buttonHeight;
		rightFraction: 1 offset: 0;
		bottomFraction: 1 offset: 0
]

{ #category : #'context stack - message list' }
Debugger >> contextStackIndex [
	"Answer the index of the selected context."

	^contextStackIndex
]

{ #category : #private }
Debugger >> contextStackIndex: anInteger oldContextWas: oldContext [ 
	"Change the context stack index to anInteger, perhaps in response to user selection."

	| isNewMethod |
	self saveReceiverInspectorState.
	self saveContextVariablesInspectorState.
	contextStackIndex := anInteger.
	anInteger = 0 ifTrue:
		[currentCompiledMethod := contents := nil.
		 self changed: #contextStackIndex.
		 self decorateButtons.
		 self contentsChanged.
		 contextVariablesInspector object: nil.
		 receiverInspector context: nil; inspect: self receiver.
		 ^self].
	isNewMethod := oldContext isNil
		or: [oldContext home method ~= (currentCompiledMethod := self selectedContext home method)].
	isNewMethod ifTrue:
		[contents := self selectedMessage.
		 self contentsChanged.
		 self pcRange].
	self changed: #contextStackIndex.
	self decorateButtons.
	contextVariablesInspector object: self selectedContext.
	self restoreContextVariablesInspectorState.
	receiverInspector context: self selectedContext; inspect: self receiver.
	self restoreReceiverInspectorState.
	isNewMethod ifFalse:
		[self changed: #contentsSelection]
]

{ #category : #'context stack menu' }
Debugger >> contextStackKey: aChar from: view [
	"Respond to a keystroke in the context list"

 	| selector |
	selector := ContextStackKeystrokes at: aChar ifAbsent: [nil].
	selector ifNil: [self messageListKey: aChar from: view]
		ifNotNil: [self perform: selector]
]

{ #category : #'context stack - message list' }
Debugger >> contextStackList [
	"Answer the array of contexts."

	^contextStackList
]

{ #category : #'context stack menu' }
Debugger >> contextStackMenu: aMenu shifted: shifted [
	"Set up the menu appropriately for the context-stack-list, either shifted or unshifted as per the parameter provided"

	^ self menu: aMenu for: #(contextStackMenu contextStackMenuShifted:) shifted: shifted

]

{ #category : #accessing }
Debugger >> contextStackTop [
	^ contextStack first.
]

{ #category : #accessing }
Debugger >> contextVariablesInspector [
	"Answer the instance of Inspector that is providing a view of the 
	variables of the selected context."

	^contextVariablesInspector
]

{ #category : #toolbuilder }
Debugger >> controlButtonsFrame [
	^LayoutFrame new
		leftFraction: 0 offset: 0;
		topFraction: 0 offset: 0;
		rightFraction: 1 offset: 0;
		bottomFraction: 0 offset: self buttonHeight
]

{ #category : #'context stack menu' }
Debugger >> copyBugReportToClipboard [

	| messageStream |
	messageStream := WriteStream on: (String new: 1500).
	self interruptedContext errorReportOn: messageStream.
	Clipboard clipboardText: messageStream contents.
]

{ #category : #'notifier buttons' }
Debugger >> createImplementingMethod [
	"Should only be called when this Debugger was created in response to a
	NotYetImplemented exception. All we need to do is pop the signalling context off the stack and open the #notYetImplemented method."
	| signallingContext |
	self initializeFull.
	signallingContext := self selectedContext sender.
	"Pop the signalling context off the stack"
	self resetContext: signallingContext.
	self debug.
]

{ #category : #'notifier buttons' }
Debugger >> createMethod [
	"Should only be called when this Debugger was created in response to a
	MessageNotUnderstood exception. Create a stub for the method that was
	missing and proceed into it."
	
	| msg chosenClass |
	self initializeFull.
	msg := self contextStackTop exceptionMessage.
	chosenClass := self
		askForSuperclassOf: self contextStackTop receiver class
		toImplement: msg selector
		ifCancel: [^self].
	self implementMissingMethod: msg inClass: chosenClass.
]

{ #category : #'notifier buttons' }
Debugger >> createOverridingMethod [
	"Should only be called when this Debugger was created in response to a
	SubclassResponsibility exception. Create a stub for the method that needs
	overriding and proceed into it. Let the user only select a class in the
	inheritance chain between the actual class and the class declaring the
	subclassResponsibility."
	| chosenClass msg category |
	self initializeFull.
	msg := self contextStackTop exceptionMessage.
	chosenClass := self
		askForSuperclassOf: self contextStackTop receiver class
		upTo: self contextStackTop sender method methodClass
		toImplement: msg selector
		ifCancel: [^self].
	"Use the same category as the marker method."
	category := self contextStackTop sender selectorCategory.
	self implementOverridingMethod: msg inClass: chosenClass inCategory: category.
]

{ #category : #initialize }
Debugger >> customButtonSpecs [
	"Answer an array of elements of the form wording, selector, help-message, that characterize the custom button row of a debugger."

	| list |
	list := #(('Proceed'	proceed				'Close the debugger and proceed.'	interruptedProcessShouldResume)
		('Restart'		restart				'Reset this context to its start.')
		('Into'			stepInto				'step Into message sends'	interruptedProcessIsActive)
		('Over'			stepOver				'step Over message sends'	interruptedProcessIsActive)
		('Through'		stepThrough		'step into a block'			interruptedProcessIsActive)
		('Full Stack'		showFullStack			'show full stack')
		('Where'		showWhere				'select current pc range')
		('Tally It'			tally				'evaluate current selection and measure the time')).
	(Preferences restartAlsoProceeds and: [self interruptedProcessShouldResume]) ifTrue:
		[list := list collect: [:each |
			each second == #restart
				ifTrue: [each copy
						at: 1 put: 'Proceed Here';
						at: 3 put: 'Proceed from the beginning of this context.';
						yourself]
				ifFalse: [each second == #proceed
					ifTrue: [each copy
							at: 1 put: 'Proceed Top';
							at: 3 put: 'Proceed from the current top context.';
							yourself]
					ifFalse: [each]]]].
	^ list
]

{ #category : #private }
Debugger >> cutBackExecutionToSenderContext [
	"When accepting a new version of a method which can't be simulated (i.e. a quick method) we
	 must cut back to the sender.  But this is non-trivial. If the quick method has been reached via
	 a perform: (as it is when one uses Create to implement a method from an MNU) then the relevant
	 arguments won't be on the stack and we can't simply proceed without crashing the VM."
	| oldContext context sel |
	oldContext := self selectedContext.
	self down.
	context := self selectedContext.
	context pc: context previousPc.
	sel := context selectorToSendOrSelf.
	sel numArgs = oldContext method numArgs
		ifTrue:
			[context push: oldContext receiver.
			 oldContext arguments do:
				[:arg| context push: arg]]
		ifFalse:
			[context privRefresh; stepToSendOrReturn]
]

{ #category : #'notifier menu' }
Debugger >> debug [
	"Open a full debugger."

	self openFullFromNotifier: self topView.

]

{ #category : #'notifier buttons' }
Debugger >> debugAt: anInteger [
	"Opens a full debugger with the given index selected. See #initializeFull to understand why contextStackIndex is set directly."
	
	contextStackIndex := anInteger.
	 ^ self debug
]

{ #category : #'context stack menu' }
Debugger >> debugProceedMenu: aMenu [
	^ aMenu labels: 
'proceed
debug'
	lines: #()
	selections: #(proceed debug )

]

{ #category : #'code pane menu' }
Debugger >> debuggerCodePaneMenu: aMenu [
	<codePaneMenu>
	<menuPriority: 200>
	^ aMenu
		add: 'run to here' target: self selector: #runToSelection: argument: self codePaneSelectionInterval;
		add: 'run until...' target: self selector: #runUntil;
		addLine;
		yourself

]

{ #category : #accessing }
Debugger >> debuggerMap [
	^self selectedContext debuggerMap
]

{ #category : #'user interface' }
Debugger >> defaultWindowColor [
	^ (Color r: 0.9 g: 0.719 b: 0.719)
]

{ #category : #'code pane' }
Debugger >> doItContext [
	"Answer the context in which a text selection can be evaluated."

	contextStackIndex = 0
		ifTrue: [^super doItContext]
		ifFalse: [^self selectedContext]
]

{ #category : #'code pane' }
Debugger >> doItReceiver [
	"Answer the object that should be informed of the result of evaluating a
	text selection."

	^self receiver
]

{ #category : #accessing }
Debugger >> doNothing: newText [
	"Notifier window can't accept text"
]

{ #category : #'context stack menu' }
Debugger >> doStep [
	"Send the selected message in the accessed method, and regain control 
	after the invoked method returns."
	
	| currentContext newContext |
	self okToChange ifFalse: [^ self].
	self checkContextSelection.
	currentContext := self selectedContext.
	newContext := self handleLabelUpdatesIn: [interruptedProcess completeStep: currentContext]
						whenExecuting: currentContext.
	newContext == currentContext ifTrue:
		[newContext := interruptedProcess stepToSendOrReturn].
	self contextStackIndex > 1
		ifTrue: [self resetContext: newContext]
		ifFalse:
			[newContext == currentContext
				ifTrue: [self changed: #contentsSelection.
						self updateInspectors]
				ifFalse: [self resetContext: newContext]].

]

{ #category : #'context stack menu' }
Debugger >> doStepUntil: condition [
	"Step until the given condition evaluates to other than false, reporting an error it if does not evaluate to true.
	
	If shift is pressed when the expression is supplied, don't update the UI. If shift is pressed while stepping, stop stepping. Using a user interrupt to break out would be more natural but Squeak currently doesn't provide a UserInterrupt exception. It should do."
	
	| currentContext newContext value lastUpdate updateUI breakOnShift |
	self okToChange ifFalse: [^ self].
	self checkContextSelection.
	currentContext := newContext := self selectedContext.
	lastUpdate := Time millisecondClockValue.
	updateUI := breakOnShift := Sensor shiftPressed not.
	
	Cursor execute showWhile: [[
		newContext == currentContext
			and: [currentContext willReturn not
			and: [(value := condition value) == false]] ] whileTrue: [
	
				self
					handleLabelUpdatesIn: [newContext := interruptedProcess completeStep: currentContext]
					whenExecuting: currentContext.
				newContext == currentContext ifTrue: [
					newContext := interruptedProcess stepToSendOrReturn.
					self resetContext: newContext changeContents: false].
	
				Time millisecondClockValue - lastUpdate > 250 "ms" ifTrue: [
					updateUI ifTrue: [
						self changed: #contentsSelection.
						Project current world displayWorldSafely].
					breakOnShift 
						ifTrue: [Sensor shiftPressed ifTrue: [
							self changed: #contentsSelection.
							self updateInspectors.
							^self]]
						ifFalse: [Sensor shiftPressed ifFalse: [breakOnShift := true]].
					 lastUpdate := Time millisecondClockValue] ]].
	
	self contextStackIndex > 1
		ifTrue: [self resetContext: newContext]
		ifFalse:
			[newContext == currentContext
				ifTrue: [self changed: #contentsSelection; updateInspectors]
				ifFalse: [self resetContext: newContext]].
			
	^ value

]

{ #category : #'context stack menu' }
Debugger >> down [
	"move down the context stack to the previous (enclosing) context"

	self toggleContextStackIndex: contextStackIndex+1
]

{ #category : #'context stack - message list' }
Debugger >> expandNotifierStack [
	"Show a small amount of stack in the context pane. Useful for notifiers."

	self okToChange ifFalse: [^ self].
	self newStack: (self contextStackTop stackOfSize: self class notifierStackSize).
	self changed: #contextStackList.

]

{ #category : #'context stack - message list' }
Debugger >> expandStack [
	"Show a substantial amount of stack in the context pane."

	self okToChange ifFalse: [^ self].
	self newStack: (self contextStackTop stackOfSize: (self class fullStackSize max: self class notifierStackSize)).
	self changed: #contextStackList.

]

{ #category : #private }
Debugger >> externalInterrupt: aBoolean [

	externalInterrupt := aBoolean 
]

{ #category : #'context stack (message list)' }
Debugger >> findCleanHomeBelow: method [

	| dirtyIndex |
	dirtyIndex := contextStack size + 1.
	contextStack reverse detect: [:context |
		dirtyIndex := dirtyIndex - 1.
		context home method = method homeMethod].
	^ dirtyIndex + 1
]

{ #category : #'context stack menu' }
Debugger >> fullStack [
	"Change from displaying the minimal stack to a full one."

	contextStack last sender isNil
		ifTrue:
			["Already expanded"
			self changed: #flash]
		ifFalse:
			[| oldContextStackIndex |
			oldContextStackIndex := contextStackIndex.
			self fullyExpandStack.
			oldContextStackIndex = contextStackIndex
				ifFalse:
					[self toggleContextStackIndex: oldContextStackIndex]]
]

{ #category : #'context stack - message list' }
Debugger >> fullyExpandStack [
	"Expand the stack to include all of it. Well, almost all of it, we better maintain sane limits too."

	self okToChange ifFalse: [^ self].
	self newStack: (self contextStackTop stackOfSize: self class stackSizeLimit - contextStack size).
	self changed: #contextStackList.
]

{ #category : #'tally support' }
Debugger >> getSelectedText [
	| m interval text |
	m := self codeTextMorph ifNil: [^ ''].
	interval := m selectionInterval.
	text := m text.
	^ text copyFrom: interval first to: interval last
	
]

{ #category : #'context stack menu' }
Debugger >> handleLabelUpdatesIn: aBlock whenExecuting: aContext [
	"Send the selected message in the accessed method, and regain control 
	after the invoked method returns."
	
	^aBlock
		on: Notification
		do: [:ex|
			(ex tag isArray
			 and: [ex tag size = 2
			 and: [(ex tag first == aContext or: [ex tag first hasSender: aContext])]])
				ifTrue:
					[self labelString: ex tag second description.
					 ex resume]
				ifFalse:
					[ex pass]]
]

{ #category : #'notifier support' }
Debugger >> implementMissingMethod: aMessage inClass: aClass [
	^ self
		implementMissingMethod: aMessage
		inClass: aClass
		inCategory: (self askForCategoryIn: aClass default: 'as yet unclassified').
]

{ #category : #'notifier support' }
Debugger >> implementMissingMethod: aMessage inClass: aClass inCategory: aSymbol [
	"Create a stub implementation of the missing message and sew it onto the top of the stack, ensuring the context's arguments are set correctly. Debug the new context."
	self pushStubMethodOnStack: aMessage inClass: aClass inCategory: aSymbol.

	"Cut out the sender context. This is the context that signalled the MessageNotUnderstood."
	self selectedContext privSender: self selectedContext sender.
	self resetContext: self selectedContext.
	self debug.
]

{ #category : #'notifier support' }
Debugger >> implementOverridingMethod: aMessage inClass: aClass inCategory: aSymbol [
	"Create a stub implementation of the overriding message and sew it onto the top of the stack, ensuring the context's arguments are set correctly. Debug the new context."
	self pushStubMethodOnStack: aMessage inClass: aClass inCategory: aSymbol.

	"Cut out the sender context. This is the context that signalled the SubclassResponsibility."
	self selectedContext privSender: self selectedContext sender sender.
	self resetContext: self selectedContext.
	self debug.
]

{ #category : #initialize }
Debugger >> initialExtent [
	"Initial extent for the full debugger. For the notifier's extent see #initialExtentForNotifier."
	
	^ SavedExtent ifNil: [ 600@700]
]

{ #category : #initialize }
Debugger >> initialExtentForNotifier [

	^ 450@200
]

{ #category : #initialize }
Debugger >> initialize [

	super initialize.

	Smalltalk at: #MessageTally ifPresentAndInMemory: [ :tally |
		tally terminateTimerProcess].

	externalInterrupt := false.
	selectingPC := true.
	
	contextStackIndex := 0.
]

{ #category : #initialize }
Debugger >> initializeFull [
	"Expand the stack for the full debugger. Create inspectors."
	
	| oldIndex |
	oldIndex := contextStackIndex.
	contextStackIndex := 0.
	
	self expandStack.

	receiverInspector := Inspector on: nil.
	contextVariablesInspector := ContextVariablesInspector on: nil.
	
	self toggleContextStackIndex: oldIndex.
]

{ #category : #accessing }
Debugger >> interruptedContext [
	"Answer the suspended context of the interrupted process."

	^self contextStackTop.
]

{ #category : #accessing }
Debugger >> interruptedProcess [
	"Answer the interrupted process."

	^interruptedProcess
]

{ #category : #testing }
Debugger >> interruptedProcessIsActive [
	^interruptedProcess isTerminated not
]

{ #category : #testing }
Debugger >> interruptedProcessShouldResume [
	^ interruptedProcess shouldResumeFromDebugger
]

{ #category : #testing }
Debugger >> isFull [

	^ self isNotifier not
]

{ #category : #testing }
Debugger >> isNotifier [

	^ receiverInspector isNil
]

{ #category : #'user interface' }
Debugger >> keyForContextVariablesInspectorState [
	
	^ self contextVariablesInspector object ifNotNil: [:ctxt | ctxt method]
]

{ #category : #'user interface' }
Debugger >> keyForReceiverInspectorState [

	^ self receiverInspector object
]

{ #category : #accessing }
Debugger >> labelString [
	^labelString
]

{ #category : #accessing }
Debugger >> labelString: aString [
	labelString := aString.
	self changed: #relabel
]

{ #category : #'context stack menu' }
Debugger >> mailOutBugReport [
	"Compose a useful bug report showing the state of the process as well as vital image statistics as suggested by Chris Norton - 
'Squeak could pre-fill the bug form with lots of vital, but
oft-repeated, information like what is the image version, last update
number, VM version, platform, available RAM, author...'

and address it to the list with the appropriate subject prefix."

	MailSender default ifNil: [^self].

	Cursor write
		showWhile: 
			["Prepare the message"
			| messageStrm |
			messageStrm := WriteStream on: (String new: 1500).
			messageStrm nextPutAll: 'From: ';
			 nextPutAll: MailSender userName;
			 cr;
			 nextPutAll: 'To: squeak-dev@lists.squeakfoundation.org';
			 cr;
			 nextPutAll: 'Subject: ';
			 nextPutAll: '[BUG]'; nextPutAll: self interruptedContext printString;
			 cr;cr;
			 nextPutAll: 'here insert explanation of what you were doing, suspect changes you''ve made and so forth.';cr;cr.
			self interruptedContext errorReportOn: messageStrm.

			MailSender sendMessage: (MailMessage from: messageStrm contents)].

]

{ #category : #'context stack menu' }
Debugger >> mainContextStackMenu: aMenu [
	"Set up the menu appropriately for the context-stack-list, unshifted"
	<contextStackMenuShifted: false>
	^ aMenu addList: #(
			('fullStack (f)' 				fullStack) 
			('restart (r)' 				restart) 
			('proceed (p)' 				proceed) 
			('step (t)' 					doStep) 
			('step through (T)'	 		stepIntoBlock) 
			('send (e)' 					send) 
			('where (w)' 				where) 
			('peel to first like this' 		peelToFirst) 
			- 
			('return entered value' 		returnValue) 
			- 
			('toggle break on entry'	toggleBreakOnEntry) 
			('senders of    (n)' 			browseSendersOfMessages) 
			('implementors of    (m)' 	browseMessages) 
			('inheritance (i)' 			methodHierarchy) 
			- 
			('versions (v)' 				browseVersions) 
			- 
			('references    (r)' 			browseVariableReferences) 
			('assignments    (a)' 		browseVariableAssignments) 
			- 
			('class refs (N)' 				browseClassRefs) 
			('browse full (b)' 			browseMethodFull) 
			('file out ' 			 		fileOutMessage) 
			('remove method (x) ' 		removeMessage) 
			- 
			('copy bug report to clipboard'	copyBugReportToClipboard));
		yourself

]

{ #category : #'context stack - message list' }
Debugger >> messageHelpAt: anIndex [
	"Show the first n lines of the sources code of the selected message."
	
	| method |
	Preferences balloonHelpInMessageLists ifFalse: [^ nil].
	contextStack size < anIndex ifTrue: [^ nil].
	
	method := (contextStack at: anIndex) method.
	^ self messageHelpForMethod: method.
]

{ #category : #'context stack - message list' }
Debugger >> messageIconAt: anIndex [

	Browser showMessageIcons
		ifFalse: [^ nil].

	^ ToolIcons iconNamed: (ToolIcons
		iconForClass: (contextStack at: anIndex) method methodClass
		selector: (contextStack at: anIndex) method selector)
]

{ #category : #'context stack - message list' }
Debugger >> messageListIndex [
	"Answer the index of the currently selected context."

	^contextStackIndex
]

{ #category : #'context stack menu' }
Debugger >> messageListMenu: aMenu shifted: shifted [
	"The context-stack menu takes the place of the message-list menu in the debugger, so pass it on"

	^ self contextStackMenu: aMenu shifted: shifted
]

{ #category : #'user interface' }
Debugger >> modelWakeUpIn: aWindow [

	super modelWakeUpIn: aWindow.
	self updateInspectors.
]

{ #category : #private }
Debugger >> newStack: stack [
	| oldStack diff matchIndex |
	oldStack := contextStack.
	contextStack := stack.
	(oldStack isNil or: [oldStack last ~~ stack last]) ifTrue:
		[contextStackList := stack collect: [:ctx | ctx printString].
		 ^self].
	"May be able to re-use some of previous list"
	diff := stack size - oldStack size.
	contextStackList := diff <= 0
		ifTrue: [contextStackList copyFrom: 1 - diff to: oldStack size]
		ifFalse:
			[matchIndex := stack lastIndexOf: oldStack first startingAt: diff + 1.
			 matchIndex = 0
				ifTrue: [contextStack collect: [:ctx | ctx printString]]
				ifFalse: [((contextStack first: matchIndex - 1) collect: [:ctx| ctx printString]), contextStackList]]
						"#(d e f h i) => #(a b c d e f g h i)
						diff := 3.
						matchIndex := 4.
						#(a b c d e f g h i) := #(a b c), #(d e f h i)"
]

{ #category : #initialize }
Debugger >> openFullFromNotifier: topView [
	"Create a full debugger with the given label. Subclasses should complete this procedure."

	self initializeFull.
	
	topView model: nil.  "so close won't release me."
	self breakDependents.
]

{ #category : #initialize }
Debugger >> openFullNoSuspendLabel: aString [
	"Create, schedule and answer a full debugger with the given label. Subclasses should complete this procedure."

	self initializeFull.
]

{ #category : #initialize }
Debugger >> openNotifierNoSuspendContents: msgString label: label [
	"Create, schedule and answer a notifier view with the given label and message. A notifier view shows just the message or the first several lines of the stack, with a menu that allows the user to open a full debugger if so desired."
	"NOTE: When this method returns, a new process has been scheduled to run the windows, and thus this notifier, but the previous active process has not been suspended.  The sender will do this."

	savedCursor := Cursor currentCursor.
	Cursor currentCursor: Cursor normal.
	
	self expandNotifierStack.
]

{ #category : #toolbuilder }
Debugger >> optionalButtonsFrame [
	^LayoutFrame new
		leftFraction: 0 offset: 0;
		topFraction: 0 offset: self buttonHeight;
		rightFraction: 1 offset: 0;
		bottomFraction: 0 offset: self buttonHeight*2
]

{ #category : #'code pane' }
Debugger >> pc [

	^ self pcRange
]

{ #category : #'code pane' }
Debugger >> pcRange [
	"Answer the indices in the source code for the method corresponding to 
	the selected context's program counter value."

	| ctxt |
	(selectingPC and: [contextStackIndex ~= 0]) ifFalse:
		[^1 to: 0].
	(ctxt := self selectedContext) isDead ifTrue:
		[^1 to: 0].
	^ctxt debuggerMap
		rangeForPC: ctxt pc
		in: ctxt method
		contextIsActiveContext: contextStackIndex = 1
]

{ #category : #'context stack menu' }
Debugger >> peelToFirst [
	"Peel the stack back to the second occurance of the currently selected message.  Very useful for an infinite recursion.  Gets back to the second call so you can see one complete recursion cycle, and how it was called at the beginning.  Also frees a lot of space!"

	| ctxt |
	contextStackIndex = 0 ifTrue: [^ Beeper beep].
	"self okToChange ifFalse: [^ self]."
	ctxt := interruptedProcess popTo: self selectedContext findSecondToOldestSimilarSender.
	self resetContext: ctxt.

]

{ #category : #'code pane menu' }
Debugger >> perform: selector orSendTo: otherTarget [
	"Selector was just chosen from a menu by a user.  If can respond, then perform it on myself.  If not, send it to otherTarget, presumably the editPane from which the menu was invoked." 

	| result |
	(#(debug proceed) includes: selector)		"When I am a notifier window"
		ifTrue: [^ self perform: selector]
		ifFalse: [result := super perform: selector orSendTo: otherTarget.
				selector == #doIt ifTrue: [
					result ~~ #failedDoit ifTrue: [self proceedValue: result]].
				^ result]
]

{ #category : #toolbuilder }
Debugger >> preDebugButtonQuadFrame [
	^LayoutFrame new
		leftFraction: 0 offset: 0;
		topFraction: 0 offset: 0;
		rightFraction: 1 offset: 0;
		bottomFraction: 0 offset: self buttonHeight.
]

{ #category : #initialize }
Debugger >> preDebugButtonQuads [

	^Preferences eToyFriendly
		ifTrue: [
	{
	{'Send error report' translated.	#sendReport. 	#blue. 	'send a report of the encountered problem to the Squeak developers' translated}.
	{'Abandon' translated.	#abandon. 	#black.	'abandon this execution by closing this window' translated}.
	{'Debug'	 translated.		#debug. 	#red. 	'bring up a debugger' translated}}]
		ifFalse: [
	{
	{'Proceed' translated.	#proceed. 	#blue. 	'continue execution' translated. #interruptedProcessShouldResume}.
	{'Abandon' translated.	#abandon. 	#black.	'abandon this execution by closing this window' translated}.
	{'Debug'	 translated.		#debug.		#red. 	'bring up a debugger' translated}}]

]

{ #category : #toolbuilder }
Debugger >> preDebugMessageString [
	^ message ifNil: [
			String streamContents: [:s | 
				s nextPutAll: 'An error has occurred, sorry! You could send the Squeak developers an error report or just hit ''Abandon''.

In the error report, there is no personal information, only information that we can use to investigate the error. If you decide to send us the error report, it will include the following text:

' translated.
				[s nextPutAll: self contextStackTop printString; cr.
				self contextStackTop errorReportOn: s] on: Error do: [s nextPutAll: 'no text, there was an error creating the error report' translated]]].
]

{ #category : #'context stack menu' }
Debugger >> proceed [
	"Proceed from the interrupted state of the currently selected context. The argument is the topView of the receiver. That view is closed. The active process usually suspends (or terminates) after this call."

	| processToResume canResume |

	Smalltalk okayToProceedEvenIfSpaceIsLow ifFalse: [^ self].
	
	self okToChange ifFalse: [^ self].
	self checkContextSelection.
	
	processToResume := interruptedProcess.
	canResume := self interruptedProcessShouldResume.
	
	interruptedProcess := nil. "Before delete, so release doesn't terminate it"
	self close.
	
	savedCursor ifNotNil: [Cursor currentCursor: savedCursor].
	Project current restoreDisplay.
	
	Smalltalk installLowSpaceWatcher. "restart low space handler"
	
	canResume
		ifTrue: [self resumeProcess: processToResume]
		ifFalse: [self notify: 'This process should not resume.\Debugger will close now.' withCRs].
]

{ #category : #accessing }
Debugger >> proceedValue [
	"Answer the value to return to the selected context when the interrupted 
	process proceeds."

	^proceedValue
]

{ #category : #accessing }
Debugger >> proceedValue: anObject [ 
	"Set the value to be returned to the selected context when the interrupted 
	process proceeds."

	proceedValue := anObject
]

{ #category : #initialize }
Debugger >> process: aProcess context: aContext [

	interruptedProcess := aProcess.

	self newStack: (aContext stackOfSize: 1).
	contextStackIndex := 1.
]

{ #category : #private }
Debugger >> pushStubMethodOnStack: aMessage inClass: aClass inCategory: aSymbol [
	"Create a stub implementation of the message and sew it onto the top of the stack, ensuring the context's arguments are set correctly."
	aClass
		compile: aMessage createStubMethod
		classified: aSymbol.
	self setContentsToForceRefetch.
	self selectedContext privRefreshWith: (aClass lookupSelector: aMessage selector).
	aMessage numArgs > 0 ifTrue:
		[aMessage arguments withIndexDo:
			[:arg :index|
			self selectedContext tempAt: index put: arg]].
]

{ #category : #accessing }
Debugger >> receiver [
	"Answer the receiver of the selected context, if any. Answer nil 
	otherwise."

	contextStackIndex = 0
		ifTrue: [^nil]
		ifFalse: [^self selectedContext receiver]
]

{ #category : #toolbuilder }
Debugger >> receiverClass [
	^ self selectedContext receiver class
]

{ #category : #accessing }
Debugger >> receiverInspector [
	"Answer the instance of Inspector that is providing a view of the 
	variables of the selected context's receiver."

	^receiverInspector
]

{ #category : #'context stack menu' }
Debugger >> removeMessage [
	
	| oldContext method cleanIndex confirmation  |
	self okToChange ifFalse: [^ false].
	contextStackIndex isZero ifTrue: [^ false].
	
	oldContext := self selectedContext.
	method := oldContext method.
	cleanIndex := self findCleanHomeBelow: method.
	contextStack at: cleanIndex ifAbsent: [
		self inform: 'Sender of method not found on stack, can''t remove message'.
		^ false].
	(self confirm: 'I will have to revert to the sender of this message.  Is that OK?')
		ifFalse: [^ false].
	
	confirmation := self systemNavigation
		confirmRemovalOf: method selector
		on: method methodClass.
	confirmation = 3 ifTrue: [^ self].
	self selectedClassOrMetaClass removeSelector: method selector.
	
	self
		contextStackIndex: cleanIndex oldContextWas: oldContext;
		tryRestartFrom: self selectedContext.
	confirmation = 2
		ifTrue: [self systemNavigation browseAllCallsOn: method selector].
]

{ #category : #private }
Debugger >> resetContext: aContext [ 
	^ self resetContext: aContext changeContents: true
]

{ #category : #private }
Debugger >> resetContext: aContext changeContents: aBoolean [
	"Used when a new context becomes top-of-stack, for instance when the
	method of the selected context is re-compiled, or the simulator steps or
	returns to a new method. There is room for much optimization here, first
	to save recomputing the whole stack list (and text), and secondly to avoid
	recomposing all that text (by editing the paragraph instead of recreating it)."

	| oldContext |
	oldContext := self selectedContext.
	self newStack: (aContext ifNil: [oldContext]) contextStack.
	self changed: #contextStackList; changed: #interruptedProcessIsActive.
	self contextStackIndex: 1 oldContextWas: oldContext.
	aBoolean ifTrue: [self contentsChanged].

]

{ #category : #'context stack menu' }
Debugger >> restart [
	"Proceed from the initial state of the currently selected context. The 
	argument is a controller on a view of the receiver. That view is closed."
	"Closing now depends on a preference #restartAlsoProceeds - hmm 9/7/2001 16:46"

	| unwindError |
	self okToChange ifFalse: [^ self].
	self checkContextSelection.
	unwindError := self tryRestartFrom: self selectedContext.
	((Preferences restartAlsoProceeds
		and: [unwindError not])
		and: [self interruptedProcessShouldResume])
			ifTrue: [self proceed].
]

{ #category : #'user interface' }
Debugger >> restoreContextVariablesInspectorState [
	"For the user's convenience. Save field selection and user-typed content in the context-variables inspector. See #saveContextVariablesInspectorState."

	contextVariablesInspectorState ifNotNil: [:stateForAll |
		self keyForContextVariablesInspectorState ifNotNil: [:keyForState |
			stateForAll 
				at: keyForState
				ifPresent: [:state |
					self contextVariablesInspector selectFieldNamed: state first.
					state second ifNotNil: [:contentsTyped |
						self contextVariablesInspector
							setContentsTyped: contentsTyped]]]].
]

{ #category : #'user interface' }
Debugger >> restoreReceiverInspectorState [
	"For the user's convenience. Restore field selection and user-typed content in the receiver inspector. See #saveReceiverInspectorState."
	
	receiverInspectorState ifNotNil: [:stateForAll |
		self keyForReceiverInspectorState ifNotNil: [:keyForState |
			stateForAll 
				at: keyForState
				ifPresent: [:state |
					self receiverInspector selectFieldNamed: state first.
					state second ifNotNil: [:contentsTyped |
						self receiverInspector
							setContentsTyped: contentsTyped]]]].
]

{ #category : #private }
Debugger >> resumeProcess: aProcess [
	"Subclusses may override this to avoid having duplicate UI processes."
	
	aProcess resume.
]

{ #category : #'context stack menu' }
Debugger >> returnValue [
	"Force a return of a given value to the previous context!"

	| previous selectedContext expression value |
	contextStackIndex = 0 ifTrue: [^Beeper beep].
	selectedContext := self selectedContext.
	expression := UIManager default request: 'Enter expression for return value:'.
	value := Compiler new 
				evaluate: expression
				in: selectedContext
				to: selectedContext receiver.
	previous := selectedContext sender.
	self resetContext: previous.
	interruptedProcess popTo: previous value: value
]

{ #category : #'code pane menu' }
Debugger >> runToSelection: selectionInterval [

	self pc first >= selectionInterval first ifTrue: [ ^self ].
	self doStepUntil: [ self pc first >= selectionInterval first ].
]

{ #category : #'code pane menu' }
Debugger >> runUntil [
	"Step until an expression evaluates to other than false, reporting an error if it doesn't evaluate to true. Remember the expression in an inst var."

	| expression receiver context method value |
	expression := UIManager default 
					request: 'run until expression is true (shift to disable ui update; shift to break).'
					initialAnswer: (untilExpression ifNil: 'boolean expression').
	(expression isNil or: [expression isEmpty]) ifTrue:
		[^self].
	untilExpression := expression.
	context := self selectedContext.
	receiver := context receiver.
	method := receiver class evaluatorClass new 
				compiledMethodFor: untilExpression
				in: context
				to: receiver
				notifying: nil
				ifFail: [^ #failedDoit].

	value := self doStepUntil: [method valueWithReceiver: receiver arguments: {context}].
		
	(value ~~ false and: [value ~~ true]) ifTrue:
		[UIManager default inform: 'expression ', (untilExpression contractTo: 40), ' answered ', (value printString contractTo: 20), '!!']
]

{ #category : #'user interface' }
Debugger >> saveContextVariablesInspectorState [
	"For the user's convenience. Save field selection and user-typed content in the context-variables inspector. See #restoreContextVariablesInspectorState."
	
	| stateToSave keyForState |
	self flag: #duplication.
	(keyForState := self keyForContextVariablesInspectorState)
		ifNil: [^ self].
	contextVariablesInspectorState
		ifNil: [contextVariablesInspectorState := IdentityDictionary new].
	stateToSave := {
		self contextVariablesInspector selectedFieldName.
		self contextVariablesInspector contentsTyped }.
	contextVariablesInspectorState
		at: keyForState
		put: stateToSave.
]

{ #category : #'user interface' }
Debugger >> saveReceiverInspectorState [
	"For the user's convenience. Save field selection and user-typed content in the receiver inspector. See #restoreReceiverInspectorState."

	| stateToSave keyForState |
	self flag: #duplication.
	(keyForState := self keyForReceiverInspectorState)
		ifNil: [^ self].
	receiverInspectorState
		ifNil: [receiverInspectorState := IdentityDictionary new].
	stateToSave := {
		self receiverInspector selectedFieldName.
		self receiverInspector contentsTyped }.
	receiverInspectorState
		at: keyForState
		put: stateToSave.
]

{ #category : #'context stack menu' }
Debugger >> selectPC [
	"Toggle the flag telling whether to automatically select the expression 
	currently being executed by the selected context."

	selectingPC := selectingPC not
]

{ #category : #'class list' }
Debugger >> selectedClass [
	"Answer the class in which the currently selected context's method was 
	found."

	^self selectedContext methodClass
]

{ #category : #'class list' }
Debugger >> selectedClassOrMetaClass [
	"Answer the class in which the currently selected context's method was 
	found."

	^self selectedClass
]

{ #category : #private }
Debugger >> selectedContext [

	contextStackIndex = 0
		ifTrue: [^contextStack first]
		ifFalse: [^contextStack at: contextStackIndex]
]

{ #category : #'context stack - message list' }
Debugger >> selectedMessage [
	"Answer the source code of the currently selected context."
	| aContext |
	^contents := (aContext := self selectedContext) debuggerMap sourceText asText makeSelectorBoldIn: aContext home receiver class
]

{ #category : #'message category list' }
Debugger >> selectedMessageCategoryName [
	"Answer the name of the message category of the message of the 
	currently selected context."

	^self selectedClass organization categoryOfElement: self selectedMessageName
]

{ #category : #'context stack - message list' }
Debugger >> selectedMessageName [
	"Answer the message selector of the currently selected context.
	 If the method is unbound we can still usefully answer its old selector."

	| selector |
	selector := self selectedContext selector.
	^(selector ~~ self selectedContext method selector
	    and: [selector beginsWith: 'DoIt'])
		ifTrue: [self selectedContext method selector]
		ifFalse: [selector]
]

{ #category : #'context stack menu' }
Debugger >> send [
	"Send the selected message in the accessed method, and take control in 
	the method invoked to allow further step or send."

	self okToChange ifFalse: [^ self].
	self checkContextSelection.
	interruptedProcess step: self selectedContext.
	self resetContext: interruptedProcess stepToSendOrReturn.

]

{ #category : #'notifier menu' }
Debugger >> sendReport [
	[| errorReport |
	errorReport := String streamContents: [:s |
		s nextPutAll: self contextStackTop printString; cr.
		self contextStackTop errorReportOn: s].
	(Smalltalk classNamed: #WebClient)
		ifNotNil: [:wc |
			wc
				httpPost: self class errorReportServer
				content: errorReport
				type: 'text/plain']] on: Error do: ["nothing"].
	self abandon.
]

{ #category : #'context stack menu' }
Debugger >> shiftedContextStackMenu: aMenu [
	"Set up the menu appropriately for the context-stack-list, shifted"
	<contextStackMenuShifted: true>
	^ aMenu addList: #(
			('browse class hierarchy'				browseClassHierarchy)
			('browse class'							browseClass)
			('implementors of sent messages'		browseAllMessages)
			('change sets with this method'			findMethodInChangeSets)
			-	
			('inspect instances'						inspectInstances)
			('inspect subinstances'					inspectSubInstances)
			-	
			('revert to previous version'			revertToPreviousVersion)
			('remove from current change set'		removeFromCurrentChanges)
			('revert & remove from changes'		revertAndForget));
		yourself

]

{ #category : #'actions - convenience' }
Debugger >> showFullStack [

	self fullStack.
]

{ #category : #'actions - convenience' }
Debugger >> showWhere [
	"Select the PC range"
	
	self where.
]

{ #category : #'stepping - morphic' }
Debugger >> step [ 
	"Update the inspectors."

	receiverInspector ifNotNil: [receiverInspector step].
	contextVariablesInspector ifNotNil: [contextVariablesInspector step].

]

{ #category : #'actions - convenience' }
Debugger >> stepInto [

	self send.
]

{ #category : #'context stack menu' }
Debugger >> stepIntoBlock [
	"Send messages until you return to the present method context.
	 Used to step into a block in the method."

	self handleLabelUpdatesIn:
			[interruptedProcess stepToHome: self selectedContext]
		whenExecuting: self selectedContext.
	self resetContext: interruptedProcess stepToSendOrReturn
]

{ #category : #'actions - convenience' }
Debugger >> stepOver [

	self doStep.
]

{ #category : #'actions - convenience' }
Debugger >> stepThrough [

	self stepIntoBlock.
]

{ #category : #'notifier menu' }
Debugger >> storeLog [

	Smalltalk logSqueakError: labelString printString inContext: self contextStackTop

]

{ #category : #'tally support' }
Debugger >> tally [

	self codeTextMorph ifNotNil: [:o| o tallyIt] ifNil: [Beeper beep]

]

{ #category : #controls }
Debugger >> tallyMenu: aMenu [

	^ aMenu
		"title: 'Tally' translated;" flag: #todo; "ct: Implement on PluggableMenuSpec"
		addTranslatedList: #(
			('Tally selection'	tallyIt	'evaluate current selection and measure the time')
			('Record send'	doRecord 'record next message send'));
		yourself
]

{ #category : #toolbuilder }
Debugger >> textFrame [
	
	^ super textFrame
		topOffset: (self wantsOptionalButtons ifTrue: [self buttonHeight * 2] ifFalse: [self buttonHeight]);
		yourself
]

{ #category : #'context stack - message list' }
Debugger >> toggleContextStackIndex: anInteger [ 
	"If anInteger is the same as the index of the selected context, deselect it. 
	Otherwise, the context whose index is anInteger becomes the selected 
	context."

	self contextStackIndex: 
		(contextStackIndex = anInteger
			ifTrue: [0]
			ifFalse: [anInteger])
		oldContextWas:
		(contextStackIndex = 0
			ifTrue: [nil]
			ifFalse: [contextStack at: contextStackIndex])
]

{ #category : #'context stack menu' }
Debugger >> tryRestartFrom: context [
	"Try to restart from the initial state of the context.
	Return whether an unwind error occurred."

	| actualContext unwindError |
	actualContext := interruptedProcess popTo: context.
	unwindError := actualContext ~= context.
	unwindError ifFalse: [
		interruptedProcess restartTop; stepToSendOrReturn].
	self resetContext: actualContext.
	^ unwindError
]

{ #category : #'context stack menu' }
Debugger >> up [
	"move up the context stack to the next (enclosed) context"

	contextStackIndex > 1 ifTrue: [self toggleContextStackIndex: contextStackIndex-1]
]

{ #category : #'self-updating' }
Debugger >> updateCodePaneIfNeeded [
	"Ignore. We must not update code but stick to particular compiled methods on the stack."
]

{ #category : #'stepping - morphic' }
Debugger >> updateInspectors [ 
	"Update the inspectors on the receiver's variables."

	receiverInspector == nil ifFalse: [receiverInspector update].
	contextVariablesInspector == nil ifFalse: [contextVariablesInspector update]
]

{ #category : #toolbuilder }
Debugger >> wantsAnnotationPane [

	^ self class wantsAnnotationPane
]

{ #category : #toolbuilder }
Debugger >> wantsCodeProvenanceButton [

	^ false
]

{ #category : #toolbuilder }
Debugger >> wantsOptionalButtons [
	"The debugger benefits so majorly from the optional buttons that we put them up regardless of the global setting.  Some traditionalists will want to change this method manually!"

	^ Preferences extraDebuggerButtons
]

{ #category : #'stepping - morphic' }
Debugger >> wantsSteps [
 
	^ true
]

{ #category : #'context stack menu' }
Debugger >> where [
	"Select the expression whose evaluation was interrupted."

	selectingPC := true.
	self contextStackIndex: contextStackIndex oldContextWas: self selectedContext

]

{ #category : #initialize }
Debugger >> windowIsClosing [
	"My window is being closed; clean up. Restart the low space watcher."

	interruptedProcess == nil ifTrue: [^ self].
	interruptedProcess terminate.
	interruptedProcess := nil.
	
	contextStack := nil.
	receiverInspector := nil.
	contextVariablesInspector := nil.
	Smalltalk installLowSpaceWatcher.  "restart low space handler"

]
