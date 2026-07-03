#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

require_text() {
  local file="$1"
  local text="$2"

  if ! grep -Fq "$text" "$ROOT_DIR/$file"; then
    echo "Missing required text in $file:" >&2
    echo "  $text" >&2
    exit 1
  fi
}

require_text "sections/announcement-bar.liquid" "Five-Day Launch Bonus: Get the AI Workflow Starter Pack included when you enroll this week."
require_text "sections/hero.liquid" "Turn AI Tools Into Practical Income Skills"
require_text "sections/hero.liquid" "A beginner-friendly course system for learning AI workflows, automation, and simple service offers you can build with tools like OpenClaw, Hermes, and modern AI agents."
require_text "sections/hero.liquid" "Start Building With AI Today"
require_text "sections/hero.liquid" "/collections/five-day-ai-monetization-launch"
require_text "sections/hero.liquid" "See What You&rsquo;ll Build"
require_text "sections/hero.liquid" "/products/beginner-ai-monetization-system-launch-bundle"
require_text "sections/hero.liquid" "Built for beginners. No advanced coding background required."
require_text "sections/launch-bundle.liquid" "Start With the Launch Bundle"
require_text "sections/launch-bundle.liquid" "The fastest path through the store is the Beginner AI Monetization System &ndash; Launch Bundle. It includes the starter kit, workflow templates, Hermes guide, OpenClaw pack, offer builder, mini-course, and community access."
require_text "sections/launch-bundle.liquid" "View the Launch Bundle"
require_text "snippets/cart-reassurance.liquid" "Instant digital access after checkout."
require_text "snippets/cart-reassurance.liquid" "Beginner-friendly."
require_text "snippets/cart-reassurance.liquid" "No advanced coding required."
require_text "snippets/cart-reassurance.liquid" "Launch bonus included during the five-day window."
require_text "snippets/cart-reassurance.liquid" "Educational products only. No income or client guarantees."
require_text "snippets/mobile-sticky-cta.liquid" "Start Building With AI Today"
require_text "snippets/mobile-sticky-cta.liquid" "/collections/five-day-ai-monetization-launch"
require_text "assets/theme.css" ".mobile-sticky-cta"

python -m json.tool "$ROOT_DIR/templates/index.json" >/dev/null
python -m json.tool "$ROOT_DIR/config/settings_schema.json" >/dev/null
python -m json.tool "$ROOT_DIR/locales/en.default.json" >/dev/null

echo "Launch content checks passed."
