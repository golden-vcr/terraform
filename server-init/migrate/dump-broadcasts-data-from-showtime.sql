SELECT
  format('INSERT INTO broadcasts.broadcast (id, started_at, ended_at, vod_url) VALUES (%s, %s, %s, %s) ON CONFLICT (id) DO UPDATE SET started_at = EXCLUDED.started_at, ended_at = EXCLUDED.ended_at, vod_url = EXCLUDED.vod_url;',
    id,
    format('''%s''::timestamptz', started_at),
    case when ended_at is not null
        then format('''%s''::timestamptz', ended_at)
        else 'NULL'
    end,
    case when vod_url is not null
        then format('''%s''', vod_url)
        else 'NULL'
    end
  )
FROM showtime.broadcast
ORDER BY started_at;

SELECT
  format('INSERT INTO broadcasts.screening (id, broadcast_id, tape_id, started_at, ended_at) VALUES (''%s'', %s, %s, ''%s'', %s) ON CONFLICT (id) DO UPDATE SET broadcast_id = EXCLUDED.broadcast_id, tape_id = EXCLUDED.tape_id, started_at = EXCLUDED.started_at, ended_at = EXCLUDED.ended_at;',
    id,
    broadcast_id,
    tape_id,
    started_at,
    case when ended_at is not null
        then format('''%s''::timestamptz', ended_at)
        else 'NULL'
    end
  )
FROM showtime.screening
ORDER BY started_at;
