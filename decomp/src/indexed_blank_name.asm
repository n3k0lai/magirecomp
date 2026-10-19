; Ten ASCII spaces. CopyIndexedName selects this record when the id is $FF,
; before the fixed-width names that begin at IndexedNameTable ($5AA6).
IndexedBlankName::
    ds INDEXED_NAME_LEN, $20  ; one space for each column of a name record
