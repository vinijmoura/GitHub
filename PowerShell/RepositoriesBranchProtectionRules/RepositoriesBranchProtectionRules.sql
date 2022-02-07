CREATE TABLE [dbo].[RepositoriesBranchProtectionRules](
	RepositoryId	 [varchar](20) NOT NULL,
	RepositoryName [varchar](100) NOT NULL,
	RepositoryURL	 [varchar](300) NOT NULL,
	DefaultBranch	 [varchar](50) NOT NULL,
	RequiredSignatures [bit] NOT NULL,
    EnforceAdmins [bit] NOT NULL,
    RequiredLinearHistory [bit] NOT NULL,
    AllowForcePushes [bit] NOT NULL,
    AllowDeletions [bit] NOT NULL,
    RequiredConversationResolution [bit] NOT NULL,
    RequiredPullRequestReviews [bit] NOT NULL,
    RequiredStatusChecks [bit] NOT NULL,
    Restrictions [bit] NOT NULL,
	CONSTRAINT [PK_RepositoriesBranchProtectionRules] PRIMARY KEY CLUSTERED
(
	[RepositoryId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
)
GO