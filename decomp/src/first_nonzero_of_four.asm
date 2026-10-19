; Bank 2 at $70C3. PickD092SlotPlus1 and PickD096SlotPlus5 call this
; with HL pointing at four bytes.
;
; AddDividerStep returns a byte. Its low two bits are the start index,
; 0 through 3. Bit 7 picks the direction. Set walks backward and wraps
; from 0 to 3. Clear walks forward and wraps from 3 to 0. Each step
; reads one byte. The first nonzero byte returns its index in A.
; Four zeros return $FF. HL is restored. D counts the four tries.

FirstNonzeroOfFour::
    call AddDividerStep
    push af
    and $03
    ld c, a
    ld b, $00
    ld d, $04
    pop af
    push hl
    bit 7, a
    jr z, .forward

.backward:
    pop hl
    push hl
    add hl, bc
    ld a, [hl]
    and a
    jr nz, .done

    dec bc
    ld a, $FF
    cp c
    jr nz, .backwardStep

    ld bc, $0003

.backwardStep:
    dec d
    jr z, .none

    jr .backward

.forward:
    pop hl
    push hl
    add hl, bc
    ld a, [hl]
    and a
    jr nz, .done

    inc bc
    ld a, $04
    cp c
    jr nz, .forwardStep

    ld bc, $0000

.forwardStep:
    dec d
    jr nz, .forward

.none:
    ld c, $FF

.done:
    ld a, c
    pop hl
    ret
