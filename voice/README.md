# Chairperson voice-entry prototype

Self-contained, no dependencies, no database:

| | |
|---|---|
| `index.html` | the prototype — a task chooser, then one question per screen |
| `types.html` | the input-type sampler: one field of each kind, for testing a new device |
| `spike.html` | capability test — run this on any device before trusting it |

Three chairperson tasks are built. The chooser is the first screen; **Back** on
the first question returns to it.

## Register a group

Twelve questions — the longest flow, and the only one with **no account behind
it**: the group does not exist yet, so nothing can be prefilled and the outcome
is an identity rather than a record.

Location uses the app's own administrative hierarchy, lifted unchanged (1.3 KB):
region → district → ward → village, each list derived from the answer before it.
Changing the region clears everything beneath it rather than leaving a stale
district in place.

### The village question is the honest one

**23 of the 48 wards carry no village list.** Where there is one, it is a
dropdown. Where there is not, the question falls back to typing — and says so:

> No villages are listed for Bwawani, so this one has to be typed. The council
> officer will check it when they verify the group.

This is the last route by which unverified location data enters the system, and
it is also the place where voice input earns its keep most, because it is the
one unavoidable free-text field in the whole flow.

### The outcome is an identity

Registering shows the minted **CMG ID** in large type — *"Write this down. The
chairperson signs in with it from now on — there is no password."* Anything the
officer should know is passed on beneath it: fewer than 10 members, more than
25, or a village that was typed rather than chosen.

## Apply for a loan

Four questions. The order matters: savings and years are asked **before** the
amount, so the moment the chairperson types a figure it can be compared —
*"That is about 1.2 times what the group has saved."* Asking the amount first
would leave nothing to compare it against.

The review then shows what the group never typed and never should have to:

> **Sent with this application, from the group's own record:**
> 12 members · 7 meetings logged · quorum met at 3 of them · no earlier loan
> The lender reads this, not just the four answers above. Nobody assembles it.

**Send** shows the `apply_for_loan` RPC exactly as the app calls it, with a
`_filled_in_by_the_server` block listing what the group does not supply — the
lender, the member count, the prior-loan history and the initial status.

## Log a meeting

The chairperson's most frequent task: every fortnight, for the life of the
group. Eight questions, nine if the group pays the bank that month.

| | |
|---|---|
| When was the meeting? | Today / Yesterday / Choose |
| How many members came? | keypad — **with the quorum rule applied live** |
| Has anyone joined or left? | yes / no → a follow-up only if yes |
| How much was saved? | keypad, with the amount read back in words |
| How much did members repay into the group? | keypad |
| How much did the group lend out? | keypad |
| Did the group pay the bank? | yes / no → full or part → amount if part |
| Anything to note? | voice, optional |

Then a review screen, and a **Save** that shows the row it would write to the
`meetings` table — the app's own field names, so the prototype reads straight
across into the real thing.

### The quorum rule is the point

`ceil(members × 80%)` — the same arithmetic the app uses. Enter 9 of 12 and it
says so immediately:

> ⚠ Below quorum — 9 of 12 present, 10 needed. You can still record the meeting,
> but the group cannot take a decision on a loan at it.

Change the member count and the threshold moves with it: 14 members needs 12
present, not 10. This is the rule that blocks a loan acceptance later in the
walkthrough — said at the moment of entry, where it is still cheap to fix,
rather than discovered weeks afterwards.

## Why it has to be hosted

Browser speech-to-text needs a **secure context**. `file://` and `http://` over
your LAN are both refused, so a phone cannot use the microphone on a page served
from `python3 -m http.server`. Only three things work:

- `http://localhost` — this Mac only
- an **https tunnel** — `./serve.sh --tunnel`, works on a phone in seconds
- **GitHub Pages** — https for free, works for anyone you send the link to

## Publishing

**No separate repo is needed.** Your Pages site is
`https://andvraman.github.io/cmg-built-tracker/`, so drop this folder in as
`voice/` and it serves at:

    https://andvraman.github.io/cmg-built-tracker/voice/

Open that on the iPhone. Two things to know:

- GitHub Pages on a free account requires a **public** repo, so the prototype is
  world-readable at a guessable URL. It holds invented data and no credentials,
  so that is fine — but it is not private.
- `publish/` in the main project is a local git repo with **no remote**; today
  publishing is a manual upload, which the roadmap already records as having
  caused one silent mis-publish. Voice tuning means many redeploys, so wiring a
  remote is worth doing before this starts rather than after.

## Working with no internet

Everything here runs offline **except speech-to-text**, which is the one part
that was never local: the browser sends the audio to its vendor to be
recognised. The split:

