import * as React from 'react';
import Button from '@mui/material/Button';
import TextField from '@mui/material/TextField';
import InputBase from '@mui/material/InputBase';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import AuthenticityTokenInput from './AuthenticityTokenInput';

const SearchTweetsForm = ({ authToken }) => {
  const handleSubmit = (event) => {
    event.submit();
  };

  return (
    <>
      {/* こういうページのデスクリプション的なやつは別のpagerにする */}
      <Typography component="p" mb={4}>ユーザーのツイートを、いいね/リツイートの多い順に取得します</Typography>

      <Box component="form" onSubmit={handleSubmit} noValidate action="/twitter_search_processes" method="post" sx={{ mt: 1 }}>
        <Box>
          <TextField
            required
            name="search_conditions[][content]"
            autoComplete="user-url"
            placeholder="検索したいユーザーのURLを入力"
            autoFocus
            style={{ maxWidth: "100%", width: 400 }}
          />
          <Typography
            component="span"
            style={{ verticalAlign: "bottom", margin: "0 10px" }}
          >
            の、過去
          </Typography>

          <TextField
            required
            name="search_conditions[][num_of_days]"
            placeholder="日数を入力"
            autoComplete="num-of-days"
            style={{ maxWidth: "100%" }}
          />
          <Typography
            component="span"
            style={{ verticalAlign: "bottom", margin: "0 10px" }}
          >
            日のツイートを取得
          </Typography>
          
          <InputBase type="hidden" name="search_conditions[][search_type]" value="TwitterUserTimeline" />
        </Box>
        <InputBase type="hidden" name="process_type" value="tweet" />
        <AuthenticityTokenInput authToken={authToken} />

        <Button type="submit" fullWidth variant="contained" sx={{ mt: 3, mb: 2 }}>検索</Button>
      </Box>
    </>
 )
}

export default SearchTweetsForm;