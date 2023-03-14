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

CREATE TABLE [dbo].[VariablesOrganization](
	[OrganizationId]		[varchar](20) NOT NULL,
	[VariableName]			[varchar](100) NOT NULL,
	[VariableCreatedDate]	[datetime] NOT NULL,
	[VariableVisibility]	[varchar](30) NOT NULL,
	FOREIGN KEY (OrganizationId) REFERENCES Organization(OrganizationId),
)
GO

CREATE TABLE [dbo].[VariablesRepositories](
	[RepositoryId]			[varchar](20) NOT NULL,
	[VariableName]			[varchar](100) NOT NULL,
	[VariableCreatedDate]	[datetime] NOT NULL,
	FOREIGN KEY (RepositoryId) REFERENCES Repositories(RepositoryId)
) 
GO

CREATE TABLE [dbo].[VariablesRepositoriesEnvironments](
	[RepositoryId]			[varchar](20) NOT NULL,
	[EnvironmentName]		[varchar](100) NOT NULL,
	[VariableName]			[varchar](100) NOT NULL,
	[VariableCreatedDate]	[datetime] NOT NULL,
	FOREIGN KEY (RepositoryId) REFERENCES Repositories(RepositoryId)
) 
GO