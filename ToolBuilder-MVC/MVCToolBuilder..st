"
The MVC tool builder.
"
Class {
	#name : #MVCToolBuilder,
	#superclass : #ToolBuilder,
	#instVars : [
		'panes',
		'topSize',
		'widgets',
		'parentMenu'
	],
	#category : #'ToolBuilder-MVC'
}

{ #category : #services }
MVCToolBuilder class >> getBoundsForWindow: view [

	^ view displayBox
]

{ #category : #accessing }
MVCToolBuilder class >> isActiveBuilder [
	"Answer whether I am the currently active builder"
	"This is really a way of answering whether 'Smalltalk isMVC'"
	ScheduledControllers ifNil:[^false].
	^(ScheduledControllers activeControllerProcess ifNil:[^false]) isTerminated not
]

{ #category : #services }
MVCToolBuilder class >> setBoundsForWindow: standardSystemView to: rectangle [

	^ standardSystemView resizeTo: rectangle
]

{ #category : #private }
MVCToolBuilder >> asWindow: aRectangle [

	| outer |
	outer := parent window ifNil: [topSize].
	^(aRectangle origin * outer extent) truncated
		corner: (aRectangle corner * outer extent) truncated
]

{ #category : #building }
MVCToolBuilder >> buildAll: aList in: newParent [
	"Overridden to propagate reduced topSize to widgets."
	
	| priorTopSize |
	priorTopSize := topSize.
	topSize := newParent window.
	super buildAll: aList in: newParent.
	topSize := priorTopSize.
]

{ #category : #'widgets optional' }
MVCToolBuilder >> buildPluggableAlternateMultiSelectionList: aSpec [
	
	"Trim selector to one argument to match list expectations."
	aSpec setIndex: (aSpec setIndex first: (aSpec setIndex findString: ':')) asSymbol.
	^ self buildPluggableList: aSpec.
]

{ #category : #'widgets required' }
MVCToolBuilder >> buildPluggableButton: aSpec [
	| widget label state |
	label := aSpec label.
	state := aSpec state.
	widget := PluggableButtonView on: aSpec model
				getState: (state isSymbol ifTrue:[state])
				action: aSpec action
				label: (label isSymbol ifTrue:[label]).
	self register: widget id: aSpec name.
	label ifNotNil: [label isSymbol
		ifTrue: [widget label: (aSpec model perform: label)]
		ifFalse: [widget label: label]].
	self setFrame: aSpec frame in: widget.
	parent ifNotNil: [parent addSubView: widget].
	^widget
]

{ #category : #'widgets required' }
MVCToolBuilder >> buildPluggableList: aSpec [
	| widget listClass getIndex setIndex |
	aSpec getSelected ifNil:[
		listClass := PluggableListView.
		getIndex := aSpec getIndex.
		setIndex := aSpec setIndex.
	] ifNotNil:[
		listClass := PluggableListViewByItem.
		getIndex := aSpec getSelected.
		setIndex := aSpec setSelected.
	].
	widget := listClass on: aSpec model
				list: aSpec list
				selected: getIndex
				changeSelected: setIndex
				menu: aSpec menu
				keystroke: aSpec keyPress.
	self register: widget id: aSpec name.
	self setFrame: aSpec frame in: widget.
	parent ifNotNil:[parent addSubView: widget].
	panes ifNotNil:[
		aSpec list ifNotNil:[panes add: aSpec list].
	].
	^widget
]

{ #category : #'widgets required' }
MVCToolBuilder >> buildPluggableMenu: menuSpec [ 
	"Just a very simple mapping to selection menu. It assumes that all item specs have the same receiver."
	
	| menu |
	menu := CustomMenu new.
	menuSpec items do: [:ea |
		menu
			add: ea label
			target: ea action receiver
			selector: ea action selector
			argumentList: ea action arguments.
		ea separator ifTrue: [menu addLine]].
	^ menu
]

{ #category : #'widgets required' }
MVCToolBuilder >> buildPluggableMenuItem: itemSpec [
	
	^ itemSpec label
]

{ #category : #'widgets required' }
MVCToolBuilder >> buildPluggablePanel: aSpec [
	| widget children |
	widget := View new model: aSpec model.
	widget
		borderWidth: 1;
		backgroundColor: nil;
		foregroundColor: nil.
	
	self register: widget id: aSpec name.
	children := aSpec children.
	children isSymbol ifTrue:[
		"@@@@ FIXME: PluggablePanes need to remember their getChildrenSelector"
		"widget getChildrenSelector: children.
		widget update: children."
		children := #().
	].
	self setFrame: aSpec frame in: widget.
	self buildAll: children in: widget.
	parent ifNotNil:[parent addSubView: widget].
	self setLayout: aSpec layout in: widget.
	^widget
]

{ #category : #'widgets required' }
MVCToolBuilder >> buildPluggableSpacer: aSpec [
	
	| widget |
	widget := View new.
	self register: widget id: aSpec name.

	widget borderWidth: 0.
	widget backgroundColor: nil.
	widget foregroundColor: nil.
	widget window: (widget window topLeft extent: aSpec extent).
	
	self setFrame: aSpec frame in: widget.

	parent ifNotNil:[parent addSubView: widget].
	^widget
]

{ #category : #'widgets required' }
MVCToolBuilder >> buildPluggableText: aSpec [
	| widget |
	widget := PluggableTextView on: aSpec model
				text: aSpec getText 
				accept: aSpec setText
				readSelection: aSpec selection 
				menu: aSpec menu.
	self register: widget id: aSpec name.
	self setFrame: aSpec frame in: widget.
	parent ifNotNil:[parent addSubView: widget].
	panes ifNotNil:[
		aSpec getText ifNotNil:[panes add: aSpec getText].
	].
	^widget
]

{ #category : #'widgets required' }
MVCToolBuilder >> buildPluggableTree: aSpec [
	"Fall-back to list view. Just show the roots."
	
	| widget listClass getIndex setIndex |
	listClass := PluggableListViewByItem.
	getIndex := aSpec getSelected.
	setIndex := aSpec setSelected.

	widget := PluggableListViewByItem on: aSpec model
				list: aSpec roots
				selected: aSpec getSelected
				changeSelected: aSpec setSelected
				menu: aSpec menu
				keystroke: aSpec keyPress.
	self register: widget id: aSpec name.
	self setFrame: aSpec frame in: widget.
	parent ifNotNil:[parent addSubView: widget].
	panes ifNotNil:[
		aSpec roots ifNotNil:[panes add: aSpec roots].
	].
	^widget
]

{ #category : #'widgets required' }
MVCToolBuilder >> buildPluggableWindow: aSpec [
	| widget children label |
	topSize := 0@0 corner: 640@480.
	aSpec layout == #proportional ifFalse:[
		"This needs to be implemented - probably by adding a single pane and then the rest"
		^self error: 'Not implemented'.
	].
	widget := StandardSystemView new.
	self register: widget id: aSpec name.
	widget model: aSpec model.
	label := aSpec label.
	label isSymbol ifTrue: [label := aSpec model perform: label].
	label isNil ifFalse: [widget setLabel: label].
	children := aSpec children.
	children isSymbol ifTrue:[
		"This isn't implemented by StandardSystemView, so we fake it"
		children := widget model perform: children.
	].
	aSpec extent ifNotNil:[topSize :=  0@0 extent: aSpec extent].
	widget window: topSize.
	panes := OrderedCollection new.
	self buildAll: children in: widget.
	widget setUpdatablePanesFrom: panes.
	^widget
]

{ #category : #opening }
MVCToolBuilder >> close: aWidget [
	"Close a previously opened widget. If the widget works as expected, the next controller will be found automatically. No process termination required. See ControlManager >> #activeController:."
	
	aWidget controller closeAndUnscheduleNoTerminate.
]

{ #category : #opening }
MVCToolBuilder >> open: anObject [
	"Build and open the object. Answer the widget opened."
	| window |
	window := (anObject isKindOf: View)
		ifTrue: [anObject]
		ifFalse: [self build: anObject].
	(window isKindOf: PopUpMenu)
		ifTrue: [window invokeOn: nil].
	(window isKindOf: View)
		ifTrue: [window controller open].
	^window
]

{ #category : #opening }
MVCToolBuilder >> open: anObject label: aString [
	"Build an open the object, labeling it appropriately.  Answer the widget opened."
	| window |
	window := self build: anObject.
	window label: aString.
	window controller open.
	^window
]

{ #category : #opening }
MVCToolBuilder >> openDebugger: anObject [
	"Build and open the object. Answer the widget opened."
	| window |
	window := self build: anObject.
	window controller openNoTerminate.
	^window
]

{ #category : #opening }
MVCToolBuilder >> openDebugger: anObject label: aString [
	"Build an open the object, labeling it appropriately.  Answer the widget opened."
	| window |
	window := self build: anObject.
	window label: aString.
	window controller openNoTerminate.
	^window
]

{ #category : #opening }
MVCToolBuilder >> openDebugger: anObject label: aString closing: topView [
	"Build an open the object, labeling it appropriately.  Answer the widget opened."
	| window |
	topView controller controlTerminate.
	topView deEmphasize; erase.

	"a few hacks to get the scroll selection artifacts out when we got here by clicking in the list"
"	topView subViewWantingControl ifNotNil: [
		topView subViewWantingControl controller controlTerminate
	]."
	topView controller status: #closed.
	window := self build: anObject.
	window label: aString.
	window controller openNoTerminate.
	topView controller closeAndUnscheduleNoErase.
	Processor terminateActive.
	^window
]

{ #category : #private }
MVCToolBuilder >> register: widget id: id [
	id ifNil:[^self].
	widgets ifNil:[widgets := Dictionary new].
	widgets at: id put: widget.
]

{ #category : #opening }
MVCToolBuilder >> runModal: aWidget [
	"Run the (previously opened) widget modally, e.g., 
	do not return control to the sender before the user has responded."

	
]

{ #category : #private }
MVCToolBuilder >> setFrame: fractionsRectangleOrLayoutFrame in: widget [

	| win |
	fractionsRectangleOrLayoutFrame ifNil: [
		"Translate subviews to position the viewport of each subView relative to
	the widget window origin. If subviews are repositioned, as in a row of button
	views arranged within a view, then the transformations will later be rescaled
	to fit the subviews within the widget window."
		self flag: #nonProportionalLayout. "See #setLayout:in:."
		widget setTransformation: (widget transformation translateBy: parent window origin - widget window origin).
		^ self].
	
	win := fractionsRectangleOrLayoutFrame isRectangle
		ifTrue: [self asWindow: fractionsRectangleOrLayoutFrame]
		ifFalse: [fractionsRectangleOrLayoutFrame layout: nil in: topSize]. "assume LayoutFrame"
	widget window: win.
]

{ #category : #private }
MVCToolBuilder >> setLayout: layout in: widget [
	"Arrange subview horizontally or vertically according to layout directive.
	If the subview dimensions were specified with layout frames rather than explicit
	rectangle sizes, then their window horizontal or vertical dimensions will be resized
	as needed to fit within the widget extent."

	layout == #proportional ifTrue:[^self].
	layout == #horizontal ifTrue:[
		| prev subViewWidth widgetWidth xScale |
		subViewWidth := (widget subViews collect: [:e | e window extent x]) sum.
		widgetWidth := widget window extent x.
		xScale := widgetWidth / subViewWidth. "to adjust corner of prev prior to align:"
		prev := nil.
		widget subViews do:[:next| | newWindowWidth newCorner |
			prev ifNotNil:[ "resize prev window prior to aligning next"
				xScale < 1 ifTrue: [ "proportional placement spec requires resizing"
					newWindowWidth := (prev window extent x * xScale) truncated.
					newCorner := (prev window origin x + newWindowWidth)@(prev window corner y).
					prev setWindow: (prev window origin corner: newCorner)].
				next align: next viewport topLeft with: prev viewport topRight.
			].
			prev := next.
		].
		^self].
	layout == #vertical ifTrue:[
		| prev subViewHeight widgetHeight yScale |
		subViewHeight := (widget subViews collect: [:e | e window extent y]) sum.
		widgetHeight := widget window extent y.
		yScale := widgetHeight / subViewHeight. "to adjust corner of prev prior to align:"
		prev := nil.
		widget subViews do:[:next| | newWindowHeight newCorner |
			prev ifNotNil:[ "resize prev window prior to aligning next"
				yScale < 1 ifTrue: [ "proportional placement spec requires resizing"
					newWindowHeight := (prev window extent y * yScale) truncated.
					newCorner := (prev window corner x)@(prev window origin y + newWindowHeight).
					prev setWindow: (prev window origin corner: newCorner)].
				next align: next viewport topLeft with: prev viewport bottomLeft.
			].
			prev := next.
		].
		^self].
	^self error: 'Unknown layout: ', layout.
]

{ #category : #private }
MVCToolBuilder >> widgetAt: id ifAbsent: aBlock [
	widgets ifNil:[^aBlock value].
	^widgets at: id ifAbsent: aBlock
]
