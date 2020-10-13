"
This is the unit test for the class MailAddressParser. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category
"
Class {
	#name : #MailAddressParserTest,
	#superclass : #TestCase,
	#category : #'NetworkTests-RFC822'
}

{ #category : #fixtures }
MailAddressParserTest >> stringOfMailAddresses [
	^ 'joe@lama.com, joe2@lama.com, joe3@lama.com, joe4 , Not an Address <joe5@address>, joe.(annoying (nested) comment)literal@[1.2.3.4], "an annoying" group : joe1@groupie, joe2@groupie, "Joey3" joe3@groupy, "joe6"."joe8"@group.com;,  Lex''s email account <lex>, foo+bar@baz.com, romeo&juliet@shakespeare.uk, "Name" mail@email.com'.
]

{ #category : #tests }
MailAddressParserTest >> testAddressesAndNamePairsIn [

	| correctAnswer parsedParis |

	correctAnswer := #(
		('' 'joe@lama.com') 
		('' 'joe2@lama.com') 
		('' 'joe3@lama.com') 
		('' 'joe4')
		('Not an Address' 'joe5@address') 
		('' 'joe.literal@[1.2.3.4]') 
		('' 'joe1@groupie') 
		('' 'joe2@groupie') 
		('Joey3' 'joe3@groupy') 
		('' '"joe6"."joe8"@group.com')
		('Lex''s email account' 'lex')
		('' 'foo+bar@baz.com')
		('' 'romeo&juliet@shakespeare.uk')
		('Name' 'mail@email.com')) asOrderedCollection.

	parsedParis := MailAddressParser addressesAndNamePairsIn: self stringOfMailAddresses.
	self assert: correctAnswer equals: parsedParis.
]

{ #category : #tests }
MailAddressParserTest >> testAddressesIn [

	| correctAnswer |

	correctAnswer := #(
		'joe@lama.com' 
		'joe2@lama.com' 
		'joe3@lama.com' 
		'joe4' 
		'joe5@address' 
		'joe.literal@[1.2.3.4]' 
		'joe1@groupie' 
		'joe2@groupie' 
		'joe3@groupy' 
		'"joe6"."joe8"@group.com' 
		'lex' 
		'foo+bar@baz.com' 
		'romeo&juliet@shakespeare.uk'
		'mail@email.com') asOrderedCollection.

	self assert: correctAnswer equals: (MailAddressParser addressesIn: self stringOfMailAddresses).
]
