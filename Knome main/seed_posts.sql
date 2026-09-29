USE [Knome];

-- Delete existing posts for a clean slate
DELETE FROM [Posts];

-- Insert requested posts with assigned user IDs
INSERT INTO [Posts] ([AuthorUserId], [ContentText], [AudienceType], [Status], [PublishedDate], [CreatedDate]) VALUES
(5, 'Welcome to Tech Hub!', 'Everyone', 'Published', GETUTCDATE(), GETUTCDATE()),
(1, 'Building APIs is easy. Building APIs that are secure, scalable, and maintainable is the real challenge. Every day with ASP.NET Core and EF Core is another opportunity to write cleaner code, improve performance, and learn something new. &#x1F680; #DotNet #CleanCode #WebAPI', 'Everyone', 'Published', GETUTCDATE(), GETUTCDATE()),
(3, 'Dependency Injection (DI) is one of the most important concepts in modern ASP.NET Core development. It helps you build applications that are clean, maintainable, and easy to test.', 'Everyone', 'Published', GETUTCDATE(), GETUTCDATE()),
(4, '🚀 .NET Developers: Small Improvements Create Big Results!
Every great .NET developer starts with writing clean, maintainable, and scalable code—not just code that works.', 'Everyone', 'Published', GETUTCDATE(), GETUTCDATE()),
(4, '🚀 .NET Developers: Small Improvements Create Big Results!
Every great .NET developer starts with writing clean, maintainable, and scalable code—not just code that works.', 'Everyone', 'Published', GETUTCDATE(), GETUTCDATE()),
(4, '🚀 .NET Developers: Small Improvements Create Big Results!
Every great .NET developer starts with writing clean, maintainable, and scalable code—not just code that works.', 'Everyone', 'Published', GETUTCDATE(), GETUTCDATE()),
(6, 'I used sql server.', 'Everyone', 'Published', GETUTCDATE(), GETUTCDATE()),
(2, '@Sourabh Sahu, I Learn sql.', 'Everyone', 'Published', GETUTCDATE(), GETUTCDATE()),
(5, 'i worked on dot net.', 'Everyone', 'Published', GETUTCDATE(), GETUTCDATE()),
(1, 'I learned .net.', 'Everyone', 'Published', GETUTCDATE(), GETUTCDATE()),
(6, 'Shared a post from @Sourabh Sahu:

"I learned .net."', 'Everyone', 'Published', GETUTCDATE(), GETUTCDATE()),
(5, 'my first post.', 'Everyone', 'Published', GETUTCDATE(), GETUTCDATE()),
(2, 'Strong leadership is built through continuous learning, collaboration, and shared experiences. Welcome to Leadership Circle, a private community where leaders come together to exchange ideas, discuss challenges, and inspire one another to achieve excellence.', 'Everyone', 'Published', GETUTCDATE(), GETUTCDATE()),
(3, 'Engineering Is More Than Writing Code
Engineering isn''t just about building software—it''s about solving real-world problems with logic, creativity, and collaboration.', 'Everyone', 'Published', GETUTCDATE(), GETUTCDATE()),
(1, 'I am created one dotnet project.', 'Everyone', 'Published', GETUTCDATE(), GETUTCDATE()),
(4, 'I learn sql.', 'Everyone', 'Published', GETUTCDATE(), GETUTCDATE()),
(1, '⚙️ The Engineer''s Mindset
Great engineers don''t just build software—they build trust, reliability, and innovation.
Every line of code, every system design, and every technical decision contributes to creating products that solve real-world problems.
#Engineering #SoftwareEngineering #Developer #Programming #Tech #Coding#SoftwareDevelopment #Innovation', 'Everyone', 'Published', GETUTCDATE(), GETUTCDATE()),
(1, 'Technology evolves rapidly, but one platform continues to power everything from enterprise applications to cloud-native services: .NET.
Whether you''re building REST APIs, web applications, desktop software, mobile apps, or microservices, .NET provides the performance, security, and flexibility needed to deliver reliable solutions.
#DotNet #DotNet8 #DotNet9 #CSharp #ASPNETCore', 'Everyone', 'Published', GETUTCDATE(), GETUTCDATE());