| | offline? |
|---|---|
| The page itself, once installed | **yes** — a service worker caches it |
| Number keypad — amounts, counts, phone, percentage | **yes** |
| Date — Today / Yesterday / Choose | **yes** |
| Lists and dropdowns | **yes** |
| Typing any answer | **yes** |
| Reading questions aloud | **yes** — uses the device's own voices |
| **Speech to text** | **depends on the device — measured, not assumed** |

### Do not trust feature detection here

Tested on an iPhone, August 2026: **speech recognition keeps working in airplane
mode**, while the on-device capability API reports *"not offered by this
browser"* — in both Safari and Chrome (on iOS every browser is WebKit, so they
are the same engine). Apple routes the Web Speech API through system dictation,
which is already on-device, and advertises nothing.

So the prototype does **not** decide from a capability probe. It starts
optimistic and learns:

- offline and never tried → the mic stays **enabled**, with a note saying it may
  still work
- it produced words offline → remembered as working; the warning disappears
- it failed with a network error offline → remembered as needing internet, and
  only then is the mic disabled and the firm message shown

An earlier version trusted the probe and greyed the microphone out on exactly
the device where it worked. Never block something that might work.

**Android is still unknown.** iOS behaviour says nothing about it — there Chrome
is really Chrome, and the end users will be on Android. That test is outstanding.

When voice is not available, the prototype does not hide it or fail silently.
A banner appears under the header, the microphone button greys out, and the
field says:

> **Voice input is not available for this field without an internet connection.**
> Speech has to be sent away to be recognised. Type the answer above instead —
> the numbers, dates and lists in this form all work offline.

For the real chairperson this matters more than it looks: **the numeric fields
are the ones used every fortnight**, and those are exactly the ones that never
needed the network. Voice is the bonus that comes and goes with signal; the
keypad is the thing that always works.

## Installing it on a phone

Open the URL, then **Share → Add to Home Screen** (iPhone) or **⋮ → Install app**
(Android). It then opens full-screen and works with no connection.

## What it covers

The real chairperson screens have 33 inputs. They collapse to **eight distinct
interactions**, and this prototype has one of each — everything else is
replication:

| screen | stands in for |
|---|---|
| Group name — voice | CMG name, chairperson name, treasurer name |
| Phone — keypad | chairperson phone, treasurer phone |
| People present — keypad | members present, total members, years active |
| Amount saved — keypad | savings, repayments, disbursements, loan amount |
| Quorum — keypad with a default | quorum % |
| Meeting date — Today / Yesterday / Choose | meeting date |
| Frequency — a list | frequency, region, district, ward, village *(unchanged)* |
| Notes — voice | notes, loan purpose, reason for declining |

## The two rules it is built on

1. **Voice is never the only route.** Every voice question has a text box above
   the microphone. If the mic is refused, the browser cannot listen, or there is
   no internet, the prototype says so in plain words and the typing still works.
   Use *Test the failure states* on the review screen to see each case without
   unplugging anything.
2. **Voice for words, keypad for numbers.** "One eighty" is ambiguous; `180` is
   not. This also avoids the hardest part of Swahili number recognition later.

## Reading it back

Amounts are shown formatted *and* spelled out — `180,000` with "one hundred and
eighty thousand shillings" underneath. Money entry is where the costly errors
happen, and a digit count is not something you can check at a glance.

Voice answers are never taken silently: what was heard is shown back with
**Yes, that's right** / **Try again** before it is kept.

## Read-aloud

The speaker button in the header is **off by default**. It uses the device's own
voices, so it works offline — but macOS, Windows and iOS ship **no Kiswahili
voice**, so spoken prompts will likely stay English-only.

### Chrome on Android fails at this silently

Tested August 2026: read-aloud worked on iOS and said nothing at all on
Android/Chrome, with no error. Three separate causes, any one of which is enough:

1. `getVoices()` is empty until `voiceschanged` fires — speaking before that
   produces nothing;
2. `cancel()` called immediately before `speak()` kills the new utterance, so
   only cancel when something is actually speaking, and leave a beat;
3. setting `.lang` without also setting `.voice` fails when no installed voice
   matches that exact tag.

All three are handled now, and the toggle no longer pretends. If nothing starts
within 1.4 seconds it switches itself back off and says so:

> **Reading aloud is not working on this device.** Android needs a text-to-speech
> voice installed and enabled — Settings, Accessibility, Text-to-speech.

That last part is a device setting, not something the page can fix. Read-aloud
stays a bonus, never a dependency — which is why it is off by default.

## Console handles

`window.__PROTO` exposes `Q`, `answers()`, `go(n)`, `fake`, `hasSR`.
