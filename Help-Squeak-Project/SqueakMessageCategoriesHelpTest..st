Class {
	#name : #SqueakMessageCategoriesHelpTest,
	#superclass : #TestCase,
	#category : #'Help-Squeak-Project'
}

{ #category : #tests }
SqueakMessageCategoriesHelpTest >> testCategoriesAreConsistent [

	| helpInstance |
	helpInstance := SqueakMessageCategoriesHelp new.
	SqueakMessageCategoriesHelp selectors do: [:selector | |correctCategory|
		correctCategory := SqueakMessageCategoriesHelp organization categoryOfElement: selector.
		(helpInstance perform: selector) do: [:method |
			self 
				assert: ((method methodClass organization categoryOfElement: method selector) beginsWith: correctCategory)
				description: 'Expected category ' , correctCategory]]
]
