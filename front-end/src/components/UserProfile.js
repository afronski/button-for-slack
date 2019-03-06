import React, { Component } from "react";

import AceEditor from 'react-ace';

import 'brace/mode/javascript';
import 'brace/theme/solarized_light';

import AmplifyTheme from "aws-amplify-react/dist/Amplify-UI/Amplify-UI-Theme";
import { Button, Toast } from "aws-amplify-react/dist/Amplify-UI/Amplify-UI-Components-React";

import { externalRequestWithAuthAndCORS, externalRequestWithAuthAndCORSAndBody } from "../utils/helpers";

import "./UserProfile.css";

class UserProfile extends Component {
  constructor(props) {
    super(props);

    this.state = {
      error: null,
      isLoaded: false,
      profile: null,
      content: null
    };
  }

  getUrl() {
    return `${this.props.url}/users`;
  }

  async componentDidMount() {
    fetch(this.getUrl(), await externalRequestWithAuthAndCORS("GET"))
      .then(response => response.json())
      .then(
        (result) => {
          if (result.message) {
            this.setState({
              isLoaded: true,
              error: result
            });
          } else {
            this.setState({
              isLoaded: true,
              profile: JSON.stringify(result, null, 4)
            });
          }
        },

        (error) => {
          this.setState({
            isLoaded: true,
            error
          });
        }
      )
  }

  async update() {
    const { profile } = this.state;

    if (profile) {
      fetch(this.getUrl(), await externalRequestWithAuthAndCORSAndBody("PUT", profile))
        .then(response => response.json())
        .then(
          (result) => {
            if (result.message) {
              this.setState({
                error: result
              });
            } else {
              this.setState({
                profile: profile
              });
            }
          },

          (error) => {
            this.setState({
              error
            });
          }
        )
    }
  }

  render() {
    const theme = this.props.theme || AmplifyTheme;
    const { error, isLoaded, profile } = this.state;

    if (!isLoaded) {
      return (
        <div className="UserProfile">
          <h2>Loading...</h2>
        </div>
      );
    } else {
      return (
        <div className="UserProfile">
          {error &&
            <Toast theme={theme} onClose={() => this.setState({error: null})}>
              {`Error: ${error.message} at getting user profile`}
            </Toast>
          }

          <AceEditor
            mode="javascript"
            theme="solarized_light"
            value={profile}
            name="profile-editor"
            maxLines={15}
            onChange={(profile) => this.setState({ profile })}
            editorProps={{$blockScrolling: true}}
            readOnly={false}
          />

          <Button onClick={() => this.update()}>Update</Button>
        </div>
      );
    }
  }
}

export default UserProfile;
