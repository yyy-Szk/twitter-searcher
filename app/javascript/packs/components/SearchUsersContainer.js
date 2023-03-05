import * as React from 'react';
import Grid from '@mui/material/Grid';
import Paper from '@mui/material/Paper';
import Link from '@mui/material/Link';
import Box from '@mui/material/Box';

import SearchUsersForm from './SearchUsersForm';

const SearchUsersContainer = ({ authToken, inProgress, setInProgress, activeProcessId }) => {
  return (
    <Grid container spacing={3}>
      <Grid item xs={12}>
        <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column' }}>
          {
            inProgress ?
              <Box>
                検索処理が進行中です{!!activeProcessId && <Link href={`/twitter_search_processes/${activeProcessId}`} target="_blank">（詳細ページ）</Link>}
              </Box>
            :
              <SearchUsersForm authToken={authToken} setInProgress={setInProgress} />
          }
        </Paper>
      </Grid>
    </Grid>
  )
}

export default SearchUsersContainer