using System;
using System.Collections.Generic;

namespace Knome.API.Models;

public partial class ConnectionRequest
{
    public int RequestId { get; set; }

    public int SenderId { get; set; }

    public int ReceiverId { get; set; }

    public string Status { get; set; } = null!;

    public DateTime CreatedDate { get; set; }

    public DateTime UpdatedDate { get; set; }

    public virtual User Receiver { get; set; } = null!;

    public virtual User Sender { get; set; } = null!;
}
