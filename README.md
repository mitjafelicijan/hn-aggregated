# HN Aggregated

Aggreagated Hacker News stories into single JSON files.

Use this as a Cron job to keep your local copy or API endpoints of HN up to date.

## Usage

Use `crontab -e` to edit your crontab file and add the following line:

```
0 * * * * cd /path/to/hn-aggregated && lua top-stories.sh
```

This will run the script every hour and create a new JSON files in the directy `/path/to/hn-aggregated`.

Check `config.lua` to see options for the scripts.
