import * as React from 'react';
import API from "../lib/api";
import Grid from '@mui/material/Grid';
import Paper from '@mui/material/Paper';

import Dashboard from '../components/dashboard/Dashboard';



const TwitterSearchProcessesShow = ({ dataset: { authToken, searchProcessId, authUrl } }) => {
  const [jsonData, setJsonData] = React.useState({});
  const [pageIndex, setPageIndex] = React.useState(1);

  React.useEffect(() => {
    API.get(`/twitter_search_processes/${searchProcessId}/json_data?page=${pageIndex}`)
      .then((response) => {
        setJsonData(response.data);
      });
  }, [pageIndex]);

  return (
    <>
      <Dashboard
        title='Search Page'
        authToken={authToken}
        specifiedPage='show-result'
        jsonData={jsonData}
        pageIndex={pageIndex}
        setPageIndex={setPageIndex}
        authUrl={authUrl}
      />
    </>
  );
};

export default TwitterSearchProcessesShow
