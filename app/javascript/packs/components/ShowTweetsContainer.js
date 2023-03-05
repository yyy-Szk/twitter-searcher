import * as React from 'react';
import Grid from '@mui/material/Grid';
import Paper from '@mui/material/Paper';
import Typography from '@mui/material/Typography';
import Link from '@mui/material/Link';

const ShowTweetsContainer = ({ results, userId }) => {
  const tweetGridItems = results.map((result, index) => {
    const tweetUrl = `https://twitter.com/${userId}/status/${result.id}`

    return (
      <Grid item xs={12} key={`result-${index}`}>
      <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column' }}>
        <Typography variant="p" mb={2}>
          {result.text}
        </Typography>
        <Typography variant="p" mb={1}>
          {
            (() => {
              const d = new Date(result.created_at)

              return d.toLocaleString()
            })()
          }
        </Typography>
        <Typography variant="p" sx={{ textAlign: "right" }}>
          <Typography variant="span">
            いいね数: {result.public_metrics.like_count} /
            リツイート数: {result.public_metrics.retweet_count} /
            引用リツイート数: {result.public_metrics.quote_count} /
            リプライ数: {result.public_metrics.reply_count} /
            インプレッション数: {
              !!result.public_metrics.impression_count ? result.public_metrics.impression_count : "取得できません。"
            }
          </Typography>
        </Typography>

        <Typography variant="p" sx={{ textAlign: "right" }} mt={1}>
          <Link rel="noopener" href={tweetUrl} target="_blank" sx={{ ml: 1 }}>
            <Typography variant="span">元ツイート</Typography>
          </Link>
        </Typography>

      </Paper>
    </Grid>
    )
  })

  return (
    <Grid container spacing={3}>
      {tweetGridItems}
    </Grid>
  )
}

export default ShowTweetsContainer