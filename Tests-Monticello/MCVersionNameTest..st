Class {
	#name : #MCVersionNameTest,
	#superclass : #MCTestCase,
	#category : #'Tests-Monticello'
}

{ #category : #accessing }
MCVersionNameTest >> allValidFixtures [
	^ self standardFixtures , (self diffyFixtures pairsCollect: [:diffy :base | diffy])
]

{ #category : #accessing }
MCVersionNameTest >> diffyBranchFixtures [
	^ #( 'Package.branch-author.123(origAuthor.122)' 'Package.branch-origAuthor.122'
		 'Package.branch-author.123(origAuthor.122).mcd' 'Package.branch-origAuthor.122.mcd'
		 'Package.branch-author.123(122)' 'Package.branch-author.122'
		 'Package.branch-author.123(@origPackage-origAuthor.122)' 'origPackage-origAuthor.122'
		 'Package-author.123(@origPackage.branch-origAuthor.122)' 'origPackage.branch-origAuthor.122'
	 ) collect:
		[ : each | each asMCVersionName ]
]

{ #category : #accessing }
MCVersionNameTest >> diffyFixtures [
	^ #( 'Package-author.123(origAuthor.122)' 'Package-origAuthor.122'
		 'Package-author.123(origAuthor.122).mcd' 'Package-origAuthor.122.mcd'
		 'Package-author.123(122)' 'Package-author.122'
		 'Package-author.123(@origPackage-origAuthor.122)' 'origPackage-origAuthor.122'
	 ) collect:
		[ : each | each asMCVersionName ]
]

{ #category : #accessing }
MCVersionNameTest >> invalidFixtures [
	^ {String empty. 'abc'. '123' } collect: [ : each | each asMCVersionName ]
]

{ #category : #accessing }
MCVersionNameTest >> standardFixtures [
	^ #('Package-author.123' 'Package-author.123.mcz' ) collect:
		[ : each | each asMCVersionName ]
]

{ #category : #tests }
MCVersionNameTest >> testAttributeAccess [
	self allValidFixtures do: [ : each | self verifyPackageAuthorVersion: each ]
]

{ #category : #tests }
MCVersionNameTest >> testBranches [
	| noBranch otherBranch withBranch |
	noBranch :=  'Package-author.123.mcz' asMCVersionName.
	withBranch := 'Package.branch-author.123.mcz' asMCVersionName.
	otherBranch := 'Package.other-author.123.mcz' asMCVersionName.
	self
		assert: 'Package' equals: noBranch packageName;
		assert: 'Package'  equals: withBranch packageName;
		assert: 'Package-author.123' equals: noBranch versionName;
		assert: 'Package.branch-author.123'  equals: withBranch versionName;
		assert: 'Package' equals: noBranch packageAndBranchName;
		assert: 'Package.branch' equals: withBranch packageAndBranchName;
		deny: noBranch = withBranch;
		deny: withBranch = noBranch;
		deny: withBranch = otherBranch.


]

{ #category : #tests }
MCVersionNameTest >> testDiffyNames [
	self diffyFixtures, self diffyBranchFixtures pairsDo: [ :diffy :base |
		self verifyDiffy: diffy base: base ]
]

{ #category : #tests }
MCVersionNameTest >> testEquality [
	| standard mc |
	standard := 'Package-author.123.mcz'.
	mc := standard asMCVersionName.
	self
		 assert: standard = mc ;
		 assert: mc = standard.
	self assert: self allValidFixtures asSet size = 1
]

{ #category : #tests }
MCVersionNameTest >> testInvalid [
	self assert: (self invalidFixtures noneSatisfy: [ : each | each isValid ])
]

{ #category : #tests }
MCVersionNameTest >> testSpecies [

	self
		assert: ByteString equals: 'Package-author.123.mcz' asMCVersionName versionName class;
		assert: ByteString equals: 'Package-author.123' asMCVersionName versionName class
]

{ #category : #tests }
MCVersionNameTest >> testVersionNameReturnsAByteString [

	#(
		'Package-author.123.mcz'
		'Package-author.123'
		'Package-author.123(122).mcd'
		'Package-author.123(author2.122).mcd') do: [ :each |
			self assert: ByteString equals: each asMCVersionName versionName class ]
]

{ #category : #tests }
MCVersionNameTest >> verifyDiffy: diffyMCVersionName base: expectedBaseMCVersionName [ 
	self
		 assert: diffyMCVersionName baseVersionName = expectedBaseMCVersionName
]

{ #category : #tests }
MCVersionNameTest >> verifyPackageAuthorVersion: aMCFileName [ 
	self
		 assert: aMCFileName versionName = 'Package-author.123';
		 assert: aMCFileName packageName = 'Package' ;
		 assert: aMCFileName versionNumber = 123 ;
		 assert: aMCFileName author = 'author' ;
		 assert: aMCFileName isValid
]
