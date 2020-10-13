"
I represent a list of items. My instances are presented on the display screen in a rectangular area. The user points to an item, pressing a mouse button; the item is highlighted. When the button is released, the highlighted item indicates the selection.
"
Class {
	#name : #PopUpMenu,
	#superclass : #Object,
	#instVars : [
		'labelString',
		'font',
		'lineArray',
		'frame',
		'form',
		'marker',
		'selection'
	],
	#classVars : [
		'CacheMenuForms'
	],
	#category : #'Tools-Menus'
}

{ #category : #'class initialization' }
PopUpMenu class >> cleanUp [
	"Re-initialize"

	self initialize.
]

{ #category : #dialogs }
PopUpMenu class >> confirm: queryString [
	"Put up a yes/no menu with caption queryString. Answer true if the 
	response is yes, false if no. This is a modal question--the user must 
	respond yes or no."

	"PopUpMenu confirm: 'Are you hungry?'"

	^ self confirm: queryString trueChoice: 'Yes' translated falseChoice: 'No' translated
]

{ #category : #dialogs }
PopUpMenu class >> confirm: queryString orCancel: cancelBlock [ 
	"Put up a yes/no/cancel menu with caption aString. Answer 
	true if  
	the response is yes, false if no. If cancel is chosen, evaluate  
	cancelBlock. This is a modal question--the user must respond 
	yes or no."
	"PopUpMenu confirm: 'Reboot universe' orCancel: 
	[^'Nevermind'] "
	| menu choice |
	menu := PopUpMenu labelArray: {'Yes' translated. 'No' translated. 'Cancel' translated}.
	choice := menu startUpWithCaption: queryString icon: MenuIcons confirmIcon.
	choice = 1
		ifTrue: [^ true].
	choice = 2
		ifTrue: [^ false].
	^ cancelBlock value
]

{ #category : #dialogs }
PopUpMenu class >> confirm: queryString trueChoice: trueChoice falseChoice: falseChoice [ 
	"Put up a yes/no menu with caption queryString. The actual 
	wording  
	for the two choices will be as provided in the trueChoice and  
	falseChoice parameters. Answer true if the response is the 
	true-choice,  
	false if it's the false-choice. 
	This is a modal question -- the user must respond one way or 
	the other."
	"PopUpMenu  
	confirm: 'Are you hungry?' 
	trueChoice: 'yes, I''m famished' 
	falseChoice: 'no, I just ate'"
	| menu choice |
	menu := PopUpMenu labelArray: {trueChoice. falseChoice}.
	[(choice := menu startUpWithCaption: queryString icon: MenuIcons confirmIcon) isNil] whileTrue.
	^ choice = 1
]

{ #category : #dialogs }
PopUpMenu class >> inform: aString [
	"PopUpMenu inform: 'I like Squeak'"

	| iconOrNil |
	iconOrNil := Smalltalk at: #MenuIcons ifPresent: [:cls | cls confirmIcon].
	(PopUpMenu labels: ' OK ' translated)
		startUpWithCaption: aString
		icon: iconOrNil

]

{ #category : #'instance creation' }
PopUpMenu class >> labelArray: labelArray [
	"Answer an instance of me whose items are in labelArray."

	^ self labelArray: labelArray lines: nil
]

{ #category : #'instance creation' }
PopUpMenu class >> labelArray: labelArray lines: lineArray [
	"Answer an instance of me whose items are in labelArray, with lines 
	drawn after each item indexed by anArray. 2/1/96 sw"

	labelArray isEmpty ifTrue: [self error: 'Menu must not be zero size'].
	^ self
		labels: (String streamContents: 
			[:stream |
			labelArray do: [:each | stream nextPutAll: each; cr].
			stream skip: -1 "remove last CR"])
		lines: lineArray

"Example:
	(PopUpMenu labelArray: #('frog' 'and' 'toad') lines: #()) startUp"
]

{ #category : #'instance creation' }
PopUpMenu class >> labels: aString [
	"Answer an instance of me whose items are in aString."

	^ self labels: aString lines: nil
]

{ #category : #'instance creation' }
PopUpMenu class >> labels: aString lines: anArray [
	"Answer an instance of me whose items are in aString, with lines drawn 
	after each item indexed by anArray."

	^ self new
		labels: aString
		font: Preferences standardMenuFont
		lines: anArray
]

{ #category : #dialogs }
PopUpMenu class >> notify: message [
	"Deprecated. Use #inform: instead."

	self inform: message
]

{ #category : #'class initialization' }
PopUpMenu class >> standardMenuStyle [

	^ (TextStyle fontArray: { Preferences standardMenuFont })
		gridForFont: 1 withLead: 0;
		centered;
		yourself
]

{ #category : #'instance creation' }
PopUpMenu class >> withCaption: cap chooseFrom: labels [ 
	"Simply put up a menu. Get the args in the right order with the caption 
	first. labels may be either an array of items or a string with CRs in it. 
	May use backslashes for returns."

	^ (labels isString
		ifTrue: [self labels: labels withCRs lines: nil]
		ifFalse: [self labelArray: labels lines: nil])
		startUpWithCaption: cap withCRs
]

{ #category : #accessing }
PopUpMenu >> center [
	"Answer the point at the center of the receiver's rectangular area."

	^ frame center
]

{ #category : #private }
PopUpMenu >> computeForm [
	"Compute and answer a Form to be displayed for this menu."

	| borderInset paraForm menuForm menuStyle inside |
	borderInset := 4@4.
	menuStyle := self class standardMenuStyle.
	paraForm := ((DisplayText text: labelString asText textStyle: menuStyle)
		foregroundColor: (self userInterfaceTheme textColor ifNil: [Color black])
		backgroundColor: (self userInterfaceTheme color ifNil: [Color white])) form.
	menuForm := Form extent: paraForm extent + (borderInset * 2) depth: paraForm depth.
      menuForm fill: (0 @ 0 extent: menuForm  extent)
                        rule: Form over
                        fillColor: (self userInterfaceTheme color ifNil: [Color white]).
	menuForm
		border: menuForm boundingBox
		width: 2
		fillColor: (self userInterfaceTheme borderColor ifNil: [Color black]).
	
	paraForm displayOn: menuForm at: borderInset.
	lineArray == nil ifFalse:
		[lineArray do:
			[ :line |
			menuForm
				fill: (4 @ ((line * font height) + borderInset y)
						extent: (menuForm width - 8 @ 1))
				rule: Form over
				fillColor: (self userInterfaceTheme lineColor ifNil: [Color black])]].

	frame := Quadrangle new.
	frame region: menuForm boundingBox.
	frame borderWidth: 4.
	inside := frame inside.
	marker := inside topLeft extent: (inside width @ menuStyle lineGrid).
	selection := 1.

	^ form := menuForm

]

{ #category : #'basic control sequence' }
PopUpMenu >> controlActivity [
	"Do whatever a menu must do - now with keyboard support."

	| didNotMove downPos |
	didNotMove := true.
	Sensor anyButtonPressed
		ifFalse:
			[didNotMove := false.
			Sensor waitButtonOrKeyboard]. 

	Sensor keyboardPressed ifFalse: [self manageMarker].
	(didNotMove and: [selection = 0])
		ifTrue:
			[downPos := Sensor cursorPoint.
			[didNotMove and: [Sensor anyButtonPressed]]
				whileTrue:
					[ Project current world activeController interActivityPause.
					(downPos dist: Sensor cursorPoint) < 2 ifFalse: [didNotMove := false]].
			didNotMove ifTrue: [Sensor waitButtonOrKeyboard]].

	[Sensor keyboardPressed] whileTrue:
		[self readKeyboard ifTrue: [^ self].
		Sensor waitButtonOrKeyboard].

	[Sensor anyButtonPressed] whileTrue: [
		ScheduledControllers activeController interActivityPause.
		self manageMarker]
]

{ #category : #displaying }
PopUpMenu >> displayAt: aPoint withCaption: captionOrNil during: aBlock [
	"Display the receiver just to the right of aPoint while aBlock is evaluated.  If the receiver is forced off screen, display it just to the right."
	| delta savedArea captionForm captionSave outerFrame captionText tFrame frameSaveLoc captionBox |
	marker ifNil: [self computeForm].
	frame := frame align: marker leftCenter with: aPoint + (2@0).
	outerFrame := frame.
	captionOrNil notNil ifTrue:
		[captionText := (DisplayText
				text: captionOrNil asText
				textStyle: self class standardMenuStyle copy centered)
					foregroundColor: (self userInterfaceTheme textColor ifNil: [Color black])
					backgroundColor: (self userInterfaceTheme color ifNil: [Color white]).
		tFrame := captionText boundingBox insetBy: -2.
		outerFrame := frame merge: (tFrame align: tFrame bottomCenter
					with: frame topCenter + (0@2))].
	delta := outerFrame amountToTranslateWithin: Display boundingBox.
	frame right > Display boundingBox right
		ifTrue: [delta := 0 - frame width @ delta y].
	frame := frame translateBy: delta.
	captionOrNil notNil ifTrue:
		[captionForm := captionText form.
		captionBox := captionForm boundingBox expandBy: 4.
		captionBox := captionBox align: captionBox bottomCenter
								with: frame topCenter + (0@2).
		captionSave := Form fromDisplay: captionBox.
		Display border: captionBox width: 4 fillColor: (self userInterfaceTheme color ifNil: [Color white]).
		Display border: captionBox width: 2 fillColor: (self userInterfaceTheme textColor ifNil: [Color black]).
		captionForm displayAt: captionBox topLeft + 4].
	marker := marker align: marker leftCenter with: aPoint + delta +  (2@0).
	savedArea := Form fromDisplay: frame.
	self menuForm displayOn: Display at: (frameSaveLoc := frame topLeft).
	selection ~= 0 ifTrue: [Display reverse: marker].
	Cursor normal showWhile: aBlock.
	savedArea displayOn: Display at: frameSaveLoc.
	captionOrNil notNil ifTrue:
		[captionSave displayOn: Display at: captionBox topLeft]
]

{ #category : #accessing }
PopUpMenu >> frameHeight [
	"Designed to avoid the entire frame computation (includes MVC form),
	since the menu may well end up being displayed in Morphic anyway."
	| nItems |
	frame ifNotNil: [^ frame height].
	nItems := 1 + (labelString occurrencesOf: Character cr).
	^ (nItems * self class standardMenuStyle lineGrid) + 4 "border width"
]

{ #category : #accessing }
PopUpMenu >> labelString [
	^ labelString
]

{ #category : #private }
PopUpMenu >> labels: aString font: aFont lines: anArray [

	labelString := aString.
	font := aFont.
	lineArray := anArray.

]

{ #category : #accessing }
PopUpMenu >> lineArray [
	^ lineArray
]

{ #category : #'marker adjustment' }
PopUpMenu >> manageMarker [
	"If the cursor is inside the receiver's frame, then highlight the marked 
	item. Otherwise no item is to be marked."
	| pt |
	"Don't let pt get far from display box, so scrolling will go all the way"
	pt := Sensor cursorPoint adhereTo: (Display boundingBox expandBy: 1).
	(frame inside containsPoint: pt)
		ifTrue: ["Need to cache the form for reasonable scrolling performance"
				((Display boundingBox insetBy: 0@3) containsPoint: pt)
					ifFalse: [pt := pt - (self scrollIntoView: pt)].
				self markerOn: pt]
		ifFalse: [self markerOff]
]

{ #category : #'marker adjustment' }
PopUpMenu >> markerOff [
	"No item is selected. Reverse the highlight if any item has been marked 
	as selected."

	self setSelection: 0
]

{ #category : #'marker adjustment' }
PopUpMenu >> markerOn: aPoint [ 
	"The item whose bounding area contains aPoint should be marked as 
	selected. Highlight its area and set the selection to its index."

	selection = 0 | (marker containsPoint: aPoint) not 
		ifTrue: [selection = 0 & (marker containsPoint: aPoint)
					ifTrue: [Display reverse: marker]
					ifFalse: 
						[selection > 0 ifTrue: [Display reverse: marker].
						marker := 
							marker 
								align: marker topLeft 
								with: marker left @ (self markerTop: aPoint).
						Display reverse: marker]].
	selection := marker top - frame top // marker height + 1
]

{ #category : #'marker adjustment' }
PopUpMenu >> markerTop: aPoint [ 
	"Answer aPoint, gridded to lines in the receiver."

	^(aPoint y - frame inside top truncateTo: font height) + frame inside top
]

{ #category : #private }
PopUpMenu >> menuForm [
	"Answer a Form to be displayed for this menu."

	form == nil ifTrue: [self computeForm].
	^ form
]

{ #category : #accessing }
PopUpMenu >> nItems [
	^ (labelString occurrencesOf: Character cr) + 1
]

{ #category : #'basic control sequence' }
PopUpMenu >> readKeyboard [
	"Keyboard support for menus. ESC will abort the menu, Space or CR
	will select an item. Cursor up and cursor down will change the
	selection. Any other key will either select an item whose label starts
	with that character or select the next matching label.
	Answer true if the menu should be closed and false otherwise."

	| ch labels occurences |
	ch := Sensor keyboard asciiValue.
	(ch = 13 or: [ch = 32]) ifTrue: [^ true].
	ch = 27 ifTrue: [self setSelection: 0. ^ true].
	ch = 30
		ifTrue:
			[self setSelection: (selection <= 1
				ifTrue: [self nItems]
				ifFalse: [selection - 1])].
	ch = 31 ifTrue: [self setSelection: selection \\ self nItems + 1].
	ch := ch asCharacter asLowercase.
	labels := labelString lines.
	occurences := 0.
	1 + selection to: selection + labels size do:
		[:index |
		| i | i := index - 1 \\ labels size + 1.
		(labels at: i) withBlanksTrimmed first asLowercase = ch
			ifTrue: [(occurences := occurences + 1) = 1 ifTrue: [self setSelection: i]]].
	^ occurences = 1
]

{ #category : #private }
PopUpMenu >> rescan [
	"Cause my form to be recomputed after a font change."

	labelString == nil ifTrue: [labelString := 'NoText!'].
	self labels: labelString font: Preferences standardMenuFont lines: lineArray.
	frame := marker := form := nil.

	"PopUpMenu allSubInstancesDo: [:m | m rescan]"
]

{ #category : #'marker adjustment' }
PopUpMenu >> scrollIntoView: cursorLoc [
	| dy |
	dy := 0.
	cursorLoc y < 2 ifTrue: [dy := font height].
	cursorLoc y > (Display height-3) ifTrue: [dy := font height negated].
	dy = 0 ifTrue: [^ 0@0].
	self markerOff.
	frame := frame translateBy: 0@dy.
	marker := marker translateBy: 0@dy.
	self menuForm displayOn: Display at: frame topLeft.
	^ 0@dy
]

{ #category : #selecting }
PopUpMenu >> selection [
	"Answer the current selection."

	^ selection
]

{ #category : #selecting }
PopUpMenu >> setSelection: index [
	| newSelection |
	selection = index ifTrue: [^ self].
	newSelection := (0 max: index) min: frame height // marker height.
	selection > 0 ifTrue: [Display reverse: marker].
	marker := marker translateBy: 0 @ (newSelection - selection * marker height).
	selection := newSelection.
	selection > 0 ifTrue: [Display reverse: marker]
]

{ #category : #'basic control sequence' }
PopUpMenu >> startUp [
	"Display and make a selection from the receiver as long as the button 
	is pressed. Answer the current selection."
	
	^ self startUpWithCaption: nil
]

{ #category : #'basic control sequence' }
PopUpMenu >> startUpCenteredWithCaption: captionOrNil [
	"Differs from startUpWithCaption: by appearing with cursor in the menu, and thus ready to act on mouseUp, without requiring user tweak to confirm"

	^ self
		startUpWithCaption: captionOrNil
		at: (self currentHand ifNil: [Sensor]) cursorPoint - (20 @ 0)
]

{ #category : #'basic control sequence' }
PopUpMenu >> startUpSegmented: segmentHeight withCaption: captionOrNil at: location [
	"This menu is too big to fit comfortably on the screen.
	Break it up into smaller chunks, and manage the relative indices.
	Inspired by a special-case solution by Reinier van Loon."
"
(PopUpMenu labels: (String streamContents: [:s | 1 to: 100 do: [:i | s print: i; cr]. s skip: -1])
		lines: (5 to: 100 by: 5)) startUpWithCaption: 'Give it a whirl...'.
"
	| nLines nLinesPer allLabels from to subset subLines index |
	frame ifNil: [self computeForm].
	allLabels := labelString lines.
	nLines := allLabels size.
	lineArray ifNil: [lineArray := Array new].
	nLinesPer := segmentHeight // marker height - 3.
	from := 1.
	[to := (from + nLinesPer) min: nLines.
	subset := allLabels copyFrom: from to: to.
	subset add: (to = nLines ifTrue: ['start over...' translated] ifFalse: ['more...' translated])
		before: subset first.
	subLines := lineArray select: [:n | n >= from] thenCollect: [:n | n - (from-1) + 1].
	subLines := (Array with: 1) , subLines.
	index := (PopUpMenu labels: subset asStringWithCr lines: subLines)
				startUpWithCaption: captionOrNil at: location.
	index = 1
		ifTrue: [from := to + 1.
				from > nLines ifTrue: [ from := 1 ]]
		ifFalse: [index = 0 ifTrue: [^ 0].
				^ from + index - 2]] repeat
]

{ #category : #'basic control sequence' }
PopUpMenu >> startUpSegmented: segmentHeight withCaption: captionOrNil at: location allowKeyboard: aBoolean [
	"This menu is too big to fit comfortably on the screen.
	Break it up into smaller chunks, and manage the relative indices.
	Inspired by a special-case solution by Reinier van Loon.  The boolean parameter indicates whether the menu should be given keyboard focus (if in morphic)"

"
(PopUpMenu labels: (String streamContents: [:s | 1 to: 100 do: [:i | s print: i; cr]. s skip: -1])
		lines: (5 to: 100 by: 5)) startUpWithCaption: 'Give it a whirl...'.
"
	| nLines nLinesPer allLabels from to subset subLines index |
	frame ifNil: [self computeForm].
	allLabels := labelString lines.
	nLines := allLabels size.
	lineArray ifNil: [lineArray := Array new].
	nLinesPer := segmentHeight // marker height - 3.
	from := 1.
	[to := (from + nLinesPer) min: nLines.
	subset := (allLabels copyFrom: from to: to) asOrderedCollection.
	subset add: (to = nLines ifTrue: ['start over...' translated] ifFalse: ['more...' translated])
		before: subset first.
	subLines := lineArray select: [:n | n >= from] thenCollect: [:n | n - (from-1) + 1].
	subLines := (Array with: 1) , subLines.
	index := (PopUpMenu labels: subset asStringWithCr lines: subLines)
				startUpWithCaption: captionOrNil at: location allowKeyboard: aBoolean.
	index = 1
		ifTrue: [from := to + 1.
				from > nLines ifTrue: [ from := 1 ]]
		ifFalse: [index = 0 ifTrue: [^ 0].
				^ from + index - 2]] repeat
]

{ #category : #'basic control sequence' }
PopUpMenu >> startUpWithCaption: captionOrNil [
	"Display the menu, slightly offset from the cursor,
	so that a slight tweak is required to confirm any action."
	self flag: #fix. "mt: Could we manage to open pop-up menus in Morphic without accessing self currentHand?"

	^ self
		startUpWithCaption: captionOrNil
		at: (self currentHand ifNil: [Sensor]) cursorPoint
]

{ #category : #'basic control sequence' }
PopUpMenu >> startUpWithCaption: captionOrNil at: location [
	"Display the menu, with caption if supplied. Wait for the mouse button to go down,
	then track the selection as long as the button is pressed. When the button is released, 
	answer the index of the current selection, or zero if the mouse is not released over 
	any menu item. Location specifies the desired topLeft of the menu body rectangle."

		^ self startUpWithCaption: captionOrNil at: location allowKeyboard: Preferences menuKeyboardControl
]

{ #category : #'basic control sequence' }
PopUpMenu >> startUpWithCaption: captionOrNil at: location allowKeyboard: aBoolean [
	"Display the menu, with caption if supplied. Wait for the mouse button to go down, then track the selection as long as the button is pressed. When the button is released,
	Answer the index of the current selection, or zero if the mouse is not released over  any menu item. Location specifies the desired topLeft of the menu body rectangle. The final argument indicates whether the menu should seize the keyboard focus in order to allow the user to navigate it via the keyboard."

	^ self
			startUpWithCaption: captionOrNil
			icon: nil
			at: location
			allowKeyboard: aBoolean
]

{ #category : #'basic control sequence' }
PopUpMenu >> startUpWithCaption: captionOrNil icon: aForm [
	"Display the menu, slightly offset from the cursor, so that a slight tweak is required to confirm any action."

	^ self
			startUpWithCaption: captionOrNil
			icon: aForm
			at: (self currentHand ifNil: [Sensor]) cursorPoint
]

{ #category : #'basic control sequence' }
PopUpMenu >> startUpWithCaption: captionOrNil icon: aForm at: location [
	"Display the menu, with caption if supplied. Wait for the mouse button to go down,
	then track the selection as long as the button is pressed. When the button is released, 
	answer the index of the current selection, or zero if the mouse is not released over 
	any menu item. Location specifies the desired topLeft of the menu body rectangle."

	^ self
			startUpWithCaption: captionOrNil
			icon: aForm
			at: location
			allowKeyboard: Preferences menuKeyboardControl

]

{ #category : #'basic control sequence' }
PopUpMenu >> startUpWithCaption: captionOrNil icon: aForm at: location allowKeyboard: aBoolean [
	"Display the menu, with caption if supplied. Wait for the mouse button to go down, then track the selection as long as the button is pressed. When the button is released,
	Answer the index of the current selection, or zero if the mouse is not released over  any menu item. Location specifies the desired topLeft of the menu body rectangle. The final argument indicates whether the menu should seize the keyboard focus in order to allow the user to navigate it via the keyboard."

	| maxHeight |
	(ProvideAnswerNotification signal: captionOrNil) ifNotNil:
		[:answer | ^ selection := answer ifTrue: [1] ifFalse: [2]].
		 
	maxHeight := Display height*3//4.
	self frameHeight > maxHeight ifTrue:
		[^ self
			startUpSegmented: maxHeight
			withCaption: captionOrNil
			at: location
			allowKeyboard: aBoolean].

	^ Project uiManager startUpMenu: self withCaption: captionOrNil icon: aForm at: location allowKeyboard: aBoolean
]

{ #category : #'basic control sequence' }
PopUpMenu >> startUpWithoutKeyboard [
	"Display and make a selection from the receiver as long as the button  is pressed. Answer the current selection.  Do not allow keyboard input into the menu"
	
	^ self
		startUpWithCaption: nil
		at: ((self currentHand ifNil: [Sensor]) cursorPoint)
		allowKeyboard: false
]
