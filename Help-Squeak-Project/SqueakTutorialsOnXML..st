Class {
	#name : #SqueakTutorialsOnXML,
	#superclass : #SqueakTutorials,
	#category : #'Help-Squeak-Project'
}

{ #category : #accessing }
SqueakTutorialsOnXML class >> bookName [ 
	^'XML'
]

{ #category : #pages }
SqueakTutorialsOnXML class >> dataRetrieval [
	"This method was automatically generated. Edit it using:"
	"SqueakTutorialsOnXML edit: #dataRetrieval"
	^HelpTopic 
		title: 'Retrieving XML data'
		contents: 
'Retrieving data from XML documents is simple and easy in Squeak Smalltalk. This tutorial demonstrates the fundamentals with a straightforward approach where code can be tested right away either here or in a Workspace window. The beauty of Squeak Smalltalk resides in the possibility to evaluate, inspect, print and debug code anywhere and this window is no different. 

This tutorial demonstrates how to...

	* retrieve an XML document from the World Wide Web
	* instantiate an XML document class
	* inspect and understand the content of an XML document
	* retrieve and display values from specific XML tags

Retrieve an XML document from the World Wide Web

There are many manners to retrieve data from the World Wide Web in Squeak Smalltalk. HTTPClient is among them and allows to download files in all simplicity. Select the following code snippet and inspect it (press alt-i). An Inspect window will open with the document loaded in memory. The result is a MIMEDocument object.

	HTTPClient httpGetDocument: ''http://source.squeak.org/trunk/feed.rss''.

TIP: Select HTTPClient and browse it (press alt-b) to open a System Browser window on its class. HTTPClient does not have instance methods but it has class methods. Click on class to see class methods.

Instantiate an XML Document

An instance of MIMEDocument will not allow to retrieve XML data in a comprehensive manner because it does not understand the nature of XML. For this reason, it is necessary to parse the content of MIMEDocument using XMLDOMParser. XMLDOMParser>>parseDocumentFrom: requires a stream as a parameter and ReadStream will be used for this purpose. The following code snippet instantiates an XMLDocument using the content of the downloaded file.

	| doc |
	doc := HTTPClient httpGetDocument: ''http://source.squeak.org/trunk/feed.rss''.
	XMLDOMParser parseDocumentFrom: (ReadStream on: (doc content)).

Inspect and understand the content of an XML document

XML is a flexible document format and it is necessary to understand how each given XML file is structured in order to properly search, retrieve and manipulate data. Inspecting values is critical in a dynamic programming language and environment, such as Squeak Smalltalk. Select the previous code snippet and inspect it (press alt-i).

Unfortunately, the Inspect window does not reveal a lot about the XML structure of the downloaded file. Select the previous code snippet once again and explore it (press alt and the capital letter i). An Explorer window will open with a tree outline on the instance of XMLDocument.

The Inspect and Explorer windows tell a lot about an XMLDocument. The sections are instance variables and their values are displayed aside. In the Explorer window, unfold elementsAndContents. Unfold other sections as deemed necessary to understand the XML format and the data available.

The gibberish coding is about to become clear. Open a Browser window from the world menu and right click in the first pane, select find class (press alt-f) and type XMLDocument to search for its class, or select the class name and browse it (press alt-b). However, it is suggested to read more about XMLParser and XMLParserTest first. 

Retrieve and display values from specific XML tags

The downloaded XML file contains a list of items which are denoted by the tag name "item". The Explorer window revealed the content of interest is located at the array index 1 of the elementsAndContents, which can be accessed through XMLDocument>>root.

TIP: Some XML documents have additional components contained within its file, such as XMLPI (XML Processing Instructions). For this reason, the root may lead to this rather than the data which will be indexed at 2 or more. It is necessary to use XMLNodeWithElements>>elements, e.g. (xml elements at: 2), in order to access subsequent data.

The following code snippet will display items in a Transcript window. Open a Transcript window using the world menu before selecting and executing the code. Select the code snippet and execute it (press alt-d).

	| doc xml |
	doc := HTTPClient httpGetDocument: ''http://source.squeak.org/trunk/feed.rss''.
	xml := XMLDOMParser parseDocumentFrom: (ReadStream on: (doc content)).
	xml root tagsNamed: #item do: [:e |
		Transcript show: (e asString); cr.
		].

An XML item looks like this:

	<item>
	<title>HelpSystem-Core-tbn.46.mcz</title>
	<link>http://source.squeak.org/trunk.html</link>
	<description>throw out pharo specific stuff since we are now integrated in squeak (and pharo too where squeak specific stuff was removed)</description>
	<pubDate>Sun, 02 May 2010 20:23:49 +0000</pubDate>
	<author>Torsten Bergmann &lt;Torsten.Bergmann@astares.de&gt;</author>
	<category>The Trunk</category>
	<enclosure length="27288" type="application/x-monticello" url="http://source.squeak.org/trunk/HelpSystem-Core-tbn.46.mcz"/> 
	<guid isPermaLink="false"/> </item>

The following code snippet uses information learned, retrieves each comment and displays them in a Transcript window. Notice an author can have a nil value and is handled accordingly.

	| doc xml |
	doc := HTTPClient httpGetDocument: ''http://source.squeak.org/trunk/feed.rss''.
	xml := XMLDOMParser parseDocumentFrom: (ReadStream on: (doc content)).
	xml root tagsNamed: #item do: [:e |
		Transcript 
			show: ''Date: '', ((e firstTagNamed: #pubDate) contentString); cr;
			show: ''Title: '', ((e firstTagNamed: #title) contentString); cr;
			show: ''Author: '', 
				(((e firstTagNamed: #author) notNil)
					ifTrue: [(e firstTagNamed: #author) contentString]
					ifFalse: ['''']); cr;
			show: ''Description: '', ((e firstTagNamed: #description) contentString); cr; cr.
			].

An item will now look like:

	Date: Sun, 02 May 2010 20:23:49 +0000
	Title: HelpSystem-Core-tbn.46.mcz
	Author: Torsten Bergmann <Torsten.Bergmann@astares.de>
	Description: throw out pharo specific stuff since we are now integrated in squeak (and pharo too where squeak specific stuff was removed)
'
]

{ #category : #accessing }
SqueakTutorialsOnXML class >> pages [
	^# (dataRetrieval)
]

{ #category : #testing }
SqueakTutorialsOnXML class >> usesCodeStyling [
	^ false
]
