Class {
	#name : #EnvironmentTest,
	#superclass : #TestCase,
	#instVars : [
		'env',
		'value'
	],
	#category : #'Tests-Environments'
}

{ #category : #asserting }
EnvironmentTest >> assertExports: aSymbol value: v2 [
	| other |
	other := Environment withName: #other.
	other import: env.
	self assert: (other bindingOf: aSymbol) value = v2
]

{ #category : #support }
EnvironmentTest >> createClass: aSymbol [
	| builder |
	builder := ClassBuilder new.
	^ builder
		name: aSymbol
		inEnvironment: env
		subclassOf: Object
		type: #normal
		instanceVariableNames: ''
		classVariableNames: ''
		poolDictionaries: ''
		category: 'Test'.
	
]

{ #category : #asserting }
EnvironmentTest >> denyExports: aSymbol [
	| other |
	other := Environment withName: #other.
	other import: env.
	self assert: (other bindingOf: aSymbol) isNil
]

{ #category : #running }
EnvironmentTest >> setUp [
	env := Environment withName: 'test'.
	value := Object new.
]

{ #category : #support }
EnvironmentTest >> storeValueMethod [
	"Assign an object to the global,
	capture the value of the assignment 
	expression, and answer both
	the object and the result."


	^ 'doStore
	| expr result | 
	expr := Object new.  
	result := Plonk := expr. 
	^ { expr. result }
'
]

{ #category : #running }
EnvironmentTest >> tearDown [
	env destroy.
	env := nil
]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testAssociationsDo [
	"For compatibility with legacy code, environments 
	should implement the dictionary protocol."

	env at: #Griffle put: value.
	env at: #Plonk put: value.
	env at: #Nurp put: value.
	env associationsDo: [:assoc |
		(#(Smalltalk Undeclared) includes: assoc key)
			ifFalse: ["We're not interested in these default bindings"
				self assert: (#(Griffle Plonk Nurp) includes: assoc key).
				self assert: value equals: assoc value]].

]

{ #category : #'tests - binding' }
EnvironmentTest >> testAtDoesntFindUndeclared [
	"It seems reasonable for #bindingOf: to answer either an
	existing binding, or create an undeclared binding and
	answer that. Reasonable, but wrong. The tools expect to 
	receive nil if no binding exists, and explicitly create
	an undeclared binding if that's desirable."
	
	env := Environment withName: #Test.
	env bindingOf: #Griffle.
	self should: [ env at: #Griffle ] raise: KeyNotFound
]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testAtIfAbsent [
	"For compatibility with legacy code, environments 
	should implement the dictionary protocol."

	| result |
	result := env at: #Griffle ifAbsent: [value].
	self assert: result == value
]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testAtIfAbsentNot [
	"For compatibility with legacy code, environments 
	should implement the dictionary protocol."

	| result |
	env at: #Griffle put: value.
	result := env at: #Griffle ifAbsent: [self assert: false].
	self assert: result == value
]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testAtIfPresent [
	"For compatibility with legacy code, environments 
	should implement the dictionary protocol."

	| result |
	env at: #Griffle put: value.
	env at: #Griffle ifPresent: [:v | result := v].
	self assert: result == value
]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testAtIfPresentIfAbsentAbsent [
	"For compatibility with legacy code, environments 
	should implement the dictionary protocol."

	| answer result |
	result := Object new.
	answer := env 
		at: #Griffle 
		ifPresent: [:v | self fail: 'should not reach here'] 
		ifAbsent: [result].
		
	self
		assert: result 
		identical: answer
		description: 'Method answers the result of the absent block'
]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testAtIfPresentIfAbsentPresent [
	"For compatibility with legacy code, environments 
	should implement the dictionary protocol."

	| answer argument result |
	result := Object new.
	env at: #Griffle put: value.
	answer := env 
		at: #Griffle 
		ifPresent: [:v | argument := v. result] 
		ifAbsent: [#absent].
		
	self 
		assert: value 
		identical: argument 
		description: 'Value is passed to the ifPresent block'.
	self
		assert: result 
		identical: answer
		description: 'Method answers the result of the block'
]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testAtIfPresentNot [
	"For compatibility with legacy code, environments 
	should implement the dictionary protocol."
	
	env 
		at: #Griffle 
		ifPresent: [self fail: 'should not reach here'].
]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testAtPutDeclared [
	"For compatibility with legacy code, environments 
	should implement the dictionary protocol."

	| binding |
	env bind: #Griffle to: Object new.
	binding := env associationAt: #Griffle.
	env at: #Griffle put: value.
	self assert: binding value == value
]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testAtPutUndeclared [
	"For compatibility with legacy code, environments 
	should implement the dictionary protocol."

	| binding |
	binding := env undeclare: #Griffle.
	env at: #Griffle put: value.
	self assert: binding value == value
]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testDeclaredBecomeClassBinding [
	"If a global variable is assigned a class as
	its value, its binding will become a class 
	binding."

	| binding class |
	class := Behavior new.
	binding := env 
		bind: #Griffle to: value;
		declarationOf: #Griffle.
	env at: #Griffle put: class.
	self assert: (binding class == ClassBinding).
	self assert: binding value == class.
]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testDeclaredBecomeGlobal [
	"If a class binding gets assigned a non-
	class value, the binding becomes a global."

	| binding class |
	class := Behavior new.
	binding := env 
		bind: #Griffle to: class;
		declarationOf: #Griffle.
	env at: #Griffle put: value.
	self assert: (binding class == Global).
	self assert: binding value == value.
]

{ #category : #'tests - observation' }
EnvironmentTest >> testDestroyRemovesObservers [
	"When an imported environment is destroyed,
	the import is destroyed along with it."

	| foreign |
	foreign := Environment withName: #Foreign.
	foreign exportSelf.
	env import: foreign.
	foreign destroy.
	self assert: 0 equals: (env instVarNamed: 'policies') size
]

{ #category : #'tests - observation' }
EnvironmentTest >> testDestroyStopsObserving [
	"When an environment is destroyed, it removes its self
	from the observers list of other environments."

	| foreign |
	foreign := Environment withName: #Foreign.
	foreign exportSelf.
	env import: foreign.
	env destroy.
	self assert: 0 equals: (foreign instVarNamed: 'observers') size
]

{ #category : #'tests - observation' }
EnvironmentTest >> testDestroyedImportIsUndeclared [
	"When an imported environment is destroyed, it's
	bindings become undeclared in the importing environment"

	| foreign |
	foreign := Environment withName: #Foreign.
	foreign exportSelf.
	foreign at: #Griffle put: value.
	env from: foreign import: #Griffle.
	foreign destroy.
	self assert: (env bindingOf: #Griffle) isNil.
	self assert: (env isUndeclared: #Griffle).
]

{ #category : #'tests - export' }
EnvironmentTest >> testExclusiveExplicitExport [
	"Exporting one name shouldn't
	export others."

	env export: #Plonk.
	env at: #Griffle put: Object new.
	self denyExports: #Griffle
]

{ #category : #'tests - export' }
EnvironmentTest >> testExclusiveMultiExplicitExport [
	"Exporting multiple names shouldn't export
	a name not on the list."

	env export: #(Plonk #Griffle).
	env at: #Nurp put: Object new.
	self denyExports: #Nurp
]

{ #category : #'tests - export' }
EnvironmentTest >> testExplicitExport [
	"Export a single name"
	
	env export: #Griffle.
	env bind: #Griffle to: value.
	self assertExports: #Griffle value: value
]

{ #category : #'tests - export' }
EnvironmentTest >> testExportAddPrefix [
	"export all names, adding a prefix."
	
	env exportAddingPrefix: 'XX'.
	env at: #Griffle put: value.
	self assertExports: #XXGriffle value: value
]

{ #category : #'tests - export' }
EnvironmentTest >> testExportAddingPrefixPublicizesExistingValue [
	"Export, adding prefix, *after* the binding has been created"
	
	env at: #Griffle put: value.
	env exportAddingPrefix: 'XX'.
	self assertExports: #XXGriffle value: value
]

{ #category : #'tests - export' }
EnvironmentTest >> testExportPublicizesExistingValue [
	"Export a single name, after the binding as been created."
	
	env at: #Griffle put: value.
	env export: #Griffle.
	self assertExports: #Griffle value: value
]

{ #category : #'tests - export' }
EnvironmentTest >> testExportRemovingPrefix [
	"Export all names, removing a prefix"

	env exportRemovingPrefix: 'XX'.
	env at: #XXGriffle put: value.
	self assertExports: #Griffle value: value
]

{ #category : #'tests - export' }
EnvironmentTest >> testExportRemovingPrefixPublicizesExistingValue [
	"Export all names, removing a prefix, 
	after a binding has been created."

	env at: #XXGriffle put: value.
	env exportRemovingPrefix: 'XX'.
	self assertExports: #Griffle value: value
]

{ #category : #'tests - export' }
EnvironmentTest >> testExportSelfPublicizesExistingValue [
	"Export all values, after a binding has been created."
	
	env at: #Griffle put: value.
	env exportSelf.
	self assertExports: #Griffle value: value
]

{ #category : #'tests - import' }
EnvironmentTest >> testImportAddingPrefix [
	"Import a single name adding a prefix."

	| foreign |
	foreign := Environment withName: #Foreign.
	foreign exportSelf.
	foreign at: #Griffle put: value.
	env import: foreign addingPrefix: 'XX'.
	self assert: (env bindingOf: #XXGriffle) value == value
]

{ #category : #'tests - import' }
EnvironmentTest >> testImportAddingPrefixResolvesUndeclared [
	"If there's an existing undeclared variable, importing
	a binding with the same (transformed) name creates
	the binding."

	| binding foreign |
	foreign := Environment withName: #Foreign.
	foreign exportSelf.
	foreign bind: #Griffle to: value.
	binding := env undeclare: #XXGriffle.
	env import: foreign addingPrefix: 'XX'.
	self assert: (env bindingOf: #XXGriffle) == binding.
	self assert: (env valueOf: #XXGriffle) == value
]

{ #category : #'tests - import' }
EnvironmentTest >> testImportAlias [
	| foreign binding |
	foreign := Environment withName: #Foreign.
	foreign exportSelf.
	foreign bind: #Griffle to: value.
	env from: foreign import: #Griffle -> #Plonk.
	binding := env bindingOf: #Plonk.
	self assert: binding key = #Plonk.
	self assert: binding value == value
]

{ #category : #'tests - import' }
EnvironmentTest >> testImportAliases [
	"Import several specific names, renaming them."

	| foreign v2 v3 |
	foreign := Environment withName: #Foreign.
	foreign exportSelf.
	foreign at: #Griffle put: value.
	foreign at: #Nurp put: (v2 := Object new).
	foreign at: #Ziffy put: (v3 := Object new).
	env from: foreign import: {#Nurp -> #Plonk. #Ziffy -> #Wiffy}.
	self assert: (env bindingOf: #Griffle) isNil.
	self assert: (env bindingOf: #Plonk) value == v2.
	self assert: (env bindingOf: #Wiffy) value == v3
]

{ #category : #'tests - import' }
EnvironmentTest >> testImportFromOther [
	"Import a whole environment."

	| foreign |
	foreign := Environment withName: #Foreign.
	foreign exportSelf.
	foreign at: #Griffle put: value.
	env import: foreign.
	self assert: (env bindingOf: #Griffle) value == value
]

{ #category : #'tests - import' }
EnvironmentTest >> testImportOne [
	"import s specific name"

	| foreign |
	foreign := Environment withName: #Foreign.
	foreign exportSelf.
	foreign at: #Griffle put: value.
	env from: foreign import: #Griffle.
	self assert: (env bindingOf: #Griffle) value == value
]

{ #category : #'tests - import' }
EnvironmentTest >> testImportRemovingPrefix [
	"Import all names, removing a prefix."

	| foreign |
	foreign := Environment withName: #Foreign.
	foreign exportSelf.
	foreign at: #XXGriffle put: value.
	env import: foreign removingPrefix: 'XX'.
	self assert: (env bindingOf: #Griffle) value == value
]

{ #category : #'tests - import' }
EnvironmentTest >> testImportRemovingPrefixResolvesUndeclared [
	"Import all names, removing a prefix, with undeclared"

	| binding foreign |
	foreign := Environment withName: #Foreign.
	foreign exportSelf.
	foreign at: #XXGriffle put: value.
	binding := env undeclare: #Griffle.
	env import: foreign removingPrefix: 'XX'.
	self assert: (env bindingOf: #Griffle) == binding.
	self assert: (env valueOf: #Griffle) == value
]

{ #category : #'tests - import' }
EnvironmentTest >> testImportResolvesUndeclared [
	"Import all bindings, with undeclared"

	| binding foreign |
	foreign := Environment withName: #Foreign.
	foreign exportSelf.
	foreign at: #Griffle put: value.
	binding := env undeclare: #Griffle.
	env import: foreign.
	self assert: (env bindingOf: #Griffle) == binding.
	self assert: (env valueOf: #Griffle) == value
]

{ #category : #'tests - import' }
EnvironmentTest >> testImportWritable [
	"Imported globals, even if renamed, should be writable."

	| foreign binding |
	foreign := Environment withName: #Foreign.
	foreign exportSelf.
	foreign bind: #Griffle to: 'v1'.
	env from: foreign import: #Griffle -> #Plonk.
	binding := env bindingOf: #Plonk.
	binding value: 'v2'.
	self assert: (foreign declarationOf: #Griffle) value = 'v2' 
]

{ #category : #'tests - compiling' }
EnvironmentTest >> testInternalVisibility [
	"A method on a class in an environment
	can refer to other classes in that environment
	(provided the environment imports its self)"
	
	| griffle plonk |
	env importSelf.
	self createClass: #Griffle.
	self createClass: #Plonk.
	griffle := env at: #Griffle.
	griffle compileSilently: 'plonk ^ Plonk'.
	plonk := griffle new plonk.
	self assert: (env at: #Plonk) == plonk
]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testKeysAndValuesDo [
	"For compatibility with legacy code, environments 
	should implement the dictionary protocol."

	env at: #Griffle put: value.
	env at: #Plonk put: value.
	env at: #Nurp put: value.
	env keysAndValuesDo: [:key :val |
		(#(Smalltalk Undeclared) includes: key)
			ifFalse: ["We're not interested in these default bindings"
				self assert: (#(Griffle Plonk Nurp) includes: key).
				self assert: value equals: val]].
]

{ #category : #'tests - export' }
EnvironmentTest >> testMultiExplicitExport [
	"Export a list of names"

	| v2 |
	env export: #(#Griffle #Plonk).
	env at: #Griffle put: value.
	env at: #Plonk put: (v2 := Object new).
	self assertExports: #Griffle value: value.
	self assertExports: #Plonk value: v2
]

{ #category : #'tests - export' }
EnvironmentTest >> testMultiExportPublicizesExistingValue [
	"Export a list of names, with existing binaries."
	
	| v2 |
	env at: #Griffle put: value.
	env at: #Plonk put: (v2 := Object new).
	env export: #(Griffle Plonk).
	self assertExports: #Griffle value: value.
	self assertExports: #Plonk value: v2.
]

{ #category : #'tests - binding' }
EnvironmentTest >> testReadOnlyBindings [
	"It's almost always a bug to overwrite a class, so 
	all class bindings should be read-only by default."
	
	| binding class |
	class := Behavior new.
	env importSelf.
	env bind: #Griffle to: class.
	binding := env bindingOf: #Griffle.
	self
		should: [binding value: nil]
		raise: AttemptToWriteReadOnlyGlobal
]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testRemoveKey [
	"For compatibility with legacy code, environments 
	should implement the dictionary protocol."

	self 
		should: [env removeKey: #Griffle] 
		raise: KeyNotFound.
]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testRemoveKeyIfAbsent [
	"For compatibility with legacy code, environments 
	should implement the dictionary protocol."

	| result |
	result := env removeKey: #Griffle ifAbsent: [#removed].
	self assert: #removed equals: result.
	
	env at: #Griffle put: value.
	result := env removeKey: #Griffle ifAbsent: [#removed].
	self assert: value equals: result.
]

{ #category : #'tests - class' }
EnvironmentTest >> testRenameContinuity [
	"When we rename a class, literal references to it 
	from method bytecode should still work even though
	they are now undeclared."

	| class |
	env importSelf.
	class := self createClass: #Griffle.
	class compileSilently: 'foo ^ Griffle new' classified: ''.
	self shouldnt: [class new foo] raise: Error.
	self assert: class equals: class new foo class description: '<failsafe>'.

	class rename: #Plonk.
	self shouldnt: [class new foo] raise: Error.
	self
		assert: class
		equals: class new foo class
		description: 'The value of the binding should still be intact after a class rename'.
	
]

{ #category : #'tests - class' }
EnvironmentTest >> testRenameCreatesNewBinding [
	"When we rename a class, a completely new 
	binding should be created for the new name.
	The old binding is moved to undeclared."

	| class newBinding oldBinding |
	env importSelf.
	class := self createClass: #Griffle.
	oldBinding := env bindingOf: #Griffle.
	class rename: #Plonk.
	newBinding := env bindingOf: #Plonk.
	self deny: newBinding == oldBinding.
	
	self assert: class identical: oldBinding value.
	self assert: #Griffle equals: oldBinding key.
	
	self assert: #Plonk equals: newBinding key.
	self assert: class identical: newBinding value.
	
]

{ #category : #'tests - export' }
EnvironmentTest >> testRequireExplicitExports [
	"Names that haven't been exported
	aren't visible, even if a binding exists."

	env bind: #Griffle to: Object new.
	self denyExports: #Griffle.
]

{ #category : #'tests - compiling' }
EnvironmentTest >> testStoreDomesticValue [
	"Create a class that implements #doStore.
	(see the comment in #storeValueMethod.)
	Send the message, then examine the results.
	The two values should be identical."

	| griffle values |
	env importSelf.
	env from: Smalltalk globals import: #Object.
	self createClass: #Griffle.
	env bind: #Plonk to: value.
		
	griffle := env at: #Griffle.
	griffle compileSilently: self storeValueMethod.
	values := griffle new doStore.
	
	self assert: values isArray.
	self assert: values size = 2.
	self assert: values first == values last.
	self assert: (env valueOf: #Plonk) == values first
]

{ #category : #'tests - compiling' }
EnvironmentTest >> testStoreImportedValue [
	"Create a class that implements #doStore.
	Import #Plonk from another environment.
	(see the comment in #storeValueMethod.)
	Send the message, then examine the results.
	The two values should be identical."

	| griffle foreign values |
	self createClass: #Griffle.
	foreign := Environment withName: #Foreign.
	foreign exportSelf.
	foreign at: #Plonk put: 'v1'.
	env from: foreign import: #Plonk.
	env from: Smalltalk globals import: #Object.
	
	griffle := env at: #Griffle.
	griffle compileSilently: self storeValueMethod.
	values := griffle new doStore.
	
	self assert: values isArray.
	self assert: values size = 2.
	self assert: values first == values last.
	self assert: (foreign at: #Plonk) == values first
]

{ #category : #'tests - observation' }
EnvironmentTest >> testUnbindDoesNotAlterImportedBindings [
	"When attempting to unbind a symbol, do not alter bindings outside of the envrionments'
	own declarations."

	| foreign foreignBinding one two |
	foreign := Environment withName: #Foreign.
	foreign exportSelf.
	foreign bind: #Griffle to: value.
	foreignBinding := foreign associationAt: #Griffle.
	env at: #Griffle put: Object new.
	env importSelf.
	env import: foreign.
	one := env bindingOf: #Griffle.
	self assert: one == foreignBinding description: 'imported binding'.
	
	env unbind: #Griffle.
	two := env bindingOf: #Griffle.
	self assert: value equals: foreignBinding value description: 'imported value unaffacted'.
	self assert: two == foreignBinding description: 'imported binding still in place'.
]

{ #category : #'tests - observation' }
EnvironmentTest >> testUnbindDoesNotDestroyImportedBindingsFromAnotherEnvironment [
	"When a symbol is undeclared, the observing environments should not
	lose a binding with the same key if that binding is actually imported from
	self or a third environment."

	| foreign foreignBinding one ownValue two three |
	foreign := Environment withName: #Foreign.
	foreign exportSelf.
	foreign bind: #Griffle to: value.
	foreignBinding := foreign associationAt: #Griffle.
	env importSelf.
	env import: foreign.
	one := env bindingOf: #Griffle.
	self assert: one == foreignBinding description: 'imported binding'.
	self assert: one value == value description: 'imported binding'.
	
	ownValue := Object new.
	env bind: #Griffle to: ownValue.
	two := env bindingOf: #Griffle.
	self assert: one ~~ two description: 'new binding'.
	
	foreign unbind: #Griffle.
	self assert: nil equals: one value description: 'imported binding undeclared'.
	three := env bindingOf: #Griffle.
	self assert: two == three description: 'own binding unaffected'.
	self assert: three value == ownValue description: 'own binding''s value unaffected'.
]

{ #category : #'tests - binding' }
EnvironmentTest >> testUndeclare [
	"When a symbol is undeclared, it's not visible to methods compiled
	in the environment, so #bindingOf: should answer nil. However, 
	methods that refer to the symbol anyway use a canonical binding.
	That binding should have a nil value and be an instance of Global, 
	rather than a class binding or alias."

	| one two |
	one := env undeclare: #Griffle.
	two := env bindingOf: #Griffle.
	self assert: nil equals: two description: '#bindingOf:'.
	self assert: Global equals: one class description: 'Type of binding'.
	self assert: nil equals: one value description: 'Value of binding'.
]

{ #category : #'tests - binding' }
EnvironmentTest >> testUndeclareAgain [
	"Multiple 'undeclarations' of the same variable name should
	use the same canonical binding."
	
	| one two |
	one := env undeclare: #Griffle.
	two := env undeclare: #Griffle.
	self assert: one == two.
]

{ #category : #'tests - binding' }
EnvironmentTest >> testUndeclareFromConflict [
	"When a shared variable is removed from a class pool,
	it gets undeclared in the environment. If that variable
	name is *already* undeclared in the environment, the
	binding in the environment is maintained, and references
	to the pool binding become references to the environment's
	binding. The binding should be a Global."

	| one pool three two |
	pool := IdentityDictionary new.
	pool at: #Griffle put: value.
	one := pool bindingOf: #Griffle.
	two := env undeclare: #Griffle.
	three := env undeclare: #Griffle from: pool.
	self assert: three == two description: 'Existing binding is reused'.
	self assert: three == one description: 'Pool binding is forwarded'.
	self assert: Global equals: three class description: 'Type of binding'.
	
]

{ #category : #'tests - binding' }
EnvironmentTest >> testUndeclareFromEmpty [
	"When a binding is moved from a pool to an environment, but
	actually doesn't exist in the pool in the first place, a new binding
	with a nil value is created for the environment's undeclared dictionary."

	| binding |
	binding := env undeclare: #Griffle from: IdentityDictionary new.
	self assert: Global equals: binding class description: 'Type of binding'.
	self assert: nil equals: binding value description: 'Value of binding'.
]

{ #category : #'tests - binding' }
EnvironmentTest >> testUndeclareFromRemovesOld [
	"When a binding is removed from a pool,
	and undeclared in the enviornment, it should
	actually be removed from the pool dictionary."
	
	| pool |
	pool := IdentityDictionary new.
	pool at: #Griffle put: value.
	env undeclare: #Griffle from: pool.
	self 
		assert: false 
		equals: (pool includesKey: #Griffle) 
		description: 'Existing binding is removed'.
	
]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testUndeclaredBecomeClassBinding [
	"When a undeclared name is bound to a
	class existing bindings are transformed
	into ClassBindings."

	| binding class |
	class := Behavior new.
	binding := env undeclare: #Griffle.
	env at: #Griffle put: class.
	self assert: (binding class == ClassBinding).
	self assert: binding value == class.
]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testUndeclaredBecomesGlobal [
	"If a class binding is somehow undeclared, 
	it becomes a Global when a non-behavior
	value is bound to the name."

	| binding class |
	class := Behavior new.
	binding := env undeclared
		add: (#Griffle => class);
		associationAt: #Griffle.
	env bind: #Griffle to: value.
	self assert: (binding class == Global).
	self assert: binding value == value.
]

{ #category : #'tests - binding' }
EnvironmentTest >> testUndeclaredBindingMoved [
	"If a binding is undeclared, and subsequently
	declared, the existing binding is re-used for 
	the declaration."
	
	| binding |
	binding := env undeclare: #Griffle.
	env bind: #Griffle to: value.
	self assert: (env declarationOf: #Griffle) = binding.
]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testValuesDo [
	"For compatibility with legacy code, environments 
	should implement the dictionary protocol."

	| count |
	env at: #Griffle put: value.
	env at: #Plonk put: value.
	env at: #Nurp put: value.
	count := 0.	
	env valuesDo: [:val | count := count + 1].
	self assert: 3 + 2 equals: count description: '#valuesDo: should see all declared vallues plus the ones from Smalltalk and Undeclares'

]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testWriteAndLookup [
	"For compatibility with SystemDictionary, #at:put:
	should create a binding which can subsequently
	be found with #associationAt:."
	
	| binding |
	env at: #Griffle put: value.
	binding := env associationAt: #Griffle.
	self assert: binding key == #Griffle.
	self assert: binding value == value.
	
]

{ #category : #'tests - compatibility' }
EnvironmentTest >> testWriteAndRead [
	"For compatibility with SystemDictionary,
	a value set with #at:put: should be retrievable
	with #at:"

	env at: #Griffle put: value.
	self assert: (env at: #Griffle) == value.
]
