"
Main comment stating the purpose of this class and relevant relationship to other classes.


   Some parsers allow the scheme name to be present in a relative URI if
   it is the same as the base URI scheme.  This is considered to be a
   loophole in prior specifications of partial URI [RFC1630]. Its use
   should be avoided.

      http:g        =  http:g           ; for validating parsers
                    |  http://a/b/c/g   ; for backwards compatibility

"
Class {
	#name : #TestURI,
	#superclass : #TestCase,
	#category : #'NetworkTests-URI'
}

{ #category : #'test generation' }
TestURI class >> generateAbnormalResolverTests [
	"TestURI generateAbnormalResolverTests"

	| relURIString result method testPairs pair |

	testPairs := #(
		#('../../../g' 'http://a/../g' )
		#('../../../../g' 'http://a/../../g' )
		#('/./g' 'http://a/./g' )
		#('/../g' 'http://a/../g' )
		#('g.' 'http://a/b/c/g.' )
		#('.g' 'http://a/b/c/.g' )
		#('g..' 'http://a/b/c/g..' )
		#('..g' 'http://a/b/c/..g' )
		#('./../g' 'http://a/b/g' )
		#('./g/.' 'http://a/b/c/g/' )
		#('g/./h' 'http://a/b/c/g/h' )
		#('g/../h' 'http://a/b/c/h' )
		#('g;x=1/./y' 'http://a/b/c/g;x=1/y' )
		#('g;x=1/../y' 'http://a/b/c/y' )
		#('g?y/./x' 'http://a/b/c/g?y/./x' )
		#('g?y/../x' 'http://a/b/c/g?y/../x' )
		#('g#s/./x' 'http://a/b/c/g#s/./x' )
		#('g#s/../x' 'http://a/b/c/g#s/../x' )
	).
	1 to: testPairs size do: [:index |
		pair := testPairs at: index.
		relURIString := pair first.
		result := pair last.
		method := String streamContents: [:stream |
			stream nextPutAll: 'testResolveAbnormal' , index printString; cr.
			stream
				nextPutAll: '	| baseURI relURI resolvedURI |' ; cr;
				nextPutAll: '	baseURI := ''http://a/b/c/d;p?q'' asURI.' ; cr;
				nextPutAll: '	relURI := '; nextPut: $'; nextPutAll: relURIString; nextPutAll: '''.' ; cr;
				nextPutAll: '	resolvedURI := baseURI resolveRelativeURI: relURI.' ; cr;
				nextPutAll: '	self should: [resolvedURI asString = '''; nextPutAll: result; nextPutAll: '''].' ; cr].
		self compile: method classified: 'running resolving'].

]

{ #category : #'test generation' }
TestURI class >> generateNormalResolverTests [
	"TestURI generateNormalResolverTests"

	| relURIString result method testPairs pair |

	testPairs := #(
		#('g:h' 'g:h' )
		#('g' 'http://a/b/c/g' )
		#('./g' 'http://a/b/c/g' )
		#('g/' 'http://a/b/c/g/' )
		#('/g' 'http://a/g' )
		#('//g' 'http://g' )
		#('?y' 'http://a/b/c/?y' )
		#('g?y' 'http://a/b/c/g?y' )
		#('g#s' 'http://a/b/c/g#s' )
		#('g?y#s' 'http://a/b/c/g?y#s' )
		#(';x' 'http://a/b/c/;x' )
		#('g;x' 'http://a/b/c/g;x' )
		#('g;x?y#s' 'http://a/b/c/g;x?y#s' )
		#('.' 'http://a/b/c/' )
		#('./' 'http://a/b/c/' )
		#('..' 'http://a/b/' )
		#('../' 'http://a/b/' )
		#('../g' 'http://a/b/g' )
		#('../..' 'http://a/' )
		#('../../' 'http://a/' )
		#('../../g' 'http://a/g' )
	).
	1 to: testPairs size do: [:index |
		pair := testPairs at: index.
		relURIString := pair first.
		result := pair last.
		method := String streamContents: [:stream |
			stream nextPutAll: 'testResolveNormal' , index printString; cr.
			stream
				nextPutAll: '	| baseURI relURI resolvedURI |' ; cr;
				nextPutAll: '	baseURI := ''http://a/b/c/d;p?q'' asURI.' ; cr;
				nextPutAll: '	relURI := '; nextPut: $'; nextPutAll: relURIString; nextPutAll: '''.' ; cr;
				nextPutAll: '	resolvedURI := baseURI resolveRelativeURI: relURI.' ; cr;
				nextPutAll: '	self should: [resolvedURI asString = '''; nextPutAll: result; nextPutAll: '''].' ; cr].
		self compile: method classified: 'running resolving'].

]

{ #category : #'tests - file' }
TestURI >> testDefaultDirRoundtrip [
	| defaultDir defaultURI uriDir |
	defaultDir := FileDirectory default.
	defaultURI := defaultDir uri.
	uriDir := FileDirectory uri: defaultURI.
	self should: [defaultDir fullName = uriDir fullName]
]

{ #category : #'tests - file' }
TestURI >> testDirWithHash [
	"Tests proper escaping of directories with hash mark"

	| uriDir origPath origDir dirURI |
	origPath := FileDirectory default pathName, '#123'.
	origDir := FileDirectory on: origPath.
	self assert: origDir pathName = origPath.

	dirURI := origDir uri.
	uriDir := FileDirectory uri: dirURI.
	self assert: origDir fullName = uriDir fullName.
]

{ #category : #'tests - file' }
TestURI >> testDirectoryRoot [

	| rootDir uriRoot uriDir |
	rootDir := FileDirectory root.
	uriRoot := 'file:///' asURI.
	uriDir := FileDirectory uri: uriRoot.
	self should: [rootDir fullName = uriDir fullName]
]

{ #category : #'tests - resolving' }
TestURI >> testResolveAbnormal1 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := '../../../g'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/../g'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveAbnormal10 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := './g/.'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/g/'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveAbnormal11 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := 'g/./h'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/g/h'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveAbnormal12 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := 'g/../h'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/h'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveAbnormal13 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := 'g;x=1/./y'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/g;x=1/y'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveAbnormal14 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := 'g;x=1/../y'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/y'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveAbnormal15 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := 'g?y/./x'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/g?y/./x'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveAbnormal16 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := 'g?y/../x'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/g?y/../x'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveAbnormal17 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := 'g#s/./x'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/g#s/./x'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveAbnormal18 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := 'g#s/../x'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/g#s/../x'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveAbnormal2 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := '../../../../g'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/../../g'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveAbnormal3 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := '/./g'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/./g'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveAbnormal4 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := '/../g'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/../g'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveAbnormal5 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := 'g.'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/g.'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveAbnormal6 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := '.g'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/.g'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveAbnormal7 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := 'g..'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/g..'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveAbnormal8 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := '..g'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/..g'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveAbnormal9 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := './../g'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/g'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal1 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := 'g:h'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'g:h'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal10 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := 'g?y#s'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/g?y#s'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal11 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := ';x'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/;x'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal12 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := 'g;x'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/g;x'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal13 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := 'g;x?y#s'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/g;x?y#s'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal14 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := '.'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal15 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := './'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal16 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := '..'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal17 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := '../'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal18 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := '../g'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/g'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal19 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := '../..'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal2 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := 'g'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/g'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal20 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := '../../'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal21 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := '../../g'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/g'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal3 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := './g'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/g'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal4 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := 'g/'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/g/'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal5 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := '/g'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/g'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal6 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := '//g'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://g'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal7 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := '?y'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/?y'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal8 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := 'g?y'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/g?y'].

]

{ #category : #'tests - resolving' }
TestURI >> testResolveNormal9 [
	| baseURI relURI resolvedURI |
	baseURI := 'http://a/b/c/d;p?q' asURI.
	relURI := 'g#s'.
	resolvedURI := baseURI resolveRelativeURI: relURI.
	self should: [resolvedURI asString = 'http://a/b/c/g#s'].

]

{ #category : #'tests - parsing' }
TestURI >> testSchemeAbsoluteFail1 [
	self should: [URI fromString: 'http:'] raise: IllegalURIException
]

{ #category : #'tests - parsing' }
TestURI >> testSchemeAbsolutePass1 [
	| uri |
	uri := URI fromString: 'http://www.squeakland.org'.
	self should: [uri scheme = 'http'].
	self should: [uri isAbsolute].
	self shouldnt: [uri isOpaque].
	self shouldnt: [uri isRelative]
]

{ #category : #'tests - parsing' }
TestURI >> testSchemeAbsolutePass2 [
	| uri |
	uri := URI fromString: 'mailto:somebody@somewhere.nowhere'.
	self should: [uri scheme = 'mailto'].
	self should: [uri isAbsolute].
	self should: [uri isOpaque].
	self shouldnt: [uri isRelative]
]

{ #category : #'tests - parsing' }
TestURI >> testSchemeAbsolutePass3 [
	| uri |
	uri := URI fromString: 'ftp://ftp@squeak.org'.
	self should: [uri scheme = 'ftp'].
	self should: [uri isAbsolute].
	self shouldnt: [uri isOpaque].
	self shouldnt: [uri isRelative].
	self should: [uri userInfo = 'ftp'].
	self should: [uri host = 'squeak.org'].
	self should: [uri port isNil].

]

{ #category : #'tests - parsing' }
TestURI >> testSchemeAbsolutePass4 [
	| uri |
	uri := URI fromString: 'mailto:somebody@somewhere.nowhere#fragment'.
	self should: [uri scheme = 'mailto'].
	self should: [uri isAbsolute].
	self should: [uri isOpaque].
	self shouldnt: [uri isRelative].
	self should: [uri fragment = 'fragment'].

]

{ #category : #'tests - parsing' }
TestURI >> testSchemeAbsolutePass5 [
	| uri |
	uri := URI fromString: 'http://www.squeakland.org#fragment'.
	self should: [uri scheme = 'http'].
	self should: [uri isAbsolute].
	self shouldnt: [uri isOpaque].
	self shouldnt: [uri isRelative].
	self should: [uri fragment = 'fragment'].

]
