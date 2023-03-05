import * as React from 'react';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import ListSubheader from '@mui/material/ListSubheader';
import PersonIcon from '@mui/icons-material/Person';
import LogoutIcon from '@mui/icons-material/Logout';
import TextsmsIcon from '@mui/icons-material/Textsms';

export const MainListItems = ({ setPageContainer }) => {
  return  (
    <>
      <ListItemButton onClick={() => setPageContainer("search-users")}>
        <ListItemIcon>
          <PersonIcon />
        </ListItemIcon>
        <ListItemText primary="Search users" />
      </ListItemButton>
      <ListItemButton onClick={() => setPageContainer("search-tweets")}>
        <ListItemIcon>
          <TextsmsIcon />
        </ListItemIcon>
        <ListItemText primary="Search tweets" />
      </ListItemButton>
    </>
  )
}

export const secondaryListItems = (
  <>
    {/* <ListSubheader component="div" inset>
      Setting
    </ListSubheader> */}
    <ListItemButton onClick={() => document.getElementById('submit-logout').click()}>
      <ListItemIcon>
        <LogoutIcon />
      </ListItemIcon>
      <ListItemText primary="Sign out" />
      <a id='submit-logout' data-method='delete' href='/logout'></a> 
    </ListItemButton>
  </>
);
