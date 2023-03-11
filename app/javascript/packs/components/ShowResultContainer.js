import * as React from 'react';
import Paper from '@mui/material/Paper';
import Grid from '@mui/material/Grid';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Link from '@mui/material/Link';
import Button from '@mui/material/Button';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import ShowTweetsContainer from './ShowTweetsContainer';
import ShowUsersContainer from './ShowUsersContainer';

const theme = createTheme();

// theme.typography.h3 = {
//   fontSize: '1.2rem',
//   '@media (min-width:600px)': {
//     fontSize: '1.5rem',
//   },
//   [theme.breakpoints.up('md')]: {
//     fontSize: '2.4rem',
//   },
// };

theme.typography.h3 = {
  fontSize: '1.2rem'
};
theme.typography.h4 = {
  fontSize: '1.0rem'
};
theme.typography.p = {
  display: "block",
  wordWrap: "break-word"
};
theme.typography.span = {
  fontSize: "0.8rem",
  wordWrap: "break-word"
};
theme.typography.a = {
  wordWrap: "break-word"
};

const conditionTypeJa = {
  "FollowingUser": "フォロワーであるユーザー",
  "NotFollowingUser": "フォロワーではないユーザー",
  "LikedTweetUser": "ツイートをいいねしているユーザー",
  "NotLikedTweetUser": "ツイートをいいねしていないユーザー",
  "NotFollowingCurrentUser": "すでにフォロー済みのユーザーを非表示",
  "IncludedWordInProfileUser": "文字をプロフィールに含むユーザー",
  "NotIncludedWordInProfileUser":  "文字をプロフィールに含まないユーザー",
  "FollowedUser": "フォローしているユーザー",
  "LikingUser": "いいねしたユーザー",
  "TwitterUserTimeline": "過去のツイートをいいね/リツイートが多い順に取得"
}

const MainConditionGridItem = ({ main_conditions }) => {
  return (
    <Grid item xs={12} sm={6}>
      <Paper
        sx={{
          p: 2, height: "100%",
          "@media screen and (min-width:600px)": { mr: 2 }
        }}
      >
        <Typography variant="h3">
          メイン条件<Typography variant="span" sx={{ ml: 1 }}>(いずれかを満たす)</Typography>
        </Typography>

        <Box mt={2}>
          {
            main_conditions.map((condition, i) => {
              const displayNumOfDays = ["LikedTweetUser", "NotLikedTweetUser", "LikingUser", "TwitterUserTimeline"].includes(condition.type)

              return (
                <Typography variant="p" key={`main-condition-${i}`}>
                  ・<Link href={condition.content} target="_blank" rel="noopener">{condition.content}</Link>
                  の
                  {conditionTypeJa[condition.type]}
                  { displayNumOfDays && !!condition.num_of_days && `（直近${condition.num_of_days}日のツイート）`}
                </Typography>
              )
            })
          }
        </Box>
      </Paper>
    </Grid>
  )
}

const NarrowConditionGridItem = ({ narrow_conditions }) => {
  return (
    <Grid item xs={12} sm={6}>
      <Paper
        sx={{
          p: 2, height: "100%", mt: 2,
          "@media screen and (min-width:600px)": { ml: 2, mt: 0 },
        }}
      >
        <Typography variant="h3">
          絞り込み条件<Typography variant="span" sx={{ ml: 1 }}>(すべてを満たす)</Typography>
        </Typography>
        <Box mt={2}>
          {
            narrow_conditions.map((condition, i) => {
              const displayNumOfDays = ["LikedTweetUser", "NotLikedTweetUser", "LikingUser", "TwitterUserTimeline"].includes(condition.type)
              const notLink = ["NotFollowingCurrentUser", "IncludedWordInProfileUser", "NotIncludedWordInProfileUser"].includes(condition.type)

              return (
                <Typography variant="p" key={`narrow-condition-${i}`}>
                  {
                    notLink ?
                      condition.content :
                      <Link href={condition.content} target="_blank" rel="noopener">{condition.content}</Link>
                  }
                  の
                  {conditionTypeJa[condition.type]}
                  { displayNumOfDays && !!condition.num_of_days && `（直近${condition.num_of_days}日のツイート）`}
                </Typography>
              )
            })
          }
        </Box>
      </Paper>
    </Grid>
  )
}

