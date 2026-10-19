; Sprite lists read by QueueSpriteList (bank 0): 4-byte records of
; relative Y, relative X, tile offset ($FF95 is added), and OAM
; attributes, ended by a Y of $80 (SPRITE_LIST_END).

IF !DEF(SPRITE_MACROS_INC)
DEF SPRITE_MACROS_INC EQU 1

MACRO sprite
    db LOW(\1), LOW(\2), \3, \4
ENDM
MACRO sprites_end
    db $80
ENDM

ENDC
