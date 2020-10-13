"
A ClassChangeRecorder keeps track of most substantive changes permissible in a project, isolated or not.

Structure:
inForce		a boolean
			Tells whether these changes are in effect.
			true for all changeSets in and above the current project.
			It should be sufficient only to record this for the changeSet
			as a whole, but this redundancy could help in error recovery.
classIsLocal	a boolean
			True if and only if this class is defined in this layer of the
			project structure.
changeTypes an identitySet
			Summarizes which changes have been made in this class.
			Values include #comment, #reorganize, #rename,
			and the four more summarized below.
thisName	a string
			Retains the class name for this layer.
priorName	a string
			Preserves the prior name.
thisComment	a text
			Retains the class comment for this layer.
priorComment	a text
			Preserves the prior comment.
thisOrganization	a classOrganizer
			Retains the class organization for this layer.
priorOrganization	a classOrganizer
			Preserves the prior organization.
thisMD	a methodDictionary
			Used to prepare changes for nearly atomic invocation
			of this layer (see below).
priorMD	a methodDictionary
			Preserves the state of an altered class as it exists in the next
			outer layer of the project structure.
methodChanges		a dictionary of classChangeRecords
			Retains all the method changes for this layer.

Four of the possible changeTypes are maintained in a mutually exclusive set, analogously to MethodChangeRecords.  Here is a simple summary of the relationship between these four changeType symbols and the recording of prior state
			|	prior == nil			|	prior not nil	
	---------	|----------------------------	|--------------------
	add		|	add					|	change
	---------	|----------------------------	|--------------------
	remove	|	addedThenRemoved	|	remove

A classChangeRecorder is notified of changes by the method
		noteMethodChange: <ClassChangeRecord>.
ClassChangeRecorders are designed to invoke a set of changes relative to the definition of a class in an prior layer.  It is important that both invocation and revocation of these changes take place in a nearly atomic fashion so that interdependent changes will be adopted as a whole, and so that only one flush of the method cache should be necessary.  A further reason for revocation to be simple is that it may be requested as an attempt to recover from an error in a project that is failing.
"
Class {
	#name : #ClassChangeRecord,
	#superclass : #Object,
	#instVars : [
		'inForce',
		'revertable',
		'changeTypes',
		'thisDefinition',
		'priorDefinition',
		'thisName',
		'priorName',
		'thisOrganization',
		'priorOrganization',
		'thisComment',
		'priorComment',
		'thisMD',
		'priorMD',
		'methodChanges'
	],
	#category : #'System-Changes'
}

