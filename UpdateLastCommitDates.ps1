Write-Host "===== Script Started ====="

# Get the folder where this script lives
$projectRoot = $PSScriptRoot

# Path to your content folder
$folder = Join-Path $projectRoot "Content\Product Documentation"

Write-Host "`nScanning folder: $folder`n"

# Get all .htm/.html files
$files = Get-ChildItem -Path $folder -Include *.htm, *.html -Recurse -File

foreach ($file in $files) {
    $filePath = $file.FullName
    Write-Host "Checking: $filePath"

    # Get Git commit date with time
    $gitDate = git log -1 --format="%ad" --date=format:"%d %B, %Y %H:%M:%S" -- "$filePath" 2>$null

    if ($gitDate) {
        Write-Host "Git Date Found: $gitDate"
    } else {
        $gitDate = (Get-Date).ToString("dd MMMM, yyyy HH:mm:ss")
        Write-Host "Git date not found, using fallback: $gitDate"
    }

    # Read file content
    $content = Get-Content -Path $filePath -Raw

    # Regex: find <span class="last-commit-date">...</span> and replace inner content
    $updatedContent = [regex]::Replace(
        $content,
        '<span class="last-commit-date">.*?</span>',
        "<span class=`"last-commit-date`">$gitDate</span>"
    )

    # Save only if modified
    if ($updatedContent -ne $content) {
        Write-Host "Updating file..."
        Set-Content -Path $filePath -Value $updatedContent -Encoding UTF8
    } else {
        Write-Host "No update needed."
    }
}

Write-Host "===== Script Completed ====="
