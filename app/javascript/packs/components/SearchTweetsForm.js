import * as React from 'react';
import Button from '@mui/material/Button';
import TextField from '@mui/material/TextField';
import InputBase from '@mui/material/InputBase';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import AuthenticityTokenInput from './AuthenticityTokenInput';

const SearchTweetsForm = ({ authToken, setInProgress }) => {
  const contentInputRef = React.useRef(null);
  const numOfDaysInputRef = React.useRef(null);
  const [contentInputError, setContentInputError] = React.useState(false);
  const [numOfDaysInputError, setNumOfDaysInputError] = React.useState(false);

  const validate = () => {
    const contentRef = contentInputRef.current;
    const numOfDaysRef = numOfDaysInputRef.current;
    if (!contentRef || !numOfDaysRef) return

    contentRef.validity.valid ? setContentInputError(false) : setContentInputError(true)
    numOfDaysRef.validity.valid ? setNumOfDaysInputError(false) : setNumOfDaysInputError(true)

    return  (contentRef.validity.valid && numOfDaysRef.validity.valid)
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!validate()) return

    setInProgress(true);
    document.getElementById('tweets-form').submit();
  };


  return (
    <>
      {/* こういうページのデスクリプション的なやつは別のpagerにする */}
      <Typography component="p" mb={4}>ユーザーのツイートを、いいね/リツイートの多い順に取得します（最大365日まで）</Typography>

      <Box component="form" id="tweets-form" onSubmit={handleSubmit} noValidate action="/twitter_search_processes" method="post" sx={{ mt: 1 }} target="_blank">
        <Box>
          <TextField
            required
            name="search_conditions[][content]"
            autoComplete="user-url"
            placeholder="検索したいユーザーのURLを入力"
            autoFocus
            style={{ maxWidth: "100%", width: 400 }}
            error={contentInputError}
            inputProps={{ required: true }}
            inputRef={contentInputRef}
            helperText={contentInputRef?.current?.validationMessage}
          />
          <Typography
            component="span"
            style={{ verticalAlign: "bottom", margin: "0 10px" }}
          >
            の、過去
          </Typography>

          <TextField
            required
            type="number"
            name="search_conditions[][num_of_days]"
            placeholder="日数を入力"
            autoComplete="num-of-days"
            style={{ maxWidth: "100%" }}
            error={numOfDaysInputError}
            inputProps={{ required: true, min: 1, max: 365 }}
            inputRef={numOfDaysInputRef}
            helperText={numOfDaysInputRef?.current?.validationMessage}
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