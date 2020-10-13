Class {
	#name : #SelectionMenu,
	#superclass : #PopUpMenu,
	#instVars : [
		'selections'
	],
	#category : #'Tools-Menus'
}

{ #category : #'instance creation' }
SelectionMenu class >> fromArray: anArray [
	"Construct a menu from anArray.  The elements of anArray must be either:
	*  A pair of the form: <label> <selector>
or	*  The 'dash' (or 'minus sign') symbol

	Refer to the example at the bottom of the method"

	| labelList lines selections anIndex |
	labelList := OrderedCollection new.
	lines := OrderedCollection new.
	selections := OrderedCollection new.
	anIndex := 0.
	anArray do:
		[:anElement |
			anElement size = 1
				ifTrue:
					[(anElement == #-) ifFalse: [self error: 'badly-formed menu constructor'].
					lines add: anIndex]
				ifFalse:
					[anElement size = 2 ifFalse: [self error: 'badly-formed menu constructor'].
					anIndex := anIndex + 1.
					labelList add: anElement first.
					selections add: anElement second]].
	^ self labelList: labelList lines: lines selections: selections

"(SelectionMenu fromArray:
	#(	('first label'		moja)
		('second label'	mbili)
		-
		('third label' 	tatu)
		-
		('fourth label'	nne)
		('fifth label'	tano))) startUp"
]

{ #category : #'instance creation' }
SelectionMenu class >> labelList: labelList [
	^ self labelArray: labelList
]

{ #category : #'instance creation' }
SelectionMenu class >> labelList: labelList lines: lines [
	^ self labelArray: labelList lines: lines
]

{ #category : #'instance creation' }
SelectionMenu class >> labelList: labelList lines: lines selections: selections [
	^ (self labelArray: labelList lines: lines) selections: selections
]

{ #category : #'instance creation' }
SelectionMenu class >> labelList: labelList selections: selections [
	^ self
		labelList: labelList
		lines: #()
		selections: selections
]

{ #category : #'instance creation' }
SelectionMenu class >> labels: labels lines: linesArray [
	"Answer an instance of me whose items are in labels, with lines drawn  
	after each item indexed by linesArray. Labels can be either a string 
	with embedded CRs, or a collection of strings."

	(labels isString)
		ifTrue: [^ super labels: labels lines: linesArray]
		ifFalse: [^ super labelArray: labels lines: linesArray]
]

{ #category : #'instance creation' }
SelectionMenu class >> labels: labels lines: linesArray selections: selectionsArray [
	"Answer an instance of me whose items are in labels, with lines drawn  
	after each item indexed by linesArray. Labels can be either a string  
	with embedded CRs, or a collection of strings. Record the given array of 
	selections corresponding to the items in labels."

	| labelString |
	(labels isString)
		ifTrue: [labelString := labels]
		ifFalse: [labelString := String streamContents:
					[:s |
					labels do: [:l | s nextPutAll: l; cr].
					s skip: -1]].
	^ (self labels: labelString lines: linesArray) selections: selectionsArray

]

{ #category : #'instance creation' }
SelectionMenu class >> labels: labels selections: selectionsArray [
	"Answer an instance of me whose items are in labels, recording 
	the given array of selections corresponding to the items in labels."

	^ self
		labels: labels
		lines: #()
		selections: selectionsArray
]

{ #category : #'instance creation' }
SelectionMenu class >> selections: selectionsArray [
	"Answer an instance of me whose labels and selections are identical."

	^ self selections: selectionsArray lines: nil
]

{ #category : #'instance creation' }
SelectionMenu class >> selections: selectionsArray lines: linesArray [
	"Answer an instance of me whose labels and selections are identical."

	^ self
		labelList: (selectionsArray collect: [:each | each asString])
		lines: linesArray
		selections: selectionsArray
]

{ #category : #'basic control sequence' }
SelectionMenu >> invokeOn: targetObject [
	"Pop up this menu and return the result of sending to the target object 
	the selector corresponding to the menu item selected by the user. Return 
	nil if no item is selected."

	| sel |
	sel := self startUp.
	sel = nil ifFalse: [^ targetObject perform: sel].
	^ nil

"Example:
	(SelectionMenu labels: 'sin
cos
neg' lines: #() selections: #(sin cos negated)) invokeOn: 0.7"
]

{ #category : #invocation }
SelectionMenu >> invokeOn: targetObject orSendTo: anObject [
	"Pop up the receiver, obtaining a selector; return the result of having the target object perform the selector.  If it dos not understand the selector, give the alternate object a chance"

	| aSelector |
	^ (aSelector := self startUp) ifNotNil:
		[(targetObject respondsTo: aSelector)
			ifTrue:
				[targetObject perform: aSelector]
			ifFalse:
				[anObject perform: aSelector]]
]

{ #category : #accessing }
SelectionMenu >> selections [
	^ selections
]

{ #category : #accessing }
SelectionMenu >> selections: selectionArray [
	selections := selectionArray
]

{ #category : #'basic control sequence' }
SelectionMenu >> startUpWithCaption: captionOrNil at: location allowKeyboard: aBoolean [
	"Overridden to return value returned by manageMarker.  The boolean parameter indicates whether the menu should be given keyboard focus (if in morphic)"

	| index |
	index := super startUpWithCaption: captionOrNil at: location allowKeyboard: aBoolean.
	(selections isNil or: [(index between: 1 and: selections size) not])
		ifTrue: [^ nil].
	^ selections at: index
]
