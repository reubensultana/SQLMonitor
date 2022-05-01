SET NOCOUNT ON;

/* ----- dbo.ReportSubscriptions ----- */

-- TRUNCATE TABLE [dbo].[ReportSubscriptions]
INSERT INTO [dbo].[ReportSubscriptions] ([ReportRecipient], [ReportID], [RecordStatus], [RecordCreated])
VALUES 
     (1, NULL, 'A', DEFAULT) 
    ,(2, NULL, 'A', DEFAULT)
    ,(3, 3, 'A', DEFAULT)
    ,(4, 6, 'A', DEFAULT)
    ,(4, 8, 'A', DEFAULT)
    ,(5, 5, 'A', DEFAULT)
    ,(5, 7, 'A', DEFAULT)
    ,(6, 6, 'A', DEFAULT)
    ,(6, 8, 'A', DEFAULT)
    ,(7, 10, 'A', DEFAULT)
    ,(1, 7, 'A', DEFAULT)
    ,(1, 8, 'A', DEFAULT)
    ,(1, 9, 'A', DEFAULT)
GO
INSERT INTO [dbo].[ReportSubscriptions] ([ReportRecipient], [ReportID], [RecordStatus], [RecordCreated])
VALUES 
     (8, 14, 'H', DEFAULT)  -- Service Desk
    ,(8, 15, 'H', DEFAULT)  -- Service Desk
    ,(8, 16, 'H', DEFAULT)  -- Service Desk
    ,(8, 17, 'H', DEFAULT)  -- Service Desk
    ,(8, 18, 'H', DEFAULT)  -- Service Desk
    ,(8, 19, 'H', DEFAULT)  -- Service Desk
    ,(8, 20, 'H', DEFAULT)  -- Service Desk
    ,(8, 21, 'H', DEFAULT)  -- Service Desk
    ,(8, 22, 'H', DEFAULT)  -- Service Desk
    ,(8, 23, 'H', DEFAULT)  -- Service Desk
    ,(8, 24, 'H', DEFAULT)  -- Service Desk
    ,(8, 25, 'H', DEFAULT)  -- Service Desk
    ,(8, 26, 'H', DEFAULT)  -- Service Desk
    ,(8, 27, 'H', DEFAULT)  -- Service Desk
    ,(8, 28, 'H', DEFAULT)  -- Service Desk
    ,(8, 29, 'H', DEFAULT)  -- Service Desk
    ,(8, 30, 'H', DEFAULT)  -- Service Desk
    ,(8, 31, 'H', DEFAULT)  -- Service Desk
    ,(8, 32, 'H', DEFAULT)  -- Service Desk
    ,(8, 33, 'H', DEFAULT)  -- Service Desk
    ,(8, 34, 'H', DEFAULT)  -- Service Desk
    ,(8, 35, 'H', DEFAULT)  -- Service Desk
    ,(8, 36, 'H', DEFAULT)  -- Service Desk
    ,(8, 37, 'H', DEFAULT)  -- Service Desk
    ,(8, 38, 'H', DEFAULT)  -- Service Desk
    ,(8, 39, 'H', DEFAULT)  -- Service Desk
    ,(8, 40, 'H', DEFAULT)  -- Service Desk
    ,(8, 41, 'H', DEFAULT)  -- Service Desk
    ,(8, 42, 'H', DEFAULT)  -- Service Desk
    ,(8, 43, 'H', DEFAULT)  -- Service Desk
    ,(8, 44, 'H', DEFAULT)  -- Service Desk
    ,(8, 45, 'H', DEFAULT)  -- Service Desk
    ,(8, 46, 'H', DEFAULT)  -- Service Desk
    ,(8, 47, 'H', DEFAULT)  -- Service Desk
    ,(8, 48, 'H', DEFAULT)  -- Service Desk
    ,(8, 49, 'H', DEFAULT)  -- Service Desk
    ,(8, 50, 'H', DEFAULT)  -- Service Desk
    ,(8, 51, 'H', DEFAULT)  -- Service Desk
    ,(8, 52, 'H', DEFAULT)  -- Service Desk
    ,(8, 53, 'H', DEFAULT)  -- Service Desk
    ,(8, 54, 'H', DEFAULT)  -- Service Desk
    ,(8, 55, 'H', DEFAULT)  -- Service Desk
    ,(8, 56, 'H', DEFAULT)  -- Service Desk
    ,(8, 57, 'H', DEFAULT)  -- Service Desk
    ,(8, 58, 'H', DEFAULT)  -- Service Desk
    ,(8, 59, 'H', DEFAULT)  -- Service Desk
    ,(8, 60, 'H', DEFAULT)  -- Service Desk
    ,(8, 61, 'H', DEFAULT)  -- Service Desk
    ,(8, 62, 'H', DEFAULT)  -- Service Desk
    ,(8, 63, 'H', DEFAULT)  -- Service Desk
    ,(8, 64, 'H', DEFAULT)  -- Service Desk
    ,(8, 65, 'H', DEFAULT)  -- Service Desk
    ,(8, 66, 'H', DEFAULT)  -- Service Desk
    ,(8, 67, 'H', DEFAULT)  -- Service Desk
    ,(8, 68, 'H', DEFAULT)  -- Service Desk
    ,(8, 69, 'H', DEFAULT)  -- Service Desk
    ,(8, 70, 'H', DEFAULT)  -- Service Desk
    ,(8, 71, 'H', DEFAULT)  -- Service Desk
    ,(8, 72, 'H', DEFAULT)  -- Service Desk
    ,(8, 73, 'H', DEFAULT)  -- Service Desk
    ,(8, 74, 'H', DEFAULT)  -- Service Desk
    ,(8, 75, 'H', DEFAULT)  -- Service Desk
    ,(8, 76, 'H', DEFAULT)  -- Service Desk
    ,(8, 77, 'H', DEFAULT)  -- Service Desk
    ,(8, 78, 'H', DEFAULT)  -- Service Desk
    ,(8, 79, 'H', DEFAULT)  -- Service Desk
    ,(8, 80, 'H', DEFAULT)  -- Service Desk
    ,(8, 81, 'H', DEFAULT)  -- Service Desk
    ,(8, 82, 'H', DEFAULT)  -- Service Desk
    ,(8, 83, 'H', DEFAULT)  -- Service Desk
    ,(8, 84, 'H', DEFAULT)  -- Service Desk
    ,(8, 85, 'H', DEFAULT)  -- Service Desk
    ,(8, 86, 'H', DEFAULT)  -- Service Desk
    ,(8, 87, 'H', DEFAULT)  -- Service Desk
    ,(8, 88, 'H', DEFAULT)  -- Service Desk
    ,(8, 89, 'H', DEFAULT)  -- Service Desk
    ,(8, 90, 'H', DEFAULT)  -- Service Desk
    ,(8, 91, 'H', DEFAULT)  -- Service Desk
    ,(8, 92, 'H', DEFAULT)  -- Service Desk
    ,(8, 93, 'H', DEFAULT)  -- Service Desk
    ,(8, 94, 'H', DEFAULT)  -- Service Desk
    ,(8, 95, 'H', DEFAULT)  -- Service Desk
    ,(8, 96, 'H', DEFAULT)  -- Service Desk
    ,(8, 97, 'H', DEFAULT)  -- Service Desk
    ,(8, 98, 'H', DEFAULT)  -- Service Desk
    ,(8, 99, 'H', DEFAULT)  -- Service Desk
    ,(8, 101, 'H', DEFAULT)  -- Service Desk
    ,(8, 102, 'H', DEFAULT)  -- Service Desk
    ,(8, 103, 'H', DEFAULT)  -- Service Desk
    ,(8, 104, 'H', DEFAULT)  -- Service Desk
    ,(8, 105, 'H', DEFAULT)  -- Service Desk
    ,(8, 106, 'H', DEFAULT)  -- Service Desk
    ,(8, 107, 'H', DEFAULT)  -- Service Desk
    ,(8, 108, 'H', DEFAULT)  -- Service Desk
    ,(8, 109, 'H', DEFAULT)  -- Service Desk
    ,(8, 110, 'H', DEFAULT)  -- Service Desk
    ,(8, 111, 'H', DEFAULT)  -- Service Desk
    ,(8, 112, 'H', DEFAULT)  -- Service Desk
    ,(8, 113, 'H', DEFAULT)  -- Service Desk
    ,(8, 114, 'H', DEFAULT)  -- Service Desk
    ,(8, 115, 'H', DEFAULT)  -- Service Desk
    ,(8, 116, 'H', DEFAULT)  -- Service Desk
    ,(8, 117, 'H', DEFAULT)  -- Service Desk
    ,(8, 118, 'H', DEFAULT)  -- Service Desk
    ,(8, 119, 'H', DEFAULT)  -- Service Desk
    ,(8, 120, 'H', DEFAULT)  -- Service Desk
    ,(8, 121, 'H', DEFAULT)  -- Service Desk
    ,(8, 122, 'H', DEFAULT)  -- Service Desk
    ,(8, 123, 'H', DEFAULT)  -- Service Desk
    ,(8, 124, 'H', DEFAULT)  -- Service Desk
    ,(8, 125, 'H', DEFAULT)  -- Service Desk
    ,(8, 126, 'H', DEFAULT)  -- Service Desk
    ,(8, 127, 'H', DEFAULT)  -- Service Desk
    ,(8, 128, 'H', DEFAULT)  -- Service Desk
    ,(8, 129, 'H', DEFAULT)  -- Service Desk
    ,(8, 130, 'H', DEFAULT)  -- Service Desk
    ,(8, 131, 'H', DEFAULT)  -- Service Desk
    ,(8, 132, 'H', DEFAULT)  -- Service Desk
    ,(8, 135, 'H', DEFAULT)  -- Service Desk
    ,(8, 136, 'H', DEFAULT)  -- Service Desk
    ,(8, 137, 'H', DEFAULT)  -- Service Desk
    ,(8, 138, 'H', DEFAULT)  -- Service Desk
    ,(8, 139, 'H', DEFAULT)  -- Service Desk
    ,(8, 140, 'H', DEFAULT)  -- Service Desk
    ,(8, 143, 'H', DEFAULT)  -- Service Desk
    ,(8, 144, 'H', DEFAULT)  -- Service Desk
    ,(8, 145, 'H', DEFAULT)  -- Service Desk
    ,(8, 146, 'H', DEFAULT)  -- Service Desk
    ,(8, 147, 'H', DEFAULT)  -- Service Desk
    ,(8, 148, 'H', DEFAULT)  -- Service Desk
    ,(8, 149, 'H', DEFAULT)  -- Service Desk
    ,(8, 150, 'H', DEFAULT)  -- Service Desk
    ,(8, 151, 'H', DEFAULT)  -- Service Desk
    ,(8, 152, 'H', DEFAULT)  -- Service Desk
    ,(8, 153, 'H', DEFAULT)  -- Service Desk
    ,(8, 154, 'H', DEFAULT)  -- Service Desk
    ,(8, 155, 'H', DEFAULT)  -- Service Desk
    ,(8, 156, 'H', DEFAULT)  -- Service Desk
    ,(8, 157, 'H', DEFAULT)  -- Service Desk
    ,(8, 158, 'H', DEFAULT)  -- Service Desk
    ,(8, 159, 'H', DEFAULT)  -- Service Desk
    ,(8, 160, 'H', DEFAULT)  -- Service Desk
    ,(8, 161, 'H', DEFAULT)  -- Service Desk
    ,(8, 162, 'H', DEFAULT)  -- Service Desk
    ,(8, 163, 'H', DEFAULT)  -- Service Desk
    ,(8, 164, 'H', DEFAULT)  -- Service Desk
    ,(8, 165, 'H', DEFAULT)  -- Service Desk
    ,(8, 166, 'H', DEFAULT)  -- Service Desk
    ,(8, 167, 'H', DEFAULT)  -- Service Desk
    ,(8, 168, 'H', DEFAULT)  -- Service Desk
    ,(8, 169, 'H', DEFAULT)  -- Service Desk
    ,(8, 170, 'H', DEFAULT)  -- Service Desk
    ,(8, 171, 'H', DEFAULT)  -- Service Desk
    ,(8, 172, 'H', DEFAULT)  -- Service Desk
    ,(8, 173, 'H', DEFAULT)  -- Service Desk
    ,(8, 174, 'H', DEFAULT)  -- Service Desk
    ,(8, 175, 'H', DEFAULT)  -- Service Desk
    ,(8, 176, 'H', DEFAULT)  -- Service Desk
    ,(8, 177, 'H', DEFAULT)  -- Service Desk
    ,(8, 178, 'H', DEFAULT)  -- Service Desk
    ,(8, 179, 'H', DEFAULT)  -- Service Desk
    ,(8, 180, 'H', DEFAULT)  -- Service Desk
    ,(8, 181, 'H', DEFAULT)  -- Service Desk
    ,(8, 182, 'H', DEFAULT)  -- Service Desk
    ,(8, 183, 'H', DEFAULT)  -- Service Desk
    ,(8, 184, 'H', DEFAULT)  -- Service Desk
    ,(8, 185, 'H', DEFAULT)  -- Service Desk
    ,(8, 186, 'H', DEFAULT)  -- Service Desk
    ,(8, 187, 'H', DEFAULT)  -- Service Desk
    ,(8, 188, 'H', DEFAULT)  -- Service Desk
    ,(8, 189, 'H', DEFAULT)  -- Service Desk
    ,(8, 190, 'H', DEFAULT)  -- Service Desk
    ,(8, 191, 'H', DEFAULT)  -- Service Desk
    ,(8, 192, 'H', DEFAULT)  -- Service Desk
    ,(8, 193, 'H', DEFAULT)  -- Service Desk
    ,(8, 194, 'H', DEFAULT)  -- Service Desk
    ,(8, 195, 'H', DEFAULT)  -- Service Desk
    ,(8, 196, 'H', DEFAULT)  -- Service Desk
    ,(8, 197, 'H', DEFAULT)  -- Service Desk
    ,(8, 198, 'H', DEFAULT)  -- Service Desk
    ,(8, 199, 'H', DEFAULT)  -- Service Desk
    ,(8, 200, 'H', DEFAULT)  -- Service Desk
    ,(8, 201, 'H', DEFAULT)  -- Service Desk
    ,(8, 202, 'H', DEFAULT)  -- Service Desk
    ,(8, 203, 'H', DEFAULT)  -- Service Desk
    ,(8, 204, 'H', DEFAULT)  -- Service Desk
    ,(8, 205, 'H', DEFAULT)  -- Service Desk
    ,(8, 206, 'H', DEFAULT)  -- Service Desk
    ,(8, 207, 'H', DEFAULT)  -- Service Desk
    ,(8, 208, 'H', DEFAULT)  -- Service Desk
    ,(8, 209, 'H', DEFAULT)  -- Service Desk
    ,(8, 210, 'H', DEFAULT)  -- Service Desk
    ,(8, 211, 'H', DEFAULT)  -- Service Desk
    ,(8, 212, 'H', DEFAULT)  -- Service Desk
    ,(8, 213, 'H', DEFAULT)  -- Service Desk
    ,(8, 214, 'H', DEFAULT)  -- Service Desk
    ,(8, 215, 'H', DEFAULT)  -- Service Desk
    ,(8, 216, 'H', DEFAULT)  -- Service Desk
    ,(8, 217, 'H', DEFAULT)  -- Service Desk
    ,(8, 218, 'H', DEFAULT)  -- Service Desk
    ,(8, 219, 'H', DEFAULT)  -- Service Desk
    ,(8, 220, 'H', DEFAULT)  -- Service Desk
    ,(8, 221, 'H', DEFAULT)  -- Service Desk
    ,(8, 222, 'H', DEFAULT)  -- Service Desk
    ,(8, 223, 'H', DEFAULT)  -- Service Desk
    ,(8, 224, 'H', DEFAULT)  -- Service Desk
    ,(8, 225, 'H', DEFAULT)  -- Service Desk
    ,(8, 226, 'H', DEFAULT)  -- Service Desk
    ,(8, 227, 'H', DEFAULT)  -- Service Desk
    ,(8, 228, 'H', DEFAULT)  -- Service Desk
    ,(8, 229, 'H', DEFAULT)  -- Service Desk
    ,(8, 230, 'H', DEFAULT)  -- Service Desk
    ,(8, 231, 'H', DEFAULT)  -- Service Desk
    ,(8, 232, 'H', DEFAULT)  -- Service Desk
    ,(8, 233, 'H', DEFAULT)  -- Service Desk
    ,(8, 234, 'H', DEFAULT)  -- Service Desk
    ,(8, 235, 'H', DEFAULT)  -- Service Desk
    ,(8, 236, 'H', DEFAULT)  -- Service Desk
    ,(8, 237, 'H', DEFAULT)  -- Service Desk
    ,(8, 238, 'H', DEFAULT)  -- Service Desk
    ,(8, 239, 'H', DEFAULT)  -- Service Desk
    ,(8, 240, 'H', DEFAULT)  -- Service Desk
    ,(8, 241, 'H', DEFAULT)  -- Service Desk
    ,(8, 242, 'H', DEFAULT)  -- Service Desk
    ,(8, 243, 'H', DEFAULT)  -- Service Desk
    ,(8, 244, 'H', DEFAULT)  -- Service Desk
    ,(8, 245, 'H', DEFAULT)  -- Service Desk
    ,(8, 246, 'H', DEFAULT)  -- Service Desk
    ,(8, 247, 'H', DEFAULT)  -- Service Desk
    ,(8, 248, 'H', DEFAULT)  -- Service Desk
    ,(8, 249, 'H', DEFAULT)  -- Service Desk
    ,(8, 250, 'H', DEFAULT)  -- Service Desk
    ,(8, 251, 'H', DEFAULT)  -- Service Desk
    ,(8, 252, 'H', DEFAULT)  -- Service Desk
    ,(8, 253, 'H', DEFAULT)  -- Service Desk
    ,(8, 254, 'H', DEFAULT)  -- Service Desk
    ,(8, 255, 'H', DEFAULT)  -- Service Desk
    ,(8, 256, 'H', DEFAULT)  -- Service Desk
    ,(8, 257, 'H', DEFAULT)  -- Service Desk
    ,(8, 258, 'H', DEFAULT)  -- Service Desk
    ,(8, 259, 'H', DEFAULT)  -- Service Desk
    ,(8, 260, 'H', DEFAULT)  -- Service Desk
    ,(8, 261, 'H', DEFAULT)  -- Service Desk
    ,(8, 262, 'H', DEFAULT)  -- Service Desk
    ,(8, 263, 'H', DEFAULT)  -- Service Desk
    ,(8, 265, 'H', DEFAULT)  -- Service Desk
    ,(8, 269, 'H', DEFAULT)  -- Service Desk
    ,(8, 270, 'H', DEFAULT)  -- Service Desk
    ,(8, 276, 'H', DEFAULT)  -- Service Desk
    ,(8, 277, 'H', DEFAULT)  -- Service Desk
    ,(8, 278, 'H', DEFAULT)  -- Service Desk
    ,(8, 279, 'H', DEFAULT)  -- Service Desk
    ,(8, 280, 'H', DEFAULT)  -- Service Desk
    ,(8, 281, 'H', DEFAULT)  -- Service Desk
    ,(8, 283, 'H', DEFAULT)  -- Service Desk
    ,(8, 284, 'H', DEFAULT)  -- Service Desk
GO