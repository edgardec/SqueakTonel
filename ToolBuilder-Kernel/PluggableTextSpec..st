"
A text editor.

Instance variables:
	getText	<Symbol>	The selector to retrieve the text.
	setText	<Symbol>	The selector to set the text.
	selection <Symbol>	The selector to retrieve the text selection.
	menu	<Symbol>	The selector to offer (to retrieve?) the context menu.
	color	 <Symbol>	The selector to retrieve the background color.


"
Class {
	#name : #PluggableTextSpec,
	#superclass : #PluggableWidgetSpec,
	#instVars : [
		'getText',
		'setText',
		'selection',
		'menu',
		'askBeforeDiscardingEdits',
		'editText',
		'indicateUnacceptedChanges',
		'stylerClass',
		'font',
		'readOnly',
		'softLineWrap',
		'hardLineWrap',
		'textColor'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #accessing }
PluggableTextSpec >> askBeforeDiscardingEdits [
	^askBeforeDiscardingEdits ifNil:[true]
]

{ #category : #accessing }
PluggableTextSpec >> askBeforeDiscardingEdits: aBool [
	askBeforeDiscardingEdits := aBool
]

{ #category : #building }
PluggableTextSpec >> buildWith: builder [
	^builder buildPluggableText: self
]

{ #category : #accessing }
PluggableTextSpec >> editText [
	^ editText
]

{ #category : #accessing }
PluggableTextSpec >> editText: aSymbol [
	"Answer the selector for getting informed about any modifications of the text."
	editText := aSymbol
]

{ #category : #accessing }
PluggableTextSpec >> font [
	^ font
]

{ #category : #accessing }
PluggableTextSpec >> font: aFont [
	font := aFont.
]

{ #category : #accessing }
PluggableTextSpec >> getText [
	"Answer the selector for retrieving the text"
	^getText
]

{ #category : #accessing }
PluggableTextSpec >> getText: aSymbol [
	"Answer the selector for retrieving the text"
	getText := aSymbol
]

{ #category : #accessing }
PluggableTextSpec >> hardLineWrap [

	^ hardLineWrap
]

{ #category : #accessing }
PluggableTextSpec >> hardLineWrap: aBoolean [

	hardLineWrap := aBoolean.
]

{ #category : #accessing }
PluggableTextSpec >> indicateUnacceptedChanges [
	^ indicateUnacceptedChanges ifNil: [true]
]

{ #category : #accessing }
PluggableTextSpec >> indicateUnacceptedChanges: aBoolean [
	indicateUnacceptedChanges := aBoolean.
]

{ #category : #accessing }
PluggableTextSpec >> menu [
	"Answer the selector for retrieving the text's menu"
	^menu
]

{ #category : #accessing }
PluggableTextSpec >> menu: aSymbol [
	"Indicate the selector for retrieving the text's menu"
	menu := aSymbol
]

{ #category : #accessing }
PluggableTextSpec >> readOnly [

	^ readOnly ifNil: [false]
]

{ #category : #accessing }
PluggableTextSpec >> readOnly: aBoolean [

	readOnly := aBoolean.
]

{ #category : #accessing }
PluggableTextSpec >> selection [
	"Answer the selector for retrieving the text selection"
	^selection
]

{ #category : #accessing }
PluggableTextSpec >> selection: aSymbol [
	"Indicate the selector for retrieving the text selection"
	selection := aSymbol
]

{ #category : #accessing }
PluggableTextSpec >> setText [
	"Answer the selector for setting the text"
	^setText
]

{ #category : #accessing }
PluggableTextSpec >> setText: aSymbol [
	"Answer the selector for setting the text"
	setText := aSymbol
]

{ #category : #accessing }
PluggableTextSpec >> softLineWrap [

	^ softLineWrap
]

{ #category : #accessing }
PluggableTextSpec >> softLineWrap: aBoolean [

	softLineWrap := aBoolean.
]

{ #category : #accessing }
PluggableTextSpec >> stylerClass [
	^ stylerClass
]

{ #category : #accessing }
PluggableTextSpec >> stylerClass: aStylerClass [
	stylerClass := aStylerClass.
]

{ #category : #accessing }
PluggableTextSpec >> textColor [
	^ textColor
]

{ #category : #accessing }
PluggableTextSpec >> textColor: aSymbol [
	textColor := aSymbol.
]
