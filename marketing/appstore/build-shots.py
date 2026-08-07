#!/usr/bin/env python3
"""Soon App Store screenshot factory: caption band + framed UI on the
midnight-indigo palette, output 1284x2778 (6.5"). Usage:
python3 build-shots.py <raw-shots-dir> <out-dir>"""
import pathlib, subprocess, sys, tempfile

CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
W, H = 1284, 2778

CARD = """<!doctype html><html><head><meta charset="utf-8"><style>
* {{ margin:0; box-sizing:border-box; }}
html,body {{ width:{w}px; height:{h}px; overflow:hidden; }}
body {{
  background:
    radial-gradient(90% 55% at 18% 6%, rgba(124,92,255,.38), transparent 70%),
    radial-gradient(70% 45% at 88% 94%, rgba(233,64,120,.16), transparent 70%),
    #14121F;
  font-family: Georgia, 'Times New Roman', serif; color:#F3F1FB;
  display:flex; flex-direction:column; align-items:center; padding:96px 90px 0;
}}
.eyebrow {{ font-family:-apple-system,Helvetica,sans-serif; font-size:26px;
  letter-spacing:.32em; color:#A78BFF; text-transform:uppercase; margin-bottom:36px; }}
h1 {{ font-size:88px; line-height:1.1; font-weight:500; text-align:center; max-width:1050px; }}
h1 em {{ font-style:italic; color:#A78BFF; }}
.frame {{ margin-top:72px; border-radius:64px; overflow:hidden;
  border:10px solid #2B2740; box-shadow: 0 60px 120px rgba(0,0,0,.55);
  width:960px; }}
.frame img {{ width:100%; display:block; }}
.wordmark {{ position:absolute; bottom:52px; font-size:34px; color:#F3F1FB;
  font-family:-apple-system,Helvetica,sans-serif; font-weight:700; }}
.wordmark em {{ font-style:normal; color:#A78BFF; }}
</style></head><body>
<div class="eyebrow">SOON</div>
<h1>{headline}</h1>
<div class="frame"><img src="file://{img}"></div>
<div class="wordmark">Soon<em>.</em></div>
</body></html>"""

SHOTS = [
    ("home.png",      "The days you <em>can't wait</em> for."),
    ("detail.png",    "Watch them melt away — <em>to the second.</em>"),
    ("add.png",       "Add one <em>in seconds.</em>"),
    ("confetti.png",  "And then, one morning — <em>it's today.</em>"),
]

def main(raw, out):
    raw, out = pathlib.Path(raw).resolve(), pathlib.Path(out).resolve()
    out.mkdir(parents=True, exist_ok=True)
    for i, (shot, headline) in enumerate(SHOTS, 1):
        src = raw / shot
        if not src.exists():
            print("SKIP missing", shot); continue
        html = CARD.format(w=W, h=H, headline=headline, img=src)
        tmp = pathlib.Path(tempfile.mkdtemp()) / "c.html"
        tmp.write_text(html)
        dest = out / f"{i:02d}-{shot}"
        subprocess.run([CHROME, "--headless", "--disable-gpu",
                        f"--screenshot={dest}", f"--window-size={W},{H}",
                        "--hide-scrollbars", "--force-device-scale-factor=1",
                        f"file://{tmp}"], capture_output=True)
        print("card", dest.name)
    print("DONE")

if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
