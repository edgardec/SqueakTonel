"
I represent the basic editor for creating and modifying Forms. This is intended to be an easy to use general-purpose picture (bitMap) editor. I am a kind of MouseMenuController that creates a yellow button menu for accepting and canceling edits. My instances give up control if the cursor is outside the FormView or if a key on the keyboard is pressed.

The form to be edited is stored in instance variable model.
The instance variable form references the paint brush.
"
Class {
	#name : #FormEditor,
	#superclass : #MouseMenuController,
	#instVars : [
		'form',
		'tool',
		'grid',
		'togglegrid',
		'mode',
		'previousTool',
		'color',
		'unNormalizedColor',
		'xgridOn',
		'ygridOn',
		'hasUnsavedChanges'
	],
	#classVars : [
		'BitEditKey',
		'BlackKey',
		'BlockKey',
		'ChangeGridsKey',
		'CurveKey',
		'DarkGrayKey',
		'EraseKey',
		'FlashCursor',
		'GrayKey',
		'InKey',
		'LightGrayKey',
		'LineKey',
		'OutKey',
		'OverKey',
		'RepeatCopyKey',
		'ReverseKey',
		'SelectKey',
		'SingleCopyKey',
		'TogglexGridKey',
		'ToggleyGridKey',
		'UnderKey',
		'WhiteKey',
		'YellowButtonMenu',
		'YellowButtonMessages',
		'YgridKey'
	],
	#category : #'ST80-Editors'
}

