#!/afs/cats.ucsc.edu/courses/cmps112-wm/usr/smalltalk/bin/gst -f
"Jinyan Li jli134 cmps112 asg3"

execname := '$RCSfile: cmdline.st,v $' =~ '.*: (.*),v.*' at: 1.
nl := Character nl.
queue := SortedCollection new.

|decodingtree ExitStatus|


"add helper methods for FileStream class"
FileStream extend [
   nl := Character nl.
   catFile [
      |count textline|
      count := 0.
      [self atEnd not] whileTrue: [
         count := count + 1.
         textline :=self nextLine.
         count asString size to: 5 do: [:skip| stdout << ' '].
         
         stdout << count << ': ' << textline << nl.
      ]
   ]
]

"extend methods for Character class"
Character extend [
   isPrint [
      ^ (Character space < self) & (self <= $~)
   ]
   length[
         ^ (self asInteger) > 15
         ]
   visible [
 
      self isPrint ifTrue: [^' ', self asString, ' ']             
                   ifFalse: [ self length
                      ifTrue:[((self asInteger) = 256)
                              ifTrue:[ ^ 'EOF']ifFalse:[^ 'x',
                              ((self asInteger printStringRadix: 16)
                               copyFrom: 4 )]
                             ]
                      ifFalse:[
                             
                             ^ 'x0',
                              ((self asInteger printStringRadix: 16)
                               copyFrom: 4)]
                     ]           
   ]
]

"zeroArray class is for storing data"
Object subclass: ZeroArray [
   |theArray|

   ZeroArray class >> new [
      self shouldNotImplement.
   ]

   ZeroArray class >> new: size [
      |result|
      result := super new.
      result init: size.
      ^ result
   ]

   init: size [
      theArray := Array new: size.
   ]

   size [
      ^ theArray size.
   ]

   at: index [
      ^ theArray at: index + 1.
   ]

   at: index put: value [
      ^ theArray at: index + 1 put: value.
   ]

   incr: index [
      (self at: index) isNil
         ifTrue: [ self at: index put: 0].
      self at: index put: (self at: index) + 1.
   ]

   keysAndValuesDo: aBlock [
      (0 to: (self size) - 1) do: [:index |
         aBlock value: index value: (self at: index).
      ]
   ]
]


"leaf class to hold a character and its
frequency"
Object subclass: Leaf [
   |char count isleaf|
   
   char [ ^ char ]
   count [ ^ count ]
   isleaf [^ isleaf]
   
   Leaf class >> new [
      self shouldNotImplement
   ]

   Leaf class >> new: aChar count: aCount [
      |result|
      result := super new.
      result setChar: aChar andCount: aCount.      
      ^result
   ]

   setChar: aChar andCount: aCount [
      char := aChar.
      count := aCount.
      isleaf:=true.
   ]

   <= other [
      ^ (count < other count)
      | ((count = other count) & (char <= other char))
   ]

   printBase: aStream [
      ^ aStream << self class << '(' << char << ',' << count
   ]

   printOn: aStream [
      (self printBase: aStream) << ')'.
   ]

   inorder: visitor prefix: string [
      visitor value: char value: string.
   ]
   
   postorder: visitor [
      visitor  value:char value: isleaf.
   ]
]

"tree class to hold leaves"
Leaf subclass: Tree [
   |left right|

   Tree class >> new: aChar count: aCount [
      self shouldNotImplement
   ]

   Tree class >> new: aChar count: aCount left: aLeft right: aRight [
      |result|
      result := super new: aChar count: aCount.
      result setLeft: aLeft andRight: aRight.
      ^ result
   ]

   setLeft: aLeft andRight: aRight [
      left := aLeft.
      right := aRight.
      isleaf:=false.
   ]

   left  [ ^ left]
   right [ ^ right]

   printOn: aStream [
      (self printBase: aStream) << ',' << left << ',' << right << ')'.
   ]

   inorder: visitor prefix: string [
      left inorder: visitor prefix: string, '0'.
      right inorder: visitor prefix: string, '1'.
   ]
   
   postorder: visitor[      
      left postorder: visitor .
      right postorder: visitor .  
      visitor value: char value:isleaf.
   ]
]

"OutBits class is for writing bits to output file"
Object subclass: OutBits [
   |bitIndex currentByte myStream|
   OutBits class >> new [
      self shouldNotImplement.
   ]
   OutBits class >> new: fileStream [
      |result|
      result := super new.
      result init: fileStream.
      ^result
   ]
   clearByte [
      bitIndex := 8.
      currentByte := 0.
   ]
   init: fileStream [
      myStream := fileStream.
      self clearByte.
   ]
   flushByte [
         myStream nextPutByte: currentByte.
         self clearByte.

   ]
   writeBit: bit [
      currentByte := currentByte bitAt: bitIndex put: bit.
      bitIndex := bitIndex - 1.
      bitIndex = 0 ifTrue: [
        self flushByte].
   ]
]

