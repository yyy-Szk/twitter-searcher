import * as React from 'react';
import InputBase from '@mui/material/InputBase';

export default function AuthenticityTokenInput({ authToken }) {
  return (
    <>
      <InputBase type="hidden" name="authenticity_token" value={authToken} />
    </>
 )
}