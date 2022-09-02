CREATE TABLE [dbo].[RepositoriesForks](
	RepositoryName						[varchar](100) NOT NULL,
	ForkBy						        [varchar](100) NOT NULL,
	ForkCreatedDate						[datetime] NOT NULL
)
