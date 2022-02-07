Param
(
    [string]$PAT,
    [string]$Organization,
    [string]$Connstr
)

$SQLQuery = "TRUNCATE TABLE RepositoriesBranchProtectionRules"
Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr

$UriOrganization = "https://api.github.com/orgs/$($organization)"
$base64Token = [System.Convert]::ToBase64String([char[]]$PAT)
$headers = @{Authorization = 'Basic {0}' -f $base64Token};

#Repositories Secrets
$uriRepositories = "$($UriOrganization)/repos"
$RepositoriesResult = Invoke-RestMethod -Headers $headers -Uri $uriRepositories
foreach ($repo in $RepositoriesResult)
{    
    [bool] $required_signatures = $false
    [bool] $enforce_admins = $false
    [bool] $required_linear_history = $false
    [bool] $allow_force_pushes = $false
    [bool] $allow_deletions = $false
    [bool] $required_conversation_resolution = $false
    [bool] $required_pull_request_reviews = $false
    [bool] $required_status_checks = $false
    [bool] $restrictions = $false
    
    $uriDefaultBranch = $repo.branches_url.Replace('{/branch}',"/$($repo.default_branch)")
    $DefaultBranchResults = Invoke-RestMethod -Headers $headers -Uri $uriDefaultBranch
    if ($DefaultBranchResults.protected)
    {
        $branchProtectionResults = Invoke-RestMethod -Headers $headers -Uri $DefaultBranchResults.protection_url
        If ($branchProtectionResults)
        {
            $required_signatures = $branchProtectionResults.required_signatures.enabled
            $enforce_admins = $branchProtectionResults.enforce_admins.enabled
            $required_linear_history = $branchProtectionResults.required_linear_history.enabled
            $allow_force_pushes = $branchProtectionResults.allow_force_pushes.enabled
            $allow_deletions = $branchProtectionResults.allow_deletions.enabled
            $required_conversation_resolution = $branchProtectionResults.required_conversation_resolution.enabled

            $exist_required_pull_request_reviews = $branchProtectionResults | Get-Member | where {$_.Name -eq 'required_pull_request_reviews'}
            if ($exist_required_pull_request_reviews) { $required_pull_request_reviews = $true }

            $exist_required_status_checks = $branchProtectionResults | Get-Member | where {$_.Name -eq 'required_status_checks'}
            if ($exist_required_status_checks) { $required_status_checks = $true }

            $exist_restrictions = $branchProtectionResults | Get-Member | where {$_.Name -eq 'restrictions'}
            if ($exist_restrictions) { $restrictions = $true }
        }
    }

    #Insert RepositoriesBranchProtectionRules
    $SQLQuery = "INSERT INTO RepositoriesBranchProtectionRules (
                    RepositoryId,
                    RepositoryName,
                    RepositoryURL,
                    DefaultBranch,
                    RequiredSignatures,
                    EnforceAdmins,
                    RequiredLinearHistory,
                    AllowForcePushes,
                    AllowDeletions,
                    RequiredConversationResolution,
                    RequiredPullRequestReviews,
                    RequiredStatusChecks,
                    Restrictions )
                    VALUES(
                    '$($repo.id)',
                    '$($repo.name)',
                    '$($repo.html_url)',
                    '$($repo.default_branch)',
                    '$($required_signatures)',
                    '$($enforce_admins)',
                    '$($required_linear_history)',
                    '$($allow_force_pushes)',
                    '$($allow_deletions)',
                    '$($required_conversation_resolution)',
                    '$($required_pull_request_reviews)',
                    '$($required_status_checks)',
                    '$($restrictions)'
                    )"
    Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr
}