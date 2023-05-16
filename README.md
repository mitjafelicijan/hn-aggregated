# HN Aggregated

Aggreagated Hacker News stories into single JSON files.

Use this as a Cron job to keep your local copy or API endpoints of HN up to date.

This project is using the [Hacker News API](https://github.com/HackerNews/API) under the hood.

## Usage

Before running the script, make sure you have the following dependencies installed:

- [Lua](https://www.lua.org/)
- [LuaRocks](https://luarocks.org/)

Then install the following Lua packages:

```sh
[sudo] luarocks install lua-cjson
```

Use `crontab -e` to edit your crontab file and add the following line:

```text
0 * * * * cd /path/to/hn-aggregated && lua top-stories.sh
```

This will run the script every hour and create a new JSON files in the directy `/path/to/hn-aggregated`.

Check `config.lua` to see options for the scripts.

For 50 top stories, the script takes about 6 minute to run.
