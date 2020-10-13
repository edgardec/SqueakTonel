"
SystemWindow is the Morphic equivalent of StandardSystemView -- a labelled container for rectangular views, with iconic facilities for close, collapse/expand, and resizing.

The attribute onlyActiveOnTop, if set to true (and any call to activate will set this), determines that only the top member of a collection of such windows on the screen shall be active.  To be not active means that a mouse click in any region will only result in bringing the window to the top and then making it active.
"
Class {
	#name : #SystemWindow,
	#superclass : #MorphicModel,
	#instVars : [
		'labelString',
		'stripes',
		'label',
		'closeBox',
		'collapseBox',
		'paneMorphs',
		'paneRects',
		'collapsedFrame',
		'fullFrame',
		'isCollapsed',
		'isActive',
		'isLookingFocused',
		'menuBox',
		'mustNotClose',
		'labelWidgetAllowance',
		'updatablePanes',
		'allowReframeHandles',
		'labelArea',
		'expandBox'
	],
	#classVars : [
		'ClickOnLabelToEdit',
		'CloseBoxFrame',
		'CloseBoxImageFlat',
		'CloseBoxImageGradient',
		'CollapseBoxImageFlat',
		'CollapseBoxImageGradient',
		'DoubleClickOnLabelToExpand',
		'DragToEdges',
		'ExpandBoxFrame',
		'ExpandBoxImageFlat',
		'ExpandBoxImageGradient',
		'FocusFollowsMouse',
		'GradientWindow',
		'HideExpandButton',
		'MenuBoxFrame',
		'MenuBoxImageFlat',
		'MenuBoxImageGradient',
		'ResizeAlongEdges',
		'ReuseWindows',
		'RoundedWindowCorners',
		'TopWindow',
		'WindowTitleActiveOnFirstClick',
		'WindowsRaiseOnClick'
	],
	#category : #'Morphic-Windows'
}

