using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Threading.Tasks;
using Knome.API.Data;
using Knome.API.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Knome.API.Repositories;

public class Repository<T> : IRepository<T> where T : class
{
    protected readonly KnomeDbContext Context;
    protected readonly DbSet<T> DbSet;

    public Repository(KnomeDbContext context)
    {
        Context = context ?? throw new ArgumentNullException(nameof(context));
        DbSet = context.Set<T>();
    }

    public async Task<T?> GetByIdAsync(object id)
    {
        return await DbSet.FindAsync(id);
    }

    public async Task<IEnumerable<T>> GetAllAsync()
    {
        return await DbSet.ToListAsync();
    }

    public async Task<IEnumerable<T>> FindAsync(Expression<Func<T, bool>> predicate)
    {
        return await DbSet.Where(predicate).ToListAsync();
    }

    public async Task AddAsync(T entity)
    {
        await DbSet.AddAsync(entity);
    }

    public void Update(T entity)
    {
        DbSet.Update(entity);
    }

    public void Remove(T entity)
    {
        DbSet.Remove(entity);
    }
}
