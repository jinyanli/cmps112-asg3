#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f
"$Id: sortedcollection.st,v 1.3 2012-03-07 14:40:03-08 - - $"

nl := Character nl.
Object subclass: Name [
nl := Character nl.
   |first last|
   first [^ first]
   last [^ last]
   Name class >> new [self shouldNotImplement]

   Name class >> new: last first: first [
      |result|
      result := super new.
      result setFirst: first setLast: last.
      ^ result.
   ]

   setFirst: myFirst setLast: myLast [
      first := myFirst.
      last := myLast.
   ]

   <= other [
     "stdout <<'log: ' <<'last: '<< last 
            <<' other last: ' << other last <<' other: '<< other <<nl."
      last = other last
         ifTrue: [^ first <= other first]
         ifFalse: [^ last <= other last].
   ]

   printOn: aStream [
      ^ aStream << last << ', ' << first.
   ]
]

sortcol := SortedCollection new.
"
sortcol add: (Name new: 11 first: 'J').
sortcol add: (Name new: 12 first: 'b').
sortcol add: (Name new: 1 first: 'M').
sortcol add: (Name new: 5 first: 'h').
sortcol add: (Name new: 3 first: 'n').
sortcol add: (Name new: 'Ada' first: 'Jackon').
sortcol add: (Name new: 'Bob' first: 'kim').
sortcol add: (Name new: 'Smith' first: 'Jane').
sortcol add: (Name new: 'David' first: 'Beckham')."


sortcol do: [:item| stdout << item << nl.].

sortnode := SortedCollection new.

Object subclass: Node [
nl := Character nl.
   |count char|
   count [^ count]
   char  [^ char]
   Node class >> new [self shouldNotImplement]

   Node class >> new: count char: char [
      |result|
      result := super new.
      result setChar: char setCount: count.
      ^ result.
   ]

   setChar: myChar setCount: myCount [
      char := myChar.
      count := myCount.
   ]

   <= other [
         count = other count
         ifTrue: [^ char <= other char]
         ifFalse: [^ count <= other count].
   ]

   printOn: aStream [
      ^ aStream << count << ': ' << char.
   ]
]

sortnode add: (Node new: 12  char: 'a').
sortnode add: (Node new: 12  char: 'v').
sortnode add: (Node new: 11  char: 'c').
sortnode add: (Node new: 2   char:  'd').
sortnode add: (Node new: 153 char: 't').
sortnode add: (Node new: 345 char: 's').
sortnode add: (Node new: 345 char: ' ').
sortnode add: (Node new:  4   char: 'q').
sortnode add: (Node new:  35   char: '&').




sortnode do: [:item| stdout << item << nl.].


"TEST: sortedcollection.st"