{ #category : #'all changes' }
ClassChangeRecord >> allChangeTypes [

	| chgs |
	(priorName ~~ nil and: [changeTypes includes: #rename]) ifTrue:
		[(chgs := changeTypes copy) add: 'oldName: ' , priorName.
		^ chgs].
	^ changeTypes
]

{ #category : #'all changes' }
ClassChangeRecord >> assimilateAllChangesIn: otherRecord [

	otherRecord isClassRemoval ifTrue: [^ self noteChangeType: #remove].

	otherRecord allChangeTypes do:
		[:chg | self noteChangeType: chg fromClass: self realClass].

	otherRecord methodChanges associationsDo:
		[:assn | | selector changeRecord changeType |
		selector := assn key. changeRecord := assn value.
		changeType := changeRecord changeType.
		(changeType == #remove or: [changeType == #addedThenRemoved])
			ifTrue:
				[changeType == #addedThenRemoved
					ifTrue: [self atSelector: selector put: #add].
				self noteRemoveSelector: selector priorMethod: nil
						lastMethodInfo: changeRecord methodInfoFromRemoval]
			ifFalse: 
				[self atSelector: selector put: changeType]].

]

{ #category : #'method changes' }
ClassChangeRecord >> atSelector: selector ifAbsent: absentBlock [

	^ (methodChanges at: selector ifAbsent: absentBlock)
		changeType
]

{ #category : #'method changes' }
ClassChangeRecord >> atSelector: selector put: changeType [

	(self findOrMakeMethodChangeAt: selector priorMethod: nil)
		noteChangeType: changeType
]

{ #category : #'method changes' }
ClassChangeRecord >> changedSelectors [
	"Return a set of the changed or removed selectors."

	^ methodChanges keys
]

{ #category : #definition }
ClassChangeRecord >> checkCoherence [
	"If I recreate the class then don't remove it"

	(changeTypes includes: #remove) ifTrue:
		[changeTypes remove: #remove.
		changeTypes add: #change].
	(changeTypes includes: #addedThenRemoved) ifTrue:
		[changeTypes remove: #addedThenRemoved.
		changeTypes add: #add].

]

{ #category : #'method changes' }
ClassChangeRecord >> compileAll: newClass from: oldClass [
	"Something about this class has changed.  Locally retained methods must be recompiled.
	NOTE:  You might think that if this changeSet is in force, then we can just note
	the new methods but a lower change set may override and be in force which
	would mean that only the overriding copies go recompiled.  Just do it."

	methodChanges associationsDo:
		[:assn | | sel changeType changeRecord newMethod |
		sel := assn key.
		changeRecord := assn value.
		changeType := changeRecord changeType.
		(changeType == #add or: [changeType == #change]) ifTrue:
			[newMethod := newClass
				recompileNonResidentMethod: changeRecord currentMethod
				atSelector: sel from: oldClass.
			changeRecord noteNewMethod: newMethod]]
]

{ #category : #'method changes' }
ClassChangeRecord >> findOrMakeMethodChangeAt: selector priorMethod: priorMethod [ 
	^methodChanges at: selector
		ifAbsentPut: [MethodChangeRecord new priorMethod: priorMethod]
]

{ #category : #removal }
ClassChangeRecord >> forgetChangesIn: otherRecord [
	"See forgetAllChangesFoundIn:.  Used in culling changeSets."

	| cls otherMethodChanges |
	(cls := self realClass) == nil ifTrue: [^ self].  "We can do better now, though..."
	otherMethodChanges := otherRecord methodChangeTypes.
	otherMethodChanges associationsDo:
		[:assoc | | selector actionToSubtract |
		selector := assoc key. actionToSubtract := assoc value.
		(cls includesSelector: selector)
			ifTrue: [(#(add change) includes: actionToSubtract)
					ifTrue: [methodChanges removeKey: selector ifAbsent: []]]
			ifFalse: [(#(remove addedThenRemoved) includes: actionToSubtract)
					ifTrue: [methodChanges removeKey: selector ifAbsent: []]]].
	changeTypes isEmpty ifFalse:
		[changeTypes removeAllFoundIn: otherRecord allChangeTypes.
		(changeTypes includes: #rename) ifFalse:
			[changeTypes removeAllSuchThat: [:x | x beginsWith: 'oldName: ']]]
]

{ #category : #removal }
ClassChangeRecord >> forgetClassRemoval [

	self halt.
]

{ #category : #'all changes' }
ClassChangeRecord >> hasNoChanges [

	^ changeTypes isEmpty and: [methodChanges isEmpty]
]

{ #category : #'all changes' }
ClassChangeRecord >> includesChangeType: changeType [

	changeType == #new ifTrue: [^ changeTypes includes: #add].  "Backwd compat"
	^ changeTypes includes: changeType
]

{ #category : #'method changes' }
ClassChangeRecord >> infoFromRemoval: selector [

	^ (methodChanges at: selector ifAbsent: [^ nil])
		methodInfoFromRemoval


]

{ #category : #initialization }
ClassChangeRecord >> initFor: className revertable: isRevertable [

	inForce := isRevertable.
	changeTypes := IdentitySet new.
	methodChanges := IdentityDictionary new.
	priorName := thisName := className.
	revertable := isRevertable and: [self realClass notNil].
	revertable ifTrue:
		[priorMD := self realClass methodDict copy.
		priorOrganization := self realClass organization deepCopy].

]

{ #category : #'isolation layers' }
ClassChangeRecord >> invokePhase1 [

	| elements |
	revertable ifFalse: [^ self].
	inForce ifTrue: [self error: 'Can invoke only when not in force.'].

	"Do the first part of the invoke operation -- no particular hurry."
	"Save the outer method dictionary for quick revert of method changes."
	priorMD := self realClass methodDict.

	"Prepare a methodDictionary for switcheroo."
	thisMD := self realClass methodDict copy.
	methodChanges associationsDo:
		[:assn | | selector changeRecord type |
		selector := assn key.
		changeRecord := assn value.
		type := changeRecord changeType.
		type = #remove ifTrue: [thisMD removeKey: selector].
		type = #add ifTrue: [thisMD at: selector put: changeRecord currentMethod].
		type = #change ifTrue: [thisMD at: selector put: changeRecord currentMethod].
		].

	"Replace the original organization (and comment)."
	priorOrganization := self realClass organization.
	thisOrganization elementArray copy do:
		[:sel | (thisMD includesKey: sel) ifFalse: [thisOrganization removeElement: sel]].
	#(DoIt DoItIn:) do: [:sel | thisMD removeKey: sel ifAbsent: []].
	thisOrganization elementArray size = thisMD size ifFalse:
		[elements := thisOrganization elementArray asSet.
		thisMD keysDo:
			[:sel | (elements includes: sel) ifFalse:
				[thisOrganization classify: sel
					under: (priorOrganization categoryOfElement: sel)]]].
	self realClass organization: thisOrganization.



]

{ #category : #'isolation layers' }
ClassChangeRecord >> invokePhase2 [

	revertable ifFalse: [^ self].

	"Do the second part of the revert operation.  This must be very simple."
	"Replace original method dicts if there are method changes."
	self realClass methodDictionary: thisMD.  "zap.  Must flush Cache in outer loop."
	inForce := true.

]

{ #category : #removal }
ClassChangeRecord >> isClassRemoval [
	"NOTE: there are other removals with changeType #addedThenRemoved,
	but this message is used to write out removals in fileOut, and those
	cases should not be written out."

	^ (changeTypes includes: #remove) or: [changeTypes includes: #removeClass]
]

{ #category : #'method changes' }
ClassChangeRecord >> methodChangeTypes [
	"Return an old-style dictionary of method change types."

	| dict |
	dict := IdentityDictionary new.
	methodChanges associationsDo:
		[:assn | | selector record |
		selector := assn key.
		record := assn value.
		dict at: selector put: record changeType].
	^ dict
]

{ #category : #'method changes' }
ClassChangeRecord >> methodChanges [

	^ methodChanges
]

{ #category : #'all changes' }
ClassChangeRecord >> noteChangeType: changeSymbol [

	^ self noteChangeType: changeSymbol fromClass: nil
]

{ #category : #'all changes' }
ClassChangeRecord >> noteChangeType: changeSymbol fromClass: class [

	(changeSymbol = #new or: [changeSymbol = #add]) ifTrue:
		[changeTypes add: #add.
		changeTypes remove: #change ifAbsent: [].
		revertable := false.
		^ self].
	changeSymbol = #change ifTrue:
		[(changeTypes includes: #add) ifTrue: [^ self].
		^ changeTypes add: changeSymbol].
	changeSymbol == #addedThenRemoved ifTrue:
		[^ self].  "An entire class was added but then removed"
	changeSymbol = #comment ifTrue:
		[^ changeTypes add: changeSymbol].
	changeSymbol = #reorganize ifTrue:
		[^ changeTypes add: changeSymbol].
	changeSymbol = #rename ifTrue:
		[^ changeTypes add: changeSymbol].
	(changeSymbol beginsWith: 'oldName: ') ifTrue:
		["Must only be used when assimilating other changeSets"
		(changeTypes includes: #add) ifTrue: [^ self].
		priorName := changeSymbol copyFrom: 'oldName: ' size + 1 to: changeSymbol size.
		^ changeTypes add: #rename].
	changeSymbol = #remove ifTrue:
		[(changeTypes includes: #add)
			ifTrue: [changeTypes add: #addedThenRemoved]
			ifFalse: [changeTypes add: #remove].
		^ changeTypes removeAllFoundIn: #(add change comment reorganize)].

	self error: 'Unrecognized changeType'
]

{ #category : #'method changes' }
ClassChangeRecord >> noteNewMethod: newMethod selector: selector priorMethod: methodOrNil [

	| methodChange |
	methodChange := self findOrMakeMethodChangeAt: selector priorMethod: methodOrNil.
	methodOrNil == nil
		ifTrue: [methodChange noteChangeType: #add]
		ifFalse: [methodChange noteChangeType: #change].
	methodChange noteNewMethod: newMethod.

]

{ #category : #rename }
ClassChangeRecord >> noteNewName: newName [

	thisName := newName
]

{ #category : #definition }
ClassChangeRecord >> notePriorDefinition: oldClass [

	oldClass ifNil: [^ self].
	priorDefinition ifNil: [priorDefinition := oldClass definition]
]

{ #category : #'method changes' }
ClassChangeRecord >> noteRemoveSelector: selector priorMethod: priorMethod lastMethodInfo: infoOrNil [

	| methodChange |
	methodChange := self findOrMakeMethodChangeAt: selector priorMethod: priorMethod.
	methodChange changeType == #add
		ifTrue: [methodChange noteChangeType: #addedThenRemoved]
		ifFalse: [methodChange noteChangeType: #remove].

	infoOrNil ifNotNil:
		["Save the source code pointer and category so can still browse old versions"
		methodChange noteMethodInfoFromRemoval: infoOrNil]


]

{ #category : #definition }
ClassChangeRecord >> priorDefinition [

	^ priorDefinition
]

{ #category : #rename }
ClassChangeRecord >> priorName [

	^ priorName
]

{ #category : #'isolation layers' }
ClassChangeRecord >> realClass [
	^ self realClass: Smalltalk globals.
]

{ #category : #'isolation layers' }
ClassChangeRecord >> realClass: anEnvironment [
	"Return the actual class (or meta), as determined from my name."
	thisName ifNil: [^ nil].
	(thisName endsWith: ' class')
		ifTrue: [^ (anEnvironment at: (thisName copyFrom: 1 to: thisName size - 6) asSymbol
						ifAbsent: [nil]) class]
		ifFalse: [^ anEnvironment at: thisName ifAbsent: [nil]]
]

{ #category : #'method changes' }
ClassChangeRecord >> removeSelector: selector [
	"Remove all memory of changes associated with the argument, selector, in this class."

	selector == #Comment
		ifTrue:
			[changeTypes remove: #comment ifAbsent: []]
		ifFalse:
			[methodChanges removeKey: selector ifAbsent: []]
]

{ #category : #'isolation layers' }
ClassChangeRecord >> revokePhase1 [

	revertable ifFalse: [^ self].
	inForce ifFalse: [self error: 'Can revoke only when in force.'].

	"Do the first part of the revoke operation.  This must be very simple."
	"Replace original method dict if there are method changes."
	self realClass methodDictionary: priorMD  "zap.  Must flush Cache in outer loop."
]

{ #category : #'isolation layers' }
ClassChangeRecord >> revokePhase2 [

	revertable ifFalse: [^ self].

	"Replace the original organization (and comment)."
	thisOrganization := self realClass organization.
	self realClass organization: priorOrganization.
	inForce := false.

]

{ #category : #rename }
ClassChangeRecord >> thisName [

	^ thisName
]

{ #category : #'all changes' }
ClassChangeRecord >> trimHistory [
	"Drop non-essential history."
	| realClass |
	realClass := self realClass.

	"Forget methods added and later removed"
	methodChanges keysAndValuesRemove:
		[:sel :chgRecord |
		chgRecord changeType == #addedThenRemoved
		"this removes methods that have been lost, e.g. by being deleted in a different change set, etc"
		or: [(chgRecord changeType == #add or: [chgRecord changeType == #change])
			and: [realClass isNil or: [(realClass includesSelector: sel) not]]]].

	"Forget renaming and reorganization of newly-added classes."
	(changeTypes includes: #add) ifTrue:
		[changeTypes removeAllFoundIn: #(rename reorganize)]
]

{ #category : #initialization }
ClassChangeRecord >> zapHistory [
	"Drop all recorded information not needed to simply keep track of what has been changed.
	Saves a lot of space."

	methodChanges do: [:r | r noteNewMethod: nil].  "Drop all refes to old methods"
	thisOrganization := nil.
	priorOrganization := nil.
	thisComment := nil.
	priorComment := nil.
	thisMD := nil.
	priorMD := nil.
]
