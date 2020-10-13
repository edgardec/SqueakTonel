"
I am a bit-magnifying tool for editing small Forms directly on the display screen. I continue to be active until the user points outside of my viewing area.
"
Class {
	#name : #BitEditor,
	#superclass : #MouseMenuController,
	#instVars : [
		'scale',
		'squareForm',
		'color',
		'transparent'
	],
	#classVars : [
		'YellowButtonMenu'
	],
	#category : #'ST80-Editors'
}

{ #category : #private }
BitEditor class >> bitEdit: aForm at: magnifiedFormLocation scale: scaleFactor remoteView: remoteView [
	"Create a BitEditor on aForm. That is, aForm is a small image that will 
	change as a result of the BitEditor changing a second and magnified 
	view of me. magnifiedFormLocation is where the magnified form is to be 
	located on the screen. scaleFactor is the amount of magnification. This 
	method implements a scheduled view containing both a small and 
	magnified view of aForm. Upon accept, aForm is updated."

	| aFormView scaledFormView bitEditor topView extent menuView lowerRightExtent |
	scaledFormView := FormHolderView new model: aForm.
	scaledFormView scaleBy: scaleFactor.
	bitEditor := self new.
	scaledFormView controller: bitEditor.
	bitEditor setColor: Color black.
	topView := ColorSystemView new.
	remoteView == nil ifTrue: [topView label: 'Bit Editor'].
	topView borderWidth: 2.

	topView addSubView: scaledFormView.
	remoteView == nil
		ifTrue:  "If no remote view, then provide a local view of the form"
			[aFormView := FormView new model: scaledFormView workingForm.
			aFormView controller: NoController new.
			aForm height < 50
				ifTrue: [aFormView borderWidthLeft: 0 right: 2 top: 2 bottom: 2]
				ifFalse: [aFormView borderWidthLeft: 0 right: 2 top: 2 bottom: 0].
			topView addSubView: aFormView below: scaledFormView]
		 ifFalse:  "Otherwise, the remote one should view the same form"
			[remoteView model: scaledFormView workingForm].
	lowerRightExtent := remoteView == nil
			ifTrue:
				[(scaledFormView viewport width - aFormView viewport width) @
					(aFormView viewport height max: 50)]
			ifFalse:
				[scaledFormView viewport width @ 50].
	menuView := self buildColorMenu: lowerRightExtent colorCount: 1.
	menuView model: bitEditor.
	menuView borderWidthLeft: 0 right: 0 top: 2 bottom: 0.
	topView
		addSubView: menuView
		align: menuView viewport topRight
		with: scaledFormView viewport bottomRight.
	extent := scaledFormView viewport extent + (0 @ lowerRightExtent y)
			+ (4 @ 4).  "+4 for borders"
	topView minimumSize: extent.
	topView maximumSize: extent.
	topView translateBy: magnifiedFormLocation.
	topView insideColor: Color white.
	^topView
]

{ #category : #private }
BitEditor class >> buildColorMenu: extent colorCount: nColors [
	"See BitEditor magnifyWithSmall."

	| menuView form aSwitchView
	 button formExtent highlightForm color leftOffset |
	menuView := FormMenuView new.
	menuView window: (0@0 corner: extent).
	formExtent := 30@30 min: extent//(nColors*2+1@2).  "compute this better"
	leftOffset := extent x-(nColors*2-1*formExtent x)//2.
	highlightForm := Form extent: formExtent.
	highlightForm borderWidth: 4.
	1 to: nColors do: [:index | 
		color := (nColors = 1
			ifTrue: [#(black)]
			ifFalse: [#(black gray)]) at: index.
		form := Form extent: formExtent.
		form fill: form boundingBox fillColor: (Color perform: color).
		form borderWidth: 5.
		form border: form boundingBox width: 4 fillColor: Color white.
		button := Button new.
		aSwitchView := PluggableButtonView
			on: button
			getState: #isOn
			action: #turnOn
			label: #getCurrentColor.

		index = 1
			ifTrue: [button onAction: [menuView model setColor: Color fromUser.
									  aSwitchView label: menuView model getCurrentColor;
									                  displayView
					                     ]
				    ]
			ifFalse: [button onAction: [menuView model setTransparentColor]].

		aSwitchView
			shortcutCharacter: ((nColors=3 ifTrue: ['xvn'] ifFalse: ['xn']) at: index);
			label: form;
			window: (0@0 extent: form extent);
			translateBy: (((index - 1) * 2 * form width) + leftOffset)@(form height // 2);
			borderWidth: 1.
		menuView addSubView: aSwitchView].
	^ menuView

]

{ #category : #'class initialization' }
BitEditor class >> initialize [
	"The Bit Editor is the only controller to override the use of the blue
	button with a different pop-up menu. Initialize this menu."

	YellowButtonMenu := SelectionMenu
		labels:
'cancel
accept
file out
test'
		lines: #(2 3)
		selections: #(cancel accept fileOut test)

	"BitEditor initialize"
]

{ #category : #examples }
BitEditor class >> magnifyOnScreen [
	"Bit editing of an area of the display screen. User designates a 
	rectangular area that is magnified by 8 to allow individual screens dots to
	be modified. red button is used to set a bit to black and yellow button is
	used to set a bit to white. Editor is not scheduled in a view. Original
	screen location is updated immediately. This is the same as FormEditor
	magnify."
	| smallRect smallForm scaleFactor tempRect |
	scaleFactor := 8 @ 8.
	smallRect := Rectangle fromUser.
	smallRect isNil ifTrue: [^self].
	smallForm := Form fromDisplay: smallRect.
	tempRect := Rectangle locateMagnifiedView: smallForm scale: scaleFactor.
	"show magnified form size until mouse is depressed"
	self
		openScreenViewOnForm: smallForm 
		at: smallRect topLeft 
		magnifiedAt: tempRect topLeft 
		scale: scaleFactor

	"BitEditor magnifyOnScreen."
]

{ #category : #examples }
BitEditor class >> magnifyWithSmall [
"	Also try:
	BitEditor openOnForm:
		(Form extent: 32@32 depth: Display depth)
	BitEditor openOnForm:
		((MaskedForm extent: 32@32 depth: Display depth)
		withTransparentPixelValue: -1)
"
	"Open a BitEditor viewing an area on the screen which the user chooses"
	| area form |
	area := Rectangle fromUser.
	area isNil ifTrue: [^ self].
	form := Form fromDisplay: area.
	self openOnForm: form

	"BitEditor magnifyWithSmall."
]

{ #category : #'instance creation' }
BitEditor class >> openOnForm: aForm [ 
	"Create and schedule a BitEditor on the form aForm at its top left corner. 
	Show the small and magnified view of aForm."

	| scaleFactor |
	scaleFactor := 8 @ 8.
	^self openOnForm: aForm
		at: (Rectangle locateMagnifiedView: aForm scale: scaleFactor) topLeft
		scale: scaleFactor
]

{ #category : #'instance creation' }
BitEditor class >> openOnForm: aForm at: magnifiedLocation [ 
	"Create and schedule a BitEditor on the form aForm at magnifiedLocation. 
	Show the small and magnified view of aForm."

	^self openOnForm: aForm
		at: magnifiedLocation
		scale: 8 @ 8
]

{ #category : #'instance creation' }
BitEditor class >> openOnForm: aForm at: magnifiedLocation scale: scaleFactor [ 
	"Create and schedule a BitEditor on the form aForm. Show the small and 
	magnified view of aForm."

	| aScheduledView |
	aScheduledView := self
				bitEdit: aForm
				at: magnifiedLocation
				scale: scaleFactor
				remoteView: nil.
	aScheduledView controller openDisplayAt:
		aScheduledView displayBox topLeft + (aScheduledView displayBox extent / 2)
]

{ #category : #'instance creation' }
BitEditor class >> openScreenViewOnForm: aForm at: formLocation magnifiedAt: magnifiedLocation scale: scaleFactor [
	"Create and schedule a BitEditor on the form aForm. Show the magnified
	view of aForm in a scheduled window."
	| smallFormView bitEditor savedForm r |
	smallFormView := FormView new model: aForm.
	smallFormView align: smallFormView viewport topLeft with: formLocation.
	bitEditor := self bitEdit: aForm at: magnifiedLocation scale: scaleFactor remoteView: smallFormView.
	savedForm := Form fromDisplay: (r := bitEditor displayBox expandBy: (0@23 corner: 0@0)).
	bitEditor controller startUp.
	savedForm displayOn: Display at: r topLeft.
	bitEditor release.
	smallFormView release.

	"BitEditor magnifyOnScreen."
]

{ #category : #'menu messages' }
BitEditor >> accept [
	"The edited information should now be accepted by the view."

	view accept
]

{ #category : #'menu messages' }
BitEditor >> cancel [
	"The edited informatin should be forgotten by the view."

	view cancel
]

{ #category : #'basic control sequence' }
BitEditor >> controlInitialize [

	super controlInitialize.
	Cursor crossHair show
]

{ #category : #'basic control sequence' }
BitEditor >> controlTerminate [

	Cursor normal show
]

{ #category : #'menu messages' }
BitEditor >> fileOut [

	| fileName |
	fileName := UIManager default 
		saveFilenameRequest: 'Save this Form to' translated
		initialAnswer: 'Filename.form'.
	fileName ifNil: [^ self].
	Cursor normal
		showWhile: [model writeOnFileNamed: fileName].

]

{ #category : #'menu messages' }
BitEditor >> getCurrentColor [
	| formExtent form c |
	c := Color colorFromPixelValue: color depth: Display depth.
	formExtent := 30@30" min: 10@ 10//(2+1@2)".  "compute this better"
	form := Form extent: formExtent depth: Display depth.
	form borderWidth: 5.
	form border: form boundingBox width: 4 fillColor: Color white.
	form fill: form boundingBox fillColor: c.

	^form
]

{ #category : #'pluggable menus' }
BitEditor >> getPluggableYellowButtonMenu: shiftKeyState [
	^ YellowButtonMenu
]

{ #category : #'control defaults' }
BitEditor >> isControlActive [
	^ super isControlActive and: [sensor keyboardPressed not]
]

{ #category : #'control defaults' }
BitEditor >> redButtonActivity [
	| formPoint displayPoint |
	model depth = 1 ifTrue:
		["If this is just a black&white form, then set the color to be
		the opposite of what it was where the mouse was clicked"
		formPoint := (view inverseDisplayTransform: sensor cursorPoint - (scale//2)) rounded.
		color := 1-(view workingForm pixelValueAt: formPoint).
		squareForm fillColor: (color=1 ifTrue: [Color black] ifFalse: [Color white])].
	[sensor redButtonPressed]
	  whileTrue: 
		[formPoint := (view inverseDisplayTransform: sensor cursorPoint - (scale//2)) rounded.
		displayPoint := view displayTransform: formPoint.
		squareForm 
			displayOn: Display
			at: displayPoint 
			clippingBox: view insetDisplayBox 
			rule: Form over
			fillColor: nil.
		view changeValueAt: formPoint put: color]
]

{ #category : #'initialize-release' }
BitEditor >> release [

	super release.
	squareForm release.
	squareForm := nil
]

{ #category : #'menu messages' }
BitEditor >> setColor: aColor [ 
	"Set the color that the next edited dots of the model to be the argument,  
	aSymbol. aSymbol can be any color changing message understood by a  
	Form, such as white or black."

	color := aColor pixelValueForDepth: Display depth.
	squareForm fillColor: aColor.
	self changed: #getCurrentColor
]

{ #category : #'menu messages' }
BitEditor >> setTransparentColor [
	squareForm fillColor: Color gray.
	color := Color transparent
]

{ #category : #'menu messages' }
BitEditor >> test [
	view workingForm follow: [Sensor cursorPoint] while: [Sensor noButtonPressed].
	Sensor waitNoButton
]

{ #category : #'view access' }
BitEditor >> view: aView [

	super view: aView.
	scale := aView transformation scale.	
	scale := scale x rounded @ scale y rounded.
	squareForm := Form extent: scale depth: aView model depth.
	squareForm fillBlack
]
