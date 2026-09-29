using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Threading.Tasks;
using Knome.API.Exceptions;
using Knome.API.Interfaces;
using Knome.API.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace Knome.API.Controllers;

public class UploadMediaDto
{
    public IFormFile File { get; set; } = null!;
    public string Type { get; set; } = "doc";
}

[Authorize]
[ApiController]
[Route("api/media")]
public class MediaController : KnomeControllerBase
{
    private readonly IFileStorageService _fileStorageService;
    private readonly IConfiguration _configuration;
    private readonly ILogger<MediaController> _logger;
    private static readonly object _fileLock = new();

    public MediaController(
        IFileStorageService fileStorageService,
        IConfiguration configuration,
        ILogger<MediaController> logger)
    {
        _fileStorageService = fileStorageService;
        _configuration = configuration;
        _logger = logger;
    }

    [HttpPost("upload")]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(500L * 1024L * 1024L)]
    [RequestFormLimits(MultipartBodyLengthLimit = 500L * 1024L * 1024L)]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status200OK)]
    public async Task<IActionResult> UploadMedia([FromForm] UploadMediaDto dto)
    {
        if (dto.File == null)
            throw new BadRequestException("No file provided.");

        var url = await _fileStorageService.SaveMediaAsync(dto.File, dto.Type);
        
        return Ok(ApiResponse<object>.SuccessResponse(200, "File uploaded successfully.", new { url }));
    }

    private string GetPendingFilePath()
    {
        var basePath = _configuration["StorageSettings:BasePath"];
        if (string.IsNullOrWhiteSpace(basePath) || !Directory.Exists(basePath))
        {
            basePath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
        }
        var dir = Path.Combine(basePath, "uploads");
        if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
        return Path.Combine(dir, "pending_media_approvals.json");
    }

    [HttpGet("pending")]
    [ProducesResponseType(typeof(ApiResponse<List<JsonElement>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetPendingMedia()
    {
        var filePath = GetPendingFilePath();
        if (!System.IO.File.Exists(filePath))
        {
            return Ok(ApiResponse<List<JsonElement>>.SuccessResponse(200, "Pending media retrieved.", new List<JsonElement>()));
        }

        try
        {
            var json = await System.IO.File.ReadAllTextAsync(filePath);
            var list = JsonSerializer.Deserialize<List<JsonElement>>(json) ?? new List<JsonElement>();
            return Ok(ApiResponse<List<JsonElement>>.SuccessResponse(200, "Pending media retrieved.", list));
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed reading pending media approvals");
            return Ok(ApiResponse<List<JsonElement>>.SuccessResponse(200, "Pending media retrieved.", new List<JsonElement>()));
        }
    }

    [HttpPost("pending")]
    [ProducesResponseType(typeof(ApiResponse<object>), StatusCodes.Status201Created)]
    public IActionResult AddPendingMedia([FromBody] JsonElement item)
    {
        var filePath = GetPendingFilePath();
        List<JsonElement> list = new();

        lock (_fileLock)
        {
            if (System.IO.File.Exists(filePath))
            {
                try
                {
                    var json = System.IO.File.ReadAllText(filePath);
                    list = JsonSerializer.Deserialize<List<JsonElement>>(json) ?? new List<JsonElement>();
                }
                catch
                {
                    list = new List<JsonElement>();
                }
            }

            list.Insert(0, item);
            var updatedJson = JsonSerializer.Serialize(list, new JsonSerializerOptions { WriteIndented = true });
            System.IO.File.WriteAllText(filePath, updatedJson);
        }

        return Ok(ApiResponse<object>.SuccessResponse(201, "Media submitted for approval.", item));
    }

    [HttpDelete("pending/{id}")]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status200OK)]
    public IActionResult RemovePendingMedia(string id)
    {
        var filePath = GetPendingFilePath();
        lock (_fileLock)
        {
            if (System.IO.File.Exists(filePath))
            {
                try
                {
                    var json = System.IO.File.ReadAllText(filePath);
                    using var doc = JsonDocument.Parse(json);
                    var filtered = new List<JsonElement>();
                    foreach (var el in doc.RootElement.EnumerateArray())
                    {
                        if (el.TryGetProperty("id", out var idProp) && idProp.GetString() == id)
                            continue;
                        filtered.Add(el.Clone());
                    }

                    var updatedJson = JsonSerializer.Serialize(filtered, new JsonSerializerOptions { WriteIndented = true });
                    System.IO.File.WriteAllText(filePath, updatedJson);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed removing pending media {Id}", id);
                }
            }
        }

        return Ok(ApiResponse.SuccessResponse(200, "Pending media removed successfully."));
    }
}
