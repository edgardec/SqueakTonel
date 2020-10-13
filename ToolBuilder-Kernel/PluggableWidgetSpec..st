"
The abstract superclass for all widgets.

Instance variables:
	model	<Object>	The object the various requests should be directed to.
	frame	<Rectangle> The associated layout frame for this object (if any).

"
Class {
	#name : #PluggableWidgetSpec,
	#superclass : #ToolBuilderSpec,
	#instVars : [
		'model',
		'frame',
		'color',
		'minimumExtent',
		'margin',
		'padding',
		'horizontalResizing',
		'verticalResizing'
	],
	#category : #'ToolBuilder-Kernel'
}

{ #category : #accessing }
PluggableWidgetSpec >> color [
	"Answer the selector for retrieving the button's color"
	^color
]

{ #category : #accessing }
PluggableWidgetSpec >> color: aSymbol [
	"Indicate the selector for retrieving the button's color"
	color := aSymbol
]

{ #category : #accessing }
PluggableWidgetSpec >> frame [
	"Answer the receiver's layout frame"
	^frame
]

{ #category : #accessing }
PluggableWidgetSpec >> frame: aRectangle [
	"Indicate the receiver's layout frame"
	frame := aRectangle
]

{ #category : #'layout hints' }
PluggableWidgetSpec >> horizontalResizing [

	^ horizontalResizing
]

{ #category : #'layout hints' }
PluggableWidgetSpec >> horizontalResizing: aSymbol [
	"#rigid, #spaceFill, #shrinkWrap"

	horizontalResizing := aSymbol.
]

{ #category : #'layout hints' }
PluggableWidgetSpec >> margin [
	"Space outside the widgets border.
	See: http://www.w3.org/wiki/The_CSS_layout_model_-_boxes_borders_margins_padding"
	
	^ margin
]

{ #category : #'layout hints' }
PluggableWidgetSpec >> margin: numberOrPointOrRectangle [

	margin := numberOrPointOrRectangle.
]

{ #category : #'layout hints' }
PluggableWidgetSpec >> minimumExtent [

	^ minimumExtent ifNil: [-1 @ -1]
]

{ #category : #'layout hints' }
PluggableWidgetSpec >> minimumExtent: aPoint [

	minimumExtent := aPoint.
]

{ #category : #'layout hints' }
PluggableWidgetSpec >> minimumHeight [

	^ self minimumExtent y
]

{ #category : #'layout hints' }
PluggableWidgetSpec >> minimumHeight: aNumber [

	self minimumExtent: self minimumExtent x @ aNumber.
]

{ #category : #'layout hints' }
PluggableWidgetSpec >> minimumWidth [

	^ self minimumExtent x
]

{ #category : #'layout hints' }
PluggableWidgetSpec >> minimumWidth: aNumber [

	self minimumExtent: aNumber @ self minimumExtent y.
]

{ #category : #accessing }
PluggableWidgetSpec >> model [
	"Answer the model for which this widget should be built"
	^model
]

{ #category : #accessing }
PluggableWidgetSpec >> model: aModel [
	"Indicate the model for which this widget should be built"
	model := aModel.
]

{ #category : #'layout hints' }
PluggableWidgetSpec >> padding [
	"Space inside the widget's border.
	See: http://www.w3.org/wiki/The_CSS_layout_model_-_boxes_borders_margins_padding"
	
	^ padding
]

{ #category : #'layout hints' }
PluggableWidgetSpec >> padding: numberOrPointOrRectangle [

	padding := numberOrPointOrRectangle.
]

{ #category : #'layout hints' }
PluggableWidgetSpec >> verticalResizing [

	^ verticalResizing
]

{ #category : #'layout hints' }
PluggableWidgetSpec >> verticalResizing: aSymbol [
	"#rigid, #spaceFill, #shrinkWrap"

	verticalResizing := aSymbol.
]
