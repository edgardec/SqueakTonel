"
The Solarized color palette.

http://ethanschoonover.com/solarized

SOLARIZED HEX     16/8 TERMCOL  XTERM/HEX   L*A*B      RGB         HSB
--------- ------- ---- -------  ----------- ---------- ----------- -----------
base03    #002b36  8/4 brblack  234 #1c1c1c 15 -12 -12   0  43  54 193 100  21
base02    #073642  0/4 black    235 #262626 20 -12 -12   7  54  66 192  90  26
base01    #586e75 10/7 brgreen  240 #585858 45 -07 -07  88 110 117 194  25  46
base00    #657b83 11/7 bryellow 241 #626262 50 -07 -07 101 123 131 195  23  51
base0     #839496 12/6 brblue   244 #808080 60 -06 -03 131 148 150 186  13  59
base1     #93a1a1 14/4 brcyan   245 #8a8a8a 65 -05 -02 147 161 161 180   9  63
base2     #eee8d5  7/7 white    254 #e4e4e4 92 -00  10 238 232 213  44  11  93
base3     #fdf6e3 15/7 brwhite  230 #ffffd7 97  00  10 253 246 227  44  10  99
yellow    #b58900  3/3 yellow   136 #af8700 60  10  65 181 137   0  45 100  71
orange    #cb4b16  9/3 brred    166 #d75f00 50  50  55 203  75  22  18  89  80
red       #dc322f  1/1 red      160 #d70000 50  65  45 220  50  47   1  79  86
magenta   #d33682  5/5 magenta  125 #af005f 50  65 -05 211  54 130 331  74  83
violet    #6c71c4 13/5 brmagenta 61 #5f5faf 50  15 -45 108 113 196 237  45  77
blue      #268bd2  4/4 blue      33 #0087ff 55 -10 -45  38 139 210 205  82  82
cyan      #2aa198  6/6 cyan      37 #00afaf 60 -35 -05  42 161 152 175  74  63
green     #859900  2/2 green     64 #5f8700 60 -20  65 133 153   0  68 100  60
"
Class {
	#name : #SolarizedTheme,
	#superclass : #UserInterfaceTheme,
	#category : #'System-Support'
}

