namespace Knome.API.Interfaces;

public interface IEmailService
{
    Task<bool> SendEmailAsync(string toEmail, string subject, string htmlBody);
    Task<bool> SendEmailAsync(string toEmail, string subject, string htmlBody, string? textBody);
    Task<bool> SendRolePendingEmailAsync(string toEmail, string fullName, string employeeId, string departmentName, string designation);
    Task<bool> SendRoleAssignedEmailAsync(string toEmail, string fullName, string employeeId, string roleName, string departmentName, string? adminComment = null);
    Task SendTemplateEmailAsync(string toEmail, string templateName, object model);
}
