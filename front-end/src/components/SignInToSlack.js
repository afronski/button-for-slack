import React, { Component } from "react";

import { Auth } from 'aws-amplify';

import settings from "../settings";

class SignInToSlack extends Component {

  constructor(props) {
    super(props);

    this.state = {
      user: null
    };
  }

  async componentDidMount() {
    const user = await Auth.currentAuthenticatedUser();

    this.setState({ user });
  }

  render() {
    if (this.state.user) {
      const url = window.location;
      const state = btoa(`${this.state.user.username};${url}`);

      return (
        <a href={`https://slack.com/oauth/authorize?scope=identity.basic,identity.email,identity.team,identity.avatar&client_id=${settings.client_id}&state=${state}`}>
          <img alt="Sign in with Slack" height="40" width="172" src="https://platform.slack-edge.com/img/sign_in_with_slack.png" srcSet="https://platform.slack-edge.com/img/sign_in_with_slack.png 1x, https://platform.slack-edge.com/img/sign_in_with_slack@2x.png 2x" />
        </a>
      );
    } else {
      return <span></span>;
    }
  }
}

export default SignInToSlack;
