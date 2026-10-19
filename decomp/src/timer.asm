; Timer overflow interrupt vector. The CPU enters here when TIMA overflows.
; TimerOverflow saves the banks, runs the sound command, then returns.

Timer::
    jp TimerOverflow
