"
HelpBrowser openOn: SWikiHelp.
"
Class {
	#name : #SWikiHelp,
	#superclass : #CustomHelp,
	#category : #'Help-Squeak-SWiki'
}

{ #category : #converting }
SWikiHelp class >> asHelpTopic [

	^ HtmlHelpTopic new
		url: 'http://wiki.squeak.org/squeak';
		selectBlock: [:url | ((url beginsWith: '/squeak/') and: [(url includes: $.) not ".edit, .history, ..."]) and: [url last isDigit]];
		convertBlock: [:url | 'http://wiki.squeak.org', url];
		yourself
]

{ #category : #accessing }
SWikiHelp class >> ignore [
	"Experimental."
	^ true
]
