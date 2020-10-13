"
I am the controller for the parts of the display screen that have no view on them. I only provide a standard yellow button menu. I view (a FormView of) an infinite gray form.  (ScheduledControllers screenController) is the way to find me.
"
Class {
	#name : #ScreenController,
	#superclass : #Controller,
	#category : #'ST80-Controllers'
}

{ #category : #'menu messages' }
ScreenController >> aboutThisSystem [ 
	SmalltalkImage current aboutThisSystem
]

{ #category : #'menu messages' }
ScreenController >> absorbUpdatesFromServer [ 
	Utilities updateFromServer
]

{ #category : #'nested menus' }
ScreenController >> appearanceMenu [ 
	"Answer the appearance menu to be put up as a screen submenu"

	^ SelectionMenu labelList:
		#(
			'system fonts...'
			'full screen on'
			'full screen off'
			'set display depth...'
			'set desktop color...' ) 

		lines: #(2 4)
		selections: #(configureFonts
fullScreenOn fullScreenOff setDisplayDepth setDesktopColor)
"
ScreenController new appearanceMenu startUp
"
]

{ #category : #'menu messages' }
ScreenController >> bitCachingString [
	^ StandardSystemView cachingBits
		ifTrue: ['don''t save bits (compact)']
		ifFalse: ['save bits (fast)']
]

{ #category : #'menu messages' }
ScreenController >> browseChangedMessages [
	ChangeSet  browseChangedMessages
]

{ #category : #'menu messages' }
ScreenController >> browseRecentSubmissions [
	"Open a method-list browser on recently-submitted methods.  5/16/96 sw"

	Utilities browseRecentSubmissions
]

{ #category : #cursor }
ScreenController >> centerCursorInView [
	"Override so this doesn't happen when taking control"
]

{ #category : #'menu messages' }
ScreenController >> changeWindowPolicy [

	Preferences toggle: #reverseWindowStagger.
]

{ #category : #'nested menus' }
ScreenController >> changesMenu [
	"Answer a menu for changes-related items"
	^ SelectionMenu labelList:
		#(
			'simple change sorter'
			'dual change sorter'

			'file out current change set'
			'create new change set...'
			'browse changed methods'
			'check change set for slips'

			'browse recent submissions'
			'recently logged changes...'
			'recent log file...'
			)
		lines: #(1 3 7)
		selections: #(
openSimpleChangeSorter openChangeManager
fileOutChanges newChangeSet browseChangedMessages lookForSlips
browseRecentSubmissions browseRecentLog fileForRecentLog)
"
ScreenController new changesMenu startUp
"
]

{ #category : #'menu messages' }
ScreenController >> chooseDirtyWindow [
	"Put up a list of windows with unaccepted edits and let the user chose one to activate."
	"ScheduledControllers screenController chooseDirtyWindow"

	ScheduledControllers findWindowSatisfying:
		[:c | c model canDiscardEdits not].

]

{ #category : #'menu messages' }
ScreenController >> closeUnchangedWindows [
	"Close any window that doesn't have unaccepted input."

	| clean |
	(SelectionMenu confirm:
'Do you really want to close all windows
except those with unaccepted edits?')
		ifFalse: [^ self].

	clean := ScheduledControllers scheduledControllers select:
		[:c | c model canDiscardEdits and: [(c isKindOf: ScreenController) not]].
	clean do: [:c | c closeAndUnscheduleNoTerminate].

	Project current restoreDisplay.

]

{ #category : #'menu messages' }
ScreenController >> collapseAll [
	"Collapses all open windows"
	ScheduledControllers scheduledControllers do:
		[:controller | controller == self ifFalse:
			[controller view isCollapsed ifFalse:
					[controller collapse.
					controller view deEmphasize]]]
]

{ #category : #'menu messages' }
ScreenController >> commonRequests [ 
	"Put up a popup of common requests, and perform whatever the user request.  2/1/96 sw"
	Utilities offerCommonRequests
]

{ #category : #'menu messages' }
ScreenController >> configureFonts [
	| aMenu result |
	aMenu := CustomMenu fromArray: #(
		('default text font...'  chooseSystemFont)
		('list font'  chooseListFont)
		('flaps font'  chooseFlapsFont)
		('menu font'  chooseMenuFont)
		('window-title font'  chooseWindowTitleFont)
		('code font'  chooseCodeFont)
		-
		('restore default font choices'  restoreDefaultFonts)).
	aMenu title: 'Standard System Fonts'.

	(result := aMenu startUp) ifNotNil:
		[Preferences perform: result].
]

{ #category : #'control defaults' }
ScreenController >> controlActivity [
	"Any button opens the screen's menu.
	If the shift key is down, do find window."

	sensor leftShiftDown ifTrue: [^ self findWindow].
	(self projectScreenMenu invokeOn: self) ifNil: [super controlActivity]
]

{ #category : #'menu messages' }
ScreenController >> editPreferences [
	"Open up a Preferences inspector.  2/7/96 sw"
	self inform: 'The preference browser is currently not available in MVC'
]

{ #category : #'menu messages' }
ScreenController >> emergencyCollapse [
	"Emergency collapse of a selected window"
	| controller |
	(controller := ScheduledControllers windowFromUser) notNil
		ifTrue:
			[controller collapse.
			controller view deEmphasize]
]

{ #category : #'menu messages' }
ScreenController >> ensureProjectAccessors [

	Project allSubclassesDo: [:cls |
		(self respondsTo: (#open, cls name) asSymbol)
			ifFalse: [self class
				compile: ('open{1}\	Smalltalk at: #{1} ifPresent: [:p | ProjectView open: p new]' withCRs format: {cls name}) classified: '*autogenerated-project accessors']].
]

{ #category : #'menu messages' }
ScreenController >> exitProject [ 
	"Leave the current Project and enter the Project in which the receiver's 
	view is scheduled."

	Project current exit
]

{ #category : #'menu messages' }
ScreenController >> expandAll [
	"Reopens all collapsed windows"
	ScheduledControllers scheduledControllers reverseDo:
		[:controller | controller == self ifFalse:
			[controller view isCollapsed
				ifTrue:  [controller view expand]
				ifFalse: [controller view displayDeEmphasized]]]
]

{ #category : #'menu messages' }
ScreenController >> fastWindows [
	StandardSystemView cachingBits
		ifTrue: [StandardSystemView dontCacheBits]
		ifFalse: [StandardSystemView doCacheBits]
]

{ #category : #'menu messages' }
ScreenController >> fileForRecentLog [
	Smalltalk writeRecentToFile
]

{ #category : #'menu messages' }
ScreenController >> fileOutChanges [
	ChangeSet current verboseFileOut.
]

{ #category : #'menu messages' }
ScreenController >> findWindow [
	"Put up a menu of all windows on the screen, and let the user select one.
	 1/18/96 sw: the real work devolved to ControlManager>>findWindowSatisfying:"

	ScheduledControllers findWindowSatisfying: [:c | true]
]

{ #category : #'menu messages' }
ScreenController >> fontSizeSummary [
	TextStyle fontSizeSummary
]

{ #category : #'menu messages' }
ScreenController >> fullScreenOff [

	DisplayScreen fullScreenOff.
]

{ #category : #'menu messages' }
ScreenController >> fullScreenOn [

	DisplayScreen fullScreenOn.
]

{ #category : #'menu messages' }
ScreenController >> garbageCollect [
	"Do a garbage collection, and report results to the user."

	Utilities garbageCollectAndReport
]

{ #category : #'nested menus' }
ScreenController >> helpMenu [ 
	"Answer the help menu to be put up as a screen submenu"

	^ SelectionMenu labelList:
		#(
			'about this system...'
			'update code from server'
			'preferences...'

			'command-key help'
			'font size summary'
			'useful expressions'
			'view graphical imports'
			'standard graphics library'),

			(Array with: (SoundService soundEnablingString)) ,

		#(	'set author initials...'
			'vm statistics'
			'space left')
		lines: #(1 4 6 11)
		selections: #( aboutThisSystem absorbUpdatesFromServer
editPreferences  openCommandKeyHelp fontSizeSummary openStandardWorkspace viewImageImports
standardGraphicsLibrary soundOnOrOff setAuthorInitials vmStatistics garbageCollect)
"
ScreenController new helpMenu startUp
"
]

{ #category : #'control defaults' }
ScreenController >> isControlActive [
	^ self isControlWanted
]

{ #category : #'control defaults' }
ScreenController >> isControlWanted [
	^ self viewHasCursor and: [sensor anyButtonPressed]
]

{ #category : #'menu messages' }
ScreenController >> jumpToProject [

	Project current jumpToProject.

]

{ #category : #'menu messages' }
ScreenController >> lookForSlips [
	ChangeSet current lookForSlips
]

{ #category : #'menu messages' }
ScreenController >> newChangeSet [
	ChangeSet newChangeSet
]

{ #category : #'file in\/out' }
ScreenController >> objectForDataStream: refStrm [
	| dp |
	"I am about to be written on an object file.  Write a path to me in the other system instead."

	dp := DiskProxy global: #ScheduledControllers selector: #screenController args: #().
	refStrm replace: self with: dp.
	^ dp
]

{ #category : #'menu messages' }
ScreenController >> openBrowser [ 
	"Create and schedule a Browser view for browsing code."
	ToolSet browse: nil selector: nil
]

{ #category : #'menu messages' }
ScreenController >> openCommandKeyHelp [
	"1/18/96 sw Open a window that explains command-keys"

	(Smalltalk classNamed: 'SqueakTutorialsCommandKey') ifNotNil: [:cls |
		StringHolder new
			contents: cls commandKeyMappings contents;
			openLabel: 'Command Key Mappings' translated].
]

{ #category : #'nested menus' }
ScreenController >> openMenu [

	| projectLabels projectAccessors |
	self ensureProjectAccessors.
	projectLabels := Project allSubclasses collect: [:cls | 'new ', cls name].
	projectAccessors := Project allSubclasses collect: [:cls | (#open, cls name) asSymbol].
	
	^ SelectionMenu labelList:
		#(	
			'browser'
			'workspace'
			'transcript'
			
			'package browser'
			'method finder'
			'file list'
			'file...'

			'simple change sorter'
			'dual change sorter'),
			
		projectLabels,
		
		#(
			'process browser'
			)
		lines: {3. 7. 9. 9+projectLabels size}
		selections: #(openBrowser openWorkspace openTranscript openPackageBrowser openSelectorBrowser openFileList openFile 
openSimpleChangeSorter openChangeManager),
projectAccessors,
#(openProcessBrowser  )
"
ScreenController  new openMenu startUp
"
]

{ #category : #'menu messages' }
ScreenController >> openProcessBrowser [

	ToolBuilder open: ProcessBrowser new.
]

{ #category : #'menu messages' }
ScreenController >> openStandardWorkspace [
	"Open a standard, throwaway window chock full of useful expressions.  1/17/96 sw"

	Utilities openStandardWorkspace
]

{ #category : #'menu messages' }
ScreenController >> openTranscript [ 
	"Create and schedule the System Transcript."
	Transcript open
]

{ #category : #'menu messages' }
ScreenController >> openWorkspace [ 
	"Create and schedule workspace."

	UIManager default edit:'' label: 'Workspace'
]

{ #category : #'nested menus' }
ScreenController >> popUpMenuFor: aSymbol [
	(self perform: aSymbol) invokeOn: self
]

{ #category : #'nested menus' }
ScreenController >> presentAppearanceMenu [
	self popUpMenuFor: #appearanceMenu
]

{ #category : #'nested menus' }
ScreenController >> presentChangesMenu [
	self popUpMenuFor: #changesMenu
]

{ #category : #'nested menus' }
ScreenController >> presentHelpMenu [
	self popUpMenuFor: #helpMenu
]

{ #category : #'nested menus' }
ScreenController >> presentOpenMenu [
	self popUpMenuFor: #openMenu
]

{ #category : #'nested menus' }
ScreenController >> presentWindowMenu [
	self popUpMenuFor: #windowMenu
]

{ #category : #'nested menus' }
ScreenController >> projectScreenMenu [
	"Answer the project screen menu."

	^ SelectionMenu labelList:
		#(
			'browser'
			'workspace'

			'previous project'
			'jump to project...'
			
			'restore display'

			'open...'
			'windows...'
			'changes...'
			'help...'
			'appearance...'
			'do...'

			'save'
			'save as...'
			'save and quit'
			'quit')
		lines: #(2 4 5 11)
		selections: #(
openBrowser openWorkspace		
returnToPreviousProject jumpToProject restoreDisplay
presentOpenMenu presentWindowMenu presentChangesMenu presentHelpMenu presentAppearanceMenu commonRequests
snapshot saveAs snapshotAndQuit quit )
"
ScreenController new projectScreenMenu startUp
"
]

{ #category : #'menu messages' }
ScreenController >> quit [
	SmalltalkImage current
		snapshot:
			(self confirm: 'Save changes before quitting?' translated
				orCancel: [^ self])
		andQuit: true
]

{ #category : #'menu messages' }
ScreenController >> restoreDisplay [ 
	"Clear the screen to gray and then redisplay all the scheduled views."

	Project current restoreDisplay.
]

{ #category : #'menu messages' }
ScreenController >> returnToPreviousProject [

	Project returnToPreviousProject.

]

{ #category : #'menu messages' }
ScreenController >> saveAs [
	^ SmalltalkImage current saveAs
]

{ #category : #'menu messages' }
ScreenController >> setAuthorInitials [
	"Put up a dialog allowing the user to specify the author's initials.  "
	Utilities setAuthorInitials
]

{ #category : #'menu messages' }
ScreenController >> setDesktopColor [
	"Let the user choose a new color for the desktop.   Based on an idea by Georg Gollmann.   "

	Preferences desktopColor: Color fromUser.
	ScheduledControllers updateGray; restore
]

{ #category : #'menu messages' }
ScreenController >> setDisplayDepth [
	"Let the user choose a new depth for the display. "
	| result |
	(result := (SelectionMenu selections: Display supportedDisplayDepths) startUpWithCaption: ('Choose a display depth
(it is currently {1})' translated format: {Display depth printString})) == nil ifFalse:
		[Display newDepth: result]
]

{ #category : #'menu messages' }
ScreenController >> snapshot [
	SmalltalkImage current snapshot: true andQuit: false
]

{ #category : #'menu messages' }
ScreenController >> snapshotAndQuit [
	"Snapshot and quit without bother the user further.  2/4/96 sw"

	SmalltalkImage current
		snapshot: true
		andQuit: true
]

{ #category : #'menu messages' }
ScreenController >> soundEnablingString [
	^ SoundService soundEnablingString
]

{ #category : #'menu messages' }
ScreenController >> soundOnOrOff [
	SoundService toggleSoundEnabled
]

{ #category : #'menu messages' }
ScreenController >> staggerPolicyString [
	^ Preferences staggerPolicyString
]

{ #category : #'menu messages' }
ScreenController >> standardGraphicsLibrary [
	"Open a standard, throwaway window chock full of useful expressions.  1/17/96 sw"

	ScriptingSystem inspectFormDictionary
]

{ #category : #'menu messages' }
ScreenController >> viewImageImports [
	"Open an inspector on forms imported from Image files."

	Imports default viewImages
]

{ #category : #'menu messages' }
ScreenController >> vmStatistics [
	"Open a string view on a report of vm statistics"

	(StringHolder new contents: SmalltalkImage current  vmStatisticsReportString)
		openLabel: 'VM Statistics'
]

{ #category : #'nested menus' }
ScreenController >> windowMenu [
	"Answer a menu for windows-related items.  "

	^ SelectionMenu labelList:
		#(
			'find window...'
			'find changed browsers...'
			'find changed windows...'

			'collapse all windows'
			'expand all windows'
			'close unchanged windows' ) , 
			(Array
				with: self bitCachingString
				with: self staggerPolicyString)
		lines: #(1 4 7)
		selections: #(
findWindow chooseDirtyBrowser chooseDirtyWindow
collapseAll expandAll closeUnchangedWindows
fastWindows changeWindowPolicy)
"
ScreenController new windowMenu startUp
"
]
