"
I subclass the PreferenceBrowserMorph to adapt the interface to services. So far the changes are minimal.
"
Class {
	#name : #ServiceBrowserMorph,
	#superclass : #PreferenceBrowserMorph,
	#category : #'Services-Base-GUI'
}

{ #category : #'as yet unclassified' }
ServiceBrowserMorph >> newButtonRow [
	^BorderedMorph new
		color: Color transparent; 
		cellGap: 2;
		layoutInset: 2;
		layoutPolicy: TableLayout new;
		listDirection: #leftToRight;
		listCentering: #topLeft;
		cellPositioning: #topLeft;
		on: #mouseEnter send: #paneTransition: to: self;
		on: #mouseLeave send: #paneTransition: to: self;
		"addMorphBack: self defaultButton;
		addMorphBack: self newSeparator;
		addMorphBack: self saveButton;
		addMorphBack: self loadButton;
		addMorphBack: self newSeparator;
		addMorphBack: self saveToDiskButton;
		addMorphBack: self loadFromDiskButton;
		addMorphBack: self newSeparator;
		addMorphBack: self newTransparentFiller;
		addMorphBack: self helpButton;"
		yourself.
]
