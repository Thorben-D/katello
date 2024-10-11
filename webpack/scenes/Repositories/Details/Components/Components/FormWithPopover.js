import React from 'react';
import PropTypes from 'prop-types';
import { Form, FormGroup, TextInput, Popover } from '@patternfly/react-core';
import HelpIcon from '@patternfly/react-icons/dist/esm/icons/help-icon';

const FormWithPopover = props => (
  <Form>
    <FormGroup
      label={props.label}
      labelIcon={props.popoverContent &&
        <Popover
          bodyContent={props.popoverContent}
        >
          <button
            type="button"
            aria-label={`${props.attribute}_popover`}
            onClick={e => e.preventDefault()}
            className="pf-c-form__group-label-help"
          >
            <HelpIcon noVerticalAlign />
          </button>
        </Popover>
}
      fieldId={props.attribute}
    >
      {props.textInput || <TextInput
        isDisabled
        type="text"
        id="simple-form-name-01"
        name="simple-form-name-01"
        aria-describedby="simple-form-name-01-helper"
        ouiaId={`${props.attribute}_default_input`}
        value={props.displayValue}
      />}
    </FormGroup>

  </Form>
);


FormWithPopover.propTypes = {
  attribute: PropTypes.string.isRequired,
  popoverContent: PropTypes.string,
  textInput: PropTypes.node,
  displayValue: PropTypes.string,
  label: PropTypes.string.isRequired,
};

export default FormWithPopover;
