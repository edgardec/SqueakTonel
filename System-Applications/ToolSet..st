"
ToolSet defines an interface that clients can use to request programmer facilities such as browsers, inspectors, debuggers, message sets etc.
"
Class {
	#name : #ToolSet,
	#superclass : #AppRegistry,
	#category : #'System-Applications'
}

{ #category : #accessing }
ToolSet class >> askForDefault [
	"Ask for the default implementor"
	self registeredClasses isEmpty 
		ifTrue:[^ default := nil].
	self registeredClasses size = 1 
		ifTrue:[^ default := self registeredClasses anyOne].
	default := UIManager default 
		chooseFrom: (self registeredClasses collect:[:each| each name printString])
		values: self registeredClasses
		title: 'Which ', self appName, ' would you prefer?'.
	^default.
]

{ #category : #inspecting }
ToolSet class >> basicInspect: anObject [
	"Open an inspector on the given object. The tool set must know which inspector type to use for which object - the object cannot possibly know what kind of inspectors the toolset provides."
	self default ifNil:[^self inform: 'Cannot inspect -- no Inspector present'].
	^self default basicInspect: anObject
]

{ #category : #browsing }
ToolSet class >> browse: aClass selector: aSelector [
	"Open a browser"
	self default ifNil:[^self inform: 'Cannot open Browser'].
	^self default browse: aClass selector: aSelector
]

{ #category : #browsing }
ToolSet class >> browseCategory: aCategory [

	self default ifNil: [^ self inform: 'Cannot open Browser'].
	^ self default browseCategory: aCategory
]

{ #category : #browsing }
ToolSet class >> browseChangeSetsWithClass: aClass selector: aSelector [
	"Browse all the change sets with the given class/selector"
	self default ifNil:[^self inform: 'No ChangeSorter present'].
	^self default browseChangeSetsWithClass: aClass selector: aSelector
]

{ #category : #browsing }
ToolSet class >> browseClass: aClass [
	"Open a browser"
	self default ifNil:[^self inform: 'Cannot open Browser'].
	^self default browseClass: aClass.
]

{ #category : #browsing }
ToolSet class >> browseClass: aClass category: aCategory [
	"Open a browser"
	self default ifNil:[^self inform: 'Cannot open Browser'].
	^self default browseClass: aClass category: aCategory
]

{ #category : #browsing }
ToolSet class >> browseHierarchy: aClass selector: aSelector [
	"Open a browser"
	self default ifNil:[^self inform: 'No browser present'].
	^self default browseHierarchy: aClass selector: aSelector
]

{ #category : #browsing }
ToolSet class >> browseMessageCategory: aCategory inClass: aClass [
	"Open a message category browser."
	self default ifNil:[^self inform: 'Cannot open Browser'].
	^self default browseMessageCategory: aCategory inClass: aClass
]

{ #category : #browsing }
ToolSet class >> browseMessageNames: aString [
	"Open a MessageNames browser"
	self default ifNil:[^self inform: 'No MessageNames present'].
	^self default browseMessageNames: aString
]

{ #category : #browsing }
ToolSet class >> browseMessageSet: messageList name: title autoSelect: autoSelectString [
	"Open a message set browser"
	self default ifNil:[^self inform: 'Cannot open MessageSet'].
	^self default browseMessageSet: messageList name: title autoSelect: autoSelectString
]

{ #category : #browsing }
ToolSet class >> browseMethod: aCompiledMethod [
	
	self default ifNil: [^ self inform: 'Cannot open Browser'].
	^ self default browseMethod: aCompiledMethod
]

{ #category : #browsing }
ToolSet class >> browseMethodVersion: aCompiledMethod [
	
	self default ifNil:[^self inform: 'Cannot open Browser'].
	^self default browseMethodVersion: aCompiledMethod
]

{ #category : #browsing }
ToolSet class >> browsePackage: aPackageInfo [

	self default ifNil: [^ self inform: 'Cannot open Browser'].
	^ self default browsePackage: aPackageInfo
]

{ #category : #browsing }
ToolSet class >> browseVersionsOf: aClass selector: aSelector [
	"Open a browser"
	self default ifNil:[^self inform: 'Cannot open Browser'].
	^self default browseVersionsOf: aClass selector: aSelector
]

{ #category : #completion }
ToolSet class >> codeCompletionAround: aBlock textMorph: aTextMorph keyStroke: evt [
	self default ifNil: [aBlock value. ^ self].
	self default codeCompletionAround: aBlock textMorph: aTextMorph keyStroke: evt
]

{ #category : #debugging }
ToolSet class >> debugException: anException [
	"For convenience. Enable users to debug an exception that occurred in the active process later on. Note that the active process is the process where the exception was raised, which might not be the current ui process. It is okay to ignore this request in a custom toolset.
	
	Example print-it: 
	
	[ self halt. 3+4 ]
		on: Halt do: [:ex | ToolSet debugException: ex. ex resume] "

	^ self default ifNotNil: [:ts |ts debugException: anException]
]

{ #category : #debugging }
ToolSet class >> debugProcess: aProcess context: aContext label: aString contents: contents fullView: aBool [
	"Open a debugger on the given process, which might be active, suspended, or terminated."

	^ self default
		ifNil: [(self confirm: 'Debugger request -- proceed?') ifFalse: [Processor terminateActive]]
		ifNotNil: [:ts | ts debugProcess: aProcess context: aContext label: aString contents: contents fullView: aBool]
]

{ #category : #debugging }
ToolSet class >> debugSyntaxError: aSyntaxErrorNotification [
	"Opens a tool to let the user correct the syntax error, which then resumes the compiler process."
	
	^ self default
		ifNil: [Project uiManager edit: aSyntaxErrorNotification errorCode label: 'Syntax Error (read only)']
		ifNotNil: [:ts | ts debugSyntaxError: aSyntaxErrorNotification]
]

{ #category : #inspecting }
ToolSet class >> explore: anObject [
	"Open an explorer on the given object."
	self default ifNil:[^self inform: 'Cannot explore - no ToolSet present'].
	^self default explore: anObject
]

{ #category : #inspecting }
ToolSet class >> explore: anObject label: aString [
	"Open an explorer on the given object."
	self default ifNil:[^self inform: 'Cannot explore - no ToolSet present'].
	^self default explore: anObject label: aString
]

{ #category : #'debugging - handlers' }
ToolSet class >> handleError: anError [
	"No exception handler caught the given error. Let the user handle that error through an interactive tool such as a debugger.
	
	THE ACTIVE PROCESS *IS* WHERE THE ERROR HAPPENED."

	^ self default
		ifNil: [ | ctx |
			Smalltalk 
				logSqueakError: anError description 
				inContext: (ctx := anError signalerContext) .
			self inform: (anError description, String cr, ctx shortStack).
			anError return "Maybe better teminate process?"]
		ifNotNil: [:ts | ts handleError: anError]
]

{ #category : #'debugging - handlers' }
ToolSet class >> handleRecursiveError: description [
	"THE ACTIVE PROCESS *IS* WHERE THE RECURSION WAS DETECTED."
	
	^ self default
		ifNil: [Project current primitiveError: description]
		ifNotNil: [:ts | ts handleRecursiveError: description]
]

{ #category : #'debugging - handlers' }
ToolSet class >> handleSyntaxError: anError [
	"A syntax error (notification) occurred while parsing and compiling source code. Usually, the compiling process suspends until the syntax error gets corrected.
	
	THE ACTIVE PROCESS *IS* THAT COMPILER PROCESS."

	^ self default
		ifNil: [self handleError: anError]
		ifNotNil: [:ts | ts handleSyntaxError: anError]
]

{ #category : #'debugging - handlers' }
ToolSet class >> handleUserInterruptRequest: aString [
	"The user wants to interrupt a process, which might be unresponsive, to debug it.
	
	THE ACTIVE PROCESS *IS* A HELPER PROCESS with a priority higher than the preempted one. See EventSensor >> #userInterruptWatcher."

	^ self default
		ifNil: [self inform: 'No handler for user interrupts found.']
		ifNotNil: [:ts | ts handleUserInterruptRequest: aString]
]

{ #category : #'debugging - handlers' }
ToolSet class >> handleWarning: aWarning [
	"No exception handler caught the given warning. Let the user handle that warning through an interactive tool such as a debugger.
	
	THE ACTIVE PROCESS *IS* WHERE THE WARNING HAPPENED."

	^ self default
		ifNil: [
			self inform: (aWarning messageText, String cr, aWarning signalerContext shortStack).
			aWarning resume]
		ifNotNil: [:ts | ts handleWarning: aWarning]
]

{ #category : #inspecting }
ToolSet class >> inspect: anObject [
	"Open an inspector on the given object. The tool set must know which inspector type to use for which object - the object cannot possibly know what kind of inspectors the toolset provides."
	self default ifNil:[^self inform: 'Cannot inspect - no ToolSet present'].
	^self default inspect: anObject
]

{ #category : #inspecting }
ToolSet class >> inspect: anObject label: aString [
	"Open an inspector on the given object. The tool set must know which inspector type to use for which object - the object cannot possibly know what kind of inspectors the toolset provides."
	self default ifNil:[^self inform: 'Cannot inspect - no ToolSet present'].
	^self default inspect: anObject label: aString
]

{ #category : #menu }
ToolSet class >> menuItems [
	"Answer the menu items available for this tool set"
	self default ifNil:[^#()].
	^self default menuItems
]

{ #category : #browsing }
ToolSet class >> openChangedMessageSet: aChangeSet [
	"Open a ChangedMessageSet for aChangeSet"
	self default ifNil:[^self inform: 'Cannot open MessageSet'].
	^self default openChangedMessageSet: aChangeSet
]

{ #category : #browsing }
ToolSet class >> openClassListBrowser: anArray title: aString [
	"Open a class list browser on the list of classes named"

	self default ifNil:[^self inform: 'Cannot open ClassListBrowser'].
	^self default openClassListBrowser: anArray title: aString
]
