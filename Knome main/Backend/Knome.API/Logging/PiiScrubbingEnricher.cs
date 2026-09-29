using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using Serilog.Core;
using Serilog.Events;

namespace Knome.API.Logging;

public class PiiScrubbingEnricher : ILogEventEnricher
{
    private static readonly HashSet<string> SensitiveKeys = new(StringComparer.OrdinalIgnoreCase)
    {
        "Password", "NewPassword", "OldPassword", "PasswordHash",
        "Token", "RefreshToken", "Authorization", "Secret", "SecretKey"
    };

    private static readonly Regex BearerRegex = new(@"Bearer\s+[A-Za-z0-9\-\._~\+\/]+", RegexOptions.Compiled | RegexOptions.IgnoreCase);

    public void Enrich(LogEvent logEvent, ILogEventPropertyFactory propertyFactory)
    {
        var propertiesToUpdate = new List<LogEventProperty>();

        foreach (var prop in logEvent.Properties)
        {
            if (SensitiveKeys.Contains(prop.Key))
            {
                propertiesToUpdate.Add(new LogEventProperty(prop.Key, new ScalarValue("[REDACTED]")));
            }
            else if (prop.Value is ScalarValue scalar && scalar.Value is string strVal && strVal.Contains("Bearer ", StringComparison.OrdinalIgnoreCase))
            {
                var scrubbed = BearerRegex.Replace(strVal, "Bearer [REDACTED]");
                propertiesToUpdate.Add(new LogEventProperty(prop.Key, new ScalarValue(scrubbed)));
            }
        }

        foreach (var prop in propertiesToUpdate)
        {
            logEvent.AddOrUpdateProperty(prop);
        }
    }
}
