Class {
	#name : #MonokaiTheme,
	#superclass : #UserInterfaceTheme,
	#category : #'System-Support'
}

{ #category : #'instance creation' }
MonokaiTheme class >> addDarkButtons: theme [
	"self createDark apply."
	theme
		set: #borderColor for: #PluggableButtonMorph to: self backgroundColor;
		set: #color for: #PluggableButtonMorph to: self invisibleColor;
		set: #textColor for: #PluggableButtonMorph to: self yellow;

		set: #selectionModifier for: #PluggableButtonMorph to: [ [:c | c adjustBrightness: -0.1] ];
		set: #hoverModifier for: #PluggableButtonMorph to: [ [:c | c adjustBrightness: -0.1] ];
		set: #feedbackModifier for: #PluggableButtonMorph to: [ [:c | c adjustBrightness: -0.3] ].
	
	"And the plus-version."
	theme set: #disabledTextColor for: #PluggableButtonMorphPlus to: self grayDarker.

]

{ #category : #'instance creation' }
MonokaiTheme class >> addDarkDialogs: theme [
	"self createDark apply."
	theme
		set: #borderColor for: #DialogWindow to: self backgroundColor muchDarker;
		set: #color for: #DialogWindow to: self invisibleColor;

		set: #titleColor for: #DialogWindow to: self backgroundColor;
		set: #titleTextColor for: #DialogWindow to: self foregroundColor;
		
		set: #textColor for: #DialogWindow to: self yellow;
		
		set: #okColor for: #DialogWindow to: self green muchDarker;
		set: #cancelColor for: #DialogWindow to: self orange muchDarker;
		set: #buttonColor for: #DialogWindow to: self invisibleColor;
		set: #selectionModifier for: #DialogWindow to: [ [:c | c adjustBrightness: -0.1 ] ].
	
	"The List Chooser is a dialog, too."
	theme
		set: #addColor for: #ListChooser to: self blue;
		set: #disabledColor for: #ListChooser to: Color transparent.

		
	"And the system progress bar."
	theme
		set: #color for: #SystemProgressBarMorph to: self invisibleColor;
		set: #barColor for: #SystemProgressBarMorph to: self foregroundColor.
		
	"And the balloon morphs."
	theme
		set: #borderColor for: #NewBalloonMorph to: self backgroundColor muchDarker;
		set: #color for: #NewBalloonMorph to: self invisibleColor.
]

{ #category : #'instance creation' }
MonokaiTheme class >> addDarkFonts: theme [

	"Set-up fonts."
	theme
		set: #balloonHelpFont to: [StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: 7];
		set: #standardButtonFont to: [StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: 7];
		set: #standardCodeFont to: [StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: 9];
		set: #standardFlapFont to: [StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: 7 emphasized: TextEmphasis bold emphasisCode];
		set: #haloLabelFont to: [StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: 9];
		set: #standardListFont to: [StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: 9];
		set: #standardMenuFont to: [StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: 9];
		set: #standardSystemFont to: [StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: 9];
		set: #windowTitleFont to: [StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: 9].
]

{ #category : #'instance creation' }
MonokaiTheme class >> addDarkMenusAndDockingBars: theme [
	"self createDark apply."
	theme
		set: #borderWidth for: #MenuMorph to: 1;
		set: #borderColor for: #MenuMorph to: self invisibleColor;
		set: #color for: #MenuMorph to: self backgroundColor;
		set: #titleTextColor for: #MenuMorph to: self yellow;
		set: #lineColor for: #MenuMorph to: self invisibleColor;
		set: #lineStyle for: #MenuMorph to: BorderStyle simple;
		set: #lineWidth for: #MenuMorph to: 1.
		
	theme
		set: #textColor for: #MenuItemMorph to: self foregroundColor;
		set: #disabledTextColor for: #MenuItemMorph to: self grayLight;
		set: #selectionColor for: #MenuItemMorph to: self invisibleColor;
		set: #selectionTextColor for: #MenuItemMorph to: self yellow.
		"set: #subMenuMarker for: #MenuItemMorph to: nil." "Use hard-coded default. See MenuItemMorph."
		
	"The world main docking bar."
	theme
		set: #color for: #DockingBarMorph to: self invisibleColor;
		set: #selectionColor for: #DockingBarItemMorph to: self grayLight;
		set: #logoColor for: #TheWorldMainDockingBar to: self foregroundColor;
		set: #selectionLogoColor for: #TheWorldMainDockingBar to: self yellow.
]

{ #category : #'instance creation' }
MonokaiTheme class >> addDarkScrollables: theme [
	"self createDark apply."

	"Scroll bars"
	theme
		set: #thumbColor for: #ScrollBar to: self backgroundColor;
		set: #thumbBorderColor for: #ScrollBar to: self backgroundColor;
		set: #thumbBorderWidth for: #ScrollBar to: 1;
		set: #thumbColorModifier for: #ScrollBar to: [ [:c | c adjustBrightness: -0.2] ];
		set: #pagingAreaColorModifier for: #ScrollBar to: [ [:c | Color transparent ] ];
		set: #borderColorModifier for: #ScrollBar to: [ [:c | c adjustBrightness: -0.2] ].
	
	"Scroll panes (includes generic stuff for list widgets, tree widgets, and text widgets."
	theme
		set: #borderWidth for: #ScrollPane to: 0;
	"	set: #borderColor for: #ScrollPane to: Color transparent;"
		set: #color for: #ScrollPane to: self backgroundColor.
		
	"List widgets"
	theme
		set: #textColor for: #PluggableListMorph to: self foregroundColor;
		set: #selectionColor for: #PluggableListMorph to: self invisibleColor;
		set: #selectionTextColor for: #PluggableListMorph to: self yellow;
		set: #filterColor for: #PluggableListMorph to: self yellow;
		set: #filterTextColor for: #PluggableListMorph to: self backgroundColor;
		set: #preSelectionModifier for: #PluggableListMorph to: [ [:c | c lighter alpha: 0.5 ] ];
		set: #hoverSelectionModifier for: #PluggableListMorph to: [ [:c | c lighter alpha: 0.5 ] ].
		
	"Tree widgets"
	theme
		set: #highlightTextColor for: #SimpleHierarchicalListMorph to: self yellow lighter lighter;
		set: #lineColor for: #SimpleHierarchicalListMorph to: self grayLight.
	
	"Text widgets"
	theme
		set: #textColor for: #PluggableTextMorph to: self foregroundColor;
		set: #caretColor for: #PluggableTextMorph to: self yellow;
		set: #selectionColor for: #PluggableTextMorph to: self invisibleColor;
		set: #unfocusedSelectionModifier for: #PluggableTextMorph to: [ [:c | (Color r: 0.285 g: 0.282 b: 0.242) "invisible color"] ];
		set: #adornmentReadOnly for: #PluggableTextMorph to: self magenta;
		set: #adornmentRefuse for: #PluggableTextMorph to: self cyan;
		set: #adornmentConflict for: #PluggableTextMorph to: self red;
		set: #adornmentDiff for: #PluggableTextMorph to: self green;
		set: #adornmentNormalEdit for: #PluggableTextMorph to: self orange;
		set: #adornmentDiffEdit for: #PluggableTextMorph to: self yellow.
	theme
		set: #balloonTextColor for: #PluggableTextMorphPlus to: self grayLight.
]

{ #category : #'instance creation' }
MonokaiTheme class >> addDarkSyntaxHighlighting: theme [
	"self createDark apply."

	theme
		set: #color for: #TextAction to: self blue;

		set: #default for: #SHTextStylerST80 to: {self foregroundColor};
		set: #invalid for: #SHTextStylerST80 to: {self red};
		set: #excessCode for: #SHTextStylerST80 to: {self red};
		set: #comment for: #SHTextStylerST80 to: {self commentColor};
		set: #unfinishedComment for: #SHTextStylerST80 to: {self red. TextEmphasis italic};
		set: #'$' for: #SHTextStylerST80 to: {self red};
		set: #character for: #SHTextStylerST80 to: {self numberColor};
		set: #integer for: #SHTextStylerST80 to: {self numberColor};
		set: #number for: #SHTextStylerST80 to: {self numberColor};	
		set: #- for: #SHTextStylerST80 to: {self red};
		set: #symbol for: #SHTextStylerST80 to: {self orange};	
		set: #stringSymbol for: #SHTextStylerST80 to: {self orange};	
		set: #literalArray for: #SHTextStylerST80 to: {self orange};
		set: #string for: #SHTextStylerST80 to: {self stringColor. TextEmphasis normal};
		set: #unfinishedString for: #SHTextStylerST80 to: {self red. TextEmphasis normal};
		set: #assignment for: #SHTextStylerST80 to: {nil. TextEmphasis bold};
		set: #ansiAssignment for: #SHTextStylerST80 to: {nil. TextEmphasis bold};
		set: #literal for: #SHTextStylerST80 to: {nil. TextEmphasis italic};
		set: #keyword for: #SHTextStylerST80 to: {self blue};
		set: #binary for: #SHTextStylerST80 to: {self blue};	
		set: #unary for: #SHTextStylerST80 to: {self blue};
		set: #incompleteKeyword for: #SHTextStylerST80 to: {self foregroundColor. TextEmphasis underlined};
		set: #incompleteBinary for: #SHTextStylerST80 to: {self foregroundColor. TextEmphasis underlined};	
		set: #incompleteUnary for: #SHTextStylerST80 to: {self foregroundColor. TextEmphasis underlined};
		set: #undefinedKeyword for: #SHTextStylerST80 to: {self red};
		set: #undefinedBinary for: #SHTextStylerST80 to: {self red};	
		set: #undefinedUnary for: #SHTextStylerST80 to: {self red};													
		set: #patternKeyword for: #SHTextStylerST80 to: {nil};
		set: #patternBinary for: #SHTextStylerST80 to: {nil};
		set: #patternUnary for: #SHTextStylerST80 to: {nil};	
		set: #self for: #SHTextStylerST80 to: {Color gray: 0.6};
		set: #super for: #SHTextStylerST80 to: {Color gray: 0.6}; 
		set: #true for: #SHTextStylerST80 to: {self red};
		set: #false for: #SHTextStylerST80 to: {self red};
		set: #nil for: #SHTextStylerST80 to: {self red};
		set: #thisContext for: #SHTextStylerST80 to: {self red};
		set: #return for: #SHTextStylerST80 to: {self red};
		set: #patternArg for: #SHTextStylerST80 to: {self blue};	
		set: #methodArg for: #SHTextStylerST80 to: {self blue};
		set: #blockPatternArg for: #SHTextStylerST80 to: {self blue};
		set: #blockArg for: #SHTextStylerST80 to: {self blue};
		set: #argument for: #SHTextStylerST80 to: {self blue};
		set: #blockArgColon for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #leftParenthesis for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #rightParenthesis for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #leftParenthesis1 for: #SHTextStylerST80 to: {self green}; 
		set: #rightParenthesis1 for: #SHTextStylerST80 to: {self green}; 
		set: #leftParenthesis2 for: #SHTextStylerST80 to: {self magenta}; 
		set: #rightParenthesis2 for: #SHTextStylerST80 to: {self magenta}; 
		set: #leftParenthesis3 for: #SHTextStylerST80 to: {self red}; 
		set: #rightParenthesis3 for: #SHTextStylerST80 to: {self red}; 
		set: #leftParenthesis4 for: #SHTextStylerST80 to: {self green}; 
		set: #rightParenthesis4 for: #SHTextStylerST80 to: {self green}; 
		set: #leftParenthesis5 for: #SHTextStylerST80 to: {self orange}; 
		set: #rightParenthesis5 for: #SHTextStylerST80 to: {self orange}; 
		set: #leftParenthesis6 for: #SHTextStylerST80 to: {self magenta}; 
		set: #rightParenthesis6 for: #SHTextStylerST80 to: {self magenta}; 
		set: #leftParenthesis7 for: #SHTextStylerST80 to: {self blue}; 
		set: #rightParenthesis7 for: #SHTextStylerST80 to: {self blue}; 
		set: #blockStart for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #blockEnd for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #blockStart1 for: #SHTextStylerST80 to: {self green}; 
		set: #blockEnd1 for: #SHTextStylerST80 to: {self green}; 
		set: #blockStart2 for: #SHTextStylerST80 to: {self magenta}; 
		set: #blockEnd2 for: #SHTextStylerST80 to: {self magenta}; 
		set: #blockStart3 for: #SHTextStylerST80 to: {self red}; 
		set: #blockEnd3 for: #SHTextStylerST80 to: {self red}; 
		set: #blockStart4 for: #SHTextStylerST80 to: {self green}; 
		set: #blockEnd4 for: #SHTextStylerST80 to: {self green}; 
		set: #blockStart5 for: #SHTextStylerST80 to: {self orange}; 
		set: #blockEnd5 for: #SHTextStylerST80 to: {self orange}; 
		set: #blockStart6 for: #SHTextStylerST80 to: {self magenta}; 
		set: #blockEnd6 for: #SHTextStylerST80 to: {self magenta}; 
		set: #blockStart7 for: #SHTextStylerST80 to: {self blue}; 
		set: #blockEnd7 for: #SHTextStylerST80 to: {self blue}; 																																																		
		set: #arrayStart for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #arrayEnd for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #arrayStart1 for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #arrayEnd1 for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #byteArrayStart for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #byteArrayEnd for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #byteArrayStart1 for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #byteArrayEnd1 for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #leftBrace for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #rightBrace for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #cascadeSeparator for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #statementSeparator for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #externalCallType for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #externalCallTypePointerIndicator for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #primitiveOrExternalCallStart for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #primitiveOrExternalCallEnd for: #SHTextStylerST80 to: {self foregroundColor};
		set: #methodTempBar for: #SHTextStylerST80 to: {self foregroundColor}; 
		set: #blockTempBar for: #SHTextStylerST80 to: {self foregroundColor};
		set: #blockArgsBar for: #SHTextStylerST80 to: {self foregroundColor};
		set: #primitive for: #SHTextStylerST80 to: {self green. TextEmphasis bold};
		set: #pragmaKeyword for: #SHTextStylerST80 to: {self green. TextEmphasis bold};
		set: #pragmaUnary for: #SHTextStylerST80 to: {self green. TextEmphasis bold};
		set: #pragmaBinary for: #SHTextStylerST80 to: {self green. TextEmphasis bold};									
		set: #externalFunctionCallingConvention for: #SHTextStylerST80 to: {self green. TextEmphasis bold}; 
		set: #module for: #SHTextStylerST80 to: {self green. TextEmphasis bold};
		set: #blockTempVar for: #SHTextStylerST80 to: {self foregroundColor};
		set: #blockPatternTempVar for: #SHTextStylerST80 to: {self foregroundColor};
		set: #instVar for: #SHTextStylerST80 to: {self foregroundColor};
		set: #workspaceVar for: #SHTextStylerST80 to: {self foregroundColor};
		set: #undefinedIdentifier for: #SHTextStylerST80 to: {self red};
		set: #incompleteIdentifier for: #SHTextStylerST80 to: {self foregroundColor. {TextEmphasis italic. TextEmphasis underlined}};
		set: #tempVar for: #SHTextStylerST80 to: {self foregroundColor};
		set: #patternTempVar for: #SHTextStylerST80 to: {self foregroundColor};
		set: #poolConstant for: #SHTextStylerST80 to: {self classColor};
		set: #classVar for: #SHTextStylerST80 to: {self classColor};
		set: #globalVar for: #SHTextStylerST80 to: {self classColor}.
		
	"And the text differ"
	theme	
		set: #insertTextAttributes for: #TextDiffBuilder to: { TextColor color: self red };
		set: #removeTextAttributes for: #TextDiffBuilder to: { TextEmphasis struckOut. TextColor color: self blue };
		set: #normalTextAttributes for: #TextDiffBuilder to: { TextEmphasis normal }.
]

{ #category : #'instance creation' }
MonokaiTheme class >> addDarkToolColors: theme [
	"Tool-specific colors."
	
	theme 
		set: #failureColor for: #TestRunner to: self yellow;
		set: #errorColor for: #TestRunner to: self red;
		set: #passColor for: #TestRunner to: self green;
		
		set: #failureTextColor for: #TestRunner to: self backgroundColor;
		set: #errorTextColor for: #TestRunner to: self backgroundColor;
		set: #passTextColor for: #TestRunner to: self backgroundColor.
		
	theme
		set: #ignoredOperationAttributes for: #MCOperationsBrowser to: {TextColor color: self grayLight}.
		
	"Browser."
	theme
		set: #noClassCommentColor for: #Browser to: self red;
		set: #deprecatedMessageAttributes for: #CodeHolder to: { TextEmphasis struckOut. TextColor color: self grayLight }.
]

{ #category : #'instance creation' }
MonokaiTheme class >> addDarkWindowColors: theme [
	"self createDark apply."
	theme
		set: #uniformWindowColor for: #Model to:( self invisibleColor adjustBrightness: 0.16) "lighter twice";
		
		set: #unfocusedWindowColorModifier for: #SystemWindow to: [ [:color | color adjustBrightness: -0.16 "darker twice"] ];
		set: #unfocusedLabelColor for: #SystemWindow to: [
			Model useColorfulWindows
				ifTrue: [(Color r: 0.285 g: 0.282 b: 0.242) "invisible color"]
				ifFalse: [(Color r: 0.972 g: 0.972 b: 0.948) "foreground color"] ];
		set: #focusedLabelColor for: #SystemWindow to: [
			Model useColorfulWindows
				ifTrue: [(Color r: 0.152 g: 0.156 b: 0.133) "background color"]
				ifFalse: [(Color r: 0.901 g: 0.858 b: 0.455) "yellow"] ];

		set: #customWindowColor for: #Browser to: self green duller;
		set: #customWindowColor for: #ChangeList to: self blue duller;
		set: #customWindowColor for: #ChangeSorter to: self blue duller;
		set: #customWindowColor for: #ChatNotes to: self magenta duller;
		set: #customWindowColor for: #ClassCommentVersionsBrowser to: self violet duller;
		set: #customWindowColor for: #Debugger to: self red duller;
		set: #customWindowColor for: #DualChangeSorter to: self blue duller;
		set: #customWindowColor for: #FileContentsBrowser to: self yellow duller;
		set: #customWindowColor for: #FileList to: self yellow duller;
		set: #customWindowColor for: #InstanceBrowser to: self cyan duller;
		set: #customWindowColor for: #Lexicon to: self cyan duller;
		set: #customWindowColor for: #MCTool to: self violet duller;
		set: #customWindowColor for: #MessageNames to: self green duller;
		set: #customWindowColor for: #MessageSet to: self cyan duller;
		set: #customWindowColor for: #PackagePaneBrowser to: self green duller;
		set: #customWindowColor for: #PluggableFileList to: self yellow duller;
		set: #customWindowColor for: #PreferenceBrowser to: self cyan duller;
		set: #customWindowColor for: #SMLoader to: self orange duller;
		set: #customWindowColor for: #SMLoaderPlus to: self orange duller;
		set: #customWindowColor for: #SMReleaseBrowser to: self orange duller;
		set: #customWindowColor for: #ScriptingDomain to: self yellow duller;
		set: #customWindowColor for: #SelectorBrowser to: self cyan duller;
		set: #customWindowColor for: #StringHolder to: self yellow duller;
		set: #customWindowColor for: #TestRunner to: self orange duller;
		set: #customWindowColor for: #TranscriptStream to: self orange duller;
		set: #customWindowColor for: #VersionsBrowser to: self violet duller.
]

{ #category : #'colors by purpose' }
MonokaiTheme class >> argumentColor [
	
	^ Color fromString: '#FD971F'
]

{ #category : #'colors by purpose' }
MonokaiTheme class >> backgroundColor [

	^ Color fromString: '#272822'
]

{ #category : #'colors by accent' }
MonokaiTheme class >> blue [

	^ self globalColor
]

{ #category : #'colors by purpose' }
MonokaiTheme class >> caretColor [
	"invalid foreground, invalid deprecated foreground ..."
	
	^ Color fromString: '#F8F8F0'
]

{ #category : #'colors by purpose' }
MonokaiTheme class >> classColor [
	"inherited class, function name, tag attribute,  ..."
	
	^ Color fromString: '#A6E22E'
]

{ #category : #'colors by purpose' }
MonokaiTheme class >> commentColor [
	
	^ Color fromString: '#75715E'
]

{ #category : #'instance creation' }
MonokaiTheme class >> createDark [
	"self createDark apply."
	| themeName |
	themeName := 'Monokai (dark)'.
	^ (self named: themeName) in: [:theme |
		theme merge: (self named: 'Squeak') overwrite: true.
		theme name: themeName.
		
		"General morph stuff."
		theme
			set: #keyboardFocusColor for: #Morph to: self yellow;
			set: #keyboardFocusWidth for: #Morph to: 1.

		theme set: #background for: #MorphicProject to: self darkBackgroundForm.

		self
			addDarkFonts: theme;
			addDarkWindowColors: theme;
			addDarkSyntaxHighlighting: theme;
			addDarkScrollables: theme;
			addDarkButtons: theme;
			addDarkDialogs: theme;
			addDarkMenusAndDockingBars: theme;
			addDarkToolColors: theme.

		theme]
]

{ #category : #'colors by accent' }
MonokaiTheme class >> cyan [

	^ SolarizedTheme cyan
]

{ #category : #'instance creation' }
MonokaiTheme class >> darkBackgroundForm [

	| ref |
	ref := self backgroundColor.

	^ (SqueakTheme linenblue  asFormOfDepth: 32) collectColors: [:c | 
		Color
			h:ref hue
			s: ref saturation
			v: c brightness - 0.1
			alpha: c alpha]
]

{ #category : #'colors by purpose' }
MonokaiTheme class >> foregroundColor [

	^ Color fromString: '#F8F8F2'
]

{ #category : #'colors by purpose' }
MonokaiTheme class >> globalColor [
	"library function, library constant, library class type, ..."
	
	^ Color fromString: '#66D9EF'
]

{ #category : #'colors by purpose' }
MonokaiTheme class >> grayDarker [
	
	^ Color fromString: '#383830'
]

{ #category : #'colors by purpose' }
MonokaiTheme class >> grayLight [
	
	^ Color fromString: '#595959'
]

{ #category : #'colors by purpose' }
MonokaiTheme class >> grayLightest [
	
	^ Color fromString: '#E6E6E6'
]

{ #category : #'colors by accent' }
MonokaiTheme class >> green [

	^ self classColor
]

{ #category : #'colors by purpose' }
MonokaiTheme class >> invisibleColor [
	"line highlight, selection, ..."
	
	^ Color fromString: '#49483E'
]

{ #category : #'colors by purpose' }
MonokaiTheme class >> keywordColor [
	"tag name, invalid background,  ..."
	
	^ Color fromString: '#F92672'
]

{ #category : #'colors by accent' }
MonokaiTheme class >> magenta [

	^ self keywordColor
]

{ #category : #'colors by purpose' }
MonokaiTheme class >> numberColor [
	"Constant, invalid deprecated background, ..."
	"purple"
	
	^ Color fromString: '#AE81FF'
]

{ #category : #'colors by accent' }
MonokaiTheme class >> orange [

	^ self argumentColor
]

{ #category : #'colors by accent' }
MonokaiTheme class >> red [

	^ SolarizedTheme red
]

{ #category : #'colors by purpose' }
MonokaiTheme class >> stringColor [
	
	^ Color fromString: '#E6DB74'
]

{ #category : #'colors by accent' }
MonokaiTheme class >> violet [

	^ self numberColor
]

{ #category : #'colors by accent' }
MonokaiTheme class >> yellow [

	^ self stringColor
]
