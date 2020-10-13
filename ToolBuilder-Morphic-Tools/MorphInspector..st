"
I am an inspector for morphs. In addition to field values I display properties of the morph, and add additional selections to the field item menu.
"
Class {
	#name : #MorphInspector,
	#superclass : #Inspector,
	#category : #'ToolBuilder-Morphic-Tools'
}

{ #category : #'menu - construction' }
MorphInspector >> addFieldItemsTo: aMenu [

	super addFieldItemsTo: aMenu.

	self isMorphSelected ifFalse: [^ self].
	
	aMenu addLine.
	
	aMenu addTranslatedList: #(
			('open screenshot in hand'			openScreenshotInHand)
			('open screenshot in world'			openScreenshotInWorld)).
]

{ #category : #fields }
MorphInspector >> fieldExtent [

	^ (self newFieldForType: #misc key: #extent)
		name: 'extent' translated; emphasizeName;
		valueGetter: [:morph | morph extent];
		valueSetter: [:morph :newExtent | morph extent: newExtent];
		yourself
]

{ #category : #fields }
MorphInspector >> fieldScreenshot [

	^ (self newFieldForType: #misc key: #screenshot)
		name: 'screenshot' translated; emphasizeName;
		printValueAsIs;
		valueGetter: [:morph |
			| screenshot |
			screenshot := morph imageForm.
			FormInspector new embedForm: screenshot inText: screenshot printString];
		yourself
]

{ #category : #morphs }
MorphInspector >> isMorphSelected [

	^ [self selectionOrObject isMorph] ifError: [false]
]

{ #category : #'menu - commands' }
MorphInspector >> openScreenshotInHand [

	^ self selectedMorph imageForm asMorph openInHand
]

{ #category : #'menu - commands' }
MorphInspector >> openScreenshotInWorld [

	^ self selectedMorph imageForm asMorph openInWorld
]

{ #category : #morphs }
MorphInspector >> selectedMorph [

	^ self selectionOrObject
]

{ #category : #'fields - streaming' }
MorphInspector >> streamBaseFieldsOn: aStream [

	super streamBaseFieldsOn: aStream.
	aStream
		nextPut: self fieldExtent;
		nextPut: self fieldScreenshot.
]

{ #category : #'fields - streaming' }
MorphInspector >> streamInstanceVariablesOn: aStream [

	super streamInstanceVariablesOn: aStream.
	self streamPropertiesOn: aStream.
]

{ #category : #'fields - streaming' }
MorphInspector >> streamPropertiesOn: aStream [
	"Prepend all properties with # (hash) so that users can distinguish them from regular instance variables. Trigger both #layoutChanged and #changed to be sure that any value changes yield the expected visual updates. Note that this is required because we invade the morph's privacy by exposing its extension object this way; normal updates are handled only through the morph's public interface. For example, compare Morph >> #visible: with MorphExtension >> #visible:."
	
	| extension field |
	(extension := self object extension) ifNil: [^ self].
	
	extension sortedPropertyNames do: [:property |
		(extension respondsTo: property)
			ifTrue: [field := (self newFieldForType: #property key: property)
				name: property printString;
				valueGetter: [:morph | morph extension perform: property];
				valueSetter: [:morph :value |
					morph extension perform: property asSimpleSetter with: value.
					morph layoutChanged; changed];
				yourself]
			ifFalse: [field := (self newFieldForType: #property key: property)
				name: property printString;
				valueGetter: [:morph | morph extension valueOfProperty: property];
				valueSetter: [:morph :value |
					morph extension setProperty: property toValue: value.
					morph layoutChanged; changed];
				yourself].
			
		aStream nextPut: field].
]
