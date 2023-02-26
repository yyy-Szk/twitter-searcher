import * as React from 'react';
import Button from '@mui/material/Button';
import FormControl from '@mui/material/FormControl';
import TextField from '@mui/material/TextField';
import InputBase from '@mui/material/InputBase';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Select from '@mui/material/Select';
import MenuItem from '@mui/material/MenuItem';
import AuthenticityTokenInput from './AuthenticityTokenInput';

const mainConditionMinSize = 1
const mainConditionMaxSize = 5
const narrowConditionMinSize = 0
const narrowConditionMaxSize = 5

const MainConditionContainer = () => {
  const [type, setType] = React.useState("FollowingUser")
  const handleChange = (e) => setType(e.target.value)

  const mainSearchTypes = [
    { name: "フォロワーであるユーザー", value: "FollowingUser" },
    { name: "ツイートをいいねしたユーザー", value: "LikedTweetUser" },
    { name: "フォローしているユーザー", value: "FollowedUser" },
    { name: "いいねしたユーザー", value: "LikingUser" }
  ]
  const mainSearchTypeContainer = mainSearchTypes.map(({ name, value }) =>
    <MenuItem value={value} key={`main-${value}`}>{name}</MenuItem>
  )
  const displayNumOfDays = ["LikedTweetUser", "LikingUser"].includes(type)

  return (
    <Box mb={2}>
      <TextField
        required
        name="search_conditions[][content]"
        autoComplete="user-url"
        placeholder="検索したいユーザーのURLを入力"
        autoFocus
        style={{ width: 400, maxWidth: "100%" }}
      />
      <Typography
        component="span"
        style={{ verticalAlign: "bottom", margin: "0 10px" }}
      >
        の
      </Typography>

      <Select value={type} onChange={handleChange}>{mainSearchTypeContainer}</Select>
      <InputBase type="hidden" name="search_conditions[][search_type]" value={type} />

      {
        displayNumOfDays &&
        <>
          <Typography component="span" style={{ verticalAlign: "bottom", margin: "0 10px" }}>
            （直近
          </Typography>
          <TextField
            required
            name="search_conditions[][num_of_days]"
            autoFocus
            style={{ width: 70, maxWidth: "100%" }}
          />
          <Typography component="span" style={{ verticalAlign: "bottom", margin: "0 10px" }}>
            日）
          </Typography>
        </>
      }
    </Box>
  )
}

const NarrowConditionContainer = () => {
  const [type, setType] = React.useState("FollowingUser")
  const handleChange = (e) => setType(e.target.value)

  const narrowSearchTypes = [
    { name: "フォロワーであるユーザー", value: "FollowingUser" },
    { name: "フォロワーではないユーザー", value: "NotFollowingUser" },
    { name: "ツイートをいいねしたユーザー", value: "LikedTweetUser" },
    { name: "ツイートをいいねしていないユーザー", value: "NotLikedTweetUser" },
    { name: "文字をプロフィールに含むユーザー", value: "IncludedWordInProfileUser" },
    { name: "文字をプロフィールに含まないユーザー", value: "NotIncludedWordInProfileUser" },
    { name: "フォローしているユーザー", value: "FollowedUser" },
    { name: "いいねしたユーザー", value: "LikingUser" }
  ]
  const narrowSearchTypeContainer = narrowSearchTypes.map(({ name, value }) =>
    <MenuItem value={value} key={`narrow-${value}`}>{name}</MenuItem>
  )
  const displayNumOfDays = ["LikedTweetUser", "NotLikedTweetUser", "LikingUser"].includes(type)

  return (
    <Box mb={2}>
      <TextField
        required
        name="narrow_conditions[][content]"
        autoComplete="user-url"
        placeholder="検索したいユーザーのURLを入力"
        autoFocus
        style={{ width: 400, maxWidth: "100%" }}
      />
      <Typography
        component="span"
        style={{ verticalAlign: "bottom", margin: "0 10px" }}
      >
        の
      </Typography>

      <Select value={type} onChange={handleChange}>{narrowSearchTypeContainer}</Select>
      <InputBase type="hidden" name="narrow_conditions[][search_type]" value={type} />

      {
        displayNumOfDays &&
        <>
          <Typography component="span" style={{ verticalAlign: "bottom", margin: "0 10px" }}>
            （直近
          </Typography>
          <TextField
            required
            name="narrow_conditions[][num_of_days]"
            autoFocus
            style={{ width: 70, maxWidth: "100%" }}
          />
          <Typography component="span" style={{ verticalAlign: "bottom", margin: "0 10px" }}>
            日）
          </Typography>
        </>
      }
  </Box>
  )
}

const SearchUsersForm = ({ authToken }) => {
  const handleSubmit = (event) => {
    event.submit();
  };
  const [mainConditionCount, setMainConditionCount] = React.useState(mainConditionMinSize)
  const [narrowConditionCount, setNarrowConditionCount] = React.useState(narrowConditionMinSize)

  return (
    <>
      {/* こういうページのデスクリプション的なやつは別のpagerにする */}
      <Typography component="h2" mb={4}>条件を指定してユーザーを検索し、マッチしたユーザーの情報を取得します</Typography>

      <Box component="form" onSubmit={handleSubmit} noValidate action="/twitter_search_processes" method="post" sx={{ mt: 1 }}>
        {
          [...Array(mainConditionCount)].map((_, i) =>
            <MainConditionContainer key={`main-condition-${i}`} containerKey={""} />
          )
        }
        
        {
          mainConditionCount < mainConditionMaxSize &&
            <Button variant="outlined" sx={{ mt: 3, mb: 2, mr: 1 }} onClick={() => setMainConditionCount(mainConditionCount + 1)}>+</Button>
        }
        {
          mainConditionCount > mainConditionMinSize &&
            <Button variant="outlined" sx={{ mt: 3, mb: 2 }} onClick={() => setMainConditionCount(mainConditionCount - 1)}>-</Button>
        }

        <p>絞り込み条件</p>

        {
          [...Array(narrowConditionCount)].map((_, i) =>
            <NarrowConditionContainer key={`narrow-condition-${i}`} />
          )
        }

        {
          narrowConditionCount < narrowConditionMaxSize &&
            <Button variant="outlined" sx={{ mt: 3, mb: 2, mr: 1 }} onClick={() => setNarrowConditionCount(narrowConditionCount + 1)}>+</Button>
        }
        {
          narrowConditionCount > narrowConditionMinSize &&
            <Button variant="outlined" sx={{ mt: 3, mb: 2 }} onClick={() => setNarrowConditionCount(narrowConditionCount - 1)}>-</Button>
        }

        <InputBase type="hidden" name="process_type" value="user" />
        <AuthenticityTokenInput authToken={authToken} />

        <Button type="submit" fullWidth variant="contained" sx={{ mt: 3, mb: 2 }}>検索</Button>
      </Box>
    </>
 )
}

export default SearchUsersForm;
