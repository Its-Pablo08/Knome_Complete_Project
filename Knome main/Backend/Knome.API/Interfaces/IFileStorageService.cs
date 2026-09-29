using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;

namespace Knome.API.Interfaces;

/// <summary>
/// Storage abstraction for saving and removing profile images.
/// Decouples controllers and domain logic from physical storage providers (local disk, GCS, Azure Blob, etc.).
/// </summary>
public interface IFileStorageService
{
    Task<string> SaveProfileImageAsync(int userId, IFormFile file);
    Task<string> SaveMediaAsync(IFormFile file, string mediaType);
    Task DeleteProfileImageAsync(string fileUrl);
}
