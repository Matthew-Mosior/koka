/*---------------------------------------------------------------------------
  Copyright 2012-2021, Microsoft Research, Daan Leijen.

  This is free software; you can redistribute it and/or modify it under the
  terms of the Apache License, Version 2.0. A copy of the License can be
  found in the LICENSE file at the root of this distribution.
---------------------------------------------------------------------------*/
 
// 64-bit signed integers.
//
// Using 64-bit signed two's complement representation 
// with wrapping on overflow, e.g. `max-int64 + 1.int64 == min-int64`
module std/num/int64

// The maximal integer value before overflow happens
pub val max-int64 : int64 =  0x7FFF_FFFF_FFFF_FFFF.int64

// The minimal integer value before underflow happens
pub val min-int64 : int64 = -0x8000_0000_0000_0000.int64

// The number of bits in an `:int64` (always 64)
pub val bits-int64 : int64 = 64.int64

// Convert an `:int64` to a string
pub fun show( i : int64 ) : string 
  show(i.int)


// Convert an `:int64` to a boolean.
pub fun bool( i : int64 ) : bool 
  (i!=zero)


// Convert a boolean to an `:int64`.
pub fun int64( b : bool ) : int64 
  if b then one else zero

// Convert an `:int32` to an `:int64` (using sign extension).
pub inline extern int64( i : int32 ) : int64
  c inline "(int64_t)(#1)"
  js "$std_core._int64_from_int32"  

// Convert an `:int32` to an `:int64` interpreting the `:int32` as unsigned.
pub inline extern uint64( i : int32 ) : int64
  c inline "(int64_t)((uint32_t)(#1))"
  js "$std_core._int64_from_uint32"  

// Clamp an `:int64` to an `:int32`
// `-1.int64.int32 == -1.int32`  
// `0x8000_0000.int64.int32 == 0x7FFF_FFFF.int32` (clamped)
pub inline extern int32( i : int64 ) : int32
  c  "kk_int64_clamp_int32"
  js "$std_core._int64_clamp_int32"

// Clamp an `:int64` to an `:int32` but interpreting the `:int32` as unsigned
// (and thus clamp between 0 and 0xFFFFFFFF).
// `-1.int64.uint32 == 0.int32` (clamped)  
// `0xFFFFFFFF.int64.uint32 == -1.int32`
pub inline extern uint32( i : int64 ) : int32
  c  "kk_int64_clamp_uint32"
  js "$std_core._int64_clamp_uint32"

// Create an `:int64` `i` from the bits of `lo` and `hi` such
// that `i.int = hi.int * 0x1_0000_0000 + lo.uint`.
pub fun int64( lo : int32, hi : int32 ) : int64 
  hi.int64.shl(32).or(lo.uint64)
  
// Convert an `:int` to `:int64` but interpret the `int` as an unsigned 64-bit value.
// `i` is clamped between `0` and `0xFFFF_FFFF_FFFF_FFFF`.\
// `0x7FFF_FFFF_FFFF_FFFF.uint64 == 0x7FFF_FFFF_FFFF_FFFF.int64 == max-int64`\
// `0x8000_0000_0000_0000.uint64 == -0x8000_0000_0000_0000.int64 == min-int64`\
// `0xFFFF_FFFF_FFFF_FFFF.uint64 == -1.int64`\
pub fun uint64( i : int ) : int64 
  if i > max-int64.int then (i - 0x1_0000_0000_0000_0000).int64 else i.int64


// Convert an `:int64` to an `:int` but interpret the `:int64` as a 64-bit unsigned value.
pub fun uint( i : int64 ) : int 
  if i.is-neg then 0x1_0000_0000_0000_0000 + i.int else i.int


// Show an `:int64` in hexadecimal notation
// The `width`  parameter specifies how wide the hex value is where `'0'`  is used to align.\
// The `use-capitals` parameter (= `True`) determines if captical letters should be used to display the hexadecimal digits.\
// The `pre` (=`"0x"`) is an optional prefix for the number (goes between the sign and the number).
pub fun show-hex( i : int64, width : int = 1, use-capitals : bool = True, pre : string = "0x" ) : string 
  std/core/show-hex(i.int,width,use-capitals,pre)

// Show an `:int64` in hexadecimal notation interpreted as an unsigned 64-bit value.
// The `width`  parameter specifies how wide the hex value is where `'0'`  is used to align.\
// The `use-capitals` parameter (= `True`) determines if captical letters should be used to display the hexadecimal digits.\
// The `pre` (=`"0x"`) is an optional prefix for the number.
pub fun show-hex64( i : int64, width : int = 16, use-capitals : bool = True, pre : string = "0x" ) : string 
  std/core/show-hex(i.uint,width,use-capitals,pre)


