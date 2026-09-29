/**
 * Calculates the engagement score for a post based on defined weights.
 * FR-HP-01: (Views × 1) + (Reactions × 3) + (Comments × 5) + (Shares × 4)
 */
export function calculateEngagementScore(views = 0, reactions = 0, comments = 0, shares = 0) {
    const WEIGHTS = {
        VIEWS: 1,
        REACTIONS: 3,
        COMMENTS: 5,
        SHARES: 4
    };

    return (views * WEIGHTS.VIEWS) + 
           (reactions * WEIGHTS.REACTIONS) + 
           (comments * WEIGHTS.COMMENTS) + 
           (shares * WEIGHTS.SHARES);
}
