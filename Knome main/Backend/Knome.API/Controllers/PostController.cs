using System.Security.Claims;
using System.Threading.Tasks;
using Knome.API.DTOs.Posts;
using Knome.API.Exceptions;
using Knome.API.Interfaces;
using Knome.API.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace Knome.API.Controllers;

[Authorize]
[ApiController]
[Route("api/posts")]
public class PostController : KnomeControllerBase
{
    private readonly IPostService _postService;

    public PostController(IPostService postService)
    {
        _postService = postService;
    }

    [HttpGet]
    [ProducesResponseType(typeof(ApiResponse<List<PostDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetPosts([FromQuery] string? audienceType, [FromQuery] string? search, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 20)
    {
        var posts = await _postService.GetPostsAsync(audienceType, search, pageNumber, pageSize, GetCurrentUserId());
        return Ok(ApiResponse<List<PostDto>>.SuccessResponse(200, "Posts retrieved successfully.", posts));
    }

    [HttpGet("my")]
    [ProducesResponseType(typeof(ApiResponse<List<PostDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetMyPosts([FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 20)
    {
        var posts = await _postService.GetMyPostsAsync(GetCurrentUserId(), pageNumber, pageSize);
        return Ok(ApiResponse<List<PostDto>>.SuccessResponse(200, "User posts retrieved successfully.", posts));
    }

    [HttpGet("user/{userId:int}")]
    [ProducesResponseType(typeof(ApiResponse<List<PostDto>>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetUserPosts(int userId, [FromQuery] int pageNumber = 1, [FromQuery] int pageSize = 20)
    {
        var posts = await _postService.GetUserPostsAsync(userId, GetCurrentUserId(), pageNumber, pageSize);
        return Ok(ApiResponse<List<PostDto>>.SuccessResponse(200, "User posts retrieved successfully.", posts));
    }

    [HttpGet("{postId:long}")]
    [ProducesResponseType(typeof(ApiResponse<PostDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetPost(long postId)
    {
        var post = await _postService.GetPostAsync(postId, GetCurrentUserId());
        return Ok(ApiResponse<PostDto>.SuccessResponse(200, "Post retrieved successfully.", post));
    }

    [HttpPost]
    [ProducesResponseType(typeof(ApiResponse<PostDto>), StatusCodes.Status201Created)]
    public async Task<IActionResult> CreatePost([FromBody] CreatePostDto dto)
    {
        var result = await _postService.CreatePostAsync(GetCurrentUserId(), dto);
        return CreatedAtAction(nameof(GetPost), new { postId = result.PostId }, ApiResponse<PostDto>.SuccessResponse(201, "Post created successfully.", result));
    }

    [HttpPut("{postId}")]
    [ProducesResponseType(typeof(ApiResponse<PostDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> UpdatePost(long postId, [FromBody] UpdatePostDto dto)
    {
        var result = await _postService.UpdatePostAsync(postId, GetCurrentUserId(), dto);
        return Ok(ApiResponse<PostDto>.SuccessResponse(200, "Post updated successfully.", result));
    }

    [HttpDelete("{postId}")]
    [ProducesResponseType(typeof(ApiResponse), StatusCodes.Status200OK)]
    public async Task<IActionResult> DeletePost(long postId)
    {
        await _postService.DeletePostAsync(postId, GetCurrentUserId());
        return Ok(ApiResponse.SuccessResponse(200, "Post deleted successfully."));
    }

    [HttpPost("{postId:long}/view")]
    [ProducesResponseType(typeof(ApiResponse<int>), StatusCodes.Status200OK)]
    public async Task<IActionResult> RecordView(long postId)
    {
        var newCount = await _postService.IncrementViewCountAsync(postId, GetCurrentUserId());
        return Ok(ApiResponse<int>.SuccessResponse(200, "Post view recorded.", newCount));
    }
}