pub inline extern (<=) : (int64,int64) -> bool  { inline "(#1 <= #2)" }
pub inline extern (==) : (int64,int64) -> bool  { inline "(#1 == #2)"; js inline "(#1 === #2)" }
pub inline extern (!=) : (int64,int64) -> bool  { inline "(#1 != #2)"; js inline "(#1 !== #2)" }
pub inline extern (>=) : (int64,int64) -> bool  { inline "(#1 >= #2)" }
pub inline extern (<)  : (int64,int64) -> bool  { inline "(#1 < #2)"  }
pub inline extern (>)  : (int64,int64) -> bool  { inline "(#1 > #2)"  }

pub inline extern (+)  : (int64,int64) -> int64 
  c inline "(int64_t)((uint64_t)#1 + (uint64_t)#2)"  
  js inline "BigInt.asIntN(64,#1 + #2)" 


pub inline extern (-)  : (int64,int64) -> int64 
  inline "(int64_t)((uint64_t)#1 - (uint64_t)#2)"
  js inline "BigInt.asIntN(64,#1 - #2)" 


pub inline extern is-neg( i : int64 ) : bool 
  inline "0 > #1"
  js inline "0n > #1"


pub inline extern is-pos( i : int64 ) : bool 
  inline "0 < #1"
  js inline "0n < #1"


pub inline extern is-zero( i : int64 ) : bool 
  inline "0 == #1"
  js inline "0n === #1"


pub val zero = 0.int64
pub val one  = 1.int64

pub fun sign( i : int64 ) : order 
  if i.is-pos then Gt 
  elif i.is-neg then Lt 
  else Eq


// Returns `true` if the integer `i`  is an odd number.
pub fun is-odd( i : int64 ) : bool 
  and(i,one)==one


// Returns `true` if the integer `i`  is an even number.
pub fun is-even( i : int64 ) : bool 
  and(i,one)==zero


// Increment a 64-bit integer.
pub fun inc( i : int64 ) : int64 
  i + 1.int64


// Decrement a 64-bit integer.
pub fun dec( i : int64 ) : int64 
  i - 1.int64


// Multiply two 64-bit integers.
pub inline extern (*) : (int64,int64) -> int64 
  c inline "(int64_t)((uint64_t)#1 * (uint64_t)#2)";
  js inline "BigInt.asIntN(64,#1 * #2)"


pub fun compare( x : int64, y : int64) : order 
  if x < y then Lt
  elif x > y then Gt
  else Eq


// Return the absolute value of an integer.
// Raises an exception if the `:int64` is `min-int64`
// (since the negation of `min-int64` equals itself and is still negative)
pub fun abs( i : int64 ) : exn int64 
  if !i.is-neg then i
  elif i > min-int64 then negate(i)
  else throw( "std/num/int64/abs: cannot make min-int64 into a positive int64 without overflow" )


// Return the absolute value of an integer.
// Returns 0 if the `:int64` is `min-int64`
// (since the negation of `min-int64` equals itself and is still negative)
pub fun abs0( i : int64 ) : int64 
  if !i.is-neg then i
  elif i > min-int64 then negate(i)
  else 0.int64



// Take the bitwise _and_ of two `:int64`s
pub inline extern and : (int64,int64) -> int64 
  inline "#1 & #2"

// Take the bitwise _or_ of two `:int64`s
pub inline extern or : (int64,int64) -> int64 
  inline "#1 | #2"

// Take the bitwise _xor_ of two `:int64`s
pub inline extern xor : (int64,int64) -> int64 
  inline "#1 ^ #2";

// Take the bitwise _xor_ of two `:int64`s
pub fun(^)( x : int64, y : int64) : int64 
  xor(x,y)

// Bitwise _not_ of an `:int64`, i.e. flips all bits.
pub inline extern not : ( i : int64 ) -> int64  
  inline "~#1"
  js inline "BigInt.asIntN(64, ~#1)"


// Shift an `:int64` `i` to the left by `n % 64` bits.
inline extern shl64 : (int64,int64) -> int64 
  c inline "kk_shl64(#1,#2)"
  js "$std_core._int64_shl"

// Shift an `:int64` `i` to the left by `n % 64` bits.
pub fun shl( i : int64, shift : int) : int64
  shl64(i,shift.int64)

// Logical shift an `:int64` to the right by `n % 64` bits. Shift in zeros from the left.
inline extern shr64 : (int64,int64) -> int64 
  c inline "(int64_t)kk_shr64(#1,#2)"
  cs inline "(int64)(((Uint64)#1)>>#2)"
  js "$std_core._int64_shr"

// Logical shift an `:int64` to the right by `n % 64` bits. Shift in zeros from the left.
pub fun shr( i : int64, shift : int) : int64
  shr64(i,shift.int64)


// Arithmetic shift an `:int64` to the right by `n % 64` bits. Preserves the sign bit.
inline extern sar64 : (int64,int64) -> int64 
  c inline "kk_sar64(#1,#2)"
  js "$std_core._int64_sar"

// Arithmetic shift an `:int64` to the right by `n % 64` bits. Shift in the sign bit from the left.
pub fun sar( i : int64, shift : int) : int64
  sar64(i,shift.int64)

// Bitwise rotate an `:int64` `n % 64` bits to the left.
inline extern rotl64( i : int64, n : int64 ) : int64 
  c inline "(int64_t)kk_bits_rotl64(#1,#2)"
  js "$std_core._int64_rotl"

