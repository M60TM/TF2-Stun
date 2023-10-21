# TF2-Stun
`TF2_OnConditionRemoved` is too late to get `m_hStunner` and `m_iStunFlags`.
Because before calling `TF2_OnConditionRemoved`, `CTFPlayerShared::OnRemoveStunned` reset them early.

This is only reason of exist of this plugin. Just in case, this plugin provides `TF2_OnAddStunned`.

## Forward
```
/**
 * When CTFPlayerShared::OnAddStunned Called.
 * 
 * @param client        Client index.
 * @param duration      Stun duration.
 * @param slowdown      Slowdown rate. from 0(no slowdown) to 255(can't move).
 * @param stunflags     Stun flags. See tf2.inc.
 * @param stunner       Stunner index. -1 when no stunner.
 * 
 * @noreturn
 */
forward void TF2_OnAddStunned(int client, float duration, int slowdown, int stunflags, int stunner);

/**
 * When CTFPlayerShared::OnRemoveStunned Called.
 * 
 * @param client        Client index.
 * @param duration      Stun duration.
 * @param slowdown      Slowdown rate. from 0(no slowdown) to 255(can't move).
 * @param stunflags     Stun flags. See tf2.inc.
 * @param stunner       Stunner index. -1 when no stunner.
 * 
 * @noreturn
 */
forward void TF2_OnRemoveStunned(int client, float duration, int slowdown, int stunflags, int stunner);
```

## Dependancy
- sourcemod 1.11+ (Because DHooks)
- [SM-TFUtils](https://github.com/nosoop/SM-TFUtils)

----

## Building

This project is configured for building via [Ninja][]; see `BUILD.md` for detailed
instructions on how to build it.

If you'd like to use the build system for your own projects,
[the template is available here](https://github.com/nosoop/NinjaBuild-SMPlugin).

[Ninja]: https://ninja-build.org/
