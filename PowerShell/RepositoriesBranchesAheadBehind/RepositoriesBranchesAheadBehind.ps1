Param
(
    [string]$PAT,
    [string]$Organization,
    [string]$Connstr
)

$SQLQuery = "TRUNCATE TABLE RepositoriesBranchesAheadBehind"
Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr

$UriOrganization = "https://api.github.com/orgs/$($organization)"
$UriRepos = "https://api.github.com/repos/$($organization)"

$base64Token = [System.Convert]::ToBase64String([char[]]$PAT)
$headers = @{Authorization = 'Basic {0}' -f $base64Token};

$uriRepositories = "$($UriOrganization)/repos"
$RepositoriesResult = Invoke-RestMethod -Headers $headers -Uri $uriRepositories
foreach ($repo in $RepositoriesResult)
{
    $urlBranchesRepo = $repo.branches_url.Replace('{/branch}','')
    $BranchesRepoResult = Invoke-RestMethod -Headers $headers -Uri $urlBranchesRepo
    foreach ($branchRepo in $BranchesRepoResult)
    {
        $uriCompare = "$($UriRepos)/$($repo.name)/compare/$($repo.default_branch)...$($branchRepo.name)"
        $ComparesResult = Invoke-RestMethod -Headers $headers -Uri $uriCompare
        $SQLQuery = "INSERT INTO RepositoriesBranchesAheadBehind (
                                RepositoryId,
                                RepositoryName,
                                RepositoryBranchName,
                                RepositoryBranchAheadCount,
                                RepositoryBranchBehindCount
                                )
                                VALUES(
                                '$($repo.id)',
                                '$($repo.name)',
                                '$($branchRepo.name)',
                                $($ComparesResult.ahead_by),
                                $($ComparesResult.behind_by)
                                )"
        Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr
    }
}