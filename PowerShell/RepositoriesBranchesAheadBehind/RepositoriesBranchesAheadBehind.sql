CREATE TABLE [dbo].[RepositoriesBranchesAheadBehind](
	RepositoryId					[varchar](20) NOT NULL,
	RepositoryName					[varchar](100) NOT NULL,
	RepositoryBranchName				[varchar](50) NOT NULL,
	RepositoryBranchAheadCount			[int] NULL,
	RepositoryBranchBehindCount			[int] NULL,
)
