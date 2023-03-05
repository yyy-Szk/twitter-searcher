import * as React from 'react';
import SignIn from '../components/SignIn'

const SessionsNew = ({ dataset }) => {
  return (
    <>
      <SignIn authToken={dataset.authToken} />
    </>
  );
};

export default SessionsNew;