{ #category : #initializing }
SystemWindow class >> borderWidth [

	^ AbstractResizerMorph gripThickness
]

{ #category : #preferences }
SystemWindow class >> boxExtent [
	"answer the extent to use in all the buttons"
	
	^ (Preferences alternativeWindowBoxesLook
		ifTrue: [18 @ 18]
		ifFalse: [16 @ 16])
]

{ #category : #'top window' }
SystemWindow class >> bringWindowUnderHandToFront [
"This only works when All Windows Active is enabled."
	(self windowsIn: Project current world) do: [ : each | each isLookingFocused ifTrue: [ ^ each beKeyWindow ]]
]

{ #category : #initializing }
SystemWindow class >> classVersion [
	"Changed to 1 for SystemWindow Dec 2000 - see if this helps loading old ones"
	^ 1
]

{ #category : #'top window' }
SystemWindow class >> clearTopWindow [

	TopWindow := nil.	"if leaving morphic to export from mvc, this ref could cause problems"
]

{ #category : #preferences }
SystemWindow class >> clickOnLabelToEdit [

	<preference: 'Click On Label To Edit'
		category: 'windows'
		description: 'If true, a click on the label of a system window lets you edit it'
		type: #Boolean>
	^ ClickOnLabelToEdit ifNil: [false].

]

{ #category : #preferences }
SystemWindow class >> clickOnLabelToEdit: aBoolean [

	ClickOnLabelToEdit := aBoolean.
	self refreshAllWindows.
]

{ #category : #preferences }
SystemWindow class >> closeBoxFrame [

	^ CloseBoxFrame ifNil: [
		CloseBoxFrame := (LayoutFrame new
								leftFraction: 0;
								leftOffset: 2;
								topFraction: 0;
								topOffset: 0;
								yourself)]
]

{ #category : #initializing }
SystemWindow class >> closeBoxImage [

	^ self gradientWindow
		ifTrue: [self closeBoxImageGradient]
		ifFalse: [self closeBoxImageFlat].

]

{ #category : #initializing }
SystemWindow class >> closeBoxImageFlat [

	^ CloseBoxImageFlat ifNil: [CloseBoxImageFlat :=  (Form
	extent: 12@12
	depth: 32
	fromArray: #( 0 0 552294233 2683000665 4025177945 4293613401 4293613401 4025177945 2683000665 552294233 0 0 0 1089165145 4025177945 4293613401 4293613401 4293613401 4293613401 4293613401 4293613401 4025177945 820729689 0 552294233 4025177945 4293613401 4293613401 4293613401 4293613401 4293613401 4293613401 4293613401 4293613401 4025177945 283858777 2683000665 4293613401 4293613401 4294492353 4294492353 4293613401 4293613401 4294492353 4294492353 4293613401 4293613401 2683000665 4025177945 4293613401 4293613401 4294492353 4294967295 4294492353 4294492353 4294967295 4294492353 4293613401 4293613401 4025177945 4293613401 4293613401 4293613401 4293613401 4294492353 4294967295 4294967295 4294492353 4293613401 4293613401 4293613401 4293613401 4293613401 4293613401 4293613401 4293613401 4294492353 4294967295 4294967295 4294492353 4293613401 4293613401 4293613401 4293613401 4025177945 4293613401 4293613401 4294492353 4294967295 4294492353 4294492353 4294967295 4294492353 4293613401 4293613401 3756742489 2683000665 4293613401 4293613401 4294492353 4294492353 4293613401 4293613401 4294492353 4294492353 4293613401 4293613401 2162906969 552294233 4025177945 4293613401 4293613401 4293613401 4293613401 4293613401 4293613401 4293613401 4293613401 4025177945 283858777 0 820729689 4025177945 4293613401 4293613401 4293613401 4293613401 4293613401 4293613401 4025177945 820729689 0 0 0 283858777 2683000665 4025177945 4293613401 4293613401 3756742489 2162906969 283858777 0 0)
	offset: 0@0)]
]

{ #category : #initializing }
SystemWindow class >> closeBoxImageGradient [

	^ CloseBoxImageGradient ifNil: [CloseBoxImageGradient := (Form
	extent: 14@14
	depth: 32
	fromArray: #(0 0 6032910 288687365 1550655006 2844865845 3450028610 3450028610 2828088372 1550655006 288687365 5967374 0 0 1377027 15091784 844830230 3063889984 4158092147 4294153621 4294681250 4294681250 4294153364 4158091376 3047046718 844764694 14763847 1376770 7742243 861541910 3585164870 4294282123 4294943908 4294943908 4294943651 4294943651 4294943908 4294943908 4294216330 3585099848 844764694 7676450 288098055 3047109684 4294211447 4294939539 4293757578 4293363848 4294939025 4294939282 4293954186 4293560456 4294939539 4294212732 3047110455 288031748 1584209695 4158081610 4294932343 4293753466 4291733929 4291802549 4293164156 4293884281 4291666594 4291670192 4293294457 4294933885 4158018130 1567432222 2861706541 4294136145 4294924376 4292761945 4292198592 4294704894 4292064950 4291403679 4294375158 4293057499 4291846497 4294925147 4294136659 2844863789 3483644980 4294660947 4294923605 4294857555 4292566879 4292658886 4294770173 4294704380 4293452000 4291981681 4294595154 4294923605 4294660947 3466867764 3500422196 4294726483 4294923605 4294923605 4293742415 4291402908 4294836223 4294967295 4292198592 4292760660 4294923348 4294923605 4294660947 3483644980 2878484014 4294136145 4294923605 4293939794 4291728018 4294375158 4293452257 4292793042 4294704637 4292128944 4293154390 4294923605 4294136145 2878484014 1617830177 4174923591 4294923862 4292957011 4292000442 4293386721 4291915888 4292238685 4292659400 4292595406 4292303450 4294923605 4158146375 1617829920 305072650 3097572147 4294267217 4294923348 4292631901 4291781989 4294595154 4294857555 4292435036 4292238942 4294857812 4294267217 3097506611 305007114 8070437 912005658 3635624249 4294333010 4294923605 4294857555 4294923605 4294923605 4294923348 4294923348 4294333010 3635624249 895228442 8004901 1639428 16735838 912071451 3131126579 4191766343 4294267217 4294726740 4294726740 4294201681 4191766343 3131126579 895293978 16735067 1573892 0 0 6888733 322506254 1651515681 2945723950 3550885173 3550885173 2945723950 1651515681 322440718 6822940 0 0)
	offset: 0@0)]
]

{ #category : #'top window' }
SystemWindow class >> closeTopWindow [
	"Try to close the top window.  It may of course decline"

	TopWindow ifNotNil:
		[TopWindow delete]
]

{ #category : #initializing }
SystemWindow class >> collapseBoxImage [

	^ self gradientWindow
		ifTrue: [self collapseBoxImageGradient]
		ifFalse: [self collapseBoxImageFlat].

]

{ #category : #initializing }
SystemWindow class >> collapseBoxImageFlat [

	^ CollapseBoxImageFlat ifNil: [CollapseBoxImageFlat :=  (Form
	extent: 12@12
	depth: 32
	fromArray: #( 0 0 552699410 2683405842 4025583122 4294018578 4294018578 4025583122 2683405842 552699410 0 0 0 1089570322 4025583122 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4025583122 821134866 0 552699410 4025583122 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4025583122 284263954 2683405842 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 2683405842 4025583122 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4025583122 4294018578 4294221118 4294762948 4294762948 4294762948 4294762948 4294762948 4294762948 4294762948 4294762948 4294221118 4294018578 4294018578 4294221118 4294762948 4294762948 4294762948 4294762948 4294762948 4294762948 4294762948 4294762948 4294221118 4294018578 4025583122 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 3757147666 2683405842 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 2163312146 552699410 4025583122 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4025583122 284263954 0 821134866 4025583122 4294018578 4294018578 4294018578 4294018578 4294018578 4294018578 4025583122 821134866 0 0 0 284263954 2683405842 4025583122 4294018578 4294018578 3757147666 2163312146 284263954 0 0)
	offset: 0@0)]
]

{ #category : #initializing }
SystemWindow class >> collapseBoxImageGradient [

	^ CollapseBoxImageGradient ifNil: [CollapseBoxImageGradient := (Form
	extent: 14@14
	depth: 32
	fromArray: #(0 768 5853184 288569344 1550537988 2844748052 3449976096 3449976096 2827970835 1550537731 288569600 5787392 768 0 1256960 15043082 844713216 3063837470 4158037328 4294162549 4294689156 4294689156 4294162292 4158036813 3046994460 844713216 14714890 1256704 7690756 861424896 3585112609 4294226279 4294952069 4294952069 4294951812 4294951812 4294952069 4294952068 4294226278 3585047331 844647680 7625220 287914752 3047058190 4294222924 4294949230 4294948716 4294948716 4294948716 4294948716 4294948716 4294948717 4294949231 4294223955 3047058707 287914240 1584092675 4158030361 4294944327 4294945619 4294945877 4294946134 4294946134 4294945877 4294945619 4294945102 4294944587 4294945360 4158031652 1567315202 2861589770 4294150937 4294938911 4294217252 4293955628 4294021937 4294021938 4294021421 4294020390 4293954079 4294084893 4294873892 4294151196 2844812298 3483593741 4294741530 4294478360 4291271017 4292461743 4292461485 4292461485 4292461485 4292461485 4292527535 4291340680 4293625630 4294807066 3466816525 3500370957 4294741530 4294347032 4291669904 4294112759 4294112244 4294112244 4294112244 4294112244 4294243831 4292200893 4293428769 4294807066 3483593741 2878432779 4294150937 4294806810 4292511536 4292382532 4292382531 4292382531 4292382531 4292382531 4292382532 4292249912 4294347548 4294216473 2878432523 1617712902 4174872597 4294938651 4294938393 4294938136 4294938136 4294938136 4294938136 4294938136 4294938136 4294938393 4294938651 4158095381 1617712902 304955136 3097520909 4294282265 4294938395 4294938395 4294938395 4294938395 4294938395 4294938395 4294938395 4294938395 4294282009 3097455373 304889600 7953671 911888388 3635573264 4294347801 4294938651 4294938395 4294938395 4294938395 4294938395 4294938651 4294347801 3635573264 895111172 7888135 1520128 16753431 911954180 3131075341 4191781141 4294216473 4294741530 4294741530 4294216473 4191781141 3131075341 895176964 16752406 1454592 0 3072 6708483 322388481 1651398919 2945607436 3550833934 3550833934 2945607436 1651398919 322322945 6642947 2816 0)
	offset: 0@0)]
]

{ #category : #'top window' }
SystemWindow class >> deleteTopWindow [
	TopWindow ifNotNil: [ TopWindow delete ]
]

{ #category : #preferences }
SystemWindow class >> doubleClickOnLabelToExpand [

	<preference: 'Double-Click On Label To Expand'
		category: 'windows'
		description: 'Activates expansion through double-clicking on the window label area. This mimics the behavior in many current operating systems'
		type: #Boolean>
	^ DoubleClickOnLabelToExpand ifNil: [true].

]

{ #category : #preferences }
SystemWindow class >> doubleClickOnLabelToExpand: aBoolean [

	DoubleClickOnLabelToExpand := aBoolean.
	self refreshAllWindows.

]

{ #category : #preferences }
SystemWindow class >> dragToEdges [
	<preference: 'Drag To Edges'
		category: 'windows'
		description: 'When true, windows snap and resize to corners and edges of the Display.'
		type: #Boolean>
	^DragToEdges ifNil: [false]
]

{ #category : #preferences }
SystemWindow class >> dragToEdges: aBoolean [
	DragToEdges := aBoolean
]

{ #category : #preferences }
SystemWindow class >> expandBoxFrame [

	^ ExpandBoxFrame ifNil: [
		ExpandBoxFrame := (LayoutFrame new
								leftFraction: 1;
								leftOffset: (self boxExtent x * 2 + 3) negated;
								topFraction: 0;
								topOffset: 0;
								yourself)]
]

{ #category : #initializing }
SystemWindow class >> expandBoxImage [

	^ self gradientWindow
		ifTrue: [self expandBoxImageGradient]
		ifFalse: [self expandBoxImageFlat].

]

{ #category : #initializing }
SystemWindow class >> expandBoxImageFlat [

	^ ExpandBoxImageFlat ifNil: [ExpandBoxImageFlat :=  (Form
	extent: 12@12
	depth: 32
	fromArray: #( 0 0 542547506 2673253938 4015431218 4283866674 4283866674 4015431218 2673253938 542547506 0 0 0 1079418418 4015431218 4283866674 4283866674 4285968472 4285968472 4283866674 4283866674 4015431218 810982962 0 542547506 4015431218 4283866674 4283866674 4283866674 4292208588 4292208588 4283866674 4283866674 4283866674 4015431218 274112050 2673253938 4283866674 4283866674 4283866674 4283866674 4292208588 4292208588 4283866674 4283866674 4283866674 4283866674 2673253938 4015431218 4283866674 4283866674 4283866674 4283866674 4292208588 4292208588 4283866674 4283866674 4283866674 4283866674 4015431218 4283866674 4285968472 4292208588 4292208588 4292208588 4294244850 4294244850 4292208588 4292208588 4292208588 4285968472 4283866674 4283866674 4285968472 4292208588 4292208588 4292208588 4294244850 4294244850 4292208588 4292208588 4292208588 4285968472 4283866674 4015431218 4283866674 4283866674 4283866674 4283866674 4292208588 4292208588 4283866674 4283866674 4283866674 4283866674 3746995762 2673253938 4283866674 4283866674 4283866674 4283866674 4292208588 4292208588 4283866674 4283866674 4283866674 4283866674 2153160242 542547506 4015431218 4283866674 4283866674 4283866674 4292208588 4292208588 4283866674 4283866674 4283866674 4015431218 274112050 0 810982962 4015431218 4283866674 4283866674 4285968472 4285968472 4283866674 4283866674 4015431218 810982962 0 0 0 274112050 2673253938 4015431218 4283866674 4283866674 3746995762 2153160242 274112050 0 0)
	offset: 0@0)]
]

{ #category : #initializing }
SystemWindow class >> expandBoxImageGradient [

	^ ExpandBoxImageGradient ifNil: [ExpandBoxImageGradient := (Form
	extent: 14@14
	depth: 32
	fromArray: #(0 0 1058562 285544960 1545616142 2838976800 3443812652 3443812652 2822199328 1545550349 285610496 1058562 0 0 197889 5015843 840445449 3057804586 4151680347 4288134782 4288989580 4288989580 4288134525 4151549016 3040961576 840379656 4949796 132352 2441745 857222409 3578360366 4287543665 4289187213 4289121422 4288857993 4288792456 4289121421 4289121677 4287478128 3578491696 840445193 2375953 285740802 3040304923 4286295641 4288070777 4288004983 4287543410 4288524177 4289312671 4287344755 4288004983 4288136313 4286624095 3040502048 285543680 1579236111 4149118761 4286297173 4286822495 4286888545 4286426462 4291679432 4293717227 4286752873 4286560090 4286428504 4286691421 4149578546 1562393102 2855294231 4283865130 4284326448 4284325172 4284718907 4284716865 4291416516 4293651691 4285043786 4284061998 4283996461 4284523316 4283996461 2838517015 3476513307 4284063275 4283865386 4287341947 4290759608 4290693559 4293717483 4294572537 4291153599 4290759607 4288129929 4283864876 4283997739 3459736090 3493290523 4284063275 4283799593 4289312927 4294243316 4294046193 4294769916 4294901502 4294177779 4294243316 4290364338 4283864621 4284063275 3476513306 2872071703 4283865130 4284063275 4284453693 4285176395 4285109069 4291811019 4293849070 4285962336 4285110602 4284585024 4283997227 4283799593 2872071447 1612856592 4165698852 4284195372 4284063786 4284064041 4283864620 4291285440 4293651690 4284782402 4283998248 4284063786 4284195372 4148921636 1612856336 302649860 3090571034 4283865642 4284129580 4284129580 4283930157 4289378465 4291218626 4284519486 4284064042 4284129580 4283865642 3090505498 302649604 2573587 907751437 3627904029 4283865642 4284195372 4284063275 4284060978 4284126260 4283996972 4284195372 4283865642 3627838237 890974221 2573330 263937 6533168 907817229 3124125722 4182476324 4283865386 4284063531 4284063531 4283865386 4182476324 3124125722 891040013 6335279 263937 0 0 1979406 319691015 1646476817 2939246103 3543687963 3543687963 2939246103 1646476817 319691015 1979406 0 0)
	offset: 0@0) ]
]

{ #category : #preferences }
SystemWindow class >> gradientWindow [

	<preference: 'gradientWindow'
		category: 'windows'
		description: 'If true, windows will have a gradient look.'
		type: #Boolean>
	^ GradientWindow ifNil: [true]

]

{ #category : #preferences }
SystemWindow class >> gradientWindow: aBoolean [

	aBoolean = GradientWindow ifTrue: [^ self].
	GradientWindow := aBoolean.
	self refreshAllWindows.
]

{ #category : #preferences }
SystemWindow class >> hideExpandButton [

	<preference: 'Hide Expand Button'
		category: 'windows'
		description: 'Hides the expand ( + ) button in all window titlebars'
		type: #Boolean>
	^ HideExpandButton ifNil: [ false ]

]

{ #category : #preferences }
SystemWindow class >> hideExpandButton: aBoolean [

	HideExpandButton := aBoolean.
	"Have the menu button frame rebuilt accordingly"
	self moveMenuButtonRight: self moveMenuButtonRight.

]

{ #category : #'new-morph participation' }
SystemWindow class >> includeInNewMorphMenu [
	"Include my subclasses but not me"
	^ self ~~ SystemWindow
]

{ #category : #'top window' }
SystemWindow class >> keyWindow [
	"Multiple windows may appear to be on top, especially on large screens. Only one window, however, can be the key window, which gets the programmers primary attention."
	
	^ TopWindow
]

{ #category : #'instance creation' }
SystemWindow class >> labelled: labelString [

	^ self basicNew
		initializeWithLabel: labelString;
		yourself
]

{ #category : #preferences }
SystemWindow class >> menuBoxFrame [

	^ MenuBoxFrame ifNil: [
		MenuBoxFrame := (LayoutFrame new
								leftFraction: 0;
								leftOffset: self boxExtent x + 3;
								topFraction: 0;
								topOffset: 0;
								yourself)]
]

{ #category : #initializing }
SystemWindow class >> menuBoxImage [

	^ self gradientWindow
		ifTrue: [self menuBoxImageGradient]
		ifFalse: [self menuBoxImageFlat].

]

{ #category : #initializing }
SystemWindow class >> menuBoxImageFlat [

	^ MenuBoxImageFlat ifNil: [MenuBoxImageFlat :=  (Form
	extent: 12@12
	depth: 32
	fromArray: #( 0 0 540831669 2671538101 4013715381 4282150837 4282150837 4013715381 2671538101 540831669 0 0 0 1077702581 4013715381 4282150837 4282150837 4282150837 4282150837 4282150837 4282150837 4013715381 809267125 0 540831669 4013715381 4282150837 4282150837 4282150837 4282150837 4282150837 4282150837 4282150837 4282150837 4013715381 272396213 2671538101 4282150837 4282150837 4282150837 4282150837 4282150837 4282150837 4282150837 4282150837 4282150837 4282150837 2671538101 4013715381 4282150837 4284582595 4288591834 4288591834 4288591834 4288591834 4288591834 4288591834 4283728318 4282150837 4013715381 4282150837 4282150837 4282939578 4292535537 4294967295 4294967295 4294967295 4294967295 4292535537 4282150837 4282150837 4282150837 4282150837 4282150837 4282150837 4284582595 4294967295 4294967295 4294967295 4294178554 4283728318 4282150837 4282150837 4282150837 4013715381 4282150837 4282150837 4282150837 4287737557 4294967295 4294967295 4286948817 4282150837 4282150837 4282150837 3745279925 2671538101 4282150837 4282150837 4282150837 4282150837 4291746797 4290958056 4282150837 4282150837 4282150837 4282150837 2151444405 540831669 4013715381 4282150837 4282150837 4282150837 4282939578 4282939578 4282150837 4282150837 4282150837 4013715381 272396213 0 809267125 4013715381 4282150837 4282150837 4282150837 4282150837 4282150837 4282150837 4013715381 809267125 0 0 0 272396213 2671538101 4013715381 4282150837 4282150837 3745279925 2151444405 272396213 0 0)
	offset: 0@0)]
]

{ #category : #initializing }
SystemWindow class >> menuBoxImageGradient [

	^ MenuBoxImageGradient ifNil: [MenuBoxImageGradient := (Form
	extent: 14@14
	depth: 32
	fromArray: #(0 0 7774 285216318 1544039783 2837267842 3442168720 3442168720 2820490625 1544039782 285216574 7774 0 0 2087 1532860 839001178 3056161165 4150166716 4286817494 4287738079 4287803615 4286751958 4150035131 3039252364 839001178 1467065 1831 668526 855712858 3576584601 4286029012 4287935459 4287935458 4287869666 4287869666 4287935458 4287869923 4285963476 3576715929 838935642 602733 285216827 3038463881 4284517582 4286621149 4286489564 4286489564 4286489564 4286489564 4286489564 4286489820 4286621149 4284911823 3038726794 285216058 1577594471 4147012271 4284387029 4284978391 4285043927 4285109719 4285109719 4285044183 4284978135 4284649685 4284518357 4284912599 4147603633 1560751463 2853453696 4281560257 4281888189 4283200687 4284186808 4284515256 4284515257 4284252600 4283858102 4283529653 4282740653 4282151359 4281757378 2836676480 3474606220 4281757894 4281559740 4285761703 4292993507 4293454315 4293388522 4293388522 4293454315 4292862177 4285432998 4281494205 4281692102 3457829004 3491383436 4281757638 4281758153 4281953722 4288589251 4294835708 4294967295 4294967295 4294769659 4288194752 4281887931 4281823689 4281692102 3474606220 2870296704 4281560257 4281823689 4281758153 4282215861 4289838026 4294967294 4294967038 4289377991 4282084534 4281758153 4281823689 4281560257 2870296704 1611280232 4163592111 4281823946 4281823688 4281692360 4282740914 4291152852 4290758353 4282544051 4281692361 4281823688 4281823946 4146749358 1611214696 301994814 3088664202 4281626050 4281823689 4281823688 4281692103 4282937773 4282806447 4281692360 4281823688 4281823689 4281626050 3088664202 301994814 734577 906307420 3625930390 4281626050 4281823946 4281823689 4281692360 4281692360 4281823689 4281823946 4281626050 3625930390 889530204 734576 2347 2392036 906373213 3122218634 4180369583 4281560257 4281757638 4281757638 4281560257 4180369583 3122218634 889595997 2325471 2346 0 3 76907 318773060 1644834921 2937405569 3541780621 3541780621 2937405569 1644834921 318773059 76906 2 0)
	offset: 0@0)]
]

{ #category : #preferences }
SystemWindow class >> moveMenuButtonRight [

	<preference: 'Move Menu Button Right'
		category: 'windows'
		description: 'Moves the menu to the right side of the window label area, while traditionally it used to be on the left side'
		type: #Boolean>
	^ self menuBoxFrame leftOffset negative

]

{ #category : #preferences }
SystemWindow class >> moveMenuButtonRight: aBoolean [

	| absLeftOffset |
	absLeftOffset := ((self hideExpandButton and: [aBoolean])
		ifTrue: [absLeftOffset := self boxExtent x * 2]
		ifFalse: [absLeftOffset := self boxExtent x]) + 3.
	self menuBoxFrame leftOffset: (aBoolean 
										ifTrue: [absLeftOffset negated]
										ifFalse: [absLeftOffset]).
	self refreshAllWindows.
]

{ #category : #'top window' }
SystemWindow class >> noteTopWindowIn: aWorld [
	"Look for a new top window in the given world. We have to reset the former top window because this is global state shared between all worlds."

	| newTopWindow |
	TopWindow := nil.
	newTopWindow := nil.

	aWorld ifNil: [^ self].

	aWorld submorphsDo: [:m |
		(m isSystemWindow and: [newTopWindow isNil])
			ifTrue: [newTopWindow := m].
		
		self flag: #refactor. "This really belongs in a special ProjWindow class"
		(m model isKindOf: Project)
			ifTrue: [m label ~= m model name ifTrue: [m setLabel: m model name]]].

	newTopWindow ifNotNil: [newTopWindow beKeyWindow].
]

{ #category : #private }
SystemWindow class >> reconfigureWindowsForFocus [

	self allSubInstancesDo: [:window |
		window
			passivate;
			activate;
			unlockWindowDecorations;
			passivateIfNeeded].
	self topWindow ifNotNil: [:wnd | wnd activate].
]

{ #category : #initializing }
SystemWindow class >> refreshAllWindows [
	"If there is some prominent UI change, use this method to update all open windows."
	
	SystemWindow allSubInstances do: [:w |
		w
			replaceBoxes;
			setDefaultParameters;
			refreshWindowColor].
]

{ #category : #preferences }
SystemWindow class >> resizeAlongEdges [
	<preference: 'Resize Windows along edges'
		category: 'Morphic'
		description: 'When true, windows can be resized along their edges as well as the corners'
		type: #Boolean>
	^ResizeAlongEdges ifNil:[true]
]

{ #category : #preferences }
SystemWindow class >> resizeAlongEdges: aBool [
	"Preference setter"
	ResizeAlongEdges := aBool
]

{ #category : #preferences }
SystemWindow class >> reuseWindows [

	<preference: 'Reuse Windows'
		category: 'browsing'
		description: 'When enabled, before opening a new window check if there is any open window like it, and if there is, reuse it.'
		type: #Boolean>
	^ReuseWindows ifNil: [ false ]

]

{ #category : #preferences }
SystemWindow class >> reuseWindows: aBoolean [

	ReuseWindows := aBoolean
]

{ #category : #preferences }
SystemWindow class >> roundedWindowCorners [

	<preference: 'Rounded Window Corners'
		category: 'windows'
		description: 'If true, windows will have rounded corners.'
		type: #Boolean>
	^ RoundedWindowCorners ifNil: [false]
]

{ #category : #preferences }
SystemWindow class >> roundedWindowCorners: aBoolean [

	RoundedWindowCorners = aBoolean ifTrue: [^ self].
	RoundedWindowCorners := aBoolean.
	self refreshAllWindows.
]

{ #category : #'top window' }
SystemWindow class >> sendTopWindowToBack [
	"Send the top window of the world to the back, activating the one just beneath it"

	TopWindow ifNotNil:
		[TopWindow sendToBack]
]

{ #category : #preferences }
SystemWindow class >> themeProperties [

	^ super themeProperties, {	
		{ #borderColorModifier. 'Colors'. 'How to derive the borderColor from the window color.' }.
		{ #borderWidth. 'Borders'. 'Width of the menu''s border.' }.
		{ #titleFont. 'Fonts'. 'Font of the window title.' }.
		
		{ #unfocusedWindowColorModifier. 'Colors'. 'A block with one argument that modifies a color to look unfocused.' }.
		{ #unfocusedLabelColor. 'Colors'. 'Window title color when window has no focus.'}.
		{ #focusedLabelColor. 'Colors'. 'Window title color when window has focus.'}.
		
		{ #color. 'Colors'. 'Color to use if the model or the pane morphs do not provide one.' }.
	}
]

{ #category : #'top window' }
SystemWindow class >> topWindow [
	^ TopWindow
]

{ #category : #'top window' }
SystemWindow class >> wakeUpTopWindowUponStartup [
	TopWindow ifNotNil:
		[TopWindow isCollapsed ifFalse:
			[TopWindow model ifNotNil:
				[TopWindow model modelWakeUpIn: TopWindow]]]
]

{ #category : #preferences }
SystemWindow class >> windowTitleActiveOnFirstClick [
	<preference: 'Windows'' Controls Are Always Active'
		category: 'windows'
		description: '... except for grips and splitters. Those remain always active and an option to bring the window to the front.'
		type: #Boolean>
	^ WindowTitleActiveOnFirstClick ifNil: [ true ]
]

{ #category : #preferences }
SystemWindow class >> windowTitleActiveOnFirstClick: boolean [
	WindowTitleActiveOnFirstClick := boolean.
	self reconfigureWindowsForFocus.
]

{ #category : #'top window' }
SystemWindow class >> windowsIn: aWorld [

	^ self windowsIn: aWorld satisfying: [:window | true].
]

{ #category : #'top window' }
SystemWindow class >> windowsIn: aWorld satisfying: windowBlock [
	| windows |

	windows := OrderedCollection new.
	aWorld ifNil: [^windows].	"opening MVC in Morphic - WOW!"
	aWorld submorphs do:
		[:m | | s |
		((m isSystemWindow) and: [windowBlock value: m])
			ifTrue: [windows addLast: m]
			ifFalse: [((m isKindOf: TransformationMorph) and: [m submorphs size = 1])
					ifTrue: [s := m firstSubmorph.
							((s isSystemWindow) and: [windowBlock value: s])
								ifTrue: [windows addLast: s]]]].
	^ windows
]

{ #category : #preferences }
SystemWindow class >> windowsRaiseOnClick [
	<preference: 'Windows Raise On Any Click'
		category: 'windows'
		description: 'If false, windows only raise when clicking on window decorations.'
		type: #Boolean>
	^ WindowsRaiseOnClick ifNil: [ true ]
]

{ #category : #preferences }
SystemWindow class >> windowsRaiseOnClick: boolean [
	WindowsRaiseOnClick := boolean.
]

{ #category : #focus }
SystemWindow >> activate [
	"An active window delegate user input events as usual to its contents such as buttons or lists. There is a preference to ensure that all windows stay active regardless of being focused or not. Also take a look at #passivate, #lookFocused, and #beKeyWindow."
	
	self isActive ifTrue: [self lookFocused. ^ self].
	self topRendererOrSelf owner ifNil: [^ self "avoid spurious activate when drop in trash"].
	
	self isActive: true.
			
	"Special handling for expanded windows."
	self isCollapsed ifFalse: [
		model modelWakeUpIn: self.
		self positionSubmorphs].

	self submorphsDo: [:each | each unlock].

	self lookFocused.
]

{ #category : #initialization }
SystemWindow >> addCloseBox [
	"If I have a labelArea, add a close box to it"

	labelArea ifNil: [^ self].
	mustNotClose == true ifTrue: [^ self].
	closeBox ifNotNil: [closeBox delete].
	closeBox := self createCloseBox.
	closeBox layoutFrame: self class closeBoxFrame.
	labelArea addMorphFront: closeBox
]

{ #category : #initialization }
SystemWindow >> addCornerGrips [
	"When enabled via preference, also add edge grips"
	super addCornerGrips.
	self class resizeAlongEdges ifTrue:[self addEdgeGrips].
]

{ #category : #menu }
SystemWindow >> addCustomMenuItems: aCustomMenu hand: aHandMorph [
	super addCustomMenuItems: aCustomMenu hand: aHandMorph.
"template..."
	aCustomMenu addLine.
	aCustomMenu add: 'edit label...' translated action: #relabel.

]

{ #category : #initialization }
SystemWindow >> addExpandBox [
	"If I have a labelArea, add a close box to it"
	
	labelArea ifNil: [^ self].
	self class hideExpandButton ifTrue: [^ self].
	expandBox ifNotNil: [expandBox delete].
	expandBox := self createExpandBox.
	expandBox layoutFrame: self class expandBoxFrame.
	labelArea addMorphBack: expandBox
]

{ #category : #initialization }
SystemWindow >> addKeyboardShortcuts [
	"Install an event capture filter to add shortcuts for window control operations."
	
	self addKeyboardCaptureFilter: self.
]

{ #category : #label }
SystemWindow >> addLabel [

	(labelArea isNil or: [label isNil]) ifTrue: [^ self].
	labelArea 
		addMorphBack: (Morph new extent: self class borderWidth @ 0);
		addMorphBack: label.
	label on: #startDrag send: #startDragFromLabel: to: self.
	self class clickOnLabelToEdit
		ifTrue: [label on: #mouseUp send: #relabel to: self].
	self class doubleClickOnLabelToExpand
		ifTrue: [label on: #doubleClick send: #expandBoxHit to: self].
]

{ #category : #initialization }
SystemWindow >> addLabelArea [

	labelArea ifNotNil: [labelArea abandon].
	labelArea := (AlignmentMorph newSpacer: Color transparent)
			vResizing: #spaceFill;
			layoutPolicy: ProportionalLayout new.
	self addMorph: labelArea.
]

{ #category : #initialization }
SystemWindow >> addMenuControl [
	"If I have a label area, add a menu control to it."
	
	labelArea ifNil: [^ self].
	"No menu if no label area"
	menuBox ifNotNil: [menuBox delete].
	menuBox := self createMenuBox.
	menuBox layoutFrame: self class menuBoxFrame.
	labelArea addMorphBack: menuBox
]

{ #category : #panes }
SystemWindow >> addMorph: aMorph frame: relFrame [
	| frame |
	frame := LayoutFrame new.
	frame 
		leftFraction: relFrame left; 
		rightFraction: relFrame right; 
		topFraction: relFrame top; 
		bottomFraction: relFrame bottom.
	self addMorph: aMorph fullFrame: frame.


]

{ #category : #panes }
SystemWindow >> addMorph: aMorph fullFrame: aLayoutFrame [
	"Add aMorph according to aLayoutFrame."

	super addMorph: aMorph fullFrame: aLayoutFrame.

	paneMorphs := paneMorphs copyReplaceFrom: 1 to: 0 with: (Array with: aMorph).
	aMorph isImageMorph ifFalse: [aMorph adoptPaneColor: self paneColor].
]

{ #category : #initialization }
SystemWindow >> addPaneSplitters [

	self removeCornerGrips.

	super addPaneSplitters.
	
	self addCornerGrips.
]

{ #category : #'resize\/collapse' }
SystemWindow >> allowReframeHandles [

	^ allowReframeHandles
]

{ #category : #'resize\/collapse' }
SystemWindow >> allowReframeHandles: aBoolean [

	allowReframeHandles := aBoolean
]

{ #category : #stepping }
SystemWindow >> amendSteppingStatus [
	"Circumstances having changed, find out whether stepping is wanted and assure that the new policy is carried out"

	self wantsSteps
		ifTrue:
			[self arrangeToStartStepping]
		ifFalse:
			[self stopStepping]
]

{ #category : #'open\/close' }
SystemWindow >> anyOpenWindowLikeMeIn: aPasteUpMorph [
	self class reuseWindows ifFalse: [ ^Array empty ].
	^ SystemWindow
		windowsIn: aPasteUpMorph 
		satisfying: 
			[ : each |
			each model class = self model class
				and: [ (each model respondsTo: #representsSameBrowseeAs:) 
				and: [ each model representsSameBrowseeAs: self model ] ] ]

]

{ #category : #initialization }
SystemWindow >> applyModelExtent [
	self extent: model initialExtent 
]

{ #category : #'user interface' }
SystemWindow >> applyUserInterfaceTheme [

	super applyUserInterfaceTheme.
	
	self
		setDefaultParameters;
		replaceBoxes;
		refreshWindowColor.

	self isLookingFocused
		ifTrue: [self lookUnfocused; lookFocused]
		ifFalse: [self lookFocused; lookUnfocused].
		
	self isCollapsed ifTrue: [self setProperty: #applyTheme toValue: true].
]

{ #category : #drawing }
SystemWindow >> areasRemainingToFill: aRectangle [
	| areas |
	(areas := super areasRemainingToFill: aRectangle) isEmpty
		ifTrue: [^ areas "good news -- complete occlusion"].
	"Check for special case that this is scrollbar damage"
	((bounds topLeft - (14@0) corner: bounds bottomRight) containsRect: aRectangle) ifTrue:
		[paneMorphs do: [:p | ((p isKindOf: ScrollPane) and: [p scrollBarFills: aRectangle])
							ifTrue: [^ Array new]]].
	^ areas
]

{ #category : #layout }
SystemWindow >> assureLabelAreaVisible [
	"Label should be visible to interact with."

	(RealEstateAgent maximumUsableAreaInWorld: self world) in: [:rect |
		 self innerBounds top < rect top ifTrue: [self top: rect top]].
]

{ #category : #'top window' }
SystemWindow >> beKeyWindow [
	"Let me be the most important window on the screen. I am at the top and I can have a shadow to get more attention by the user. I am the window that is responsible for window keyboard shortcuts. Also see #isKeyWindow, #activate, and #lookFocused."

	| oldKeyWindow |
	self isKeyWindow ifTrue: [^ self].

	oldKeyWindow := TopWindow.
	TopWindow := self.

	self
		unlockWindowDecorations; "here, because all windows might be active anyway"
		activate; "if not already active, activate now"
		comeToFront. "key windows are on top"

	"Change appearance to get noticed."
	self hasDropShadow: Preferences menuAppearance3d.
	(self valueOfProperty: #borderWidthWhenActive)
		ifNotNil: [:bw | self acquireBorderWidth: bw].

	oldKeyWindow ifNotNil: [:wnd |
		wnd passivateIfNeeded.
		
		"Change appearance to not look prettier than the new key window."
		wnd hasDropShadow: false.
		(wnd valueOfProperty: #borderWidthWhenInactive)
			ifNotNil: [:bw | wnd acquireBorderWidth: bw]].

	"Synchronize focus look with position of current hand because any call could have made this window the new key window."
	self updateFocusLookAtHand.
]

{ #category : #'top window' }
SystemWindow >> beKeyWindowIfNeeded: evt [
	"Make me the new key window if needed. Ensure that the focus look matches the keyboard focus."

	(self isKeyWindow not
		and: [self class windowsRaiseOnClick
			or: [self windowDecorations anySatisfy: [:morph | morph bounds containsPoint: evt position]] ])
				ifFalse: [
					"Just ensure the correct look after the event."
					self updateFocusLookForKeyboardFocus]
				ifTrue: [
					"We are the new key window at the front etc."
					self beKeyWindow.
					"There may have been a pop-up menu spawned. We do not want to occlude that."
					evt hand mouseFocus ifNotNil: [:morph |
						morph owner = self world ifTrue: [morph comeToFront]].
					evt hand balloonHelpList do: [:morph |
						morph comeToFront]]
]

{ #category : #initialization }
SystemWindow >> boxExtent [
	"the label height is used to be proportional to the fonts preferences"
	
	^ self class boxExtent
		max: label height @ label height 
]

{ #category : #menu }
SystemWindow >> buildWindowMenu [
	| aMenu |
	aMenu := MenuMorph new defaultTarget: self.
	aMenu add: 'change title...' translated action: #relabel.
	aMenu addLine.
	aMenu add: 'send to back' translated action: #sendToBack.
	aMenu add: 'make next-to-topmost' translated action: #makeSecondTopmost.
	aMenu addLine.
	self mustNotClose
		ifFalse:
			[aMenu add: 'make unclosable' translated action: #makeUnclosable]
		ifTrue:
			[aMenu add: 'make closable' translated action: #makeClosable].
	aMenu
		add: (self isSticky ifTrue: ['make draggable'] ifFalse: ['make undraggable']) translated 
		action: #toggleStickiness.
	aMenu addLine.
	self unexpandedFrame 
		ifNil: [aMenu add: 'full screen' translated action: #expandBoxHit]
		ifNotNil: [aMenu add: 'original size' translated action: #expandBoxHit].
	self isCollapsed ifFalse: [aMenu add: 'window color...' translated action: #setWindowColor].
	^aMenu
]

{ #category : #menu }
SystemWindow >> changeColor [
	"Change the color of the receiver -- triggered, e.g. from a menu.  This variant allows the recolor triggered from the window's halo recolor handle to have the same result as choosing change-window-color from the window-title menu"
	NewColorPickerMorph useIt
		ifTrue:
			[ (NewColorPickerMorph
				on: self
				originalColor: self color
				setColorSelector: #setWindowColor:) openNear: self fullBoundsInWorld ]
		ifFalse:
			[ ColorPickerMorph new
				 choseModalityFromPreference ;
				 sourceHand: self activeHand ;
				 target: self ;
				 selector: #setWindowColor: ;
				 originalColor: self color ;
				
				putUpFor: self
				near: self fullBoundsInWorld ]
]

{ #category : #'open\/close' }
SystemWindow >> closeBoxHit [
	"The user clicked on the close-box control in the window title.  For Mac users only, the Mac convention of option-click-on-close-box is obeyed if the mac option key is down."

	Preferences dismissAllOnOptionClose ifTrue:
		[Sensor rawMacOptionKeyPressed ifTrue:
			[^ self world closeUnchangedWindows]].
	self delete

]

{ #category : #'resize\/collapse' }
SystemWindow >> collapse [
	self isCollapsed ifFalse:[self collapseOrExpand]
]

{ #category : #'resize\/collapse' }
SystemWindow >> collapseOrExpand [
	"Collapse or expand the window, depending on existing state"
	| cf |
	isCollapsed
		ifTrue: 
			["Expand -- restore panes to morphics structure"
			isCollapsed := false.
			self beKeyWindow.  "Bring to frint first"
			Preferences collapseWindowsInPlace
				ifTrue: 
					[fullFrame := fullFrame align: fullFrame topLeft with: self getBoundsWithFlex topLeft]
				ifFalse:
					[collapsedFrame := self getBoundsWithFlex].
			collapseBox ifNotNil: [collapseBox setBalloonText: 'collapse this window' translated].
			self setBoundsWithFlex: fullFrame.
			paneMorphs reverseDo: 
					[:m |  self addMorph: m unlock.
					self world startSteppingSubmorphsOf: m].
			self addPaneSplitters.
			(self hasProperty: #applyTheme) ifTrue: [
				self removeProperty: #applyTheme.
				self userInterfaceTheme applyTo: self allMorphs]]
		ifFalse: 
			["Collapse -- remove panes from morphics structure"
			isCollapsed := true.
			fullFrame := self getBoundsWithFlex.
			"First save latest fullFrame"
			paneMorphs do: [:m | m delete; releaseCachedState].
			self removePaneSplitters.
			self removeCornerGrips.
			model modelSleep.
			cf := self getCollapsedFrame.
			(collapsedFrame isNil and: [Preferences collapseWindowsInPlace not]) ifTrue:
				[collapsedFrame := cf].
			self setBoundsWithFlex: cf.
			collapseBox ifNotNil: [collapseBox setBalloonText: 'expand this window' translated ].
			expandBox ifNotNil: [expandBox setBalloonText: 'expand this window' translated ].
			self sendToBack].
	self layoutChanged
]

{ #category : #'resize\/collapse' }
SystemWindow >> collapsedFrame [
	^ collapsedFrame
]

{ #category : #drawing }
SystemWindow >> colorForInsets [
	^self paneColor colorForInsets
]

{ #category : #'top window' }
SystemWindow >> comeToFront [

	"Modal windows: Walk along the modal owner chain, the bring all to top."
	self modalOwner ifNotNil: [:mo | mo isSystemWindow ifTrue: [
		^ mo modalOwner
			ifNil: [mo comeToFrontModally]
			ifNotNil: [:omo | omo comeToFront]]].
	self modalChild ifNotNil: [^ self comeToFrontModally].
	
	"Now show me."
	super comeToFront.
		
	"Label should be visible to interact with."
	self assureLabelAreaVisible.
	
	"Handle historic companions. May be removed in the future."
	self extantSketchEditor ifNotNil: [:sketchEditor | 
		sketchEditor comeToFront.
		(self world findA: PaintBoxMorph) ifNotNil: [:pal | pal comeToFront]].
]

{ #category : #'top window' }
SystemWindow >> comeToFrontModally [
	"If I am modal, bring along my modal owning window and my model child as well."

	super comeToFront.
	
	"Bring up my modal children in front of me."
	self modalChild ifNotNil: [:wnd | 
		wnd comeToFrontModally.
		wnd modalChild ifNil: [wnd flash]].
]

{ #category : #'resize\/collapse' }
SystemWindow >> contractToOriginalSize [
	self bounds: self unexpandedFrame.
	self unexpandedFrame: nil.
	expandBox ifNotNil: [expandBox setBalloonText: 'expand this window' translated].
]

{ #category : #layout }
SystemWindow >> convertAlignment [
	"Primarily Jesse Welton's code to convert old system windows to ones with modern layout scheme"

	self layoutPolicy: ProportionalLayout new.
	(paneMorphs isNil 
		or: [paneRects isNil or: [paneMorphs size ~= paneRects size]]) 
			ifFalse: 
				[self addLabelArea.
				self putLabelItemsInLabelArea.
				self setFramesForLabelArea.
				paneMorphs with: paneRects
					do: 
						[:m :r | 
						| frame |
						frame := LayoutFrame new.
						frame
							leftFraction: r left;
							rightFraction: r right;
							topFraction: r top;
							bottomFraction: r bottom.
						m layoutFrame: frame.
						m
							hResizing: #spaceFill;
							vResizing: #spaceFill]].
	labelArea isNil 
		ifTrue: 
			[self addLabelArea.
			self putLabelItemsInLabelArea.
			self setFramesForLabelArea.
			paneMorphs ifNotNil: 
					[paneMorphs do: 
							[:m | 
							| frame |
							frame := m layoutFrame ifNil: [LayoutFrame new].
							frame topOffset: (frame topOffset) - self labelHeight.
							frame bottomFraction ~= 1.0 
								ifTrue: 
									[frame bottomOffset: (frame bottomOffset) - self labelHeight]]]].
	label ifNotNil: 
			[| frame |
			frame := LayoutFrame new.
			frame
				leftFraction: 0.5;
				topFraction: 0;
				leftOffset: label width negated // 2.
			label layoutFrame: frame].
	collapseBox ifNotNil: 
			[| frame |
			frame := LayoutFrame new.
			frame
				rightFraction: 1;
				topFraction: 0;
				rightOffset: -1;
				topOffset: 1.
			collapseBox layoutFrame: frame].
	stripes ifNotNil: 
			[| frame |
			frame := LayoutFrame new.
			frame
				leftFraction: 0;
				topFraction: 0;
				rightFraction: 1;
				leftOffset: 1;
				topOffset: 1;
				rightOffset: -1.
			stripes first layoutFrame: frame.
			stripes first height: self labelHeight - 2.
			stripes first hResizing: #spaceFill.
			frame := LayoutFrame new.
			frame
				leftFraction: 0;
				topFraction: 0;
				rightFraction: 1;
				leftOffset: 3;
				topOffset: 3;
				rightOffset: -3.
			stripes last layoutFrame: frame.
			stripes last height: self labelHeight - 6.
			stripes last hResizing: #spaceFill].
	menuBox ifNotNil: 
			[| frame |
			frame := LayoutFrame new.
			frame
				leftFraction: 0;
				leftOffset: 19;
				topFraction: 0;
				topOffset: 1.
			menuBox layoutFrame: frame].
	closeBox ifNotNil: 
			[| frame |
			frame := LayoutFrame new.
			frame
				leftFraction: 0;
				leftOffset: 4;
				topFraction: 0;
				topOffset: 1.
			closeBox layoutFrame: frame]
]

{ #category : #'object fileIn' }
SystemWindow >> convertToCurrentVersion: varDict refStream: smartRefStrm [
	
	allowReframeHandles ifNil: [allowReframeHandles := true].
	self layoutPolicy ifNil: [self convertAlignment].
	labelArea ifNil: [self convertAlignment].
	^super convertToCurrentVersion: varDict refStream: smartRefStrm.


]

{ #category : #initialization }
SystemWindow >> createBox: aForm [
	"create a button with a form to be used in the label area"
	
	| box |
	box := SystemWindowButton new.
	box color: Color transparent;
		 target: self;
		 useSquareCorners;
		 borderWidth: 0;
		 labelGraphic: aForm scaleIconToDisplay;
		 extent: self boxExtent.
	^ box
]

{ #category : #initialization }
SystemWindow >> createCloseBox [
	^ (self createBox: self class closeBoxImage)
		actionSelector: #closeBoxHit;
		setBalloonText: 'close this window' translated
]

{ #category : #initialization }
SystemWindow >> createCollapseBox [
	^ (self createBox: self class collapseBoxImage)
		actionSelector: #collapseOrExpand;
		setBalloonText: 'collapse this window' translated.

]

{ #category : #initialization }
SystemWindow >> createExpandBox [
	^ (self createBox: self class expandBoxImage)
		actionSelector: #expandBoxHit;
		setBalloonText: 'expand this window' translated
]

{ #category : #initialization }
SystemWindow >> createMenuBox [
	^ (self createBox: self class menuBoxImage)
		actionSelector: #offerWindowMenu;
		setBalloonText: 'window menu' translated
]

{ #category : #initialization }
SystemWindow >> defaultBounds [

	^ 0@0 corner: 300@200
]

{ #category : #initialization }
SystemWindow >> defaultColor [

	^ self userInterfaceTheme color ifNil: [Color veryVeryLightGray]
]

{ #category : #'open\/close' }
SystemWindow >> delete [
	| thisWorld sketchEditor aPaintBox |
	self mustNotClose ifTrue: [^self].
	model okToClose ifFalse: [^self].
	thisWorld := self world.
	sketchEditor := self extantSketchEditor.
	
	self activeHand removeKeyboardListener: self.
	
	self isFlexed
		ifTrue: [owner delete]
		ifFalse: [super delete].
	model windowIsClosing; release.
	model := nil.
	sketchEditor ifNotNil:
		[sketchEditor deleteSelfAndSubordinates.
		 (thisWorld notNil 
		  and: [(aPaintBox := thisWorld paintBoxOrNil) notNil]) ifTrue:
			[aPaintBox delete]].
		
	SystemWindow noteTopWindowIn: thisWorld
]

{ #category : #menu }
SystemWindow >> deleteCloseBox [
	closeBox ifNotNil:
		[closeBox delete.
		closeBox := nil]
]

{ #category : #'top window' }
SystemWindow >> dimWindowButtons [
	{closeBox. collapseBox. menuBox. expandBox}
		do: [:b | b ifNotNil: [b dim]]
]

{ #category : #events }
SystemWindow >> doFastFrameDrag: grabPoint [
	"Do fast frame dragging from the given point"

	| offset newBounds outerWorldBounds clearArea |
	outerWorldBounds := self boundsIn: nil.
	offset := outerWorldBounds origin - grabPoint.
	clearArea := self currentWorld clearArea.
	newBounds := outerWorldBounds newRectFrom: [:f |
		| p selector |
		p := Sensor cursorPoint.
		(self class dragToEdges and: [(selector := self dragToEdgesSelectorFor: p in: clearArea) notNil])
			ifTrue: [clearArea perform: selector]
			ifFalse: [p + offset extent: outerWorldBounds extent]].
	self bounds: newBounds; comeToFront
]

{ #category : #'resize\/collapse' }
SystemWindow >> dragToEdgeDistance [
	^10
]

{ #category : #'resize\/collapse' }
SystemWindow >> dragToEdgesSelectorFor: p in: a [
	"answer first matching drag resize selector, if none is found, answer nil"
	#(isPoint:nearTopLeftOf: isPoint:nearTopRightOf: isPoint:nearBottomLeftOf: isPoint:nearBottomRightOf: isPoint:nearTopOf: isPoint:nearBottomOf: isPoint:nearLeftOf: isPoint:nearRightOf:)
		with: #(topLeftQuadrant topRightQuadrant bottomLeftQuadrant bottomRightQuadrant topHalf bottomHalf leftHalf rightHalf)
		do: [:predicate :selector |
			(self perform: predicate with: p with: a) ifTrue: [^selector]].
	^nil
]

{ #category : #colors }
SystemWindow >> existingPaneColor [
	"Answer the existing pane color for the window, obtaining it from the first paneMorph if any, and fall back on using the second stripe color if necessary."

	| aColor |
	aColor := self valueOfProperty: #paneColor.
	aColor ifNil: [self setProperty: #paneColor toValue: (aColor := self paneColor)].
	^aColor.
]

{ #category : #'resize\/collapse' }
SystemWindow >> expand [
	self isCollapsed ifTrue:[self collapseOrExpand]
]

{ #category : #'resize\/collapse' }
SystemWindow >> expandBoxHit [
	isCollapsed
		ifTrue: [self	hide;
					collapseOrExpand;
					expandToFullScreen;
					show]
		ifFalse: [self unexpandedFrame 
					ifNil: [self expandToFullScreen]
					ifNotNil: [self contractToOriginalSize]]
]

{ #category : #'resize\/collapse' }
SystemWindow >> expandToFullScreen [
	self unexpandedFrame ifNil: [ self unexpandedFrame: fullFrame ].
	self fullScreen.
	expandBox ifNotNil: [expandBox setBalloonText: 'contract to original size' translated]
]

{ #category : #'top window' }
SystemWindow >> extantSketchEditor [
	"If my world has an extant SketchEditorMorph associated with anything  
	in this window, return that SketchEditor, else return nil"
	| w sketchEditor pasteUp |
	(w := self world) isNil ifTrue: [^ nil].
	(sketchEditor := w sketchEditorOrNil) isNil ifTrue: [^ nil].
	(pasteUp := sketchEditor enclosingPasteUpMorph) isNil ifTrue: [^ nil].
	self findDeepSubmorphThat: [:m | m = pasteUp]
		ifAbsent: [^ nil].
	^ sketchEditor
]

{ #category : #geometry }
SystemWindow >> extent: aPoint [ 
	"Set the receiver's extent to value provided. Respect my minimumExtent."

	| newExtent |
	newExtent := self isCollapsed
		ifTrue: [aPoint]
		ifFalse: [aPoint max: self minimumExtent].
	newExtent = self extent ifTrue: [^ self].

	isCollapsed
		ifTrue: [super extent: newExtent x @ (self labelHeight + (self layoutInset * 2))]
		ifFalse: [super extent: newExtent].
	isCollapsed
		ifTrue: [collapsedFrame := self bounds]
		ifFalse: [fullFrame := self bounds]
]

{ #category : #'resize\/collapse' }
SystemWindow >> fastFramingOn [

	^ Preferences fastDragWindowForMorphic and: [self isFlexed not]
]

{ #category : #events }
SystemWindow >> filterEvent: aKeyboardEvent for: anObject [
	"Provide keyboard shortcuts."

	aKeyboardEvent isKeystroke
		ifFalse: [^ aKeyboardEvent].

	aKeyboardEvent hand halo ifNotNil: [ : halo | halo target isSystemWindow ifTrue: [ aKeyboardEvent hand removeHalo ] ].
	
	aKeyboardEvent commandKeyPressed ifTrue: [
		aKeyboardEvent keyCharacter caseOf: { 
			[$\] -> [self class sendTopWindowToBack].
			[Character escape] -> [self class deleteTopWindow].
			[$/] -> [self class bringWindowUnderHandToFront].
		} otherwise: [^ aKeyboardEvent "no hit"].
		^ aKeyboardEvent ignore "hit!"].
	
	aKeyboardEvent controlKeyPressed ifTrue: [
		aKeyboardEvent keyCharacter caseOf: {
			[Character escape] -> [self world findWindow: aKeyboardEvent].
		} otherwise: [^ aKeyboardEvent "no hit"].
		^ aKeyboardEvent ignore "hit!"].

	^ aKeyboardEvent "no hit"
]

{ #category : #'resize\/collapse' }
SystemWindow >> fullFrame [
	^ fullFrame
]

{ #category : #menu }
SystemWindow >> fullScreen [
	"Zoom Window to full owner size, allowing for scroll bars and desk margins"
	
	| left right possibleBounds |
	left := right := 0.
	self paneMorphs
		do: [:pane | ((pane isKindOf: ScrollPane)
					and: [pane retractableScrollBar])
				ifTrue: [pane scrollBarOnLeft
						ifTrue: [left := left max: pane scrollBarThickness]
						ifFalse: [right := right max: pane scrollBarThickness]]].
	possibleBounds := (RealEstateAgent maximumUsableAreaInWorld: self owner)
				insetBy: (left @ 0 corner: right @ 0).
	Preferences fullScreenLeavesDeskMargins
		ifTrue: [possibleBounds := possibleBounds insetBy: 22].
	self bounds: possibleBounds
]

{ #category : #menu }
SystemWindow >> fullScreenMaximumExtent [
	"Zoom Window to Full World size with possible DeskMargins
	obey the maximum extent rules"
	
	| left right possibleBounds |
	left := right := 0.
	self paneMorphs
		do: [:pane | ((pane isKindOf: ScrollPane)
					and: [pane retractableScrollBar])
				ifTrue: [pane scrollBarOnLeft
						ifTrue: [left := left max: pane scrollBarThickness]
						ifFalse: [right := right max: pane scrollBarThickness]]].
	possibleBounds := self worldBounds
				insetBy: (left @ 0 corner: right @ 0).

	self maximumExtent ifNotNil:
		[possibleBounds := possibleBounds origin extent: ( self maximumExtent min: ( possibleBounds extent ))].
	((Flaps sharedFlapsAllowed
				and: [Project current flapsSuppressed not])
			or: [Preferences fullScreenLeavesDeskMargins])
		ifTrue: [possibleBounds := possibleBounds insetBy: 22].
	self bounds: possibleBounds
]

{ #category : #'resize\/collapse' }
SystemWindow >> getBoundsWithFlex [
	"Return the lastest bounds rectangle with origin forced to global coordinates"

	self isFlexed
		ifTrue: [^ ((owner transform localPointToGlobal: bounds topLeft)
										extent: bounds extent)]
		ifFalse: [^ self bounds].

]

{ #category : #'resize\/collapse' }
SystemWindow >> getCollapsedFrame [

	| tmp |
	^Preferences collapseWindowsInPlace 
		ifTrue:
			[tmp := self getBoundsWithFlex.
			tmp origin corner: (tmp corner x @ 18)]
		ifFalse:
			[RealEstateAgent assignCollapseFrameFor: self]
]

{ #category : #label }
SystemWindow >> getRawLabel [
	| contentsFit |
	contentsFit := label duplicate fitContents.
	contentsFit extent: (label extent x min: contentsFit extent x) @ contentsFit extent y.
	
	^ contentsFit

]

{ #category : #colors }
SystemWindow >> gradientWithColor: aColor [

	| gradient cc |
	cc := aColor adjustSaturation: -0.08 brightness: 0.4.
	gradient := GradientFillStyle ramp: {
		0.0 -> (self isKeyWindow ifTrue: [cc muchLighter] ifFalse: [cc]). 
		0.25 -> (aColor mixed: 0.5 with: cc). 
		1.0 -> aColor.
	}.
	gradient origin: self topLeft.
	gradient direction: 0 @ self labelHeight.
	^gradient
]

{ #category : #events }
SystemWindow >> handleListenEvent: aUserInputEvent [ 
	"See #mouseEnterDragging:. Watch for finished drag-and-drop action and lock contents accordingly."

	(aUserInputEvent isMouse and: [ aUserInputEvent hand hasSubmorphs not ]) ifTrue: 
		[ self isKeyWindow ifFalse: [ self passivateIfNeeded ].
		aUserInputEvent hand removeMouseListener: self ].
]

{ #category : #events }
SystemWindow >> handleMouseDown: evt [ 

	self beKeyWindowIfNeeded: evt.
	^ super handleMouseDown: evt
]

{ #category : #events }
SystemWindow >> handleMouseUp: evt [ 
	"Some widgets grab the keyboard focus only on mouse-up. Hence, we need to update our looks."
	
	self updateFocusLookForKeyboardFocus.
	^ super handleMouseUp: evt
]

{ #category : #events }
SystemWindow >> handlesMouseDown: evt [ 

	^ true
]

{ #category : #events }
SystemWindow >> handlesMouseOver: anEvent [
	^ true
]

{ #category : #events }
SystemWindow >> handlesMouseOverDragging: evt [
	^true
]

{ #category : #panes }
SystemWindow >> holdsTranscript [
	"ugh"
	| plug |
	^ paneMorphs size = 1 and: [((plug := paneMorphs first) isKindOf: PluggableTextMorph) and: [plug model isKindOf: TranscriptStream]]
]

{ #category : #thumbnail }
SystemWindow >> icon [
	"Answer a form with an icon to represent the receiver"
	^ MenuIcons windowIcon
]

{ #category : #'open\/close' }
SystemWindow >> initialExtent [
	"Ask the model for it's initial extent."
	
	^ model initialExtent
]

{ #category : #initialization }
SystemWindow >> initialize [
	"Initialize a system window. Add label, stripes, etc., if desired"

	super initialize.

	self layoutPolicy: ProportionalLayout new.

	self wantsPaneSplitters: true.
	self layoutInset: ProportionalSplitterMorph gripThickness.
	self cellGap: ProportionalSplitterMorph gripThickness.

	self initializeLabelArea.				
	self addCornerGrips.
	self setDefaultParameters.

	allowReframeHandles := true.
	isCollapsed := false.
	paneMorphs := Array new.
	mustNotClose := false.
	updatablePanes := Array new.

	self initializeKeyboardShortcuts.
]

{ #category : #initialization }
SystemWindow >> initializeKeyboardShortcuts [
	"Install an event capture filter to add shortcuts for window control operations."
	
	PasteUpMorph globalCommandKeysEnabled
		ifTrue: [self addKeyboardShortcuts].
]

{ #category : #initialization }
SystemWindow >> initializeLabelArea [
	"Initialize the label area (titlebar) for the window."
	
	labelString ifNil: [labelString := 'Untitled Window'].
	label := StringMorph new
				contents: labelString;
				font: (self userInterfaceTheme titleFont ifNil: [TextStyle defaultFont]);
				yourself.
			"Add collapse box so #labelHeight will work"
			collapseBox := self createCollapseBox.
			stripes := Array
						with: (RectangleMorph newBounds: bounds)
						with: (RectangleMorph newBounds: bounds).
			"see extent:"
			self addLabelArea.
			self setLabelWidgetAllowance.
			self addCloseBox.
			self class moveMenuButtonRight 
				ifTrue: [self addLabel. self addMenuControl]
				ifFalse: [self addMenuControl. self addLabel].
			self addExpandBox.
			labelArea addMorphBack: collapseBox.
			self setFramesForLabelArea.
			Preferences noviceMode
				ifTrue: [closeBox
						ifNotNil: [closeBox setBalloonText: 'close window'].
					menuBox
						ifNotNil: [menuBox setBalloonText: 'window menu'].
					collapseBox
						ifNotNil: [collapseBox setBalloonText: 'collapse/expand window']].

]

{ #category : #initialization }
SystemWindow >> initializeWithLabel: aString [

	labelString := aString.	
	self initialize.
]

{ #category : #focus }
SystemWindow >> isActive [
	
	^ isActive ifNil: [false]
]

{ #category : #focus }
SystemWindow >> isActive: aBoolean [
	
	isActive := aBoolean.
]

{ #category : #'resize\/collapse' }
SystemWindow >> isCollapsed [
	^ isCollapsed
]

{ #category : #'top window' }
SystemWindow >> isKeyWindow [
	"The key window is the window with the user's main attention. It usually has a shadow or other visual hints to separate it from other windows. Usually, the key window is at the top of the screen. On large screens, however, many windows may appear at the top. Also see #beKeyWindow, #activate, and #lookFocused."

	^ self == self class keyWindow
]

{ #category : #focus }
SystemWindow >> isLookingFocused [
	
	^ isLookingFocused ifNil: [false]
]

{ #category : #focus }
SystemWindow >> isLookingFocused: aBoolean [
	
	isLookingFocused := aBoolean.
]

{ #category : #'resize\/collapse' }
SystemWindow >> isPoint: p nearBottomLeftOf: a [
	^(self isPoint: p nearBottomOf: a) and: [self isPoint: p nearLeftOf: a]
]

{ #category : #'resize\/collapse' }
SystemWindow >> isPoint: p nearBottomOf: a [
	^p y > (a bottom - self dragToEdgeDistance)
]

{ #category : #'resize\/collapse' }
SystemWindow >> isPoint: p nearBottomRightOf: a [
	^(self isPoint: p nearBottomOf: a) and: [self isPoint: p nearRightOf: a]
]

{ #category : #'resize\/collapse' }
SystemWindow >> isPoint: p nearLeftOf: a [
	^p x < (a left + self dragToEdgeDistance)
]

{ #category : #'resize\/collapse' }
SystemWindow >> isPoint: p nearRightOf: a [
	^p x > (a right - self dragToEdgeDistance)
]

{ #category : #'resize\/collapse' }
SystemWindow >> isPoint: p nearTopLeftOf: a [
	^(self isPoint: p nearTopOf: a) and: [self isPoint: p nearLeftOf: a]
]

{ #category : #'resize\/collapse' }
SystemWindow >> isPoint: p nearTopOf: a [
	^p y < (a top + self dragToEdgeDistance)
]

{ #category : #'resize\/collapse' }
SystemWindow >> isPoint: p nearTopRightOf: a [
	^(self isPoint: p nearTopOf: a) and: [self isPoint: p nearRightOf: a]
]

{ #category : #testing }
SystemWindow >> isSystemWindow [
"answer whatever the receiver is a SystemWindow"
	^ true
]

{ #category : #testing }
SystemWindow >> isWindowForModel: aModel [
	"Return true if the receiver acts as the window for the given model"
	^aModel == self model
]

{ #category : #geometry }
SystemWindow >> justDroppedInto: aMorph event: anEvent [

	isCollapsed
		ifTrue: [self position: ((self position max: 0@0) grid: 8@8).
				collapsedFrame := self bounds]
		ifFalse: [fullFrame := self bounds].

	self beKeyWindow.
	self hasDropShadow: Preferences menuAppearance3d. "See #startDragFromLabel:."
			
	aMorph == self world ifTrue: [self assureLabelAreaVisible].

	(Project uiManager openToolsAttachedToMouseCursor and: (self hasProperty: #initialDrop))
		ifTrue: [
			self removeProperty: #initialDrop.
			(self submorphs detect: [:m | m isKindOf: BottomRightGripMorph] ifNone: [])
				ifNotNil: [:grip | 
					grip
						referencePoint: anEvent position;
						setProperty: #targetHadDropShadow toValue: true "See MorphicToolBuilder >> #open:".
					self
						hasDropShadow: false;
						lookFocused.
					anEvent hand newMouseFocus: grip.]].
			
	^super justDroppedInto: aMorph event: anEvent
]

{ #category : #label }
SystemWindow >> knownName [

	^ self label
]

{ #category : #label }
SystemWindow >> label [
	^ labelString
]

{ #category : #label }
SystemWindow >> labelArea [
	^ labelArea
]

{ #category : #label }
SystemWindow >> labelHeight [
	"Answer the height for the window label.  The standard behavior is at bottom; a hook is provided so that models can stipulate other heights, in support of various less-window-looking demos."

	| aHeight |
	(model notNil and: [model respondsTo: #desiredWindowLabelHeightIn:]) ifTrue:
		[(aHeight := model desiredWindowLabelHeightIn: self) ifNotNil: [^ aHeight]].

	^ label ifNil: [0] ifNotNil:
		 [(label height + self cellInset + self cellGap + self layoutInset) max:
			(collapseBox ifNotNil: [collapseBox height] ifNil: [10])]
]

{ #category : #geometry }
SystemWindow >> labelRect [
	^ self innerBounds withHeight: self labelHeight.

]

{ #category : #label }
SystemWindow >> labelWidgetAllowance [
	^ labelWidgetAllowance ifNil: [self setLabelWidgetAllowance]
]

{ #category : #layout }
SystemWindow >> layoutBounds [
	"Bounds of pane area only."
	| box |

	box := super layoutBounds.
	^box withTop: box top + self labelHeight
]

{ #category : #focus }
SystemWindow >> lockWindowDecorations [
	"Lock all window decrations, that is grips, splitters, and title bar."
	
	self windowDecorations do: [:m | m lock].
]

{ #category : #focus }
SystemWindow >> lockWindowTitle [
	
	labelArea ifNotNil: [:m | m lock].
]

{ #category : #focus }
SystemWindow >> lookFocused [
	"Some elements of windows change visually depending on the user input focus. This is property is orthogonal to being active or passive. Active windows can either look focused or unfocused. Passive windows will always look unfocused. Also see #lookUnfocused, #activate, #passivate, and #beKeyWindow."

	self isLookingFocused ifTrue: [^ self].
	self isLookingFocused: true.

	label ifNotNil: [ label color: (self userInterfaceTheme focusedLabelColor ifNil: [Color black]) ].
	
	(self isKeyWindow or: [self class windowTitleActiveOnFirstClick])
		ifTrue: [self undimWindowButtons].
		
	self paneColorToUse in: [ : col |
		self
			 setStripeColorsFrom: col ;
			 adoptPaneColor: col].
]

{ #category : #focus }
SystemWindow >> lookUnfocused [
	"See #lookFocused, #activate, and #passivate."

	self isLookingFocused ifFalse: [^ self].
	self isLookingFocused: false.

	label ifNotNil: [ label color: (self userInterfaceTheme unfocusedLabelColor ifNil: [Color darkGray]) ].
	self dimWindowButtons.
	self paneColorToUseWhenNotActive in: [ : col |
		self
			 setStripeColorsFrom: col ;
			 adoptPaneColor: col ]
]

{ #category : #menu }
SystemWindow >> makeClosable [
	mustNotClose := false.
	closeBox ifNil: [self addCloseBox]
]

{ #category : #drawing }
SystemWindow >> makeMeVisible [ 

	self world extent > (0@0) ifFalse: [^ self].

	((self world bounds insetBy: (0@0 corner: self labelHeight asPoint))
		containsPoint: self position) ifTrue: [^ self "OK -- at least my top left is visible"].

	"window not on screen (probably due to reframe) -- move it now"
	self isCollapsed
		ifTrue: [self position: (RealEstateAgent assignCollapsePointFor: self)]
		ifFalse: [self position: (RealEstateAgent initialFrameFor: self initialExtent: self extent world: self world) topLeft].


]

{ #category : #menu }
SystemWindow >> makeSecondTopmost [

	| aWorld nextWindow |
	aWorld := self world.
	nextWindow := aWorld submorphs 
				detect: [:m | (m isSystemWindow) and: [m ~~ self]]
				ifNone: [^self].

	self comeToFront.
	nextWindow beKeyWindow.
]

{ #category : #menu }
SystemWindow >> makeUnclosable [
	mustNotClose := true.
	self deleteCloseBox
]

{ #category : #initialization }
SystemWindow >> maximumExtent [
	"This returns the maximum extent that the morph may be expanded to.
	Return nil if this property has not been set."

	^ self valueOfProperty: #maximumExtent
]

{ #category : #initialization }
SystemWindow >> maximumExtent: aPoint [
	"This returns the maximum extent that the morph may be expanded to.
	Return nil if this property has not been set."

	^ self setProperty: #maximumExtent toValue: aPoint
]

{ #category : #polymorph }
SystemWindow >> modalChild [
	"Answer the modal child of the receiver, if any."

	^self valueOfProperty: #modalChild
]

{ #category : #polymorph }
SystemWindow >> modalLockTo: aSystemWindow [
	"Lock the receiver as a modal owner of the given window."

	aSystemWindow
		setProperty: #modalOwner toValue: self.
	self setProperty: #modalChild toValue: aSystemWindow
]

{ #category : #polymorph }
SystemWindow >> modalOwner [
	"Answer the modal owner of the receiver, if any."

	^self valueOfProperty: #modalOwner
]

{ #category : #polymorph }
SystemWindow >> modalUnlockFrom: aSystemWindow [
	"Unlock the receiver as a modal owner of the given window."

	aSystemWindow removeProperty: #modalOwner.
	self removeProperty: #modalChild.
	self beKeyWindow.
]

{ #category : #initialization }
SystemWindow >> model: anObject [
	super model: anObject.
	self paneColor: nil.
]

{ #category : #events }
SystemWindow >> mouseDown: evt [

	evt hand 
		waitForClicksOrDrag: self 
		event: evt 
		selectors: { nil. nil. nil. #startDragFromLabel: }
		threshold: HandMorph dragThreshold.
]

{ #category : #events }
SystemWindow >> mouseEnter: anEvent [ 
	"Handle a mouseEnter event, meaning the mouse just entered my bounds with no button pressed. The default response is to let my eventHandler, if any, handle it."
	super mouseEnter: anEvent.

	(self isActive and: [Preferences mouseOverForKeyboardFocus])
		ifTrue: [self lookFocused].
]

{ #category : #events }
SystemWindow >> mouseEnterDragging: evt [
	"unlock children for drop operations"
	
	self flag: #performance. "mt: There may be no need to change appearance if no widget wants the drop."
	self isActive ifTrue: [self lookFocused].
		
	(self isActive not and: [evt hand hasSubmorphs]) ifTrue: [
		self activate. "unlock contents for drop"
		evt hand addMouseListener: self. "for drop completion on submorph"
	].
]

{ #category : #events }
SystemWindow >> mouseLeave: anEvent [ 
	"Handle a mouseEnter event, meaning the mouse just entered my bounds with no button pressed. The default response is to let my eventHandler, if any, handle it."
	super mouseLeave: anEvent.
	
	(model windowActiveOnFirstClick and: [Preferences mouseOverForKeyboardFocus
		or: [anEvent hand keyboardFocus notNil and: [anEvent hand keyboardFocus containingWindow ~= self]]])
			ifTrue: [self lookUnfocused].
]

{ #category : #events }
SystemWindow >> mouseLeaveDragging: evt [
	"Passivate after drop operations if needed. Unfortunately, we get a leave-dragging event for the system window we want to drag. Watch out for it."
	
	((model windowActiveOnFirstClick and: [(evt hand submorphs includes: self) not])
		or: [self isKeyWindow not])
			ifTrue: [self lookUnfocused].
	
	(self isKeyWindow not and: [evt hand hasSubmorphs]) ifTrue:[
		self passivateIfNeeded.
		evt hand removeMouseListener: self. "no more drop completion possible on submorph"
	].
]

{ #category : #'resize\/collapse' }
SystemWindow >> mouseLeaveEvent: event fromPane: pane [
	"For backward compatibility only.  Not used by any newly created window"
	(pane isKindOf: ScrollPane) ifTrue: [pane mouseLeave: event].

]

{ #category : #'open\/close' }
SystemWindow >> mustNotClose [
	^ mustNotClose == true
]

{ #category : #menu }
SystemWindow >> offerWindowMenu [
	| aMenu |
	aMenu := self buildWindowMenu.
	model ifNotNil:
		[model addModelItemsToWindowMenu: aMenu].
	aMenu popUpEvent: self currentEvent in: self world
]

{ #category : #'open\/close' }
SystemWindow >> openAsIs [
	^self openAsIsIn: self currentWorld

]

{ #category : #'open\/close' }
SystemWindow >> openAsIsIn: aWorld [
	"This msg and its callees result in the window being activeOnlyOnTop"
	aWorld addMorph: self.
	self beKeyWindow.
	aWorld startSteppingSubmorphsOf: self.
]

{ #category : #'open\/close' }
SystemWindow >> openInWorld: aWorld [
	"This msg and its callees result in the window being activeOnlyOnTop"
	^ (self anyOpenWindowLikeMeIn: aWorld)
		ifEmpty: 
			[ self 
				bounds: (RealEstateAgent initialFrameFor: self world: aWorld) ;
				openAsIsIn: aWorld ]
		ifNotEmptyDo:
			[ : windows | 
			windows anyOne
				expand ;
				beKeyWindow ; 
				postAcceptBrowseFor: self ].
]

{ #category : #'open\/close' }
SystemWindow >> openInWorld: aWorld extent: extent [
	"This msg and its callees result in the window being activeOnlyOnTop"
	^ (self anyOpenWindowLikeMeIn: aWorld)
		ifEmpty:
			[ self 
				position: (RealEstateAgent initialFrameFor: self initialExtent: extent world: aWorld) topLeft ;
				extent: extent.
			self openAsIsIn: aWorld ]
		ifNotEmptyDo:
			[ : windows | 
			windows anyOne
				expand ;
				beKeyWindow ; 
				postAcceptBrowseFor: self ].
]

{ #category : #'open\/close' }
SystemWindow >> openInWorldExtent: extent [
	"This msg and its callees result in the window being activeOnlyOnTop"
	^ self openInWorld: self currentWorld extent: extent
]

{ #category : #colors }
SystemWindow >> paneColor [
	| cc |
	(cc := self valueOfProperty: #paneColor) ifNotNil: [^cc].
	(model respondsTo: #windowColorToUse) ifTrue: [cc := model windowColorToUse].
	cc ifNil: [cc := paneMorphs isEmptyOrNil ifFalse: [paneMorphs first color]].
	cc ifNil: [cc := self defaultColor].
	self paneColor: cc.
	^cc
]

{ #category : #colors }
SystemWindow >> paneColor: aColor [
	self setProperty: #paneColor toValue: aColor.

	self adoptPaneColor: aColor.
]

{ #category : #colors }
SystemWindow >> paneColorToUse [
	^ Display depth <= 2
		ifTrue:
			[Color white]
		ifFalse:
			[self paneColor]
]

{ #category : #colors }
SystemWindow >> paneColorToUseWhenNotActive [

	^ (self userInterfaceTheme unfocusedWindowColorModifier ifNil: [ [:color | color darker] ])
		value: self paneColorToUse
]

{ #category : #panes }
SystemWindow >> paneMorphSatisfying: aBlock [

	^paneMorphs detect: aBlock ifNone: [ nil ]
]

{ #category : #geometry }
SystemWindow >> paneMorphs [
	"Nominally private but a need for obtaining this from the outside arose"
	^ paneMorphs
]

{ #category : #events }
SystemWindow >> paneTransition: event [
	"Mouse has entered or left a pane"
]

{ #category : #'resize\/collapse' }
SystemWindow >> paneWithLongestSide: sideBlock near: aPoint [ 
	| thePane theSide theLen |
	theLen := 0.
	paneMorphs do:
		[:pane | | box |
		box := pane bounds.
		box forPoint: aPoint closestSideDistLen:
			[:side :dist :len |
			(dist <= 5 and: [len > theLen]) ifTrue:
				[thePane := pane.
				theSide := side.
				theLen := len]]].
	sideBlock value: theSide.
	^ thePane
]

{ #category : #geometry }
SystemWindow >> panelRect [
	"Answer the area below the title bar which is devoted to panes."

	^ self innerBounds insetBy: (0 @ self labelHeight corner: 0 @ 0)
]

{ #category : #focus }
SystemWindow >> passivate [
	"A passive window's contents do not handle user input events until being activated, for example, by a single extra mouse click. There is a preference to configure whether windows can be passive at all. Also see #activate and #lookUnfocused."

	self isActive ifFalse: [^ self].
	self isActive: false.
	
	self isCollapsed ifFalse: [model modelSleep].

	self submorphsDo: [:each | each lock].

	self activeHand keyboardFocus ifNotNil: [:morph |
		morph containingWindow == self
			ifTrue: [self activeHand releaseKeyboardFocus]].

	self lookUnfocused.
]

{ #category : #focus }
SystemWindow >> passivateIfNeeded [

	model windowActiveOnFirstClick
		ifFalse: [self passivate]
		ifTrue: [self lookUnfocused].
	
	self unlockWindowDecorations.
	
	self class windowTitleActiveOnFirstClick
		ifFalse: [self lockWindowTitle]
		ifTrue: [self unlockWindowTitle].
]

{ #category : #geometry }
SystemWindow >> position: newPos [
	super position: newPos.
	isCollapsed
		ifTrue: [collapsedFrame := self bounds]
		ifFalse: [fullFrame := self bounds].

]

{ #category : #'open\/close' }
SystemWindow >> postAcceptBrowseFor: anotherSystemWindow [
	"If I am taking over browsing for anotherSystemWindow, sucblasses may override to, for example, position me to the object to be focused on."
	self model postAcceptBrowseFor: anotherSystemWindow model
]

{ #category : #layout }
SystemWindow >> putLabelItemsInLabelArea [
	"Put label items into the label area, if there is one"

	labelArea ifNotNil:
		[stripes ifNotNil: [stripes do: [:stripe | labelArea addMorph: stripe]].
		closeBox ifNotNil: [labelArea addMorph: closeBox].
		menuBox ifNotNil: [labelArea addMorph: menuBox].
		collapseBox ifNotNil: [labelArea addMorph: collapseBox].
		label ifNotNil: [labelArea addMorph: label]]


]

{ #category : #colors }
SystemWindow >> raisedColor [
	^self paneColor raisedColor
]

{ #category : #'resize\/collapse' }
SystemWindow >> reframePanesAdjoining: growingPane along: side to: aDisplayBox [ 
	| delta newRect minDim theMin horiz |
	growingPane ifNil: [^ self].  "As from click outside"
	newRect := aDisplayBox.
	horiz := #(left right) includes: side.
	theMin := horiz ifTrue: [40] ifFalse: [20].

	"First check that this won't make any pane smaller than theMin screen dots"
	minDim := (((paneMorphs select: [:pane | pane bounds bordersOn: growingPane bounds along: side])
		collect: [:pane | pane bounds adjustTo: newRect along: side]) copyWith: aDisplayBox)
			inject: 999 into:
				[:was :rect | was min: (horiz ifTrue: [rect width] ifFalse: [rect height])].
	"If so, amend newRect as required"
	minDim > theMin ifFalse:
		[delta := minDim - theMin.
		newRect := newRect withSide: side setTo: 
				((newRect perform: side) > (growingPane bounds perform: side)
					ifTrue: [(newRect perform: side) + delta]
					ifFalse: [(newRect perform: side) - delta])].

	"Now adjust all adjoining panes for real"
	paneMorphs do:
		[:pane | (pane bounds bordersOn: growingPane bounds along: side) ifTrue:
			[pane bounds: (pane bounds adjustTo: newRect along: side)]].
	"And adjust the growing pane itself"
	growingPane bounds: newRect.

	"Finally force a recomposition of the whole window"
	self setPaneRectsFromBounds.
	self extent: self extent
]

{ #category : #colors }
SystemWindow >> refreshWindowColor [
	"For changing the underlying model's default window color"
	self setProperty: #paneColor toValue: nil.
	self setWindowColor: self paneColor.

	self isLookingFocused
		ifTrue: [self lookUnfocused; lookFocused]
		ifFalse: [self lookFocused; lookUnfocused].
]

{ #category : #label }
SystemWindow >> relabel [
	| newLabel |
	newLabel := UIManager default 
		request: 'New title for this window' translated
		initialAnswer: labelString.
	newLabel isEmpty ifTrue: [^self].
	(model windowReqNewLabel: newLabel)
		ifTrue: [self setLabel: newLabel]
]

{ #category : #label }
SystemWindow >> relabelEvent: evt [
	"No longer used, but may be referred to by old eventHandlers"

	^ Preferences clickOnLabelToEdit
		ifFalse:	[self mouseDown: evt]
		ifTrue:	[self relabel]
]

{ #category : #polymorph }
SystemWindow >> rememberedKeyboardFocus [
	"Answer the remembered keyboard focus for the receiver."
	
	^self valueOfProperty: #rememberedFocus
]

{ #category : #initialization }
SystemWindow >> removeKeyboardShortcuts [
	
	self removeKeyboardCaptureFilter: self.
]

{ #category : #geometry }
SystemWindow >> removeMenuBox [
	menuBox ifNotNil:
		[menuBox delete.
		menuBox := nil].

]

{ #category : #initialization }
SystemWindow >> replaceBoxes [
	"Rebuild the various boxes."
	self setLabelWidgetAllowance.
	label ifNotNil: [label delete].
	labelArea ifNotNil: [labelArea delete].
	self initializeLabelArea.
	self setFramesForLabelArea.
	self setWindowColor: self paneColor.
	self isActive
		ifTrue: [self passivate; activate]
		ifFalse: [self activate; passivate].
]

{ #category : #panes }
SystemWindow >> replacePane: oldPane with: newPane [
	"Make newPane exactly occupy the position and extent of oldPane"

	| aLayoutFrame hadDep |
	hadDep := model dependents includes: oldPane.
	oldPane owner replaceSubmorph: oldPane by: newPane.
	newPane
		position: oldPane position;
		extent: oldPane extent.
	aLayoutFrame := oldPane layoutFrame.
	paneMorphs := paneMorphs collect:
		[:each |
		each == oldPane ifTrue: [newPane] ifFalse: [each]].
	aLayoutFrame ifNotNil: [newPane layoutFrame: aLayoutFrame].
	hadDep ifTrue: [model removeDependent: oldPane. model addDependent: newPane].

	self changed


]

{ #category : #colors }
SystemWindow >> restoreDefaultPaneColor [
	"Useful when changing from monochrome to color display"

	self setStripeColorsFrom: self paneColor.
]

{ #category : #events }
SystemWindow >> secondaryPaneTransition: event divider: aMorph [
	"Mouse has entered or left a pane"
]

{ #category : #menu }
SystemWindow >> sendToBack [
	| aWorld nextWindow |
	aWorld := self world.
	nextWindow := aWorld submorphs 
				detect: [:m | (m isSystemWindow) and: [m ~~ self]]
				ifNone: [^self].
	nextWindow beKeyWindow.
	aWorld addMorphNearBack: self
]

{ #category : #'resize\/collapse' }
SystemWindow >> setBoundsWithFlex: newFrame [
	"Set bounds from newFrame with origin preserved from global coordinates"

	self isFlexed
		ifTrue: [super bounds: ((owner transform globalPointToLocal: newFrame topLeft)
										extent: newFrame extent)]
		ifFalse: [super bounds: newFrame].
]

{ #category : #initialization }
SystemWindow >> setDefaultParameters [

	Preferences menuAppearance3d
		ifFalse: [self hasDropShadow: false]
		ifTrue: [
			self addDropShadow.
			self hasDropShadow: self isKeyWindow. "maybe turn off again"].
	
	self borderWidth: (self userInterfaceTheme borderWidth ifNil: [1]).
	label font: (self userInterfaceTheme titleFont ifNil: [TextStyle defaultFont]).
]

{ #category : #initialization }
SystemWindow >> setFramesForLabelArea [
	"an aid to converting old instances, but then I found  
	convertAlignment (jesse welton's note)"
	| frame |
	labelArea ifNil: [^ self].	
	labelArea
		layoutPolicy: TableLayout new;
		listDirection: #leftToRight;
		hResizing: #spaceFill;
		layoutInset: 0.
	label hResizing: #spaceFill.
	{closeBox. menuBox. expandBox. collapseBox} do: [:box |
		box ifNotNil: [box extent: self boxExtent]].
	frame := LayoutFrame new.
	frame leftFraction: 0;
		topFraction: 0;
		rightFraction: 1;
		bottomFraction: 0;
		topOffset: self labelHeight negated.
	labelArea layoutFrame: frame
]

{ #category : #label }
SystemWindow >> setLabel: aString [
	| frame |
	labelString := aString.
	label ifNil: [^ self].
	label contents: (aString ifNil: ['']).
	self labelWidgetAllowance.  "Sets it if not already"
	self isCollapsed
		ifTrue: [self extent: (label width + labelWidgetAllowance) @ (self labelHeight + 2)]
		ifFalse: [label fitContents; setWidth: (label width min: self width - labelWidgetAllowance).
				label align: label bounds topCenter with: self topCenter + (0@self borderWidth).
				collapsedFrame ifNotNil:
					[collapsedFrame := collapsedFrame withWidth: label width + labelWidgetAllowance]].
	frame := LayoutFrame new.
	frame leftFraction: 0.5;
		 topFraction: 0.5;
		 leftOffset: label width negated // 2;
		 topOffset: label height negated // 2.
	label layoutFrame: frame.

]

{ #category : #label }
SystemWindow >> setLabelWidgetAllowance [
	^ labelWidgetAllowance :=  (self boxExtent x * 4) + 19
]

{ #category : #geometry }
SystemWindow >> setPaneRectsFromBounds [
	"Reset proportional specs from actual bounds, eg, after reframing panes"
	| layoutBounds |
	layoutBounds := self layoutBounds.
	paneMorphs do:[:m| | box left bottom top frame right |
		frame := m layoutFrame.
		box := m bounds.
		frame ifNotNil:[
			left := box left - layoutBounds left - frame leftOffset.
			right := box right - layoutBounds left - frame rightOffset.
			top := box top - layoutBounds top - frame topOffset.
			bottom := box bottom - layoutBounds top - frame bottomOffset.
			frame leftFraction: (left / layoutBounds width asFloat).
			frame rightFraction: (right / layoutBounds width asFloat).
			frame topFraction: (top / layoutBounds height asFloat).
			frame bottomFraction: (bottom / layoutBounds height asFloat).
		].
	].
]

{ #category : #colors }
SystemWindow >> setStripeColorsFrom: paneColor [ 
	"Set the stripe color based on the given paneColor"

	labelArea ifNotNil: [labelArea color: Color transparent].
	self updateBoxesColor: paneColor.
	stripes ifNil: [^self].

	self borderColor: ((self userInterfaceTheme borderColorModifier ifNil: [ [:c | c adjustBrightness: -0.3] ])
							value: paneColor).

	self class gradientWindow
		ifTrue: [self fillStyle: (self gradientWithColor: paneColor)]
		ifFalse: [self color: paneColor].
]

{ #category : #panes }
SystemWindow >> setUpdatablePanesFrom: getSelectors [
	| aList possibles |
	"Set my updatablePanes inst var to the list of panes which are list panes with the given get-list selectors.  Order is important here!  Note that the method is robust in the face of panes not found, but a warning is printed in the transcript in each such case"

	aList := OrderedCollection new.
	possibles := OrderedCollection new.
	self allMorphsDo: [ :pane | 
		(pane isKindOf: PluggableListMorph) ifTrue: [
			possibles add: pane.
		].
	].

	getSelectors do: [:sel | | aPane | 
		aPane := possibles detect: [ :pane | pane getListSelector == sel] ifNone: [nil].
		aPane
			ifNotNil:
				[aList add: aPane]
			ifNil:
				[Transcript cr; show: 'Warning: pane ', sel, ' not found.']].
	updatablePanes := aList asArray
]

{ #category : #menu }
SystemWindow >> setWindowColor [
	"Allow the user to select a new basic color for the window"
	NewColorPickerMorph useIt
		ifTrue:
			[ (NewColorPickerMorph
				on: self
				originalColor: self paneColorToUse
				setColorSelector: #setWindowColor:) openNear: self fullBounds ]
		ifFalse:
			[ ColorPickerMorph new
				 choseModalityFromPreference ;
				 sourceHand: self activeHand ;
				 target: self ;
				 selector: #setWindowColor: ;
				 originalColor: self paneColorToUse ;
				
				putUpFor: self
				near: self fullBounds ]
]

{ #category : #colors }
SystemWindow >> setWindowColor: incomingColor [
	| existingColor aColor |
	incomingColor ifNil: [^ self].  "it happens"
	aColor := incomingColor.
	(aColor = ColorPickerMorph perniciousBorderColor 
		or: [aColor = Color black]) ifTrue: [^ self].
	existingColor := self paneColorToUse.
	existingColor ifNil: [^ Beeper beep].
	self paneColor: aColor.
	self setStripeColorsFrom: aColor.
	self changed.
]

{ #category : #testing }
SystemWindow >> shouldDropOnMouseUp [
	"Return true for consistency with fastdrag"
	^true
]

{ #category : #events }
SystemWindow >> startDragFromLabel: evt [
	"When label events are active, we need to pass dragging to the window explicitely
	 The window only recognizes a drag with an offset of more than 3 pixels"
	
	self isSticky ifTrue: [^ self].
	self fastFramingOn 
		ifTrue: [self doFastFrameDrag: evt cursorPoint]
		ifFalse: [
			self hasDropShadow: false.
			evt hand grabMorph: self topRendererOrSelf]

]

{ #category : #stepping }
SystemWindow >> stepAt: millisecondClockValue [
	"If the receiver is not collapsed, step it, after first stepping the model."

	(isCollapsed not or: [self wantsStepsWhenCollapsed]) ifTrue:
		[model ifNotNil: [model stepAt: millisecondClockValue in: self].
		super stepAt: millisecondClockValue "let player, if any, step"]

"Since this method ends up calling step, the model-stepping logic should not be duplicated there."
]

{ #category : #stepping }
SystemWindow >> stepTime [
	^ model
		ifNotNil:
			[model stepTimeIn: self]
		ifNil:
			[200] "milliseconds"
]

{ #category : #menu }
SystemWindow >> takeOutOfWindow [
	"Take the receiver's pane morph out the window and place it, naked, where once the window was"
	| aMorph |
	paneMorphs size = 1 ifFalse: [^ Beeper beep].
	aMorph := paneMorphs first.
	owner addMorphFront: aMorph.
	self delete
]

{ #category : #panes }
SystemWindow >> titleAndPaneText [
	"If the receiver represents a workspace, return an Association between the title and that text, else return nil"
	(paneMorphs size ~= 1 or: [(paneMorphs first isKindOf: PluggableTextMorph) not])
		ifTrue: [^ nil].
	^ labelString -> paneMorphs first text


]

{ #category : #label }
SystemWindow >> tryToRenameTo: newLabel [
	"Triggered eg by typing a new name in the halo"

	newLabel isEmpty ifTrue: [^self].
	(model windowReqNewLabel: newLabel)
		ifTrue: [self setLabel: newLabel]
	
]

{ #category : #'top window' }
SystemWindow >> undimWindowButtons [
	{closeBox. collapseBox. menuBox. expandBox}
		do: [:b | b ifNotNil: [b undim]]
]

{ #category : #'resize\/collapse' }
SystemWindow >> unexpandedFrame [
	"Return the frame size of an unexpanded window"

	^ self valueOfProperty: #unexpandedFrame
]

{ #category : #'resize\/collapse' }
SystemWindow >> unexpandedFrame: aRectangle [
	"Set the frame size of an unexpanded window"

	^ self setProperty: #unexpandedFrame toValue: aRectangle
]

{ #category : #focus }
SystemWindow >> unlockWindowDecorations [
	"Unlock all window decrations, that is grips, splitters, and title bar."
	
	self windowDecorations do: [:m | m unlock].
	
	"Migrate old window instances. Can be removed in the future."
	labelArea ifNotNil: [:m | m submorphsDo: [:sm | sm unlock]].
]

{ #category : #focus }
SystemWindow >> unlockWindowTitle [
	
	labelArea ifNotNil: [:m | m unlock].
]

{ #category : #panes }
SystemWindow >> updatablePanes [
	"Answer the list of panes, in order, which should be sent the #verifyContents message"
	^ updatablePanes ifNil: [updatablePanes := #()]
]

{ #category : #label }
SystemWindow >> update: aSymbol [
	aSymbol = #relabel
		ifTrue: [^ model ifNotNil: [ self setLabel: model labelString ] ].
	aSymbol = #close
		ifTrue: [self delete]
]

{ #category : #panes }
SystemWindow >> updateBox: anIconMorph color: aColor [ 

	| fill |
	anIconMorph isNil
		ifTrue: [^ self].
	anIconMorph
		extent: self boxExtent;
		useRoundedCorners.

	SystemWindow gradientWindow
		ifFalse: [anIconMorph color: aColor]
		ifTrue: [	
			fill := GradientFillStyle ramp: {
				0.0 -> aColor muchLighter muchLighter.
				1.0 -> aColor twiceDarker}.
			fill origin: anIconMorph topLeft + (5 @ 5).
			fill direction: anIconMorph extent.
			anIconMorph fillStyle: fill].

	anIconMorph
		borderWidth: (Preferences alternativeWindowBoxesLook
			ifTrue: [1]
			ifFalse: [0]);
		borderColor: aColor darker.
]

{ #category : #panes }
SystemWindow >> updateBoxesColor: aColor [ 
	| opaqueColor |
	aColor isNil
		ifTrue: [^ self].
	Preferences alternativeWindowBoxesLook ifFalse:[^ self].
	
	opaqueColor := aColor asNontranslucentColor.
	
	self
		updateBox: closeBox
		color: (opaqueColor alphaMixed: 0.5 with: Color red).
	self updateBox: menuBox color: opaqueColor.
	self updateBox: expandBox color: opaqueColor.
	self updateBox: collapseBox color: opaqueColor
]

{ #category : #focus }
SystemWindow >> updateFocusLookAtHand [
	"If there is more than one active window, look for the mouse cursor and update the window focus look accordingly. This method is not on the class-side because we need our world and some active hand."
	
	(model windowActiveOnFirstClick and: [Preferences mouseOverForKeyboardFocus])
		ifFalse: [self updateFocusLookForKeyboardFocus]
		 ifTrue: [
			((self class windowsIn: self world)
				do: [:window | window lookUnfocused];
				select: [:window | window bounds containsPoint: self activeHand position])
					ifNotEmpty: [:windowsPointed | windowsPointed first lookFocused "only to foremost window"]].
]

{ #category : #focus }
SystemWindow >> updateFocusLookForKeyboardFocus [
	"Ensure that the window holding the current keyboard focus looks focused. Note that the focus window is not necessarily the receiver of this message."

	| f w |
	(((f := self activeHand keyboardFocus) notNil and: [(w := f containingWindow) notNil])
		and: [w isActive])
			ifTrue: [
				(self class windowsIn: self world) do: [:window |
					w ~~ window ifTrue: [window lookUnfocused]].
				w lookFocused]
]

{ #category : #colors }
SystemWindow >> updatePaneColors [
	"Useful when changing from monochrome to color display"

	self setStripeColorsFrom: self paneColorToUse.
]

{ #category : #'top window' }
SystemWindow >> updatePanesFromSubmorphs [
	"Having removed some submorphs, make sure this is reflected in my paneMorphs."
	paneMorphs := paneMorphs select: [ :pane | submorphs includes: pane ].
]

{ #category : #'resize\/collapse' }
SystemWindow >> wantsExpandBox [
	"Answer whether I'd like an expand box"

	^ Preferences alwaysHideExpandButton not
]

{ #category : #events }
SystemWindow >> wantsHalo [
	^ false
]

{ #category : #drawing }
SystemWindow >> wantsRoundedCorners [
	
	^ (self hasProperty: #cornerStyle)
		ifTrue: [super wantsRoundedCorners]
		ifFalse: [self class roundedWindowCorners]
]

{ #category : #stepping }
SystemWindow >> wantsSteps [
	"Return true if the model wants its view to be stepped.  For an open system window, we give the model to offer an opinion"

	self isPartsDonor ifTrue: [^ false].
	self player wantsSteps ifTrue: [^ true].
	^ isCollapsed not and: [model wantsStepsIn: self]
]

{ #category : #stepping }
SystemWindow >> wantsStepsWhenCollapsed [
	"Default is not to bother updating collapsed windows"

	^ false
]

{ #category : #testing }
SystemWindow >> wantsToBeCachedByHand [
	"Return true if the receiver wants to be cached by the hand when it is dragged around."
	self hasTranslucentColor ifTrue:[^false].
	self bounds = self fullBounds ifTrue:[^true].
	self submorphsDo:[:m|
		(self bounds containsRect: m fullBounds) ifFalse:[
			m wantsToBeCachedByHand ifFalse:[^false].
		].
	].
	^true
]

{ #category : #events }
SystemWindow >> wantsToBeDroppedInto: aMorph [
	"Return true if it's okay to drop the receiver into aMorph"
	^ (aMorph isWorldMorph or:[Preferences systemWindowEmbedOK])
		and: [aMorph isDockingBar not]
]

{ #category : #menu }
SystemWindow >> wantsYellowButtonMenu [
	"Answer true if the receiver wants a yellow button menu"
	^ false
]

{ #category : #label }
SystemWindow >> widthOfFullLabelText [
	^Preferences windowTitleFont widthOfString: labelString
]

{ #category : #focus }
SystemWindow >> windowDecorations [
	
	^ self submorphs copyWithoutAll: self paneMorphs
]
