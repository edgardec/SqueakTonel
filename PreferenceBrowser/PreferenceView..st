"
My subclasses instances are responsible for building the visual representation of each kind of preference.
"
Class {
	#name : #PreferenceView,
	#superclass : #Object,
	#instVars : [
		'preference'
	],
	#classInstVars : [
		'registeredClasses'
	],
	#category : #PreferenceBrowser
}

{ #category : #'view registry' }
PreferenceView class >> handlesPanel: aPreferencePanel [
	self subclassResponsibility 
]

{ #category : #'instance creation' }
PreferenceView class >> preference: aPreference [
	^self new
		initializeWithPreference: aPreference;
		yourself
]

{ #category : #initialization }
PreferenceView >> initializeWithPreference: aPreference [
	preference := aPreference
]

{ #category : #'user interface' }
PreferenceView >> morphForName [

	^ ((StringMorph contents: self preference readableName)
			color: ((UserInterfaceTheme current get: #textColor for: PluggableListMorph) ifNil: [Color black]);
			font: ((UserInterfaceTheme current get: #font for: PluggableListMorph) ifNil: [TextStyle defaultFont]);
			yourself)
]

{ #category : #accessing }
PreferenceView >> preference [
	^preference
]

{ #category : #'user interface' }
PreferenceView >> representativeButtonWithColor: aColor inPanel: aPreferencesPanel [
	self subclassResponsibility 
]

{ #category : #'user interface' }
PreferenceView >> tearOffButton [
	"Hand the user a button the can control this"

	| aButton |
	aButton := self representativeButtonWithColor: ((UserInterfaceTheme current get: #uniformWindowColor for: Model) ifNil: [Color white]) inPanel: nil.
	aButton borderWidth: 1; borderColor:  Color black; useRoundedCorners.
	aButton openInHand
]
