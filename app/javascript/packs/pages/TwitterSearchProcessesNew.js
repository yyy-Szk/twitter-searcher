import * as React from 'react';

import Dashboard from '../components/dashboard/Dashboard';

const TwitterSearchProcessesNew = ({ dataset: { authToken } }) => {
  return (
    <>
      <Dashboard
        title='Search Page'
        authToken={authToken}
      />
    </>
  );
};

export default TwitterSearchProcessesNew
