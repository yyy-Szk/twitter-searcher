import * as React from 'react';
import Button from '@mui/material/Button';
import FormControl from '@mui/material/FormControl';
import TextField from '@mui/material/TextField';
import InputBase from '@mui/material/InputBase';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Select from '@mui/material/Select';
import MenuItem from '@mui/material/MenuItem';
import Checkbox from '@mui/material/Checkbox'
import AuthenticityTokenInput from './AuthenticityTokenInput';

const mainConditionMinSize = 1
const mainConditionMaxSize = 5
const narrowConditionMinSize = 0
const narrowConditionMaxSize = 5

const MainConditionContainer = ({ validationInfo }) => {
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
        error={validationInfo.contentInputError}
        inputProps={{ required: true }}
        inputRef={validationInfo.contentInputRef}
        helperText={validationInfo.contentInputRef?.current?.validationMessage}
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
            type="number"
            name="search_conditions[][num_of_days]"
            autoFocus
            style={{ maxWidth: "100%" }}
            error={validationInfo.numOfDaysInputError}
            inputProps={{ required: true, min: 1, max: 365 }}
            inputRef={validationInfo.numOfDaysInputRef}
            helperText={validationInfo.numOfDaysInputRef?.current?.validationMessage}
          />
          <Typography component="span" style={{ verticalAlign: "bottom", margin: "0 10px" }}>
            日）
          </Typography>
        </>
      }
    </Box>
  )
}

const NarrowConditionContainer = ({ validationInfo }) => {
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
        error={validationInfo.contentInputError}
        inputProps={{ required: true }}
        inputRef={validationInfo.contentInputRef}
        helperText={validationInfo.contentInputRef?.current?.validationMessage}
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
            type="number"
            name="narrow_conditions[][num_of_days]"
            autoFocus
            style={{ maxWidth: "100%" }}
            error={validationInfo.numOfDaysInputError}
            inputProps={{ required: true, min: 1, max: 365 }}
            inputRef={validationInfo.numOfDaysInputRef}
            helperText={validationInfo.numOfDaysInputRef?.current?.validationMessage}
          />
          <Typography component="span" style={{ verticalAlign: "bottom", margin: "0 10px" }}>
            日）
          </Typography>
        </>
      }
  </Box>
  )
}

const SearchUsersForm = ({ authToken, setInProgress }) => {
  const [mainConditionCount, setMainConditionCount] = React.useState(mainConditionMinSize)
  const [narrowConditionCount, setNarrowConditionCount] = React.useState(narrowConditionMinSize)
  const [removeFollowingUser, setRemoveFollowingUser] = React.useState(false)

  const mainValidationInfo = [...Array(mainConditionMaxSize)].map((_) => {
    const contentInputRef = React.useRef(null);
    const numOfDaysInputRef = React.useRef(null);
    const [contentInputError, setContentInputError] = React.useState(false);
    const [numOfDaysInputError, setNumOfDaysInputError] = React.useState(false);

    return { contentInputRef, numOfDaysInputRef, contentInputError, setContentInputError,
             numOfDaysInputError, setNumOfDaysInputError }
  })

  const narrowValidationInfo = [...Array(narrowConditionMaxSize)].map((_) => {
    const contentInputRef = React.useRef(null);
    const numOfDaysInputRef = React.useRef(null);
    const [contentInputError, setContentInputError] = React.useState(false);
    const [numOfDaysInputError, setNumOfDaysInputError] = React.useState(false);

    return { contentInputRef, numOfDaysInputRef, contentInputError, setContentInputError,
             numOfDaysInputError, setNumOfDaysInputError }
  })

  const validate = () => {
    const mainConditionValidations = [...Array(mainConditionCount)].map((_, i) => {
      const { contentInputRef, numOfDaysInputRef, setContentInputError, setNumOfDaysInputError } = mainValidationInfo[i]
      const [contentRef, numOfDaysRef] = [contentInputRef.current, numOfDaysInputRef.current]

      const contentInputResult = contentRef.validity.valid ? false : true
      const numOfDaysInputResult = !!numOfDaysRef ? (numOfDaysRef.validity.valid ? false : true) : false

      setContentInputError(contentInputResult)
      setNumOfDaysInputError(numOfDaysInputResult)

      return (!contentInputResult && !numOfDaysInputResult)
    })

    const narrowConditionValidations = [...Array(narrowConditionCount)].map((_, i) => {
      const { contentInputRef, numOfDaysInputRef, setContentInputError, setNumOfDaysInputError } = narrowValidationInfo[i]
      const [contentRef, numOfDaysRef] = [contentInputRef.current, numOfDaysInputRef.current]

      const contentInputResult = contentRef.validity.valid ? false : true
      const numOfDaysInputResult = !!numOfDaysRef ? (numOfDaysRef.validity.valid ? false : true) : false

      setContentInputError(contentInputResult)
      setNumOfDaysInputError(numOfDaysInputResult)

      return (!contentInputResult && !numOfDaysInputResult)
    })

    return (mainConditionValidations.every(v => v) && narrowConditionValidations.every(v => v))
  }

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!validate()) return

    setInProgress(true);
    document.getElementById('users-form').submit();
  };

  return (
    <>
      {/* こういうページのデスクリプション的なやつは別のpagerにする */}
      <Typography component="h2" mb={4}>条件を指定してユーザーを検索し、マッチしたユーザーの情報を取得します</Typography>

      <Box component="form" id="users-form" onSubmit={handleSubmit} noValidate action="/twitter_search_processes" method="post" sx={{ mt: 1 }} target="_blank">
        {
          [...Array(mainConditionCount)].map((_, i) =>
            <MainConditionContainer key={`main-condition-${i}`} validationInfo={mainValidationInfo[i]} />
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
            <NarrowConditionContainer key={`narrow-condition-${i}`} validationInfo={narrowValidationInfo[i]} />
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

        <Box>
          <Checkbox onChange={() => setRemoveFollowingUser(!removeFollowingUser)} />
          <Typography component="span">フォロー済みのユーザーを表示しない</Typography>
          <InputBase type="hidden" name="remove_following_user" value={removeFollowingUser} />
        </Box>

        <InputBase type="hidden" name="process_type" value="user" />
        <AuthenticityTokenInput authToken={authToken} />

        <Button type="submit" fullWidth variant="contained" sx={{ mt: 3, mb: 2 }}>検索</Button>
      </Box>
    </>
 )
}

export default SearchUsersForm;
