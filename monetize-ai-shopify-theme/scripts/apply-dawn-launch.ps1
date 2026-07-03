<#
Applies the Monetize with AI five-day launch updates to a pulled Shopify Dawn theme.
Run this from the root of the pulled Dawn theme folder, where folders like assets, config,
layout, sections, snippets, and templates exist.
#>

$ErrorActionPreference = "Stop"

$backupRoot = Join-Path "." ("monetize-launch-backup-" + (Get-Date -Format "yyyyMMdd-HHmmss"))
New-Item -ItemType Directory -Path $backupRoot | Out-Null
Write-Host "Backup folder: $backupRoot"

$requiredFolders = @("assets", "config", "layout", "sections", "snippets", "templates")
foreach ($folder in $requiredFolders) {
  if (-not (Test-Path $folder -PathType Container)) {
    throw "This does not look like a Shopify theme folder. Missing folder: $folder. Run this script from the folder that contains assets, config, layout, sections, snippets, and templates."
  }
}

function Backup-ThemeFile {
  param(
    [Parameter(Mandatory = $true)][string]$Path
  )

  if (Test-Path $Path) {
    $backupPath = Join-Path $backupRoot $Path
    $backupFolder = Split-Path $backupPath -Parent
    New-Item -ItemType Directory -Path $backupFolder -Force | Out-Null
    Copy-Item -Path $Path -Destination $backupPath -Force
  }
}

function Write-ThemeFile {
  param(
    [Parameter(Mandatory = $true)][string]$Path,
    [Parameter(Mandatory = $true)][string]$Content
  )

  Backup-ThemeFile -Path $Path
  $Content | Set-Content -Path $Path -Encoding UTF8
  Write-Host "Updated $Path"
}

$announcement = @'
<div class="announcement-bar color-accent-1 gradient" role="region" aria-label="Store announcement">
  <div class="page-width">
    <p class="announcement-bar__message h5">
      Five-Day Launch Bonus: Get the AI Workflow Starter Pack included when you enroll this week.
    </p>
  </div>
</div>

{% schema %}
{
  "name": "Announcement bar",
  "settings": []
}
{% endschema %}
'@
Write-ThemeFile -Path "sections/announcement-bar.liquid" -Content $announcement

$hero = @'
<section class="monetize-launch-hero">
  <div class="page-width monetize-launch-hero__inner">
    <p class="monetize-launch-eyebrow">Five-Day AI Monetization Launch</p>
    <h1>Turn AI Tools Into Practical Income Skills</h1>
    <p class="monetize-launch-hero__subheadline">A beginner-friendly course system for learning AI workflows, automation, and simple service offers you can build with tools like OpenClaw, Hermes, and modern AI agents.</p>
    <div class="monetize-launch-hero__actions">
      <a class="button button--primary" href="/collections/five-day-ai-monetization-launch">Start Building With AI Today</a>
      <a class="button button--secondary" href="/products/beginner-ai-monetization-system-launch-bundle">See What You&rsquo;ll Build</a>
    </div>
    <p class="monetize-launch-trust">Built for beginners. No advanced coding background required.</p>
  </div>
</section>

{% schema %}
{
  "name": "Monetize launch hero",
  "settings": [],
  "presets": [
    {
      "name": "Monetize launch hero"
    }
  ]
}
{% endschema %}
'@
Write-ThemeFile -Path "sections/monetize-launch-hero.liquid" -Content $hero

$bundle = @'
<section class="monetize-launch-bundle">
  <div class="page-width">
    <div class="monetize-launch-bundle__card">
      <p class="monetize-launch-eyebrow">Recommended starting point</p>
      <h2>Start With the Launch Bundle</h2>
      <p>The fastest path through the store is the Beginner AI Monetization System &ndash; Launch Bundle. It includes the starter kit, workflow templates, Hermes guide, OpenClaw pack, offer builder, mini-course, and community access.</p>
      <a class="button button--primary" href="/products/beginner-ai-monetization-system-launch-bundle">View the Launch Bundle</a>
    </div>
  </div>
</section>

