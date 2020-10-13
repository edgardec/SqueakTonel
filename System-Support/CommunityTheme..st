"
A dark theme designed by members of the Squeak community.
"
Class {
	#name : #CommunityTheme,
	#superclass : #UserInterfaceTheme,
	#category : #'System-Support'
}

{ #category : #'instance creation' }
CommunityTheme class >> addDarkButtons: aUserInterfaceTheme [
	"self createDark apply."
	aUserInterfaceTheme
		set: #borderColor for: #PluggableButtonMorph to: Color darkGray darker ;
		set: #color for: #PluggableButtonMorph to: Color gray darker ;
		set: #textColor for: #PluggableButtonMorph to: Color white;

		set: #selectionModifier for: #PluggableButtonMorph to: [ [:c | self dbSelection twiceDarker] ];
		set: #hoverModifier for: #PluggableButtonMorph to: [ [:c | c adjustBrightness: 0.2] ];
		set: #feedbackModifier for: #PluggableButtonMorph to: [ [:c | c adjustBrightness: 0.3] ].
	"And the plus-version."
	aUserInterfaceTheme set: #disabledTextColor for: #PluggableButtonMorphPlus to: Color lightGray
]

{ #category : #'instance creation' }
CommunityTheme class >> addDarkDialogs: aUserInterfaceTheme [
	"self createDark apply."
	aUserInterfaceTheme
		set: #borderColor for: #DialogWindow to: self dbSelection;
		set: #color for: #DialogWindow to: (self dbBlue adjustSaturation: -0.20 brightness: -0.30);

		set: #titleColor for: #DialogWindow to: self dbBlue twiceDarker;
		set: #titleTextColor for: #DialogWindow to: Color veryLightGray;

		set: #textColor for: #DialogWindow to: (Color gray: 0.9);

		set: #okColor for: #DialogWindow to: self dbGreen;
		set: #cancelColor for: #DialogWindow to: self dbOrange;
		set: #buttonColor for: #DialogWindow to: Color darkGray;
		set: #selectionModifier for: #DialogWindow to: [ [:c | self dbSelection twiceDarker ] ].
	"The List Chooser is a dialog, too."
	aUserInterfaceTheme
		set: #addColor for: #ListChooser to: self dbBlue;
		set: #disabledColor for: #ListChooser to: Color transparent.
	"And the system progress bar."
	aUserInterfaceTheme
		set: #color for: #SystemProgressBarMorph to: Color transparent;
		set: #barColor for: #SystemProgressBarMorph to: self dbSelection.
	"And the balloon morphs."
	aUserInterfaceTheme
		set: #borderColor for: #NewBalloonMorph to: Color transparent ;
		set: #color for: #NewBalloonMorph to: (self dbLabel alpha: 0.9) ;
		set: #textColor for: #NewBalloonMorph to: Color white .
]

{ #category : #'instance creation' }
CommunityTheme class >> addDarkFonts: aUserInterfaceTheme [
	"Set-up fonts."
	aUserInterfaceTheme
		set: #balloonHelpFont to: [StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: 7 emphasized: TextEmphasis italic emphasisCode];
		set: #standardButtonFont to: [StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: 7];
		set: #standardCodeFont to: [StrikeFont familyName: 'Bitmap DejaVu Sans' pointSize: 9];
		set: #standardFlapFont to: [StrikeFont familyName: 'Bitmap DejaVu Sans' pointSize: 7 emphasized: TextEmphasis bold emphasisCode];
		set: #haloLabelFont to: [StrikeFont familyName: 'Darkmap DejaVu Sans' pointSize: 9];
		set: #standardListFont to: [StrikeFont familyName: 'Bitmap DejaVu Sans' pointSize: 9];
		set: #standardMenuFont to: [StrikeFont familyName: 'Bitmap DejaVu Sans' pointSize: 9];
		set: #standardSystemFont to: [StrikeFont familyName: 'Bitmap DejaVu Sans' pointSize: 9];
		set: #windowTitleFont to: [StrikeFont familyName: 'Bitmap DejaVu Sans' pointSize: 9 emphasized: TextEmphasis bold emphasisCode]
]

{ #category : #'instance creation' }
CommunityTheme class >> addDarkMenusAndDockingBars: aUserInterfaceTheme [
	"self createDark apply."
	aUserInterfaceTheme
		set: #borderWidth for: #MenuMorph to: 0;
		set: #color for: #MenuMorph to: Color darkGray twiceDarker;
		set: #titleTextColor for: #MenuMorph to: Color white;
		set: #lineColor for: #MenuMorph to: Color darkGray;
		set: #lineStyle for: #MenuMorph to: BorderStyle simple;
		set: #lineWidth for: #MenuMorph to: 1.
	aUserInterfaceTheme
		set: #textColor for: #MenuItemMorph to: self dbForeground;
		set: #selectionColor for: #MenuItemMorph to: self dbSelection;
		set: #selectionTextColor for: #MenuItemMorph to: Color white ;
		set: #disabledTextColor for: #MenuItemMorph to: self dbForeground muchDarker.
		"set: #subMenuMarker for: #MenuItemMorph to: nil." "Use hard-coded default. See MenuItemMorph."
	"The world main docking bar."
	aUserInterfaceTheme
"		set: #color for: #DockingBarMorph to: Color darkGray;"
"		set: #selectionColor for: #DockingBarItemMorph to: self darkContentSecondary;"
		set: #logoColor for: #TheWorldMainDockingBar to: Color white;
		set: #selectionLogoColor for: #TheWorldMainDockingBar to: Color white
]

{ #category : #'instance creation' }
CommunityTheme class >> addDarkScrollables: aUserInterfaceTheme [
	"self createDark apply."
	"Scroll bars"
	aUserInterfaceTheme
		set: #thumbColor for: #ScrollBar to: self dbGray;
		set: #thumbBorderColor for: #ScrollBar to: self dbGray twiceDarker.
	"Scroll panes (includes generic stuff for list widgets, tree widgets, and text widgets."
	aUserInterfaceTheme
		set: #borderColor for: #ScrollPane to: (Color transparent) ; "So the search box isn't outlined."
		set: #color for: #ScrollPane to: self dbBackground.
	"List widgets"
	aUserInterfaceTheme
		set: #textColor for: #PluggableListMorph to: (Color gray: 0.9);
		set: #selectionColor for: #PluggableListMorph to: self dbSelection;
		set: #selectionTextColor for: #PluggableListMorph to: Color white ;
		derive: #multiSelectionColor for: #PluggableListMorph from: #PluggableListMorph at: #selectionColor do: [:c | c twiceDarker];
		set: #filterColor for: #PluggableListMorph to: (self dbYellow alpha: 0.4);
		derive: #filterTextColor for: #PluggableListMorph from: #PluggableListMorph at: #textColor ;
		set: #preSelectionModifier for: #PluggableListMorph to: [ [:c | c twiceDarker ] ];
		set: #hoverSelectionModifier for: #PluggableListMorph to: [ [:c | c twiceDarker alpha: 0.5 ] ].
	"Tree widgets"
	aUserInterfaceTheme
		set: #highlightTextColor for: #SimpleHierarchicalListMorph to: self dbYellow lighter lighter;
		set: #lineColor for: #SimpleHierarchicalListMorph to: Color gray.
	"Text widgets"
	aUserInterfaceTheme
		set: #textColor for: #PluggableTextMorph to: (Color gray: 0.9);
		set: #caretColor for: #PluggableTextMorph to: Color orange darker;
		set: #selectionColor for: #PluggableTextMorph to: (self dbSelection duller duller);
		set: #unfocusedSelectionModifier for: #PluggableTextMorph to: [ [:c | c duller] ];
		set: #adornmentReadOnly for: #PluggableTextMorph to: self dbPurple;
		set: #adornmentRefuse for: #PluggableTextMorph to: self dbBlue;
		set: #adornmentConflict for: #PluggableTextMorph to: self dbRed;
		set: #adornmentDiff for: #PluggableTextMorph to: self dbGreen;
		set: #adornmentNormalEdit for: #PluggableTextMorph to: self dbOrange;
		set: #adornmentDiffEdit for: #PluggableTextMorph to: self dbYellow;
		set: #frameAdornmentWidth for: #PluggableTextMorph to: 2.
	aUserInterfaceTheme
		set: #balloonTextColor for: #PluggableTextMorphPlus to: Color lightGray
]

{ #category : #'instance creation' }
CommunityTheme class >> addDarkSyntaxHighlighting: aUserInterfaceTheme [
	"self createDark apply."
	| normal bold italic underlined | normal  := TextEmphasis normal.  bold:=TextEmphasis bold.  italic:=TextEmphasis italic.  underlined := TextEmphasis underlined.
	aUserInterfaceTheme
		set: #color for: #TextAction to: self dbBlue;
	
		set: #default for: #SHTextStylerST80 to: {self dbForeground};
		set: #invalid for: #SHTextStylerST80 to: {self dbInvalid};
		set: #excessCode for: #SHTextStylerST80 to: {self dbInvalid twiceDarker};
		"Descriptive text for humans, italicized."
		set: #comment for: #SHTextStylerST80 to: {self dbComment. italic};
		set: #unfinishedComment for: #SHTextStylerST80 to: {self dbComment darker. italic};
		set: #'$' for: #SHTextStylerST80 to: {self dbConstant};
		set: #character for: #SHTextStylerST80 to: {self dbConstant};
		set: #integer for: #SHTextStylerST80 to: {self dbConstant};
		set: #number for: #SHTextStylerST80 to: {self dbConstant};
		set: #- for: #SHTextStylerST80 to: {self dbForeground. bold};
		set: #= for: #SHTextStylerST80 to: {self dbForeground. bold};
		set: #symbol for: #SHTextStylerST80 to: {self dbBedrock};
		set: #stringSymbol for: #SHTextStylerST80 to: {self dbBedrock};
		set: #literalArray for: #SHTextStylerST80 to: {self dbForeground};
		set: #string for: #SHTextStylerST80 to: {self dbConstant};
		set: #unfinishedString for: #SHTextStylerST80 to: {self dbConstant darker};
		set: #assignment for: #SHTextStylerST80 to: {nil. bold};
		set: #ansiAssignment for: #SHTextStylerST80 to: {nil. bold};
		set: #literal for: #SHTextStylerST80 to: {nil. bold};
		set: #keyword for: #SHTextStylerST80 to: {self dbMessage};
		set: #binary for: #SHTextStylerST80 to: {self dbForeground. bold};
		set: #unary for: #SHTextStylerST80 to: {self dbMessage};
		set: #incompleteKeyword for: #SHTextStylerST80 to: {self dbMessage darker. {underlined. bold}};
		set: #incompleteBinary for: #SHTextStylerST80 to: {self dbMessage darker. underlined};
		set: #incompleteUnary for: #SHTextStylerST80 to: {self dbMessage darker. underlined};
		set: #undefinedKeyword for: #SHTextStylerST80 to: {self dbInvalid};
		set: #undefinedBinary for: #SHTextStylerST80 to: {self dbInvalid};
		set: #undefinedUnary for: #SHTextStylerST80 to: {self dbInvalid};
		"Delineate the selector (good for new users), and make the method look like a mini-document with a title."
		set: #patternKeyword for: #SHTextStylerST80 to: {self dbMessage lighter.  {bold. underlined}};
		set: #patternBinary for: #SHTextStylerST80 to: {nil. bold};
		set: #patternUnary for: #SHTextStylerST80 to: {self dbMessage lighter.  {bold. underlined}};	
		set: #self for: #SHTextStylerST80 to: {self dbBedrock. bold};
		set: #super for: #SHTextStylerST80 to: {self dbBedrock. bold}; 
		set: #true for: #SHTextStylerST80 to: {self dbBedrock. bold};
		set: #false for: #SHTextStylerST80 to: {self dbBedrock. bold};
		set: #nil for: #SHTextStylerST80 to: {self dbBedrock. bold};
		set: #thisContext for: #SHTextStylerST80 to: {self dbBedrock. bold};
		set: #return for: #SHTextStylerST80 to: {self dbForeground. bold};
		set: #patternArg for: #SHTextStylerST80 to: {self dbSelection twiceLighter. TextEmphasis normal. ""};	
		set: #methodArg for: #SHTextStylerST80 to: {self dbSelection twiceLighter. TextEmphasis normal. ""};
		set: #blockPatternArg for: #SHTextStylerST80 to: {self dbSelection twiceLighter};
		set: #blockArg for: #SHTextStylerST80 to: {self dbSelection twiceLighter};
		set: #argument for: #SHTextStylerST80 to: {self dbSelection twiceLighter};
		set: #blockArgColon for: #SHTextStylerST80 to: {self dbBedrock}; 
		set: #leftParenthesis for: #SHTextStylerST80 to: {self dbBedrock muchLighter}; 
		set: #rightParenthesis for: #SHTextStylerST80 to: {self dbBedrock muchLighter}; 
		set: #leftParenthesis1 for: #SHTextStylerST80 to: {self dbBedrock twiceLighter}; 
		set: #rightParenthesis1 for: #SHTextStylerST80 to: {self dbBedrock twiceLighter}; 
		set: #leftParenthesis2 for: #SHTextStylerST80 to: {self dbBedrock}; 
		set: #rightParenthesis2 for: #SHTextStylerST80 to: {self dbBedrock}; 
		set: #leftParenthesis3 for: #SHTextStylerST80 to: {self dbPurple muchLighter}; 
		set: #rightParenthesis3 for: #SHTextStylerST80 to: {self dbPurple muchLighter}; 
		set: #leftParenthesis4 for: #SHTextStylerST80 to: {self dbPurple muchLighter}; 
		set: #rightParenthesis4 for: #SHTextStylerST80 to: {self dbPurple muchLighter}; 
		set: #leftParenthesis5 for: #SHTextStylerST80 to: {self dbOrange muchLighter}; 
		set: #rightParenthesis5 for: #SHTextStylerST80 to: {self dbOrange muchLighter}; 
		set: #leftParenthesis6 for: #SHTextStylerST80 to: {self dbOrange muchLighter}; 
		set: #rightParenthesis6 for: #SHTextStylerST80 to: {self dbOrange muchLighter}; 
		set: #leftParenthesis7 for: #SHTextStylerST80 to: {Color yellow}; 
		set: #rightParenthesis7 for: #SHTextStylerST80 to: {Color yellow}; 
		set: #blockStart for: #SHTextStylerST80 to: {self dbBedrock muchLighter}; 
		set: #blockEnd for: #SHTextStylerST80 to: {self dbBedrock muchLighter}; 
		set: #blockStart1 for: #SHTextStylerST80 to: {self dbBedrock twiceLighter}; 
		set: #blockEnd1 for: #SHTextStylerST80 to: {self dbBedrock twiceLighter}; 
		set: #blockStart2 for: #SHTextStylerST80 to: {self dbBedrock}; 
		set: #blockEnd2 for: #SHTextStylerST80 to: {self dbBedrock}; 
		set: #blockStart3 for: #SHTextStylerST80 to: {self dbPurple muchLighter}; 
		set: #blockEnd3 for: #SHTextStylerST80 to: {self dbPurple muchLighter}; 
		set: #blockStart4 for: #SHTextStylerST80 to: {self dbPurple muchLighter}; 
		set: #blockEnd4 for: #SHTextStylerST80 to: {self dbPurple muchLighter}; 
		set: #blockStart5 for: #SHTextStylerST80 to: {self dbOrange muchLighter}; 
		set: #blockEnd5 for: #SHTextStylerST80 to: {self dbOrange muchLighter}; 
		set: #blockStart6 for: #SHTextStylerST80 to: {self dbOrange muchLighter}; 
		set: #blockEnd6 for: #SHTextStylerST80 to: {self dbOrange muchLighter}; 
		set: #blockStart7 for: #SHTextStylerST80 to: {Color yellow}; 
		set: #blockEnd7 for: #SHTextStylerST80 to: {Color yellow}; 																																					
		set: #arrayStart for: #SHTextStylerST80 to: {self dbBedrock}; 
		set: #arrayEnd for: #SHTextStylerST80 to: {self dbBedrock}; 
		set: #arrayStart1 for: #SHTextStylerST80 to: {self dbForeground}; 
		set: #arrayEnd1 for: #SHTextStylerST80 to: {self dbForeground}; 
		set: #byteArrayStart for: #SHTextStylerST80 to: {self dbForeground}; 
		set: #byteArrayEnd for: #SHTextStylerST80 to: {self dbForeground}; 
		set: #byteArrayStart1 for: #SHTextStylerST80 to: {self dbForeground}; 
		set: #byteArrayEnd1 for: #SHTextStylerST80 to: {self dbForeground}; 
		set: #leftBrace for: #SHTextStylerST80 to: {self dbForeground}; 
		set: #rightBrace for: #SHTextStylerST80 to: {self dbForeground}; 
		set: #cascadeSeparator for: #SHTextStylerST80 to: {self dbForeground}; 
		set: #statementSeparator for: #SHTextStylerST80 to: {self dbForeground}; 
		set: #externalCallType for: #SHTextStylerST80 to: {self dbForeground}; 
		set: #externalCallTypePointerIndicator for: #SHTextStylerST80 to: {self dbForeground}; 
		set: #primitiveOrExternalCallStart for: #SHTextStylerST80 to: {self dbForeground}; 
		set: #primitiveOrExternalCallEnd for: #SHTextStylerST80 to: {self dbForeground};
		set: #methodTempBar for: #SHTextStylerST80 to: {self dbBedrock};
		set: #blockTempBar for: #SHTextStylerST80 to: {self dbBedrock};
		set: #blockArgsBar for: #SHTextStylerST80 to: {self dbBedrock};
		set: #primitive for: #SHTextStylerST80 to: {self dbGreen lighter. bold};
		set: #pragmaKeyword for: #SHTextStylerST80 to: {self dbGreen. bold};
		set: #pragmaUnary for: #SHTextStylerST80 to: {self dbGreen. bold};
		set: #pragmaBinary for: #SHTextStylerST80 to: {self dbGreen. bold};									
		set: #externalFunctionCallingConvention for: #SHTextStylerST80 to: {self dbGreen. bold}; 
		set: #module for: #SHTextStylerST80 to: {self dbGreen. bold};
		set: #blockTempVar for: #SHTextStylerST80 to: {self dbLabel. italic};
		set: #blockPatternTempVar for: #SHTextStylerST80 to: {self dbLabel. italic};
		set: #instVar for: #SHTextStylerST80 to: {self dbYellow. normal };
		set: #workspaceVar for: #SHTextStylerST80 to: {self dbLabel. italic};
		set: #undefinedIdentifier for: #SHTextStylerST80 to: {self dbInvalid};
		set: #incompleteIdentifier for: #SHTextStylerST80 to: {self dbGray. underlined};
		set: #tempVar for: #SHTextStylerST80 to: {self dbLabel. italic};
		set: #patternTempVar for: #SHTextStylerST80 to: {self dbLabel. italic};
		set: #poolConstant for: #SHTextStylerST80 to: {self dbConstant };
		set: #classVar for: #SHTextStylerST80 to: {self dbReference};
		set: #globalVar for: #SHTextStylerST80 to: {self dbClass. normal}.
	"And the text differ"
	aUserInterfaceTheme	
		set: #insertTextAttributes for: #TextDiffBuilder to: { TextColor color: self dbRed };
		set: #removeTextAttributes for: #TextDiffBuilder to: { TextEmphasis struckOut. TextColor color: self dbBlue };
		set: #normalTextAttributes for: #TextDiffBuilder to: { TextEmphasis normal }.
]

{ #category : #'instance creation' }
CommunityTheme class >> addDarkToolColors: theme [
	"Tool-specific colors."
	
	theme 
		set: #failureColor for: #TestRunner to: self dbYellow;
		set: #errorColor for: #TestRunner to: self dbRed;
		set: #passColor for: #TestRunner to: self dbGreen.
		
	"Browser."
	theme
		set: #noClassCommentColor for: #Browser to: self dbRed;
		set: #deprecatedMessageAttributes for: #CodeHolder to: { TextEmphasis struckOut. TextColor color: self dbGray }.
]

{ #category : #'instance creation' }
CommunityTheme class >> addDarkWindowColors: aUserInterfaceTheme [
	"self createDark apply."
	aUserInterfaceTheme
		set: #uniformWindowColor for: #Model to: Color darkGray;
		
		set: #unfocusedWindowColorModifier for: #SystemWindow to: [ [:color | color darker] ];
		set: #unfocusedLabelColor for: #SystemWindow to: Color veryLightGray;
		set: #focusedLabelColor for: #SystemWindow to: Color white;

		set: #customWindowColor for: #Browser to: self dbBlue;
		set: #customWindowColor for: #ChangeList to: self dbBlue;
		set: #customWindowColor for: #ChangeSorter to: self dbBlue;
		set: #customWindowColor for: #ChatNotes to: self dbPurple twiceDarker;
		set: #customWindowColor for: #ClassCommentVersionsBrowser to: self dbPurple twiceDarker;
		set: #customWindowColor for: #Debugger to: self dbRed;
		set: #customWindowColor for: #DualChangeSorter to: self dbOrange twiceDarker;
		set: #customWindowColor for: #FileContentsBrowser to: self dbGray;
		set: #customWindowColor for: #FileList to: self dbGray;
		set: #customWindowColor for: #Inspector to: self dbYellow duller;
		set: #customWindowColor for: #InstanceBrowser to: self dbYellow duller;
		set: #customWindowColor for: #Lexicon to: self dbGreen;
		set: #customWindowColor for: #MCTool to: self dbOrange twiceDarker;
		set: #customWindowColor for: #MessageNames to: self dbGreen;
		set: #customWindowColor for: #MessageSet to: self dbGreen;
		set: #customWindowColor for: #ObjectExplorer to: self dbYellow duller;
		set: #customWindowColor for: #PackagePaneBrowser to: self dbBlue;
		set: #customWindowColor for: #PluggableFileList to: self dbGray;
		set: #customWindowColor for: #PreferenceBrowser to: self dbBlue;
		set: #customWindowColor for: #ProcesBrowser to: self dbAqua;
		set: #customWindowColor for: #SMLoader to: self dbOrange twiceDarker;
		set: #customWindowColor for: #SMLoaderPlus to: self dbOrange twiceDarker;
		set: #customWindowColor for: #SMReleaseBrowser to: self dbOrange twiceDarker;
		set: #customWindowColor for: #ScriptingDomain to: self dbYellow duller;
		set: #customWindowColor for: #SelectorBrowser to: self dbBlue;
		set: #customWindowColor for: #StringHolder to: self dbGray;
		set: #customWindowColor for: #TestRunner to: self dbPink darker;
		set: #customWindowColor for: #TranscriptStream to: self dbGray;
		set: #customWindowColor for: #VersionsBrowser to: self dbPurple twiceDarker;
		set: #customWindowColor for: #Workspace to: self dbPink darker.
]

{ #category : #'instance creation' }
CommunityTheme class >> createDark [
	"self createDark apply."
	| name |
	name := 'Community (dark)'.
	^ (self named: name) in: [:theme |
		theme merge: (self named: 'Squeak') overwrite: true.
		theme name: name.
		"General morph stuff."
		theme
			set: #borderColor for: #ScrollPane to: (Color transparent) ;
			set: #keyboardFocusColor for: #Morph to: (self dbSelection adjustSaturation: -0.3 brightness: 0.10);
			set: #keyboardFocusWidth for: #Morph to: 2;
			set: #softShadowColor for: #Morph to: (self dbSelection muchLighter alpha: 0.025);
			set: #softShadowOffset for: #Morph to: (10@8 corner: 10@12);
			set: #hardShadowColor for: #Morph to: (self dbSelection muchLighter alpha: 0.02);
			set: #hardShadowOffset for: #Morph to: 1@1.
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

{ #category : #colors }
CommunityTheme class >> dbAqua [
	"Suitably saturated to serve as dbSelection."
	^ Color r: 0.1 g: 0.5 b: 0.5
]

{ #category : #'colors by purpose' }
CommunityTheme class >> dbBackground [
	"Emptiness."
	^Color black
]

{ #category : #'colors by purpose' }
CommunityTheme class >> dbBedrock [
	"Basic syntactical matter which users cannot change."
	^ self dbForeground
]

{ #category : #colors }
CommunityTheme class >> dbBlue [         
	^Color r: 0.406 g: 0.535 b: 0.645
]

{ #category : #'colors by purpose' }
CommunityTheme class >> dbClass [
	^ self dbBlue
]

{ #category : #'colors by purpose' }
CommunityTheme class >> dbComment [
	"The code should speak for itself.  Where it cannot, any comments should just be subtle, clarifying whispers."
	^ Color gray darker
]

{ #category : #'colors by purpose' }
CommunityTheme class >> dbConstant [
	"Let unparameterized constants stand out in red."
	^ self dbRed
]

{ #category : #'colors by purpose' }
CommunityTheme class >> dbForeground [
	"Not too bright."
	^Color r: 0.764 g: 0.776 b: 0.768
]

{ #category : #colors }
CommunityTheme class >> dbGray [
	^ Color gray slightlyDarker
]

{ #category : #colors }
CommunityTheme class >> dbGreen [        
	^(Color r: 0.33 g: 0.542 b: 0.287)
]

{ #category : #'colors by purpose' }
CommunityTheme class >> dbInvalid [
	"Purposefully bright, so that it conflicts with the rest of the palette, visually indicative of a problem."
	^ Color magenta twiceLighter
]

{ #category : #'colors by purpose' }
CommunityTheme class >> dbLabel [
	"Short notes and labels are meant for human consumption."
	^ self dbPink
]

{ #category : #'colors by purpose' }
CommunityTheme class >> dbMessage [
	"Green is the universal color for okay, positive, go.  In Squeak, sending messages are what make objects 'go'."
	^ self dbGreen
		adjustSaturation: 0.05
		brightness: 0.10
]

{ #category : #colors }
CommunityTheme class >> dbOrange [       
	^Color r: 0.871 g: 0.577 b: 0.372
]

{ #category : #colors }
CommunityTheme class >> dbPink [       
	^ (Color r: 0.739 g: 0.552 b: 0.652)
]

{ #category : #colors }
CommunityTheme class >> dbPurple [       
	^Color r: 0.698 g: 0.581 b: 0.733
]

{ #category : #colors }
CommunityTheme class >> dbRed [ 
	^Color r: 0.75 g: 0.25 b: 0.25
]

{ #category : #'colors by purpose' }
CommunityTheme class >> dbReference [
	"References to other objects.  Yellow like gold."
	^ self dbYellow
]

{ #category : #'colors by purpose' }
CommunityTheme class >> dbSelection [
	"Selections are transient, like electricity, so a good neon color.  The arguments passed to methods and blocks could be considered as much, 'selections', as those made from a list or menu."
	^ self dbAqua adjustSaturation: 0.10 brightness: 0.08
]

{ #category : #colors }
CommunityTheme class >> dbYellow [       
	^ (Color r: 0.675 g: 0.632 b: 0.16)
]
