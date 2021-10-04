"
SUnit tests for class Generator
"
Class {
	#name : #GeneratorTest,
	#superclass : #TestCase,
	#category : #'Collections-Streams-Tests-Base'
}

{ #category : #accessing }
GeneratorTest class >> packageNamesUnderTest [
	^ #('Generator')
]

{ #category : #'as yet unclassified' }
GeneratorTest >> cofibonacci [

	^ Generator on: [ :g | 
		  g
			  nextPut: 0;
			  nextPut: 1;
			  nextPutAll: (g with: g allButFirst collect: [ :a :b | a + b ]) ]
]

{ #category : #'as yet unclassified' }
GeneratorTest >> factorial: n [

	".. code:: javascript
	
function* factorial(n) {
  if (n === 0) return 1;
  const n1 = yield factorial(n - 1);
  return n * n1;
}

	"

	^ Generator on: [ :g | 
		  n < 2
			  ifTrue: [ g nextPut: 1 ]
			  ifFalse: [ g nextPut: n * (self factorial: n - 1) next ] ]
]

{ #category : #generators }
GeneratorTest >> fibonacciSequence [
	"Yields an infinite sequence of fibonacci numbers."
	
	^ Generator on: [ :generator |
		| a b |
		a := 0. b := 1.
		[ a := b + (b := a).
		  generator yield: a ]
			repeat ]
]

{ #category : #generators }
GeneratorTest >> numbersBetween: aStartInteger and: aStopInteger [
	"Yields the nubmers between aStartInteger and aStopInteger."
	
	^ Generator on: [ :generator |
		aStartInteger to: aStopInteger 
			do: [ :value | generator yield: value ] ]
]

{ #category : #tests }
GeneratorTest >> testAllButFirst [

	| generator |
	generator := self fibonacciSequence allButFirst allButFirst.
	self
		assert: (generator next: 10) asArray
		equals: #( 2 3 5 8 13 21 34 55 89 144 )
]

{ #category : #tests }
GeneratorTest >> testAtEnd [
	| generator |
	generator := self numbersBetween: 1 and: 3.
	self deny: generator atEnd.
	generator next.
	self deny: generator atEnd.
	generator next.
	self deny: generator atEnd.
	generator next.
	self assert: generator atEnd
]

{ #category : #tests }
GeneratorTest >> testClose [
	| generator doEnsure notEnsure |
	doEnsure := notEnsure := 0.
	[ generator := Generator
		on: [ :g | 
			[ g
				yield: 1;
				yield: 2 ]
				ensure: [ doEnsure := doEnsure + 1 ] ].
	self
		assert: doEnsure equals: 0;
		assert: notEnsure equals: 0.
	self assert: generator peek equals: 1.
	self
		assert: doEnsure equals: 0;
		assert: notEnsure equals: 0.
	generator close.
	self
		assert: doEnsure equals: 1;
		assert: notEnsure equals: 0 ]
		ensure: [ notEnsure := notEnsure + 1 ].
	self
		assert: doEnsure equals: 1;
		assert: notEnsure equals: 1
]

{ #category : #tests }
GeneratorTest >> testCoFibonacci [

	| generator |
	generator := self cofibonacci.
	self
		should: [ (generator next: 6) asArray ]
		raise: MessageNotUnderstood
]

{ #category : #tests }
GeneratorTest >> testCollect [

	| generator |
	generator := self fibonacciSequence allButFirst collect: [ :each | 
		             each - 1 ].
	self
		assert: (generator next: 10) asArray
		equals: #( 0 1 2 4 7 12 20 33 54 88 ) "http://oeis.org/A000071"
]

{ #category : #tests }
GeneratorTest >> testContents [
	| generator |
	generator := self numbersBetween: 1 and: 3.
	self assert: generator contents equals: #(1 2 3)
]

{ #category : #tests }
GeneratorTest >> testEmpty [
	| generator |
	generator := Generator on: [ :g | ].
	self assert: generator atEnd.
	self assert: generator peek isNil.
	self assert: generator next isNil
]

{ #category : #tests }
GeneratorTest >> testEnsure [
	| generator |
	generator := Generator
		on: [ :g | 
			[ g
				yield: 1;
				yield: 2 ]
				ensure: [ g yield: 3 ] ].
	self assert: generator upToEnd asArray equals: #(1 2 3)
]

{ #category : #tests }
GeneratorTest >> testErrorPropagation [
	"Ensure that errors in the generator block are properly propagated"

	| generator |
	generator := Generator
		on: [ :g | 
			g yield: 1.
			g error: 'yo' ].
	self should: [ generator next ] raise: Error
]

{ #category : #tests }
GeneratorTest >> testFactorial [

	| generator |
	generator := self factorial: 10.
	self assert: generator contents equals: #( 3628800 )
]

{ #category : #tests }
GeneratorTest >> testFibonacci [
	| generator |
	generator := self fibonacciSequence.
	self assert: (generator next: 10) asArray equals: #(1 1 2 3 5 8 13 21 34 55)
]

{ #category : #tests }
GeneratorTest >> testNext [
	| generator |
	generator := self numbersBetween: 1 and: 3.
	self assert: generator next equals: 1.
	self assert: generator next equals: 2.
	self assert: generator next equals: 3.
	self assert: generator next isNil
]

{ #category : #tests }
GeneratorTest >> testPeek [
	| generator |
	generator := self numbersBetween: 1 and: 3.
	self assert: generator peek equals: 1.
	self assert: generator peek equals: 1.
	generator next.
	self assert: generator peek equals: 2
]

{ #category : #tests }
GeneratorTest >> testReset [
	| generator |
	generator := self numbersBetween: 1 and: 3.
	self assert: generator next equals: 1.
	self assert: generator next equals: 2.
	generator reset.
	self assert: generator next equals: 1.
	self assert: generator next equals: 2.
	self assert: generator next equals: 3.
	self assert: generator next equals: nil.
	generator reset.
	self assert: generator next equals: 1
]

{ #category : #tests }
GeneratorTest >> testResetUnwind [
	"Just like close, just using reset"

	| generator doEnsure notEnsure |
	doEnsure := notEnsure := 0.
	[ generator := Generator
		on: [ :g | 
			[ g
				yield: 1;
				yield: 2 ]
				ensure: [ doEnsure := doEnsure + 1 ] ].
	self
		assert: doEnsure equals: 0;
		assert: notEnsure equals: 0.
	self assert: generator peek equals: 1.
	self
		assert: doEnsure equals: 0;
		assert: notEnsure equals: 0.
	generator reset.
	self
		assert: doEnsure equals: 1;
		assert: notEnsure equals: 0 ]
		ensure: [ notEnsure := notEnsure + 1 ].
	self
		assert: doEnsure equals: 1;
		assert: notEnsure equals: 1
]

{ #category : #tests }
GeneratorTest >> testSimple [
	| generator |
	generator := Generator
		on: [ :g | 
			g
				yield: 1;
				yield: 2 ].
	self assert: generator upToEnd asArray equals: #(1 2)
]
