                .text

                .extern _months

                ; Will get the month name from a global character array in
                ; program memory called _months.
                ;
                ; w0 contains the month index
                ; w1 contains the pointer to the character array to receive
                ;    the month name.
                ;
                ; w2:w3 is used as a pointer into program memory.
                ; w4 is used for reading bytes from the global _months.

                .global _GetMonthName
_GetMonthName:

                ; Set up w2:w3 to point to the first byte of _months.
                mov             #tblpage(_months), w3
                mov             #tbloffset(_months), w2
        
                ; If the month index passed in w0 is equal to 0, then
                ; branch to read_bytes.  We have found the location
                ; of the data to read.
                cp0             w0
                bra             Z, read_bytes

                ; Each month in the _months character array is separated
                ; by a \0.  Read each byte and check to see if it is a \0.
                ; If it is, decrement w0.  When w0 reaches 0, we have found
                ; the month to return.
not_found:
                mov             w3, _TBLPAG
                tblrdl.b        [w2], w4

                ; Increment the pointer by 1.  We do this as an add/addc in
                ; order to increment the 32-bit pointer.
                add             #1, w2
                addc            #0, w3

                ; Check to see if the \0 character was the character read.
                ; If not, keep looking; otherwise decrement w0.
                cp0.b           w4
                bra             NZ, not_found

                ; A \0 was found, decrement w0.  If w0 is 0, we have found the
                ; month requested; otherwise, keep reading.
                dec             w0, w0
                bra             NZ, not_found

                ; This loop will read bytes from program memory into the character
                ; array passed via w1.
read_bytes:
                ; Read a byte from program memory.
                mov             w3, _TBLPAG
                tblrdl.b        [w2], [w1]

                ; Increment the pointer by 1.  We do this as an add/addc in
                ; order to increment the 32-bit pointer.
                add             #1, w2
                addc            #0, w3

                ; Check to see if the last character read was a \0.  If so, we
                ; are done; otherwise, keep reading bytes.
                cp0.b           [w1++]
                bra             NZ, read_bytes

                return
