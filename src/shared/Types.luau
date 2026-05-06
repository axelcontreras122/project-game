-- src/shared/Types.luau
local Types = {}

export type PlayerProfile = {
    UserId: number,
    Name: string,
    DisplayName: string,
    Bio: string,
    Interests: {string}, -- ej: {"Gaming", "Desarrollo", "Anime"}
    LikesSent: {[string]: boolean}, -- Diccionario de UserIds a los que dio Like
    Matches: {[string]: boolean},    -- Diccionario de UserIds con los que hay Match
    ChatHistory: {[string]: {{senderId: number, message: string, timestamp: number}}} -- Historial de chats por UserId
}

return Types