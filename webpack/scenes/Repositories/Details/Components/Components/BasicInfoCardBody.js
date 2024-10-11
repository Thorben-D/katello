import React from 'react';
import EditableTextInput from '../../../../../components/EditableTextInput';
import FormWithPopover from './FormWithPopover';

const BasicInfoCardBody = (props) => {
  const a = '';
  // TODO: Add API actions

  return (
    <>
      <FormWithPopover label="Name" attribute="basic_info_name" textInput={<EditableTextInput onEdit={() => {}} attribute="basic_info_name" value={props.response.name} />} />
      <FormWithPopover label="Label" attribute="basic_info_label" displayValue={props.response.label} />
      <FormWithPopover label="Description" attribute="basic_info_desc" textInput={<EditableTextInput onEdit={() => {}} attribute="basic_info_desc" value={props.response.description} />} />
      <FormWithPopover label="Backend Identifier" attribute="basic_info_be" displayValue={props.response.backend_identifier} />
      <FormWithPopover label="Type" attribute="basic_info_type" displayValue={props.response.type} />
    </>
  );
};

export default BasicInfoCardBody;
