"
I capture tests about usages of continuations as commented, and implemented in Scheme, in [1].

[1]: Friedman, D.P. and Felleisen, M. and Bibby, D., The Seasoned Schemer, MIT Press
     (https://mitpress.mit.edu/books/seasoned-schemer-second-edition).
"
Trait {
	#name : #TSeasonedSchemerContinuationTest,
	#category : #'Kernel-Tests-Methods'
}

{ #category : #utilities }
TSeasonedSchemerContinuationTest >> callcc: aBlock [

	self explicitRequirement
]

{ #category : #functions }
TSeasonedSchemerContinuationTest >> intersect: aSet withAll: sets [
	^ sets
		ifEmpty: [ aSet ]
		ifNotEmpty: [ self
				intersect: aSet
				withCollection: (self intersect: sets first withAll: sets allButFirst) ]
]

{ #category : #functions }
TSeasonedSchemerContinuationTest >> intersect: aSet withAll: sets continuation: hop [
	^ aSet
		ifEmpty: [ hop value: aSet ]
		ifNotEmpty: [ sets
				ifEmpty: [ aSet ]
				ifNotEmpty: [ self
						intersect: aSet
						withCollection:
							(self
								intersect: sets first
								withAll: sets allButFirst
								continuation: hop) ] ]
]

{ #category : #functions }
TSeasonedSchemerContinuationTest >> intersect: aLinkedList withCollection: aCollection [
	^ aLinkedList
		ifNotEmpty: [ (self
				intersectValueLink: aLinkedList firstLink
				withCollection: aCollection)
				ifNil: [ LinkedList new ]
				ifNotNil: [ :link | LinkedList with: link ] ]
]

{ #category : #functions }
TSeasonedSchemerContinuationTest >> intersect: aLinkedList withCollection: aCollection continuation: hop [
	^ aCollection
		ifEmpty: [ hop value: aCollection ]
		ifNotEmpty: [ self intersect: aLinkedList withCollection: aCollection ]
]

{ #category : #functions }
TSeasonedSchemerContinuationTest >> intersectAll: sets [
	^ sets
		ifNotEmpty: [ self intersect: sets first withAll: sets allButFirst ]
]

{ #category : #functions }
TSeasonedSchemerContinuationTest >> intersectAllWithCC: sets [

	^ sets ifNotEmpty: [ 
		  self callcc: [ :cc | 
			  self
				  intersect: sets first
				  withAll: sets allButFirst
				  continuation: cc ] ]
]

{ #category : #functions }
TSeasonedSchemerContinuationTest >> intersectValueLink: aValueLink withCollection: anotherSet [
	^ aValueLink
		ifNotNil: [ | car cdr |
			car := aValueLink value.
			cdr := self
				intersectValueLink: aValueLink nextLink
				withCollection: anotherSet.
			(anotherSet includes: car)
				ifTrue: [ car ~~> cdr ]
				ifFalse: [ cdr ] ]
]

{ #category : #functions }
TSeasonedSchemerContinuationTest >> intersectWithCC: aSet withAll: sets continuation: hop [
	^ aSet
		ifEmpty: [ hop value: aSet ]
		ifNotEmpty: [ sets
				ifEmpty: [ aSet ]
				ifNotEmpty: [ self
						intersect: aSet
						withCollection:
							(self
								intersectWithCC: sets first
								withAll: sets allButFirst
								continuation: hop)
						continuation: hop ] ]
]

{ #category : #functions }
TSeasonedSchemerContinuationTest >> intersectWithCCAllWithCC: sets [

	^ sets ifNotEmpty: [ 
		  self callcc: [ :cc | 
			  self
				  intersectWithCC: sets first
				  withAll: sets allButFirst
				  continuation: cc ] ]
]

{ #category : #functions }
TSeasonedSchemerContinuationTest >> leftmost: aBlock tree: aTree [
	^ self
		callcc: [ :skip | self leftmost: aBlock tree: aTree continuation: skip ]
]

{ #category : #functions }
TSeasonedSchemerContinuationTest >> leftmost: aBlock tree: aTree continuation: out [
	^ (aTree isNotNil and: [ aTree isMemberOf: ValueLink ])
		ifTrue: [ | car |
			car := aTree value.
			(car isKindOf: Link)
				ifTrue: [ self leftmost: aBlock tree: car continuation: out ]
				ifFalse: [ (aBlock value: car)
						ifTrue: [ out value: car ] ].
			self leftmost: aBlock tree: aTree nextLink continuation: out ]
		ifFalse: [ nil ]
]

{ #category : #printing }
TSeasonedSchemerContinuationTest >> printStringOfTree: aValueLink [
	^ String
		streamContents: [ :aStream | self printStringOfTree: aValueLink onStream: aStream ]
]

{ #category : #printing }
TSeasonedSchemerContinuationTest >> printStringOfTree: aValueLink onStream: aStream [
	aStream nextPut: $(.
	(aValueLink isMemberOf: Link)
		ifFalse: [ | cell |
			cell := aValueLink.
			[ | car |
			car := cell value.
			(car isKindOf: Link)
				ifTrue: [ self printStringOfTree: car onStream: aStream ]
				ifFalse: [ car printOn: aStream ].
			cell nextLink ifNotNil: [ aStream nextPut: Character space ].
			cell := cell nextLink.
			cell isMemberOf: ValueLink ] whileTrue.
			cell
				ifNotNil: [ aStream
						nextPut: $.;
						nextPut: Character space.
					cell printOn: aStream ] ].
	aStream nextPut: $)
]

{ #category : #functions }
TSeasonedSchemerContinuationTest >> remove: anObj oneStar: aTree [
	| newTree sentinel |
	sentinel := #absent.
	newTree := self
		callcc: [ :oh | 
			self
				remove: anObj
				oneStar: aTree
				sentinel: sentinel
				continuation: oh ].
	^ newTree = sentinel
		ifTrue: [ aTree ]
		ifFalse: [ newTree ]
]

{ #category : #functions }
TSeasonedSchemerContinuationTest >> remove: anObj oneStar: aTree sentinel: aSymbol continuation: oh [

	^ aTree ifNil: [ oh value: aSymbol ] ifNotNil: [ 
		  | car cdr naturalRecursion |
		  car := aTree value.
		  cdr := aTree nextLink.
		  naturalRecursion := [ 
		                      | newCdr |
		                      newCdr := self
			                                remove: anObj
			                                oneStar: cdr
			                                sentinel: aSymbol
			                                continuation: oh.
		                      car ~~> newCdr ].
		  (car isMemberOf: ValueLink)
			  ifTrue: [ 
				  | newCar |
				  newCar := self callcc: [ :ooh | 
					            self
						            remove: anObj
						            oneStar: car
						            sentinel: aSymbol
						            continuation: ooh ].
				  newCar = aSymbol
					  ifTrue: naturalRecursion
					  ifFalse: [ newCar ~~> cdr ] ]
			  ifFalse: [ 
				  anObj = car
					  ifTrue: [ cdr ]
					  ifFalse: naturalRecursion ] ]
]

{ #category : #functions }
TSeasonedSchemerContinuationTest >> remove: anObj oneStarWithTry: aTree [

	^ self
		  try: [ :oh | 
		  self remove: anObj oneStarWithTry: aTree continuation: oh ]
		  otherwise: [ aTree ]
]

{ #category : #functions }
TSeasonedSchemerContinuationTest >> remove: anObj oneStarWithTry: aTree continuation: oh [

	^ aTree ifNil: [ oh value: #absent ] ifNotNil: [ 
		  | car cdr naturalRecursion |
		  car := aTree value.
		  cdr := aTree nextLink.
		  naturalRecursion := [ 
		                      | newCdr |
		                      newCdr := self
			                                remove: anObj
			                                oneStarWithTry: cdr
			                                continuation: oh.
		                      car ~~> newCdr ].
		  (car isMemberOf: ValueLink)
			  ifTrue: [ 
				  self
					  try: [ :ooh | 
						  | newCar |
						  newCar := self
							            remove: anObj
							            oneStarWithTry: car
							            continuation: ooh.
						  newCar ~~> cdr ]
					  otherwise: naturalRecursion ]
			  ifFalse: [ 
				  anObj = car
					  ifTrue: [ cdr ]
					  ifFalse: naturalRecursion ] ]
]

{ #category : #functions }
TSeasonedSchemerContinuationTest >> remove: anObj uptoLast: aLinkedList [

	^ aLinkedList ifNotEmpty: [ 
		  | valueLink |
		  valueLink := self callcc: [ :skip | 
			               self
				               remove: anObj
				               uptoLastValueLink: aLinkedList firstLink
				               continuation: skip ].
		  LinkedList with: valueLink ]
]

{ #category : #functions }
TSeasonedSchemerContinuationTest >> remove: anObj uptoLastValueLink: aValueLink continuation: skip [
	^ aValueLink
		ifNotNil: [ | car cdr |
			car := aValueLink value.
			cdr := self
				remove: anObj
				uptoLastValueLink: aValueLink nextLink
				continuation: skip.
			anObj = car
				ifTrue: [ skip value: cdr ]
				ifFalse: [ car ~~> cdr ] ]
]

{ #category : #tests }
TSeasonedSchemerContinuationTest >> testIntersectAll [
	self
		assert:
			(self
				intersectAll:
					{(LinkedList with: 3 with: #mangos with: #and).
					(LinkedList with: 3 with: #kiwis with: #and).
					(LinkedList with: 3 with: #hamburges)})
		equals: {3}.
	self
		assert:
			(self
				intersectAll:
					{(LinkedList with: 3 with: #steaks with: #and).
					(LinkedList with: #no with: #food with: #and).
					(LinkedList with: #three with: #baked with: #potatoes).
					(LinkedList with: 3 with: #diet with: #hamburges)})
		equals: {}.
	self
		assert:
			(self
				intersectAll:
					{(LinkedList with: 3 with: #steaks with: #and).
					LinkedList new.
					(LinkedList with: #three with: #baked with: #potatoes).
					(LinkedList with: 3 with: #diet with: #hamburges)})
		equals: {}.
	self
		assert:
			(self
				intersectAllWithCC:
					{(LinkedList with: 3 with: #steaks with: #and).
					LinkedList new.
					(LinkedList with: #three with: #baked with: #potatoes).
					(LinkedList with: 3 with: #diet with: #hamburges)})
		equals: {}.
	self
		assert:
			(self
				intersectWithCCAllWithCC:
					{(LinkedList with: 3 with: #steaks with: #and).
					(LinkedList with: #no with: #food with: #and).
					(LinkedList with: #three with: #baked with: #potatoes).
					(LinkedList with: 3 with: #diet with: #hamburges)})
		equals: {}
]

{ #category : #tests }
TSeasonedSchemerContinuationTest >> testIntersectWith [
	self
		assert:
			(self
				intersect: (LinkedList with: #apple with: #banana with: #avocado)
				withCollection: (LinkedList with: 1 with: 2 with: #apple))
		equals: (LinkedList with: #apple).
	self
		assert:
			(self
				intersect: ((1 to: 10) as: LinkedList)
				withCollection: (9 to: 20))
		equals: (9 to: 10).
	self
		assert:
			(self
				intersect: ((1 to: 10) as: LinkedList)
				withCollection: (11 to: 20))
		equals: {}
]

{ #category : #tests }
TSeasonedSchemerContinuationTest >> testLeftmost [
	| tree |
	tree := #a ~~> nil ~~> nil
		~~> (4 ~~> (Link new ~~> (1 ~~> nil ~~> nil))).
	self
		assert: (self printStringOfTree: tree)
		equals: '(((#a)) 4 () (1))'.
	self assert: (self leftmost: #isSymbol tree: tree) equals: #a.
	self assert: (self leftmost: #isInteger tree: tree) equals: 4.
	self assert: (self leftmost: [ :v | v = 1 ] tree: tree) equals: 1.
	self assert: (self leftmost: #isNil tree: tree) equals: nil.
	self assert: (self leftmost: [ :v | v = 5 ] tree: tree) equals: nil
]

{ #category : #tests }
TSeasonedSchemerContinuationTest >> testRemoveOneStar [
	| tree1 tree2 |
	tree1 := #Swedish ~~> (#rye ~~> nil)
		~~>
			(#French ~~> (#mustard ~~> (#salad ~~> (#turkey ~~> nil)) ~~> nil)
				~~> (#salad ~~> nil)).
	tree2 := #pasta ~~> (#meat ~~> nil)
		~~>
			(#pasta
				~~>
					(#noodles ~~> (#meat ~~> (#sauce ~~> nil))
						~~> (#meat ~~> (#tomatoes ~~> nil)))).
	self
		assert: (self printStringOfTree: tree1)
		equals: '((#Swedish #rye) (#French (#mustard #salad #turkey)) #salad)'.
	self
		assert: (self printStringOfTree: tree2)
		equals: '((#pasta #meat) #pasta (#noodles #meat #sauce) #meat #tomatoes)'.
	self
		assert: (self printStringOfTree: (self remove: #salad oneStar: tree1))
		equals: '((#Swedish #rye) (#French (#mustard #turkey)) #salad)'.
	self
		assert: (self printStringOfTree: (self remove: #salad oneStarWithTry: tree1))
		equals: '((#Swedish #rye) (#French (#mustard #turkey)) #salad)'.
	self
		assert: (self printStringOfTree: (self remove: #meat oneStar: tree2))
		equals: '((#pasta) #pasta (#noodles #meat #sauce) #meat #tomatoes)'.
	self
		assert: (self printStringOfTree: (self remove: #meat oneStarWithTry: tree2))
		equals: '((#pasta) #pasta (#noodles #meat #sauce) #meat #tomatoes)'
]

{ #category : #tests }
TSeasonedSchemerContinuationTest >> testRemoveUptoLast [
	self
		assert:
			(self
				remove: #cookies
				uptoLast:
					(LinkedList new
						add: #cookies;
						add: #chocolate;
						add: #mints;
						add: #caramel;
						add: #delight;
						add: #ginger;
						add: #snaps;
						add: #desserts;
						add: #chocolate;
						add: #mousse;
						add: #vanilla;
						add: #ice;
						add: #cream;
						add: #German;
						add: #chocolate;
						add: #cake;
						add: #more;
						add: #cookies;
						"from this down to the last should be kept in the result
						because the previous #cookies is the last one #cookies in the list."
							add: #gingerbreadman;
						add: #chocolate;
						add: #chip;
						add: #brownies;
						yourself))
		equals:
			(LinkedList new
				add: #gingerbreadman;
				add: #chocolate;
				add: #chip;
				add: #brownies;
				yourself)
]

{ #category : #tests }
TSeasonedSchemerContinuationTest >> testTwoInARow [

	| tree1 tree2 |
	tree1 := #solid ~~> (#food ~~> nil ~~> (Link new ~~> nil))
	         ~~> (#food ~~> nil ~~> nil ~~> nil ~~> nil).
	tree2 := #solid ~~> (#food ~~> nil ~~> (#marmellade ~~> nil))
	         ~~> (#food ~~> nil ~~> nil ~~> nil ~~> nil).
	self
		assert: (self printStringOfTree: tree1)
		equals: '((#solid (#food) ()) (((#food))))'.
	self
		assert: (TwoInARowStar new
				 testCase: self;
				 tree: tree1)
		equals: true.
	self
		assert: (self printStringOfTree: tree2)
		equals: '((#solid (#food) #marmellade) (((#food))))'.
	self
		assert: (TwoInARowStar new
				 testCase: self;
				 tree: tree2)
		equals: false
]

{ #category : #utilities }
TSeasonedSchemerContinuationTest >> try: tryBlock otherwise: otherwiseBlock [

	self explicitRequirement
]
