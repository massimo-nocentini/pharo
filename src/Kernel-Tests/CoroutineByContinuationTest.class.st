Class {
	#name : #CoroutineByContinuationTest,
	#superclass : #CoroutineTest,
	#category : #'Kernel-Tests-Methods'
}

{ #category : #test }
CoroutineByContinuationTest >> coroutineOn: aBlock [

	^ CoroutineByContinuation on: aBlock
]

{ #category : #tests }
CoroutineByContinuationTest >> expected_testProduct [

	^ 10 factorial
]

{ #category : #tests }
CoroutineByContinuationTest >> expected_testYieldManyTimesWhenExhausted [

	^ #( 1 2 1 3 1 4 1 )
]

{ #category : #tests }
CoroutineByContinuationTest >> expected_testYieldResume [

	^ #( 'Hi!' #( 4 5 ) #( 4 5 ) butLast butLast last last )
]

{ #category : #'expected values' }
CoroutineByContinuationTest >> expected_testYieldResumeInner [

	^ #( #( 6 7 ) #( 6 7 ) #( 6 7 ) 42 )
]
