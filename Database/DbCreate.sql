USE [master]
GO

IF DB_ID('systeam-hackaton-db') IS NULL
BEGIN
	PRINT N'--CREATE DATABASE';
	DECLARE @DataPath NVARCHAR(255) = (SELECT SUBSTRING(physical_name, 1, CHARINDEX(N'master.mdf', LOWER(physical_name)) - 1) FROM master.sys.master_files WHERE database_id = 1 AND file_id = 1)
	DECLARE @CreateStatement NVARCHAR(1000) = 'CREATE DATABASE [systeam-hackaton-db] ON  PRIMARY ( NAME = ''systeam-hackaton-db'', FILENAME = ''' + @DataPath + 'systeam-hackaton-db.mdf'', SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ) LOG ON (NAME = ''systeam-hackaton-db_log'', FILENAME = ''' + @DataPath + 'systeam-hackaton-db_log.ldf'' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )'
	PRINT (@CreateStatement)
	EXEC (@CreateStatement)
END
GO

IF DB_ID('systeam-hackaton-db') IS NOT NULL AND (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
BEGIN
	EXEC [systeam-hackaton-db].[dbo].[sp_fulltext_database] @action = 'enable'
END
GO

IF DB_ID('systeam-hackaton-db') IS NOT NULL
BEGIN
	PRINT N'--ALTER DATABASE SETTINGS';
	ALTER DATABASE [systeam-hackaton-db] SET ANSI_NULL_DEFAULT OFF 
	ALTER DATABASE [systeam-hackaton-db] SET ANSI_NULLS OFF 
	ALTER DATABASE [systeam-hackaton-db] SET ANSI_PADDING OFF 
	ALTER DATABASE [systeam-hackaton-db] SET ANSI_WARNINGS OFF 
	ALTER DATABASE [systeam-hackaton-db] SET ARITHABORT OFF 
	ALTER DATABASE [systeam-hackaton-db] SET AUTO_CLOSE OFF 
	ALTER DATABASE [systeam-hackaton-db] SET AUTO_SHRINK OFF 
	ALTER DATABASE [systeam-hackaton-db] SET AUTO_UPDATE_STATISTICS ON 
	ALTER DATABASE [systeam-hackaton-db] SET CURSOR_CLOSE_ON_COMMIT OFF 
	ALTER DATABASE [systeam-hackaton-db] SET CURSOR_DEFAULT  GLOBAL 
	ALTER DATABASE [systeam-hackaton-db] SET MULTI_USER 
	ALTER DATABASE [systeam-hackaton-db] SET READ_WRITE 
END
GO

IF (NOT EXISTS (SELECT * FROM [sys].[syslogins] WHERE [loginname]='systeam-hackaton-user')) AND (DB_ID('systeam-hackaton-db') IS NOT NULL)
BEGIN
	PRINT N'--CREATE LOGIN';
	CREATE LOGIN [systeam-hackaton-user] WITH PASSWORD=N'SysTeam2@22!', DEFAULT_DATABASE=[systeam-hackaton-db], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
END
GO

USE [systeam-hackaton-db]
GO

IF DATABASE_PRINCIPAL_ID('systeam-hackaton-user') IS NULL
BEGIN
	PRINT N'--CREATE USER';
	CREATE USER [systeam-hackaton-user] FOR LOGIN [systeam-hackaton-user] WITH DEFAULT_SCHEMA=[dbo]
END
GO

IF DATABASE_PRINCIPAL_ID('systeam-hackaton-user') IS NOT NULL
BEGIN
	EXEC sp_addrolemember 'db_datareader', 'systeam-hackaton-user'
	EXEC sp_addrolemember 'db_datawriter', 'systeam-hackaton-user'
END
GO

IF object_id('CpuUsage', 'U') IS NULL
BEGIN
	PRINT N'--CREATE TABLE CpuUsage';
	CREATE TABLE [dbo].[CpuUsage](
		[Id] [int] IDENTITY(1,1) NOT NULL,
		[Machinename] [nvarchar](60) NOT NULL,
		[Timestamp] [datetime] NOT NULL,
		[Usage] [int] NOT NULL,
	 CONSTRAINT [PK_CpuUsage] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX [IX_CpuUsage] ON [dbo].[CpuUsage]
	(
		[Machinename] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END
GO

IF object_id('MemoryUsage', 'U') IS NULL
BEGIN
	PRINT N'--CREATE TABLE MemoryUsage';
	CREATE TABLE [dbo].[MemoryUsage](
		[Id] [int] IDENTITY(1,1) NOT NULL,
		[Machinename] [nvarchar](60) NOT NULL,
		[Timestamp] [datetime] NOT NULL,
		[Usage] [int] NOT NULL,
	 CONSTRAINT [PK_MemoryUsage] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX [IX_MemoryUsage] ON [dbo].[MemoryUsage]
	(
		[Machinename] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
END
GO

IF object_id('HealthStatus', 'U') IS NULL
BEGIN
	PRINT N'--CREATE TABLE HealthStatus';
	CREATE TABLE [dbo].[HealthStatus](
		[Id] [int] IDENTITY(1,1) NOT NULL,
		[Machinename] [nvarchar](60) NOT NULL,
		[Status] [nvarchar](10) NOT NULL,
	 CONSTRAINT [PK_HealthStatus] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END
GO

PRINT N'--INSERT TESTDATA';
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-20,GETDATE()), 45)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-19,GETDATE()), 60)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-18,GETDATE()), 70)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-17,GETDATE()), 80)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-16,GETDATE()), 82)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-15,GETDATE()), 85)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-14,GETDATE()), 81)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-13,GETDATE()), 76)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-12,GETDATE()), 75)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-11,GETDATE()), 71)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-10,GETDATE()), 70)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-9,GETDATE()), 60)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-8,GETDATE()), 55)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-7,GETDATE()), 50)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-6,GETDATE()), 40)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-5,GETDATE()), 30)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-4,GETDATE()), 28)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-3,GETDATE()), 35)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-2,GETDATE()), 40)
INSERT INTO [dbo].[CpuUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-1,GETDATE()), 50)

INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-20,GETDATE()), 60)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-19,GETDATE()), 70)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-18,GETDATE()), 80)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-17,GETDATE()), 82)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-16,GETDATE()), 85)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-15,GETDATE()), 81)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-14,GETDATE()), 76)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-13,GETDATE()), 75)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-12,GETDATE()), 71)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-11,GETDATE()), 70)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-10,GETDATE()), 60)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-9,GETDATE()), 55)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-8,GETDATE()), 50)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-7,GETDATE()), 40)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-6,GETDATE()), 30)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-5,GETDATE()), 28)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-4,GETDATE()), 35)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-3,GETDATE()), 40)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-2,GETDATE()), 50)
INSERT INTO [dbo].[MemoryUsage] ([Machinename], [Timestamp],[Usage]) VALUES ('Testdata', DATEADD(minute,-1,GETDATE()), 33)


