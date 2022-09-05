Param
(
    [string]$PAT,
    [string]$UserGitHub,
    [string]$Connstr
)

Get-Date

$SQLQuery="TRUNCATE TABLE RepositoriesStargazers"
Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr

$UriUser="https://api.github.com/users/$($UserGitHub)"
$UriRepos="https://api.github.com/repos/$($UserGitHub)"

$base64Token=[System.Convert]::ToBase64String([char[]]$PAT)
$headers=@{Authorization='Basic {0}' -f $base64Token;Accept='application/vnd.github.v3.star+json'}
#$headers=@{Authorization='Basic {0}' -f $base64Token}

$Repos = @()
$pageRepos=1
do
{
    $uriRepositories="$($UriUser)/repos?page=$($pageRepos)"
    $RepositoriesResult=Invoke-RestMethod -Headers $headers -Uri $uriRepositories
    $Repos+=$RepositoriesResult
    $pageRepos++
} while ($RepositoriesResult.Count -gt 0)

foreach ($repo in $Repos)
{
    $pageStargazers=1
    do
    {
        $uriStargazers="$($UriRepos)/$($repo.name)/stargazers?page=$($pageStargazers)"
        $StargazersRepoResult=Invoke-RestMethod -Headers $headers -Uri $uriStargazers
        foreach ($stargazer in $StargazersRepoResult)
        {
            $SQLQuery = "INSERT INTO RepositoriesStargazers (
                                    RepositoryName,
                                    StargazerLogin,
                                    StargazerAvatarUrl,
                                    StargazerCreatedDate
                                    )
                                    VALUES(
                                    '$($repo.name)',
                                    '$($stargazer.user.login)',
                                    '$($stargazer.user.avatar_url)',
                                    '$($stargazer.starred_at)'
                                    )"
            Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr
        }
        $pageStargazers++
    } while ($StargazersRepoResult.Count -gt 0)
}

Get-Date