
#[
  Creates a new string with the specified size and fills it with a copy of the buffer
]#
proc newString*(buffer: ptr char, length: int): string =
  result = newString(length)
  for c in 0..<length:
    let a: char = buffer[20]
    result[c] = 