{% schema %}
{
  "name": "Monetize launch bundle",
  "settings": [],
  "presets": [
    {
      "name": "Monetize launch bundle"
    }
  ]
}
{% endschema %}
'@
Write-ThemeFile -Path "sections/monetize-launch-bundle.liquid" -Content $bundle

$cartReassurance = @'
<div class="monetize-cart-reassurance" aria-label="Checkout reassurance">
  <ul>
    <li>Instant digital access after checkout.</li>
    <li>Beginner-friendly.</li>
    <li>No advanced coding required.</li>
    <li>Launch bonus included during the five-day window.</li>
    <li>Educational products only. No income or client guarantees.</li>
  </ul>
</div>
'@
Write-ThemeFile -Path "snippets/monetize-cart-reassurance.liquid" -Content $cartReassurance

$mobileCta = @'
<div class="monetize-mobile-sticky-cta" aria-label="Launch call to action">
  <a class="button button--primary" href="/collections/five-day-ai-monetization-launch">Start Building With AI Today</a>
</div>
'@
Write-ThemeFile -Path "snippets/monetize-mobile-sticky-cta.liquid" -Content $mobileCta

$themeLayoutPath = "layout/theme.liquid"
$themeLayout = Get-Content $themeLayoutPath -Raw
if ($themeLayout -notmatch "monetize-mobile-sticky-cta") {
  $themeLayout = $themeLayout -replace "</body>", "  {% render 'monetize-mobile-sticky-cta' %}`r`n</body>"
  Backup-ThemeFile -Path $themeLayoutPath
  Set-Content -Path $themeLayoutPath -Value $themeLayout -Encoding UTF8
  Write-Host "Updated $themeLayoutPath"
} else {
  Write-Host "Skipped $themeLayoutPath because mobile CTA render already exists"
}

$cartTargets = @("sections/main-cart-items.liquid", "sections/main-cart-footer.liquid")
$cartUpdated = $false
foreach ($cartPath in $cartTargets) {
  if ((Test-Path $cartPath) -and (-not $cartUpdated)) {
    $cartContent = Get-Content $cartPath -Raw
    if ($cartContent -notmatch "monetize-cart-reassurance") {
      $cartContent = $cartContent -replace "</form>", "  {% render 'monetize-cart-reassurance' %}`r`n</form>"
      if ($cartContent -notmatch "monetize-cart-reassurance") {
        $cartContent = $cartContent + "`r`n{% render 'monetize-cart-reassurance' %}`r`n"
      }
      Backup-ThemeFile -Path $cartPath
      Set-Content -Path $cartPath -Value $cartContent -Encoding UTF8
      Write-Host "Updated $cartPath"
    } else {
      Write-Host "Skipped $cartPath because cart reassurance already exists"
    }
    $cartUpdated = $true
  }
}

$indexPath = "templates/index.json"
if (Test-Path $indexPath) {
  $index = Get-Content $indexPath -Raw | ConvertFrom-Json
  if (-not $index.sections.PSObject.Properties.Name.Contains("monetize_launch_hero")) {
    $index.sections | Add-Member -NotePropertyName "monetize_launch_hero" -NotePropertyValue ([ordered]@{ type = "monetize-launch-hero"; settings = @{} })
  }
  if (-not $index.sections.PSObject.Properties.Name.Contains("monetize_launch_bundle")) {
    $index.sections | Add-Member -NotePropertyName "monetize_launch_bundle" -NotePropertyValue ([ordered]@{ type = "monetize-launch-bundle"; settings = @{} })
  }

  $existingOrder = @($index.order | Where-Object { $_ -ne "monetize_launch_hero" -and $_ -ne "monetize_launch_bundle" })
  $index.order = @("monetize_launch_hero", "monetize_launch_bundle") + $existingOrder
  Backup-ThemeFile -Path $indexPath
  $index | ConvertTo-Json -Depth 100 | Set-Content -Path $indexPath -Encoding UTF8
  Write-Host "Updated $indexPath"
}

$cssPath = "assets/base.css"
if (-not (Test-Path $cssPath)) {
  $cssPath = "assets/theme.css"
}

$css = @'

