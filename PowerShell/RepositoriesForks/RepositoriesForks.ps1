Param
(
    [string]$PAT,
    [string]$UserGitHub,
    [string]$Connstr
)

Get-Date

$SQLQuery="TRUNCATE TABLE RepositoriesForks"
Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr

$UriUser="https://api.github.com/users/$($UserGitHub)"
$UriRepos="https://api.github.com/repos/$($UserGitHub)"

$base64Token=[System.Convert]::ToBase64String([char[]]$PAT)
$headers=@{Authorization='Basic {0}' -f $base64Token}

$Repos = @()
$pageRepos=1
do
{
    $uriRepositories="$($UriUser)/repos?page=$($pageRepos)"
    $RepositoriesResult=Invoke-RestMethod -Headers $headers -Uri $uriRepositories
    $Repos+=$RepositoriesResult
    $pageRepos++
} while ($RepositoriesResult.Count -gt 0)

$Forks=@()
foreach ($repo in $Repos)
{
    $pageForks=1
    do
    {
        $uriForks="$($UriRepos)/$($repo.name)/forks?page=$($pageForks)"
        $ForksRepoResult=Invoke-RestMethod -Headers $headers -Uri $uriForks
        $Forks+=$ForksRepoResult
        $pageForks++
    } while ($ForksRepoResult.Count -gt 0)
}

foreach ($fork in $Forks)
{
    $SQLQuery = "INSERT INTO RepositoriesForks (
                                RepositoryName,
                                ForkBy,
                                ForkCreatedDate
                                )
                                VALUES(
                                '$($fork.name)',
                                '$($fork.full_name)',
                                '$($fork.created_at)'
                                )"
    Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr
}

Get-Date