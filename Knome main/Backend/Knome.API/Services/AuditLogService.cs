using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using AutoMapper;
using Knome.API.DTOs.Audit;
using Knome.API.DTOs.User;
using Knome.API.Interfaces;
using Knome.API.Models;

namespace Knome.API.Services;

public class AuditLogService : IAuditLogService
{
    private readonly IAuditLogRepository _repository;
    private readonly IMapper _mapper;

    public AuditLogService(IAuditLogRepository repository, IMapper mapper)
    {
        _repository = repository;
        _mapper = mapper;
    }

    public async Task RecordAsync(
        int actorUserId,
        string action,
        string targetType,
        long targetId,
        string? reason = null,
        string? ipAddress = null)
    {
        await _repository.AddAsync(new AuditLog
        {
            ActorUserId = actorUserId,
            Action = action,
            TargetType = targetType,
            TargetId = targetId,
            Reason = reason,
            Ipaddress = ipAddress,
            Timestamp = Knome.API.Common.KnomeTime.Now
        });
    }

    public async Task<AuditLogDto?> GetByIdAsync(long auditId)
    {
        var entry = await _repository.GetByIdAsync(auditId);
        return entry is null ? null : _mapper.Map<AuditLogDto>(entry);
    }

    public async Task<PagedResultDto<AuditLogDto>> GetPagedAsync(AuditLogFilterDto filter)
    {
        var paged = await _repository.GetPagedAsync(filter);
        var dtos = _mapper.Map<List<AuditLogDto>>(paged.Items);
        return new PagedResultDto<AuditLogDto>(dtos, paged.TotalCount, paged.PageNumber, paged.PageSize);
    }
}
