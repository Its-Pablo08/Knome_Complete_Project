using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;
using Knome.API.Common;
using Knome.API.DTOs.Abbreviations;
using Knome.API.Interfaces;
using Knome.API.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace Knome.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class AbbreviationsController : ControllerBase
{
    private readonly IAbbreviationService _service;

    public AbbreviationsController(IAbbreviationService service)
    {
        _service = service;
    }

    private int GetCurrentUserId()
    {
        var claim = User.FindFirst("uid")?.Value ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        return int.TryParse(claim, out var id) ? id : 0;
    }

    /// <summary>
    /// Retrieves paginated list of enterprise abbreviations, optionally filtered by keyword or search term.
    /// </summary>
    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<List<AbbreviationDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAbbreviations([FromQuery] string? search = null, [FromQuery] string? keyword = null, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 100)
    {
        var result = await _service.GetAbbreviationsAsync(search, keyword, pageNumber, pageSize);
        return Ok(ApiResponse<List<AbbreviationDto>>.SuccessResponse(200, "Abbreviations retrieved successfully.", result));
    }

    /// <summary>
    /// Gets a single abbreviation by its ID.
    /// </summary>
    [HttpGet("{id:int}")]
    [ProducesResponseType(typeof(ApiResponse<AbbreviationDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(int id)
    {
        var item = await _service.GetByIdAsync(id);
        if (item == null)
            return NotFound(ApiResponse.FailureResponse(404, $"Abbreviation with ID {id} not found."));

        return Ok(ApiResponse<AbbreviationDto>.SuccessResponse(200, "Abbreviation retrieved successfully.", item));
    }

    /// <summary>
    /// Looks up abbreviations by short code or keyword prefix for autocompletion and definition tooltips.
    /// </summary>
    [HttpGet("lookup/{term}")]
    [ProducesResponseType(typeof(ApiResponse<List<AbbreviationDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> Lookup(string term)
    {
        var results = await _service.LookupAsync(term);
        return Ok(ApiResponse<List<AbbreviationDto>>.SuccessResponse(200, "Lookup completed.", results));
    }

    /// <summary>
    /// Creates a new enterprise abbreviation. Keyword is mandatory.
    /// </summary>
    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<AbbreviationDto>), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Create([FromBody] CreateAbbreviationDto dto)
    {
        var created = await _service.CreateAsync(dto, GetCurrentUserId());
        return CreatedAtAction(nameof(GetById), new { id = created.AbbreviationId }, ApiResponse<AbbreviationDto>.SuccessResponse(201, "Abbreviation created successfully.", created));
    }

    /// <summary>
    /// Updates an existing abbreviation.
    /// </summary>
    [HttpPut("{id:int}")]
    [ProducesResponseType(typeof(ApiResponse<AbbreviationDto>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status400BadRequest)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateAbbreviationDto dto)
    {
        var updated = await _service.UpdateAsync(id, dto, GetCurrentUserId());
        return Ok(ApiResponse<AbbreviationDto>.SuccessResponse(200, "Abbreviation updated successfully.", updated));
    }

    /// <summary>
    /// Deletes an abbreviation by ID.
    /// </summary>
    [HttpDelete("{id:int}")]
    [ProducesResponseType(typeof(ApiResponse<bool>), StatusCodes.Status200OK)]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status404NotFound)]
    public async Task<IActionResult> Delete(int id)
    {
        var deleted = await _service.DeleteAsync(id, GetCurrentUserId());
        return Ok(ApiResponse<bool>.SuccessResponse(200, "Abbreviation deleted successfully.", deleted));
    }
}
