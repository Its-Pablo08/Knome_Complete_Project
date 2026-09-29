-- Seed Restricted Keywords into Knome DB (FR-SM-07)
USE [Knome];
GO

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RestrictedKeywords')
BEGIN
    CREATE TABLE [dbo].[RestrictedKeywords] (
        [KeywordId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        [Keyword] NVARCHAR(100) NOT NULL UNIQUE,
        [Category] NVARCHAR(50) NOT NULL DEFAULT 'General',
        [CreatedDate] DATETIME2 NOT NULL DEFAULT GETUTCDATE()
    );
END
GO

MERGE INTO [dbo].[RestrictedKeywords] AS Target
USING (VALUES 
    ('aadhaar'), ('abuse'), ('abusive'), ('access token'), ('api key'), ('apikey'), 
    ('bank account'), ('bc'), ('behenchod'), ('betting'), ('bhenchod'), ('bhosdike'), 
    ('bkl'), ('bomb'), ('bsdk'), ('bullying'), ('buy now'), ('casino'), 
    ('cheat'), ('choot'), ('chutiya'), ('chutiye'), ('classified'), ('click here'), 
    ('client secret'), ('confidential'), ('connection string'), ('crack'), ('credit card'), 
    ('cvv'), ('damn'), ('database password'), ('earn money'), ('explicit'), ('fool'), 
    ('fraud'), ('free me paise'), ('free money'), ('free recharge'), ('gaand'), ('gambling'), 
    ('ghar baithe kamao'), ('hack'), ('hacker'), ('hacking'), ('haraami'), ('harami'), 
    ('harassment'), ('hate'), ('hell'), ('hot video'), ('idiot'), ('internal only'), 
    ('jaan se maar dunga'), ('jaldi click karo'), ('jwt token'), ('kaminey'), ('khatam kar dunga'), 
    ('kill'), ('lauda'), ('loser'), ('lottery'), ('lottery jeeto'), ('maar dalunga'), 
    ('madarchod'), ('mallu bhabhi'), ('malware'), ('mc'), ('mkc'), ('moron'), 
    ('murder'), ('nda'), ('nude'), ('nude bhejo'), ('offensive'), ('otp'), 
    ('paisa kamao'), ('pan card'), ('passport'), ('password'), ('paytm cash'), ('phishing'), 
    ('piracy'), ('porn'), ('pornography'), ('private key'), ('proprietary'), ('raand'), 
    ('racist'), ('ransomware'), ('refresh token'), ('restricted'), ('saala'), ('saale'), 
    ('salary'), ('scam'), ('secret key'), ('sex chat'), ('sexist'), ('sexual'), 
    ('stupid'), ('terrorist'), ('tujhe dekh lunga'), ('violence'), ('virus'), ('weapon')
) AS Source ([Keyword])
ON Target.[Keyword] = Source.[Keyword]
WHEN NOT MATCHED THEN
    INSERT ([Keyword], [Category], [CreatedDate])
    VALUES (Source.[Keyword], 'Security', GETUTCDATE());
GO
