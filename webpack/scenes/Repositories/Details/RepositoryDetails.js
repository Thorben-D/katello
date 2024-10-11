import React from 'react';
import { Grid, GridItem } from '@patternfly/react-core';
import BasicInfoCard from './Components/BasicInfoCard';
import PublishingSettingsCard from './Components/PublishingSettingsCard';
import SyncSettingsCard from './Components/SyncSettingsCard';
import SyncStatusCard from './Components/SyncStatusCard';
import ContentCountsCard from './Components/ContentCountsCard';
import DistributionInfoCard from './Components/DistributionInfoCard';

const RepositoryDetails = (props) => (
  <Grid hasGutter>
    <GridItem span={4} rowSpan={3}><BasicInfoCard response={props.response} /></GridItem>
    <GridItem span={4} rowSpan={6} ><SyncSettingsCard /></GridItem>
    <GridItem span={4}><SyncStatusCard /></GridItem>
    <GridItem span={4} rowSpan={3}><ContentCountsCard /></GridItem>
    <GridItem span={4} rowSpan={3}><PublishingSettingsCard /></GridItem>
    <GridItem span={4} rowSpan={2}><DistributionInfoCard /></GridItem>
  </Grid>
);

export default RepositoryDetails;
