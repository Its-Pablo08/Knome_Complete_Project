-- Insert / Update all requested Restricted Keywords in Knome Database
USE [Knome];
GO

MERGE INTO [dbo].[RestrictedKeywords] AS Target
USING (VALUES
    -- Profanities / Abusive terms
    (N'chutiya'),
    (N'chutiye'),
    (N'bhenchod'),
    (N'behenchod'),
    (N'madarchod'),
    (N'bhosdike'),
    (N'harami'),
    (N'haraami'),
    (N'kaminey'),
    (N'saala'),
    (N'saale'),
    (N'gaand'),
    (N'lauda'),
    (N'choot'),
    (N'bc'),
    (N'mc'),
    (N'bsdk'),
    (N'mkc'),
    (N'bkl'),

    -- Spam / Scam phrases
    (N'paisa kamao'),
    (N'free me paise'),
    (N'lottery jeeto'),
    (N'ghar baithe kamao'),
    (N'paytm cash'),
    (N'jaldi click karo'),
    (N'free recharge'),

    -- Threats / Harassment
    (N'jaan se maar dunga'),
    (N'tujhe dekh lunga'),
    (N'maar dalunga'),
    (N'khatam kar dunga'),

    -- NSFW / Inappropriate
    (N'nude bhejo'),
    (N'hot video'),
    (N'sex chat'),
    (N'raand'),
    (N'mallu bhabhi'),

    -- PII & Credentials
    (N'api key'),
    (N'password'),
    (N'aadhaar'),
    (N'credit card'),
    (N'pan card'),
    (N'cvv'),
    (N'bank account')
) AS Source ([Keyword])
ON Target.[Keyword] = Source.[Keyword]
WHEN NOT MATCHED THEN
    INSERT ([Keyword])
    VALUES (Source.[Keyword]);
GO
