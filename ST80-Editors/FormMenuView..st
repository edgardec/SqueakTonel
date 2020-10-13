"
I represent a View whose subViews are Switches (and Buttons and OneOnSwitches) whose actions set the mode, color, and tool for editing a Form on the screen. The default controller of my instances is FormMenuController.
"
Class {
	#name : #FormMenuView,
	#superclass : #View,
	#classVars : [
		'BorderForm',
		'FormButtons',
		'SpecialBorderForm'
	],
	#category : #'ST80-Editors'
}

{ #category : #'class initialization' }
FormMenuView class >> fileOut [
	"Save the FormEditor button icons."
	"FormMenuView fileOut"

	| names |
	names := 
		#('select.form' 'singlecopy.form' 'repeatcopy.form' 'line.form' 'curve.form'
		'block.form' 'over.form' 'under.form' 'reverse.form' 'erase.form' 'in.form'
		'magnify.form' 'white.form' 'lightgray.form' 'gray.form' 'darkgray.form' 'black.form'
		'xgrid.form' 'ygrid.form' 'togglegrids.form' 'out.form').
	1 to: FormButtons size do: [:i |
		(FormButtons at: i) form writeOnFileNamed: (names at: i)].
	SpecialBorderForm writeOnFileNamed: 'specialborderform.form'.
	BorderForm writeOnFileNamed: 'borderform.form'.

]

