param(
    [string]$Environment,
    [string]$Tag,
    [string]$VcsRoot
)

Write-Host "Starting tag validation script..."

$environment = $Environment
$tag = $Tag
$allowedBranch = $VcsRoot

Write-Host "Environment detected: $environment"
Write-Host "Tag detected: $tag"
Write-Host "Allowed branch: $allowedBranch"

# --- ENVIRONMENT VALIDATION ---
if ($environment -ne "Production") {
    Write-Host "BUILD_ENVIRONMENT is '$environment'. This validation runs only in Production. Tag Validation Skipped."
    exit 0
}

Write-Host "OK: Environment equal Production."

# --- TAG EXTRACTION ---
Write-Host "Validating tag source..."

if (-not $tag) {
    Write-Host "ERROR: No tag detected. Stopping."

    $messageTagIsEmpty = "Tag value is Empty"
    Write-Host "##teamcity[buildStatus text='$messageTagIsEmpty']"
    Write-Host "##teamcity[buildProblem description='$messageTagIsEmpty']"

    exit 1
}

# --- TAG FORMAT VALIDATION ---
if ($tag -notmatch '^[0-9]+(\.[0-9]+)*$') {
    Write-Host "ERROR: Invalid tag format: '$tag'"
    Write-Host "Tag must contain only digits and dots, e.g., 1.0.32"

    $messageTagWrongFormat = "Tag Wrong Format"
    Write-Host "##teamcity[buildStatus text='$messageTagWrongFormat']"
    Write-Host "##teamcity[buildProblem description='$messageTagWrongFormat']"

    exit 1
}

Write-Host "OK: Tag format valid."

# --- BRANCH VALIDATION ---
Write-Host "Validating tag against checked out branch..."

# Resolve commit hash for the tag
$tagCommit = git rev-parse $tag 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Tag '$tag' not found in repository"

    $messageTagNotFound = "Tag Not Found"
    Write-Host "##teamcity[buildStatus text='$messageTagNotFound']"
    Write-Host "##teamcity[buildProblem description='$messageTagNotFound']"

    exit 1
}

Write-Host "Tag commit hash: $tagCommit"
Write-Host "Checking if tag commit exists in '$allowedBranch' history..."

$isInBranch = git merge-base --is-ancestor $tagCommit $allowedBranch 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "OK: Tag '$tag' commit is in '$allowedBranch' branch history."
    exit 0
} else {
    Write-Host "ERROR: Tag '$tag' commit is NOT in '$allowedBranch' branch history"
    Write-Host "Tag commit: $tagCommit"
    Write-Host "Branch HEAD: $branchCommit"
    Write-Host "Please create Production tags only from commits in '$allowedBranch' branch."

    $messageWrongBranch = "Tag on a Wrong Branch"
    Write-Host "##teamcity[buildStatus text='$messageWrongBranch']"
    Write-Host "##teamcity[buildProblem description='$messageWrongBranch']"

    exit 1
}