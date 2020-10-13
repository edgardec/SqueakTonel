"
A general mechanism to store preference choices.  The default setup treats any symbol as a potential boolean flag; flags unknown to the preference dictionary are always answered as false.  

	To open the control panel:
		PreferenceBrowser open
	To read how to use the panel (and how to make a preference be per-project):
		 Preferences giveHelpWithPreferences

All messages are on the class side.  There are two kinds of preference definition, preference pragmas (which are preferred) and  preferences local to Preferences.

Preference Pragmas
Preferences can be local to a class or system of classes using preference pragmas.  Look at senders of #preference:category:description:type: and #preference:categoryList:description:type: for examples:
	(self systemNavigation browseAllSelect:
		[:m|
		#(preference:category:description:type: preference:categoryList:description:type:) anySatisfy:
			[:s| (m pragmaAt: s) notNil]])
With a preference pragma, the preference is typically kept in a class variable, local to the class whose method(s) contain(s) the pragma.  Good style is to put the preference pragma in the accessor for the variable; see for example BitBlt class>>#subPixelRenderColorFonts. The pragma serves to declare the preference to Preferences.


Preference-local Preferences
To query a a preference:
	Preferences logDebuggerStackToFile
or some people prefer the more verbose
	Preferences valueOfFlag: #logDebuggerStackToFile

You can make up a new preference any time.  Do not define a new message in Preferences class. Accessor methods are compiled automatically when you add a preference, either as as illustrated below, or by using 

To add a non-pragma preference (e.g. in the Postscript of a fileout):
	Preferences
		addPreference: #samplePreference
		categories: #(general browsing)
		default: true
		balloonHelp: 'This is an example of a preference added by a do-it'
		projectLocal: false
		changeInformee: nil
		changeSelector: nil.

To change a preference programatically:
	Preferences disable: #logDebuggerStackToFile.
Or to turn it on,
	Preferences enable: #logDebuggerStackToFile.

"
Class {
	#name : #Preferences,
	#superclass : #Object,
	#classVars : [
		'DesktopColor',
		'Parameters'
	],
	#classInstVars : [
		'preferencesDictionary'
	],
	#category : #'System-Preferences'
}

