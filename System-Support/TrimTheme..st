Class {
	#name : #TrimTheme,
	#superclass : #UserInterfaceTheme,
	#category : #'System-Support'
}

{ #category : #'instance creation' }
TrimTheme class >> addButtons: theme [

	theme
		set: #borderColor for: #PluggableButtonMorph to: self gray102;
		set: #borderWidth for: #PluggableButtonMorph to: 1;
		set: #borderStyle for: #PluggableButtonMorph to: BorderStyle simple;
		set: #color for: #PluggableButtonMorph to: self gray76;
		
		set: #textColor for: #PluggableButtonMorph to: self white;

		set: #selectionModifier for: #PluggableButtonMorph to: [ [:c | self gray39] ];
		set: #hoverModifier for: #PluggableButtonMorph to: [ [:c | self gray51] ];
		set: #feedbackModifier for: #PluggableButtonMorph to: [ [:c | self gray39] ].
	
	"And the plus-version."
	theme
		set: #disabledColor for: #PluggableButtonMorphPlus to: Color transparent;
		set: #disabledTextColor for: #PluggableButtonMorphPlus to: self gray128.
]

{ #category : #'instance creation' }
TrimTheme class >> addDialogs: theme [
	"self create apply."
	
	theme
		set: #borderColor for: #DialogWindow to: self gray59;
		set: #borderWidth for: #DialogWindow to: 0;
		set: #borderStyle for: #DialogWindow to: BorderStyle simple;
		set: #color for: #DialogWindow to: self gray64;

		set: #titleBorderColor for: #DialogWindow to: self gray59;
		set: #titleBorderWidth for: #DialogWindow to: 0;
		set: #titleBorderStyle for: #DialogWindow to: BorderStyle simple;
		set: #titleColor for: #DialogWindow to: self gray51;
		set: #titleTextColor for: #DialogWindow to: self white;
		
		set: #textColor for: #DialogWindow to: self white;
		
		set: #okColor for: #DialogWindow to: self green;
		set: #cancelColor for: #DialogWindow to: self red;
		set: #buttonColor for: #DialogWindow to: self gray59;
		set: #selectionModifier for: #DialogWindow to: [ [:c | self blue ] ].
	
	"The List Chooser is a dialog, too."
	theme
		set: #addColor for: #ListChooser to: self yellow;
		set: #disabledColor for: #ListChooser to: Color transparent.

		
	"And the system progress bar."
	theme		
		set: #borderColor for: #SystemProgressBarMorph to: Color transparent;
		set: #borderWidth for: #SystemProgressBarMorph to: 0;
		set: #borderStyle for: #SystemProgressBarMorph to: BorderStyle simple;
		set: #color for: #SystemProgressBarMorph to: self gray64;
		set: #barColor for: #SystemProgressBarMorph to: self blue.
		
	"And the balloon morphs."
	theme
		set: #borderColor for: #NewBalloonMorph to: self gray168;
		set: #borderWidth for: #NewBalloonMorph to: 1;
		set: #color for: #NewBalloonMorph to: self gray102;
		set: #textColor for: #NewBalloonMorph to: self white.
]

{ #category : #'instance creation' }
TrimTheme class >> addFonts: theme [

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
TrimTheme class >> addMenusAndDockingBars: theme [

	theme
		set: #borderColor for: #MenuMorph to: self gray51;
		set: #borderWidth for: #MenuMorph to: 1;
		set: #borderStyle for: #MenuMorph to: BorderStyle simple;
		set: #color for: #MenuMorph to: self gray27;

		set: #titleBorderColor for: #MenuMorph to: (Color r: 0.6 g: 0.7 b: 1);
		set: #titleBorderWidth for: #MenuMorph to: 0;
		set: #titleBorderStyle for: #MenuMorph to: BorderStyle simple;
		set: #titleColor for: #MenuMorph to: Color transparent;
		set: #titleTextColor for: #MenuMorph to: self white;
		
		set: #lineColor for: #MenuMorph to: self gray51;
		set: #lineStyle for: #MenuMorph to: BorderStyle simple;
		set: #lineWidth for: #MenuMorph to: 1.
		
	theme
		set: #textColor for: #MenuItemMorph to: self white;
		set: #disabledTextColor for: #MenuItemMorph to: self gray128;
		set: #selectionColor for: #MenuItemMorph to: self gray102;
		set: #selectionTextColor for: #MenuItemMorph to: self white.
		
	"The world main docking bar."
	theme
		set: #logoColor for: #TheWorldMainDockingBar to: self white;
		set: #selectionLogoColor for: #TheWorldMainDockingBar to: self white.
]

{ #category : #'instance creation' }
TrimTheme class >> addScrollables: theme [
	"self create apply"
	
	"Sliders"
	theme
		set: #borderColor for: #Slider to: self gray76;
		set: #borderWidth for: #Slider to: 1;
		set: #color for: #Slider to: self gray61;
		set: #thumbBorderColor for: #Slider to: self gray61;
		set: #thumbBorderWidth for: #Slider to: 1;
		set: #thumbColor for: #Slider to: self gray128;
		set: #thumbShadowModifier for: #Slider to: [ [:c | c alpha: 0.7] ].
				
	"Scroll bars"
	theme
		set: #thumbBorderWidth for: #ScrollBar to: 1;
		set: #thumbColorModifier for: #ScrollBar to: [ [:c | c adjustBrightness: 0.2] ];
		"set: #pagingAreaColorModifier for: #ScrollBar to: [ [:c | self gray51] ];"
		set: #borderColorModifier for: #ScrollBar to: [ [:c | c adjustBrightness: 0.2] ].
	
	"Scroll panes (includes generic stuff for list widgets, tree widgets, and text widgets."
	theme
		set: #borderColor for: #ScrollPane to: self gray76;
		set: #borderWidth for: #ScrollPane to: 1;
		set: #borderStyle for: #ScrollPane to: BorderStyle simple;
		set: #color for: #ScrollPane to: self gray51.
		
	"List widgets"
	theme
		set: #textColor for: #PluggableListMorph to: self white;
		set: #selectionColor for: #PluggableListMorph to: self blue;
		derive: #multiSelectionColor for: #PluggableListMorph from: #PluggableListMorph at: #selectionColor do: [:c | c lighter];
		set: #selectionTextColor for: #PluggableListMorph to: self white;
		set: #filterColor for: #PluggableListMorph to: self orange;
		set: #filterTextColor for: #PluggableListMorph to: self white;
		set: #preSelectionModifier for: #PluggableListMorph to: [ [:c | c alpha: 0.3] ];
		set: #hoverSelectionModifier for: #PluggableListMorph to: [ [:c | c darker alpha: 0.3] ].
		
	"Tree widgets"
	theme		
		set: #higlightTextColor for: #SimpleHierarchicalListMorph to: self red;
		set: #lineColor for: #SimpleHierarchicalListMorph to: self gray168.
	
	"Text widgets"
	theme
		set: #textColor for: #PluggableTextMorph to: self white;
		set: #caretColor for: #PluggableTextMorph to: self white;
		set: #selectionColor for: #PluggableTextMorph to: (self blue alpha: 0.4);
		set: #unfocusedSelectionModifier for: #PluggableTextMorph to: [ [:c | self blue alpha: 0.3] ];
		set: #adornmentReadOnly for: #PluggableTextMorph to: self black;
		set: #adornmentRefuse for: #PluggableTextMorph to: self blue;
		set: #adornmentConflict for: #PluggableTextMorph to: self red;
		set: #adornmentDiff for: #PluggableTextMorph to: self green;
		set: #adornmentNormalEdit for: #PluggableTextMorph to: self orange;
		set: #adornmentDiffEdit for: #PluggableTextMorph to: self yellow;
		set: #frameAdornmentWidth for: #PluggableTextMorph to: 1.
	theme
		set: #balloonTextColor for: #PluggableTextMorphPlus to: self gray102.
]

{ #category : #'instance creation' }
TrimTheme class >> addSyntaxHighlighting: theme [
	"self createDark apply."
	
	theme
		set: #color for: #TextAction to: self blue;
		
		set: #default for: #SHTextStylerST80 to: {self white};
		set: #invalid for: #SHTextStylerST80 to: {self red};
		set: #excessCode for: #SHTextStylerST80 to: {self red};
		set: #comment for: #SHTextStylerST80 to: {self cyan};
		set: #unfinishedComment for: #SHTextStylerST80 to: {self red. TextEmphasis italic};
		set: #'$' for: #SHTextStylerST80 to: {self yellow};
		set: #character for: #SHTextStylerST80 to: {self yellow};
		set: #integer for: #SHTextStylerST80 to: {self yellow};
		set: #number for: #SHTextStylerST80 to: {self yellow};	
		set: #- for: #SHTextStylerST80 to: {self yellow};
		set: #symbol for: #SHTextStylerST80 to: {self orange};	
		set: #stringSymbol for: #SHTextStylerST80 to: {self orange};	
		set: #literalArray for: #SHTextStylerST80 to: {self orange};
		set: #string for: #SHTextStylerST80 to: {self magenta. TextEmphasis normal};
		set: #unfinishedString for: #SHTextStylerST80 to: {self red. TextEmphasis normal};
		set: #assignment for: #SHTextStylerST80 to: {nil. TextEmphasis bold};
		set: #ansiAssignment for: #SHTextStylerST80 to: {nil. TextEmphasis bold};
		set: #literal for: #SHTextStylerST80 to: {nil. TextEmphasis italic};
		set: #keyword for: #SHTextStylerST80 to: {self blue};
		set: #binary for: #SHTextStylerST80 to: {self blue};	
		set: #unary for: #SHTextStylerST80 to: {self blue};
		set: #incompleteKeyword for: #SHTextStylerST80 to: {self white. TextEmphasis underlined};
		set: #incompleteBinary for: #SHTextStylerST80 to: {self white. TextEmphasis underlined};	
		set: #incompleteUnary for: #SHTextStylerST80 to: {self white. TextEmphasis underlined};
		set: #undefinedKeyword for: #SHTextStylerST80 to: {self red};
		set: #undefinedBinary for: #SHTextStylerST80 to: {self red};	
		set: #undefinedUnary for: #SHTextStylerST80 to: {self red};													
		set: #patternKeyword for: #SHTextStylerST80 to: {nil};
		set: #patternBinary for: #SHTextStylerST80 to: {nil};
		set: #patternUnary for: #SHTextStylerST80 to: {nil};	
		set: #self for: #SHTextStylerST80 to: {self gray168};
		set: #super for: #SHTextStylerST80 to: {self gray168}; 
		set: #true for: #SHTextStylerST80 to: {self red};
		set: #false for: #SHTextStylerST80 to: {self red};
		set: #nil for: #SHTextStylerST80 to: {self red};
		set: #thisContext for: #SHTextStylerST80 to: {self red};
		set: #return for: #SHTextStylerST80 to: {self red};
		set: #patternArg for: #SHTextStylerST80 to: {self gray168};	
		set: #methodArg for: #SHTextStylerST80 to: {self gray168};
		set: #blockPatternArg for: #SHTextStylerST80 to: {self gray168};
		set: #blockArg for: #SHTextStylerST80 to: {self gray168};
		set: #argument for: #SHTextStylerST80 to: {self gray168};
		set: #blockArgColon for: #SHTextStylerST80 to: {self white}; 
		set: #leftParenthesis for: #SHTextStylerST80 to: {self white}; 
		set: #rightParenthesis for: #SHTextStylerST80 to: {self white}; 
		set: #leftParenthesis1 for: #SHTextStylerST80 to: {self gray168}; 
		set: #rightParenthesis1 for: #SHTextStylerST80 to: {self gray168}; 
		set: #leftParenthesis2 for: #SHTextStylerST80 to: {self gray128}; 
		set: #rightParenthesis2 for: #SHTextStylerST80 to: {self gray128}; 
		set: #leftParenthesis3 for: #SHTextStylerST80 to: {self gray102}; 
		set: #rightParenthesis3 for: #SHTextStylerST80 to: {self gray102}; 
		set: #leftParenthesis4 for: #SHTextStylerST80 to: {self gray76}; 
		set: #rightParenthesis4 for: #SHTextStylerST80 to: {self gray76}; 
		set: #leftParenthesis5 for: #SHTextStylerST80 to: {self gray102}; 
		set: #rightParenthesis5 for: #SHTextStylerST80 to: {self gray102}; 
		set: #leftParenthesis6 for: #SHTextStylerST80 to: {self gray128}; 
		set: #rightParenthesis6 for: #SHTextStylerST80 to: {self gray128}; 
		set: #leftParenthesis7 for: #SHTextStylerST80 to: {self gray168}; 
		set: #rightParenthesis7 for: #SHTextStylerST80 to: {self gray168}; 
		set: #blockStart for: #SHTextStylerST80 to: {self white}; 
		set: #blockEnd for: #SHTextStylerST80 to: {self white}; 
		set: #blockStart1 for: #SHTextStylerST80 to: {self gray168}; 
		set: #blockEnd1 for: #SHTextStylerST80 to: {self gray168}; 
		set: #blockStart2 for: #SHTextStylerST80 to: {self gray128}; 
		set: #blockEnd2 for: #SHTextStylerST80 to: {self gray128}; 
		set: #blockStart3 for: #SHTextStylerST80 to: {self gray102}; 
		set: #blockEnd3 for: #SHTextStylerST80 to: {self gray102}; 
		set: #blockStart4 for: #SHTextStylerST80 to: {self gray76}; 
		set: #blockEnd4 for: #SHTextStylerST80 to: {self gray76}; 
		set: #blockStart5 for: #SHTextStylerST80 to: {self gray102}; 
		set: #blockEnd5 for: #SHTextStylerST80 to: {self gray102}; 
		set: #blockStart6 for: #SHTextStylerST80 to: {self gray128}; 
		set: #blockEnd6 for: #SHTextStylerST80 to: {self gray128}; 
		set: #blockStart7 for: #SHTextStylerST80 to: {self gray168}; 
		set: #blockEnd7 for: #SHTextStylerST80 to: {self gray168}; 																																																		
		set: #arrayStart for: #SHTextStylerST80 to: {self white}; 
		set: #arrayEnd for: #SHTextStylerST80 to: {self white}; 
		set: #arrayStart1 for: #SHTextStylerST80 to: {self white}; 
		set: #arrayEnd1 for: #SHTextStylerST80 to: {self white}; 
		set: #byteArrayStart for: #SHTextStylerST80 to: {self white}; 
		set: #byteArrayEnd for: #SHTextStylerST80 to: {self white}; 
		set: #byteArrayStart1 for: #SHTextStylerST80 to: {self white}; 
		set: #byteArrayEnd1 for: #SHTextStylerST80 to: {self white}; 
		set: #leftBrace for: #SHTextStylerST80 to: {self white}; 
		set: #rightBrace for: #SHTextStylerST80 to: {self white}; 
		set: #cascadeSeparator for: #SHTextStylerST80 to: {self white}; 
		set: #statementSeparator for: #SHTextStylerST80 to: {self white}; 
		set: #externalCallType for: #SHTextStylerST80 to: {self white}; 
		set: #externalCallTypePointerIndicator for: #SHTextStylerST80 to: {self white}; 
		set: #primitiveOrExternalCallStart for: #SHTextStylerST80 to: {self white}; 
		set: #primitiveOrExternalCallEnd for: #SHTextStylerST80 to: {self white};
		set: #methodTempBar for: #SHTextStylerST80 to: {self white}; 
		set: #blockTempBar for: #SHTextStylerST80 to: {self white};
		set: #blockArgsBar for: #SHTextStylerST80 to: {self white};
		set: #primitive for: #SHTextStylerST80 to: {self green. TextEmphasis bold};
		set: #pragmaKeyword for: #SHTextStylerST80 to: {self green. TextEmphasis bold};
		set: #pragmaUnary for: #SHTextStylerST80 to: {self green. TextEmphasis bold};
		set: #pragmaBinary for: #SHTextStylerST80 to: {self green. TextEmphasis bold};									
		set: #externalFunctionCallingConvention for: #SHTextStylerST80 to: {self green. TextEmphasis bold}; 
		set: #module for: #SHTextStylerST80 to: {self green. TextEmphasis bold};
		set: #blockTempVar for: #SHTextStylerST80 to: {self white};
		set: #blockPatternTempVar for: #SHTextStylerST80 to: {self white};
		set: #instVar for: #SHTextStylerST80 to: {self white};
		set: #workspaceVar for: #SHTextStylerST80 to: {self white};
		set: #undefinedIdentifier for: #SHTextStylerST80 to: {self red};
		set: #incompleteIdentifier for: #SHTextStylerST80 to: {self white. {TextEmphasis italic. TextEmphasis underlined}};
		set: #tempVar for: #SHTextStylerST80 to: {self white};
		set: #patternTempVar for: #SHTextStylerST80 to: {self white};
		set: #poolConstant for: #SHTextStylerST80 to: {self white};
		set: #classVar for: #SHTextStylerST80 to: {self white};
		set: #globalVar for: #SHTextStylerST80 to: {self white}.
		
	"And the text differ"
	theme	
		set: #insertTextAttributes for: #TextDiffBuilder to: { TextColor color: self green };
		set: #removeTextAttributes for: #TextDiffBuilder to: { TextEmphasis struckOut. TextColor color: self red };
		set: #normalTextAttributes for: #TextDiffBuilder to: { TextEmphasis normal }.
]

{ #category : #'instance creation' }
TrimTheme class >> addToolColors: theme [
	"Tool-specific colors."
	
	"SUnit's TestRunner."
	theme 
		set: #failureColor for: #TestRunner to: self yellow;
		set: #errorColor for: #TestRunner to: self red;
		set: #passColor for: #TestRunner to: self green.
		
	"Monticello Tools."
	theme
		set: #revertedOperationAttributes for: #MCOperationsBrowser to: {TextEmphasis struckOut};
		set: #ignoredOperationAttributes for: #MCOperationsBrowser to: {TextColor color: self gray128}.
		
	"Browser."
	theme
		set: #noClassCommentColor for: #Browser to: self red;
		set: #deprecatedMessageAttributes for: #CodeHolder to: { TextEmphasis struckOut. TextColor color: self gray128 }.
]

{ #category : #'instance creation' }
TrimTheme class >> addWindowColors: theme [
	
	| windowColorBrightnessAdjustment |
	windowColorBrightnessAdjustment := -0.35.
	theme 
		set: #titleFont for: #SystemWindow to: [Preferences windowTitleFont];
		set: #borderColorModifier for: #SystemWindow to: [ [:c | c adjustBrightness: -0.1] ];
		set: #borderColorModifier for: #ScrollPane to: [ [:c | c adjustBrightness: 0.1] ];
		set: #borderWidth for: #SystemWindow to: 1;
	
		set: #uniformWindowColor for: #Model to: self gray76;
				
		set: #unfocusedWindowColorModifier for: #SystemWindow to: [ [:color | color alphaMixed: 0.5 with: self gray40] ];
		set: #unfocusedLabelColor for: #SystemWindow to: self gray168;
		set: #focusedLabelColor for: #SystemWindow to: Color white;

		set: #customWindowColor for: #Browser to: ((Color r: 0.764 g: 0.9 b: 0.63) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #ChangeList to: ((Color r: 0.719 g: 0.9 b: 0.9) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #ChangeSorter to: ((Color r: 0.719 g: 0.9 b: 0.9) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #ChatNotes to: ((Color r: 1.0 g: 0.7 b: 0.8) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #ClassCommentVersionsBrowser to: ((Color r: 0.753 g: 0.677 b: 0.9) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #Debugger to: ((Color r: 0.9 g: 0.719 b: 0.719) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #DualChangeSorter to: ((Color r: 0.719 g: 0.9 b: 0.9) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #FileContentsBrowser to: ((Color r: 0.7 g: 0.7 b: 0.508) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #FileList to: ((Color r: 0.65 g: 0.65 b: 0.65) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #InstanceBrowser to: ((Color r: 0.726 g: 0.9 b: 0.9) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #Lexicon to: ((Color r: 0.79 g: 0.9 b: 0.79) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #MCTool to: ((Color r: 0.65 g: 0.691 b: 0.876) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #MessageNames to: ((Color r: 0.639 g: 0.9 b: 0.497) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #MessageSet to: ((Color r: 0.719 g: 0.9 b: 0.9) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #PackagePaneBrowser to: ((Color r: 0.9 g: 0.9 b: 0.63) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #PluggableFileList to: (Color lightYellow adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #PreferenceBrowser to: ((Color r: 0.671 g: 0.9 b: 0.9) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #SMLoader to: ((Color r: 0.801 g: 0.801 b: 0.614) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #SMLoaderPlus to: ((Color r: 0.801 g: 0.801 b: 0.614) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #SMReleaseBrowser to: ((Color r: 0.801 g: 0.801 b: 0.614) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #ScriptingDomain to: ((Color r: 0.91 g: 0.91 b: 0.91) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #SelectorBrowser to: ((Color r: 0.45 g: 0.9 b: 0.9) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #StringHolder to: ((Color r: 0.9 g: 0.9 b: 0.719) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #TestRunner to: ((Color r: 0.9 g: 0.576 b: 0.09) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #TranscriptStream to: ((Color r: 0.9 g: 0.75 b: 0.45) adjustBrightness: windowColorBrightnessAdjustment);
		set: #customWindowColor for: #VersionsBrowser to: ((Color r: 0.782 g: 0.677 b: 0.9) adjustBrightness: windowColorBrightnessAdjustment).
]

{ #category : #'instance creation' }
TrimTheme class >> backgroundForm [

	| ref |
	ref := self gray39.

	^ (SqueakTheme linenblue asFormOfDepth: 32) collectColors: [:c | 
		Color
			h:ref hue
			s: ref saturation
			v: c brightness - 0.12
			alpha: c alpha]
]

{ #category : #colors }
TrimTheme class >> black [

	^ self gray27
]

{ #category : #colors }
TrimTheme class >> blue [

	^ Color r: 94 / 255 g: 140 / 255 b: 204 / 255
]

{ #category : #'instance creation' }
TrimTheme class >> create [
	"doIt: [self create apply.]"

	| themeName |
	themeName := 'Trim (dark)'.
	^ (self named: themeName) in: [:theme |
		theme merge: (self named: 'Squeak') overwrite: true.
		theme name: themeName.

		"General morph stuff."
		theme
			set: #keyboardFocusColor for: #Morph to: self blue;
			set: #keyboardFocusWidth for: #Morph to: 2.

		theme set: #background for: #MorphicProject to: self backgroundForm.

		self addFonts: theme.
		self addWindowColors: theme.
		self addSyntaxHighlighting: theme.
		self addMenusAndDockingBars: theme.
		self addDialogs: theme.
		self addButtons: theme.
		self addScrollables: theme.
		self addToolColors: theme.

		theme]
]

{ #category : #colors }
TrimTheme class >> cyan [

	^ Color fromString: '#2aa198'
]

{ #category : #'colors - gray' }
TrimTheme class >> gray102 [

	^ Color gray: 102 / 255
]

{ #category : #'colors - gray' }
TrimTheme class >> gray128 [

	^ Color gray: 128 / 255
]

{ #category : #'colors - gray' }
TrimTheme class >> gray168 [

	^ Color gray: 168 / 255
]

{ #category : #'colors - gray' }
TrimTheme class >> gray27 [

	^ Color gray: 27 / 255
]

{ #category : #'colors - gray' }
TrimTheme class >> gray34 [

	^ Color gray: 34 / 255
]

{ #category : #'colors - gray' }
TrimTheme class >> gray39 [

	^ Color gray: 39 / 255
]

{ #category : #'colors - gray' }
TrimTheme class >> gray40 [

	^ Color gray: 40 / 255
]

{ #category : #'colors - gray' }
TrimTheme class >> gray51 [

	^ Color gray: 51 / 255
]

{ #category : #'colors - gray' }
TrimTheme class >> gray59 [

	^ Color gray: 59 / 255
]

{ #category : #'colors - gray' }
TrimTheme class >> gray61 [

	^ Color gray: 61 / 255
]

{ #category : #'colors - gray' }
TrimTheme class >> gray64 [

	^ Color gray: 64 / 255
]

{ #category : #'colors - gray' }
TrimTheme class >> gray76 [

	^ Color gray: 76 / 255
]

{ #category : #colors }
TrimTheme class >> green [

	^ Color fromString: '#859900'
]

{ #category : #colors }
TrimTheme class >> magenta [

	^ (Color r: 0.917 g: 0.317 b: 0.607)
]

{ #category : #colors }
TrimTheme class >> orange [

	^ (Color r: 0.886 g: 0.383 b: 0.175)
]

{ #category : #colors }
TrimTheme class >> red [

	^ (Color r: 0.952 g: 0.3 b: 0.288)
]

{ #category : #colors }
TrimTheme class >> violet [

	^ Color fromString: '#6c71c4'
]

{ #category : #colors }
TrimTheme class >> white [

	^ Color gray: 240 / 255
]

{ #category : #colors }
TrimTheme class >> yellow [

	^ Color fromString: '#b58900'
]
