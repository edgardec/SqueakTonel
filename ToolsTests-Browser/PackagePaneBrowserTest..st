Class {
	#name : #PackagePaneBrowserTest,
	#superclass : #TestCase,
	#instVars : [
		'browser'
	],
	#category : #'ToolsTests-Browser'
}

{ #category : #running }
PackagePaneBrowserTest >> setUp [
	browser := PackagePaneBrowser new.
]

{ #category : #tests }
PackagePaneBrowserTest >> testClassList [
	browser selectSystemCategory: browser class category.
	self assert: browser classList = (SystemOrganization listAtCategoryNamed: browser class category).
	
	browser selectSystemCategory: nil.
	self assert: browser classList isEmpty.
]

{ #category : #tests }
PackagePaneBrowserTest >> testPackageListIndex [
	browser packageListIndex: 0.
	self assert: browser selectedClass isNil.
	
	browser selectCategoryForClass: browser class.
	
	"Clicking the selected package unselects the selected class."
	browser packageListIndex: browser packageListIndex.
	self assert: browser selectedClass isNil.
]

{ #category : #tests }
PackagePaneBrowserTest >> testSelectCategoryForClass [
	| pkgName |
	pkgName := browser class category copyUpTo: $-.
	browser selectCategoryForClass: browser class.
	self assert: browser selectedSystemCategory = browser class category.
	self assert: browser packageListIndex = (browser packageList indexOf: pkgName).
	browser selectSystemCategory: nil.
	self assert: browser classList isEmpty.
]