/* Monetize with AI five-day launch */
.monetize-launch-hero {
  padding: clamp(4rem, 10vw, 7rem) 0;
  color: rgb(var(--color-background));
  background: radial-gradient(circle at top right, rgba(185, 255, 102, 0.35), transparent 32rem), linear-gradient(135deg, #0b1020 0%, #151b35 52%, #312e81 100%);
}

.monetize-launch-hero__inner {
  max-width: 980px;
  margin-left: auto;
  margin-right: auto;
}

.monetize-launch-eyebrow {
  margin: 0 0 1rem;
  color: #b9ff66;
  font-size: 0.82rem;
  font-weight: 900;
  letter-spacing: 0.12em;
  text-transform: uppercase;
}

.monetize-launch-hero h1 {
  max-width: 860px;
  margin: 0;
  color: #ffffff;
  font-size: clamp(3rem, 9vw, 6.5rem);
  line-height: 0.92;
  letter-spacing: -0.07em;
}

.monetize-launch-hero__subheadline {
  max-width: 760px;
  margin: 1.5rem 0 0;
  color: #d8def0;
  font-size: clamp(1.1rem, 2vw, 1.35rem);
  line-height: 1.6;
}

.monetize-launch-hero__actions {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  margin-top: 2rem;
}

.monetize-launch-hero .button--secondary {
  color: #ffffff;
  border-color: rgba(255, 255, 255, 0.42);
}

.monetize-launch-trust {
  margin: 1rem 0 0;
  color: #f3f6ff;
  font-weight: 800;
}

.monetize-launch-bundle {
  padding: clamp(3rem, 8vw, 6rem) 0;
  background: #f4f7fb;
}

.monetize-launch-bundle__card {
  max-width: 900px;
  padding: clamp(1.5rem, 5vw, 3rem);
  border: 1px solid #e0e7ff;
  border-radius: 2rem;
  background: #ffffff;
  box-shadow: 0 24px 80px rgba(15, 23, 42, 0.14);
}

.monetize-launch-bundle .monetize-launch-eyebrow {
  color: #4f46e5;
}

.monetize-launch-bundle h2 {
  margin: 0;
  font-size: clamp(2rem, 5vw, 3.75rem);
  line-height: 1;
  letter-spacing: -0.05em;
}

.monetize-launch-bundle p:not(.monetize-launch-eyebrow),
.monetize-cart-reassurance {
  color: rgba(var(--color-foreground), 0.75);
  font-size: 1.08rem;
  line-height: 1.7;
}

.monetize-cart-reassurance {
  margin: 1.5rem 0;
  padding: 1rem;
  border: 1px solid rgba(var(--color-foreground), 0.12);
  border-radius: 1rem;
  background: rgb(var(--color-background));
}

.monetize-cart-reassurance ul {
  margin: 0;
  padding-left: 1.25rem;
}

.monetize-mobile-sticky-cta {
  display: none;
}

@media screen and (max-width: 749px) {
  body {
    padding-bottom: 5.5rem;
  }

  .monetize-launch-hero__actions .button,
  .monetize-launch-bundle .button {
    width: 100%;
  }

  .monetize-mobile-sticky-cta {
    position: fixed;
    right: 0;
    bottom: 0;
    left: 0;
    z-index: 50;
    display: block;
    padding: 0.75rem;
    background: rgba(255, 255, 255, 0.94);
    box-shadow: 0 -16px 40px rgba(15, 23, 42, 0.16);
  }

  .monetize-mobile-sticky-cta .button {
    width: 100%;
  }
}
/* End Monetize with AI five-day launch */
'@

$existingCss = Get-Content $cssPath -Raw
if ($existingCss -notmatch "Monetize with AI five-day launch") {
  Backup-ThemeFile -Path $cssPath
  Add-Content -Path $cssPath -Value $css -Encoding UTF8
  Write-Host "Updated $cssPath"
} else {
  Write-Host "Skipped $cssPath because launch CSS already exists"
}

Write-Host "Done. Backups are in: $backupRoot"
Write-Host "Next run: shopify theme dev --store aiformoney.myshopify.com"
