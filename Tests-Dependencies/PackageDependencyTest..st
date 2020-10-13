"
PackageDependencyTest helps to avoid the introduction of unwanted package dependencies. There is a test for each package in the trunk image that asserts the current dependencies.

If new dependencies are introduced or existing dependencies are removed deliberately for a package, the test for that package needs to be changed in order not to fail.

As the current dependency structure is suboptimal some of the asserted dependencies are unwanted in fact. Kernel should probably not depend on MorphicExtras. In a way a green PackageDependencyTest does not mean the dependencies are good, just that they have not become worse.
"
Class {
	#name : #PackageDependencyTest,
	#superclass : #TestCase,
	#category : #'Tests-Dependencies'
}

{ #category : #failures }
PackageDependencyTest >> expectedFailures [

	^ #(testEtoys testSystem testTools)
]

{ #category : #tests }
PackageDependencyTest >> testBalloon [
	self testPackage: 'Balloon' dependsExactlyOn: #(
		Collections
		Graphics
		Kernel
	)
]

{ #category : #tests }
PackageDependencyTest >> testChronologyCore [
	self testPackage: #'Chronology-Core' dependsExactlyOn: #(
		Collections
		Kernel
	)
]

{ #category : #tests }
PackageDependencyTest >> testCollections [
	self testPackage: #Collections dependsExactlyOn: #(
		#'Chronology-Core'
		Compiler
		Kernel
		Files
		Graphics
		Multilingual
		#'ToolBuilder-Kernel'
	).
]

{ #category : #tests }
PackageDependencyTest >> testCompiler [
	self testPackage: #Compiler dependsExactlyOn: #(
		Collections
		Graphics
		Kernel
		System
		#'ToolBuilder-Kernel'
	).
]

{ #category : #tests }
PackageDependencyTest >> testCompression [
	self testPackage: #Compression dependsExactlyOn: #(
		#'Chronology-Core'
		Collections
		Files
		Graphics
		Kernel
		Multilingual
		System
		#'ToolBuilder-Kernel'
	).
]

{ #category : #tests }
PackageDependencyTest >> testEtoys [
	"Etoys clean-up is to be done for the after 5.2 release --pre"

	self testPackage: #EToys dependsExactlyOn: #(
		Balloon
		#'Chronology-Core'
		Collections
		Compiler
		Compression
		Files
		Graphics
		Kernel
		Morphic
		MorphicExtras
		Multilingual
		Network
		Protocols
		SUnit
		System
		#'ToolBuilder-Kernel'
		Tools
	).
]

{ #category : #tests }
PackageDependencyTest >> testFiles [
	self testPackage: #Files dependsExactlyOn: #(
		#'Chronology-Core'
		Collections
		Kernel
		Multilingual
		System
	).
]

{ #category : #tests }
PackageDependencyTest >> testGraphics [
	self testPackage: #Graphics dependsExactlyOn: #(
		#'Chronology-Core'
		Collections
		Compression
		Files
		Kernel
		Multilingual
		System
		#'ToolBuilder-Kernel'
	).
]

{ #category : #tests }
PackageDependencyTest >> testInstaller [
	self testPackage: #Installer dependsExactlyOn: #(
		Collections
		Compression
		Exceptions
		Files
		Kernel
		Monticello
		MonticelloConfigurations
		Multilingual
		Network
		System
		#'ToolBuilder-Kernel'
		Tools
	).
]

{ #category : #tests }
PackageDependencyTest >> testKernel [
	self testPackage: #Kernel dependsExactlyOn: #(
		#'Chronology-Core'
		Collections
		Compiler
		Environments
		Files
		Multilingual
		System
		#'ToolBuilder-Kernel'
	).
]

{ #category : #tests }
PackageDependencyTest >> testMonticello [
	self testPackage: #Monticello dependsExactlyOn: #(
		#'Chronology-Core'
		Collections
		Compiler
		Compression
		Environments
		Files
		Graphics
		Kernel
		Morphic
		Multilingual
		Network
		#'PackageInfo-Base'
		#'Services-Base'
		System
		#'ToolBuilder-Kernel'
		Tools
		#'WebClient-Core'
	).
]

{ #category : #tests }
PackageDependencyTest >> testMorphic [
	self testPackage: #Morphic dependsExactlyOn: #(
		Balloon
		#'Chronology-Core'
		Collections
		Compiler
		Compression
		EToys
		Files
		Graphics
		'Installer-Core' "Because of TheWorldMainDockingBar's install feature ..."
		Kernel
		MonticelloConfigurations
		MorphicExtras
		Multilingual
		Network
		Sound
		System
		SystemReporter
		#'ToolBuilder-Kernel'
		#'ToolBuilder-Morphic'
		Tools
		TrueType
	).
]

{ #category : #tests }
PackageDependencyTest >> testMorphicExtras [
	self testPackage: #MorphicExtras dependsExactlyOn: #(
		Balloon
		#'Chronology-Core'
		Collections
		Compiler
		Files
		Graphics
		Kernel
		MonticelloConfigurations
		Morphic
		Multilingual
		Network
		Protocols
		Sound
		System
		#'ToolBuilder-Kernel'
		#'ToolBuilder-Morphic'
		Tools
	).
]

{ #category : #tests }
PackageDependencyTest >> testMultilingual [
	self testPackage: #Multilingual dependsExactlyOn: #(
		#'Chronology-Core'
		Collections
		Files
		Graphics
		Kernel
		System
		#'ToolBuilder-Kernel'
	).
]

{ #category : #tests }
PackageDependencyTest >> testNetwork [
	self testPackage: #Network dependsExactlyOn: #(
		#'Chronology-Core'
		Collections
		Compression
		Files
		Graphics
		Kernel
		Morphic
		Multilingual
		#'SqueakSSL-Core'
		System
		#'ToolBuilder-Kernel'
		#'WebClient-Core'
	).
]

{ #category : #utilities }
PackageDependencyTest >> testPackage: pkgName dependsExactlyOn: pkgList [
	"Ensure that the package with the given name depends only on the packages in pkgList.
	NOTE: If you use this for fixing dependencies, classDeps includes the classes
	and users from the package(s) not declared as dependents. Basically, you need
	to fix all the references in classDeps to make the test pass."
	| classDeps pi pkgDeps |
	classDeps := IdentityDictionary new.
	pi := PackageOrganizer default packageNamed: pkgName ifAbsent:[^self]. "unloaded"
	pi classes do:[:pkgClass| 
		(classDeps at: (pkgClass superclass ifNil:[ProtoObject]) 
			ifAbsentPut:[OrderedCollection new]) add: pkgClass name, ' superclass'.
	].
	pi methods do:[:mref| | cm |
		cm := mref compiledMethod.
		1 to: cm numLiterals do:[:i| | lit |
			((lit := cm literalAt: i) isVariableBinding 
				and:[lit value isBehavior]) ifTrue:[(classDeps at: lit value ifAbsentPut:[OrderedCollection new]) add: cm methodClass asString, '>>', cm selector]]].
	pkgDeps := Dictionary new.
	classDeps keys do:[:aClass| | pkg |
		pkg := PackageOrganizer default packageOfClass: aClass ifNone:[nil].
		pkg ifNil:[
			Transcript cr; show: 'WARNING: No package for ', aClass.
			(classDeps removeKey: aClass) do:[:each| Transcript crtab; show: each].
		] ifNotNil:[
			(pkgDeps at: pkg name ifAbsentPut:[OrderedCollection new]) add: aClass.
		].
	].
	(pkgDeps removeKey: pkgName ifAbsent:[#()]) 
		do:[:aClass| classDeps removeKey: aClass ifAbsent:[]].
	pkgList do:[:pkg|
		self assert: (pkgDeps includesKey: pkg)
			description: pkgName, ' no longer depends on ', pkg.
		(pkgDeps removeKey: pkg ifAbsent: [#()]) 
			do:[:aClass| classDeps removeKey: aClass ifAbsent:[]].
	].
	classDeps keysAndValuesDo:[:class :deps|
		Transcript cr; show: class name, ' dependencies:'.
		deps do:[:each| Transcript crtab; show: each].
	].
	self assert: pkgDeps isEmpty
		description: pkgName, ' now depends on ', pkgDeps.

]

{ #category : #tests }
PackageDependencyTest >> testPackageInfo [
	self testPackage: #PackageInfo dependsExactlyOn: #(
		Collections
		Compiler
		Graphics
		Kernel
		Morphic
		System
		#'ToolBuilder-Kernel'
	).
]

{ #category : #tests }
PackageDependencyTest >> testPreferenceBrowser [
	self testPackage: #PreferenceBrowser dependsExactlyOn: #(
		#'Chronology-Core'
		Collections
		Graphics
		Kernel
		Morphic
		MorphicExtras
		System
		Tools
		#'ToolBuilder-Morphic' "Work in progress. Should become ToolBuilder --pre"
		
		'Installer-Core' "Because preference wizard can install extra packages."
		MonticelloConfigurations "Because preference wizard needs to start update silently."
	).
]

{ #category : #tests }
PackageDependencyTest >> testProtocols [
	self testPackage: #Protocols dependsExactlyOn: #(
		#'Chronology-Core'
		Collections
		Graphics
		Kernel
		Morphic
		System
		#'ToolBuilder-Kernel'
		Tools
	).
]

{ #category : #tests }
PackageDependencyTest >> testSUnit [
	self testPackage: #SUnit dependsExactlyOn: #(
		#'Chronology-Core'
		Collections
		Kernel
		System
	).
]

{ #category : #tests }
PackageDependencyTest >> testSUnitGUI [
	self testPackage: #SUnitGUI dependsExactlyOn: #(
		#'Chronology-Core'
		Collections
		Environments
		Graphics
		Kernel
		#'PackageInfo-Base'
		SUnit
		System
		#'ToolBuilder-Kernel'
		Tools
	).
]

{ #category : #tests }
PackageDependencyTest >> testServices [
	self testPackage: #'Services-Base' dependsExactlyOn: #(
		Collections
		Compiler
		Graphics
		Kernel
		Morphic
		#'PackageInfo-Base'
		PreferenceBrowser
		System
		#'ToolBuilder-Kernel'
		Tools
	).
]

{ #category : #tests }
PackageDependencyTest >> testShoutCore [
	self testPackage: #ShoutCore dependsExactlyOn: #(
		Collections
		Environments
		Graphics
		Kernel
		Monticello
		System
		Compiler
		Tools
		Files
	).
]

{ #category : #tests }
PackageDependencyTest >> testSound [
	self testPackage: #Sound dependsExactlyOn: #(
		#'Chronology-Core'
		Collections
		Compiler
		Balloon
		Files
		Graphics
		Kernel
		Network
		System
		#'ToolBuilder-Kernel'
	).
]

{ #category : #tests }
PackageDependencyTest >> testSystem [
	"Etoys clean-up is to be done for the after 5.2 release --pre"

	self testPackage: #System dependsExactlyOn: #(
		#'Chronology-Core'
		Collections
		Compiler
		Compression
		Environments
		Files
		Graphics
		#'Installer-Core'
		Kernel
		MonticelloConfigurations
		Morphic
		MorphicExtras
		Multilingual
		Network
		#'PackageInfo-Base'
		Sound
		#'ToolBuilder-Kernel'
		TrueType
	).
]

{ #category : #tests }
PackageDependencyTest >> testToolBuilder [
	self testPackage: #'ToolBuilder-Kernel' dependsExactlyOn: #(
		Collections
		Files
		Kernel
		System
	).
]

{ #category : #tests }
PackageDependencyTest >> testTools [
	"Tools currently directly depend on the new file handling dialogs. To be 
	refactored in after 5.2 release --pre"

	self testPackage: #Tools dependsExactlyOn: #(
		#'Chronology-Core'
		Collections
		Compiler
		Compression
		Environments
		Files
		Graphics
		Kernel
		Morphic
		MorphicExtras
		Multilingual
		Network
		#'PackageInfo-Base'
		System
		#'ToolBuilder-Kernel'
	).
]

{ #category : #tests }
PackageDependencyTest >> testTraits [
	self testPackage: #Traits dependsExactlyOn: #(
		Collections
		Compiler
		Files
		Kernel
		Monticello
		System
	).
]

{ #category : #tests }
PackageDependencyTest >> testTrueType [
	self testPackage: #TrueType dependsExactlyOn: #(
		Collections
		Balloon
		Files
		Graphics
		Kernel
		Multilingual
		System
		#'ToolBuilder-Kernel'
	).
]

{ #category : #tests }
PackageDependencyTest >> testVersionNumber [
	self testPackage: #VersionNumber dependsExactlyOn: #(
		Collections
		Kernel
	).
]

{ #category : #tests }
PackageDependencyTest >> testXML [
	self testPackage: #XML dependsExactlyOn: #(
		Collections
		Exceptions
		Files
		Kernel
		Multilingual
		System
		Tests
	).
]