{ #category : #private }
FormEditor class >> createFullScreenForm [
	"Create a StandardSystemView for a FormEditor on the form whole screen."
	| formView formEditor menuView topView extent aForm |
	aForm := Form extent: (Display extent x @ (Display extent y - 112)) depth: Display depth.
	formView := FormHolderView new model: aForm.
	formView borderWidthLeft: 0 right: 0 top: 0 bottom: 1.
	formEditor := formView controller.
	menuView := FormMenuView new makeFormEditorMenu model: formEditor.
	formEditor model: menuView controller.
	topView := StandardSystemView new.
	topView backgroundColor: #veryLightGray.
	topView model: aForm.
	topView addSubView: formView.
	topView 
		addSubView: menuView
		align: menuView viewport topCenter
		with: formView viewport bottomCenter + (0@16).
	topView window: 
		(formView viewport 
			merge: (menuView viewport expandBy: (16 @ 0 corner: 16@16))).
	topView label: 'Form Editor'.
	extent := topView viewport extent.
	topView minimumSize: extent.
	topView maximumSize: extent.
	^topView


]

{ #category : #private }
FormEditor class >> createOnForm: aForm [
	"Create a StandardSystemView for a FormEditor on the form aForm."
	| formView formEditor menuView aView topView extent topViewBorder |
	topViewBorder := 2.
	formView := FormHolderView new model: aForm.
	formEditor := formView controller.
	menuView := FormMenuView new makeFormEditorMenu model: formEditor.
	formEditor model: aForm.
	aView := View new.
	aView model: aForm.
	aView addSubView: formView.
	aView 
		addSubView: menuView
		align: menuView viewport topCenter
		with: formView viewport bottomCenter + (0@16).
	aView window: 
		((formView viewport 
			merge: (menuView viewport expandBy: (16 @ 0 corner: 16@16))) 
		  expandBy: (0@topViewBorder corner: 0@0)).
	topView := "ColorSystemView" FormEditorView new.
	topView model: formEditor.
	topView backgroundColor: #veryLightGray.
	topView addSubView: aView.
	topView label: 'Form Editor'.
	topView borderWidth: topViewBorder.
	extent := topView viewport extent.
	topView minimumSize: extent.
	topView maximumSize: extent.
	^topView
]

{ #category : #'class initialization' }
FormEditor class >> flashCursor: aBoolean [

	FlashCursor := aBoolean

	"FormEditor flashCursor: true"
]

{ #category : #examples }
FormEditor class >> formFromDisplay [
	"Create an instance of me on a new form designated by the user at a
	location designated by the user."

	Form fromUser edit

	"FormEditor formFromDisplay"
]

{ #category : #examples }
FormEditor class >> fullScreen [
	"Create an instance of me on a new form that fills the full size of the
	display screen."

	FormEditor openFullScreenForm

	"FormEditor fullScreen"
]

{ #category : #'class initialization' }
FormEditor class >> initialize [

	FlashCursor := false.
	self setKeyboardMap.
	YellowButtonMenu := SelectionMenu 
		labels:
'accept
cancel
edit
file out'
		lines: #(2)
		selections: #(accept cancel edit fileOut).

	"FormEditor initialize"
]

{ #category : #examples }
FormEditor class >> newForm [
	"Create an instance of me on a new form at a location designated by the user. "

	(Form extent: 400 @ 200 depth: Display depth)
	    fillWhite;
	    edit

	"FormEditor newForm"
]

{ #category : #'instance creation' }
FormEditor class >> openFullScreenForm [
	"Create and schedule an instance of me on the form whose extent is the 
	extent of the display screen."

	| topView |
	topView := self createFullScreenForm.
	topView controller 
		openDisplayAt: (topView viewport extent//2)

	"FormEditor openFullScreenForm."
]

{ #category : #'instance creation' }
FormEditor class >> openOnForm: aForm [
	"Create and schedule an instance of me on the form aForm."

	| topView |
	topView := self createOnForm: aForm.
	topView controller open


]

{ #category : #private }
FormEditor class >> setKeyboardMap [
	"Keyboard Mapping."

	SelectKey:=$a.
	SingleCopyKey:=$s.			"tools"
	RepeatCopyKey:=$d.
	LineKey:=$f.
	CurveKey:=$g.
	BlockKey:=$h.
	OverKey:=$j.				"modes"
	UnderKey:=$k.
	ReverseKey:=$l.
	EraseKey:=$;.
	InKey:=$'.					"file In"
	BitEditKey:=$z.
	WhiteKey:=$x.				"colors"
	LightGrayKey:=$c.
	GrayKey:=$v.
	DarkGrayKey:=$b.
	BlackKey:=$n.
	TogglexGridKey:=$m.		"gridding"
	ToggleyGridKey:=$,.
	ChangeGridsKey:=$..
	OutKey:=$/					"file Out"
]

{ #category : #'menu messages' }
FormEditor >> accept [
	"The edited information should now be accepted by the view."

	view updateDisplay.
	view accept.
	hasUnsavedChanges contents: false.
]

{ #category : #'editing tools' }
FormEditor >> block [
	"Allow the user to fill a rectangle with the gray tone and mode currently 
	selected."

	| rectangle originRect |
	originRect := (Sensor cursorPoint grid: grid) extent: 2 @ 2.
 	rectangle := Cursor corner showWhile:
		[originRect newRectFrom:
			[:f | f origin corner: (Sensor cursorPoint grid: grid)]].
	rectangle isNil 
		ifFalse:
		  [sensor waitNoButton.
		   Display
					fill: (rectangle intersect: view insetDisplayBox)
					rule: mode
					fillColor: color.
		   hasUnsavedChanges contents: true.]
]

{ #category : #'menu messages' }
FormEditor >> cancel [
	"The edited information should be forgotten by the view."

	view cancel.
	hasUnsavedChanges contents: false.
]

{ #category : #'editing tools' }
FormEditor >> changeGridding [
	"Allow the user to change the values of the horizontal and/or vertical 
	grid modules. Does not change the primary tool."

	| response gridInteger gridX gridY |
	gridX := togglegrid x.
	gridY := togglegrid y.
	response := UIManager default
		request:
'Current horizontal gridding is: ', gridX printString, '.
Type new horizontal gridding.'.
	response isEmpty
		ifFalse: 
			[gridInteger := Integer readFromString: response.
			gridX := ((gridInteger max: 1) min: Display extent x)].
	response := UIManager default
		request:
'Current vertical gridding is: ', gridY printString, '.
Type new vertical gridding.'.
	response isEmpty
		ifFalse: 
			[gridInteger := Integer readFromString: response.
			gridY := ((gridInteger max: 1) min: Display extent y)].
	xgridOn ifTrue: [grid := gridX @ grid y].
	ygridOn ifTrue: [grid := grid x @ gridY].
	togglegrid := gridX @ gridY.
	tool := previousTool
]

{ #category : #'editing tools' }
FormEditor >> changeTool: aCharacter [ 
	"Change the value of the instance variable tool to be the tool 
	corresponding to aCharacter. Typically sent from a Switch in a 
	FormMenuView."

	previousTool := tool.
	tool := self selectTool: aCharacter.
	(#(singleCopy repeatCopy line curve block) includes: tool)
		ifFalse:
			[self perform: tool]
]

{ #category : #'editing tools' }
FormEditor >> colorBlack [
	"Set the mask (color) to black. Leaves the tool set in its previous state."

	self setColor: Color black
]

{ #category : #'editing tools' }
FormEditor >> colorDarkGray [
	"Set the mask (color) to dark gray. Leaves the tool set in its previous 
	state."

	self setColor: Color darkGray
]

{ #category : #'editing tools' }
FormEditor >> colorGray [
	"Set the color to gray. Leaves the tool set in its previous state."

	self setColor: Color gray.

]

{ #category : #'editing tools' }
FormEditor >> colorLightGray [
	"Set the mask (color) to light gray. Leaves the tool set in its previous 
	state."

	self setColor: Color lightGray
]

{ #category : #'editing tools' }
FormEditor >> colorWhite [
	"Set the color to white. Leaves the tool set in its previous state."

	self setColor: Color white
]

{ #category : #'control defaults' }
FormEditor >> controlActivity [

	super controlActivity.
	self dragForm
]

{ #category : #'basic control sequence' }
FormEditor >> controlInitialize [

	Cursor crossHair show.
	self normalizeColor: unNormalizedColor.
	sensor waitNoButton
]

{ #category : #'basic control sequence' }
FormEditor >> controlTerminate [
	"Resets the cursor to be the normal Smalltalk cursor."

	Cursor normal show.
	view updateDisplay
]

{ #category : #cursor }
FormEditor >> cursorPoint [
	"Answer the mouse coordinate data gridded according to the receiver's 
	grid."

	^sensor cursorPoint grid: grid
]

{ #category : #'editing tools' }
FormEditor >> curve [
	"Conic-section specified by three points designated by: first point--press 
	red button second point--release red button third point--click red button. 
	The resultant curve on the display is displayed according to the current 
	form and mode."

	| firstPoint secondPoint thirdPoint curve drawForm |
	"sensor noButtonPressed ifTrue: [^self]."
	firstPoint := self cursorPoint.
	secondPoint := self rubberBandFrom: firstPoint until: [sensor noButtonPressed].
	thirdPoint :=  self rubberBandFrom: secondPoint until: [sensor redButtonPressed].
	Display depth > 1
	  ifTrue:
	    [self deleteRubberBandFrom: secondPoint to: thirdPoint.
	     self deleteRubberBandFrom: firstPoint to: secondPoint].
	curve := CurveFitter new.
	curve firstPoint: firstPoint.
	curve secondPoint: secondPoint.
	curve thirdPoint: thirdPoint.
	drawForm := form asFormOfDepth: Display depth.
	Display depth > 1 ifTrue:
	  [drawForm mapColor: Color white to: Color transparent; 
	               mapColor: Color black to: color].

	curve form: drawForm.
	curve
		displayOn: Display
		at: 0 @ 0
		clippingBox: view insetDisplayBox
		rule: (Display depth > 1 ifTrue: [mode ~= Form erase ifTrue: [Form paint] ifFalse: [mode]]
										ifFalse: [mode])
		fillColor: (Display depth = 1 ifTrue: [color] ifFalse: [nil]). 
	sensor waitNoButton.
	hasUnsavedChanges contents: true.
]

{ #category : #private }
FormEditor >> deleteRubberBandFrom: startPoint to: endPoint [

	(Line from: startPoint to: endPoint withForm: form)
		displayOn: Display
		at: 0 @ 0
		clippingBox: view insetDisplayBox
		rule: Form reverse
		fillColor: (Display depth = 1 ifTrue: [Color black] ifFalse: [Color gray]).
]

{ #category : #private }
FormEditor >> dragForm [

	tool = #block
		ifTrue:
			[Cursor origin show.
			[sensor anyButtonPressed
				or: [sensor keyboardPressed
				or: [self viewHasCursor not]]]
				whileFalse: [].
			^self cursorPoint]
		ifFalse:
			[^self trackFormUntil:
				[sensor anyButtonPressed
					or: [sensor keyboardPressed
					or: [self viewHasCursor not]]]]
]

{ #category : #'menu messages' }
FormEditor >> edit [
	model edit
]

{ #category : #'editing tools' }
FormEditor >> eraseMode [
	"Set the mode for the tools that copy the form onto the display to erase. 
	Leaves the tool set in its previous state."

	mode := 4.
	tool := previousTool
]

{ #category : #'editing tools' }
FormEditor >> fileInForm [
	"Ask the user for a file name and then recalls the Form in that file as the current source Form (form). Does not change the tool."

	| fileName |
	fileName := UIManager default
		chooseFileMatchingSuffixes: #('form')
		label: 'File name?' translated.
	fileName ifNil: [^ self].
	form := Form fromFileNamed: fileName.
	tool := previousTool.

]

{ #category : #'menu messages' }
FormEditor >> fileOut [

	| fileName |
	fileName := UIManager default
		saveFilenameRequest: 'File name?' translated
		initialAnswer: 'Filename.form'.
	fileName ifNil: [^ self].
	Cursor normal
		showWhile: [model writeOnFileNamed: fileName].

]

{ #category : #'editing tools' }
FormEditor >> fileOutForm [
	"Ask the user for a file name and save the current source form under that name. Does not change the tool."

	| fileName |
	fileName := UIManager default
		saveFilenameRequest: 'File name?' translated
		initialAnswer: 'Filename.form'.
	fileName ifNil: [^ self].
	Cursor normal
		showWhile: [form writeOnFileNamed: fileName].
	tool := previousTool.

]

{ #category : #'pluggable menus' }
FormEditor >> getPluggableYellowButtonMenu: shiftKeyState [
	^ YellowButtonMenu
]

{ #category : #'initialize-release' }
FormEditor >> initialize [
	super initialize.
	self setVariables
]

{ #category : #'control defaults' }
FormEditor >> isControlActive [
	^ super isControlActive and: [sensor keyboardPressed not]
]

{ #category : #'editing tools' }
FormEditor >> line [
	"Line is specified by two points from the mouse: first point--press red 
	button; second point--release red button. The resultant line is displayed 
	according to the current form and mode."

	| firstPoint endPoint drawForm |
	drawForm := form asFormOfDepth: Display depth.
	
	 Display depth > 1 
	  ifTrue:
	    [drawForm mapColor: Color white to: Color transparent; 
	                 mapColor: Color black to: color].
	           
	firstPoint := self cursorPoint.
	endPoint := self rubberBandFrom: firstPoint until: [sensor noButtonPressed].
	endPoint isNil ifTrue: [^self].
	Display depth > 1 ifTrue: [self deleteRubberBandFrom: firstPoint to: endPoint.].
	(Line from: firstPoint to: endPoint withForm: drawForm)
		displayOn: Display
		at: 0 @ 0
		clippingBox: view insetDisplayBox
		rule: (Display depth > 1 ifTrue: [mode ~= Form erase ifTrue: [Form paint] ifFalse: [mode]]
								ifFalse: [mode])
		fillColor: (Display depth = 1 ifTrue: [color] ifFalse: [nil]).  
		hasUnsavedChanges contents: true.
]

{ #category : #'editing tools' }
FormEditor >> magnify [
	"Allow for bit editing of an area of the Form. The user designates a 
	rectangular area that is scaled by 5 to allow individual screens dots to be 
	modified. Red button is used to set a bit to black, and yellow button is 
	used to set a bit to white. Editing continues until the user depresses any 
	key on the keyboard."

	| smallRect smallForm scaleFactor tempRect |
	scaleFactor := 8@8.
	smallRect := (Rectangle fromUser: grid) intersect: view insetDisplayBox.
	smallRect isNil ifTrue: [^self].
	smallForm := Form fromDisplay: smallRect.

	"Do this computation here in order to be able to save the existing display screen."
	tempRect := Rectangle locateMagnifiedView: smallForm scale: scaleFactor.
	BitEditor
		openScreenViewOnForm: smallForm 
		at: smallRect topLeft 
		magnifiedAt: tempRect topLeft 
		scale: scaleFactor.
	tool := previousTool
]

{ #category : #'editing tools' }
FormEditor >> newSourceForm [
	"Allow the user to define a new source form for the FormEditor. Copying 
	the source form onto the display is the primary graphical operation. 
	Resets the tool to be repeatCopy."
	| dForm interiorPoint interiorColor |

	dForm := Form fromUser: grid.
	"sourceForm must be only 1 bit deep"
	interiorPoint := dForm extent // 2.
	interiorColor := dForm colorAt: interiorPoint.
	form := (dForm makeBWForm: interiorColor) reverse
				findShapeAroundSeedBlock:
					[:f | f pixelValueAt: interiorPoint put: 1].
	form := form trimBordersOfColor: Color white.
	tool := previousTool
]

{ #category : #private }
FormEditor >> normalizeColor: aColor [

	color := aColor.

]

{ #category : #'window support' }
FormEditor >> okToChange [

  ^hasUnsavedChanges contents not
	ifFalse:
	  [self confirm:
		'This drawing was not saved.\Is it OK to close this window?' withCRs
	  ]
	ifTrue:
	  [true]

]

{ #category : #'editing tools' }
FormEditor >> overMode [
	"Set the mode for the tools that copy the form onto the display to over. 
	Leaves the tool set in its previous state."

	mode := Form over.
	tool := previousTool
]

{ #category : #'menu messages' }
FormEditor >> redButtonActivity [ 
	"Refer to the comment in MouseMenuController|redButtonActivity."

	self perform: tool
]

{ #category : #'initialize-release' }
FormEditor >> release [
	"Break the cycle between the Controller and its view. It is usually not 
	necessary to send release provided the Controller's view has been properly 
	released independently."

	super release.
	form := nil
]

{ #category : #'editing tools' }
FormEditor >> repeatCopy [
	"As long as the red button is pressed, copy the source form onto the 
	display screen."
  | drawingWasChanged |
	drawingWasChanged := false.
	[sensor redButtonPressed]
		whileTrue: 
		[(BitBlt destForm: Display sourceForm: form halftoneForm: color
			combinationRule: (Display depth > 1 ifTrue: [mode ~= Form erase ifTrue: [Form paint] ifFalse: [mode]]
										ifFalse: [mode])
			destOrigin: self cursorPoint sourceOrigin: 0@0 extent: form extent
			clipRect: view insetDisplayBox)
			colorMap: (Bitmap with: 0 with: 16rFFFFFFFF);
			copyBits.
		  drawingWasChanged := true.
		].
	drawingWasChanged
	  ifTrue: [hasUnsavedChanges contents: true.]
]

{ #category : #'editing tools' }
FormEditor >> reverseMode [
	"Set the mode for the tools that copy the form onto the display to reverse. 
	Leaves the tool set in its previous state."

	mode := Form reverse.
	tool := previousTool
]

{ #category : #private }
FormEditor >> rubberBandFrom: startPoint until: aBlock [

	| endPoint previousEndPoint |
	previousEndPoint := startPoint.
	[aBlock value] whileFalse:
		[(endPoint := self cursorPoint) = previousEndPoint 
			ifFalse:
			[(Line from: startPoint to: previousEndPoint withForm: form) 
				displayOn: Display
				at: 0 @ 0
				clippingBox: view insetDisplayBox
				rule: Form reverse
				fillColor: Color gray.
			(Line from: startPoint to: endPoint withForm: form)
				displayOn: Display
				at: 0 @ 0
				clippingBox: view insetDisplayBox
				rule: Form reverse
				fillColor: Color gray.
			previousEndPoint  := endPoint]].
	(Line from: startPoint to: previousEndPoint withForm: form)
		displayOn: Display
		at: 0 @ 0
		clippingBox: view insetDisplayBox
		rule: Form reverse
		fillColor: (Display depth = 1 ifTrue: [Color gray] ifFalse: [Color black]).
	^endPoint
]

{ #category : #private }
FormEditor >> selectTool: aCharacter [
	"A new tool has been selected. It is denoted by aCharacter. Set the tool.
	This code is written out in long hand (i.e., rather than dispatching on a
	table of options) so that it is obvious what is happening."
	
	aCharacter =  SingleCopyKey	ifTrue: [^#singleCopy].
	aCharacter =  RepeatCopyKey	ifTrue: [^#repeatCopy].
	aCharacter =  LineKey			ifTrue: [^#line].					
	aCharacter =  CurveKey			ifTrue: [^#curve].				
	aCharacter =  BlockKey			ifTrue: [^#block].		
	aCharacter =  SelectKey			ifTrue: [^#newSourceForm].		
	aCharacter =  OverKey			ifTrue: [^#overMode].
	aCharacter =  UnderKey			ifTrue: [^#underMode].
	aCharacter =  ReverseKey		ifTrue: [^#reverseMode].
	aCharacter =  EraseKey			ifTrue: [^#eraseMode].
	aCharacter =  ChangeGridsKey	ifTrue: [^#changeGridding].
	aCharacter =  TogglexGridKey	ifTrue: [^#togglexGridding].
	aCharacter =  ToggleyGridKey	ifTrue: [^#toggleyGridding].
	aCharacter =  BitEditKey			ifTrue: [^#magnify].			
	aCharacter =  WhiteKey			ifTrue: [^#colorWhite].			
	aCharacter =  LightGrayKey		ifTrue: [^#colorLightGray].			
	aCharacter =  GrayKey			ifTrue: [^#colorGray].				
	aCharacter =  DarkGrayKey		ifTrue: [^#colorDarkGray].			
	aCharacter =  BlackKey			ifTrue: [^#colorBlack].				
	aCharacter =  OutKey			ifTrue: [^#fileOutForm].			
	aCharacter =  InKey				ifTrue: [^#fileInForm]
]

{ #category : #'editing tools' }
FormEditor >> setColor: aColor [
	"Set the mask (color) to aColor.
	Hacked to invoke color chooser if not B/W screen.
	Leaves the tool set in its previous state."

	self normalizeColor:  (unNormalizedColor := Display depth > 1
							ifTrue: [Color fromUser]
							ifFalse: [aColor]).
	tool := previousTool
]

{ #category : #private }
FormEditor >> setVariables [
	tool := #repeatCopy.
	previousTool := tool.
	grid := 1 @ 1.
	togglegrid := 8 @ 8.
	xgridOn := false.
	ygridOn := false.
	mode := Form over.
	form := Form extent: 8 @ 8.
	form fillBlack.
	unNormalizedColor := color := Color black.
	hasUnsavedChanges := ValueHolder new contents: false.

]

{ #category : #'editing tools' }
FormEditor >> singleCopy [ 
	"If the red button is clicked, copy the source form onto the display 
	screen."

   (BitBlt destForm: Display
           sourceForm: form halftoneForm: color
           combinationRule: (Display depth > 1 ifTrue: [mode ~= Form erase ifTrue: [Form paint] ifFalse: [mode]]
                                                     ifFalse: [mode])
           destOrigin: self cursorPoint sourceOrigin: 0@0 extent: form extent
           clipRect: view insetDisplayBox)
           colorMap: (Bitmap with: 0 with: 16rFFFFFFFF);
	copyBits.
	sensor waitNoButton.
	hasUnsavedChanges contents: true.
]

{ #category : #'editing tools' }
FormEditor >> togglexGridding [
	"Turn x (horizontal) gridding off, if it is on, and turns it on, if it is off. 
	Does not change the primary tool."

	xgridOn
		ifTrue: 
			[grid := 1 @ grid y.
			xgridOn := false]
		ifFalse: 
			[grid := togglegrid x @ grid y.
			xgridOn := true].
	tool := previousTool
]

{ #category : #'editing tools' }
FormEditor >> toggleyGridding [
	"Turn y (vertical) gridding off, if it is on, and turns it on, if it is off. 
	Does not change the primary tool."

	ygridOn
		ifTrue: 
			[grid := grid x @ 1.
			ygridOn := false]
		ifFalse: 
			[grid := grid x @ togglegrid y.
			ygridOn := true].
	tool := previousTool
]

{ #category : #private }
FormEditor >> trackFormUntil: aBlock [

	| previousPoint cursorPoint displayForm |
	previousPoint := self cursorPoint.
	displayForm := Form extent: form extent depth: form depth.
	displayForm copy: (0 @ 0 extent: form extent)
	               from: form
	               to: 0 @ 0
	               rule: Form over.
	Display depth > 1 ifTrue: [displayForm reverse]. 
	displayForm displayOn: Display at: previousPoint rule: Form reverse.
	[aBlock value] whileFalse:
		[cursorPoint := self cursorPoint.
		(FlashCursor or: [cursorPoint ~= previousPoint])
			ifTrue:
			[displayForm displayOn: Display at: previousPoint rule: Form reverse.
			displayForm displayOn: Display at: cursorPoint rule: Form reverse.
			previousPoint := cursorPoint]].
	displayForm displayOn: Display at: previousPoint rule: Form reverse.
	^previousPoint
]

{ #category : #'editing tools' }
FormEditor >> underMode [
	"Set the mode for the tools that copy the form onto the display to under. 
	Leaves the tool set in its previous state."

	mode := Form under.
	tool := previousTool
]
