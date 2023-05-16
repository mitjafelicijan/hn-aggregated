local https = require("ssl.https")
local ltn12 = require("ltn12")
local cjson = require("cjson")
local config = require("config")

local function trim(str)
    return str:gsub("^%s*(.-)%s*$", "%1")
end

local function sanitizeText(text)
    if text == nil then
        return ""
    end

    local sanitizedText = text

    sanitizedText = sanitizedText:gsub("<[^>]+>", "")
    -- sanitizedText = sanitizedText:gsub("&gt;", ">")
    -- sanitizedText = sanitizedText:gsub("&lt;", "<")

    sanitizedText = trim(sanitizedText)

    return sanitizedText
end

local function fetchSingleItem(id)
    local url = string.format("https://hacker-news.firebaseio.com/v0/item/%d.json", id)

    local response = {}
    local story = {}

    local _, status, headers = https.request {
        url = url,
        method = "GET",
        sink = ltn12.sink.table(response)
    }

    if status == 200 then
        local responseBody = table.concat(response)
        story = cjson.decode(responseBody)

    else
        print("HTTPS request failed. Status:", status)
    end

    return story
end

local function fetchTopStories()
    local url = "https://hacker-news.firebaseio.com/v0/topstories.json"

    local response = {}
    local stories = {}

    local _, status, headers = https.request {
        url = url,
        method = "GET",
        sink = ltn12.sink.table(response)
    }

    if status == 200 then
        local responseBody = table.concat(response)
        stories = cjson.decode(responseBody)

    else
        print("HTTPS request failed. Status:", status)
    end

    return stories
end

local aggregate = {}
local topStories = fetchTopStories()
for i, v in ipairs(topStories) do
    if i <= config.numberOfStories then
        local story = fetchSingleItem(v)

        if story.type == "story" then

            print("Fetching story:", story.id)

            -- Fetch the comments for the story.
            local comments = {}
            if story.kids then
                for i, v in ipairs(story.kids) do
                    local comment = fetchSingleItem(v)

                    if comment.type == "comment" then
                        table.insert(comments, {
                            id = comment.id,
                            text = sanitizeText(comment.text),
                            by = comment.by,
                            time = os.date("%H:%M", comment.time)
                        })
                    end
                end
            end

            -- Add the story to the aggregate table.
            table.insert(aggregate, {
                id = story.id,
                title = story.title,
                url = story.url,
                score = story.score,
                by = story.by,
                time = os.date("%H:%M", story.time),
                comments = comments
            })
        end
    else
        break
    end
end

-- Save the JSON data to a file
local file = io.open("top-stories.json", "w")
if file then
    file:write(cjson.encode(aggregate))
    file:close()
    print("JSON data saved to file.")
else
    print("Failed to open the file.")
end
