Class {
	#name : #PBTextPreferenceView,
	#superclass : #PBPreferenceView,
	#category : #PreferenceBrowser
}

{ #category : #'class initialization' }
PBTextPreferenceView class >> initialize [
	PreferenceViewRegistry ofTextPreferences register: self.
]

{ #category : #'class initialization' }
PBTextPreferenceView class >> unload [
	"Unload order is not guaranteed so guard against failure"
	[PreferenceViewRegistry ofTextPreferences unregister: self] on: Error do:[]
]

{ #category : #'user interface' }
PBTextPreferenceView >> preferenceValue [
	^self preference preferenceValue ifNil: ['']
]

{ #category : #'user interface' }
PBTextPreferenceView >> preferenceValue: aTextOrString [
	self preference preferenceValue: aTextOrString asString.
	^true.
]

{ #category : #'user interface' }
PBTextPreferenceView >> representativeButtonWithColor: aColor inPanel: aPreferenceBrowser [
	^self horizontalPanel
		layoutInset: 2;
		color: aColor;
		cellGap: 20;
		cellPositioning: #center;
		addMorphBack: self morphForName;
		addMorphBack: self textField;
		yourself.
]

{ #category : #'user interface' }
PBTextPreferenceView >> textField [

	^(PluggableTextMorph
		on: self
		text: #preferenceValue
		accept: #preferenceValue:)
			acceptOnCR: true;
			wrapFlag: false;
			hideScrollBarsIndefinitely;
			borderStyle: BorderStyle inset;
			borderWidth: 1;
			vResizing: #rigid;
			hResizing: #spaceFill;
			height: TextStyle defaultFont height + 6;

			yourself.
]
