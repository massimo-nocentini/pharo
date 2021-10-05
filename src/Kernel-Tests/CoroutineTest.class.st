Class {
	#name : #CoroutineTest,
	#superclass : #TestCase,
	#traits : 'TSeasonedSchemerContinuationTest',
	#classTraits : 'TSeasonedSchemerContinuationTest classTrait',
	#category : #'Kernel-Tests-Methods'
}

{ #category : #utilities }
CoroutineTest >> callcc: aBlock [

	^ Coroutine currentDo: aBlock
]

{ #category : #test }
CoroutineTest >> coroutineOn: aBlock [

	^ Coroutine on: aBlock
]

{ #category : #test }
CoroutineTest >> permutation: array size: size resume: resume [

	size = 1
		ifTrue: [ resume value: array copy ]
		ifFalse: [ 
			1 to: size do: [ :i | 
				array swap: i with: size.
				self permutation: array size: size - 1 resume: resume.
				array swap: i with: size ] ]
]

{ #category : #test }
CoroutineTest >> testAlphabet [

	"create an alphabet using coroutines"

	| main gen res |
	main := gen := nil.

	main := self coroutineOn: [ :resume :value | 
		        String streamContents: [ :aStream | 
			        (1 to: value) do: [ :i | 
				        aStream nextPut: (resume value: gen value: nil) ] ] ].

	gen := self coroutineOn: [ :resume :value | 
		       | index |
		       index := 10.
		       [ index <= 35 ] whileTrue: [ 
			       | back |
			       back := resume
				               value: main
				               value: (Character digitValue: index).
			       index := index + 1.
			       self assert: back equals: nil ] ].

	res := main value: 26.

	self assert: res equals: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
]

{ #category : #tests }
CoroutineTest >> testIdentity [

	| co |
	co := self coroutineOn: [ :resume :value | value ].

	self assert: (co value: 4) equals: 4
]

{ #category : #tests }
CoroutineTest >> testInitialResume [

	| co main res |
	co := self coroutineOn: [ :resume :v | 
		      res := { 
			             v first.
			             v second.
			             (v third + 2) } ].

	main := self coroutineOn: [ :resume :value | 
		        resume value: co value: #( 1 2 3 ) ].

	main value: nil.

	self assert: res equals: #( 1 2 5 )
]

{ #category : #test }
CoroutineTest >> testPermutations [

	| co array main perms n |
	n := 4.
	array := (1 to: n) asArray.
	perms := Set new.

	main := co := nil.

	co := self coroutineOn: [ :resume :size | 
		      self
			      permutation: array
			      size: size
			      resume: [ :perm | resume value: main value: perm ] ].

	main := self coroutineOn: [ :resume :size | 
		        1 to: n factorial do: [ :each | 
		        perms add: (resume value: co value: size) ] ].

	main value: array size.

	self assert: perms size equals: n factorial.

	self assert: perms equals: (Set withAll:
			 #( #( 2 3 1 4 ) #( 4 2 3 1 ) #( 4 2 1 3 ) #( 1 2 4 3 )
			    #( 3 2 4 1 ) #( 3 2 1 4 ) #( 3 1 4 2 ) #( 3 4 1 2 )
			    #( 4 1 3 2 ) #( 2 4 3 1 ) #( 3 1 2 4 ) #( 1 4 2 3 )
			    #( 3 4 2 1 ) #( 2 1 4 3 ) #( 2 4 1 3 ) #( 1 2 3 4 )
			    #( 1 4 3 2 ) #( 4 1 2 3 ) #( 2 3 4 1 ) #( 4 3 1 2 )
			    #( 2 1 3 4 ) #( 4 3 2 1 ) #( 1 3 4 2 ) #( 1 3 2 4 ) ))
]

{ #category : #tests }
CoroutineTest >> testProducerConsumer [

	| producer consumer values random |
	values := OrderedCollection new.
	random := Random seed: 13.

	producer := consumer := nil.

	producer := self coroutineOn: [ :resume :p | 
		            [ 
		            | coin size |
		            coin := (random next < p) asBit.
		            size := resume value: consumer value: coin.
		            size < 10 ] whileTrue ].

	consumer := self coroutineOn: [ :resume :value | 
		            | coin |
		            coin := value.
		            [ 
		            values add: coin.
		            coin := resume value: producer value: values size ]
			            repeat ].

	producer value: 0.6.

	self assert: values asArray equals: #( 1 0 0 0 0 0 0 0 0 1 )
]

{ #category : #tests }
CoroutineTest >> testProduct [

	| co p n |
	p := 1.
	co := self coroutineOn: [ :resume :value | p := p * value ].

	n := 10.
	(1 to: n) do: co.

	self assert: p equals: n factorial
]

{ #category : #tests }
CoroutineTest >> testProductWithZero [

	| co p zeroCo multiplications numbers |
	p := 1.
	multiplications := 0.
	numbers := #( 1 10 2 4 0 3 5 6 8 9 7 ).

	[ :exit | 
	zeroCo := self coroutineOn: [ :resume :value | 
		          p := value.
		          exit value ].

	co := self coroutineOn: [ :resume :aCollection | 
		      aCollection do: [ :each | 
			      each
				      ifZero: [ resume value: zeroCo value: each ]
				      ifNotZero: [ 
					      p := p * each.
					      multiplications := multiplications + 1 ] ] ].

	co value: numbers ] valueWithExit.

	self
		assert: p equals: 0;
		assert: multiplications equals: (numbers indexOf: 0) - 1
]

{ #category : #tests }
CoroutineTest >> testProductWithZeroAllCo [

	| prod p zeroCo multiplications numbers mainCo witness |
	p := 1.
	multiplications := 0.
	numbers := #( 1 10 2 4 0 3 5 6 8 9 7 ).
	witness := Object new.

	zeroCo := self coroutineOn: [ :resume :value | 
		          p := 0.
		          resume value: mainCo value: witness ].

	prod := self coroutineOn: [ :resume :aCollection | 
		        aCollection do: [ :each | 
			        each
				        ifZero: [ resume value: zeroCo value: each ]
				        ifNotZero: [ 
					        p := p * each.
					        multiplications := multiplications + 1 ] ] ].

	mainCo := self coroutineOn: [ :resume :aCollection | 
		          | v |
		          v := resume value: prod value: aCollection.
		          self assert: v equals: witness ].

	mainCo value: numbers.

	self
		assert: p equals: 0;
		assert: multiplications equals: (numbers indexOf: 0) - 1
]

{ #category : #test }
CoroutineTest >> testReset [

	"test the reset function"

	| res a b |
	a := b := nil.
	res := OrderedCollection new.

	a := self coroutineOn: [ :resume :useless | 
		     res add: 'Hi'.
		     res add: (resume value: b value: nil).
		     b reset.
		     res add: (resume value: b value: nil).
		     res add: 'Bye' ].

	b := self coroutineOn: [ :resume :useless | 
		     res add: (resume value: a value: 'Hola').
		     res add: 'Adeu' ].

	a value.

	self assert: res asArray equals: #( Hi Hola Hola Bye )
]

{ #category : #tests }
CoroutineTest >> testResumeYield [

	| co main res |
	main := nil.

	co := self coroutineOn: [ :resume :v | 
		      resume value: main value: { 
				      (v first + v second).
				      (v first - v second) } ].

	main := self coroutineOn: [ :resume :value | 
		        resume value: co value: value ].

	res := main value: #( 20 10 ).

	self assert: res equals: #( 30 10 )
]

{ #category : #test }
CoroutineTest >> testStableMarriageOne [

	"només una parella"

	| solver res guys gals guyPrefs galPrefs |
	"names"
	guys := #( 'Albert' ).
	gals := #( 'Ema' ).
	"preferences"
	guyPrefs := #( #( 1 ) ).
	galPrefs := #( #( 1 ) ).
	"init solver"
	solver := CoroutineStableMarriageExample new
		          test: self;
		          yourself.
	solver guys: guys.
	solver gals: gals.
	solver guyPrefs: guyPrefs.
	solver galPrefs: galPrefs.
	solver trace: true.
	res := solver solve.
	self assert: res equals: #( 1 )
]

{ #category : #test }
CoroutineTest >> testStableMarriagePeanuts [

	"stable marriage problem with the Peanuts characters"

	| solver res guys gals guyPrefs galPrefs |
	"names"
	guys := #( 'Charlie' 'Linus' 'Schroeder' 'Franklin' ).
	gals := #( 'Lucy' 'Peppermint' 'Marcie' 'Sally' ).
	"preferences"
	guyPrefs := #( #( 1 2 3 4 ) #( 3 4 2 1 ) #( 3 1 2 4 ) #( 2 4 3 1 ) ).
	"Charlie" "Lucy" "Peppermint" "Marcie" "Sally"
	"Linus" "Marcie" "Sally" "Peppermint" "Lucy"
	"Schroeder" "Marcie" "Lucy" "Peppermint" "Sally"
	"Franklin" "Peppermint" "Sally" "Marcie" "Lucy"
	galPrefs := #( #( 3 1 4 2 ) #( 1 2 4 3 ) #( 1 4 2 3 ) #( 2 4 3 1 ) ).
	"Lucy" "Schroeder" "Charlie" "Franklin" "Linus"
	"Peppermint" "Charlie" "Linus" "Franklin" "Schroeder"
	"Marcie" "Charlie" "Franklin" "Linus" "Schroeder"
	"Sally" "Linus" "Franklin" "Schroeder" "Charlie"
	"init solver"
	solver := CoroutineStableMarriageExample new
		          test: self;
		          yourself.
	solver guys: guys.
	solver gals: gals.
	solver guyPrefs: guyPrefs.
	solver galPrefs: galPrefs.
	solver trace: true.
	res := solver solve.
	self assert: res equals: #( 2 3 1 4 )
]

{ #category : #test }
CoroutineTest >> testStableMarriageStatement [

	"prova l'exemple del PDF 'allison-1983'"

	| solver res guys gals guyPrefs galPrefs |
	"names"
	guys := #( '1' '2' '3' ).
	gals := #( 'A' 'B' 'C' ).
	"preferences"
	guyPrefs := #( #( 1 2 3 ) #( 1 3 2 ) #( 2 3 1 ) ).
	"1" "A" "B" "C"
	"2" "A" "C" "B"
	"3" "B" "C" "A"
	galPrefs := #( #( 2 1 3 ) #( 2 3 1 ) #( 1 2 3 ) ).
	"A" "2" "1" "3"
	"B" "2" "3" "1"
	"C" "1" "2" "3"
	"init solver"
	solver := CoroutineStableMarriageExample new
		          test: self;
		          yourself.
	solver guys: guys.
	solver gals: gals.
	solver guyPrefs: guyPrefs.
	solver galPrefs: galPrefs.
	solver trace: true.
	res := solver solve.
	self assert: res equals: #( 3 1 2 )
]

{ #category : #test }
CoroutineTest >> testStatement [

	"test given with the problem statement"

	| res a b c |
	a := b := c := 0.
	res := OrderedCollection new.
	a := self coroutineOn: [ :resume :useless | 
		     res add: 'This is A'.
		     res add: 'Came from ' , (resume value: b value: 'A').
		     res add: 'Back in A'.
		     res add: 'Came from ' , (resume value: c value: 'A') ].
	b := self coroutineOn: [ :resume :useless | 
		     res add: '       This is B'.
		     res add: '       Came from ' , (resume value: c value: 'B').
		     res add: '       Back in B'.
		     res add: '       Came from ' , (resume value: a value: 'B') ].
	c := self coroutineOn: [ :resume :useless | 
		     res add: '           This is C'.
		     res add: '           Came from ' , (resume value: a value: 'C').
		     res add: '           Back in C'.
		     res add: '           Came from ' , (resume value: b value: 'C') ].
	a value.
	res := res joinUsing: Character cr asString.

	self assert: res equals: 'This is A
       This is B
           This is C
Came from C
Back in A
           Came from A
           Back in C
       Came from C
       Back in B
Came from B'
]

{ #category : #test }
CoroutineTest >> testSumOneToN [

	"use coroutines to get  the summation on 1 to n"

	| sum |
	sum := nil.
	sum := self coroutineOn: [ :resume :value | 
		       | x v |
		       v := value.
		       x := 0.
		       [ v > 0 ] whileTrue: [ 
			       x := x + v.
			       v := resume value: sum value: v - 1 ].
		       x ].

	self assert: (sum value: 10) equals: (1 to: 10) sum.
	self assert: (sum value: 4) equals: (1 to: 4) sum.
	self assert: (sum value: 3) equals: (1 to: 3) sum
]

{ #category : #test }
CoroutineTest >> testTheForce [

	"join an array of words to get Yoda's famous quote"

	| res a b c words |
	a := b := c := nil.
	res := OrderedCollection new.
	words := OrderedCollection withAll:
		         #( 'fear' 'anger' 'hate' 'suffering' ).
	a := self coroutineOn: [ :resume :useless | 
		     [ words size > 1 ] whileTrue: [ 
			     res
				     add: (resume value: c value: words first);
				     add: Character cr asString ] ].
	b := self coroutineOn: [ :resume :useless | 
		     [ res add: (resume value: a value: words first) ] repeat ].
	c := self coroutineOn: [ :resume :value | 
		     res
			     add: value;
			     add: ' leads to '.
		     [ 
		     words removeFirst.
		     res add: (resume value: b value: ' leads to ') ] repeat ].

	a value.

	res := res joinUsing: ''.

	self assert: res equals: 'fear leads to anger
anger leads to hate
hate leads to suffering
'
]

{ #category : #tests }
CoroutineTest >> testYieldInterval [

	| co1to10 main values |
	values := OrderedCollection new.

	main := nil.

	co1to10 := self coroutineOn: [ :resume :useless | 
		           1 to: 10 do: [ :each | resume value: main value: each ] ].

	main := self coroutineOn: [ :resume :value | 
		        | a b c |
		        values add: value.
		        a := resume value: co1to10 value: nil.
		        values add: value.
		        b := resume value: co1to10 value: nil.
		        values add: value.
		        c := resume value: co1to10 value: nil.
		        values
			        add: value;
			        add: a;
			        add: b;
			        add: c ].

	main value: nil.

	self assert: values asArray equals: #( nil nil nil nil 1 2 3 )
]

{ #category : #tests }
CoroutineTest >> testYieldManyTimesWhenExhausted [

	| co main values |
	values := OrderedCollection new.

	main := nil.

	co := self coroutineOn: [ :resume :value | 
		      resume value: main value: 1 ].

	main := self coroutineOn: [ :resume :value | 
		        values
			        add: (resume value: co value: 1);
			        add: (resume value: co value: 2);
			        add: (resume value: co value: 3);
			        add: (resume value: co value: 4) ].

	main value: nil.

	self assert: values asArray equals: #( 1 2 1 4 )
]

{ #category : #tests }
CoroutineTest >> testYieldResume [

	| co main values answer return greet reply final f |
	greet := 'Hi!'.
	reply := #( 4 5 ).
	answer := 42.
	return := #( 6 7 ).
	final := #( 8 9 ).
	values := OrderedCollection new.

	main := nil.

	co := self coroutineOn: [ :resume :value | 
		      values
			      add: value;
			      add: (resume value: main value: answer).
		      return ].

	main := self coroutineOn: [ :resume :value | 
		        | v w |
		        v := resume value: co value: greet.
		        self assert: v equals: answer.
		        w := resume value: co value: reply.
		        self assert: w equals: return.
		        final ].

	f := main value: nil.

	self
		assert: values asArray equals: { 
				greet.
				reply };
		assert: f equals: final
]

{ #category : #tests }
CoroutineTest >> testYieldResumeWithoutReturning [

	| co main values |
	values := OrderedCollection new.

	main := nil.

	co := self coroutineOn: [ :resume :value | 
		      values
			      add: value;
			      add: (resume value: main value: 42) ].

	main := self coroutineOn: [ :resume :value | 
		        | v |
		        v := resume value: co value: 'Hi!'.
		        self assert: v equals: 42 ].

	main value: nil.

	self assert: values asArray equals: #( 'Hi!' )
]

{ #category : #utilities }
CoroutineTest >> try: tryBlock otherwise: otherwiseBlock [

	^ Coroutine try: tryBlock otherwise: otherwiseBlock
]