"BitStream class is for reading bits from input file"
Object subclass: BitStream [
   |bitIndex byte myStream|
   BitStream class >> new: fileStream [
      |result|
      result := super new.
      result init: fileStream.
      ^result
   ]
   init: fileStream [
      myStream := fileStream.
      bitIndex := 1.
   ]
   nextBit [
      bitIndex = 1 ifTrue: [
         byte := myStream next.
         bitIndex := 9.
      ].
      bitIndex := bitIndex - 1.
      ^byte value bitAt: bitIndex
   ]
   atEnd [
      ^bitIndex = 1 and: [myStream atEnd]
   ]
]

"--------below is the main function----------"

"variable to hold file stream"
|infile infile2 outfile|

dFlag := false.
cFlag := false.
tFlag := false.
uFlag := false.

argcount:=0.

"check the options and 
 crete file stream"Smalltalk arguments: '-d -t -c -u'
do: [:opt :arg |
   
   (opt = $d) ifTrue: [
   dFlag := true.].
    
   (opt = $t) ifTrue: [
   tFlag := true.].

  (opt = $c) ifTrue: [
   cFlag := true.].

  (opt = $u) ifTrue: [
    uFlag := true.].
  
  (arg ~= nil) ifTrue: [
    
     argcount = 0 
        ifTrue:[

          dFlag ifTrue:[
          stdout <<'input filename: ' << arg <<nl.].
             
          infile := FileStream open: arg
                    mode: FileStream read.
          infile2 := FileStream open: arg
                    mode: FileStream read.
          
         ]
        ifFalse:[
           dFlag ifTrue:[
           stdout <<'output filename: ' << arg <<nl.].
            outfile := FileStream open: arg
                       mode: FileStream write.].
  
     argcount := argcount + 1.
   ].
].

freqtable := ZeroArray new: 257.
encodetable := ZeroArray new: 257.
freqtable at:256 put:1.

uFlag ifFalse:[

"build frequency table"
[infile atEnd not] whileTrue: [
   |ordChar|
   ordChar := infile next asInteger.
   freqtable incr: ordChar.
].

freqtable keysAndValuesDo: [:key :count |
   (count notNil and: [count > 0]) ifTrue: [
      queue add: (Leaf new: key count: count).
   ]
].


"bulid decoding tree"
[queue size >1 ] whileTrue: [
   |leftchild rightchild|
   
   leftchild := queue removeFirst.
   rightchild := queue removeFirst.
   newtree := ( Tree new: (leftchild char)
                     count: (leftchild count) + (rightchild count)
                     left: leftchild
                     right: rightchild).
   queue add: newtree.
].
decodingtree:=queue removeFirst.

"build encoding table"
decodingtree inorder: [:char :string |
   encodetable at: char put: string.
] prefix: ''.

"convert decoding tree into binary"
binarytree:=''.
decodingtree postorder: [:char :isleaf |

   isleaf  ifFalse:[binarytree:=binarytree,'1'.]
                ifTrue:[
                   binstring:=''.
                   char = 256
                        ifTrue:[binstring:='000000001']
                        ifFalse:[
                           char=0 ifTrue:[binstring:='000000000']
                               ifFalse:[
                                8 to:1 by: -1 do:[:i|
                                  binstring:=binstring,
                                     ((char bitAt:i) printString).
                                   ]
                        ].               
                 ].
                 binarytree:=(binarytree,'0',binstring).
              ].
].

"prints decoding tree and encoding table to stdout"
tFlag ifTrue:[
     stdout <<nl<< '------------decoding tree--------------' << nl
            << decodingtree << nl<<nl
            <<'binary decoding tree: '<<nl<<binarytree << nl.

     stdout <<nl<< '------------encoding table-------------' << nl.
     encodetable keysAndValuesDo: [:key :count |
     (count notNil and: [count > 0]) ifTrue: [
        stdout <<  key asCharacter visible << '     '
               << (freqtable at: key) <<'    '<<count
               << nl.
     ].
    ].
].


"when -c option is set performs compression"
cFlag  ifTrue:[ 

outfile~=nil ifTrue:[
   
    dFlag ifTrue: [
    stdout <<nl<< 'cFlag = '<<cFlag 
          <<'  output file = true'<< nl.].

   "write binary decoding tree to output file"   
   outBytes := OutBits new: outfile.    
   1 to: (binarytree size) by: 1 do: [:index |
         bit:= ((binarytree at: index) asInteger) - 48.
         outBytes writeBit: bit.
         ].

   "at the end add 1 bit for checking 
      whether the tree is completed"  
   outBytes writeBit: 1.

   "output encoded data" 
   [infile2 atEnd not] whileTrue: [
      |ordChar|
       ordChar := infile2 next asInteger.
       code:= (encodetable at: ordChar). 
       1 to: (code size) by: 1 do: [:index |
         bit:= ((code at: index) asInteger) - 48.
         outBytes writeBit: bit.
          ].
       ].

   "output eof at the end"
   eof:= (encodetable at: 256).
   1 to: (eof size) by: 1 do: [:index |
         bit:= ((eof at: index) asInteger) - 48.
         outBytes writeBit: bit.].     

   "pad the output"
   outBytes flushByte.
]
ifFalse:[
   dFlag ifTrue:[
   stdout <<nl<< 'cFlag = '<<cFlag
              <<' without output file'<< nl.].
    
   stdout <<nl<< '----------encoded data----------' << nl.

    "add at the end 1 bit for checking 
      whether the tree is completed"
   stdout <<binarytree<<1.      
    
     [infile2 atEnd not] whileTrue: [
           |ordChar2|
           ordChar2 := infile2 next asInteger.
           code:= (encodetable at: ordChar2).
           stdout <<code. 
        ].
      eof:= (encodetable at: 256).
      stdout<<eof.
   ].    
 ].
].


