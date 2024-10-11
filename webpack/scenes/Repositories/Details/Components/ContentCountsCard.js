import React from 'react';
import { Card, CardTitle, CardBody, CardFooter } from '@patternfly/react-core';

const ContentCountsCard = () => {
  const a = 2;
  return (
    <Card isFullHeight>
      <CardTitle>ContentCountsCard</CardTitle>
      <CardBody>Body</CardBody>
      <CardFooter>Footer</CardFooter>
    </Card>
  );
};

export default ContentCountsCard;
