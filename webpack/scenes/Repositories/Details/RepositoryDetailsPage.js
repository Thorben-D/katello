import React from 'react';
import { useAPI } from 'foremanReact/common/hooks/API/APIHooks';
import { STATUS } from 'foremanReact/constants';
import { useParams } from 'react-router-dom';
import { translate as __ } from 'foremanReact/common/I18n';
import { Grid, GridItem, TextContent, Text, TextVariants, EmptyState, EmptyStateIcon, Spinner, Title } from '@patternfly/react-core';
import RepositoryDetails from './RepositoryDetails';


const RepositoryDetailsPage = () => {
  const { repository_id: repositoryId } = useParams();

  const { response, status } = useAPI('get', `/katello/api/v2/repositories/${repositoryId}`);

  if (status === STATUS.RESOLVED) {
    return (
      <>
        <Grid className="margin-24">
          <GridItem span={12}>
            <TextContent>
              <Text ouiaId="rdPageHeaderText" component={TextVariants.h1}>{__('Repository details')}</Text>
            </TextContent>
          </GridItem>
        </Grid>
        <Grid>
          <GridItem span={12}>
            <RepositoryDetails response={response} />
          </GridItem>
        </Grid>
      </>
    );
  } else if (status === STATUS.ERROR) {
    // TODO: Handle error
  }
  return (
    <EmptyState>
      <EmptyStateIcon variant="container" component={Spinner} />
      <Title ouiaId="repositoryDetailsLoadingTitle" size="lg" headingLevel="h4">
        Loading
      </Title>
    </EmptyState>
  );
};

export default RepositoryDetailsPage;
