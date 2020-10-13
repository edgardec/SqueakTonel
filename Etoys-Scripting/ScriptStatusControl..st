Class {
	#name : #ScriptStatusControl,
	#superclass : #AlignmentMorph,
	#instVars : [
		'tickPauseWrapper',
		'tickPauseButtonsShowing',
		'scriptInstantiation'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #initialization }
ScriptStatusControl >> assurePauseTickControlsShow [
	"Add two little buttons that allow the user quickly to toggle between paused and ticking state"

	| colorSelector status |
	self beTransparent.
	(tickPauseWrapper isKindOf: TickIndicatorMorph) ifFalse:[
		"this was an old guy"
		tickPauseWrapper ifNotNil:[tickPauseWrapper delete].
		tickPauseWrapper := TickIndicatorMorph new.
		tickPauseWrapper on: #mouseDown send: #mouseDownTick:onItem: to: self.
		tickPauseWrapper on: #mouseUp send: #mouseUpTick:onItem: to: self.
		tickPauseWrapper setBalloonText:'Press to toggle ticking state. Hold down to set tick rate.' translated.
		self addMorphFront: tickPauseWrapper.
	].
	status := scriptInstantiation status.
	colorSelector := ScriptingSystem statusColorSymbolFor: status.
	tickPauseWrapper color: (Color perform: colorSelector) muchLighter.
	tickPauseWrapper stepTime: (1000 // scriptInstantiation tickingRate max: 0).
	tickPauseWrapper isTicking: status == #ticking.
	tickPauseButtonsShowing := true.
]

{ #category : #initialization }
ScriptStatusControl >> initializeFor: aScriptInstantiation [
	"Answer a control that will serve to reflect and allow the user to change the status of the receiver"

	|  statusReadout |
	self hResizing: #shrinkWrap.
	self vResizing: #shrinkWrap.
	self cellInset: 0@0.
	self layoutInset: 0.
	scriptInstantiation := aScriptInstantiation.
	tickPauseButtonsShowing := false.

	self addMorphBack: (statusReadout := UpdatingSimpleButtonMorph new).
	statusReadout label: aScriptInstantiation status asString font: ScriptingSystem fontForEToyButtons.
	statusReadout setNameTo: 'trigger'.
	statusReadout height: statusReadout height - 4.
	statusReadout vResizing: #rigid.

	statusReadout target: aScriptInstantiation; wordingSelector: #translatedStatus; actionSelector: #presentScriptStatusPopUp.
	statusReadout setBalloonText: 'when this script should run' translated.
	statusReadout actWhen: #buttonDown.

	self assurePauseTickControlsShow.
	aScriptInstantiation updateStatusMorph: self
]

{ #category : #initialization }
ScriptStatusControl >> intoWorld: aWorld [
	super intoWorld: aWorld.
	aWorld ifNotNil:[self updateStatus].
]

{ #category : #initialization }
ScriptStatusControl >> maybeRemovePauseTickControls [
	"If we're in the business of removing pauseTick controls when we're neither paused nor ticking, then do it now.  The present take is not to remove these controls, which explains why the body of this method is currently commented out."
	tickPauseButtonsShowing := false.
	"note: the following is to change color of the tick control appropriately"
	self assurePauseTickControlsShow.
]

{ #category : #'mouse gestures' }
ScriptStatusControl >> mouseDownTick: evt onItem: aMorph [
	aMorph color: Color veryLightGray.
	self addAlarm: #offerTickingMenu: with: aMorph after: 1000.
]

{ #category : #'mouse gestures' }
ScriptStatusControl >> mouseUpTick: evt onItem: aMorph [
	self removeAlarm: #offerTickingMenu:.
	(self ownerThatIsA: ScriptEditorMorph) ifNotNil:[ :i | i deleteEtoysDebugger].
	aMorph color: (Color r: 0.767 g: 0.767 b: 1.0).
	(scriptInstantiation status == #ticking) ifTrue:[
		scriptInstantiation status: #paused. 
		aMorph color: (Color r: 1.0 g: 0.774 b: 0.774).
		aMorph isTicking: false.
	] ifFalse:[
		scriptInstantiation status: #ticking. 
		aMorph color: (Color r: 0.767 g: 0.767 b: 1.0).
		aMorph isTicking: true.
	].
	scriptInstantiation updateAllStatusMorphs.
]

{ #category : #'mouse gestures' }
ScriptStatusControl >> offerTickingMenu: aMorph [
	self assurePauseTickControlsShow. "to set the color"
	^scriptInstantiation presentTickingMenu
]

{ #category : #'mouse gestures' }
ScriptStatusControl >> pausedUp: ignored with: alsoIgnored [
	"The paused button was hit -- respond to it"

	(scriptInstantiation status == #paused)
		ifFalse:
			[scriptInstantiation status: #paused; updateAllStatusMorphs]

]

{ #category : #access }
ScriptStatusControl >> scriptInstantiation [
	"Answer the scriptInstantiation object with which the receiver is associated"

	^ scriptInstantiation
]

{ #category : #'script status' }
ScriptStatusControl >> scriptIsPaused [
	"Answer whether the script is paused"

	^ scriptInstantiation status == #paused
]

{ #category : #'script status' }
ScriptStatusControl >> scriptIsTicking [
	"Answer whether the script is ticking"

	^ scriptInstantiation status == #ticking
]

{ #category : #'mouse gestures' }
ScriptStatusControl >> tickingUp: ignored with: alsoIgnored [
	"The user hit the ticking control; make the status become one of ticking"

	scriptInstantiation status == #ticking
		ifFalse:
			[scriptInstantiation status: #ticking; updateAllStatusMorphs]

]

{ #category : #access }
ScriptStatusControl >> updateStatus [
	scriptInstantiation updateStatusMorph: self
]
