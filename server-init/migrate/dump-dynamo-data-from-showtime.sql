SELECT
  format('INSERT INTO dynamo.image_request (id, twitch_user_id, broadcast_id, screening_id, style, inputs, prompt, created_at, finished_at, error_message) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s) ON CONFLICT (id) DO NOTHING;',
    format('''%s''', id),
    format('''%s''', twitch_user_id),
    case when screening_id is not null
      then (SELECT screening.broadcast_id FROM showtime.screening WHERE screening.id = screening_id)::text
      else 'NULL'
    end,
    case when screening_id is not null
      then format('''%s''', screening_id)
      else 'NULL'
    end,
    '''ghost''',
    format('''{"subject":"%s"}''::jsonb', replace(subject_noun_clause, '''', '''''')),
    format('''%s''', replace(prompt, '''', '''''')),
    format('''%s''::timestamptz', created_at),
    case when finished_at is not null
        then format('''%s''::timestamptz', finished_at)
        else 'NULL'
    end,
    case when error_message is not null
        then format('''%s''', replace(error_message, '''', ''''''))
        else 'NULL'
    end
  )
FROM showtime.image_request
ORDER BY created_at;

SELECT
  format('INSERT INTO dynamo.image (image_request_id, index, url) VALUES (''%s'', 0, ''%s'') ON CONFLICT (image_request_id, index) DO NOTHING;',
    image_request_id,
    url
  )
FROM showtime.image;
