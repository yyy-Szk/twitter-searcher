import * as React from 'react';
import Grid from '@mui/material/Grid';
import Paper from '@mui/material/Paper';
import Button from '@mui/material/Button';
import TextField from '@mui/material/TextField';
import Container from '@mui/material/Container';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Link from '@mui/material/Link';

const ShowUsersContainer = ({ results }) => {
  const userGridItems = results.map((result, index) => (
    <Grid item xs={12} key={`result-${index}`}>
      <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column' }}>
        <Link rel="noopener" href={`https://twitter.com/${result.username}`} target="_blank">
          <Typography variant="h3" mb={2}>
            {result.name}<Typography variant="span" ml={1}>@{result.username}</Typography>
          </Typography>
        </Link>

        <Typography variant="p" mb={2}>
          {result.description}
        </Typography>
        <Typography variant="p" sx={{ textAlign: "right" }}>
          <Typography variant="span">
            フォロー数: {result.public_metrics.following_count} /
            フォロワー数: {result.public_metrics.followers_count} /
            ツイート数: {result.public_metrics.tweet_count}
          </Typography>
        </Typography>
      </Paper>
    </Grid>
  ))

  return (
    <Grid container spacing={3}>
      {userGridItems}
    </Grid>
  )
}

export default ShowUsersContainer