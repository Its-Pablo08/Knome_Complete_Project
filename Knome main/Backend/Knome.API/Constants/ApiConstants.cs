namespace Knome.API.Constants;

public static class ApiConstants
{
    public const string CorsPolicyName = "KnomeCorsPolicy";
    
    public static class Messages
    {
        public const string Success = "Request completed successfully.";
        public const string ValidationError = "One or more validation failures occurred.";
        public const string InternalServerError = "An unexpected error occurred on the server.";
        public const string NotFound = "The requested resource was not found.";
        public const string BadRequest = "The request was invalid or cannot be processed.";
        public const string Conflict = "A conflict occurred with the current state of the resource.";
    }
}
