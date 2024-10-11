import React from 'react';
import { Card, CardTitle, CardBody } from '@patternfly/react-core';
import BasicInfoCardBody from './Components/BasicInfoCardBody';

const BasicInfoCard = (props) => {
  const a = 2;
  return (
    <Card ouiaId="RepoInfoBasicInfoCard" isFullHeight>
      <CardTitle>Basic Information</CardTitle>
      <CardBody><BasicInfoCardBody response={props.response}/></CardBody>
    </Card>
  );
};

export default BasicInfoCard;
