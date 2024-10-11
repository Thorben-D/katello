import React from 'react';
import { Card, CardTitle, CardBody, CardFooter } from '@patternfly/react-core';

const SyncStatusCard = () => {
  const a = 2;
  return (
    <Card isFullHeight>
      <CardTitle>SyncStatusCard</CardTitle>
      <CardBody>Body</CardBody>
      <CardFooter>Footer</CardFooter>
    </Card>
  );
};

export default SyncStatusCard;
