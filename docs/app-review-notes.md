# Soon — App Store review reply (Guideline 2.1, Information Needed)

Rejection type: **Guideline 2.1 — Information Needed** (the mildest outcome — Apple
just wants more info to complete review; no app defect was found). Trigger is
almost certainly the **ATT prompt + AdMob ads**.

## What to do
1. App Store Connect → **App Review Information → Notes** → paste the block below.
2. Attach / link a **screen recording** (see checklist).
3. **Reply to Apple's message** (in the review submission) with the same info + recording.
4. Resubmit build **vc2 (1.0)**.

No code change is required. (One optional polish below.)

---

## Notes field (copy-paste)

> **About Soon**
> Soon: Days Until is a simple, fully offline countdown app. Users create
> countdowns for events they look forward to (trips, birthdays, deadlines) and
> watch the time tick down — on the home list, in Home Screen and Lock Screen
> widgets, in a Live Activity / Dynamic Island during the final 24 hours, and via
> optional local reminders.
>
> **1. App flow & sensitive prompts.** The app has **no account, no login, no
> purchases or subscriptions, and no user-generated content**. All data (the
> user's countdowns) is stored **only on the device** — there is no server. The app
> shows two optional system prompts: (a) a **notification** permission prompt for
> event reminders, and (b) an **App Tracking Transparency** prompt for personalized
> ads via Google AdMob. The app is fully functional if either is declined.
>
> **2. Devices/OS tested.** iPhone <MODELS, e.g. iPhone 15 / iPhone 13>, iOS
> <VERSION, e.g. 18.5>.
>
> **3. Purpose & audience.** A "days until" tracker for anyone anticipating an
> event — travelers, students, planners. It removes the mental math of "how many
> days until X?" and keeps the event visible via widgets and the Dynamic Island.
>
> **4. Setup / access.** No setup or credentials needed. Launch → tap **+** → enter
> a name, date & time, icon and colour → **Save**. Widgets are added via the in-app
> "Add the widget" guide or the standard iOS widget gallery (search "Soon").
>
> **5. External services.** **Google AdMob** (Google Mobile Ads SDK) for banner
> ads only. No other backend, analytics, data provider, authentication or payment
> service — the app has no server of its own.
>
> **6. Regional differences.** None. The app behaves identically in all regions.
>
> **7. Regulated industry / protected material.** Not applicable. No regulated
> content and no third-party protected material.

---

## Screen recording checklist (record on a physical iPhone, latest iOS)
Start the recording from **app launch**, then show the typical flow:
1. Launch → home list of countdowns.
2. Tap **+** → create a countdown (name, date & time, icon, colour) → **Save**.
3. Show the **notification permission** prompt appearing (and the **ATT** prompt —
   Apple specifically wants the ATT flow shown).
4. Open a countdown → the live ticker / detail.
5. (Optional but nice) open the in-app "Add the widget" guide.

Keep it ~30–60s. No account/purchase/UGC flows exist, so nothing else to show.

---

## Optional polish (not required, but strengthens 5.1.1)
Apple's generic tips mention purpose strings should say *how* the data is used.
Current ATT string: `Used to show you more relevant ads.` — consider:
`Soon uses this to show you more relevant ads. Your countdowns stay on your device
either way.` (in `project.yml` → `NSUserTrackingUsageDescription`). Purely optional.

## Reuse
Unflinch and shwaas will likely get the same 2.1 message on first submission —
adapt sections 3/4/5 to each app and keep the rest.
