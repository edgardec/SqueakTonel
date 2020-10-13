"
A PluggableSystemWindowWithLabelButton provides the pull-down menu of browser panes in the multi-pane browser.

Instance Variables
	labelButton:		<BrowserPaneButtonMorph>

labelButton
	- the labelButton is a hack to hold onto the panes of a multi-paned browser so that an inst var doesn't have to be added to the Browser hierarchy.

"
Class {
	#name : #PluggableSystemWindowWithLabelButton,
	#superclass : #PluggableSystemWindow,
	#instVars : [
		'labelButton'
	],
	#category : #'Morphic-Windows'
}

{ #category : #'resize\/collapse' }
PluggableSystemWindowWithLabelButton >> adjustExtraButton [
	labelButton ifNil: [^self].
	labelButton
		position: self innerBounds topLeft + (20 @ -3);
		extent: self innerBounds extent * (0.4@1)
]

{ #category : #geometry }
PluggableSystemWindowWithLabelButton >> extent: newExtent [
	super extent: newExtent.
	self adjustExtraButton
]

{ #category : #accessing }
PluggableSystemWindowWithLabelButton >> savedMultiWindowState: aSavedMultiWindowState [
	labelButton := MultiWindowLabelButtonMorph
						on: aSavedMultiWindowState
						getState: nil
						action: #selectWindowsMenu.
	labelButton
		triggerOnMouseDown: true;
		savedMultiWindowState: aSavedMultiWindowState.
	labelButton
		layoutFrame: (LayoutFrame "i.e. in the left 40% of the title bar"
						fractions: (0@0 corner: 0.4@0)
						offsets: (20@ -20 corner: 0@0));
		hResizing: #spaceFill;
		vResizing: #spaceFill.
	self addMorphFront: labelButton.
	self adjustExtraButton
]
