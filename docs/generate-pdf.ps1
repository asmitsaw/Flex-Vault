Param(
  [string]$InputHtml = "index.html",
  [string]$OutputPdf = "FlexVault-Technical-Report.pdf"
)

$htmlPath = Join-Path $PSScriptRoot $InputHtml
$pdfPath = Join-Path $PSScriptRoot $OutputPdf

if (-not (Test-Path $htmlPath)) {
  Write-Error "Input HTML not found: $htmlPath"
  exit 1
}

# Use Microsoft Edge headless to print to PDF if available
$edgePaths = @(
  "$Env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
  "$Env:ProgramFiles(x86)\Microsoft\Edge\Application\msedge.exe"
)

$edge = $edgePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($edge) {
  & $edge --headless --disable-gpu --print-to-pdf="$pdfPath" "$htmlPath"
  Write-Host "PDF generated: $pdfPath"
} else {
  Write-Warning "Microsoft Edge not found. Please install Edge or use wkhtmltopdf to export $htmlPath to PDF."
}

