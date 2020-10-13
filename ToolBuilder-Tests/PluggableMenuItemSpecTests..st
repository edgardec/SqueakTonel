Class {
	#name : #PluggableMenuItemSpecTests,
	#superclass : #TestCase,
	#category : #'ToolBuilder-Tests'
}

{ #category : #'as yet unclassified' }
PluggableMenuItemSpecTests >> testBeCheckableMakesItemCheckable [
	| itemSpec |
	itemSpec := PluggableMenuItemSpec new.
	itemSpec beCheckable.
	self assert: itemSpec isCheckable description: 'Item not checkable'.
]

{ #category : #'as yet unclassified' }
PluggableMenuItemSpecTests >> testByDefaultNotCheckable [
	| itemSpec |
	itemSpec := PluggableMenuItemSpec new.
	self deny: itemSpec isCheckable.
]

{ #category : #'as yet unclassified' }
PluggableMenuItemSpecTests >> testNoMarkerMakesItemChecked [
	| itemSpec |
	itemSpec := PluggableMenuItemSpec new.
	itemSpec label: '<no>no'.
	itemSpec analyzeLabel.
	self assert: itemSpec isCheckable description: 'item not checkable'.
	self deny: itemSpec checked description: 'item checked'.
]

{ #category : #'as yet unclassified' }
PluggableMenuItemSpecTests >> testOffMarkerMakesItemChecked [
	| itemSpec |
	itemSpec := PluggableMenuItemSpec new.
	itemSpec label: '<off>off'.
	itemSpec analyzeLabel.
	self assert: itemSpec isCheckable description: 'item not checkable'.
	self deny: itemSpec checked description: 'item checked'.
]

{ #category : #'as yet unclassified' }
PluggableMenuItemSpecTests >> testOnMarkerMakesItemChecked [
	| itemSpec |
	itemSpec := PluggableMenuItemSpec new.
	itemSpec label: '<on>on'.
	itemSpec analyzeLabel.
	self assert: itemSpec isCheckable description: 'item not checkable'.
	self assert: itemSpec isCheckable description: 'item not checked'.
]

{ #category : #'as yet unclassified' }
PluggableMenuItemSpecTests >> testYesMarkerMakesItemChecked [
	| itemSpec |
	itemSpec := PluggableMenuItemSpec new.
	itemSpec label: '<yes>on'.
	itemSpec analyzeLabel.
	self assert: itemSpec isCheckable description: 'item not checkable'.
	self assert: itemSpec isCheckable description: 'item not checked'.
]
