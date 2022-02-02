Param
(
    [string]$PAT,
    [string]$Organization,
    [string]$Connstr
)

$base64Token = [System.Convert]::ToBase64String([char[]]$PAT)
$headers = @{Authorization = 'Basic {0}' -f $base64Token};
$UriOrganization = "https://api.github.com/orgs/$($organization)"
$UriRepositoriesOwner = "https://api.github.com/repos/$($organization)"

$SQLQuery = "DELETE FROM SecretsRepositoriesEnvironments"
Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr

$SQLQuery = "DELETE FROM SecretsRepositories"
Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr

$SQLQuery = "DELETE FROM SecretsOrganization"
Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr

$SQLQuery = "DELETE FROM Repositories"
Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr

$SQLQuery = "DELETE FROM Organization"
Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr

$OrganizationResult = Invoke-RestMethod -Headers $headers -Uri $UriOrganization

$SQLQuery = "INSERT INTO Organization (
                        OrganizationId,
                        OrganizationName
                        )
                        VALUES (
                        '$($OrganizationResult.id)',
                        '$($organization)'
                        )"
Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr

#Organization Secrets
$uriOrganizationSecrets = "$($UriOrganization)/actions/secrets"
$OrganizationSecretsResult = Invoke-RestMethod -Headers $headers -Uri $uriOrganizationSecrets
foreach ($orgSecret in $OrganizationSecretsResult.secrets)
{
    #Insert SecretsOrganization
    $SQLQuery = "INSERT INTO SecretsOrganization (
                            OrganizationId,
	                        SecretName,
	                        SecretCreatedDate,
	                        SecretVisibility
                            )
                            VALUES (
                            '$($OrganizationResult.id)',
                            '$($orgSecret.name)',
                            CONVERT(DATETIME,SUBSTRING('$($orgSecret.created_at)',1,19),127),
                            '$($orgSecret.visibility)')"
    Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr
}

#Repositories Secrets
$uriRepositories = "$($UriOrganization)/repos"
$RepositoriesResult = Invoke-RestMethod -Headers $headers -Uri $uriRepositories
foreach ($repo in $RepositoriesResult)
{
    #Insert Repositories
    $SQLQuery = "INSERT INTO Repositories (
                            OrganizationId,
                            RepositoryId,
                            RepositoryName
                            )
                            VALUES (
                            '$($OrganizationResult.id)',
                            '$($repo.id)',
                            '$($repo.name)'
                            )"
    Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr

    $uriRepositoriesSecrets = "$($UriRepositoriesOwner)/$($repo.name)/actions/secrets"
    $RepositoriesSecretsResult = Invoke-RestMethod -Headers $headers -Uri $uriRepositoriesSecrets
    foreach ($repoSecret in $RepositoriesSecretsResult.secrets)
    {
        #Insert SecretsRepositories
        $SQLQuery = "INSERT INTO SecretsRepositories (
                                RepositoryId,
                                SecretName,
                                SecretCreatedDate
                                )
                                VALUES (
                                '$($repo.id)',
                                '$($repoSecret.name)',
                                CONVERT(DATETIME,SUBSTRING('$($repoSecret.created_at)',1,19),127)
                                )"
        Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr
    }

    #Environment Secrets
    $uriRepositoriesEnvironments = "$($UriRepositoriesOwner)/$($repo.name)/environments"
    $RepositoriesEnvironmentsResult = Invoke-RestMethod -Headers $headers -Uri $uriRepositoriesEnvironments
    foreach ($repoenvironment in $RepositoriesEnvironmentsResult.environments)
    {
        $uriRepositoriesEnvironmentsSecrets = "https://api.github.com/repositories/$($repo.id)/environments/$($repoenvironment.name)/secrets"
        $RepositoriesEnvironmentsSecrets = Invoke-RestMethod -Headers $headers -Uri $uriRepositoriesEnvironmentsSecrets
        foreach ($repoenvironmentsecret in $RepositoriesEnvironmentsSecrets.secrets)
        {
            #Insert SecretsRepositoriesEnvironments
            $SQLQuery = "INSERT INTO SecretsRepositoriesEnvironments (
                                    RepositoryId,
                                    EnvironmentName,
                                    SecretName,
                                    SecretCreatedDate
                                    )
                                    VALUES (
                                    '$($repo.id)',
                                    '$($repoenvironment.name)',
                                    '$($repoenvironmentsecret.name)',
                                    CONVERT(DATETIME,SUBSTRING('$($repoenvironmentsecret.created_at)',1,19),127)
                                    )"
            Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr
        }
    }
}