{ #category : #accessing }
FormMenuView class >> formButtons [

  ^FormButtons
]

{ #category : #'class initialization' }
FormMenuView class >> initialize2 [
	"The icons for the menu are typically stored on files. In order to avoid reading them every time, they are stored in a collection in a class variable, along with their offset, tool value, and initial visual state (on or off)."
	"FormMenuView initialize"

	| offsets keys states names button |
	offsets := OrderedCollection new: 21.
	#(0 64 96 128 160 192 256 288 320 352 420) do: [:i | offsets addLast: i@0].  "First row"
	#(0 64 96 128 160 192 256 304 352 420) do: [:i | offsets addLast: i@48].  "Second row"
	offsets := offsets asArray.
	keys := #($a $s $d $f $g $h $j $k $l $; $' $z $x $c $v $b $n $m $, $. $/ ).  "Keyboard"
	states := #(
		#false #false #true #false #false #false #true #false #false #false #false
		#false #false #false #false #false #true #false #false #false #false).  "Initial button states"
	names := 
		#('select.form' 'singlecopy.form' 'repeatcopy.form' 'line.form' 'curve.form'
		'block.form' 'over.form' 'under.form' 'reverse.form' 'erase.form' 'in.form'
		'magnify.form' 'white.form' 'lightgray.form' 'gray.form' 'darkgray.form' 'black.form'
		'xgrid.form' 'ygrid.form' 'togglegrids.form' 'out.form').  "Files of button images"
	FormButtons := OrderedCollection new.
	1 to: 21 do: [:index |
		button := FormButtonCache new.
		button form: (Form fromFileNamed: (names at: index)).
		button offset: (offsets at: index).
		button value: (keys at: index).
		button initialState: (states at: index).
		FormButtons addLast: button].
	SpecialBorderForm  := Form fromFileNamed: 'specialborderform.form'.
	BorderForm := Form fromFileNamed: 'borderform.form'.

]

{ #category : #'controller access' }
FormMenuView >> defaultControllerClass [ 
	"Refer to the comment in View|defaultControllerClass."

	^FormMenuController
]

{ #category : #private }
FormMenuView >> makeButton: index [

	| buttonCache button |
	buttonCache := (FormButtons at: index) shallowCopy.
	buttonCache form: (FormButtons at: index) form copy.
	button := Button newOff.
	button onAction: [model changeTool: buttonCache value].
	self makeViews: buttonCache for: button.

]

{ #category : #private }
FormMenuView >> makeColorConnections: indexInterval [

	| connector aSwitchView |
	connector := Object new.  "a dummy model for connecting dependents"
	indexInterval do: [:index | | button buttonCache |
	buttonCache := (FormButtons at: index) shallowCopy.
	buttonCache form: (FormButtons at: index) form copy.
		buttonCache initialState = #true
			ifTrue: [button := OneOnSwitch newOn]
			ifFalse: [button := OneOnSwitch newOff].
		button onAction: [model changeTool: buttonCache value].
		button connection: connector.
		aSwitchView := self makeViews: buttonCache for: button.
		aSwitchView
			borderWidthLeft: 1 right: 0 top: 1 bottom: 1;
			action: #turnOn].
	aSwitchView borderWidth: 1.

]

{ #category : #private }
FormMenuView >> makeConnections: indexInterval [

	| connector aSwitchView |
	connector := Object new.  "a dummy model for connecting dependents."
	indexInterval do: [:index | | button buttonCache |
	buttonCache := (FormButtons at: index) shallowCopy.
	buttonCache form: (FormButtons at: index) form copy.
		buttonCache initialState = #true
			ifTrue: [button := OneOnSwitch newOn]
			ifFalse: [button := OneOnSwitch newOff].
		button onAction: [model changeTool: buttonCache value].
		button connection: connector.
		aSwitchView := self makeViews: buttonCache for: button.
		aSwitchView
			borderWidthLeft: 1 right: 0 top: 1 bottom: 1;
			action: #turnOn].
	aSwitchView borderWidth: 1.

]

{ #category : #'initialize-release' }
FormMenuView >> makeFormEditorMenu [

	| button buttonCache form aSwitchView aSwitchController|
	"Now get those forms into the subviews"
	self makeButton: 1.					"form source"
	self makeConnections: (2 to: 6).		"tools"
	self makeConnections: (7 to: 10).		"modes"
	self makeButton: 11.					"filing in"
	self makeButton: 12.					"bit editing"
	self makeColorConnections: (13 to: 17).		"colors"
	self makeGridSwitch: 18.					"toggle x"
	self makeGridSwitch: 19.					"toggle y"
	self makeButton: 20.					"setting grid"
	self makeButton: 21					"filing out"
]

{ #category : #private }
FormMenuView >> makeGridSwitch: index [

	| buttonCache button |
	buttonCache := FormButtons at: index.
	buttonCache form: (FormButtons at: index) form copy.
	buttonCache initialState = #true
		ifTrue: [button := Switch newOn]
		ifFalse: [button := Switch newOff].
	button onAction: [model changeTool: buttonCache value].
	button offAction: [model changeTool: buttonCache value].
	self makeViews: buttonCache for: button.

]

{ #category : #private }
FormMenuView >> makeSwitch: index [

	| buttonCache button |
	buttonCache := (FormButtons at: index) shallowCopy.
	buttonCache form: (FormButtons at: index) form copy.
	buttonCache initialState = #true
		ifTrue: [button := Switch newOn]
		ifFalse: [button := Switch newOff].
	button onAction: [model changeTool: buttonCache value].
	self makeViews: buttonCache for: button.

]

{ #category : #private }
FormMenuView >> makeViews: cache for: aSwitch [

	| form aSwitchView |
	form := cache form.
	aSwitchView := PluggableButtonView
		on: aSwitch
		getState: #isOn
		action: #switch.
	aSwitchView
		label: form;
		shortcutCharacter: cache value;
		window: (0@0 extent: form extent);
		translateBy: cache offset;
		borderWidth: 1.
	self addSubView: aSwitchView.
	^ aSwitchView

]

{ #category : #'subView access' }
FormMenuView >> subViewContainingCharacter: aCharacter [
	"Answer the receiver's subView that corresponds to the key, aCharacter. 
	Answer nil if no subView is selected by aCharacter."

	self subViews reverseDo: 
		[:aSubView |
		(aSubView shortcutCharacter = aCharacter) ifTrue: [^aSubView]].
	^nil	

]
