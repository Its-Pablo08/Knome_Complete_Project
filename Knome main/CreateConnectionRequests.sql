CREATE TABLE ConnectionRequests (
    RequestId INT IDENTITY(1,1) PRIMARY KEY,
    SenderId INT NOT NULL,
    ReceiverId INT NOT NULL,
    Status NVARCHAR(20) NOT NULL DEFAULT 'Pending',
    CreatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedDate DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    FOREIGN KEY (SenderId) REFERENCES Users(UserId),
    FOREIGN KEY (ReceiverId) REFERENCES Users(UserId)
);

CREATE UNIQUE INDEX UQ_ConnectionRequests_Sender_Receiver ON ConnectionRequests(SenderId, ReceiverId);
