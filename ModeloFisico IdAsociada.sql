/*
   Monday, November 18, 202411:42:06 PM
   User: 
   Server: DESKTOP-51KTN66\SQLEXPRESS
   Database: Proyecto 3 BackUp
   Application: 
*/

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.TCA SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.TCA', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.TCA', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.TCA', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.TCM SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.TCM', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.TCM', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.TCM', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.TF ADD
	TCM int NULL,
	TCA int NULL
GO
ALTER TABLE dbo.TF ADD CONSTRAINT
	FK_TF_TCA1 FOREIGN KEY
	(
	TCA
	) REFERENCES dbo.TCA
	(
	id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.TF ADD CONSTRAINT
	FK_TF_TCM1 FOREIGN KEY
	(
	TCM
	) REFERENCES dbo.TCM
	(
	id
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.TF SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.TF', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.TF', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.TF', 'Object', 'CONTROL') as Contr_Per 