# frab-ms guide

One short English doc covering both audiences: admin/crew (see everything) and
speakers (their own papers, their own reviews, their own payment).

| File | What it is |
| --- | --- |
| `frab-ms-guide.html` | The guide. 8 sections, 9 screenshots. Plain HTML + CSS, no build step, no dependencies. |
| `frab-ms-guide.pdf` | The same, rendered to PDF. |
| `screenshots/` | 9 PNGs at 2x, reused across the doc. |
| `capture_screenshots.rb` | Drives a real browser against a running frab-ms and re-shoots every screenshot. |
| `build_pdf.sh` | Renders the HTML to PDF with headless Chrome. |

Written against the demo conference `demo2026`, the *current* one in the
shared frab demo data (`rails demo:seed` in the parent `/frab` app, see
`/frab/lib/tasks/demo.rake`). frab-ms adds its own layer on top of that:
`db/seeds.rb` here creates eight fresh reviewable papers (type `Paper
Presentation` / `Special Session` / `Non-academic Session` - the only types
this app's review logic understands) so speakers actually have something
pending to review, plus a handful of `Payment` records so the participant
list isn't empty. Run it with `bundle exec rails db:seed`.

## Editing the text

Edit `frab-ms-guide.html` and run `./build_pdf.sh`. Figure numbers are plain
sequential numbers, not chapter-scoped like frab's full manual - renumber by
hand if you insert one in the middle.

## Regenerating the screenshots

```bash
# 1. make sure demo data + this app's own demo content exist
bundle exec rails demo:seed        # in /frab
bundle exec rails db:seed          # in frab-ms

# 2. start frab-ms in another shell (NOT port 3000 - that's frab's own server)
bundle exec rails server -p 3001

# 3. shoot everything
FRAB_MS_URL=http://127.0.0.1:3001 bundle exec ruby doc/manual/capture_screenshots.rb
```

The script signs in as `orga@example.org`, `speaker1@example.org` and
`speaker7@example.org` (password `test123` in the demo data), takes a
full-page screenshot of each screen, and trims the empty edges off with
ImageMagick (`convert -trim`).

The grade form screenshot (`06-review-form`) is the one view that can render
with a large fixed blank gap between the paper details and the review
section, unrelated to how much content it wraps - `-trim` only strips a
uniform border around the *whole* image, so it can't remove a gap in the
middle. If a re-shoot comes out with several thousand blank pixels in the
middle, re-run just that one shot (it's flaky rather than always broken) or
crop it by hand - see the comment above `shoot` in the script for the
one-liner.

If Selenium complains about a chromedriver version mismatch, download the
build matching your local Chrome from
<https://googlechromelabs.github.io/chrome-for-testing/> and pass
`CHROMEDRIVER=/path/to/it`.

## Building the PDF

```bash
doc/manual/build_pdf.sh                        # every frab-*.html here
doc/manual/build_pdf.sh frab-ms-guide.html
doc/manual/build_pdf.sh frab-ms-guide.html /tmp/out.pdf
```

## Requirements

* Google Chrome or Chromium (screenshots and PDF)
* a chromedriver matching that Chrome (screenshots)
* ImageMagick `convert` (trimming and downscaling)
* the app's own gems - `capybara` and `selenium-webdriver` from the `test` group
* Node 14 + `yarn`/`npm install` to compile webpacker assets first (`bin/rails
  webpacker:compile`), or the app renders unstyled - this repo's JS toolchain
  is old enough that newer Node versions fail to build `node-sass`
