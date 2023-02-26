import * as React from 'react';
import Grid from '@mui/material/Grid';
import Paper from '@mui/material/Paper';

import SearchUsersForm from './SearchUsersForm';

const SearchUsersContainer = ({ authToken }) => {
  return (
    <Grid container spacing={3}>
      <Grid item xs={12}>
        <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column' }}>
          <SearchUsersForm authToken={authToken} />
        </Paper>
      </Grid>
    </Grid>
  )
}

export default SearchUsersContainer