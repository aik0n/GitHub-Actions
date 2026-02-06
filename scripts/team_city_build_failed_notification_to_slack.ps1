# ========================================================== #
# TeamCity → Slack Notification                              #
# ========================================================== #
# Step must be added with Run condition as "IF Build Failed" #
# ========================================================== #
param(
    [string]$_slackWebhookURL,
    [string]$_environment
)

Write-Host "Starting Build Status Check ..."

if (-not $_slackWebhookURL) {
    Write-Error "ERROR: SlackWebhookURL parameter is missing"
    
    exit 1
}

Write-Error "ERROR: Overall Build Status FAILURE"

$slackWebhookUrl = $_slackWebhookURL
$environment = $_environment
$buildType = $env:TEAMCITY_BUILDCONF_NAME
$branch = $env:TEAMCITY_BUILD_BRANCH

$color = "danger"
$text  = "*Failed* (tests or other reasons)"

$payload = @{
    attachments = @(
        @{
            color = $color
            text  = "$text"
            fields = @(
                @{ title = "Environment"; value = $environment; short = $true }
                @{ title = "Build"; value = $buildType; short = $true }
                @{ title = "Branch"; value = $branch; short = $true }
            )
        }
    )
}

Invoke-RestMethod `
-Uri $slackWebhookUrl `
-Method Post `
-Body ($payload | ConvertTo-Json -Depth 10) `
-ContentType "application/json"

exit 1