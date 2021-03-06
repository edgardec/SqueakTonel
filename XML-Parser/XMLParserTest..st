Class {
	#name : #XMLParserTest,
	#superclass : #ClassTestCase,
	#category : #'XML-Parser'
}

{ #category : #source }
XMLParserTest >> addressBookXML [
	^'<addressbook>
  <person employee-number="A0000" family-name="Gates" first-name="Bob">
    <contact-info><!--Confidential--></contact-info>
    <address city="Los Angeles" number="1239" state="CA" street="Pine Rd."/>
    <job-info employee-type="Full-Time" is-manager="no" job-description="Manager"/>
    <manager employee-number="A0000"/>
  </person>
  <person employee-number="A7000" family-name="Brown"
    first-name="Robert" middle-initial="L.">
    <contact-info>
      <email address="robb@iro.ibm.com"/>
      <home-phone number="03-3987873"/>
    </contact-info>
    <address city="New York" number="344" state="NY" street="118 St."/>
    <job-info employee-type="Full-Time" is-manager="yes" job-description="Group Leader"/>
    <manager employee-number="A0000"/>
  </person>
  <person employee-number="A7890" family-name="DePaiva"
    first-name="Kassie" middle-initial="W.">
    <contact-info><!-- Kassie''s agent phone: 03-987654 --></contact-info>
    <address city="Los Angeles" number="1234" state="CA" street="Pine Rd."/>
    <job-info employee-type="Full-Time" is-manager="no" job-description="Actor"/>
    <manager employee-number="A0000"/>
    <misc-info>One of the most talented actresses on Daytime. Kassie
      plays the devious and beautiful Blair Cramer on ABC&apos;s
      &quot;One Life To Live.&quot;</misc-info>
  </person>
  <person employee-number="A7987" family-name="Smith" first-name="Joe">
    <contact-info>
      <email address="joes@iro.ibm.com"/>
      <mobile-phone number="888-7657765"/>
      <home-phone number="03-8767898"/>
      <home-phone number="03-8767871"/>
    </contact-info>
    <address city="New York" number="12789" state="NY" street="W. 15th Ave."/>
    <job-info employee-type="Part-Time" is-manager="no" job-description="Hacker"/>
    <manager employee-number="A7000"/>
  </person>
</addressbook>
'
]

{ #category : #source }
XMLParserTest >> addressBookXMLWithDTD [
	^'<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE addressbook SYSTEM "addressbook.dtd">
<?xml-stylesheet type="text/xsl" href="demo.xsl"?>
<addressbook>
  <person employee-number="A0000" family-name="Gates" first-name="Bob">
    <contact-info><!--Confidential--></contact-info>
    <address city="Los Angeles" number="1239" state="CA" street="Pine Rd."/>
    <job-info employee-type="Full-Time" is-manager="no" job-description="Manager"/>
    <manager employee-number="A0000"/>
  </person>
  <person employee-number="A7000" family-name="Brown"
    first-name="Robert" middle-initial="L.">
    <contact-info>
      <email address="robb@iro.ibm.com"/>
      <home-phone number="03-3987873"/>
    </contact-info>
    <address city="New York" number="344" state="NY" street="118 St."/>
    <job-info employee-type="Full-Time" is-manager="yes" job-description="Group Leader"/>
    <manager employee-number="A0000"/>
  </person>
  <person employee-number="A7890" family-name="DePaiva"
    first-name="Kassie" middle-initial="W.">
    <contact-info><!-- Kassie''s agent phone: 03-987654 --></contact-info>
    <address city="Los Angeles" number="1234" state="CA" street="Pine Rd."/>
    <job-info employee-type="Full-Time" is-manager="no" job-description="Actor"/>
    <manager employee-number="A0000"/>
    <misc-info>One of the most talented actresses on Daytime. Kassie
      plays the devious and beautiful Blair Cramer on ABC&apos;s
      &quot;One Life To Live.&quot;</misc-info>
  </person>
  <person employee-number="A7987" family-name="Smith" first-name="Joe">
    <contact-info>
      <email address="joes@iro.ibm.com"/>
      <mobile-phone number="888-7657765"/>
      <home-phone number="03-8767898"/>
      <home-phone number="03-8767871"/>
    </contact-info>
    <address city="New York" number="12789" state="NY" street="W. 15th Ave."/>
    <job-info employee-type="Part-Time" is-manager="no" job-description="Hacker"/>
    <manager employee-number="A7000"/>
  </person>
</addressbook>
'
]

{ #category : #tests }
XMLParserTest >> testExampleAddressBook [
	| tokenizer |
	"self debug: #testExampleAddressBook"

	tokenizer := XMLTokenizer on: self addressBookXML readStream.

	"We enumerate the first characters of the addressbook example. The file being parsed begins with <addressbook"
	self assert: tokenizer next = $<.
	self assert: tokenizer next = $a.	
	self assert: tokenizer next = $d.
	self assert: tokenizer next = $d.
	self assert: tokenizer next = $r.

	"This should not raise an exception."
	[tokenizer next notNil] whileTrue: [].
]

{ #category : #tests }
XMLParserTest >> testExampleAddressBookWithDTD [
	| tokenizer |
	"XMLTokenizer exampleAddressBookWithDTD"

	tokenizer := XMLTokenizer on: self addressBookXMLWithDTD readStream.
	
	"This should not raise an exception."
	[tokenizer next notNil] whileTrue: [].
]

{ #category : #tests }
XMLParserTest >> testParsing [
	| xmlDocument root firstPerson numberOfPersons |
	"self debug: #testParsing"

	xmlDocument := XMLDOMParser parseDocumentFrom: self addressBookXML readStream.
	self assert: (xmlDocument isKindOf: XMLDocument).
	root := xmlDocument root.
	self assert: (root class == XMLElement).
	
	"the tag has to be a symbol!"
	self assert: (root firstTagNamed: 'person') isNil.
	self assert: (root firstTagNamed: 'addressbook') isNil.

	self assert: (root firstTagNamed: #addressbook) == root.

	numberOfPersons := 0.
	root tagsNamed: #person do: [:p | numberOfPersons := numberOfPersons + 1].
	self assert: numberOfPersons = 4.

	firstPerson := root firstTagNamed: #person.
	self assert: (firstPerson attributeAt: #'employee-number') = 'A0000'.
	self assert: (firstPerson attributeAt: #'family-name') = 'Gates'.
	self assert: (firstPerson attributeAt: #'first-name') = 'Bob'.
]

{ #category : #tests }
XMLParserTest >> testParsingCharacters [
	| parser |
	"This test is actually not that useful. This is not the proper way of using the parser. This test is here just for specification purpose"
	"self debug: #testParsingCharacters"

	parser := XMLParser on: self addressBookXML readStream.

	self assert: parser next = $<.
	self assert: parser next = $a.	
	self assert: parser next = $d.
	self assert: parser next = $d.
	self assert: parser next = $r.
]

{ #category : #tests }
XMLParserTest >> testPrintElements [
	| node |
	node:= (XMLElement new) name: 'foo';
		setAttributes: (Dictionary new);
		yourself.
	self assert: node asString withBlanksTrimmed = '<foo/>'.

	node:= (XMLElement new) name: 'foo';
		setAttributes: (Dictionary newFromPairs: {'id'. '123'});
		yourself.
	self assert: node asString withBlanksTrimmed = '<foo id="123"/>'.

	node:= (XMLElement new) name: 'foo';
		addContent: (XMLStringNode string: 'Hello World'); 
		setAttributes: (Dictionary new);
		yourself.
	self assert: node asString withBlanksTrimmed = '<foo>Hello World</foo>'.

	node:= (XMLElement new) name: 'foo';
		addContent: (XMLStringNode string: 'Hello World'); 
		setAttributes: (Dictionary newFromPairs: {'id'. '123'});
		yourself.
	self assert: node asString withBlanksTrimmed = '<foo id="123">Hello World</foo>'.


]
