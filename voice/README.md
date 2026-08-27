# Chairperson voice-entry prototype

Two files, both self-contained, no dependencies, no database:

| | |
|---|---|
| `spike.html` | capability test — run this first, on every device you care about |
| `index.html` | the prototype: one question per screen, voice and keypad |

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
| **Speech to text** | **no**, unless the browser has on-device recognition |

Newer Chromium exposes an on-device path (`SpeechRecognition.available` /
`install` with `processLocally`). The prototype probes for it at start-up and
uses it when present, so on those devices voice keeps working with no
connection. `spike.html` section 3 reports what your device actually offers —
and the test that settles it is to turn Wi-Fi *and* mobile data off and hold the
button.

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

## Console handles

`window.__PROTO` exposes `Q`, `answers()`, `go(n)`, `fake`, `hasSR`.
