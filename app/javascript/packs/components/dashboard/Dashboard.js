import * as React from 'react';
import { styled, createTheme, ThemeProvider } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import MuiDrawer from '@mui/material/Drawer';
import Box from '@mui/material/Box';
import MuiAppBar from '@mui/material/AppBar';
import Toolbar from '@mui/material/Toolbar';
import List from '@mui/material/List';
import Typography from '@mui/material/Typography';
import Divider from '@mui/material/Divider';
import IconButton from '@mui/material/IconButton';
import Button from '@mui/material/Button';
import Container from '@mui/material/Container';
import Link from '@mui/material/Link';
import MenuIcon from '@mui/icons-material/Menu';
import ChevronLeftIcon from '@mui/icons-material/ChevronLeft';

import SearchTweetsContainer from '../SearchTweetsContainer';
import SearchUsersContainer from '../SearchUsersContainer';
import ShowResultContainer from '../ShowResultContainer';

import { MainListItems, secondaryListItems } from './listItems';

function Copyright(props) {
  return (
    <Typography variant="body2" color="text.secondary" align="center" {...props}>
      {'Copyright © '}
      <Link color="inherit" href="https://twitter-searcher.onrender.com">
        twitter-searcher
      </Link>{' '}
      {new Date().getFullYear()}
      {'.'}
    </Typography>
  );
}

const drawerWidth = 240;

const AppBar = styled(MuiAppBar, {
  shouldForwardProp: (prop) => prop !== 'open',
})(({ theme, open }) => ({
  zIndex: theme.zIndex.drawer + 1,
  transition: theme.transitions.create(['width', 'margin'], {
    easing: theme.transitions.easing.sharp,
    duration: theme.transitions.duration.leavingScreen,
  }),
  ...(open && {
    marginLeft: drawerWidth,
    width: `calc(100% - ${drawerWidth}px)`,
    transition: theme.transitions.create(['width', 'margin'], {
      easing: theme.transitions.easing.sharp,
      duration: theme.transitions.duration.enteringScreen,
    }),
  }),
}));

const Drawer = styled(MuiDrawer, { shouldForwardProp: (prop) => prop !== 'open' })(
  ({ theme, open }) => ({
    '& .MuiDrawer-paper': {
      position: 'relative',
      whiteSpace: 'nowrap',
      width: drawerWidth,
      transition: theme.transitions.create('width', {
        easing: theme.transitions.easing.sharp,
        duration: theme.transitions.duration.enteringScreen,
      }),
      boxSizing: 'border-box',
      ...(!open && {
        overflowX: 'hidden',
        transition: theme.transitions.create('width', {
          easing: theme.transitions.easing.sharp,
          duration: theme.transitions.duration.leavingScreen,
        }),
        width: theme.spacing(7),
        [theme.breakpoints.up('sm')]: {
          width: theme.spacing(9),
        },
      }),
    },
  }),
);

const mdTheme = createTheme();

function DashboardContent(
  { title, authToken, specifiedPage, jsonData, pageIndex, setPageIndex, authUrl, activeProcessId,
    needAuth, searchProcessId }
) {
  const [open, setOpen] = React.useState(false);
  const [pageContainer, setPageContainer] = React.useState(specifiedPage || "search-users");
  const [inProgress, setInProgress] = React.useState(!!activeProcessId);

  if (inProgress) {
    console.log("progress")
    setTimeout(() => window.location.reload(), 30000);
  }

  const toggleDrawer = () => {
    setOpen(!open);
  };

  const page = (() => {
    if (JSON.parse(needAuth)) {
      return <Box>
        使用するには<Link href={authUrl}>認証</Link>してください
      </Box>
    }

    switch (pageContainer) {
      case "search-tweets":
        return <SearchTweetsContainer authToken={authToken} inProgress={inProgress} setInProgress={setInProgress} activeProcessId={activeProcessId} />
      case "search-users":
        return <SearchUsersContainer authToken={authToken} inProgress={inProgress} setInProgress={setInProgress} activeProcessId={activeProcessId} />
      case "show-result":
        return <ShowResultContainer jsonData={jsonData} pageIndex={pageIndex} setPageIndex={setPageIndex} authUrl={authUrl} searchProcessId={searchProcessId} />
    }
  })()

  return (
    <ThemeProvider theme={mdTheme}>
      <Box sx={{ display: 'flex' }}>
        <CssBaseline />
        <AppBar position="absolute" open={open}>
          <Toolbar
            sx={{
              pr: '24px', // keep right padding when drawer closed
            }}
          >
            <IconButton
              edge="start"
              color="inherit"
              aria-label="open drawer"
              onClick={toggleDrawer}
              sx={{
                marginRight: '36px',
                ...(open && { display: 'none' }),
              }}
            >
              <MenuIcon />
            </IconButton>
            <Typography
              component="h1"
              variant="h6"
              color="inherit"
              noWrap
              sx={{ flexGrow: 1 }}
            >
              {title}
            </Typography>
          </Toolbar>
        </AppBar>
        <Drawer variant="permanent" open={open}>
          <Toolbar
            sx={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'flex-end',
              px: [1],
            }}
          >
            <IconButton onClick={toggleDrawer}>
              <ChevronLeftIcon />
            </IconButton>
          </Toolbar>
          <Divider />
          <List component="nav">
            <MainListItems setPageContainer={setPageContainer} />
            <Divider sx={{ my: 1 }} />
            {secondaryListItems}
          </List>
        </Drawer>
        <Box
          component="main"
          sx={{
            backgroundColor: (theme) =>
              theme.palette.mode === 'light'
                ? theme.palette.grey[100]
                : theme.palette.grey[900],
            flexGrow: 1,
            height: '100vh',
            overflow: 'auto',
          }}
        >
          <Toolbar />
          <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
            {
              (!!specifiedPage && (pageContainer != specifiedPage)) &&
              <Button
                variant="outlined"
                sx={{ mt: 3, mb: 2 }}
                onClick={() => setPageContainer(specifiedPage)}
              >
                戻る
              </Button>
            }

            {page}
            <Copyright sx={{ pt: 4 }} />
          </Container>
        </Box>
      </Box>
    </ThemeProvider>
  );
}

export default function Dashboard(
  { title, authToken, specifiedPage, jsonData, pageIndex, setPageIndex, authUrl, activeProcessId,
    needAuth, searchProcessId }
) {
  return (
    <DashboardContent
      title={title}
      authToken={authToken}
      specifiedPage={specifiedPage}
      jsonData={jsonData}
      pageIndex={pageIndex}
      setPageIndex={setPageIndex}
      authUrl={authUrl}
      activeProcessId={activeProcessId}
      needAuth={needAuth}
      searchProcessId={searchProcessId}
    />
  )
}
