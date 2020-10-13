Class {
	#name : #ColorTheme,
	#superclass : #Object,
	#classVars : [
		'Current'
	],
	#category : #'60Deprecated-System-Support'
}

{ #category : #applying }
ColorTheme class >> apply [
	^self new apply
]

{ #category : #applying }
ColorTheme class >> applyTheme: aThemeClass [ 
	aThemeClass new apply
]

{ #category : #accessing }
ColorTheme class >> current [
	^ Current
		ifNil: [self defaultTheme apply]
]

{ #category : #accessing }
ColorTheme class >> current: aColorTheme [
	Current := aColorTheme
]

{ #category : #accessing }
ColorTheme class >> defaultTheme [
	^ self new.
]

{ #category : #applying }
ColorTheme >> apply [
	"apply the receiver as the current theme"
	BalloonMorph balloonColor: self balloonColor.

	Preferences setParameter: #defaultWorldColor to: self defaultWorldColor.

	Preferences setParameter: #insertionPointColor to: self insertionPointColor.
	Preferences setParameter: #keyboardFocusColor to: self keyboardFocusColor.
	Preferences setParameter: #textHighlightColor to: self textHighlightColor.

	Preferences setParameter: #menuTitleColor to: self menuTitleColor.
	Preferences setParameter: #menuTitleBorderColor to: self menuTitleBorderColor.
	Preferences setParameter: #menuTitleBorderWidth to: self menuTitleBorderWidth.
	Preferences setParameter: #menuColor to: self menuColor.
	Preferences setParameter: #menuBorderColor to: self menuBorderColor.
	Preferences setParameter: #menuLineColor to: self menuLineColor.
	Preferences setParameter: #menuBorderWidth to: self menuBorderWidth.
	Preferences setParameter: #menuSelectionColor to: self menuSelectionColor.

	SystemProgressMorph reset.

	self class current: self.

]

{ #category : #theme }
ColorTheme >> balloonColor [
	^ TranslucentColor
			r: 0.92
			g: 0.92
			b: 0.706
			alpha: 0.75
]

{ #category : #theme }
ColorTheme >> cancelColor [
	^ Color lightRed
]

{ #category : #theme }
ColorTheme >> defaultWorldColor [
	^ Color blue muchLighter
]

{ #category : #'theme - dialogs' }
ColorTheme >> dialog3DTitles [
	^ true
]

{ #category : #'theme - dialogs' }
ColorTheme >> dialogBorderColor [
	^ Color fromArray: #(0.355 0.516 1.0 )
]

{ #category : #'theme - dialogs' }
ColorTheme >> dialogBorderWidth [
	^ 4
]

{ #category : #'theme - dialogs' }
ColorTheme >> dialogButtonBorderWidth [
	^ 0
]

{ #category : #'theme - dialogs' }
ColorTheme >> dialogColor [
	^ Color paleYellow
]

{ #category : #'theme - dialogs' }
ColorTheme >> dialogPaneBorderColor [
	^ Color black

]

{ #category : #'theme - dialogs' }
ColorTheme >> dialogPaneBorderWidth [
	^ 0
]

{ #category : #'theme - dialogs' }
ColorTheme >> dialogPaneRampOrColor [
	^ {0.0 -> (Color r: 0.742 g: 0.871 b: 1.0).
		1.0 -> (Color r: 0.516 g: 0.645 b: 1.0)}
]

{ #category : #'theme - dialogs' }
ColorTheme >> dialogRampOrColor [
	^ {0.0 -> (Color r: 0.516 g: 0.645 b: 1.0).
		1.0 -> (Color r: 0.742 g: 0.871 b: 1.0)}
]

{ #category : #'theme - dialogs' }
ColorTheme >> dialogTextBoxBorderColor [
	^ Color black
]

{ #category : #'theme - dialogs' }
ColorTheme >> dialogTextBoxColor [
	^ Color white
]

{ #category : #theme }
ColorTheme >> disabledColor [
	^ Color lightGray
]

{ #category : #'theme - dockingbar' }
ColorTheme >> dockingBarAutoGradient [
	^ true
]

{ #category : #'theme - dockingbar' }
ColorTheme >> dockingBarColor [
	^ Color r: 0.6 g: 0.7 b: 1
]

{ #category : #'theme - dockingbar' }
ColorTheme >> dockingBarGradientRamp [
	^ { 0.0 -> Color white.
		1.0 -> (Color r: 0.6 g: 0.7 b: 1) }
]

{ #category : #theme }
ColorTheme >> helpColor [
	^ Color lightGreen
]

{ #category : #theme }
ColorTheme >> insertionPointColor [
	^ Color red
]

{ #category : #theme }
ColorTheme >> keyboardFocusColor [
	^ Color r: 0.6 g: 1 b: 1
]

{ #category : #'theme - menus' }
ColorTheme >> menuBorderColor [
	^ Color r: 0.2 g: 0.3 b: 0.9
]

{ #category : #'theme - menus' }
ColorTheme >> menuBorderWidth [
	^ 2
]

{ #category : #'theme - menus' }
ColorTheme >> menuColor [
	^ Color r: 0.85 g: 0.9 b: 1
]

{ #category : #'theme - menus' }
ColorTheme >> menuLineColor [
	^ Color r: 0.6 g: 0.7 b: 1
]

{ #category : #'theme - menus' }
ColorTheme >> menuSelectionColor [
	^ Color r: 0.2 g: 0.3 b: 0.9
]

{ #category : #'theme - menus' }
ColorTheme >> menuTitleBorderColor [
	^ Color r: 0.6 g: 0.7 b: 1
]

{ #category : #'theme - menus' }
ColorTheme >> menuTitleBorderWidth [
	^ 6
]

{ #category : #'theme - menus' }
ColorTheme >> menuTitleColor [
	^ Color r: 0.6 g: 0.7 b: 1
]

{ #category : #theme }
ColorTheme >> okColor [
	^ Color lightGreen
]

{ #category : #theme }
ColorTheme >> textHighlightColor [
	^ Color blue muchLighter alpha: 0.7
]