const ShowResultContainer = ({ jsonData, pageIndex, setPageIndex, authUrl, searchProcessId }) => {
  if (!Object.keys(jsonData).length) return <></>

  const process = jsonData.process
  return (
    <><ThemeProvider theme={theme}>
      <Grid container>
        <MainConditionGridItem  main_conditions={jsonData.main_conditions} />
        {/* <Grid item xs={2} /> */}
        <NarrowConditionGridItem narrow_conditions={jsonData.narrowing_conditions} />
      </Grid>

      <Typography id="result-top" variant="h3" mt={3} mb={3}>結果</Typography>

      <Box mb={5}>
        <Box ml={2}>
          <Typography variant="p">取得した情報が、随時掲載されます。</Typography>
          <Typography variant="p">一定時間経過後に、再度画面を更新してください。</Typography>
          <Typography variant="p">
            <Typography variant="span">※ ユーザー検索の場合、ツイートを非表示にしているアカウント（鍵アカウント）は、検索結果に含まれません。</Typography>
          </Typography>
          <Typography variant="p">
            <Typography variant="span">※ ダウンロードしたCSVの文字コードは Shift_JIS となります。</Typography>
          </Typography>

        </Box>
      </Box>

      <Box mb={3}>
        <Typography variant="p">
          進行状況: {(process.status === "will_finish") ? "中断処理を実行中です..." :
                    (process.progress_rate === 100) ? `取得完了${!!process.error_message ? `(${process.error_message})` : ""}` : "現在取得中..." } /
          表示数: {jsonData.results.length} /
          ヒット数: {jsonData.total_count}
          {
            (process.status != "will_finish") &&
              (process.progress_rate === 100 ?
                ( !!jsonData.results.length &&
                  <Typography variant="span" sx={{ ml: 2 }}>
                    <Link href={`/twitter_search_processes/${searchProcessId}.csv`} sx={{ cursor: "pointer" }}>
                      (csvをダウンロード)
                    </Link>
                  </Typography>
                )
              :
                <a data-method='put' href={`/twitter_search_processes/${process.id}`}>
                  <Typography variant="span" sx={{ ml: 2 }}>
                    (処理を中断する)
                  </Typography>
                </a>)
          }
        </Typography>
      </Box>

      {
        !!process.error_class &&
        <Box mt={4}>
            <Typography variant="p">
              取得に失敗しました（エラーメッセージ: {process.error_message}）
            </Typography>
            {
              (process.error_class == "TwitterApiClient::UnAuthorizedError") &&
                <Typography variant="p" my={2}>
                  <Link href={authUrl} rel="noopener">
                    <Button variant="contained">再度認証する</Button>
                  </Link>
                </Typography>
            }
          </Box>
      }

      {
        (process.process_type === "user") &&
          <ShowUsersContainer
            results={jsonData.results}
          />
      }
      {
        (process.process_type === "tweet") &&
          <ShowTweetsContainer
            results={jsonData.results}
            // ツイート検索は、単一のユーザーしか指定できない かつ メイン条件しか存在しないためこのような方法でuser_idが取れる
            userId={
              (() => {
                const id = jsonData.main_conditions[0].content.trim().replace(/^.*https:\/\/(.*\.)?twitter.com\//, "").replace(/(\?.*)?$/, "").replace(/^([^\/]+)\/?.*/, "$1")

                return id
              })()
            }
          />
      }

      <Grid container spacing={3} mt={1}>
        <Grid item xs={6} sx={{ textAlign: "right" }}>
          {
            (pageIndex > 1) &&
              <Button onClick={() => {
                setPageIndex(pageIndex - 1)
                document.getElementById("result-top").scrollIntoView({behavior: 'smooth'})
              }}>戻る</Button>
          }
        </Grid>

        <Grid item xs={6}>
          {
            (pageIndex < jsonData.total_count / 100) &&
              <Button onClick={() => {
                setPageIndex(pageIndex + 1)
                document.getElementById("result-top").scrollIntoView({behavior: 'smooth'})
              }}>次へ</Button>
          }
        </Grid>
      </Grid>
    </ThemeProvider></>
 )
}

export default ShowResultContainer