Class {
	#name : #PBNumericPreferenceView,
	#superclass : #PBPreferenceView,
	#category : #PreferenceBrowser
}

{ #category : #'class initialization' }
PBNumericPreferenceView class >> initialize [
	PreferenceViewRegistry ofNumericPreferences register: self.
]

{ #category : #'class initialization' }
PBNumericPreferenceView class >> unload [
	"Unload order is not guaranteed so guard against failure"
	[PreferenceViewRegistry ofNumericPreferences unregister: self] on: Error do:[].
]

{ #category : #'user interface' }
PBNumericPreferenceView >> preferenceValue [
	^self preference preferenceValue asString
]

{ #category : #'user interface' }
PBNumericPreferenceView >> preferenceValue: aTextOrString [
	(aTextOrString notEmpty and: [aTextOrString asString isAllDigits])
		ifFalse: [^false].
	self preference preferenceValue: aTextOrString asNumber.
	^true.
]

{ #category : #'user interface' }
PBNumericPreferenceView >> representativeButtonWithColor: aColor inPanel: aPreferenceBrowser [
	^self horizontalPanel
		layoutInset: 2;
		color: aColor;
		cellGap: 20;
		cellPositioning: #center;
		addMorphBack: self morphForName;
		addMorphBack: self horizontalFiller;
		addMorphBack: self textField;
		yourself.
]

{ #category : #'user interface' }
PBNumericPreferenceView >> textField [
	^(PluggableTextMorph
		on: self
		text: #preferenceValue
		accept: #preferenceValue:)
			borderStyle: BorderStyle inset;
			borderWidth: 1;
			hideScrollBarsIndefinitely;
			acceptOnCR: true;
			wrapFlag: false;
			vResizing: #rigid;
			hResizing: #spaceFill;
			height: TextStyle defaultFont height + 6;
			yourself.
]
