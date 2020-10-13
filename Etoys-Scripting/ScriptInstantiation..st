"
One of these is associated with each user-defined script for each Player.   Holds the state that defines when the script should be run automatically by the system.

	player				The player whose script this is.
	selector				The message to send my player to activate this script
	status				#ticking, #paused, #normal, #mouseDown, #mouseStillDown, #mouseUp,
							#mouseEnter, #mouseLeave, #keyStroke
	frequency			For ticking scripts, their frequency.  Place-holder: not implemented yet
	anonymous			If true, the script has is unnamed -- in this case, the selector is private to the implementation
"
Class {
	#name : #ScriptInstantiation,
	#superclass : #Object,
	#instVars : [
		'player',
		'selector',
		'status',
		'frequency',
		'anonymous',
		'tickingRate',
		'lastTick'
	],
	#category : #'Etoys-Scripting'
}

{ #category : #'customevents-status control' }
ScriptInstantiation >> addStatusChoices: choices toMenu: menu [
	choices isEmpty ifFalse: [
		choices	 do: [ :choice || label sym |
			(choice isKindOf: Array) 
				ifTrue: [ label := choice first translated. sym := choice second ]
				ifFalse: [ label := choice translated. sym := choice ].
			menu add: label target: menu selector: #modalSelection: argument: sym ].
		menu addLine. ].
	^menu.

]

{ #category : #'customevents-status control' }
ScriptInstantiation >> addStatusChoices: choices toSubMenu: submenu forMenu: menu [
	choices isEmpty ifFalse: [
		choices	 do: [ :choice || label sym |
			(choice isKindOf: Array) 
				ifTrue: [ label := choice first translated. sym := choice second ]
				ifFalse: [ label := choice translated. sym := choice ].
			submenu add: label target: menu selector: #modalSelection: argument: sym ].
		menu addLine. ].
	^menu.

]

{ #category : #misc }
ScriptInstantiation >> assignStatusToAllSiblings [
	"Let all sibling instances of my player have the same status that I do.  The stati affected are both the event stati and the tickingStati"

	
	(player class allInstances copyWithout: player) do:
		[:aPlayer | | aScriptInstantiation |
			aScriptInstantiation := aPlayer scriptInstantiationForSelector: selector.
			aScriptInstantiation status: status.
			aScriptInstantiation frequency: self frequency.
			aScriptInstantiation tickingRate: self tickingRate.
			aScriptInstantiation updateAllStatusMorphs]
]

{ #category : #misc }
ScriptInstantiation >> assignStatusToAllSiblingsIn: aStatusViewer [
	"Let all sibling instances of my player have the same status that I do"

	self assignStatusToAllSiblings.
	self updateAllStatusMorphs.
	aStatusViewer presenter reinvigorateAllScriptsTool: aStatusViewer 
]

{ #category : #misc }
ScriptInstantiation >> assureEventHandlerRepresentsStatus [
	self status: self status
]

{ #category : #'player & selector access' }
ScriptInstantiation >> changeSelectorTo: aNewSelector [
	"Change the selector associated with the receiver to the new one provided"

	selector := aNewSelector
]

{ #category : #'status control' }
ScriptInstantiation >> chooseTriggerFrom: ignored [
	"Backward compatibility for old scriptors"

	^ self presentScriptStatusPopUp
]

{ #category : #'customevents-status control' }
ScriptInstantiation >> defineNewEvent [
	| newEventName newEventHelp |
	"Prompt the user for the name of a new event and install it into the custom event table"
	newEventName := FillInTheBlankMorph request: 'What is the name of your new event?' translated.
	newEventName isEmpty ifTrue: [ ^self ].
	newEventName := newEventName asSymbol.
	(ScriptingSystem customEventStati includes: newEventName) ifTrue: [
		self inform: 'That event is already defined.' translated. ^self ].
	newEventHelp := FillInTheBlankMorph request: 'Please describe this event:' translated.
	ScriptingSystem addUserCustomEventNamed: newEventName help: newEventHelp.
]

{ #category : #'customevents-status control' }
ScriptInstantiation >> deleteCustomEvent [
	| userEvents eventName |
	userEvents :=  ScriptingSystem userCustomEventNames.
	eventName := UIManager default 
		chooseFrom: userEvents 
		values: userEvents 
		title: 'Remove which event?'.
	eventName ifNotNil: [ ScriptingSystem removeUserCustomEventNamed: eventName ].
	self class allSubInstancesDo: [ :ea | ea status = eventName ifTrue: [ ea status: #normal ]]
]

{ #category : #'customevents-status control' }
ScriptInstantiation >> explainStatusAlternatives [
	"Open a little window that explains the various status 
	alternatives "

	ScriptingSystem putUpInfoPanelFor:(ScriptingSystem statusHelpStringFor: player) title: 'Script Status' translated extent: 800@500
]

{ #category : #'status control' }
ScriptInstantiation >> fireOnce [
	"Run this script once"

	player triggerScript: selector
]

{ #category : #frequency }
ScriptInstantiation >> frequency [
	(frequency isNil or: [frequency = 0]) ifTrue: [frequency := 1].
	^frequency
]

{ #category : #frequency }
ScriptInstantiation >> frequency: aNumber [
	frequency := aNumber
]

{ #category : #anonymity }
ScriptInstantiation >> initializePermanentScriptFor: aPlayer selector: aSelector [
	"Initialize the receiver on behalf of the player, setting its status to #normal and giving it the given selector"

	player := aPlayer.
	status := #normal.
	selector := aSelector
]

{ #category : #misc }
ScriptInstantiation >> offerMenuIn: aStatusViewer [
	"Put up a menu."

	| aMenu |
	self currentHand showTemporaryCursor: nil.
	aMenu := MenuMorph new defaultTarget: self.
	aMenu title: player knownName, ' ', selector.
	aMenu addStayUpItem.
	(player class instanceCount > 1) ifTrue:
		[aMenu add: 'propagate status to siblings' translated selector: #assignStatusToAllSiblingsIn: argument: aStatusViewer.
		aMenu balloonTextForLastItem: 'Make the status of this script in all of my sibling instances be the same as the status you see here' translated].
	aMenu addLine.
	
	aMenu add: 'grab this object' translated target: player selector: #grabPlayerIn: argument: self currentWorld.
	aMenu balloonTextForLastItem: 'This will actually pick up the object bearing this script and hand it to you.  Click the (left) button to drop it' translated.
	
	aMenu add: 'reveal this object' translated target: player selector: #revealPlayerIn: argument: self currentWorld.
	aMenu balloonTextForLastItem: 'If you have misplaced the object bearing this script, use this item to (try to) make it visible' translated.
	
	aMenu add: 'tile representing this object' translated target: player selector: #tearOffTileForSelf.
	aMenu balloonTextForLastItem: 'choose this to obtain a tile which represents the object associated with this script' translated.
	
	aMenu addLine.
	
	aMenu add: 'open this script''s Scriptor' translated target: player selector: #grabScriptorForSelector:in: argumentList: {selector. aStatusViewer world}.
	aMenu balloonTextForLastItem: 'Open up the Scriptor for this script' translated.
	aMenu add: 'open this object''s Viewer' translated target: player selector: #beViewed.
	aMenu balloonTextForLastItem: 'Open up a Viewer for this object' translated.
	aMenu addLine.
	aMenu add: 'more...' translated target: self selector: #offerShiftedMenuIn: argument: aStatusViewer.
	aMenu balloonTextForLastItem: 'The "more..." branch offers you menu items that are less frequently used.' translated.
	^ aMenu popUpInWorld: self currentWorld
]

{ #category : #misc }
ScriptInstantiation >> offerShiftedMenuIn: aStatusViewer [
	"Put up the shifted menu"

	^ (MenuMorph new defaultTarget: self)
		title: player knownName, ' ', selector;
		add: 'grab this object' translated target: player selector: #grabPlayerIn: argument: self currentWorld;
		balloonTextForLastItem: 'Wherever this object currently is, the "grab" command will rip it out, and place it in your "hand".  This is a very drastic step, that can disassemble things that may be very hard to put back together!' translated;
		add: 'destroy this script' translated target: player selector: #removeScriptWithSelector: argument: selector;
		balloonTextForLastItem: 'Caution!  This is irreversibly destructive -- it removes the script from the system.' translated;
		
		addLine;
		
		add: 'inspect morph' translated target: player costume selector: #inspect;
		add: 'inspect player' translated target: player selector: #inspect;
		
		popUpInWorld: self currentWorld
]

{ #category : #running }
ScriptInstantiation >> pausedOrTicking [
	"Answer true if the receiver is either in paused or ticking status, false otherwise"

	^ #(paused ticking) includes: status
]

{ #category : #'player & selector access' }
ScriptInstantiation >> player [
	"answer the receiver's player"
	^ player
]

{ #category : #'player & selector access' }
ScriptInstantiation >> player: p [
	"Needed for making duplicate players, otherwise private"
	player := p
]

{ #category : #'player & selector access' }
ScriptInstantiation >> player: p selector: s status: st [
	frequency := 0.
	status := st.
	player := p.
	selector := s
]

{ #category : #misc }
ScriptInstantiation >> playersExternalName [
	"Answer the external name of my player"

	^ player externalName
]

{ #category : #misc }
ScriptInstantiation >> prepareToBeRunning [
	lastTick := nil.
]

{ #category : #'customevents-status control' }
ScriptInstantiation >> presentScriptStatusPopUp [
	"Put up a menu of status alternatives and carry out the request"

	| reply  m menu submenu |

	menu := MenuMorph new.
	self addStatusChoices: #( normal " -- run when called" ) toMenu: menu.
	self addStatusChoices: 
		#(	paused 		"ready to run all the time"
			ticking			"run all the time" )
		toMenu: menu.
	self addStatusChoices: (ScriptingSystem standardEventStati copyFrom: 1 to: 3) toMenu: menu.
	self addStatusChoices: (ScriptingSystem standardEventStati allButFirst: 3) toMenu: menu.
	self addStatusChoices: 
		#(opening			"when I am being opened"
			closing			"when I am being closed" )
		toMenu: menu.
	
	submenu := MenuMorph new.
	self addStatusChoices: (ScriptingSystem globalCustomEventNamesFor: player) toSubMenu: submenu forMenu: menu.
	menu add: 'more... ' translated subMenu: submenu.

	(Preferences valueOfFlag: #allowEtoyUserCustomEvents) ifTrue: [
		submenu addLine.
		self addStatusChoices: ScriptingSystem userCustomEventNames toSubMenu: submenu forMenu: menu.
		submenu addLine.
		self addStatusChoices:
			(Array streamContents: [ :s | s nextPut: { 'define a new custom event'. #defineNewEvent }.
			ScriptingSystem userCustomEventNames isEmpty
				ifFalse: [ s nextPut: { 'delete a custom event'. #deleteCustomEvent } ]])
			toSubMenu: submenu forMenu: menu ].
	
	menu addLine.

	self addStatusChoices: #(
		('what do these mean?'explainStatusAlternatives)
		('apply my status to all siblings' assignStatusToAllSiblings) ) toMenu: menu.

	menu addTitle: 'When should this script run?' translated.
	menu submorphs last delete.
	menu invokeModal.
	
	reply := menu modalSelection.

	reply == #explainStatusAlternatives ifTrue: [^ self explainStatusAlternatives].
	reply == #assignStatusToAllSiblings ifTrue: [^ self assignStatusToAllSiblings].
	reply == #defineNewEvent ifTrue: [ ^self defineNewEvent ].
	reply == #deleteCustomEvent ifTrue: [ ^self deleteCustomEvent ].

	reply ifNotNil: 
		[self status: reply.  "Gets event handlers fixed up"
		reply == #paused ifTrue:
			[m := player costume.
			(m isKindOf: SpeakerMorph) ifTrue: [m stopSound]].
		self updateAllStatusMorphs]

]

{ #category : #'status control' }
ScriptInstantiation >> presentTickingMenu [
	"Put up a menu of status alternatives and carry out the request"
	| aMenu ticks item any |
	ticks := self tickingRate.
	ticks = ticks asInteger ifTrue:[ticks := ticks asInteger].
	aMenu := MenuMorph new defaultTarget: self.
	any := false.
	#(1 2 5 8 10 25 50 100) do:[:i | 
		item := aMenu addUpdating: nil target: self selector: #tickingRate: argumentList: {i}.
		item contents:
			((ticks = i) ifTrue:[ any := true. '<on>', i printString]
					ifFalse:['<off>', i printString])].
	item := aMenu addUpdating: nil target: self selector: #typeInTickingRate argumentList: #().
	item contents: (any ifTrue:['<off>'] ifFalse:['<on>']), 'other...' translated.
	aMenu addTitle: ('Ticks (now: {1}/sec)' translated format:{ticks}).
	aMenu  popUpEvent: self currentEvent in: self currentWorld
]

{ #category : #printing }
ScriptInstantiation >> printOn: aStream [
	"Print the receiver on aStream"

	super printOn: aStream.
	aStream nextPut: Character space;
		nextPutAll: self identityHashPrintString;
		nextPutAll: ' for #', selector asString
]

{ #category : #'customevents-status control' }
ScriptInstantiation >> removeEventTriggersForMorph: actualMorph [ 
	"user custom events are triggered at the World, while system custom events are triggered on individual Morphs."

	actualMorph removeActionsSatisfying: 
			[:action | 
			action receiver == player and: 
					[(#(#doScript: #triggerScript:) includes: action selector) 
						and: [action arguments first == selector]]]
		forEvent: status.
	self currentWorld removeActionsSatisfying: 
			[:action | 
			action receiver == player and: 
					[(#(#doScript: #triggerScript:) includes: action selector) 
						and: [action arguments first == selector]]]
		forEvent: status
]

{ #category : #'status control' }
ScriptInstantiation >> resetToNormalIfCurrently: aStatus [
	"If my status *had been* aStatus, quietly reset it to normal, without tampering with event handlers.  But get the physical display of all affected status morphs right"

	status == aStatus ifTrue:
		[status := #normal.
		self updateAllStatusMorphs]
]

{ #category : #running }
ScriptInstantiation >> runIfClosing [
	| result |
	(result := status == #closing) ifTrue:
		[player triggerScript: selector].
	^ result
]

{ #category : #running }
ScriptInstantiation >> runIfOpening [
	| result |
	(result := status == #opening) ifTrue:
		[player triggerScript: selector].
	^ result
]

{ #category : #running }
ScriptInstantiation >> runIfTicking: nowTick [ 
	"If the receiver is meant to be ticking, run it if it's time"

	| ticks rate |
	status == #ticking ifFalse: [^self].
	rate := self tickingRate.
	ticks := (lastTick isNil or: [nowTick < lastTick]) 
				ifTrue: 
					[lastTick := nowTick.
					1]
				ifFalse: [((nowTick - lastTick) * rate * 0.001) asInteger].
	ticks <= 0 ifTrue: [^self].

	"Scripts which have been out of the world and then return can have a huge number of ticks accumulated. A better fix would be to reset <lastTick> when a script leaves/enters the world. Also, if the system is falling behind, this attempt to catch up can result in falling further behind, leading to sluggish behavior and termination of ticking status. Whether the user really wants this catch up behavior needs to be determined (often she will not, I suspect) and better ways of doing it need to be found.  (This comment inserted by Bob Arning on 3/5/2001)"
	ticks := 1.
	1 to: ticks * self frequency do: [:i | player triggerScript: selector].
	lastTick := nowTick.
	ticks > 10 
		ifTrue: 
			["check if we're lagging behind"

			ticks <= ((Time millisecondClockValue - lastTick) * rate / 1000) asInteger 
				ifTrue: 
					["e.g., time to run script is higher than number of ticks"

					self status: #paused.
					self updateAllStatusMorphs]]
]

{ #category : #'player & selector access' }
ScriptInstantiation >> selector [
	^ selector
]

{ #category : #'player & selector access' }
ScriptInstantiation >> selector: sel [
	selector := sel
]

{ #category : #running }
ScriptInstantiation >> startRunningIfPaused [
	"If the receiver is paused, start it ticking"

	status == #paused ifTrue:
		[self status: #ticking.
		self updateAllStatusMorphs]
]

{ #category : #'status control' }
ScriptInstantiation >> status [
	status ifNil: [status := #normal].
	^ status
]

{ #category : #'customevents-status control' }
ScriptInstantiation >> status: newStatus [ 
	"Set the receiver's status as indicated"

	| stati actualMorph |
	actualMorph := player costume renderedMorph.

	"standard (EventHandler) events"
	stati := ScriptingSystem standardEventStati.
	(stati includes: status) 
		ifTrue: 
			[actualMorph 
				on: status
				send: nil
				to: nil
			"remove old link in event handler"].
	(stati includes: newStatus) 
		ifTrue: 
			[actualMorph 
				on: newStatus
				send: selector
				to: player.
			"establish new link in evt handler"
			player assureNoScriptOtherThan: self hasStatus: newStatus].

	"user custom events are triggered at the World, while system custom events are triggered on individual Morphs."
	self removeEventTriggersForMorph: actualMorph.
	stati := ScriptingSystem customEventStati.
	(stati includes: newStatus) 
		ifTrue: 
			[(ScriptingSystem userCustomEventNames includes: newStatus) 
				ifTrue: 
					[self currentWorld 
						when: newStatus
						send: #triggerScript:
						to: player
						withArguments: { 
								selector}]
				ifFalse: 
					[actualMorph when: newStatus
						evaluate: (MessageSend 
								receiver: player
								selector: #triggerScript:
								arguments: { 
										selector})]].
	status := newStatus.
	self pausedOrTicking ifTrue: [lastTick := nil].
	self flag: #arNote.	"this from fall 2000"
	self flag: #workaround.	"Code below was in #chooseTriggerFrom: which did not reflect status changes from other places (e.g., the stepping/pause buttons). It is not clear why this is necessary though - theoretically, any morph should step when it has a player but alas! something is broken and I have no idea why and where."

	"14 feb 2001 - bob - I reinstated this after alan noticed that a newly drawn car would not go until you picked it up and dropped it. The reason is that unscripted players have #wantSteps ^false. If a morph enters the world with an unscripted player and then acquires a scripted player, that would be a good time to change, but this will work too"
	status == #ticking 
		ifTrue: 
			[player costume isStepping ifFalse: [player costume arrangeToStartStepping]]
]

{ #category : #'status control' }
ScriptInstantiation >> statusControlMorph [
	"Answer a control that will serve to reflect (and allow the user to change) the status of the receiver"

	^ ScriptStatusControl new initializeFor: self

]

{ #category : #misc }
ScriptInstantiation >> statusControlRowIn: aStatusViewer [
	"Answer an object that reports my status and lets the user change it"

	| aRow aMorph buttonWithPlayerName |
	aRow := ScriptStatusLine newRow beTransparent.
	buttonWithPlayerName := UpdatingSimpleButtonMorph new.
	buttonWithPlayerName font: Preferences standardEToysButtonFont.
	buttonWithPlayerName
		on: #mouseEnter send: #menuButtonMouseEnter: to: buttonWithPlayerName;
		 on: #mouseLeave send: #menuButtonMouseLeave: to: buttonWithPlayerName.

	buttonWithPlayerName target: self; wordingSelector: #playersExternalName; actionSelector: #offerMenuIn:; arguments: {aStatusViewer}; beTransparent; actWhen: #buttonDown.
	buttonWithPlayerName setBalloonText: 'This is the name of the player to which this script belongs; if you click here, you will get a menu of interesting options pertaining to this player and script' translated.
	buttonWithPlayerName borderWidth: 1; borderColor: Color blue.
	aRow addMorphBack: buttonWithPlayerName.
	aRow addTransparentSpacerOfSize: 10@0.
	aRow addMorphBack: AlignmentMorph newVariableTransparentSpacer.

	aMorph := UpdatingStringMorph on: self selector: #selector.
	aMorph font: Preferences standardEToysButtonFont.
	aMorph color: Color brown lighter; useStringFormat.
	aMorph setBalloonText: 'This is the name of the script to which this entry pertains.' translated.
	aRow addMorphBack: aMorph.
	aRow addMorphBack: AlignmentMorph newVariableTransparentSpacer.
	aRow addTransparentSpacerOfSize: 10@0.

	aRow addMorphBack: self statusControlMorph.
	aRow submorphsDo: [:m | m wantsSteps ifTrue: [m step]].
	^ aRow
]

{ #category : #running }
ScriptInstantiation >> stopTicking [
	"If I'm ticking stop, else do nothing"

	status == #ticking ifTrue:
		[self status: #paused.
		self updateAllStatusMorphs]
]

{ #category : #frequency }
ScriptInstantiation >> tickingRate [
	"Return the number of ticks per second this script should get"
	^tickingRate ifNil:[8]
]

{ #category : #frequency }
ScriptInstantiation >> tickingRate: aNumber [
	"See the comment in #tickingRate"
	tickingRate := aNumber.
	self updateAllStatusMorphs.
]

{ #category : #'status control' }
ScriptInstantiation >> translatedStatus [
	^ self status translated
]

{ #category : #'status control' }
ScriptInstantiation >> typeInTickingRate [
	| reply aNumber |
	reply := FillInTheBlank request: 'Number of ticks per second: ' translated initialAnswer: self tickingRate printString.

	reply ifNotNil:
		[aNumber := reply asNumber.
		aNumber > 0 ifTrue:
			[self tickingRate: aNumber]]
]

{ #category : #'status control' }
ScriptInstantiation >> updateAllStatusMorphs [
	"Update all status morphs bound to the receiver.  Done with a sledge-hammer at present."

	| w |
	w := self currentWorld.
	(w hasProperty: self) ifTrue: [^ self].
	w setProperty: self toValue: #updating.
	Project current addDeferredUIMessage: [
		(w allMorphs select: [:m | (m isKindOf: ScriptStatusControl) and:
			[m scriptInstantiation == self]]) do:
			[:aStatusControl | self updateStatusMorph: aStatusControl].
		w removeProperty: self.
	]


]

{ #category : #'status control' }
ScriptInstantiation >> updateStatusMorph: statusControlMorph [
	"the status control may need to reflect an externally-induced change in status"

	| colorSelector statusReadoutButton |
	statusControlMorph ifNil: [^ self].

	self pausedOrTicking
		ifTrue:
			[statusControlMorph assurePauseTickControlsShow]
		ifFalse:
			[statusControlMorph maybeRemovePauseTickControls].
	statusReadoutButton := statusControlMorph submorphs last.
	colorSelector := ScriptingSystem statusColorSymbolFor: self status.
	statusReadoutButton color: (Color perform: colorSelector) muchLighter.
	statusReadoutButton label: self translatedStatus asString font: ScriptingSystem fontForEToyButtons
]

{ #category : #misc }
ScriptInstantiation >> userScriptObject [
	"Answer the UserScript object in the receiver's class that holds on to the editing state for this script"

	^ player class userScriptForPlayer: player selector: selector
]
