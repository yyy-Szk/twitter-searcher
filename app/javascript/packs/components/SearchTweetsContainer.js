import * as React from 'react';
import Grid from '@mui/material/Grid';
import Paper from '@mui/material/Paper';

import SearchTweetsForm from './SearchTweetsForm';

const SearchTweetsContainer = ({ authToken }) => {
  return (
    <Grid container spacing={3}>
      <Grid item xs={12}>
        <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column' }}>
          <SearchTweetsForm authToken={authToken} />
        </Paper>
      </Grid>
    </Grid>
  )
}

export default SearchTweetsContainer