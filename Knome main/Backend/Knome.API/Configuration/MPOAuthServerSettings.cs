namespace Knome.API.Configuration;

/// <summary>
/// Settings for central MPO Employee Hub OpenID Connect / SSO Identity Server.
/// </summary>
public class MPOAuthServerSettings
{
    public string Authority { get; set; } = "https://counselling-1.mponline.demo.gov.in:3001";
    public string ClientId { get; set; } = "Knome-2026";
    public string ClientSecret { get; set; } = "secret_olikl9fqskbjuzjg";
    public string TokenEndpoint { get; set; } = "https://counselling-1.mponline.demo.gov.in:3001/connect/token";
}
