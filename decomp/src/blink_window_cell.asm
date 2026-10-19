; Bank 1 at $47B9. The byte before this is ImmediateReturn. What plants
; this address is still unknown.
;
; VRAM bank 0 is selected. HL is one window-map cell: row 4, column $13
; ($9C93). wUnknownC6F2 is a countdown in bits 0-6 and a phase in bit 7.
;
; Bit 7 clear: those low bits decrement. A result of zero is replaced
; with $94, which is bit 7 set and a count of $14. The cell's tile
; becomes WINDOW_TILE ($80). The attribute byte is left alone.
;
; Bit 7 set: the low bits decrement and bit 7 is stored again. A result
; of zero is stored as $14, with bit 7 clear. This visit still paints
; the marked phase: tile $81 in VRAM bank 0, then attribute $EF in VRAM
; bank 1. $EF is palette 7, tile data from VRAM bank 1, both flips, and
; BG-to-OAM priority.
;
; Both paths plant IdleCallback at wCallback and return. That address
; is in ROM0, so the bank byte is left alone.
;
; The rVBK stores are the 3-byte form. rVBK, vWindowMap, and WINDOW_TILE
; are the names from setup_window.asm. wCallback and IdleCallback are
; the names from default_state.asm. $C6F2 has no name yet.

; Byte after wWindowY. Phase in bit 7, countdown in bits 0-6.
DEF wUnknownC6F2 EQU $C6F2

; Row 4, column $13 of the 32-wide window map.
DEF WINDOW_BLINK_CELL EQU vWindowMap + $93

; Count reloaded when a phase expires. $14 visits, including the zero test.
DEF WINDOW_BLINK_COUNT EQU $14

; Tile one past WINDOW_TILE, painted while bit 7 is set.
DEF WINDOW_BLINK_TILE EQU WINDOW_TILE + 1

; Palette 7, VRAM bank 1, horizontal flip, vertical flip, BG-to-OAM priority.
DEF WINDOW_BLINK_ATTR EQU $EF

BlinkWindowCell::
    xor a
    ld [rVBK], a
    ld hl, WINDOW_BLINK_CELL
    ld a, [wUnknownC6F2]
    bit 7, a
    jr nz, .marked
    and $7f
    dec a
    jr nz, .storePlain
    ld a, $80 | WINDOW_BLINK_COUNT
.storePlain:
    ld [wUnknownC6F2], a
    ld a, WINDOW_TILE
    ld [hl], a
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret

.marked:
    and $7f
    dec a
    jr nz, .keepMark
    ld a, WINDOW_BLINK_COUNT
    ld [wUnknownC6F2], a
    jr .paintMarked
.keepMark:
    set 7, a
    ld [wUnknownC6F2], a
.paintMarked:
    ld a, WINDOW_BLINK_TILE
    ld [hl], a
    ld a, $01
    ld [rVBK], a
    ld a, WINDOW_BLINK_ATTR
    ld [hl], a
    ld a, LOW(IdleCallback)
    ld [wCallback], a
    ld a, HIGH(IdleCallback)
    ld [wCallback + 1], a
    ret
