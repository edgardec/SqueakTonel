Class {
	#name : #PluggableTextController,
	#superclass : #StringHolderController,
	#category : #'ST80-Pluggable Views'
}

{ #category : #'menu messages' }
PluggableTextController >> accept [ 
	view hasUnacceptedEdits ifFalse: [^ view flash].
	view hasEditingConflicts ifTrue:
		[(self confirm: 
'Caution! This method may have been
changed elsewhere since you started
editing it here.  Accept anyway?' translated) ifFalse: [^ self flash]].

	(view setText: paragraph text from: self) == true ifTrue:
		[initialText := paragraph text copy.
		view ifNotNil: [view hasUnacceptedEdits: false]]    .

]

{ #category : #transcript }
PluggableTextController >> appendEntry [
	"Append the text in the model's writeStream to the editable text. "
	self deselect.
	paragraph text size > model characterLimit ifTrue:
		["Knock off first half of text"
		self selectInvisiblyFrom: 1 to: paragraph text size // 2.
		self replaceSelectionWith: Text new].
	self selectInvisiblyFrom: paragraph text size + 1 to: paragraph text size.
	self replaceSelectionWith: model contents asText.
	self selectInvisiblyFrom: paragraph text size + 1 to: paragraph text size
]

{ #category : #transcript }
PluggableTextController >> bsText [
	self changeText: (self text copyFrom: 1 to: (self text size - 1 max: 0))
]

{ #category : #transcript }
PluggableTextController >> changeText: aText [
	"The paragraph to be edited is changed to aText."
	paragraph text: aText.
	self resetState.
	self selectInvisiblyFrom: paragraph text size + 1 to: paragraph text size.
	self selectAndScroll.
	self deselect
]

{ #category : #transcript }
PluggableTextController >> doOccluded: actionBlock [
	| paneRect rectSet bottomStrip |
	paneRect := paragraph clippingRectangle.
	paragraph withClippingRectangle: (paneRect withHeight: 0)
		do: [actionBlock value.
			self scrollIn: paneRect].
	view topView isCollapsed ifTrue: [^ self].
	rectSet := self visibleAreas.
	bottomStrip := paneRect withTop: paragraph compositionRectangle bottom + 1.
	rectSet do:
		[:rect |
		(bottomStrip intersects: rect) ifTrue:
			["The subsequent displayOn should clear this strip but it doesnt"
			Display fill: (bottomStrip intersect: rect)
					fillColor: paragraph backgroundColor].
		paragraph withClippingRectangle: rect
				do: [paragraph displayOn: Display]]
]

{ #category : #transcript }
PluggableTextController >> scrollIn: scrollRect [
	"Altered from selectAndScroll so can use with null clipRect"
	"Scroll until the selection is in the view and then highlight it."
	| deltaY |
	deltaY := self stopBlock top - scrollRect top.
	deltaY >= 0 
		ifTrue: [deltaY := self stopBlock bottom - scrollRect bottom max: 0].
						"check if stopIndex below bottom of scrollRect"
	deltaY ~= 0 
		ifTrue: [self scrollBy: (deltaY abs + paragraph lineGrid - 1) * deltaY sign]
]

{ #category : #'accessing-selection' }
PluggableTextController >> selectForTopFrom: start to: stop [
	"Deselect, then select the specified characters inclusive.
	 Be sure the selection is in view."

	self selectFrom: start to: stop scroll: #selectAndScrollToTop
]

{ #category : #'accessing-selection' }
PluggableTextController >> selectFrom: start to: stop [
	"Deselect, then select the specified characters inclusive.
	 Be sure the selection is in view."

	self selectFrom: start to: stop scroll: #selectAndScroll
]

{ #category : #'accessing-selection' }
PluggableTextController >> selectFrom: start to: stop scroll: scrollCommand [
	"Deselect, then select the specified characters inclusive.
	 Be sure the selection is in view."

	(start = self startIndex and: [stop + 1 = self stopIndex]) ifFalse:
		[view superView ifNotNil: [self deselect].
		self selectInvisiblyFrom: start to: stop].
	view superView ifNotNil: [self perform: scrollCommand]
]

{ #category : #'edit flag' }
PluggableTextController >> userHasEdited [
	"Note that the user has edited my text."

	view hasUnacceptedEdits: true
]

{ #category : #'edit flag' }
PluggableTextController >> userHasNotEdited [
	"Note that my text is free of user edits."

	view hasUnacceptedEdits: false
]

{ #category : #transcript }
PluggableTextController >> visibleAreas [
	"Transcript dependents last controller visibleAreas"
	| myTopController visibleAreas |
	myTopController := self view topView controller.
	visibleAreas := Array with: view insetDisplayBox.
	myTopController view uncacheBits.
	ScheduledControllers scheduledWindowControllers do:
		[:c | | remnants rect |
		c == myTopController ifTrue: [^ visibleAreas].
		rect := c view windowBox.
		remnants := OrderedCollection new.
		visibleAreas do: [:a | remnants addAll: (a areasOutside: rect)].
		visibleAreas := remnants].
	^ visibleAreas
]
