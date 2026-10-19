; Bank 6 at $6F8A. The last eight tiles of the index-9 20-by-10
; tilemap that CopyIndexedMap writes at $9C20. IndexedMap09Tail stored
; the first twelve blanks of row 9. These finish that blank row.
; Tile $80 is blank. The map is 200 bytes and ends here.

IndexedMap09EndRow::
    ds 8, $80               ; row 9, columns 12-19, rest of the blank row
