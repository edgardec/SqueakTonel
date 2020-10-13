Class {
	#name : #SUnitToolBuilderTests,
	#superclass : #ToolBuilderTests,
	#category : #'ToolBuilder-SUnit'
}

{ #category : #support }
SUnitToolBuilderTests >> acceptWidgetText [
	widget accept: 'Some text'
]

{ #category : #support }
SUnitToolBuilderTests >> buttonWidgetEnabled [
	^ widget isEnabled
]

{ #category : #support }
SUnitToolBuilderTests >> changeListWidget [
	widget clickItemAt: widget selectedIndex + 1
]

{ #category : #support }
SUnitToolBuilderTests >> fireButtonWidget [
	widget click
]

{ #category : #support }
SUnitToolBuilderTests >> fireMenuItemWidget [
	widget click: 'Menu Item'
]

{ #category : #running }
SUnitToolBuilderTests >> setUp [
	super setUp.
	builder := SUnitToolBuilder new.
]

{ #category : #tests }
SUnitToolBuilderTests >> testHandlingNotification [
	| receivedSignal resumed |
	receivedSignal := resumed := false.
	[ | count |
	"client-code puts up progress, and signals some notications"
	count := 0.
	'doing something'
		displayProgressFrom: 0
		to: 10
		during:
			[ : bar | 10 timesRepeat:
				[ bar value: (count := count + 1).
				(Delay forMilliseconds: 200) wait.
				Notification signal: 'message'.
				resumed := true ] ] ]
		on: Notification
		do:
			[ : noti | receivedSignal := true.
			noti resume ].
	self
		 assert: receivedSignal ;
		 assert: resumed
]

{ #category : #tests }
SUnitToolBuilderTests >> testListCached [
	
	self makeItemList.
	queries := Bag new.
	self changed: #getList.
	widget list.
	widget list.
	self assert: queries size = 1
]

{ #category : #tests }
SUnitToolBuilderTests >> testListSelectionCached [
	
	self makeItemList.
	queries := Bag new.
	self changed: #getListSelection.
	widget selectedIndex.
	widget selectedIndex.
	self assert: queries size = 1
]

{ #category : #tests }
SUnitToolBuilderTests >> testTextCached [
	
	self makeText.
	queries := Bag new.
	self changed: #getText.
	widget text.
	widget text.
	self assert: queries size = 1
]

{ #category : #support }
SUnitToolBuilderTests >> widgetColor [
	^ widget color
]
