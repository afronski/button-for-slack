import { Auth } from 'aws-amplify';

export async function externalRequestWithAuthAndCORS(method) {
  const data = await Auth.currentSession();

  return {
    method,
    headers: {
      "Authorization": data.idToken.jwtToken
    }
  };
};

export async function externalRequestWithAuthAndCORSAndBody(method, body) {
  const data = await Auth.currentSession();

  return {
    method,
    body,
    headers: {
      "Content-Type": "application/json",
      "Authorization": data.idToken.jwtToken
    }
  };
};
