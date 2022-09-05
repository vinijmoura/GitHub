CREATE TABLE [dbo].[RepositoriesStargazers](
	RepositoryName			[varchar](100) NOT NULL,
	StargazerLogin			[varchar](100) NOT NULL,
	StargazerAvatarUrl		[nvarchar](MAX) NOT NULL,
	StargazerCreatedDate		[datetime] NOT NULL
)