// Bitwise rotate an `:int64` `n % 64` bits to the left.
pub fun rotl( i : int64, shift : int) : int64
  rotl64(i,shift.int64)

// Bitwise rotate an `:int64` `n % 64` bits to the right.
inline extern rotr64( i : int64, n : int64 ) : int64 
  c inline "(int64_t)kk_bits_rotr64(#1,#2)"
  js "$std_core._int64_rotr"

// Bitwise rotate an `:int64` `n % 64` bits to the right.
pub fun rotr( i : int64, shift : int) : int64
  rotr64(i,shift.int64)


// Return the minimum of two integers
pub fun min( i : int64, j : int64 ) : int64 
  if i <= j then i else j 

// Return the maximum of two integers
pub fun max( i : int64, j : int64 ) : int64 
  if i >= j then i else j 


// Truncated division (as in C). See also `(/):(x : int64, y : int64) -> int64`.
pub fun cdiv(i:int64, j:int64) : exn int64 
  if j.is-zero then throw("std/num/int64/cdiv: division by zero")
  elif j == -1.int64 && i==min-int64 then throw("std/num/int64/cdiv: division overflow in cdiv(min-int64, -1.int64)")
  else unsafe-cdiv(i,j)


// Truncated modulus (as in C). See also `(%):(x : int64, y : int64) -> int64`.
pub fun cmod(i:int64, j:int64) : exn int64 
  if j.is-zero then throw("std/num/int64/cmod: modulus by zero")
  elif j == -1.int64 && i==min-int64 then throw("std/num/int64/cmod: modulus overflow in cmod(min-int64, -1.int64)")
  else unsafe-cmod(i,j)


// Truncated division (as in C). See also `(/):(x : int64, y : int64) -> int64`.
inline extern unsafe-cdiv : (int64,int64) -> int64 
  inline "#1 / #2"


// Truncated modulus (as in C). See also `(%):(x : int64, y : int64) -> int64`.
inline extern unsafe-cmod : (int64,int64) -> int64 
  inline "#1 % #2"


// Convert an 64-bit integer to a `:float64`.
pub fun float64( i : int64 ) : float64 
  i.int.float64


// Negate a 64-bit integer
pub fun negate( i : int64 ) : int64 
  0.int64 - i


// Negate an 64-bit integer
pub fun (~)(i : int64) : total int64 
  0.int64 - i


/* 
Euclidean-0 division.
Euclidean division is defined as: For any `D`  and `d`  where `d!=0` , we have:

1. `D == d*(D/d) + (D%d)`
2. `D%d`  is always positive where `0 <= D%d < abs(d)`

Moreover, Euclidean-0 is a total function, for the case where `d==0`  we have
that `D%0 == D`  and `D/0 == 0` . So property (1) still holds, but not property (2).
Useful laws that hold for Euclidean-0 division:

* `D/(-d) == -(D/d)`
* `D%(-d) == D%d`
* `D/(2^n) == sar(D,n)         `  (with `0 <= n <= 31`)
* `D%(2^n) == D & ((2^n) - 1)  `  (with `0 <= n <= 31`)

Note that an interesting edge case is `min-int64 / -1` which equals `min-int64` since in modulo 64-bit
arithmetic `min-int64 == -1 * min-int64 == -1 * (min-int64 / -1) + (min-int64 % -1)` satisfying property (1).
Of course `(min-int64 + 1) / -1` is again positive (namely `max-int64`).

See also _Division and modulus for computer scientists, Daan Leijen, 2001_ 
[pdf](http://research.microsoft.com/pubs/151917/divmodnote.pdf) .
*/
pub fun (/)( x : int64, y : int64 ) : int64
  if y == 0.int64 return 0.int64
  if y == -1.int64 && x==min-int64 return x
  val q = unsafe-cdiv(x,y)
  val r = unsafe-cmod(x,y)
  if r >= 0.int64 then q
  elif y > 0.int64 then q.dec
  else q.inc


// Euclidean-0 modulus. See `(/):(x : int64, y : int64) -> int64` division for more information.
pub fun (%)( x : int64, y : int64 ) : int64
  if y == 0.int64 return x
  if y == -1.int64 && x==min-int64 return 0.int64
  val r = unsafe-cmod(x,y)
  if r >= 0.int64 then r
  elif y > 0.int64 then r + y
  else r - y

pub fun divmod( x :int64, y :int64 ) : (int64,int64) 
  if y.is-zero return (zero,x)
  if y == -1.int64 && x==min-int64 return (x,0.int64)
  val q = unsafe-cdiv(x,y)
  val r = unsafe-cmod(x,y)
  if r >= 0.int64 then (q, r)
  elif y > 0.int64 then (q.dec, r + y)
  else (q.inc, r - y)


pub fun fold-int64( start : int64, end : int64, init : a, f : (int64,a) -> e a ) : e a 
  if start >= end then init else
    val x = f(start,init)
    fold-int64(unsafe-decreasing(start.inc), end, x, f)
