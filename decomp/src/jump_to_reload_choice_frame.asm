; Bank 3 at $6B77. Choice steps plant this address at $CCB0 as the
; armed-slot word. When that slot runs, control lands here and leaves
; through the reload at $7637. That routine is already source.

JumpToReloadChoiceFrame::
    jp ReloadChoiceFrame
