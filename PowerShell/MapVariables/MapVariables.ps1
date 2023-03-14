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

$SQLQuery = "DELETE FROM VariablesRepositoriesEnvironments"
Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr

$SQLQuery = "DELETE FROM VariablesRepositories"
Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr

$SQLQuery = "DELETE FROM VariablesOrganization"
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

#Organization Variables
$uriOrganizationVariables = "$($UriOrganization)/actions/variables"
$OrganizationVariablesResult = Invoke-RestMethod -Headers $headers -Uri $uriOrganizationVariables
foreach ($orgVariable in $OrganizationVariablesResult.variables)
{
    #Insert VariablesOrganization
    $SQLQuery = "INSERT INTO VariablesOrganization (
                            OrganizationId,
	                        VariableName,
	                        VariableCreatedDate,
	                        VariableVisibility
                            )
                            VALUES (
                            '$($OrganizationResult.id)',
                            '$($orgVariable.name)',
                            CONVERT(DATETIME,SUBSTRING('$($orgVariable.created_at)',1,19),127),
                            '$($orgVariable.visibility)')"
    Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr
}

#Repositories Variables
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

    $uriRepositoriesVariables = "$($UriRepositoriesOwner)/$($repo.name)/actions/variables"
    $RepositoriesVariablesResult = Invoke-RestMethod -Headers $headers -Uri $uriRepositoriesVariables
    foreach ($repoVariable in $RepositoriesVariablesResult.variables)
    {
        #Insert VariablesRepositories
        $SQLQuery = "INSERT INTO VariablesRepositories (
                                RepositoryId,
                                VariableName,
                                VariableCreatedDate
                                )
                                VALUES (
                                '$($repo.id)',
                                '$($repoVariable.name)',
                                CONVERT(DATETIME,SUBSTRING('$($repoVariable.created_at)',1,19),127)
                                )"
        Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr
    }

    #Environment Variables
    $uriRepositoriesEnvironments = "$($UriRepositoriesOwner)/$($repo.name)/environments"
    $RepositoriesEnvironmentsResult = Invoke-RestMethod -Headers $headers -Uri $uriRepositoriesEnvironments
    foreach ($repoenvironment in $RepositoriesEnvironmentsResult.environments)
    {
        $uriRepositoriesEnvironmentsVariables = "https://api.github.com/repositories/$($repo.id)/environments/$($repoenvironment.name)/variables"
        $RepositoriesEnvironmentsVariables = Invoke-RestMethod -Headers $headers -Uri $uriRepositoriesEnvironmentsVariables
        foreach ($repoenvironmentvariable in $RepositoriesEnvironmentsVariables.variables)
        {
            #Insert VariablesRepositoriesEnvironments
            $SQLQuery = "INSERT INTO VariablesRepositoriesEnvironments (
                                    RepositoryId,
                                    EnvironmentName,
                                    VariableName,
                                    VariableCreatedDate
                                    )
                                    VALUES (
                                    '$($repo.id)',
                                    '$($repoenvironment.name)',
                                    '$($repoenvironmentvariable.name)',
                                    CONVERT(DATETIME,SUBSTRING('$($repoenvironmentvariable.created_at)',1,19),127)
                                    )"
            Invoke-Sqlcmd -query $SQLQuery -ConnectionString $Connstr
        }
    }
}