"code for decompression and -u is set"
(uFlag) ifTrue:[
   |iseof outBytes stack|
   iseof:=false.

   dFlag ifTrue: [
   stdout<<'doing decompression'<<nl.].

   outBytes := OutBits new: outfile.  
   stack := OrderedCollection new.
   fileBits := BitStream new: infile.
   treebuilt:=false.
   reconstructedTree:=''.
   node:=''.   
   
   "read each bit from the input file"
   [(fileBits atEnd not) & (iseof not)] whileTrue: [

     treenode:=fileBits nextBit.
     leafchar:=0.

     "if the decoding tree is still constructing"
     treebuilt ifFalse:[

        "convert the input code into a leaf"        
        treenode=0 ifTrue:[

           8 to:1 by:-1 do:[:i|
              bit:=fileBits nextBit.
              
            leafchar:=leafchar bitAt:i put:bit.                        
           ].

           leafchar=0 ifTrue:[
             specialbit:=fileBits nextBit.
             specialbit=1 ifTrue:[
              leafchar:=leafchar bitAt:9 put:1.
             ].
           ].
         
          stack add: (Leaf new: leafchar count: '').

        ].

        "build a tree from two leaf" 
        treenode=1 ifTrue:[
                 
           stack size>1 ifTrue:[
           rightchild:=stack removeLast.
           leftchild:=stack removeLast.
           
           newtree := (Tree new: -1
                      count: ''
                      left: leftchild right: rightchild).
             stack add: newtree.
           ] ifFalse:[
             treebuilt:=true.
             
             reconstructedTree:=stack removeLast.
             node:=reconstructedTree.
     
            "outfile=nil ifTrue:[
            stdout<<nl<<
                '---------decoded output-----------'<<nl<<nl.]."
 
           ].
        ].
     ]
     ifTrue:["<-- when the tree is reconstructed
                                   decode the compressed data"
        
       node isleaf ifTrue:[
                ((node char)=256) ifTrue:[
                    iseof:=true.
                    ] ifFalse:[
                     stdout nextPut: (Character value: (node char)).
                  node:=reconstructedTree.].
               ]ifFalse:[
        treenode=0 ifTrue:[
                
                node:=node left.

                node isleaf ifTrue:[
                iseof not ifTrue:[  
                    ((node char)=256) ifTrue:[
                    iseof:=true.


                    ] ifFalse:[

                     outfile=nil ifTrue:[

                     stdout nextPut: (Character value: (node char)).
                     "stdout<<(node char) asCharacter."]
                     ifFalse:[
                        8 to: 1 by: -1 do: [:index |
                           bit:= (node char) bitAt: index.
                           outBytes writeBit: bit.
                        ].
                     ].
                     node:=reconstructedTree.

                    ].
                ].
               ]
           ] ifFalse:[
               
               node:=node right.

               node isleaf ifTrue:[
                iseof not ifTrue:[
                    ((node char)=256) ifTrue:[
                    iseof:=true.

                    ] ifFalse:[

                     outfile=nil ifTrue:[

                     stdout nextPut: (Character value: (node char)).
                     "stdout<<(node char) asCharacter."]
                     ifFalse:[
                        8 to: 1 by: -1 do: [:index |
                           bit:= (node char) bitAt: index.
                           outBytes writeBit: bit.
                        ].
                     ].
                    node:=reconstructedTree.

                    ].
                ].
               ]
           ].
       ].
     ].
   ].
].  


infile close.
outfile~=nil ifTrue:[
outfile close.
].
ExitStatus:=0.
dFlag ifTrue: [
stdout<<nl<<'Exit Status: '<<ExitStatus<<nl.
stdout<<'Finished '<<nl.
].