{ #category : #'instance creation' }
SolarizedTheme class >> addDarkButtons: theme [
	"self createDark apply."
	theme
		set: #borderColor for: #PluggableButtonMorph to: self darkContentSecondary;
		set: #color for: #PluggableButtonMorph to: self darkBackgroundHighlights;
		set: #textColor for: #PluggableButtonMorph to: self darkContentEmphasizedMore;

		set: #selectionModifier for: #PluggableButtonMorph to: [ [:c | c adjustBrightness: -0.1] ];
		set: #hoverModifier for: #PluggableButtonMorph to: [ [:c | c adjustBrightness: -0.1] ];
		set: #feedbackModifier for: #PluggableButtonMorph to: [ [:c | c adjustBrightness: -0.3] ].
	
	"And the plus-version."
	theme set: #disabledTextColor for: #PluggableButtonMorphPlus to: self darkContentSecondary.

]

{ #category : #'instance creation' }
SolarizedTheme class >> addDarkDialogs: theme [
	"self createDark apply."
	theme
		set: #borderColor for: #DialogWindow to: self darkBackground muchDarker;
		set: #color for: #DialogWindow to: self darkBackgroundHighlights;

		set: #titleColor for: #DialogWindow to: self darkBackground;
		set: #titleTextColor for: #DialogWindow to: self darkContentEmphasized;
		
		set: #textColor for: #DialogWindow to: self darkContentEmphasizedMore;
		
		set: #okColor for: #DialogWindow to: self green;
		set: #cancelColor for: #DialogWindow to: self orange;
		set: #buttonColor for: #DialogWindow to: self darkBackgroundHighlights;
		set: #selectionModifier for: #DialogWindow to: [ [:c | c adjustBrightness: -0.1 ] ].
	
	"The List Chooser is a dialog, too."
	theme
		set: #addColor for: #ListChooser to: self blue;
		set: #disabledColor for: #ListChooser to: Color transparent.

		
	"And the system progress bar."
	theme
		set: #color for: #SystemProgressBarMorph to: self darkBackgroundHighlights;
		set: #barColor for: #SystemProgressBarMorph to: self darkContentSecondary.
		
	"And the balloon morphs."
	theme
		set: #borderColor for: #NewBalloonMorph to: self darkBackground muchDarker;
		set: #color for: #NewBalloonMorph to: self darkBackgroundHighlights.
]

{ #category : #'instance creation' }
SolarizedTheme class >> addDarkFonts: theme [

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
SolarizedTheme class >> addDarkMenusAndDockingBars: theme [
	"self createDark apply."
	theme
		set: #borderWidth for: #MenuMorph to: 1;
		set: #borderColor for: #MenuMorph to: self darkBackgroundHighlights;
		set: #color for: #MenuMorph to: self darkBackground;
		set: #titleTextColor for: #MenuMorph to: self darkContentEmphasizedMore;
		set: #lineColor for: #MenuMorph to: self darkBackgroundHighlights;
		set: #lineStyle for: #MenuMorph to: BorderStyle simple;
		set: #lineWidth for: #MenuMorph to: 1.
		
	theme
		set: #textColor for: #MenuItemMorph to: self darkContentEmphasized;
		set: #disabledTextColor for: #MenuItemMorph to: self darkContentSecondary;
		set: #selectionColor for: #MenuItemMorph to: self darkSelectionColor;
		set: #selectionTextColor for: #MenuItemMorph to: self darkSelectionTextColor.
		"set: #subMenuMarker for: #MenuItemMorph to: nil." "Use hard-coded default. See MenuItemMorph."
		
	"The world main docking bar."
	theme
		set: #color for: #DockingBarMorph to: self darkBackgroundHighlights;
		set: #selectionColor for: #DockingBarItemMorph to: self darkContentSecondary;
		set: #logoColor for: #TheWorldMainDockingBar to: self darkContentEmphasized;
		set: #selectionLogoColor for: #TheWorldMainDockingBar to: self darkContentEmphasizedMore.
]

{ #category : #'instance creation' }
SolarizedTheme class >> addDarkScrollables: theme [
	"self createDark apply."

	"Scroll bars"
	theme
		set: #thumbColor for: #ScrollBar to: self darkBackground;
		set: #thumbBorderColor for: #ScrollBar to: self darkBackground;
		set: #thumbBorderWidth for: #ScrollBar to: 1;
		set: #thumbColorModifier for: #ScrollBar to: [ [:c | c adjustBrightness: -0.1] ];
		set: #pagingAreaColorModifier for: #ScrollBar to: [ [:c | Color transparent ] ];
		set: #borderColorModifier for: #ScrollBar to: [ [:c | c adjustBrightness: -0.1] ].
	
	"Scroll panes (includes generic stuff for list widgets, tree widgets, and text widgets."
	theme
		set: #borderWidth for: #ScrollPane to: 0;
	"	set: #borderColor for: #ScrollPane to: Color transparent;"
		set: #color for: #ScrollPane to: self darkBackground.
		
	"List widgets"
	theme
		set: #textColor for: #PluggableListMorph to: self darkContentEmphasized;
		set: #selectionColor for: #PluggableListMorph to: self darkSelectionColor;
		set: #selectionTextColor for: #PluggableListMorph to: self darkSelectionTextColor;
		set: #filterColor for: #PluggableListMorph to: self yellow;
		set: #filterTextColor for: #PluggableListMorph to: self base03;
		set: #preSelectionModifier for: #PluggableListMorph to: [ [:c | c lighter alpha: 0.5 ] ];
		set: #hoverSelectionModifier for: #PluggableListMorph to: [ [:c | c lighter alpha: 0.5 ] ].
		
	"Tree widgets"
	theme
		set: #highlightTextColor for: #SimpleHierarchicalListMorph to: self yellow lighter lighter;
		set: #lineColor for: #SimpleHierarchicalListMorph to: self darkContentSecondary.
	
	"Text widgets"
	theme
		set: #textColor for: #PluggableTextMorph to: self darkContentPrimary;
		set: #caretColor for: #PluggableTextMorph to: self darkContentEmphasizedMore;
		set: #selectionColor for: #PluggableTextMorph to: self darkSelectionColor;
		set: #unfocusedSelectionModifier for: #PluggableTextMorph to: [ [:c | c darker ] ];
		set: #adornmentReadOnly for: #PluggableTextMorph to: self magenta;
		set: #adornmentRefuse for: #PluggableTextMorph to: self cyan;
		set: #adornmentConflict for: #PluggableTextMorph to: self red;
		set: #adornmentDiff for: #PluggableTextMorph to: self green;
		set: #adornmentNormalEdit for: #PluggableTextMorph to: self orange;
		set: #adornmentDiffEdit for: #PluggableTextMorph to: self yellow.
	theme
		set: #balloonTextColor for: #PluggableTextMorphPlus to: self darkContentSecondary.
]

{ #category : #'instance creation' }
SolarizedTheme class >> addDarkSyntaxHighlighting: theme [
	"self createDark apply."
	theme
		set: #color for: #TextAction to: self blue;
		
		set: #default for: #SHTextStylerST80 to: {self darkContentPrimary};
		set: #invalid for: #SHTextStylerST80 to: {self red};
		set: #excessCode for: #SHTextStylerST80 to: {self red};
		set: #comment for: #SHTextStylerST80 to: {self cyan};
		set: #unfinishedComment for: #SHTextStylerST80 to: {self red. TextEmphasis italic};
		set: #'$' for: #SHTextStylerST80 to: {self red};
		set: #character for: #SHTextStylerST80 to: {self red};
		set: #integer for: #SHTextStylerST80 to: {self red};
		set: #number for: #SHTextStylerST80 to: {self red};	
		set: #- for: #SHTextStylerST80 to: {self red};
		set: #symbol for: #SHTextStylerST80 to: {self green};	
		set: #stringSymbol for: #SHTextStylerST80 to: {self green};	
		set: #literalArray for: #SHTextStylerST80 to: {self green};
		set: #string for: #SHTextStylerST80 to: {self magenta. TextEmphasis normal};
		set: #unfinishedString for: #SHTextStylerST80 to: {self red. TextEmphasis normal};
		set: #assignment for: #SHTextStylerST80 to: {nil. TextEmphasis bold};
		set: #ansiAssignment for: #SHTextStylerST80 to: {nil. TextEmphasis bold};
		set: #literal for: #SHTextStylerST80 to: {nil. TextEmphasis italic};
		set: #keyword for: #SHTextStylerST80 to: {self blue};
		set: #binary for: #SHTextStylerST80 to: {self blue};	
		set: #unary for: #SHTextStylerST80 to: {self blue};
		set: #incompleteKeyword for: #SHTextStylerST80 to: {self darkContentPrimary. TextEmphasis underlined};
		set: #incompleteBinary for: #SHTextStylerST80 to: {self darkContentPrimary. TextEmphasis underlined};	
		set: #incompleteUnary for: #SHTextStylerST80 to: {self darkContentPrimary. TextEmphasis underlined};
		set: #undefinedKeyword for: #SHTextStylerST80 to: {self red};
		set: #undefinedBinary for: #SHTextStylerST80 to: {self red};	
		set: #undefinedUnary for: #SHTextStylerST80 to: {self red};													
		set: #patternKeyword for: #SHTextStylerST80 to: {nil};
		set: #patternBinary for: #SHTextStylerST80 to: {nil};
		set: #patternUnary for: #SHTextStylerST80 to: {nil};	
		set: #self for: #SHTextStylerST80 to: {self darkContentPrimary};
		set: #super for: #SHTextStylerST80 to: {self darkContentPrimary}; 
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
		set: #blockArgColon for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #leftParenthesis for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #rightParenthesis for: #SHTextStylerST80 to: {self darkContentPrimary}; 
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
		set: #blockStart for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #blockEnd for: #SHTextStylerST80 to: {self darkContentPrimary}; 
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
		set: #arrayStart for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #arrayEnd for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #arrayStart1 for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #arrayEnd1 for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #byteArrayStart for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #byteArrayEnd for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #byteArrayStart1 for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #byteArrayEnd1 for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #leftBrace for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #rightBrace for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #cascadeSeparator for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #statementSeparator for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #externalCallType for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #externalCallTypePointerIndicator for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #primitiveOrExternalCallStart for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #primitiveOrExternalCallEnd for: #SHTextStylerST80 to: {self darkContentPrimary};
		set: #methodTempBar for: #SHTextStylerST80 to: {self darkContentPrimary}; 
		set: #blockTempBar for: #SHTextStylerST80 to: {self darkContentPrimary};
		set: #blockArgsBar for: #SHTextStylerST80 to: {self darkContentPrimary};
		set: #primitive for: #SHTextStylerST80 to: {self green. TextEmphasis bold};
		set: #pragmaKeyword for: #SHTextStylerST80 to: {self green. TextEmphasis bold};
		set: #pragmaUnary for: #SHTextStylerST80 to: {self green. TextEmphasis bold};
		set: #pragmaBinary for: #SHTextStylerST80 to: {self green. TextEmphasis bold};									
		set: #externalFunctionCallingConvention for: #SHTextStylerST80 to: {self green. TextEmphasis bold}; 
		set: #module for: #SHTextStylerST80 to: {self green. TextEmphasis bold};
		set: #blockTempVar for: #SHTextStylerST80 to: {self darkContentPrimary};
		set: #blockPatternTempVar for: #SHTextStylerST80 to: {self darkContentPrimary};
		set: #instVar for: #SHTextStylerST80 to: {self darkContentPrimary};
		set: #workspaceVar for: #SHTextStylerST80 to: {self darkContentPrimary};
		set: #undefinedIdentifier for: #SHTextStylerST80 to: {self red};
		set: #incompleteIdentifier for: #SHTextStylerST80 to: {self darkContentPrimary. {TextEmphasis italic. TextEmphasis underlined}};
		set: #tempVar for: #SHTextStylerST80 to: {self darkContentPrimary};
		set: #patternTempVar for: #SHTextStylerST80 to: {self darkContentPrimary};
		set: #poolConstant for: #SHTextStylerST80 to: {self darkContentPrimary};
		set: #classVar for: #SHTextStylerST80 to: {self darkContentPrimary};
		set: #globalVar for: #SHTextStylerST80 to: {self darkContentPrimary}.
		
	"And the text differ"
	theme	
		set: #insertTextAttributes for: #TextDiffBuilder to: { TextColor color: self red };
		set: #removeTextAttributes for: #TextDiffBuilder to: { TextEmphasis struckOut. TextColor color: self blue };
		set: #normalTextAttributes for: #TextDiffBuilder to: { TextEmphasis normal }.
]

{ #category : #'instance creation' }
SolarizedTheme class >> addDarkToolColors: theme [
	"Tool-specific colors."
	
	theme 
		set: #failureColor for: #TestRunner to: self yellow;
		set: #errorColor for: #TestRunner to: self red;
		set: #passColor for: #TestRunner to: self green;
		
		set: #failureTextColor for: #TestRunner to: self darkBackground;
		set: #errorTextColor for: #TestRunner to: self darkBackground;
		set: #passTextColor for: #TestRunner to: self darkBackground.
		
	theme
		set: #ignoredOperationAttributes for: #MCOperationsBrowser to: {TextColor color: self darkContentSecondary}.
	
	"Browser."
	theme
		set: #noClassCommentColor for: #Browser to: self red;
		set: #deprecatedMessageAttributes for: #CodeHolder to: { TextEmphasis struckOut. TextColor color: self darkContentSecondary }.
]

{ #category : #'instance creation' }
SolarizedTheme class >> addDarkWindowColors: theme [
	"doIt: [self createDark apply.]"

	theme
		set: #uniformWindowColor for: #Model to: (self darkBackgroundHighlights adjustBrightness: 0.16 "lighter twice");

		set: #unfocusedWindowColorModifier for: #SystemWindow to: [ [:color | color adjustBrightness: -0.16 "darker twice"] ];
		set: #unfocusedLabelColor for: #SystemWindow to: self darkContentEmphasized;
		set: #focusedLabelColor for: #SystemWindow to: self darkContentEmphasizedMore;

		set: #customWindowColor for: #Browser to: self green;
		set: #customWindowColor for: #ChangeList to: self blue;
		set: #customWindowColor for: #ChangeSorter to: self blue;
		set: #customWindowColor for: #ChatNotes to: self magenta;
		set: #customWindowColor for: #ClassCommentVersionsBrowser to: self violet;
		set: #customWindowColor for: #Debugger to: self red;
		set: #customWindowColor for: #DualChangeSorter to: self blue;
		set: #customWindowColor for: #FileContentsBrowser to: self yellow;
		set: #customWindowColor for: #FileList to: self yellow;
		set: #customWindowColor for: #InstanceBrowser to: self cyan;
		set: #customWindowColor for: #Lexicon to: self cyan;
		set: #customWindowColor for: #MCTool to: self violet;
		set: #customWindowColor for: #MessageNames to: self green;
		set: #customWindowColor for: #MessageSet to: self cyan;
		set: #customWindowColor for: #PackagePaneBrowser to: self green;
		set: #customWindowColor for: #PluggableFileList to: self yellow;
		set: #customWindowColor for: #PreferenceBrowser to: self cyan;
		set: #customWindowColor for: #SMLoader to: self orange;
		set: #customWindowColor for: #SMLoaderPlus to: self orange;
		set: #customWindowColor for: #SMReleaseBrowser to: self orange;
		set: #customWindowColor for: #ScriptingDomain to: self yellow;
		set: #customWindowColor for: #SelectorBrowser to: self cyan;
		set: #customWindowColor for: #StringHolder to: self yellow;
		set: #customWindowColor for: #TestRunner to: self orange;
		set: #customWindowColor for: #TranscriptStream to: self orange;
		set: #customWindowColor for: #VersionsBrowser to: self violet.
]

{ #category : #'instance creation' }
SolarizedTheme class >> addLightButtons: theme [
	"self createLight apply."
	theme
		set: #borderColor for: #PluggableButtonMorph to: self lightContentSecondary;
		set: #color for: #PluggableButtonMorph to: self lightBackgroundHighlights;
		set: #textColor for: #PluggableButtonMorph to: self lightContentEmphasizedMore;

		set: #selectionModifier for: #PluggableButtonMorph to: [ [:c | c adjustBrightness: -0.1] ];
		set: #hoverModifier for: #PluggableButtonMorph to: [ [:c | c adjustBrightness: -0.1] ];
		set: #feedbackModifier for: #PluggableButtonMorph to: [ [:c | c adjustBrightness: -0.3] ].
	
	"And the plus-version."
	theme set: #disabledTextColor for: #PluggableButtonMorphPlus to: self lightContentSecondary.

]

{ #category : #'instance creation' }
SolarizedTheme class >> addLightDialogs: theme [
	"self createLight apply."
	theme
		set: #borderColor for: #DialogWindow to: self lightBackground muchDarker;
		set: #color for: #DialogWindow to: self lightBackgroundHighlights;

		set: #titleColor for: #DialogWindow to: self lightBackground;
		set: #titleTextColor for: #DialogWindow to: self lightContentEmphasized;
		
		set: #textColor for: #DialogWindow to: self lightContentEmphasizedMore;
		
		set: #okColor for: #DialogWindow to: self green;
		set: #cancelColor for: #DialogWindow to: self orange;
		set: #buttonColor for: #DialogWindow to: self lightBackgroundHighlights;
		set: #selectionModifier for: #DialogWindow to: [ [:c | c adjustBrightness: -0.1 ] ].
	
	"The List Chooser is a dialog, too."
	theme
		set: #addColor for: #ListChooser to: self blue;
		set: #disabledColor for: #ListChooser to: Color transparent.

		
	"And the system progress bar."
	theme
		set: #color for: #SystemProgressBarMorph to: self lightBackgroundHighlights;
		set: #barColor for: #SystemProgressBarMorph to: self lightContentSecondary.
		
	"And the balloon morphs."
	theme
		set: #borderColor for: #NewBalloonMorph to: self lightBackground muchDarker;
		set: #color for: #NewBalloonMorph to: self lightBackgroundHighlights.
]

{ #category : #'instance creation' }
SolarizedTheme class >> addLightFonts: theme [

	"Set-up fonts."
	theme
		set: #balloonHelpFont to: [StrikeFont familyName: 'Bitmap DejaVu Sans' pointSize: 7];
		set: #standardButtonFont to: [StrikeFont familyName: 'Bitmap DejaVu Sans' pointSize: 7];
		set: #standardCodeFont to: [StrikeFont familyName: 'Bitmap DejaVu Sans' pointSize: 9];
		set: #standardFlapFont to: [StrikeFont familyName: 'Bitmap DejaVu Sans' pointSize: 7 emphasized: TextEmphasis bold emphasisCode];
		set: #haloLabelFont to: [StrikeFont familyName: 'Bitmap DejaVu Sans' pointSize: 9];
		set: #standardListFont to: [StrikeFont familyName: 'Bitmap DejaVu Sans' pointSize: 9];
		set: #standardMenuFont to: [StrikeFont familyName: 'Bitmap DejaVu Sans' pointSize: 9];
		set: #standardSystemFont to: [StrikeFont familyName: 'Bitmap DejaVu Sans' pointSize: 9];
		set: #windowTitleFont to: [StrikeFont familyName: 'Bitmap DejaVu Sans' pointSize: 9 emphasized: TextEmphasis bold emphasisCode].
]

{ #category : #'instance creation' }
SolarizedTheme class >> addLightMenusAndDockingBars: theme [
	"self createLight apply."
	theme
		set: #borderWidth for: #MenuMorph to: 1;
		set: #borderColor for: #MenuMorph to: self lightBackgroundHighlights;
		set: #color for: #MenuMorph to: self lightBackground;
		set: #titleTextColor for: #MenuMorph to: self lightContentEmphasizedMore;
		set: #lineColor for: #MenuMorph to: self lightBackgroundHighlights;
		set: #lineStyle for: #MenuMorph to: BorderStyle simple;
		set: #lineWidth for: #MenuMorph to: 1.
		
	theme
		set: #textColor for: #MenuItemMorph to: self lightContentEmphasized;
		set: #disabledTextColor for: #MenuItemMorph to: self lightContentSecondary;
		set: #selectionColor for: #MenuItemMorph to: self lightBackgroundHighlights darker;
		set: #selectionTextColor for: #MenuItemMorph to: self lightContentEmphasizedMore.
		"set: #subMenuMarker for: #MenuItemMorph to: nil." "Use hard-coded default. See MenuItemMorph."
		
	"The world main docking bar."
	theme
		set: #color for: #DockingBarMorph to: self lightBackgroundHighlights;
		set: #selectionColor for: #DockingBarItemMorph to: self lightContentSecondary;
		set: #logoColor for: #TheWorldMainDockingBar to: self lightContentEmphasized;
		set: #selectionLogoColor for: #TheWorldMainDockingBar to: self lightContentEmphasizedMore.
]

{ #category : #'instance creation' }
SolarizedTheme class >> addLightScrollables: theme [
	"self createLight apply."

	"Scroll bars"
	theme
		set: #thumbColor for: #ScrollBar to: self lightBackground;
		set: #thumbBorderColor for: #ScrollBar to: self lightBackground;
		set: #thumbBorderWidth for: #ScrollBar to: 1;
		set: #thumbColorModifier for: #ScrollBar to: [ [:c | c adjustBrightness: -0.1] ];
		set: #pagingAreaColorModifier for: #ScrollBar to: [ [:c | Color transparent ] ];
		set: #borderColorModifier for: #ScrollBar to: [ [:c | c adjustBrightness: -0.1] ].
	
	"Scroll panes (includes generic stuff for list widgets, tree widgets, and text widgets."
	theme
		set: #borderWidth for: #ScrollPane to: 0;
	"	set: #borderColor for: #ScrollPane to: Color transparent;"
		set: #color for: #ScrollPane to: self lightBackground.
		
	"List widgets"
	theme
		set: #textColor for: #PluggableListMorph to: self lightContentEmphasized;
		set: #selectionColor for: #PluggableListMorph to: self lightBackgroundHighlights darker;
		set: #selectionTextColor for: #PluggableListMorph to: self lightContentEmphasizedMore;
		derive: #multiSelectionColor for: #PluggableListMorph from: #PluggableListMorph at: #selectionColor do: [:c | c darker];
		set: #filterColor for: #PluggableListMorph to: self yellow;
		set: #filterTextColor for: #PluggableListMorph to: self lightBackground;
		set: #preSelectionModifier for: #PluggableListMorph to: [ [:c | c darker alpha: 0.5 ] ];
		set: #hoverSelectionModifier for: #PluggableListMorph to: [ [:c | c darker alpha: 0.5 ] ].
		
	"Tree widgets"
	theme
		set: #highlightTextColor for: #SimpleHierarchicalListMorph to: self yellow lighter lighter;
		set: #lineColor for: #SimpleHierarchicalListMorph to: self lightContentSecondary.
	
	"Text widgets"
	theme
		set: #textColor for: #PluggableTextMorph to: self lightContentPrimary;
		set: #caretColor for: #PluggableTextMorph to: self lightContentEmphasizedMore;
		set: #selectionColor for: #PluggableTextMorph to: self lightBackgroundHighlights darker;
		set: #unfocusedSelectionModifier for: #PluggableTextMorph to: [ [:c | (Color r: 0.933 g: 0.909 b: 0.835) "light background highlights"] ];
		set: #adornmentReadOnly for: #PluggableTextMorph to: self magenta;
		set: #adornmentRefuse for: #PluggableTextMorph to: self cyan;
		set: #adornmentConflict for: #PluggableTextMorph to: self red;
		set: #adornmentDiff for: #PluggableTextMorph to: self green;
		set: #adornmentNormalEdit for: #PluggableTextMorph to: self orange;
		set: #adornmentDiffEdit for: #PluggableTextMorph to: self yellow.
	theme
		set: #balloonTextColor for: #PluggableTextMorphPlus to: self lightContentSecondary.
]

{ #category : #'instance creation' }
SolarizedTheme class >> addLightSyntaxHighlighting: theme [
	"self createLight apply."

	theme
		set: #color for: #TextAction to: self blue;

		set: #default for: #SHTextStylerST80 to: {self lightContentPrimary};
		set: #invalid for: #SHTextStylerST80 to: {self red};
		set: #excessCode for: #SHTextStylerST80 to: {self red};
		set: #comment for: #SHTextStylerST80 to: {self cyan};
		set: #unfinishedComment for: #SHTextStylerST80 to: {self red. TextEmphasis italic};
		set: #'$' for: #SHTextStylerST80 to: {self red};
		set: #character for: #SHTextStylerST80 to: {self red};
		set: #integer for: #SHTextStylerST80 to: {self red};
		set: #number for: #SHTextStylerST80 to: {self red};	
		set: #- for: #SHTextStylerST80 to: {self red};
		set: #symbol for: #SHTextStylerST80 to: {self green};	
		set: #stringSymbol for: #SHTextStylerST80 to: {self green};	
		set: #literalArray for: #SHTextStylerST80 to: {self green};
		set: #string for: #SHTextStylerST80 to: {self magenta. TextEmphasis normal};
		set: #unfinishedString for: #SHTextStylerST80 to: {self red. TextEmphasis normal};
		set: #assignment for: #SHTextStylerST80 to: {nil. TextEmphasis bold};
		set: #ansiAssignment for: #SHTextStylerST80 to: {nil. TextEmphasis bold};
		set: #literal for: #SHTextStylerST80 to: {nil. TextEmphasis italic};
		set: #keyword for: #SHTextStylerST80 to: {self blue};
		set: #binary for: #SHTextStylerST80 to: {self blue};	
		set: #unary for: #SHTextStylerST80 to: {self blue};
		set: #incompleteKeyword for: #SHTextStylerST80 to: {self lightContentPrimary. TextEmphasis underlined};
		set: #incompleteBinary for: #SHTextStylerST80 to: {self lightContentPrimary. TextEmphasis underlined};	
		set: #incompleteUnary for: #SHTextStylerST80 to: {self lightContentPrimary. TextEmphasis underlined};
		set: #undefinedKeyword for: #SHTextStylerST80 to: {self red};
		set: #undefinedBinary for: #SHTextStylerST80 to: {self red};	
		set: #undefinedUnary for: #SHTextStylerST80 to: {self red};													
		set: #patternKeyword for: #SHTextStylerST80 to: {nil. TextEmphasis bold};
		set: #patternBinary for: #SHTextStylerST80 to: {nil. TextEmphasis bold};
		set: #patternUnary for: #SHTextStylerST80 to: {nil. TextEmphasis bold};	
		set: #self for: #SHTextStylerST80 to: {self lightContentPrimary};
		set: #super for: #SHTextStylerST80 to: {self lightContentPrimary}; 
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
		set: #blockArgColon for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #leftParenthesis for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #rightParenthesis for: #SHTextStylerST80 to: {self lightContentPrimary}; 
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
		set: #blockStart for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #blockEnd for: #SHTextStylerST80 to: {self lightContentPrimary}; 
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
		set: #arrayStart for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #arrayEnd for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #arrayStart1 for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #arrayEnd1 for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #byteArrayStart for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #byteArrayEnd for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #byteArrayStart1 for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #byteArrayEnd1 for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #leftBrace for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #rightBrace for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #cascadeSeparator for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #statementSeparator for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #externalCallType for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #externalCallTypePointerIndicator for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #primitiveOrExternalCallStart for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #primitiveOrExternalCallEnd for: #SHTextStylerST80 to: {self lightContentPrimary};
		set: #methodTempBar for: #SHTextStylerST80 to: {self lightContentPrimary}; 
		set: #blockTempBar for: #SHTextStylerST80 to: {self lightContentPrimary};
		set: #blockArgsBar for: #SHTextStylerST80 to: {self lightContentPrimary};
		set: #primitive for: #SHTextStylerST80 to: {self green. TextEmphasis bold};
		set: #pragmaKeyword for: #SHTextStylerST80 to: {self green. TextEmphasis bold};
		set: #pragmaUnary for: #SHTextStylerST80 to: {self green. TextEmphasis bold};
		set: #pragmaBinary for: #SHTextStylerST80 to: {self green. TextEmphasis bold};									
		set: #externalFunctionCallingConvention for: #SHTextStylerST80 to: {self green. TextEmphasis bold}; 
		set: #module for: #SHTextStylerST80 to: {self green. TextEmphasis bold};
		set: #blockTempVar for: #SHTextStylerST80 to: {self lightContentPrimary};
		set: #blockPatternTempVar for: #SHTextStylerST80 to: {self lightContentPrimary};
		set: #instVar for: #SHTextStylerST80 to: {self lightContentPrimary};
		set: #workspaceVar for: #SHTextStylerST80 to: {self lightContentPrimary};
		set: #undefinedIdentifier for: #SHTextStylerST80 to: {self red};
		set: #incompleteIdentifier for: #SHTextStylerST80 to: {self lightContentPrimary. {TextEmphasis italic. TextEmphasis underlined}};
		set: #tempVar for: #SHTextStylerST80 to: {self lightContentPrimary};
		set: #patternTempVar for: #SHTextStylerST80 to: {self lightContentPrimary};
		set: #poolConstant for: #SHTextStylerST80 to: {self lightContentPrimary};
		set: #classVar for: #SHTextStylerST80 to: {self lightContentPrimary};
		set: #globalVar for: #SHTextStylerST80 to: {self lightContentPrimary}.
		
	"And the text differ"
	theme	
		set: #insertTextAttributes for: #TextDiffBuilder to: { TextColor color: self red };
		set: #removeTextAttributes for: #TextDiffBuilder to: { TextEmphasis struckOut. TextColor color: self blue };
		set: #normalTextAttributes for: #TextDiffBuilder to: { TextEmphasis normal }.
]

{ #category : #'instance creation' }
SolarizedTheme class >> addLightToolColors: theme [
	"Tool-specific colors."
	
	theme 
		set: #failureColor for: #TestRunner to: self yellow;
		set: #errorColor for: #TestRunner to: self red;
		set: #passColor for: #TestRunner to: self green;

		set: #failureTextColor for: #TestRunner to: self lightBackground;
		set: #errorTextColor for: #TestRunner to: self lightBackground;
		set: #passTextColor for: #TestRunner to: self lightBackground.
		
	theme
		set: #ignoredOperationAttributes for: #MCOperationsBrowser to: {TextColor color: self lightContentSecondary}.
	
	"Browser."
	theme
		set: #noClassCommentColor for: #Browser to: self red;
		set: #deprecatedMessageAttributes for: #CodeHolder to: { TextEmphasis struckOut. TextColor color: self lightContentSecondary }.
]

{ #category : #'instance creation' }
SolarizedTheme class >> addLightWindowColors: theme [
	"You have to create dark first.
	doIt: [self createDark. self createLight apply.]"

	theme
		set: #uniformWindowColor for: #Model to: (self lightBackgroundHighlights adjustBrightness: -0.16 "darker twice");

		set: #unfocusedWindowColorModifier for: #SystemWindow to: [ [:color | color adjustBrightness: 0.16 "lighter twice"] ];
		set: #unfocusedLabelColor for: #SystemWindow to: self lightContentEmphasized;
		set: #focusedLabelColor for: #SystemWindow to: self lightContentEmphasizedMore;

		set: #customWindowColor for: #Browser to: self green;
		set: #customWindowColor for: #ChangeList to: self blue;
		set: #customWindowColor for: #ChangeSorter to: self blue;
		set: #customWindowColor for: #ChatNotes to: self magenta;
		set: #customWindowColor for: #ClassCommentVersionsBrowser to: self violet;
		set: #customWindowColor for: #Debugger to: self red;
		set: #customWindowColor for: #DualChangeSorter to: self blue;
		set: #customWindowColor for: #FileContentsBrowser to: self yellow;
		set: #customWindowColor for: #FileList to: self yellow;
		set: #customWindowColor for: #InstanceBrowser to: self cyan;
		set: #customWindowColor for: #Lexicon to: self cyan;
		set: #customWindowColor for: #MCTool to: self violet;
		set: #customWindowColor for: #MessageNames to: self green;
		set: #customWindowColor for: #MessageSet to: self cyan;
		set: #customWindowColor for: #PackagePaneBrowser to: self green;
		set: #customWindowColor for: #PluggableFileList to: self yellow;
		set: #customWindowColor for: #PreferenceBrowser to: self cyan;
		set: #customWindowColor for: #SMLoader to: self orange;
		set: #customWindowColor for: #SMLoaderPlus to: self orange;
		set: #customWindowColor for: #SMReleaseBrowser to: self orange;
		set: #customWindowColor for: #ScriptingDomain to: self yellow;
		set: #customWindowColor for: #SelectorBrowser to: self cyan;
		set: #customWindowColor for: #StringHolder to: self yellow;
		set: #customWindowColor for: #TestRunner to: self orange;
		set: #customWindowColor for: #TranscriptStream to: self orange;
		set: #customWindowColor for: #VersionsBrowser to: self violet.
]

{ #category : #'colors by name' }
SolarizedTheme class >> base0 [

	^ Color fromString: '#839496'
]

{ #category : #'colors by name' }
SolarizedTheme class >> base00 [

	^ Color fromString: '#657b83'
]

{ #category : #'colors by name' }
SolarizedTheme class >> base01 [

	^ Color fromString: '#586e75'
]

{ #category : #'colors by name' }
SolarizedTheme class >> base02 [

	^ Color fromString: '#073642'
]

{ #category : #'colors by name' }
SolarizedTheme class >> base03 [

	^ Color fromString: '#002b36'
]

{ #category : #'colors by name' }
SolarizedTheme class >> base1 [

	^ Color fromString: '#93a1a1'
]

{ #category : #'colors by name' }
SolarizedTheme class >> base2 [

	^ Color fromString: '#eee8d5'
]

{ #category : #'colors by name' }
SolarizedTheme class >> base3 [

	^ Color fromString: '#fdf6e3'
]

{ #category : #'colors for accent' }
SolarizedTheme class >> blue [

	^ Color fromString: '#268bd2'
]

{ #category : #'instance creation' }
SolarizedTheme class >> createDark [
	"doIt: [self createDark apply.]"

	| themeName |
	themeName := 'Solarized (dark)'.
	^ (self named: themeName) in: [:theme |
		theme merge: (self named: 'Squeak') overwrite: true.
		theme name: themeName.

		"General morph stuff."
		theme
			set: #keyboardFocusColor for: #Morph to: self darkContentSecondary;
			set: #keyboardFocusWidth for: #Morph to: 1.

		theme set: #background for: #MorphicProject to: self lightBackgroundForm.

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

{ #category : #'instance creation' }
SolarizedTheme class >> createLight [
	"You have to create dark first.
	doIt: [self createDark. self createLight apply.]"

	| themeName |
	themeName := 'Solarized (light)'.
	^ (self named: themeName) in: [:theme |
		theme merge: (self named: 'Solarized (dark)') overwrite: true.
		theme name: themeName.

		"General morph stuff."
		theme
			set: #keyboardFocusColor for: #Morph to: self lightContentSecondary;
			set: #keyboardFocusWidth for: #Morph to: 1.

		theme set: #background for: #MorphicProject to: self darkBackgroundForm.

		self
			addLightFonts: theme;
			addLightWindowColors: theme;
			addLightSyntaxHighlighting: theme;
			addLightScrollables: theme;
			addLightButtons: theme;
			addLightDialogs: theme;
			addLightMenusAndDockingBars: theme;
			addLightToolColors: theme.

		theme]
]

{ #category : #'colors for accent' }
SolarizedTheme class >> cyan [

	^ Color fromString: '#2aa198'
]

{ #category : #'colors by purpose' }
SolarizedTheme class >> darkBackground [
	^ self base03
]

{ #category : #'instance creation' }
SolarizedTheme class >> darkBackgroundForm [

	| ref |
	ref := self darkBackground.

	^ (SqueakTheme linenblue  asFormOfDepth: 32) collectColors: [:c | 
		Color
			h:ref hue
			s: ref saturation
			v: c brightness
			alpha: c alpha]
]

{ #category : #'colors by purpose' }
SolarizedTheme class >> darkBackgroundHighlights [

	^ self base02
]

{ #category : #'colors by purpose' }
SolarizedTheme class >> darkContentEmphasized [

	^ self base1
]

{ #category : #'colors by purpose' }
SolarizedTheme class >> darkContentEmphasizedMore [

	^ self base2
]

{ #category : #'colors by purpose' }
SolarizedTheme class >> darkContentPrimary [
	"body text, default code, ..."

	^ self base0
]

{ #category : #'colors by purpose' }
SolarizedTheme class >> darkContentSecondary [
	"comments, keyboard focus indication, ..."

	^ self base01
]

{ #category : #'colors by purpose' }
SolarizedTheme class >> darkSelectionColor [
	^ self base01 darker
]

{ #category : #'colors by purpose' }
SolarizedTheme class >> darkSelectionTextColor [
	^ self base2
]

{ #category : #'colors for accent' }
SolarizedTheme class >> green [

	^ Color fromString: '#859900'
]

{ #category : #'colors by purpose' }
SolarizedTheme class >> lightBackground [

	^ self base3
]

{ #category : #'instance creation' }
SolarizedTheme class >> lightBackgroundForm [

	| ref |
	ref := self lightBackground.

	^ (SqueakTheme linenblue  asFormOfDepth: 32) collectColors: [:c | 
		Color
			h:ref hue
			s: ref saturation
			v: 0.7 - c brightness
			alpha: c alpha]
]

{ #category : #'colors by purpose' }
SolarizedTheme class >> lightBackgroundHighlights [

	^ self base2
]

{ #category : #'colors by purpose' }
SolarizedTheme class >> lightContentEmphasized [

	^ self base01
]

{ #category : #'colors by purpose' }
SolarizedTheme class >> lightContentEmphasizedMore [

	^ self base02
]

{ #category : #'colors by purpose' }
SolarizedTheme class >> lightContentPrimary [
	"body text, default code, ..."

	^ self base00
]

{ #category : #'colors by purpose' }
SolarizedTheme class >> lightContentSecondary [
	"comments, ..."

	^ self base1
]

{ #category : #'colors for accent' }
SolarizedTheme class >> magenta [

	^ Color fromString: '#d33682'
]

{ #category : #'colors for accent' }
SolarizedTheme class >> orange [

	^ Color fromString: '#cb4b16'
]

{ #category : #'colors for accent' }
SolarizedTheme class >> red [

	^ Color fromString: '#dc322f'
]

{ #category : #'colors for accent' }
SolarizedTheme class >> violet [

	^ Color fromString: '#6c71c4'
]

{ #category : #'colors for accent' }
SolarizedTheme class >> yellow [

	^ Color fromString: '#b58900'
]