{ #category : #'prefs - fonts' }
Preferences class >> aaFontsColormapDepth [
	"Adjust balance between colored AA text quality (especially if subpixel AA is used) and space / performance.
	5 is optimal quality. Each colorMap takes 128kB of RAM, and takes several seconds to build.
	4 is a reasonable balance. Each colorMap takes 16kB of RAM and builds fast on a fast machine.
	3 is good for slow hardware or memory restrictions. Each colorMap takes 2 kb of RAM."
	^self
		valueOfFlag: #aaFontsColormapDepth
		ifAbsent: [4]
]

{ #category : #'standard queries' }
Preferences class >> abbreviatedBrowserButtons [
	^ self
		valueOfFlag: #abbreviatedBrowserButtons
		ifAbsent: [ false ]
]

{ #category : #'support - misc' }
Preferences class >> acceptAnnotationsFrom: aSystemWindow [
	"This intricate extraction is based on the precise structure of the annotation-request window.  Kindly avert your eyes."
	| aList |
	aList := aSystemWindow paneMorphs first firstSubmorph submorphs collect:
		[:m |  m contents asSymbol].
	self defaultAnnotationRequests: aList
	
]

{ #category : #'add\/remove - specific' }
Preferences class >> addBooleanPreference: prefSymbol categories: categoryList default: defaultValue balloonHelp: helpString [ 
	"Add an item repreesenting the given preference symbol to the system. Default view for this preference is boolean to keep backward compatibility"

	^ self addPreference: prefSymbol  categories: categoryList  default:  defaultValue balloonHelp: helpString  projectLocal: false  changeInformee: nil changeSelector: nil type: #Boolean
]

{ #category : #'add\/remove - specific' }
Preferences class >> addBooleanPreference: prefSymbol category: categorySymbol default: defaultValue balloonHelp: helpString [ 
	"Add an item repreesenting the given preference symbol to the system. Default view for this preference is boolean to keep backward compatibility"

	^ self addPreference: prefSymbol  categories: {categorySymbol} default:  defaultValue balloonHelp: helpString  projectLocal: false  changeInformee: nil changeSelector: nil type: #Boolean
]

{ #category : #'add\/remove - specific' }
Preferences class >> addColorPreference: prefSymbol categories: categoryList default: defaultValue balloonHelp: helpString [ 
	"Add an item repreesenting the given preference symbol to the system. Default view for this preference is boolean to keep backward compatibility"

	^ self addPreference: prefSymbol  categories: categoryList  default:  defaultValue balloonHelp: helpString  projectLocal: false  changeInformee: nil changeSelector: nil type: #Color
]

{ #category : #'add\/remove - specific' }
Preferences class >> addColorPreference: prefSymbol category: categorySymbol default: defaultValue balloonHelp: helpString [ 
	"Add an item repreesenting the given preference symbol to the system. Default view for this preference is boolean to keep backward compatibility"

	^ self addPreference: prefSymbol  categories: {categorySymbol} default:  defaultValue balloonHelp: helpString  projectLocal: false  changeInformee: nil changeSelector: nil type: #Color
]

{ #category : #'add\/remove - specific' }
Preferences class >> addFontPreference: prefSymbol categories: categoryList default: defaultValue balloonHelp: helpString [ 
	"Add an item repreesenting the given preference symbol to the system. Default view for this preference is boolean to keep backward compatibility"

	^ self addPreference: prefSymbol  categories: categoryList  default:  defaultValue balloonHelp: helpString  projectLocal: false  changeInformee: nil changeSelector: nil type: #Font
]

{ #category : #'add\/remove - specific' }
Preferences class >> addFontPreference: prefSymbol category: categorySymbol default: defaultValue balloonHelp: helpString [ 
	"Add an item repreesenting the given preference symbol to the system. Default view for this preference is boolean to keep backward compatibility"

	^ self addPreference: prefSymbol  categories: {categorySymbol} default:  defaultValue balloonHelp: helpString  projectLocal: false  changeInformee: nil changeSelector: nil type: #Font
]

{ #category : #'support - misc' }
Preferences class >> addModelItemsToWindowMenu: aMenu [
	aMenu addLine.
	aMenu add: 'restore default preference settings' target: self action: #chooseInitialSettings.
]

{ #category : #'add\/remove - specific' }
Preferences class >> addNumericPreference: prefSymbol categories: categoryList default: defaultValue balloonHelp: helpString [ 
	"Add an item repreesenting the given preference symbol to the system. "

	^ self addPreference: prefSymbol  categories: categoryList  default:  defaultValue balloonHelp: helpString  projectLocal: false  changeInformee: nil changeSelector: nil type: #Number
]

{ #category : #'add\/remove - specific' }
Preferences class >> addNumericPreference: prefSymbol category: categorySymbol default: defaultValue balloonHelp: helpString [ 
	"Add an item repreesenting the given preference symbol to the system."

	^ self addPreference: prefSymbol  categories: {categorySymbol} default:  defaultValue balloonHelp: helpString  projectLocal: false  changeInformee: nil changeSelector: nil type: #Number
]

{ #category : #'add\/remove' }
Preferences class >> addPragmaPreference: pragma [
	"Note that there will be no accessor method generated because the pragma's method does already govern that."
	
	| preference |
	
	((pragma keyword beginsWith: #preference:) and: [self respondsTo: pragma keyword])
		ifFalse: [
			"no pragma pref to be defined. do nothing"
			^ self].
	self assert: pragma methodClass isMeta.
	
	preference := self
		perform: pragma keyword
		withArguments: pragma arguments.
			
	preference 
		provider: pragma methodClass theNonMetaClass
		getter: pragma method selector 
		setter: pragma method selector asSimpleSetter.
			
	self atomicUpdatePreferences: [ :copyOfDictionaryOfPreferences |
		copyOfDictionaryOfPreferences
			at: preference id
			put: preference].

	^ preference
]

{ #category : #'add\/remove - convenience' }
Preferences class >> addPreference: prefSymbol categories: categoryList default: defaultValue balloonHelp: helpString [ 
	"Add an item repreesenting the given preference symbol to the system."

	^ self
		addPreference: prefSymbol
		categories: categoryList
		default: defaultValue
		balloonHelp: helpString
		projectLocal: false
		changeInformee: nil
		changeSelector: nil
]

{ #category : #'add\/remove - convenience' }
Preferences class >> addPreference: prefSymbol categories: categoryList default: aValue balloonHelp: helpString projectLocal: localBoolean changeInformee: informeeSymbol  changeSelector: aChangeSelector [
	"Add an item representing the given preference symbol to the system."

	^ self
		addPreference: prefSymbol
		categories: categoryList
		default: aValue
		balloonHelp: helpString
		projectLocal: localBoolean
		changeInformee: informeeSymbol
		changeSelector: aChangeSelector
		type: (self typeForValue: aValue)

]

{ #category : #'add\/remove' }
Preferences class >> addPreference: aName categories: categoryList default: aValue balloonHelp: helpString projectLocal: localBoolean changeInformee: informeeSymbol changeSelector: aChangeSelector type: aType [
	"Add or replace a preference as indicated.  Reuses the preexisting Preference object for this symbol, if there is one, so that UI artifacts that interact with it will remain valid."

	| newPreference aPreference |
	newPreference := Preference new
		name: aName asSymbol
		defaultValue: aValue
		helpString: helpString
		localToProject: localBoolean
		categoryList: categoryList
		changeInformee: informeeSymbol
		changeSelector: aChangeSelector
		type: aType;
		yourself.
	aPreference := preferencesDictionary
						 at: newPreference name
						 ifAbsent: [newPreference].
	aPreference == newPreference
		ifTrue: "Atomically add the new preference to the dictionary."
			[self atomicUpdatePreferences:
				[:preferenceDictionaryCopy|
				preferenceDictionaryCopy at: newPreference name put: newPreference]]
		ifFalse: "Use the copyFrom: primitive to atomically update the existing preference."
			[aPreference copyFrom: newPreference].
	self compileAccessorForPreference: aPreference.

	^ aPreference
]

{ #category : #'add\/remove - convenience' }
Preferences class >> addPreference: prefSymbol category: categorySymbol default: defaultValue [
	"Add the given preference, putting it in the given category, with the given default value, and with the given balloon help."

	^ self
		addPreference: prefSymbol
		category: categorySymbol
		default: defaultValue
		balloonHelp: nil.
]

{ #category : #'add\/remove - convenience' }
Preferences class >> addPreference: prefSymbol category: categorySymbol default: defaultValue balloonHelp: helpString [ 
	"Add the given preference, putting it in the given category, with the given default value, and with the given balloon help."

	^ self
		addPreference: prefSymbol
		categories: {categorySymbol}
		default: defaultValue
		balloonHelp: helpString.
]

{ #category : #'add\/remove - convenience' }
Preferences class >> addPreference: prefSymbol default: defaultValue [

	^ self
		addPreference: prefSymbol
		category: self unclassifiedCategory
		default: defaultValue
		balloonHelp: nil.
]

{ #category : #'add\/remove - specific' }
Preferences class >> addTextPreference: prefSymbol categories: categoryList default: defaultValue balloonHelp: helpString [ 
	"Add an item repreesenting the given preference symbol to the system. Default view for this preference is boolean to keep backward compatibility"

	^ self addPreference: prefSymbol  categories: categoryList  default:  defaultValue balloonHelp: helpString  projectLocal: false  changeInformee: nil changeSelector: nil type: #String
]

{ #category : #'add\/remove - specific' }
Preferences class >> addTextPreference: prefSymbol category: categorySymbol default: defaultValue balloonHelp: helpString [ 
	"Add an item repreesenting the given preference symbol to the system. Default view for this preference is boolean to keep backward compatibility"

	^ self addPreference: prefSymbol  categories: {categorySymbol} default:  defaultValue balloonHelp: helpString  projectLocal: false  changeInformee: nil changeSelector: nil type: #String
]

{ #category : #accessing }
Preferences class >> allPreferences [

	^preferencesDictionary values reject: [:pref | pref isDeprecated]
]

{ #category : #'standard queries' }
Preferences class >> alphabeticalProjectMenu [
	^ self
		valueOfFlag: #alphabeticalProjectMenu
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> alternateHandlesLook [
	^ self
		valueOfFlag: #alternateHandlesLook
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> alternativeBrowseIt [
	^ self
		valueOfFlag: #alternativeBrowseIt
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> alternativeButtonsInScrollBars [
	^ self
		valueOfFlag: #alternativeButtonsInScrollBars
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> alternativeWindowBoxesLook [
	^ self
		valueOfFlag: #alternativeWindowBoxesLook
		ifAbsent: [true]
]

{ #category : #'standard queries' }
Preferences class >> alwaysHideHScrollbar [
	^ self
		valueOfFlag: #alwaysHideHScrollbar
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> alwaysShowConnectionVocabulary [
	^ self
		valueOfFlag: #alwaysShowConnectionVocabulary
		ifAbsent: [false]
]

{ #category : #'standard queries' }
Preferences class >> alwaysShowHScrollbar [
	^ self
		valueOfFlag: #alwaysShowHScrollbar
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> alwaysShowVScrollbar [
	^ self
		valueOfFlag: #alwaysShowVScrollbar
		ifAbsent: [ true ]
]

{ #category : #'support - misc' }
Preferences class >> annotationEditingWindow [
	"Answer a window affording editing of annotations"
	| aPanel ins outs current aWindow aButton info standardHeight standardWidth |
	standardHeight := 200.
	standardWidth := (2 sqrt reciprocal * standardHeight) rounded.
	Smalltalk isMorphic
		ifFalse: [self error: 'annotations can be edited only in morphic'].
	aPanel := AlignmentMorph newRow extent: 2 * standardWidth @ standardHeight.
	ins := AlignmentMorph newColumn extent: standardWidth @ standardHeight.
	ins color: Color green muchLighter.
	ins enableDrop: true;
		 beSticky.
	outs := AlignmentMorph newColumn extent: standardWidth @ standardHeight.
	outs color: Color red muchLighter.
	outs enableDrop: true;
		 beSticky.
	aPanel addMorph: outs;
		 addMorphFront: ins.
	outs position: ins position + (standardWidth @ 0).
	current := self defaultAnnotationRequests.
	info := self annotationInfo.
	current
		do: [:sym | | pair aMorph | 
			pair := info
						detect: [:aPair | aPair first == sym].
			aMorph := StringMorph new contents: pair first.
			aMorph setBalloonText: pair last.
			aMorph enableDrag: true.
			aMorph
				on: #startDrag
				send: #startDrag:with:
				to: aMorph.
			ins addMorphBack: aMorph].
	info
		do: [:aPair | (current includes: aPair first)
				ifFalse: [| aMorph |
					aMorph := StringMorph new contents: aPair first.
					aMorph setBalloonText: aPair last.
					aMorph enableDrag: true.
					aMorph
						on: #startDrag
						send: #startDrag:with:
						to: aMorph.
					outs addMorph: aMorph]].
	aPanel layoutChanged.
	aWindow := SystemWindowWithButton new setLabel: 'Annotations'.
	aButton := SimpleButtonMorph new target: Preferences;
				 actionSelector: #acceptAnnotationsFrom:;
				
				arguments: (Array with: aWindow);
				 label: 'apply';
				 borderWidth: 0;
				 borderColor: Color transparent;
				 color: Color transparent.
	aButton submorphs first color: Color blue.
	aButton setBalloonText: 'After moving all the annotations you want to the left (green) side, and all the ones you do NOT want to the right (pink) side, hit this "apply" button to have your choices take effect.'.
	aWindow buttonInTitle: aButton;
		 adjustExtraButton.
	^ aPanel wrappedInWindow: aWindow"Preferences annotationEditingWindow openInHand"
]

{ #category : #'prefs - annotations' }
Preferences class >> annotationInfo [ 
	"Answer a list of pairs characterizing all the available kinds of annotations; in each pair, the first element is a symbol representing the info type, and the second element is a string providing the corresponding balloon help"

	^ #(

		(timeStamp			'The time stamp of the last submission of the method.')
		(firstComment		'The first comment in the method, if any.')
		(masterComment		'The comment at the beginning of the supermost implementor of the method if any.')
		(documentation		'Comment at beginning of the method or, if it has none, comment at the beginning of a superclass''s implementation of the method')
		(messageCategory	'Which method category the method lies in')
		(sendersCount		'A report of how many senders there of the message.')
		(implementorsCount	'A report of how many implementors there are of the message.')
		(recentChangeSet	'The most recent change set bearing the method.')
		(allChangeSets		'A list of all change sets bearing the method.')
		(priorVersionsCount	'A report of how many previous versions there are of the method' )
		(priorTimeStamp		'The time stamp of the penultimate submission of the method, if any'))
]

{ #category : #'standard queries' }
Preferences class >> annotationPanes [
	^ self
		valueOfFlag: #annotationPanes
		ifAbsent: [true]
]

{ #category : #'updating - system' }
Preferences class >> annotationPanesChanged [
	"The setting of the annotationPanes preference changed; react.  Formerly, we replaced prototypes in flaps but this is no longer necessary"
]

{ #category : #'standard queries' }
Preferences class >> areaFillsAreTolerant [
	^ self
		valueOfFlag: #areaFillsAreTolerant
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> areaFillsAreVeryTolerant [
	^ self
		valueOfFlag: #areaFillsAreVeryTolerant
		ifAbsent: [ false ]
]

{ #category : #accessing }
Preferences class >> atomicUpdatePreferences: aBlock [ 
	"Evaluate aBlock with a copy of the preferences dictionary and
	then assign (assignment is atomic) the copy to the dictionary."

	[
		| originalPreferences copyOfPreferences |
		originalPreferences := preferencesDictionary.
		copyOfPreferences := preferencesDictionary
			ifNil: [ IdentityDictionary new ]
			ifNotNil: [ :dictionary | dictionary copy ].
		aBlock value: copyOfPreferences.
		originalPreferences == preferencesDictionary ifTrue: [
	 		preferencesDictionary := copyOfPreferences.
			^self ] ] repeat
]

{ #category : #'prefs - fonts' }
Preferences class >> attemptToRestoreClassicFonts [
	"If certain fonts formerly used in early versions of Squeak happen to be present in the image, restore them to their corresponding roles.  Not called by any other method -- intended to be invoked via do-it, possibly in a postscript"
	"Preferences attemptToRestoreClassicFonts"

	
	self setDefaultFonts: #(	(setButtonFontTo:		NewYork		12)
		(setCodeFontTo:			NewYork		12)
		(setFlapsFontTo:			ComicBold		16)
		(setEToysFontTo:			ComicBold		16)
		(setListFontTo:			NewYork		12)
		(setMenuFontTo:			NewYork		12)
		(setWindowTitleFontTo:	NewYork		15)
		(setSystemFontTo:		NewYork		12)) .
]

{ #category : #'standard queries' }
Preferences class >> autoIndent [
	^ self
		valueOfFlag: #autoIndent
		ifAbsent: [true]
]

{ #category : #'standard queries' }
Preferences class >> automaticFlapLayout [
	^ self
		valueOfFlag: #automaticFlapLayout
		ifAbsent: [ true ]
]

{ #category : #'support - misc' }
Preferences class >> automaticFlapLayoutString [
	"Answer a string for the automaticFlapLayout menu item"
	^ (self automaticFlapLayout
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		, 'automatic flap layout' translated
]

{ #category : #'standard queries' }
Preferences class >> automaticKeyGeneration [
	^ self
		valueOfFlag: #automaticKeyGeneration
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> automaticPlatformSettings [
	^ self
		valueOfFlag: #automaticPlatformSettings
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> automaticViewerPlacement [
	^ self
		valueOfFlag: #automaticViewerPlacement
		ifAbsent: [ true ]
]

{ #category : #'prefs - misc' }
Preferences class >> balloonHelpDelayTime [
	"Answer the number of milliseconds before a balloon help 
	should be put up on morphs."
	^ Parameters
		at: #balloonHelpDelayTime
		ifAbsent: [800]
]

{ #category : #'standard queries' }
Preferences class >> balloonHelpEnabled [
	^ self
		valueOfFlag: #balloonHelpEnabled
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> balloonHelpInMessageLists [
	^ self
		valueOfFlag: #balloonHelpInMessageLists
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> batchPenTrails [
	^ self
		valueOfFlag: #batchPenTrails
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> biggerHandles [
	^ self
		valueOfFlag: #biggerHandles
		ifAbsent: [ true ]
]

{ #category : #'prefs - misc' }
Preferences class >> borderColorWhenRunning [
	^ Color green
]

{ #category : #'themes - tools' }
Preferences class >> browseThemes [
	"Open up a message-category browser on the theme-defining methods"
	ToolSet browse: Preferences class selector: #outOfTheBox.
]

{ #category : #'standard queries' }
Preferences class >> capitalizedReferences [
	^ self
		valueOfFlag: #capitalizedReferences
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> caseSensitiveFinds [
	^ self
		valueOfFlag: #caseSensitiveFinds
		ifAbsent: [ false ]
]

{ #category : #support }
Preferences class >> categoryList [
	"Return all available categories. No duplicates."

	| aSet |
	aSet := Set new.
	self allPreferences do: [ :aPreference | 
		aSet addAll: (
			aPreference categoryList collect: [ :aCategory |
				aCategory asSymbol ]) ].
	
	aSet add: self unclassifiedCategory.
	
	^aSet
]

{ #category : #support }
Preferences class >> categoryListOfPreference: prefSymbol [
	"Return a list of all categories in which the preference occurs"

	^ (self preferenceAt: prefSymbol ifAbsent: [^ Error signal: 'Preference not found!']) categoryList
]

{ #category : #'standard queries' }
Preferences class >> cautionBeforeClosing [
	^ self
		valueOfFlag: #cautionBeforeClosing
		ifAbsent: [ false ]
]

{ #category : #'prefs - fonts' }
Preferences class >> changeFontSize: delta [
	| theme base fonts |
	delta = 0 ifTrue: [self restoreDefaultFonts].
	(UserInterfaceTheme current name beginsWith: 'Demo')
		ifFalse: [
			"Create DEMO version of current theme."
			theme := UserInterfaceTheme named: 'Demo'.
			theme merge: UserInterfaceTheme current overwrite: true.
			theme apply].

	base := (TextStyle defaultFont name beginsWith: 'Darkmap')
		ifTrue: ['Darkmap DejaVu Sans'] ifFalse: ['Bitmap DejaVu Sans'].

	fonts := {
		{#SystemFont. base}.
		{#FixedFont. 'BitstreamVeraSansMono'}.
		{#ListFont. base}.
		{#FlapFont. base}.
		{#EToysFont. base}.
		{#PaintBoxButtonFont. base}.
		{#MenuFont. base}.
		{#WindowTitleFont. base, ' B'}.
		{#BalloonHelpFont. base}.
		{#CodeFont. base}.
		{#ButtonFont. base}.
	} collect: [:ary || newPtSize |
		newPtSize := (self perform: ('standard', ary first) asSymbol) pointSize + delta.
		{('set', ary first, 'To:') asSymbol. ary second. newPtSize}
	].
	self setDefaultFonts: fonts.

]

{ #category : #'standard queries' }
Preferences class >> changeSetVersionNumbers [
	^ self
		valueOfFlag: #changeSetVersionNumbers
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> checkForSlips [
	^ self
		valueOfFlag: #checkForSlips
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> checkForUnsavedProjects [
	^ self
		valueOfFlag: #checkForUnsavedProjects
		ifAbsent: [ true ]
]

{ #category : #'prefs - fonts' }
Preferences class >> chooseBalloonHelpFont [

	BalloonMorph chooseBalloonFont
]

{ #category : #'prefs - fonts' }
Preferences class >> chooseCodeFont [
	"Not currently sent, but once protocols are sorted out so that we can disriminate on whether a text object being launched is for code or not, will be reincorporated"

	self 
		chooseFontWithPrompt: 'Code font...' translated 
		andSendTo: self 
		withSelector: #setCodeFontTo: 
		highlightSelector: #standardCodeFont.
]

{ #category : #'prefs - fonts' }
Preferences class >> chooseEToysFont [
	"present a menu with the possible fonts for the eToys"
	self
		chooseFontWithPrompt: 'eToys font...' translated
		andSendTo: self
		withSelector: #setEToysFontTo:
		highlightSelector: #standardEToysFont
]

{ #category : #'prefs - fonts' }
Preferences class >> chooseEToysTitleFont [
	"present a menu with the possible fonts for the eToys"
	self
		chooseFontWithPrompt: 'eToys Title font...' translated
		andSendTo: self
		withSelector: #setEToysTitleFontTo:
		highlightSelector: #standardEToysTitleFont
]

{ #category : #'prefs - fonts' }
Preferences class >> chooseFixedFont [
	self 
		chooseFontWithPrompt: 'Default fixed font...' translated
		andSendTo: self 
		withSelector: #setFixedFontTo: 
		highlightSelector: #standardFixedFont
]

{ #category : #'prefs - fonts' }
Preferences class >> chooseFlapsFont [
	self 
		chooseFontWithPrompt: 'Flaps font...' translated
		andSendTo: self 
		withSelector: #setFlapsFontTo: 
		highlightSelector: #standardFlapFont
]

{ #category : #'prefs - fonts' }
Preferences class >> chooseFontWithPrompt: aPrompt andSendTo: aReceiver withSelector: aSelector highlightSelector: highlightSelector [
	^UIManager default 
			chooseFont: aPrompt 
			for: aReceiver 
			setSelector: aSelector
			getSelector: highlightSelector 
]

{ #category : #'prefs - fonts' }
Preferences class >> chooseHaloLabelFont [
	"present a menu with the possible fonts for label in halo"
	self
		chooseFontWithPrompt: 'Halo Label font...'
		andSendTo: self
		withSelector: #setHaloLabelFontTo:
		highlightSelector: #standardHaloLabelFont
]

{ #category : #initialization }
Preferences class >> chooseInitialSettings [
	"Restore the default choices for all of the standard Preferences."

	self allPreferences do: [:aPreference |
		aPreference restoreDefaultValue].
	Project current installProjectPreferences
]

{ #category : #'prefs - fonts' }
Preferences class >> chooseListFont [
	self 
		chooseFontWithPrompt: 'List font...' translated
		andSendTo: self 
		withSelector: #setListFontTo: 
		highlightSelector: #standardListFont
]

{ #category : #'prefs - fonts' }
Preferences class >> chooseMenuFont [
	self 
		chooseFontWithPrompt: 'Menu font...' translated
		andSendTo: self 
		withSelector: #setMenuFontTo: 
		highlightSelector: #standardMenuFont
]

{ #category : #'prefs - fonts' }
Preferences class >> chooseStandardButtonFont [
	self 
		chooseFontWithPrompt: 'Button font...' translated
		andSendTo: self 
		withSelector: #setButtonFontTo: 
		highlightSelector: #standardButtonFont


]

{ #category : #'prefs - fonts' }
Preferences class >> chooseSystemFont [
	self 
		chooseFontWithPrompt: 'Default font...' translated
		andSendTo: self 
		withSelector: #setSystemFontTo: 
		highlightSelector: #standardSystemFont
]

{ #category : #'prefs - fonts' }
Preferences class >> chooseWindowTitleFont [
	self 
		chooseFontWithPrompt: 'Window Title font...' translated
		andSendTo: self 
		withSelector: #setWindowTitleFontTo: 
		highlightSelector: #windowTitleFont
]

{ #category : #'prefs - halos' }
Preferences class >> classicHaloSpecs [
	"Non-iconic halos with traditional placements"

	"Preferences installClassicHaloSpecs"
	"Preferences resetHaloSpecifications"  "  <-  will result in the standard default halos being reinstalled"
	"NB: listed below in clockwise order"

		^ #(
	"  	selector				horiz		vert			color info						icon key
		---------				------		-----------		-------------------------------		---------------"
	(addMenuHandle:		left			top				(red)							none)
	(addDismissHandle:		leftCenter	top				(red		muchLighter)			'Halo-Dismiss')
	(addGrabHandle:			center		top				(black)							none)
	(addDragHandle:			rightCenter	top				(brown)							none)
	(addDupHandle:			right		top				(green)							none)	
	(addMakeSiblingHandle:		right		top				(green muchDarker)				'Halo-Dup')	
	(addDebugHandle:		right		topCenter		(blue	veryMuchLighter)		none)
	(addPoohHandle:			right		center			(white)							none)
	(addPaintBgdHandle:		right		center			(lightGray)						none)
	(addRepaintHandle:		right		center			(lightGray)						none)
	(addGrowHandle:		right		bottom			(yellow)						none)
	(addScaleHandle:		right		bottom			(lightOrange)					none)
	(addFontEmphHandle:	rightCenter	bottom			(lightBrown darker)				none)
	(addFontStyleHandle:		center		bottom			(lightRed)						none)
	(addFontSizeHandle:		leftCenter	bottom			(lightGreen)						none)

	(addRecolorHandle:		right		bottomCenter	(magenta darker)				none)

	(addRotateHandle:		left			bottom			(blue)							none))


]

{ #category : #'prefs - halos' }
Preferences class >> classicHalosInForce [
	^ (self preferenceAt: #haloTheme) preferenceValue == #classicHaloSpecs
]

{ #category : #'standard queries' }
Preferences class >> classicNavigatorEnabled [
	^ self
		valueOfFlag: #classicNavigatorEnabled
		ifAbsent: [ false ]
]

{ #category : #'updating - system' }
Preferences class >> classicTilesSettingToggled [
	"The current value of the largeTiles flag has changed; now react"

	Smalltalk isMorphic ifTrue:
		[Preferences universalTiles
			ifFalse:
				[self inform: 
'note that this will only have a noticeable
effect if the universalTiles preference is
set to true, which it currently is not' translated]
			ifTrue:
				[Project current world recreateScripts]]
]

{ #category : #'class initialization' }
Preferences class >> cleanUp [

	"Synchronize the cache for pragma preferences. Note that the actual preferences values are stored in class variables. So, no such value gets lost if we remove all such preferences from that cache."
	self removeAllPreferencesSuchThat: [:preference |
		preference isPragmaPreference].
	SystemNavigation default allSelectorsAndMethodsDo: [:behavior :selector :method |
		method pragmas do: [:pragma |
			self addPragmaPreference: pragma]].
	
	"Remove obsolete (non-pragma) preferences."
	self removeObsolete.

]

{ #category : #initialization }
Preferences class >> cleanUp: aggressive [

	aggressive ifTrue: [
		self class organization categories
			select: [:ea | ea beginsWith: '*autogenerated']
			thenDo: [:ea | self class removeCategory: ea]].
]

{ #category : #'standard queries' }
Preferences class >> cmdDotEnabled [
	^ self
		valueOfFlag: #cmdDotEnabled
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> cmdGesturesEnabled [
	"compiled programatically -- return hard-coded preference value"
	^ true
]

{ #category : #'prefs - misc' }
Preferences class >> cmdKeysInText [
	"compiled programatically -- return hard-coded preference value"
	^ true
]

{ #category : #'standard queries' }
Preferences class >> collapseWindowsInPlace [
	^ self
		valueOfFlag: #collapseWindowsInPlace
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> compactViewerFlaps [
	^ self
		valueOfFlag: #compactViewerFlaps
		ifAbsent: [ false ]
]

{ #category : #private }
Preferences class >> compileAccessorForPreference: aPreference [
	"Compile an accessor method for the given preference"

	self class 
		compileSilently: (
			'{1} ^self valueOfFlag: {2} ifAbsent: [ {3} ]'
				format: {
					aPreference name asString.
					aPreference name asSymbol printString.
					aPreference defaultValue storeString })
		classified: 'standard queries'
]

{ #category : #private }
Preferences class >> compileAccessorForPreferenceNamed: name value: value [
	"Compile a method that returns a simple true or false (depending on the value of aBoolean) when Preferences is sent prefName as a message"

	self class 
		compileSilently: (
			'{1} ^{2}'
				format: {
					name asString.
					value storeString })
		classified: 'prefs - misc'.
	
"Preferences compileAccessorForPreferenceNamed: #testing value: false"
]

{ #category : #'standard queries' }
Preferences class >> compressFlashImages [
	^ self
		valueOfFlag: #compressFlashImages
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> confirmFirstUseOfStyle [
	^ self
		valueOfFlag: #confirmFirstUseOfStyle
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> conversionMethodsAtFileOut [
	^ self
		valueOfFlag: #conversionMethodsAtFileOut
		ifAbsent: [ false ]
]

{ #category : #'prefs - halos' }
Preferences class >> customHaloSpecs [
	"Intended for you to modify to suit your personal preference.  What is implemented in the default here is just a skeleton; in comment at the bottom of this method are some useful lines you may wish to paste in to the main body here, possibly modifying positions, colors, etc..
	Note that in this example, we include:
			Dismiss handle, at top-left
			Menu handle, at top-right
			Resize handle, at bottom-right
			Rotate handle, at bottom-left
			Drag handle, at top-center
			Recolor handle, at left-center.  (this one is NOT part of the standard formulary --
											it is included here to illustrate how to
 											add non-standard halos)
			Note that the optional handles for specialized morphs, such as Sketch, Text, PasteUp, are also included"

	^ #(
	(addDismissHandle:		left			top				(red		muchLighter)			'Halo-Dismiss')
	(addMenuHandle:		right		top				(red)							'Halo-Menu')
	(addDragHandle:			center	top					(brown)							'Halo-Drag')
	(addGrowHandle:		right		bottom			(yellow)						'Halo-Scale')
	(addScaleHandle:		right		bottom			(lightOrange)					'Halo-Scale')

	(addRecolorHandle:		left			center			(green muchLighter lighter)		'Halo-Recolor')

	(addPaintBgdHandle:		right		center			(lightGray)						'Halo-Paint')
	(addRepaintHandle:		right		center			(lightGray)						'Halo-Paint')
	(addFontSizeHandle:		leftCenter	bottom			(lightGreen)						'Halo-FontSize')
	(addFontStyleHandle:		center		bottom			(lightRed)						'Halo-FontStyle')
	(addFontEmphHandle:	rightCenter	bottom			(lightBrown darker)				'Halo-FontEmph')
	(addRotateHandle:		left			bottom			(blue)							'Halo-Rot')

	(addDebugHandle:		right		topCenter		(blue	veryMuchLighter)		'Halo-Debug')
	(addPoohHandle:			right		center			(white)							'Halo-Pooh')


			)

	"  Other useful handles...

  		selector				horiz		vert			color info						icon key
		---------				------		-----------		-------------------------------		---------------

	(addTileHandle:			left			bottomCenter	(lightBrown)					'Halo-Tile')
	(addViewHandle:			left			center			(cyan)							'Halo-View')
	(addGrabHandle:			center		top				(black)							'Halo-Grab')
	(addDragHandle:			rightCenter	top				(brown)							'Halo-Drag')
	(addDupHandle:			right		top				(green)							'Halo-Dup')	
	(addHelpHandle:			center		bottom			(lightBlue)						'Halo-Help')
	(addFewerHandlesHandle:	left		topCenter		(paleBuff)						'Halo-FewerHandles')
	(addPaintBgdHandle:		right		center			(lightGray)						'Halo-Paint')
	(addRepaintHandle:		right		center			(lightGray)						'Halo-Paint')
	"

]

{ #category : #'prefs - halos' }
Preferences class >> customHalosInForce [
	^ (self preferenceAt: #haloTheme) preferenceValue == #customHaloSpecs
]

{ #category : #'standard queries' }
Preferences class >> debugHaloHandle [
	^ self
		valueOfFlag: #debugHaloHandle
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> debugLogTimestamp [
	^ self
		valueOfFlag: #debugLogTimestamp
		ifAbsent: [false]
]

{ #category : #'prefs - misc' }
Preferences class >> debugMenuItemsInvokableFromScripts [
	"If true, then items occurring in an object's debug menu will be included in the alternatives offered as arguments to a doMenuItem: tile in the scripting system"
	^ false
]

{ #category : #'standard queries' }
Preferences class >> debugPrintSpaceLog [
	^ self
		valueOfFlag: #debugPrintSpaceLog
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> debugShowDamage [
	^ self
		valueOfFlag: #debugShowDamage
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> decorateBrowserButtons [
	^ self
		valueOfFlag: #decorateBrowserButtons
		ifAbsent: [ false ]
]

{ #category : #'prefs - fonts' }
Preferences class >> decreaseFontSize [

	self changeFontSize: -3.

]

{ #category : #'prefs - annotations' }
Preferences class >> defaultAnnotationInfo [

	^ #(timeStamp messageCategory implementorsCount allChangeSets)
]

{ #category : #'prefs - annotations' }
Preferences class >> defaultAnnotationRequests [
	^ Parameters at: #MethodAnnotations ifAbsent:
		[self setDefaultAnnotationInfo]
	"Preferences annotationInfo"
]

{ #category : #'prefs - annotations' }
Preferences class >> defaultAnnotationRequests: newList [
	^ Parameters at: #MethodAnnotations put: newList
]

{ #category : #'prefs - misc' }
Preferences class >> defaultAuthorName [
	"Answer the author name to be planted, by default, in a changeset-preamble template.  You can hard-code this to hold your name, thus saving you time when writing the preambles of subsequent changesets"

	^ Utilities authorName
]

{ #category : #'standard queries' }
Preferences class >> defaultFileOutFormatMacRoman [
	^ self
		valueOfFlag: #defaultFileOutFormatMacRoman
		ifAbsent: [ false ]
]

{ #category : #'prefs - misc' }
Preferences class >> defaultPaintingExtent [
	"Answer the preferred size for the onion-skin paint area when launching a new painting within a paste-up morph.  Feel free to change the parameters to suit your configuration."

	^ 800 @ 600
]

{ #category : #defaults }
Preferences class >> defaultValueTableForCurrentRelease [
	"Answer a table defining default values for all the preferences in the release.  Returns a list of (pref-symbol, boolean-symbol) pairs"

	^  #(
		(abbreviatedBrowserButtons false)
		(alternativeBrowseIt false)
		(annotationPanes false)
		(areaFillsAreTolerant false)
		(areaFillsAreVeryTolerant false)
		(automaticFlapLayout true)
		(automaticKeyGeneration false)
		(automaticPlatformSettings true)
		(automaticViewerPlacement true)
		(balloonHelpEnabled true)
		(balloonHelpInMessageLists false)
		(batchPenTrails false)
		(capitalizedReferences true)
		(caseSensitiveFinds false)
		(cautionBeforeClosing false)
		(changeSetVersionNumbers true)
		(checkForSlips true)
		(checkForUnsavedProjects true)
		(classicNavigatorEnabled false)
		(cmdDotEnabled true)
		(collapseWindowsInPlace false)
		(compactViewerFlaps false)
		(compressFlashImages false)
		(confirmFirstUseOfStyle true)
		(conversionMethodsAtFileOut false)
		(debugHaloHandle true)
		(debugPrintSpaceLog false)
		(debugShowDamage false)
		(decorateBrowserButtons true)
		(diffsInChangeList true)
		(diffsWithPrettyPrint false)
		(dismissAllOnOptionClose false)
		(dragNDropWithAnimation false)
		(eToyFriendly false)
		(eToyLoginEnabled false)
		(enableLocalSave true)
		(extractFlashInHighQuality true)
		(extractFlashInHighestQuality false)
		(fastDragWindowForMorphic true)
		(fenceEnabled true)
		(fullScreenLeavesDeskMargins true)
		(haloTransitions false)
		(higherPerformance false)
		(honorDesktopCmdKeys true)
		(includeSoundControlInNavigator false)
		(infiniteUndo false)
		(logDebuggerStackToFile true)
		(magicHalos false)
		(menuButtonInToolPane false)
		(menuColorFromWorld false)
		(menuKeyboardControl false)  
		(modalColorPickers true)
		(mouseOverForKeyboardFocus false)
		(mouseOverHalos false)
		(mvcProjectsAllowed true)
		(navigatorOnLeftEdge true)
		(noviceMode false)
		(okToReinitializeFlaps true)
		(optionalButtons true)
		(passwordsOnPublish false)
		(personalizedWorldMenu true)
		(postscriptStoredAsEPS false)
		(projectViewsInWindows true)
		(projectZoom true)
		(projectsSentToDisk false)
		(propertySheetFromHalo false)
		(readDocumentAtStartup true)
		(restartAlsoProceeds false)
		(reverseWindowStagger true)
		(roundedMenuCorners true)
		(scrollBarsNarrow false)
		(scrollBarsOnRight true)
		(securityChecksEnabled false)
		(selectiveHalos false)
		(showBoundsInHalo false)
		(showDirectionForSketches false)
		(showDirectionHandles false)
		(showFlapsWhenPublishing false)
		(showProjectNavigator false)
		(showSecurityStatus true)
		(showSharedFlaps true)
		(signProjectFiles true)
		(simpleMenus false)
		(smartUpdating true)
		(startInUntrustedDirectory false)
		(systemWindowEmbedOK false)
		(tileTranslucentDrag true)
		(timeStampsInMenuTitles true)
		(turnOffPowerManager false)
		(twentyFourHourFileStamps true)
		(typeCheckingInTileScripting true)
		(uniTilesClassic true)
		(uniqueNamesInHalos false)
		(universalTiles false)
		(unlimitedPaintArea false)
		(useButtonPropertiesToFire false)
		(useUndo true)
		(viewersInFlaps true)
		(warnAboutInsecureContent true)
		(warnIfNoChangesFile true)
		(warnIfNoSourcesFile true))


"
Preferences defaultValueTableForCurrentRelease do:
	[:pair | (Preferences preferenceAt: pair first ifAbsent: [nil]) ifNotNilDo:
			[:pref | pref defaultValue: (pair last == true)]].
Preferences chooseInitialSettings.
"
]

{ #category : #'prefs - misc' }
Preferences class >> defaultWorldColor [
	^ Parameters
		at: #defaultWorldColor
		ifAbsent: [ Color r: 0.937 g: 0.937 b: 0.937 ].

]

{ #category : #'prefs - misc' }
Preferences class >> desktopColor [
	"Answer the desktop color. Initialize it if necessary."
	
	DesktopColor == nil ifTrue: [DesktopColor := Color gray].
	^ DesktopColor

]

{ #category : #'prefs - misc' }
Preferences class >> desktopColor: aColor [
	"Record a new desktop color preference."

	DesktopColor := aColor.

]

{ #category : #'prefs - misc' }
Preferences class >> desktopMenuTitle [
	"Answer the title to be used for the 'meta menu'.  For now, you can hard-code this, later someone should make this be a parameter the user can easily change.  sw 9/6/2000"

	^ 'World'    "This is what it has always been"

	"^ 'Desktop'
	^ 'Squeak'
	^ 'Mike''s Control Panel'"
]

{ #category : #accessing }
Preferences class >> dictionaryOfPreferences [
	"N.B.  Does /not/ answer the dictionary itself.  To burrow that deep use e.g. instVarNamed:"
	^preferencesDictionary copy
]

{ #category : #'standard queries' }
Preferences class >> diffsInChangeList [
	^ self
		valueOfFlag: #diffsInChangeList
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> diffsWithPrettyPrint [
	^ self
		valueOfFlag: #diffsWithPrettyPrint
		ifAbsent: [ false ]
]

{ #category : #'get\/set - flags' }
Preferences class >> disable: aSymbol [
	"Shorthand access to enabling a preference of the given name.  If there is none in the image, conjure one up"

	^ self setFlag: aSymbol toValue: false
]

{ #category : #'initialization - misc' }
Preferences class >> disableProgrammerFacilities [
	"Warning: do not call this lightly!  It disables all access to menus, debuggers, halos.  There is no guaranteed return from this, which is to say, you cannot necessarily reenable these things once they are disabled -- you can only use whatever the UI of the current project affords, and you cannot even snapshot -- you can only quit. 

     You can completely reverse the work of this method by calling the dual Preferences method enableProgrammerFacilities, provided you have left yourself leeway to bring about a call to that method.

	To set up a system that will come up in such a state, you have to request the snapshot in the same breath as you disable the programmer facilities.  To do this, put the following line into the 'do' menu and then evaluate it from that 'do' menu:

         Preferences disableProgrammerFacilities.

You will be prompted for a new image name under which to save the resulting image."

	Beeper beep.
	(self 
		confirm: 'CAUTION!!
This is a drastic step!
Do you really want to do this?') 
			ifFalse: 
				[Beeper beep.
				^self inform: 'whew!'].
	self disable: #cmdDotEnabled.	"No user-interrupt-into-debugger"
	self compileAccessorForPreferenceNamed: #cmdGesturesEnabled value: false.	"No halos, etc."
	self compileAccessorForPreferenceNamed: #cmdKeysInText value: false.	"No user commands invokable via cmd-key combos in text editor"
	self enable: #noviceMode.	"No control-menu"
	self disable: #warnIfNoSourcesFile.
	self disable: #warnIfNoChangesFile.
	Smalltalk saveAs
]

{ #category : #'standard queries' }
Preferences class >> dismissAllOnOptionClose [
	^ self
		valueOfFlag: #dismissAllOnOptionClose
		ifAbsent: [ false ]
]

{ #category : #'updating - system' }
Preferences class >> displaySizeChanged [
	self flag: #todo.
	self tinyDisplay
		ifTrue: [self enable: #scrollBarsNarrow]
		ifFalse: [self disable: #scrollBarsNarrow].
	self tinyDisplay 
		ifTrue:[self disable: #biggerHandles] 
		ifFalse:[self enable: #biggerHandles]
]

{ #category : #'get\/set' }
Preferences class >> doesNotUnderstand: aMessage [
	"Interpret unary message selectors as preference id."
	
	^ aMessage arguments size > 0
		ifTrue: [super doesNotUnderstand: aMessage]
		ifFalse: [
			self
				valueOfPreference: aMessage selector
				ifAbsent: [super doesNotUnderstand: aMessage]]
]

{ #category : #'standard queries' }
Preferences class >> dragNDropWithAnimation [
	^ self
		valueOfFlag: #dragNDropWithAnimation
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> dropProducesWatcher [
	^ self
		valueOfFlag: #dropProducesWatcher
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> duplicateAllControlAndAltKeys [
	^ self
		valueOfFlag: #duplicateAllControlAndAltKeys
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> duplicateControlAndAltKeys [
	^ self
		valueOfFlag: #duplicateControlAndAltKeys
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> eToyFriendly [
	^ self
		valueOfFlag: #eToyFriendly
		ifAbsent: [ false ]
]

{ #category : #'updating - system' }
Preferences class >> eToyFriendlyChanged [
	"The eToyFriendly preference changed; React"
	
	ScriptingSystem customizeForEToyUsers: Preferences eToyFriendly
]

{ #category : #'standard queries' }
Preferences class >> eToyLoginEnabled [
	^ self
		valueOfFlag: #eToyLoginEnabled
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> easySelection [
	^ self
		valueOfFlag: #easySelection
		ifAbsent: [ false ]
]

{ #category : #'support - misc' }
Preferences class >> editAnnotations [
	"Put up a window that allows the user to edit annotation specifications"

	| aWindow |
	self currentWorld addMorphCentered: (aWindow := self annotationEditingWindow).
	aWindow beKeyWindow.

	"Preferences editAnnotations"


]

{ #category : #'prefs - halos' }
Preferences class >> editCustomHalos [

	ToolSet browse: Preferences class
		selector: #customHaloSpecs
]

{ #category : #'get\/set - flags' }
Preferences class >> enable: aSymbol [
	"Shorthand access to enabling a preference of the given name.  If there is none in the image, conjure one up"

	^ self setFlag: aSymbol toValue: true
]

{ #category : #'standard queries' }
Preferences class >> enableLocalSave [
	^ self
		valueOfFlag: #enableLocalSave
		ifAbsent: [ true ]
]

{ #category : #'initialization - misc' }
Preferences class >> enableProgrammerFacilities [
	"Meant as a one-touch recovery from a #disableProgrammerFacilities call."
	"Preferences enableProgrammerFacilities"

	self enable: #cmdDotEnabled.
	self compileAccessorForPreferenceNamed: #cmdGesturesEnabled value: true. 
	self compileAccessorForPreferenceNamed: #cmdKeysInText value: true.
	self disable: #noviceMode.
	self enable: #warnIfNoSourcesFile.
	self enable: #warnIfNoChangesFile.
]

{ #category : #'prefs - misc' }
Preferences class >> enableProjectNavigator [
	"Answer whether the project-navigator menu item should be enabled"

	^ true
]

{ #category : #'standard queries' }
Preferences class >> expandedPublishing [
	^ self
		valueOfFlag: #expandedPublishing
		ifAbsent: [ true ]
]

{ #category : #parameters }
Preferences class >> expungeParameter: aKey [
	"If Parameters holds an entry under the given key, remove the entry.  No senders in the current system, but called from the postscript of the change-set that defines it, and potentially useful otherwise."

	Parameters removeKey: aKey ifAbsent: []
]

{ #category : #'standard queries' }
Preferences class >> extraDebuggerButtons [
	^ self
		valueOfFlag: #extraDebuggerButtons
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> extractFlashInHighQuality [
	^ self
		valueOfFlag: #extractFlashInHighQuality
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> extractFlashInHighestQuality [
	^ self
		valueOfFlag: #extractFlashInHighestQuality
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> fastDragWindowForMorphic [
	^ self
		valueOfFlag: #fastDragWindowForMorphic
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> fenceEnabled [
	^ self
		valueOfFlag: #fenceEnabled
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> fenceSoundEnabled [
	^ self
		valueOfFlag: #fenceSoundEnabled
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> fenceSoundEnabled: aBoolean [
	self setPreference: #fenceSoundEnabled toValue: aBoolean
]

{ #category : #'support - file list services' }
Preferences class >> fileReaderServicesForFile: fullName suffix: suffix [ 
	^(suffix = 'prefs')  | (suffix = '*') 
		ifTrue: [ self services ]
		ifFalse: [ #() ]
]

{ #category : #'prefs - fonts' }
Preferences class >> fontConfigurationMenu [
	| aMenu |
	aMenu := MenuMorph new defaultTarget: Preferences.
	^self fontConfigurationMenu: aMenu.
	
	
	
]

{ #category : #'prefs - fonts' }
Preferences class >> fontConfigurationMenu: aMenu [

	aMenu removeAllMorphs.
	aMenu addTitle: 'Standard System Fonts' translated.
	aMenu addStayUpIcons.
	
	aMenu add: 'default text font...' translated action: #chooseSystemFont.
	aMenu lastItem font: Preferences standardSystemFont.
	aMenu balloonTextForLastItem: 'Choose the default font to be used for code and  in workspaces, transcripts, etc.' translated.
	
	aMenu add: 'default fixed font...' translated action: #chooseFixedFont.
	aMenu lastItem font: Preferences standardFixedFont.
	aMenu balloonTextForLastItem: 'Choose the default font to be used for text that needs fixed width characters for layouting etc.' translated.
	
	aMenu add: 'list font...' translated action: #chooseListFont.
	aMenu lastItem font: Preferences standardListFont.
	aMenu balloonTextForLastItem: 'Choose the font to be used in list panes' translated.
	
	aMenu add: 'flaps font...' translated action: #chooseFlapsFont.
	aMenu lastItem font: Preferences standardFlapFont.
	aMenu balloonTextForLastItem: 'Choose the font to be used on textual flap tabs' translated.

	aMenu add: 'eToys font...' translated action: #chooseEToysFont.
	aMenu lastItem font: Preferences standardEToysFont.
	aMenu balloonTextForLastItem: 'Choose the font to be used on eToys environment' translated.

	aMenu add: 'eToys title font...' translated action: #chooseEToysTitleFont.
	aMenu lastItem font: Preferences standardEToysTitleFont.
	aMenu balloonTextForLastItem: 'Choose the font to be used in titles on eToys environment' translated.

	aMenu add: 'halo label font...' translated action: #chooseHaloLabelFont.
	aMenu lastItem font: Preferences standardHaloLabelFont.
	aMenu balloonTextForLastItem: 'Choose the font to be used on labels ih halo' translated.

	aMenu add: 'menu font...' translated action: #chooseMenuFont.
	aMenu lastItem font: Preferences standardMenuFont.
	aMenu balloonTextForLastItem: 'Choose the font to be used in menus' translated.
	
	aMenu add: 'window-title font...' translated action: #chooseWindowTitleFont.
	aMenu lastItem font: Preferences windowTitleFont.
	aMenu balloonTextForLastItem: 'Choose the font to be used in window titles.' translated.

	aMenu add: 'balloon-help font...' translated action: #chooseBalloonHelpFont.
	aMenu lastItem font: Preferences standardBalloonHelpFont.
	aMenu balloonTextForLastItem: 'choose the font to be used when presenting balloon help.' translated.
	
	aMenu add: 'code font...' translated action: #chooseCodeFont. 
	aMenu lastItem font: Preferences standardCodeFont. 
	aMenu balloonTextForLastItem: 'Choose the font to be used in code panes.' translated.

	aMenu add: 'button font...' translated action: #chooseStandardButtonFont.
	aMenu lastItem font: Preferences standardButtonFont.
	aMenu balloonTextForLastItem: 'Choose the font to be used in buttons.' translated.

	aMenu addLine.
	aMenu add: 'demo/hi-dpi mode' translated action: #setDemoFonts.
	aMenu balloonTextForLastItem: 'Set Fonts usable for giving a presentation' translated.

	aMenu addLine.
	aMenu add: 'restore default font choices' translated action: #restoreDefaultFonts.
	aMenu balloonTextForLastItem: 'Use the standard system font defaults' translated.
	
	aMenu add: 'print current font choices' translated action: #printStandardSystemFonts.
	aMenu balloonTextForLastItem: 'Print the standard system font defaults to the Transcript' translated.
	
	aMenu addLine.
	aMenu add: 'refresh this menu' translated target: self selector: #fontConfigurationMenu:  argument: aMenu.
	aMenu balloonTextForLastItem: 'Update this menu to reflect the current fonts' translated.
	MenuIcons decorateMenu: aMenu.
	^ aMenu
]

{ #category : #'standard queries' }
Preferences class >> fullScreenLeavesDeskMargins [
	^ self
		valueOfFlag: #fullScreenLeavesDeskMargins
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> generalizedYellowButtonMenu [
	^ self
		valueOfFlag: #generalizedYellowButtonMenu
		ifAbsent: [ true ]
]

{ #category : #support }
Preferences class >> giveHelpWithPreferences [
	"Open up a workspace with explanatory info in it about Preferences"

	| aString |
	aString := String streamContents: [:aStream | 
		aStream nextPutAll:

'Many aspects of the system are governed by the settings of various "Preferences".  

Click on any of brown tabs at the top of the panel to see all the preferences in that category.  
Or type in to the box above the Search button, then hit Search, and all Preferences matching whatever you typed in will appear in the "search results" category.  A preference is considered to match your search if either its name matches the characters *or* if anything in the balloon help provided for the preferences matches the search text.

To find out more about any particular Preference, hold the mouse over it for a moment and balloon help will appear.  Also, a complete list of all the Preferences, with documentation for each, is included below.

Preferences whose names are in shown in bold in the Preferences Panel are designated as being allowed to vary from project to project; those whose name are not in bold are "global", which is to say, they apply equally whatever project you are in.

Click on the name of any preference to get a menu which allows you to *change* whether the preference should vary from project to project or should be global, and also allows you to browse all the senders of the preference, and to discover all the categories under which the preference has been classified, and to be handed a button that you can drop wherever you please that will control the preference.

If you like all your current Preferences settings, you may wish to hit the "Save Current Settings as my Personal Preferences" button.  Once you have done that, you can at any point in the future hit "Restore my Personal Preferences" and all your saved settings will get restored immediately.

Also, you can use "themes" to set multiple preferences all at once; click on the "change theme..." button in the Squeak flap or in the Preferences panel, or seek out the themes item in the Appearance menu.' translated.

	aStream cr; cr; nextPutAll: '-----------------------------------------------------------------';
		cr; cr; nextPutAll:  'Alphabetical listing of all Preferences' translated; cr; cr.
   (Preferences allPreferences sort: [:a :b | a name < b name]) do:
	[:pref | | aHelpString |
		aStream nextPutAll: pref name; cr.
		aHelpString := pref helpString translated.
		(aHelpString beginsWith: pref name) ifTrue:
			[aHelpString := aHelpString copyFrom: (pref name size ) to: aHelpString size].
		aHelpString := (aHelpString copyReplaceAll: String cr with: ' ')  copyWithout: Character tab.
		aStream nextPutAll: aHelpString capitalized.
		(aHelpString isEmpty or: [aHelpString last == $.]) ifFalse: [aStream nextPut: $.].
        aStream cr; cr]].

	UIManager default edit: aString label: 'About Preferences' translated

"Preferences giveHelpWithPreferences"
]

{ #category : #'standard queries' }
Preferences class >> haloEnclosesFullBounds [
	^ self
		valueOfFlag: #haloEnclosesFullBounds
		ifAbsent: [ false ]
]

{ #category : #'prefs - halos' }
Preferences class >> haloSpecifications [
	"Answer a list of HaloSpecs that describe which halos are to be used, what they should look like, and where they should be situated"

	^ Parameters at: #HaloSpecs ifAbsent:
			[self installHaloTheme: #iconicHaloSpecifications.
			^ Parameters at: #HaloSpecs]

	"Preferences haloSpecifications"
	"Preferences resetHaloSpecifications"

]

{ #category : #'prefs - halos' }
Preferences class >> haloSpecificationsForWorld [
	| desired |
	"Answer a list of HaloSpecs that describe which halos are to be used on a world halo, what they should look like, and where they should be situated"
	"Preferences resetHaloSpecifications"

	desired := #(addDebugHandle: addMenuHandle: addTileHandle: addViewHandle: addHelpHandle: addScriptHandle: addPaintBgdHandle: addRecolorHandle:).
	^ self haloSpecifications select:
		[:spec | desired includes: spec addHandleSelector]
]

{ #category : #'prefs - halos' }
Preferences class >> haloTheme [
	^ self
		valueOfFlag: #haloTheme
		ifAbsent: [ #iconicHaloSpecifications ]
]

{ #category : #'standard queries' }
Preferences class >> haloTransitions [
	^ self
		valueOfFlag: #haloTransitions
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> higherPerformance [
	^ self
		valueOfFlag: #higherPerformance
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> honorDesktopCmdKeys [
	^ self
		valueOfFlag: #honorDesktopCmdKeys
		ifAbsent: [ true ]
]

{ #category : #'prefs - halos' }
Preferences class >> iconicHaloSpecifications [
	"Answer an array that characterizes the locations, colors, icons, and selectors of the halo handles that may be used in the iconic halo scheme"

	"Preferences resetHaloSpecifications"

	^ #(
	"  	selector				horiz		vert			color info						icon key
		---------				------		-----------		-------------------------------		---------------"
	(addCollapseHandle:		left			topCenter		(tan)							'Halo-Collapse')
	(addPoohHandle:			right		center			(white)							'Halo-Pooh')
	(addDebugHandle:		right		topCenter		(blue	veryMuchLighter)		'Halo-Debug')
	(addDismissHandle:		left			top				(red		muchLighter)			'Halo-Dismiss')
	(addRotateHandle:		left			bottom			(blue)							'Halo-Rot')
	(addMenuHandle:		leftCenter	top				(red)							'Halo-Menu')
	(addTileHandle:			left			bottomCenter	(lightBrown)					'Halo-Tile')
	(addViewHandle:			left			center			(cyan)							'Halo-View')
	(addGrabHandle:			center		top				(black)							'Halo-Grab')
	(addDragHandle:			rightCenter	top				(brown)							'Halo-Drag')
	(addDupHandle:			right		top				(green)							'Halo-Dup')	
	(addMakeSiblingHandle:	right		top				(green muchDarker)				'Halo-Dup')	
	(addHelpHandle:			center		bottom			(lightBlue)						'Halo-Help')
	(addGrowHandle:		right		bottom			(yellow)						'Halo-Scale')
	(addScaleHandle:		right		bottom			(lightOrange)					'Halo-Scale')
	(addScriptHandle:		rightCenter	bottom			(green muchLighter)			'Halo-Script')
	(addPaintBgdHandle:		right		center			(lightGray)						'Halo-Paint')
	(addViewingHandle:		leftCenter	bottom			(lightGreen lighter)				'Halo-View')
	(addRepaintHandle:		right		center			(lightGray)						'Halo-Paint')
	(addFontSizeHandle:		leftCenter	bottom			(lightGreen)						'Halo-FontSize')
	(addFontStyleHandle:		center		bottom			(lightRed)						'Halo-FontStyle')
	(addFontEmphHandle:	rightCenter	bottom			(lightBrown darker)				'Halo-FontEmph')
	(addRecolorHandle:		right		bottomCenter	(magenta darker)				'Halo-Recolor')
	(addChooseGraphicHandle:	right	bottomCenter	(green muchLighter)			'Halo-ChooseGraphic')
		) 
]

{ #category : #'prefs - halos' }
Preferences class >> iconicHalosInForce [
	^ (self preferenceAt: #haloTheme) preferenceValue == #iconicHaloSpecifications
]

{ #category : #'standard queries' }
Preferences class >> includeSoundControlInNavigator [
	^ self
		valueOfFlag: #includeSoundControlInNavigator
		ifAbsent: [ false ]
]

{ #category : #'prefs - fonts' }
Preferences class >> increaseFontSize [

	self changeFontSize: 3.

]

{ #category : #'standard queries' }
Preferences class >> infiniteUndo [
	^ self
		valueOfFlag: #infiniteUndo
		ifAbsent: [ false ]
]

{ #category : #'updating - system' }
Preferences class >> infiniteUndoChanged [
	"The infiniteUndo preference changed; react"
	
	self infiniteUndo ifFalse:
		[CommandHistory resetAllHistory]
]

{ #category : #'support - misc' }
Preferences class >> initialExtent [
	^ Smalltalk isMorphic ifFalse: [219 @ 309] ifTrue: [232 @ 309]
]

{ #category : #'class initialization' }
Preferences class >> initialize [
	"Preferences initialize"
	self registerForEvents.
]

{ #category : #initialization }
Preferences class >> initializeDictionaryOfPreferences [
	"Initialize the preferencesDictionary to be an empty IdentityDictionary"

	"Preferences initializeDictionaryOfPreferences"

	preferencesDictionary := IdentityDictionary new
]

{ #category : #parameters }
Preferences class >> initializeParameters [
	"Preferences initializeParameters"
	Parameters := IdentityDictionary new.
	Parameters at: #maxBalloonHelpLineLength put: 28.
]

{ #category : #parameters }
Preferences class >> inspectParameters [
	"Open up an inspector on the Parameters of Preferences.  This is crude!"

	Parameters inspectWithLabel: 'Parameters'
]

{ #category : #'support - misc' }
Preferences class >> inspectPreferences [
	"Open a window on the current preferences dictionary, allowing the user to inspect and change the current preference settings.  This is fallen back upon if Morphic is not present. This is dangerous, the dictionary of preferences should not be accessed concurrently."

	"Preferences inspectPreferences"

	preferencesDictionary inspectWithLabel: 'Preferences'
]

{ #category : #'prefs - halos' }
Preferences class >> installClassicHaloSpecs [
	"Install an alternative set of halos,  rather more based on the old placements, and without icons, , and lacking the scripting-relating handles.."
	"Preferences installClassicHaloSpecs"
	"Preferences resetHaloSpecifications"  "  <-  will result in the standard default halos being reinstalled"
	self installHaloTheme: #classicHaloSpecs
]

{ #category : #'prefs - halos' }
Preferences class >> installCustomHaloSpecs [
	"Install an alternative set of halos, as customized by the user"
	"Preferences installCustomHaloSpecs"
	self installHaloTheme: #customHaloSpecs
]

{ #category : #'prefs - halos' }
Preferences class >> installHaloSpecsFromArray: anArray [

	
	^ Parameters at: #HaloSpecs put: 
		(anArray collect:
			[:quin | | aColor |
				aColor := Color.
				quin fourth do: [:sel | aColor := aColor perform: sel].
				HaloSpec new 
					horizontalPlacement: quin second
					verticalPlacement: quin third 
					color: aColor
					iconSymbol: quin fifth
					addHandleSelector: quin first])
]

{ #category : #'prefs - halos' }
Preferences class >> installHaloTheme: themeSymbol [
	self installHaloSpecsFromArray: (self perform: themeSymbol).
	(self preferenceAt: #haloTheme) preferenceValue: themeSymbol.
	
]

{ #category : #'prefs - halos' }
Preferences class >> installIconicHaloSpecs [
	"Install an alternative set of halos,  rather more based on the old placements, and without icons, , and lacking the scripting-relating handles.."
	"Preferences installIconicHaloSpecs"
	self installHaloTheme: #iconicHaloSpecifications
]

{ #category : #'prefs - halos' }
Preferences class >> installSimpleHaloSpecs [
	"Preferences installSimpleHaloSpecs"
	self installHaloTheme: #simpleFullHaloSpecifications
]

{ #category : #'themes - tools' }
Preferences class >> installTheme: aSymbol [
	"Install the theme represented by aSymbol.  The code that makes the theme-specific changes is lodged in a method of the same name as aSymbol, which must reside in category #themes in Preferences class"

	self perform: aSymbol.
	self inform: ('Theme {1} is now installed.
Many of the changes will only be
noticeable in new windows that you
create from now on.' translated format: {aSymbol translated}).
]

{ #category : #'reacting to change' }
Preferences class >> isChangeSelector: aLiteral [
	^preferencesDictionary anySatisfy: [:pref |
		aLiteral = pref changeSelector]
]

{ #category : #'standard queries' }
Preferences class >> keepTickingWhilePainting [
	^ self
		valueOfFlag: #keepTickingWhilePainting
		ifAbsent: [ false ]
]

{ #category : #'updating - system' }
Preferences class >> largeTilesSettingToggled [
	"The current value of the largeTiles flag has changed; now react"

	Smalltalk isMorphic ifTrue:
		[Preferences universalTiles
			ifFalse:
				[self inform: 
'note that this will only have a noticeable
effect if the universalTiles preference is
set to true, which it currently is not' translated]
			ifTrue:
				[Project current world recreateScripts]]
]

{ #category : #'support - misc' }
Preferences class >> letUserPersonalizeMenu [
	"Invoked from menu, opens up a single-msg browser on the message that user is invited to customize for rapid morphic access via option-click on morphic desktop"

	ToolSet browse: Preferences class 
		selector: #personalizeUserMenu:
]

{ #category : #'initialization - save\/load' }
Preferences class >> loadPreferencesFrom: aFile [
	| stream params dict desktopColor |
	stream := ReferenceStream fileNamed: aFile.
	params := stream next.
	self assert: (params isKindOf: IdentityDictionary).
	params removeKey: #PersonalDictionaryOfPreferences.
	dict := stream next.
	self assert: (dict isKindOf: IdentityDictionary).
	desktopColor := stream next.
	stream close.
	dict keysAndValuesDo:
		[:key :value | (self preferenceAt: key ifAbsent: [nil]) ifNotNil:
			[:pref | [pref preferenceValue: value preferenceValue] on: Deprecation do: [ : err | "Ignore preferences which may not be supported anymore."]]].
	params keysAndValuesDo: [ :key :value | self setParameter: key to: value ].
	Smalltalk isMorphic
		ifTrue: [ Project current world fillStyle: desktopColor ]
		ifFalse: [ self desktopColor: desktopColor. ScheduledControllers updateGray ]
]

{ #category : #updating }
Preferences class >> localeChanged [
	LocaleID current isoLanguage = 'ja'
		ifTrue: [Preferences enable: #useFormsInPaintBox]
		ifFalse: [Preferences disable: #useFormsInPaintBox]
]

{ #category : #'standard queries' }
Preferences class >> logDebuggerStackToFile [
	^ self
		valueOfFlag: #logDebuggerStackToFile
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> magicHalos [
	^ self
		valueOfFlag: #magicHalos
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> maintainHalos [
	^ self
		valueOfFlag: #maintainHalos
		ifAbsent: [ true ]
]

{ #category : #'prefs - misc' }
Preferences class >> maxBalloonHelpLineLength [
	^ Parameters at: #maxBalloonHelpLineLength
]

{ #category : #'standard queries' }
Preferences class >> menuAppearance3d [
	^ self
		valueOfFlag: #menuAppearance3d
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> menuButtonInToolPane [
	^ self
		valueOfFlag: #menuButtonInToolPane
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> menuColorFromWorld [
	^ self
		valueOfFlag: #menuColorFromWorld
		ifAbsent: [true
			"success"]
]

{ #category : #'support - misc' }
Preferences class >> menuColorString [
	^ ((self valueOfFlag: #menuColorFromWorld)
		ifTrue: ['stop menu-color-from-world']
		ifFalse: ['start menu-color-from-world']) translated
]

{ #category : #'standard queries' }
Preferences class >> menuKeyboardControl [
	^ self
		valueOfFlag: #menuKeyboardControl
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> menuWithIcons [
	^ self
		valueOfFlag: #menuWithIcons
		ifAbsent: [ true ]
]

{ #category : #'prefs - misc' }
Preferences class >> messengersInViewers [
	"A coming technology..."

	^ false
]

{ #category : #'prefs - misc' }
Preferences class >> metaMenuDisabled [
	"If true, then click/cmd-click on the desktop will not bring up the World menu.  Can be changed manually right here, and can be programattically changed via a call of the following form:

	Preferences compileHardCodedPref: #metaMenuDisabled enable: true"

	^ false
]

{ #category : #'standard queries' }
Preferences class >> modalColorPickers [
	^ self
		valueOfFlag: #modalColorPickers
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> mouseOverForKeyboardFocus [
	^ self
		valueOfFlag: #mouseOverForKeyboardFocus
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> mouseOverHalos [
	^ self
		valueOfFlag: #mouseOverHalos
		ifAbsent: [ false ]
]

{ #category : #'updating - system' }
Preferences class >> mouseOverHalosChanged [
	Project current world wantsMouseOverHalos: self mouseOverHalos
]

{ #category : #'standard queries' }
Preferences class >> mvcProjectsAllowed [
	^ self
		valueOfFlag: #mvcProjectsAllowed
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> navigatorOnLeftEdge [
	^ self
		valueOfFlag: #navigatorOnLeftEdge
		ifAbsent: [ true ]
]

{ #category : #'support - misc' }
Preferences class >> navigatorShowingString [
	"Answer a string for the show-project-navigator menu item"
	^ (self showProjectNavigator
		ifTrue: ['<yes>']
		ifFalse: ['<no>'])
		, 'show navigator (N)' translated
]

{ #category : #'standard queries' }
Preferences class >> noviceMode [
	^ self
		valueOfFlag: #noviceMode
		ifAbsent: [ false ]
]

{ #category : #'updating - system' }
Preferences class >> noviceModeSettingChanged [
	"The current value of the noviceMode flag has changed;  
	now react"
	TheWorldMainDockingBar updateInstances.
	PasteUpMorph allSubInstances
		select: [:each | each isWorldMorph]
		thenDo: [:each | each initializeDesktopCommandKeySelectors].
	Smalltalk at: #ParagraphEditor ifPresent: [:aClass| aClass initialize]
]

{ #category : #'themes - tools' }
Preferences class >> offerThemesMenu [
	"Put up a menu offering the user a choice of themes.  Each theme is represented by a method in category #themes in Preferences class.  The comment at the front of each method is used as the balloon help for the theme"

	"Preferences offerThemesMenu"
	| selectors aMenu |
	selectors := self class allMethodsInCategory: #themes.
	selectors := selectors select: [:sel | sel numArgs = 0].
	aMenu := MenuMorph new defaultTarget: self.
	aMenu addTitle: 'Choose a set of preferences to install' translated.
	selectors do:
		[:sel |
			aMenu add: sel target: self selector: #installTheme: argument: sel.
			aMenu balloonTextForLastItem: (self class firstCommentAt: sel)].
	aMenu addLine.
	aMenu add: 'browse details...' translated target: self action: #browseThemes.
	aMenu balloonTextForLastItem: 'Puts up a tool that will allow you to view and edit the code underlying all of the available preference sets' translated.
	aMenu popUpInWorld.
	"(Workspace new contents: 'here is an example of a new window with your new theme installed' translated) openLabel: 'Testing one two three'"
]

{ #category : #'standard queries' }
Preferences class >> okToReinitializeFlaps [
	^ self
		valueOfFlag: #okToReinitializeFlaps
		ifAbsent: [ true ]
]

{ #category : #support }
Preferences class >> okayToChangeProjectLocalnessOf: prefSymbol [
	"Answer whether it would be okay to allow the user to switch the setting of whether or not the preference symbol is local to a project.  Formerly useful and perhaps again will be, though to be sure this is a non-modular design."

	^ (#() includes: prefSymbol) not
]

{ #category : #'standard queries' }
Preferences class >> oliveHandleForScriptedObjects [
	^ self
		valueOfFlag: #oliveHandleForScriptedObjects
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> optionalButtons [
	^ self
		valueOfFlag: #optionalButtons
		ifAbsent: [ false ]
]

{ #category : #'updating - system' }
Preferences class >> optionalButtonsChanged [
	"The setting of the optionalButtons preference changed; react.  Formerly, we replaced prototypes in flaps but this is no longer necessary"

]

{ #category : #themes }
Preferences class >> outOfTheBox [
	"The default out-of-the-box preference settings for Squeak 3.2.  The 'alternative' window-look and scrollbar-look are used.  Button panes are used but not annotation panes.  Scrollbars are on the right and do not flop out."

	self setPreferencesFrom: self defaultValueTableForCurrentRelease.
	"SystemNavigation thoroughSenders: true. <- deprecated since all sender searching is now very thorough"
	SystemWindow clickOnLabelToEdit: true.
	Text ignoreStyleIfOnlyBold: true.
	MenuMorph roundedMenuCorners: true.
	ScrollBar scrollBarsWithoutMenuButton: true.
	SoundPlayer soundQuickStart: false.
	SoundPlayer stopSoundWhenDone: false.
	SoundService soundEnabled: true.
	SoundRecorder canRecordWhilePlaying:false.
]

{ #category : #parameters }
Preferences class >> parameterAt: aKey [
	^ Parameters at: aKey ifAbsent: [nil]
]

{ #category : #parameters }
Preferences class >> parameterAt: aKey default: defaultValueBlock [
	"Deprecated interface; no surviving senders in the released image, but clients probably still use"

	^ self parameterAt: aKey ifAbsentPut: defaultValueBlock
]

{ #category : #parameters }
Preferences class >> parameterAt: aKey ifAbsent: aBlock [
	"Answer the parameter saved at the given key; if there is no such key in the Parameters dictionary, evaluate aBlock"

	^ Parameters at: aKey ifAbsent: aBlock
]

{ #category : #parameters }
Preferences class >> parameterAt: aKey ifAbsentPut: defaultValueBlock [
	"Return the Parameter setting at the given key.  If there is no entry for this key in the Parameters dictionary, create one with the value of defaultValueBlock as its value"

	^ Parameters at: aKey ifAbsentPut: defaultValueBlock
]

{ #category : #parameters }
Preferences class >> parameters [
	
"Preferences parameters explore"
	^Parameters
]

{ #category : #'standard queries' }
Preferences class >> passwordsOnPublish [
	^ self
		valueOfFlag: #passwordsOnPublish
		ifAbsent: [ false ]
]

{ #category : #themes }
Preferences class >> personal [
	"Settings saved (by sometime earlier having hit the 'Save Current Settings as my Personal Preferences' in a Preferences panel) as my personal preferences"

	self restorePersonalPreferences
]

{ #category : #'support - misc' }
Preferences class >> personalizeUserMenu: aMenu [
	"The user has clicked on the morphic desktop with the yellow mouse button (option+click on the Mac); a menu is being constructed to present to the user in response; its default target is the current world.  In this method, you are invited to add items to the menu as per personal preferences.
	The default implementation, for illustrative purposes, sets the menu title to 'personal', and adds items for go-to-previous-project, show/hide flaps, and load code updates"
	
	aMenu addTitle: 'personal' translated.  "Remove or modify this as per personal choice"

	aMenu addStayUpItem.
	aMenu add: 'previous project' translated action: #goBack.
	aMenu add: 'load latest code updates' translated target: MCMcmUpdater action: #updateFromServer.
	aMenu add: 'about this system...' translated target: Smalltalk action: #aboutThisSystem.
	
	aMenu addLine.
				
	aMenu addUpdating: #suppressFlapsString target: Project current action: #toggleFlapsSuppressed.
	aMenu balloonTextForLastItem: 'Whether prevailing flaps should be shown in the project right now or not.' translated
]

{ #category : #'standard queries' }
Preferences class >> personalizedWorldMenu [
	^ self
		valueOfFlag: #personalizedWorldMenu
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> postscriptStoredAsEPS [
	^ self
		valueOfFlag: #postscriptStoredAsEPS
		ifAbsent: [ false ]
]

{ #category : #updating }
Preferences class >> prefEvent: anEvent [
	"Check if this system event defines or removes a preference."

	| class selector method |
	self flag: #performance. "mt: Maybe defer preference dictionary update?"

	anEvent itemKind = SystemChangeNotifier classKind ifTrue: [
		anEvent isRemoved ifTrue: [
			self removeAllPreferencesSuchThat: [:pref | 
				pref provider == anEvent item]].
		
		anEvent isRenamed ifTrue: [
			self atomicUpdatePreferences: [ :prefs |
				self allPreferences
					select: [:pref | pref provider == anEvent item]
					thenDo: [:pref | prefs at: pref id put: pref].
				prefs keys
					select: [:id | id beginsWith: anEvent oldName]
					thenDo: [:id | prefs removeKey: id] ] ] ].
	
	anEvent itemKind = SystemChangeNotifier methodKind ifTrue: [
		"ignore instance methods"
		anEvent itemClass isMeta
			ifFalse: [^ self]. 

		class := anEvent itemClass theNonMetaClass.
		selector := anEvent itemSelector.
		method := anEvent item.

		anEvent isRemoved ifTrue: [
			self atomicUpdatePreferences: [ :prefs | 
				"See PragmaPreference >> #id."
				prefs removeKey: (class name,'>>', selector) asSymbol ifAbsent: []]].
	
		(anEvent isAdded or: [anEvent isModified]) ifTrue: [
			method pragmas do: [:pragma | self addPragmaPreference: pragma] ] ].
]

{ #category : #private }
Preferences class >> preference: prefName category: categoryName description: helpString type: typeSymbol [
	"Create a preference for a preference pragma in a method."
	
	^ self 
		preference: prefName
		categoryList: (categoryName isArray "Alas pragma users are not always careful"
						ifTrue: [categoryName]
						ifFalse: [{categoryName}])
		description: helpString
		type: typeSymbol
]

{ #category : #private }
Preferences class >> preference: prefName categoryList: categoryList description: helpString type: typeSymbol [
	"Create a preference for a preference pragma in a method."
	
	^ PragmaPreference new
		 name: prefName
		 defaultValue: nil	"always nil"
		 helpString: helpString
		 localToProject: false "governed by the method"
		 categoryList: categoryList
		 changeInformee: nil
		 changeSelector: nil
		 type: typeSymbol
]

{ #category : #accessing }
Preferences class >> preferenceAt: aSymbol [ 
	"Answer the Preference object at the given symbol, or nil if not there"

	^self preferenceAt: aSymbol ifAbsent: [ nil ]
]

{ #category : #accessing }
Preferences class >> preferenceAt: aSymbol ifAbsent: aBlock [ 
	"Answer the Preference object at the given symbol, or the value of aBlock if not present"

	 ^preferencesDictionary at: aSymbol ifAbsent: aBlock
]

{ #category : #support }
Preferences class >> preferencesInCategory: aCategorySymbol [ 
	"Answer a list of Preference objects that reside in the given category."

	^ self allPreferences select: [ :aPreference |
		aPreference categoryList includes: aCategorySymbol ]
]

{ #category : #'prefs - misc' }
Preferences class >> preserveCommandExcursions [
	"An architecture is in place for storing command excursions to which access is otherwise cut off by having taken a variant branch, but it is not accessible unless you hand-code this preference to true -- which I suggest you do only with fingers crossed."

	^ false
]

{ #category : #'prefs - fonts' }
Preferences class >> printStandardSystemFonts [
	"self printStandardSystemFonts"

	| string |
	string := String streamContents: [ :s |

	#(standardDefaultTextFont standardListFont standardFlapFont 
	standardEToysFont standardMenuFont windowTitleFont 
	standardBalloonHelpFont standardCodeFont standardButtonFont) do: [:selector |
		| font |
		font := Preferences perform: selector.
		s
			nextPutAll: selector; space;
			nextPutAll: font familyName; space;
			nextPutAll: (AbstractFont emphasisStringFor: font emphasis);
			nextPutAll: ' points: ';
			print: font pointSize;
			nextPutAll: ' height: ';
			print: font height;
			cr
		]].

	(StringHolder new)
		contents: string;
		openLabel: 'Current system font settings' translated.

]

{ #category : #'standard queries' }
Preferences class >> projectViewsInWindows [
	^ self
		valueOfFlag: #projectViewsInWindows
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> projectZoom [
	^ self
		valueOfFlag: #projectZoom
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> projectsSentToDisk [
	^ self
		valueOfFlag: #projectsSentToDisk
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> propertySheetFromHalo [
	^ self
		valueOfFlag: #propertySheetFromHalo
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> purgeUndoOnQuit [
	^ self
		valueOfFlag: #purgeUndoOnQuit
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> readDocumentAtStartup [
	^ self
		valueOfFlag: #readDocumentAtStartup
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> readDocumentAtStartup: aBoolean [
	^ self
		setPreference: #readDocumentAtStartup
		toValue: aBoolean
]

{ #category : #'standard queries' }
Preferences class >> readOnlyMode [
	^ self
		valueOfFlag: #readOnlyMode
		ifAbsent: [ false ]
]

{ #category : #'prefs - fonts' }
Preferences class >> refreshFontSettings [
	"Try to update all the current font settings to make things consistent."

	UserInterfaceTheme current applyAfter: [
		self setFlapsFontTo: (self standardFlapFont);
			setEToysFontTo: (self standardEToysFont);
			setWindowTitleFontTo: (self windowTitleFont);
			setListFontTo: (self standardListFont);
			setMenuFontTo: (self standardMenuFont);
			setSystemFontTo: (TextStyle defaultFont);
			setCodeFontTo: (self standardCodeFont);
			setBalloonHelpFontTo: (BalloonMorph balloonFont)].

	SystemWindow allSubInstancesDo: [ :s | | rawLabel |
		rawLabel := s getRawLabel.
		rawLabel owner vResizing: #spaceFill.
		rawLabel font: rawLabel font.
		s setLabel: s label.
		s replaceBoxes ].
]

{ #category : #initialization }
Preferences class >> registerForEvents [
	"Preferences registerForEvents"
	
	"Do not register pragma preferences with any preferences holder but this one."
	self == Preferences ifFalse: [^ self].
	
	SystemChangeNotifier uniqueInstance
		noMoreNotificationsFor: self;
		notify: self ofAllSystemChangesUsing: #prefEvent:.

	Smalltalk allClassesDo: [:aClass |
		aClass class methodsDo: [:method |
			method pragmas do: [:pragma |
				self addPragmaPreference: pragma] ] ].
]

{ #category : #'add\/remove' }
Preferences class >> removeAllPreferencesSuchThat: block [

	self atomicUpdatePreferences: [ :copyOfDictionaryOfPreferences |
		| map |
		map := copyOfDictionaryOfPreferences select: block.
		map keysDo: [ :prefName |
			copyOfDictionaryOfPreferences removeKey: prefName]]
]

{ #category : #initialization }
Preferences class >> removeObsolete [
	"Remove obsolete preferences"
	Preference allInstancesDo:[:pref|
		pref isObsolete ifTrue:[self removePreference: pref].
	].
]

{ #category : #'add\/remove' }
Preferences class >> removePreference: aSymbol [ 
	"Remove all memory of the given preference symbol in my various structures."

	| pref |
	pref := self preferenceAt: aSymbol ifAbsent: [^self].
	
	pref localToProject ifTrue: [
		Project allProjects do: [ :proj | 
			 proj projectPreferenceFlagDictionary ifNotNil: [ :projectpreferences |
				projectpreferences removeKey: aSymbol ifAbsent: [] ] ] ].
	
	self atomicUpdatePreferences: [ :copyOfDictionaryOfPreferences |
		copyOfDictionaryOfPreferences removeKey: aSymbol ifAbsent: nil ].
	
	"Remove auto-generated accessor method."
	self class removeSelector: aSymbol.
	
	^ pref
]

{ #category : #'prefs - halos' }
Preferences class >> resetHaloSpecifications [
	"Preferences resetHaloSpecifications"

	^ Parameters removeKey: #HaloSpecs ifAbsent: []
]

{ #category : #'standard queries' }
Preferences class >> restartAlsoProceeds [
	^ self
		valueOfFlag: #restartAlsoProceeds
		ifAbsent: [ true ]
]

{ #category : #'prefs - fonts' }
Preferences class >> restoreDefaultFonts [
	"Since this is called from menus, we can take the opportunity to prompt for missing font styles."
	"
	Preferences restoreDefaultFonts
	"
	
	UserInterfaceTheme allThemes
		detect: [:ea | UserInterfaceTheme current name ~= ea name
			and: [UserInterfaceTheme current name includesSubstring: ea name]]
		ifFound: [:ea | 
			(Project uiManager
				confirm: ('Do you want to apply\"{1}"?' translated withCRs format: {ea name})
				title: 'Apply UI Theme' translated) ifTrue: [ea apply]]
		ifNone: [self inform: 'Sorry, could not revert font choices.\Please apply a UI theme with smaller fonts.' translated withCRs].
]

{ #category : #'prefs - fonts' }
Preferences class >> restoreDefaultFontsForJapanese [
	"Preferences restoreDefaultFontsForJapanese"
	#(	"(setButtonFontTo:		ComicBold		15)"
		"(setTextButtonFontTo:		NewYork		12)"
		"(setCodeFontTo:			NewYork		12)"  "Later"
		(setFlapsFontTo:			NewYork		15)
		(setListFontTo:			NewYork		12)
		(setMenuFontTo:			NewYork		12)
		(setWindowTitleFontTo:	NewYork		15)
		(setSystemFontTo:		NewYork		12)) do:
			[:triplet |
				self perform: triplet first with: (StrikeFontSet familyName: triplet second size: triplet third)].

	self setButtonFontTo: (StrikeFont familyName: #ComicBold size: 16).

	Smalltalk at: #BalloonMorph ifPresent:
		[:thatClass | thatClass setBalloonFontTo: (StrikeFontSet familyName: #NewYork size: 12)].

	"Note:  The standardCodeFont is not currently used -- the default font is instead; later hopefully we can split the code font out as  a separate choice, but only after we're able to have the protocols reorganized such that we can know whether it's code or not when we launch the text object.

	Note:  The standard button font is reset by this code but is not otherwise settable by a public UI (too many things can go afoul) "
]

{ #category : #'prefs - fonts' }
Preferences class >> restoreFontsAfter: aBlock [

	"Restore the currently chosen set of standard fonts after 
	evaluating aBlock. Used for tests that modify the default fonts."

	| standardDefaultTextFont standardListFont standardEToysFont standardMenuFont 
	windowTitleFont standardBalloonHelpFont standardCodeFont standardButtonFont |

	standardDefaultTextFont := Preferences standardDefaultTextFont.
	standardListFont := Preferences standardListFont.
	standardEToysFont := Preferences standardEToysFont.
	standardMenuFont := Preferences standardMenuFont.
	windowTitleFont := Preferences windowTitleFont.
	standardBalloonHelpFont := Preferences standardBalloonHelpFont.
	standardCodeFont := Preferences standardCodeFont.
	standardButtonFont := Preferences standardButtonFont.
	^ UserInterfaceTheme current applyAfter: [
		aBlock ensure: [
			Preferences setSystemFontTo: standardDefaultTextFont.
			Preferences setListFontTo: standardListFont.
			Preferences setEToysFontTo: standardEToysFont.
			Preferences setMenuFontTo: standardMenuFont.
			Preferences setWindowTitleFontTo: windowTitleFont.
			Preferences setBalloonHelpFontTo: standardBalloonHelpFont.
			Preferences setCodeFontTo: standardCodeFont.
			Preferences setButtonFontTo: standardButtonFont]].

]

{ #category : #'initialization - save\/load' }
Preferences class >> restorePersonalPreferences [
	"Restore all the user's saved personal preference settings"

	| savedPrefs |
	savedPrefs := self parameterAt: #PersonalDictionaryOfPreferences ifAbsent: [^ self inform: 'There are no personal preferences saved in this image yet'].

	savedPrefs associationsDo:
		[:assoc | (self preferenceAt: assoc key ifAbsent: [nil]) ifNotNil:
			[:pref | pref preferenceValue: assoc value preferenceValue]]
]

{ #category : #'initialization - save\/load' }
Preferences class >> restorePreferencesFromDisk [
	(FileDirectory default fileExists: 'my.prefs')
		ifTrue: [ Cursor wait showWhile: [
			[ self loadPreferencesFrom: 'my.prefs' ] on: Error do: [ :ex | self inform: 'there was an error restoring the preferences' ]
		] ]
		ifFalse: [ self inform: 'you haven''t saved your preferences yet!' ].
	
]

{ #category : #'initialization - save\/load' }
Preferences class >> restorePreferencesFromDisk: aFile [ 
	Cursor wait
		showWhile: [[self loadPreferencesFrom: aFile]
				on: Error
				do: [:ex | self inform: 'there was an error restoring the preferences' translated]]
]

{ #category : #'standard queries' }
Preferences class >> reverseWindowStagger [
	^ self
		valueOfFlag: #reverseWindowStagger
		ifAbsent: [ true ]
]

{ #category : #'updating - system' }
Preferences class >> roundedWindowCornersChanged [
	"The user changed the value of the roundedWindowCorners preference.  React"

	Project current world fullRepaintNeeded.
]

{ #category : #'initialization - save\/load' }
Preferences class >> savePersonalPreferences [
	"Save the current list of Preference settings as the user's personal choices"

	self
		setParameter: #PersonalDictionaryOfPreferences
		to: preferencesDictionary deepCopy
]

{ #category : #'prefs - misc' }
Preferences class >> scrollBarColor [
	"Answer the preferred color for scroll bar elevators."

	^ Color gray
]

{ #category : #'prefs - misc' }
Preferences class >> scrollBarWidth [
	"Answer the preferred width for scroll bars."

	^ 8
]

{ #category : #'standard queries' }
Preferences class >> scrollBarsNarrow [
	^ self
		valueOfFlag: #scrollBarsNarrow
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> scrollBarsOnRight [
	^ self
		valueOfFlag: #scrollBarsOnRight
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> securityChecksEnabled [
	^ self
		valueOfFlag: #securityChecksEnabled
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> selectiveHalos [
	^ self
		valueOfFlag: #selectiveHalos
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> serverMode [
	^ self
		valueOfFlag: #serverMode
		ifAbsent: [false]
]

{ #category : #'support - file list services' }
Preferences class >> serviceLoadPreferencesFromDisk [
	^ SimpleServiceEntry 
		provider: self 
		label: 'load preferences from a saved file'
		selector: #restorePreferencesFromDisk:
		description: 'restore all saved personal preference settings'
		buttonLabel: 'load preferences'
]

{ #category : #'support - file list services' }
Preferences class >> services [
	^ Array with: self serviceLoadPreferencesFromDisk
]

{ #category : #'support - misc' }
Preferences class >> setArrowheads [
	"Let the user edit the size of arrowheads"

	| aParameter result  |
	aParameter := self parameterAt: #arrowSpec ifAbsent: [5 @ 4].
	result := Morph obtainArrowheadFor: 'Default size of arrowheads on pen trails ' translated defaultValue: aParameter asString.
	result ifNotNil:
			[self setParameter: #arrowSpec to: result]
		ifNil:
			[Beeper beep]
]

{ #category : #'prefs - fonts' }
Preferences class >> setBalloonHelpFontTo: aFont [

	UserInterfaceTheme current
		set: #balloonHelpFont
		to: aFont;
		apply.
]

{ #category : #'prefs - fonts' }
Preferences class >> setButtonFontTo: aFont [

	UserInterfaceTheme current
		set: #standardButtonFont
		to: aFont;
		apply.
]

{ #category : #'prefs - fonts' }
Preferences class >> setCodeFontTo: aFont [
	"Establish the code font."

	UserInterfaceTheme current
		set: #standardCodeFont
		to: aFont;
		apply.
]

{ #category : #'initialization - misc' }
Preferences class >> setDefaultAnnotationInfo [
	"Preferences setDefaultAnnotationInfo"
	^ Parameters at: #MethodAnnotations put: self defaultAnnotationInfo
]

{ #category : #'prefs - fonts' }
Preferences class >> setDefaultFonts: defaultFontsSpec [
	"Since this is called from menus, we can take the opportunity to prompt for missing font styles."

	| fontNames map emphases |
	fontNames := defaultFontsSpec collect: [:array | array second].
	map := IdentityDictionary new.
	emphases := IdentityDictionary new.
	fontNames do: [:originalName | | decoded style |
		decoded := TextStyle decodeStyleName: originalName.
		style := map at: originalName put: (TextStyle named: decoded second).
		emphases at: originalName put: decoded first.
		style ifNil: [map at: originalName put: TextStyle default]].

	UserInterfaceTheme current applyAfter: [
		defaultFontsSpec do: [:triplet | self
			perform: triplet first
			with: (((map at: triplet second) fontOfPointSize: triplet third) emphasized: (emphases at: triplet second))]].
]

{ #category : #'prefs - fonts' }
Preferences class >> setDemoFonts [
	"Preferences setDemoFonts"

	| theme base |
	self inform: 'The current UI theme will be copied\and larger fonts be installed.' translated withCRs.
	
	(UserInterfaceTheme current name beginsWith: 'Demo')
		ifFalse: [
			UserInterfaceTheme allThemes
				detect: [:ea | (ea name beginsWith: 'Demo')
					and: [ea name endsWith: UserInterfaceTheme current name]]
				ifFound: [:uit | uit apply]
				ifNone: [			
					"Create DEMO version of current theme."
					theme := UserInterfaceTheme named: 'Demo'.
					theme merge: UserInterfaceTheme current overwrite: true.
					theme apply]].

	base := (TextStyle defaultFont name beginsWith: 'Darkmap')
		ifTrue: ['Darkmap DejaVu Sans'] ifFalse: ['Bitmap DejaVu Sans'].

	self setDefaultFonts: {
		{#setSystemFontTo:. base. 14}.
		{#setFixedFontTo:. 'BitstreamVeraSansMono'. 16}.
		{#setListFontTo:. base. 14}.
		{#setFlapsFontTo:. base. 12}.
		{#setEToysFontTo:. base. 14}.
		{#setPaintBoxButtonFontTo:. base. 14}.
		{#setMenuFontTo:. base	. 14}.
		{#setWindowTitleFontTo:. base, ' B'. 	14}.
		{#setBalloonHelpFontTo:. base. 12}.
		{#setCodeFontTo:. base. 14}.
		{#setButtonFontTo:. base. 	12}.
	}

]

{ #category : #'prefs - fonts' }
Preferences class >> setEToysFontTo: aFont [ 
	"change the font used in eToys environment"

	UserInterfaceTheme current
		set: #eToysFont
		to: aFont;
		apply.
]

{ #category : #'prefs - fonts' }
Preferences class >> setEToysTitleFontTo: aFont [ 
	"change the font used in eToys environment"

	UserInterfaceTheme current
		set: #eToysTitleFont
		to: aFont;
		apply.
]

{ #category : #'prefs - fonts' }
Preferences class >> setFixedFontTo: aFont [
	"Establish the default fixed text font and style"

	| aStyle newDefaultStyle |
	aFont ifNil: [^ self].
	aStyle := aFont textStyle ifNil: [^ self].
	
	newDefaultStyle := aStyle copy.
	newDefaultStyle defaultFontIndex: (aStyle fontIndexOf: aFont).

	UserInterfaceTheme current
		set: #standardFixedFont to: aFont;
		apply.

	TextStyle setDefaultFixed: newDefaultStyle.
]

{ #category : #'get\/set - flags' }
Preferences class >> setFlag: prefSymbol toValue: aBoolean [
	"Convenience method for consistency."
	
	^ self setPreference: prefSymbol toValue: aBoolean
]

{ #category : #'get\/set - flags' }
Preferences class >> setFlag: prefSymbol toValue: aBoolean during: aBlock [
	"Set the flag to the given value for the duration of aBlock"

	(self valueOfFlag: prefSymbol) in: [:previous |
		self setFlag: prefSymbol toValue: aBoolean.
		^ aBlock ensure: [self setFlag: prefSymbol toValue: previous]].
]

{ #category : #'prefs - fonts' }
Preferences class >> setFlapFontTo: aFont [

	UserInterfaceTheme current
		set: #standardFlapFont
		to: aFont;
		apply.	
		
	"FlapTab allSubInstancesDo:
		[:aFlapTab | aFlapTab reformatTextualTab]"
]

{ #category : #'prefs - fonts' }
Preferences class >> setFlapsFontTo: aFont [

	UserInterfaceTheme current
		set: #standardFlapFont
		to: aFont;
		apply.	
		
	"FlapTab allSubInstancesDo:
		[:aFlapTab | aFlapTab reformatTextualTab]"
]

{ #category : #'prefs - fonts' }
Preferences class >> setHaloLabelFontTo: aFont [ 
	"change the font used in eToys environment"

	UserInterfaceTheme current
		set: #haloLabelFont
		to: aFont;
		apply.
]

{ #category : #'prefs - fonts' }
Preferences class >> setListFontTo: aFont [
	"Set the list font as indicated"

	UserInterfaceTheme current
		set: #standardListFont
		to: aFont;
		apply.

	"Smalltalk at: #ListParagraph ifPresent: [:lp | lp initialize].
	Smalltalk at: #Flaps ifPresent: [:flaps | flaps replaceToolsFlap]"
]

{ #category : #'prefs - fonts' }
Preferences class >> setMenuFontTo: aFont [

	UserInterfaceTheme current
		set: #standardMenuFont
		to: aFont;
		apply.
		
	"Smalltalk at: #PopUpMenu ifPresent:[:aClass| aClass setMenuFontTo: aFont].
	TheWorldMainDockingBar updateInstances."
]

{ #category : #'initialization - misc' }
Preferences class >> setNotificationParametersForStandardPreferences [
	"Set up the notification parameters for the standard preferences that require need them.  When adding new Preferences that require use of the notification mechanism, users declare the notifcation info as part of the call that adds the preference, or afterwards -- the two relevant methods for doing that are:
 	Preferences.addPreference:categories:default:balloonHelp:projectLocal:changeInformee:changeSelector:   and
	Preference changeInformee:changeSelector:"

		"Preferences setNotificationParametersForStandardPreferences"

	
	#(	
		(annotationPanes		annotationPanesChanged)
		(eToyFriendly			eToyFriendlyChanged)
		(infiniteUndo			infiniteUndoChanged)
		(uniTilesClassic			classicTilesSettingToggled)
		(optionalButtons			optionalButtonsChanged)
		(showProjectNavigator	showProjectNavigatorChanged)
		(smartUpdating			smartUpdatingChanged)
		(universalTiles			universalTilesSettingToggled)
		(showSharedFlaps		sharedFlapsSettingChanged)
		(noviceMode		noviceModeSettingChanged)
	)  do:

			[:pair | | aPreference |
				aPreference := self preferenceAt: pair first.
				aPreference changeInformee: self changeSelector: pair second]
]

{ #category : #'prefs - fonts' }
Preferences class >> setPaintBoxButtonFontTo: aFont [ 
	"change the font used in the buttons in PaintBox."

	UserInterfaceTheme current
		set: #paintBoxButtonFont
		to: aFont;
		apply.
]

{ #category : #parameters }
Preferences class >> setParameter: paramName to: paramValue [
	"Set the given field in the parameters dictionary."

	Parameters at: paramName put: paramValue
]

{ #category : #'get\/set' }
Preferences class >> setPreference: prefSymbol toValue: anObject [
	"Set the given preference to the given value, and answer that value"

	^ (self
		preferenceAt: prefSymbol
		ifAbsent: [^ self addPreference: prefSymbol default: anObject])
			preferenceValue: anObject;
			yourself
]

{ #category : #'get\/set' }
Preferences class >> setPreference: prefSymbol toValue: anObject during: aBlock [

	(self valueOfPreference: prefSymbol) in: [:previous |
		self setPreference: prefSymbol toValue: anObject.
		^ aBlock ensure: [self setPreference: prefSymbol toValue: previous]]
]

{ #category : #initialization }
Preferences class >> setPreferencesFrom: listOfPairs [
	"Given a list of <preferenceName, value> pairs, set preference values.  This method is tolerent of the value being supplied either a Boolean or else one of the symbols #true and #false.  Also, a new-value of #noOpinion will result in that 'preference's value not being changed."

	listOfPairs do:
		[:aPair |
			(aPair second == #noOpinion) ifFalse:
				[Preferences setPreference: aPair first toValue: ((aPair second == #true) or: [aPair second == true])]]

"
Preferences setPreferencesFrom: #(( mouseOverForKeyboardFocus false))
Preferences setPreferencesFrom: {{  #mouseOverForKeyboardFocus. true}}
"
]

{ #category : #'prefs - fonts' }
Preferences class >> setSystemFontTo: aFont [
	"Establish the default text font and style"

	| aStyle newDefaultStyle |
	aFont ifNil: [^ self].
	aStyle := aFont textStyle ifNil: [^ self].
	newDefaultStyle := aStyle copy.
	newDefaultStyle defaultFontIndex: (aStyle fontIndexOf: aFont).

	UserInterfaceTheme current
		set: #standardSystemFont to: aFont;
		apply.

	TextStyle setDefault: newDefaultStyle.
	Flaps replaceToolsFlap.
	ScriptingSystem resetStandardPartsBin.
	

]

{ #category : #'prefs - fonts' }
Preferences class >> setWindowTitleFontTo: aFont [
	"Set the window-title font to be as indicated"

	UserInterfaceTheme current
		set: #windowTitleFont
		to: aFont;
		apply.

	"(Smalltalk hasClassNamed: #StandardSystemView)
		ifTrue: [(Smalltalk at: #StandardSystemView) setLabelStyle].
	(Smalltalk hasClassNamed: #Flaps)
		ifTrue: [(Smalltalk at: #Flaps) replaceToolsFlap]"

]

{ #category : #'updating - system' }
Preferences class >> sharedFlapsSettingChanged [
	"The current value of the showSharedFlaps flag has changed; now react"

	self showSharedFlaps  "viz. the new setting"
		ifFalse:		
			[Flaps globalFlapTabsIfAny do:
				[:aFlapTab | Flaps removeFlapTab: aFlapTab keepInList: true]]

		ifTrue:
			[Smalltalk isMorphic ifTrue:
				[self currentWorld addGlobalFlaps]]
]

{ #category : #'standard queries' }
Preferences class >> showAdvancedNavigatorButtons [
	^ self
		valueOfFlag: #showAdvancedNavigatorButtons
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> showBoundsInHalo [
	^ self
		valueOfFlag: #showBoundsInHalo
		ifAbsent: [true]
]

{ #category : #'prefs - halos' }
Preferences class >> showChooseGraphicHaloHandle [
	"Hard-coded; reimplement to change behavior.  If this preference is set to true, then a choose-graphic halo handle may appear on the halo of SketchMorphs"

	^ false
]

{ #category : #'standard queries' }
Preferences class >> showDirectionForSketches [
	^ self
		valueOfFlag: #showDirectionForSketches
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> showDirectionHandles [
	^ self
		valueOfFlag: #showDirectionHandles
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> showFlapsWhenPublishing [
	^ self
		valueOfFlag: #showFlapsWhenPublishing
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> showProjectNavigator [
	^ self
		valueOfFlag: #showProjectNavigator
		ifAbsent: [ true ]
]

{ #category : #'updating - system' }
Preferences class >> showProjectNavigatorChanged [
	"The showProjectNavigatorChanged preference changed; react"
	
	Project current assureNavigatorPresenceMatchesPreference
]

{ #category : #'standard queries' }
Preferences class >> showSecurityStatus [
	^ self
		valueOfFlag: #showSecurityStatus
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> showSharedFlaps [
	^ self
		valueOfFlag: #showSharedFlaps
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> showSplitterHandles [
	^ self
		valueOfFlag: #showSplitterHandles
		ifAbsent: [false]
]

{ #category : #'standard queries' }
Preferences class >> signProjectFiles [
	^ self
		valueOfFlag: #signProjectFiles
		ifAbsent: [ true ]
]

{ #category : #'prefs - halos' }
Preferences class >> simpleFullHaloSpecifications [
	"This method gives the specs for the 'full' handles variant when simple halos are in effect"

	"Preferences resetHaloSpecifications"

	^ #(
	"  	selector				horiz		vert			color info						icon key
		---------				------		-----------		-------------------------------		---------------"
	(addDebugHandle:		right		topCenter		(blue	veryMuchLighter)		'Halo-Debug')
	(addPoohHandle:			right		center			(white)							'Halo-Pooh')
	(addDismissHandle:		left			top				(red		muchLighter)			'Halo-Dismiss')
	(addRotateHandle:		left			bottom			(blue)							'Halo-Rot')
	(addMenuHandle:		leftCenter	top				(red)							'Halo-Menu')
	(addTileHandle:			left			bottomCenter	(lightBrown)					'Halo-Tile')
	(addViewHandle:			left			center			(cyan)							'Halo-View')
	(addGrabHandle:			center		top				(black)							'Halo-Grab')
	(addDragHandle:			rightCenter	top				(brown)							'Halo-Drag')
	(addDupHandle:			right		top				(green)							'Halo-Dup')	
	(addMakeSiblingHandle:	right		top				(green muchDarker)				'Halo-Dup')	
	(addHelpHandle:			center		bottom			(lightBlue)						'Halo-Help')
	(addGrowHandle:		right		bottom			(yellow)						'Halo-Scale')
	(addScaleHandle:		right		bottom			(lightOrange)					'Halo-Scale')
	(addFewerHandlesHandle:	left		topCenter		(paleBuff)						'Halo-FewerHandles')
	(addScriptHandle:		right		bottomCenter	(green muchLighter)			'Halo-Script')
	(addPaintBgdHandle:		right		center			(lightGray)						'Halo-Paint')
	(addRepaintHandle:		right		center			(lightGray)						'Halo-Paint')
	(addFontSizeHandle:		leftCenter	bottom			(lightGreen)						'Halo-FontSize')
	(addFontStyleHandle:		center		bottom			(lightRed)						'Halo-FontStyle')
	(addFontEmphHandle:	rightCenter	bottom			(lightBrown darker)		  'Halo-FontEmph')
	(addRecolorHandle:		right		bottomCenter	(magenta darker)				'Halo-Recolor')

		) 
]

{ #category : #'prefs - halos' }
Preferences class >> simpleHalosInForce [
	^ (self preferenceAt: #haloTheme) preferenceValue == #simpleFullHaloSpecifications
]

{ #category : #'standard queries' }
Preferences class >> simpleMenus [
	^ self
		valueOfFlag: #simpleMenus
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> smartUpdating [
	^ self
		valueOfFlag: #smartUpdating
		ifAbsent: [ true ]
]

{ #category : #'updating - system' }
Preferences class >> smartUpdatingChanged [
	"The smartUpdating preference changed. React"

	SystemWindow allSubInstancesDo:
		[:aWindow | aWindow amendSteppingStatus]

	"NOTE: This makes this preference always behave like a global preference, which is problematical"
]

{ #category : #'support - misc' }
Preferences class >> staggerPolicyString [
	"Answer the string to be shown in a menu to represent the 
	stagger-policy status"
	^ ((self valueOfFlag: #reverseWindowStagger)
		ifTrue: ['<yes>']
		ifFalse: ['<no>']), 'stagger windows' translated
]

{ #category : #'standard queries' }
Preferences class >> standaloneSecurityChecksEnabled [
	^ self
		valueOfFlag: #standaloneSecurityChecksEnabled
		ifAbsent: [false]
]

{ #category : #'prefs - fonts' }
Preferences class >> standardBalloonHelpFont [
	
	^ (UserInterfaceTheme current get: #balloonHelpFont)
		ifNil: [TextStyle defaultFont]
]

{ #category : #'prefs - fonts' }
Preferences class >> standardButtonFont [
	
	^ (UserInterfaceTheme current get: #standardButtonFont)
		ifNil: [TextStyle defaultFont]
]

{ #category : #'prefs - fonts' }
Preferences class >> standardCodeFont [

	^ (UserInterfaceTheme current get: #standardCodeFont)
		ifNil: [TextStyle defaultFont]
]

{ #category : #'prefs - fonts' }
Preferences class >> standardDefaultTextFont [
	^TextStyle defaultFont
]

{ #category : #'prefs - fonts' }
Preferences class >> standardEToysFont [

	^ (UserInterfaceTheme current get: #eToysFont)
		ifNil: [self standardButtonFont]
]

{ #category : #'prefs - fonts' }
Preferences class >> standardEToysTitleFont [

	^ (UserInterfaceTheme current get: #eToysTitleFont)
		ifNil: [self standardEToysFont]
]

{ #category : #'prefs - fonts' }
Preferences class >> standardFixedFont [
	"Answer the standard fixed font "

	^ (UserInterfaceTheme current get: #standardFixedFont)
		ifNil: [TextStyle defaultFixedFont]
]

{ #category : #'prefs - fonts' }
Preferences class >> standardFlapFont [
	
	^ (UserInterfaceTheme current get: #standardFlapFont)
		ifNil: [self standardButtonFont]
]

{ #category : #'prefs - fonts' }
Preferences class >> standardHaloLabelFont [

	^ (UserInterfaceTheme current get: #haloLabelFont)
		ifNil: [TextStyle defaultFont]
]

{ #category : #'prefs - fonts' }
Preferences class >> standardListFont [

	^ (UserInterfaceTheme current get: #standardListFont)
		ifNil: [TextStyle defaultFont]
]

{ #category : #'prefs - fonts' }
Preferences class >> standardMenuFont [

	^ (UserInterfaceTheme current get: #standardMenuFont)
		ifNil: [TextStyle defaultFont]
]

{ #category : #'prefs - fonts' }
Preferences class >> standardPaintBoxButtonFont [

	^ (UserInterfaceTheme current get: #paintBoxButtonFont)
		ifNil: [self standardButtonFont]
]

{ #category : #'prefs - fonts' }
Preferences class >> standardSystemFont [
	"Answer the standard system font "

	^ (UserInterfaceTheme current get: #standardSystemFont)
		ifNil: [TextStyle defaultFont]
]

{ #category : #'prefs - fonts' }
Preferences class >> standardWindowTitleFont [
	"Answer the standard font to use for window titles"

	^ (UserInterfaceTheme current get: #windowTitleFont)
		ifNil: [TextStyle defaultFont]
]

{ #category : #'standard queries' }
Preferences class >> startInUntrustedDirectory [
	^ self
		valueOfFlag: #startInUntrustedDirectory
		ifAbsent: [ false ]
]

{ #category : #'initialization - save\/load' }
Preferences class >> storePreferencesIn: aFileName [ 
	| stream prefsSnapshot |
	#(Prevailing PersonalPreferences) do:
		[:ea |
		 Parameters removeKey: ea ifAbsent: []].
	stream := ReferenceStream fileNamed: aFileName.
	stream nextPut: Parameters.
	prefsSnapshot := preferencesDictionary copy.
	prefsSnapshot keysAndValuesDo: [:key :pref | prefsSnapshot at: key put: pref asPreference].
	stream nextPut: prefsSnapshot.
	stream nextPut: (Smalltalk isMorphic 
						 ifTrue:[Project current world fillStyle]
						 ifFalse:[self desktopColor]).
	stream close
]

{ #category : #'initialization - save\/load' }
Preferences class >> storePreferencesToDisk [
	Cursor wait showWhile: [
		[ self storePreferencesIn: 'my.prefs' ] on: Error do: [ :ex | self inform: 'there was an error storing your preferences to disk' ]]
]

{ #category : #'prefs - fonts' }
Preferences class >> subPixelRenderColorFonts [
	^ self
		valueOfFlag: #subPixelRenderColorFonts
		ifAbsent: [ true ]
]

{ #category : #'prefs - fonts' }
Preferences class >> subPixelRenderFonts [
	^ self
		valueOfFlag: #subPixelRenderFonts
		ifAbsent: [ true ]
]

{ #category : #'prefs - misc' }
Preferences class >> suppressWindowTitlesInInstanceBrowsers [
	"Hard-coded for the moment: answer whether instance browsers should suppresss their window titles"

	^ false
]

{ #category : #'standard queries' }
Preferences class >> swapControlAndAltKeys [
	^ self
		valueOfFlag: #swapControlAndAltKeys
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> swapMouseButtons [
	^ self
		valueOfFlag: #swapMouseButtons
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> systemWindowEmbedOK [
	^ self
		valueOfFlag: #systemWindowEmbedOK
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> tabAmongFields [
	^ self
		valueOfFlag: #tabAmongFields
		ifAbsent: [ true ]
]

{ #category : #'themes - tools' }
Preferences class >> themeChoiceButtonOfColor: aColor font: aFont [
	"Answer a button inviting the user to choose a theme"

	| aButton |
	aButton := SimpleButtonMorph new target: self; actionSelector: #offerThemesMenu.
	aButton label: 'change theme...' translated font: aFont.
	aButton color: aColor.
	aButton setBalloonText: 'Numerous "Preferences" govern many things about the way Squeak looks and behaves.  Set individual preferences using a "Preferences" panel.  Set an entire "theme" of many Preferences all at the same time by pressing this "change theme" button and choosing a theme to install.  Look in category "themes" in Preferences class to see what each theme does; add your own methods to the "themes" category and they will show up in the list of theme choices.' translated.
	^ aButton
]

{ #category : #'standard queries' }
Preferences class >> tileTranslucentDrag [
	^ self
		valueOfFlag: #tileTranslucentDrag
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> timeStampsInMenuTitles [
	^ self
		valueOfFlag: #timeStampsInMenuTitles
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> tinyDisplay [
	^ self
		valueOfFlag: #tinyDisplay
		ifAbsent: [ false ]
]

{ #category : #'get\/set - flags' }
Preferences class >> toggle: flagName [
	"Toggle the given preference. prefSymbol must be of a boolean preference"
	
	^ self setFlag: flagName toValue: (self valueOfFlag: flagName) not
]

{ #category : #'standard queries' }
Preferences class >> traceMessages [
	^ self
		valueOfFlag: #traceMessages
		ifAbsent: [false]
]

{ #category : #'standard queries' }
Preferences class >> turnOffPowerManager [
	^ self
		valueOfFlag: #turnOffPowerManager
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> twentyFourHourFileStamps [
	^ self
		valueOfFlag: #twentyFourHourFileStamps
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> typeCheckingInTileScripting [
	^ self
		valueOfFlag: #typeCheckingInTileScripting
		ifAbsent: [ true ]
]

{ #category : #support }
Preferences class >> typeForValue: anObject [
	"Returns the preference type for the given value to be distinguished in tools."

	{
		AbstractFont -> #Font.
		Boolean -> #Boolean.
		Color -> #Color.
		String -> #String.
		Number -> #Number
	} do: [:spec | (anObject isKindOf: spec key) ifTrue: [^ spec value]].

	^ #Object
	



]

{ #category : #defaults }
Preferences class >> unclassifiedCategory [
	"Generic category to be used when no specific alternative is provided."
	
	^ #unclassified
]

{ #category : #'standard queries' }
Preferences class >> uniTilesClassic [
	^ self
		valueOfFlag: #uniTilesClassic
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> uniqueNamesInHalos [
	^ self
		valueOfFlag: #uniqueNamesInHalos
		ifAbsent: [ false ]
]

{ #category : #'standard queries' }
Preferences class >> universalTiles [
	^ self
		valueOfFlag: #universalTiles
		ifAbsent: [false]
]

{ #category : #'updating - system' }
Preferences class >> universalTilesSettingToggled [
	"The current value of the universalTiles flag has changed; now react"

	(self preferenceAt: #universalTiles ifAbsent: [^ self]) localToProject ifFalse:
			[^ self inform: 
'This is troubling -- you may regret having done that, because
the change will apply to *all projects*, including pre-existing ones.  Unfortunately this check is done after the damage is done, so you
may be hosed.  Fortunately, however, you can simply reverse your choice right now and perhaps no deep damage will have been done.'].

	self universalTiles  "User just switched project to classic tiles"
		ifFalse:
			[self inform: 
'CAUTION -- if you had any scripted objects in
this project that already used universal tiles, 
there is no reasonable way to go back to classic
tiles.  Recommended course of action in that case:
just toggle this preference right back to true.']
		ifTrue:
			[Preferences capitalizedReferences ifFalse:
				[Preferences enable: #capitalizedReferences.
				self inform: 
'Note that the "capitalizedReferences" flag
has now been automatically set to true for
you, since this is required for the use of
universal tiles.'].
			Project current isMorphic ifTrue:
				[Project current world recreateScripts]]
]

{ #category : #'standard queries' }
Preferences class >> unlimitedPaintArea [
	^ self
		valueOfFlag: #unlimitedPaintArea
		ifAbsent: [ false ]
]

{ #category : #'class initialization' }
Preferences class >> unload [
	"Unload the receiver from global registries"

	self environment at: #Flaps ifPresent: [:cl |
	cl unregisterQuadsWithReceiver: self] 
]

{ #category : #'standard queries' }
Preferences class >> useButtonPropertiesToFire [
	^ self
		valueOfFlag: #useButtonProprtiesToFire
		ifAbsent: [ false ]
]

{ #category : #'prefs - misc' }
Preferences class >> useCategoryListsInViewers [
	"Temporarily hard-coded pending viewer work underway"
	^ false
]

{ #category : #'prefs - misc' }
Preferences class >> useFormsInPaintBox [

	^ self valueOfFlag: #useFormsInPaintBox
]

{ #category : #'prefs - misc' }
Preferences class >> useFormsInPaintBox: aBoolean [

	self setPreference: #useFormsInPaintBox toValue: aBoolean

]

{ #category : #'standard queries' }
Preferences class >> useSmartLabels [
	^ self
		valueOfFlag: #useSmartLabels
		ifAbsent: [false]
]

{ #category : #'standard queries' }
Preferences class >> useUndo [
	^ self
		valueOfFlag: #useUndo
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> useVectorVocabulary [
	^ self
		valueOfFlag: #useVectorVocabulary
		ifAbsent: [ false ]
]

{ #category : #'get\/set - flags' }
Preferences class >> valueOfFlag: aFlagName [
	"Utility method for all the preferences that are boolean, and for backward compatibility"
	^self valueOfFlag: aFlagName ifAbsent: [false]
]

{ #category : #'get\/set - flags' }
Preferences class >> valueOfFlag: aFlagName ifAbsent: booleanValuedBlock [
	"the same as in #valueOfFlag:"
	^self valueOfPreference: aFlagName ifAbsent: booleanValuedBlock.
]

{ #category : #'get\/set' }
Preferences class >> valueOfPreference: aPreferenceSymbol [
	"Answer the value of the given preference"
	^self valueOfPreference: aPreferenceSymbol ifAbsent: []
]

{ #category : #'get\/set' }
Preferences class >> valueOfPreference: aPreferenceSymbol ifAbsent: block [
	"Answer the value of the given preference"
	^ (self preferenceAt: aPreferenceSymbol ifAbsent: [^ block value]) preferenceValue
]

{ #category : #'updating - system' }
Preferences class >> vectorVocabularySettingChanged [
	"The current value of the useVectorVocabulary flag has changed; now react.  No senders, but invoked by the Preference object associated with the #useVectorVocabulary preference."

	Smalltalk isMorphic ifFalse: [^ self].
	Project current world makeVectorUseConformToPreference.
]

{ #category : #'standard queries' }
Preferences class >> viewersInFlaps [
	^ self
		valueOfFlag: #viewersInFlaps
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> visualExplorer [
	^ self
		valueOfFlag: #visualExplorer
		ifAbsent: [ true ]
]

{ #category : #'support - misc' }
Preferences class >> wantsChangeSetLogging [
	"Answer whether method changes in the receiver should be logged to current change set.  This circumlocution avoids such logging for programmatically-compiled methods in Preferences, removing an annoyance"

	^ Utilities authorInitialsPerSe  ~= 'programmatic'
]

{ #category : #'standard queries' }
Preferences class >> warnAboutInsecureContent [
	^ self
		valueOfFlag: #warnAboutInsecureContent
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> warnIfNoChangesFile [
	^ self
		valueOfFlag: #warnIfNoChangesFile
		ifAbsent: [ true ]
]

{ #category : #'standard queries' }
Preferences class >> warnIfNoSourcesFile [
	^ self
		valueOfFlag: #warnIfNoSourcesFile
		ifAbsent: [ true ]
]

{ #category : #'prefs - fonts' }
Preferences class >> windowTitleFont [
	"Answer the standard font to use for window titles"
	
	^ (UserInterfaceTheme current get: #windowTitleFont)
		ifNil: [TextStyle defaultFont]
]

{ #category : #'prefs - fonts' }
Preferences class >> windowTitleStyle [
	"Answer the standard style to use for window titles"
	^  self windowTitleFont textStyle
]

{ #category : #'standard queries' }
Preferences class >> wordStyleCursorMovement [
	^ self
		valueOfFlag: #wordStyleCursorMovement
		ifAbsent: [ true ]
]
