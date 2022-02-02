CREATE TABLE [dbo].[Organization](
	[OrganizationId] [varchar](20) NOT NULL,
	[OrganizationName] [varchar](100) NOT NULL,
	CONSTRAINT [PK_Organization] PRIMARY KEY CLUSTERED
(
	[OrganizationId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
)
GO

CREATE TABLE [dbo].[Repositories](
	[OrganizationId] [varchar](20) NOT NULL,
	[RepositoryId]	 [varchar](20) NOT NULL,
	[RepositoryName] [varchar](100) NOT NULL,
	FOREIGN KEY (OrganizationId) REFERENCES Organization(OrganizationId),
	CONSTRAINT [PK_Repositories] PRIMARY KEY CLUSTERED
(
	[RepositoryId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
)
GO

CREATE TABLE [dbo].[SecretsOrganization](
	[OrganizationId]		[varchar](20) NOT NULL,
	[SecretName]			[varchar](100) NOT NULL,
	[SecretCreatedDate]		[datetime] NOT NULL,
	[SecretVisibility]		[varchar](30) NOT NULL,
	FOREIGN KEY (OrganizationId) REFERENCES Organization(OrganizationId),
)
GO

CREATE TABLE [dbo].[SecretsRepositories](
	[RepositoryId]			[varchar](20) NOT NULL,
	[SecretName]			[varchar](100) NOT NULL,
	[SecretCreatedDate]		[datetime] NOT NULL,
	FOREIGN KEY (RepositoryId) REFERENCES Repositories(RepositoryId)
) 
GO

CREATE TABLE [dbo].[SecretsRepositoriesEnvironments](
	[RepositoryId]			[varchar](20) NOT NULL,
	[EnvironmentName]		[varchar](100) NOT NULL,
	[SecretName]			[varchar](100) NOT NULL,
	[SecretCreatedDate]		[datetime] NOT NULL,
	FOREIGN KEY (RepositoryId) REFERENCES Repositories(RepositoryId)
) 
GO