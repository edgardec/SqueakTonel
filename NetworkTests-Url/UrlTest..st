"
This is the unit test for the class Url. Unit tests are a good way to exercise the functionality of your system in a repeatable and automatic manner. They are therefore recommended if you plan to release anything. For more information, see: 
	- http://www.c2.com/cgi/wiki?UnitTest
	- http://minnow.cc.gatech.edu/squeak/1547
	- the sunit class category
"
Class {
	#name : #UrlTest,
	#superclass : #ClassTestCase,
	#instVars : [
		'url',
		'baseUrl',
		'expected',
		'string'
	],
	#category : #'NetworkTests-Url'
}

{ #category : #tests }
UrlTest >> testAbsoluteBrowser [

	url := Url absoluteFromText: 'browser:bookmarks#mainPart'.

	self assert: url schemeName = 'browser'.
	self assert: url locator = 'bookmarks'.
	self assert:url fragment = 'mainPart'.
	self assert: url class = BrowserUrl.
	
]

{ #category : #tests }
UrlTest >> testAbsoluteFILE [
	
	url := Url absoluteFromText: 'file:/etc/passwd#foo'.

	self assert: url schemeName = 'file'.
	self assert: url path first = 'etc'.
	self assert: url path size = 2.	
	self assert: url fragment = 'foo'.
]

{ #category : #tests }
UrlTest >> testAbsoluteFILE2 [
	
	url := 'fILE:/foo/bar//zookie/?fakequery/#fragger' asUrl.

	self assert: url schemeName = 'file'.
	self assert: url class = FileUrl.
	self assert: url path first ='foo'.
	self assert: url path size = 5.
	self assert: url fragment = 'fragger'.
]

{ #category : #tests }
UrlTest >> testAbsoluteFILE3 [
	"Just a few selected tests for FileUrl, not complete by any means."


	{'file:'. 'file:/'. 'file://'} do: [:s |
	 	url := FileUrl absoluteFromText: s.
		self assert: (url asString = 'file:///').
		self assert: (url host = '').
		self assert: url isAbsolute].
	
	url := FileUrl absoluteFromText: 'file://localhost/dir/file.txt'.
	self assert: (url asString = 'file://localhost/dir/file.txt').
	self assert: (url host = 'localhost').
	
	url := FileUrl absoluteFromText: 'file://localhost/dir/file.txt'.
	self assert: (url asString = 'file://localhost/dir/file.txt').
	self assert: (url host = 'localhost').
	self assert: url isAbsolute.
	
	url := FileUrl absoluteFromText: 'file:///dir/file.txt'.
	self assert: (url asString = 'file:///dir/file.txt').
	self assert: (url host = '').
	self assert: url isAbsolute.
	
	url := FileUrl absoluteFromText: '/dir/file.txt'.
	self assert: (url asString = 'file:///dir/file.txt').
	self assert: url isAbsolute.
	
	url := FileUrl absoluteFromText: 'dir/file.txt'.
	self assert: (url asString = 'file:///dir/file.txt').
	self deny: url isAbsolute.
	
	url := FileUrl absoluteFromText: 'c:/dir/file.txt'.
	self assert: (url asString = 'file:///c%3A/dir/file.txt').
	self assert: url isAbsolute.
	
	"Only a drive letter doesn't refer to a directory."
	url := FileUrl absoluteFromText: 'c:'.
	self assert: (url asString = 'file:///c%3A/').
	self assert: url isAbsolute.
	
	url := FileUrl absoluteFromText: 'c:/'.
	self assert: (url asString = 'file:///c%3A/').
	self assert: url isAbsolute
]

{ #category : #tests }
UrlTest >> testAbsoluteFTP [
	
	url := 'ftP://some.server/some/directory/' asUrl.

	self assert: url schemeName = 'ftp'.
	self assert: url class = FtpUrl.
	self assert: url authority = 'some.server'.	
	self assert: url path first = 'some'.
	self assert: url path size  = 3.
	
]

{ #category : #tests }
UrlTest >> testAbsoluteHTTP [
	
	url := 'hTTp://chaos.resnet.gatech.edu:8000/docs/java/index.html?A%20query%20#part' asUrl.

	self assert: url schemeName = 'http'.
	self assert: url authority = 'chaos.resnet.gatech.edu'.
	self assert: url path first = 'docs'.
	self assert: url path size = 3.
	self assert: url query = 'A%20query%20'.
	self assert: url fragment = 'part'.
]

{ #category : #tests }
UrlTest >> testAbsolutePortErrorFix [
	"This should not throw an exception."
	Url absoluteFromText: 'http://swikis.ddo.jp:8823/'.

	self should: [Url absoluteFromText: 'http://swikis.ddo.jp:-1/'] raise: Error.
	self should: [Url absoluteFromText: 'http://swikis.ddo.jp:65536/'] raise: Error.
	self should: [Url absoluteFromText: 'http://swikis.ddo.jp:auau/'] raise: Error.
]

{ #category : #tests }
UrlTest >> testAbsoluteTELNET [
	
	url := 'telNet:chaos.resnet.gatech.edu#goo' asUrl.

	self assert: url schemeName = 'telnet'.
	self assert: url locator = 'chaos.resnet.gatech.edu'.
	self assert: url fragment = 'goo'.	

]

{ #category : #tests }
UrlTest >> testCombineWithRelative [
	#(#('http://www.rfc1149.net/' 'foo.html' 'http://www.rfc1149.net/foo.html') #('http://www.rfc1149.net/index.html' 'foo.html' 'http://www.rfc1149.net/foo.html') #('http://www.rfc1149.net/devel/' '../sam/' 'http://www.rfc1149.net/sam/') #('http://www.rfc1149.net/devel/index.html' '../sam/' 'http://www.rfc1149.net/sam/')) 
		do: [:a | self assert: (Url combine: a first withRelative: a second) = a third]
]

{ #category : #tests }
UrlTest >> testFromFileNameOrUrlString [

	url := Url absoluteFromFileNameOrUrlString: 'asdf'.
	self assert: url schemeName = 'file'.
	self assert: url fragment isNil.
	self assert: url class = FileUrl.

	url := Url absoluteFromFileNameOrUrlString: 'http://209.143.91.36/super/SuperSwikiProj/AAEmptyTest.001.pr'.
	self assert: url schemeName = 'http'.
	self assert: url fragment isNil.
	self assert: url class = HttpUrl.
]

{ #category : #tests }
UrlTest >> testRelativeFILE [
	
	| url2 |
	baseUrl := 'file:/some/dir#fragment1' asUrl.
	url := baseUrl newFromRelativeText: 'file:../another/dir/#fragment2'.
	self assert: url asText =  'file:///another/dir/#fragment2'.
	
	url := FileUrl absoluteFromText: 'file://localhost/dir/dir2/file.txt'.
	url2 := FileUrl absoluteFromText: 'file://hostname/flip/file.txt'.
	url2 privateInitializeFromText: '../file2.txt' relativeTo: url.
	self assert: (url2 asString = 'file://localhost/dir/file2.txt').
	self assert: (url2 host = 'localhost').
	self assert: url2 isAbsolute.
	
	url := FileUrl absoluteFromText: 'file://localhost/dir/dir2/file.txt'.
	url2 := FileUrl absoluteFromText: 'flip/file.txt'.
	self deny: url2 isAbsolute.
	url2 privateInitializeFromText: '.././flip/file.txt' relativeTo: url.
	self assert: (url2 asString = 'file://localhost/dir/flip/file.txt').
	self assert: (url2 host = 'localhost').
	self assert: url2 isAbsolute.
	

]

{ #category : #tests }
UrlTest >> testRelativeFTP [
	
	baseUrl := 'ftp://somewhere/some/dir/?query#fragment' asUrl.
	url := baseUrl newFromRelativeText: 'ftp://a.b'.

	self assert: url asString =  'ftp://a.b/'.
]

{ #category : #tests }
UrlTest >> testRelativeFTP2 [
	
	baseUrl := 'ftp://somewhere/some/dir/?query#fragment' asUrl.
	url := baseUrl newFromRelativeText: 'ftp:xyz'.


	self assert: url asString =  'ftp://somewhere/some/dir/xyz'.
]

{ #category : #tests }
UrlTest >> testRelativeFTP3 [
	
	baseUrl := 'ftp://somewhere/some/dir/?query#fragment' asUrl.
	url := baseUrl newFromRelativeText: 'http:xyz'.

	self assert: url asString = 'http://xyz/'.
]

{ #category : #tests }
UrlTest >> testRelativeHTTP [
	
	baseUrl := 'http://some.where/some/dir?query1#fragment1' asUrl.
	url := baseUrl newFromRelativeText: '../another/dir/?query2#fragment2'.

	self assert: url asString =  'http://some.where/another/dir/?query2#fragment2'.
]

{ #category : #tests }
UrlTest >> testRoundTripFILE [
	"File URLs should round-trip OK. This test should ultimately be
	tested on all platforms."

	| fileName |
	fileName := FileDirectory default fullNameFor: 'xxx.st'.
	url := FileDirectory urlForFileNamed: fileName.
	self assert: (url pathForFile = fileName) description: 'fileName didn''t round-trip'.
]

{ #category : #tests }
UrlTest >> testUrlEncoded [
	"Test the behavior of #urlEncoded"

	self assert: 'http://squeak.org/name with space?and=value' urlEncoded
		equals: 'http://squeak.org/name%20with%20space?and=value'.

	self assert: 'http://squeak.org/name%20with%20space?and=value' urlEncoded
		equals: 'http://squeak.org/name%20with%20space?and=value'.

	self assert: 'http://squeak.org/name%with%space?and=value' urlEncoded
		equals: 'http://squeak.org/name%25with%25space?and=value'.

]

{ #category : #tests }
UrlTest >> testUsernamePassword [

	"basic case with a username+password specified"
	url := 'http://user:pword@someserver.blah:8000/root/index.html' asUrl.
	self should: [ url schemeName = 'http' ].
	self should: [ url authority = 'someserver.blah' ].
	self should: [ url port = 8000 ].
	self should: [ url path first = 'root' ].
	self should: [ url username = 'user' ].
	self should: [ url password = 'pword' ].

	"basic case for a relative url"
	baseUrl := 'http://anotherserver.blah:9999/somedir/someotherdir/stuff/' asUrl.
	url := 'http://user:pword@someserver.blah:8000/root/index.html' asUrlRelativeTo: baseUrl.
	self should: [ url schemeName = 'http' ].
	self should: [ url authority = 'someserver.blah' ].
	self should: [ url port = 8000 ].
	self should: [ url path first = 'root' ].
	self should: [ url username = 'user' ].
	self should: [ url password = 'pword' ].

	"a true relative test that should keep the username and password from the base URL"
	baseUrl := 'http://user:pword@someserver.blah:8000/root/index.html' asUrl.
	url := '/anotherdir/stuff/' asUrlRelativeTo: baseUrl.
	self should: [ url schemeName = 'http' ].
	self should: [ url authority = 'someserver.blah' ].
	self should: [ url port = 8000 ].
	self should: [ url path first = 'anotherdir' ].
	self should: [ url username = 'user' ].
	self should: [ url password = 'pword' ].
	


	"just a username specified"
	url := 'http://user@someserver.blah:8000/root/index.html' asUrl.
	self should: [ url schemeName = 'http' ].
	self should: [ url authority = 'someserver.blah' ].
	self should: [ url port = 8000 ].
	self should: [ url path first = 'root' ].
	self should: [ url username = 'user' ].
	self should: [ url password = nil ].


	"the port is not specified"
	url := 'http://user:pword@someserver.blah/root/index.html' asUrl.
	self should: [ url schemeName = 'http' ].
	self should: [ url authority = 'someserver.blah' ].
	self should: [ url port = nil ].
	self should: [ url path first = 'root' ].
	self should: [ url username = 'user' ].
	self should: [ url password = 'pword' ].


	"neither a path nor a port is specified"
	url := 'http://user:pword@someserver.blah' asUrl.
	self should: [ url schemeName = 'http' ].
	self should: [ url authority = 'someserver.blah' ].
	self should: [ url port = nil ].
	self should: [ url username = 'user' ].
	self should: [ url password = 'pword' ].


	"relative URL where the username+password should be forgotten"
	baseUrl := 'http://user:pword@someserver.blah' asUrl.
	url := 'http://anotherserver.blah' asUrlRelativeTo: baseUrl.
	self should: [ url username = nil ].
	self should: [ url password = nil ].


]

{ #category : #tests }
UrlTest >> testUsernamePasswordEncoded [
	"Sometimes, weird usernames or passwords are necessary in 
	applications, and, thus, we might receive them in a Url.
	The @ and the : ar the kind of critical ones.
	"

	#(	"('user' 'pword' 'host' port 'path')"
		('Fürst Pückler' 'leckerEis' 'cottbus.brandenburg' 80 'mein/Zuhause')
		('Jeannde.d''Arc' 'jaiunesécret' 'orleans' 8080 'une/deux/trois')
		('HaXor@roxor:fnac' 'my~Pa$§wert' 'cbase' 42 'do/not_try')
	) do: [:urlParts | |theUrl|
		theUrl := ('http://{1}:{2}@{3}:{4}/{5}' format: {
			(urlParts at: 1) encodeForHTTP. 	(urlParts at: 2) encodeForHTTP.
			urlParts at: 3. urlParts at: 4. urlParts at: 5.
		}) asUrl.
		self 
			should: [theUrl schemeName = 'http'];
			should: [theUrl username = (urlParts at: 1)];
			should: [theUrl password = (urlParts at: 2)];
			should: [theUrl authority = (urlParts at: 3)];
			should: [theUrl port = (urlParts at: 4)];
			should: [theUrl path first = ((urlParts at: 5) copyUpTo: $/)]].

]

{ #category : #tests }
UrlTest >> testUsernamePasswordPrinting [

	#(	'http://user:pword@someserver.blah:8000/root/index.html'
		'http://user@someserver.blah:8000/root/index.html' 
		'http://user:pword@someserver.blah/root/index.html'
	) do: [ :urlText |
		self should: [ urlText = urlText asUrl asString ] ].


]

{ #category : #tests }
UrlTest >> testUsernamePasswordPrintingEncoded [

	#(	'http://F%C3%BCrst%20P%C3%BCckler:leckerEis@cottbus.brandenburg:80/mein/Zuhause'
		'http://Jeannde.d%27Arc:jaiunes%C3%A9cret@orleans:8080/une/deux/trois' 
		'http://HaXor%40roxor%3Afnac:my%7EPa%24%C2%A7wert@cbase:42/do/not_try'
	) do: [ :urlText |
		self should: [ urlText = urlText asUrl asString ] ].


]
