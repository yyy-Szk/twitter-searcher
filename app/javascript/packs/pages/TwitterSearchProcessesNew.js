import * as React from 'react';

import Dashboard from '../components/dashboard/Dashboard';

const TwitterSearchProcessesNew = ({ dataset: { authToken, activeProcessId, needAuth, authUrl } }) => {
  return (
    <>
      <Dashboard
        title='Search Page'
        authToken={authToken}
        activeProcessId={activeProcessId}
        needAuth={needAuth}
        authUrl={authUrl}
      />
    </>
  );
};

export default TwitterSearchProcessesNew
