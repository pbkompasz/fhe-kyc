import { useEffect, useRef, useState } from 'react';
import Webcam from 'react-webcam';
import { Devnet } from './components/Devnet';
import { init } from './fhevmjs';
import './App.css';
import { Connect } from './components/Connect';
import { NATIONALITIES } from './constants.ts';

type Nationality = {
  id: string;
  country: string;
  nationality: string;
};

function App() {
  const providers = [
    {
      id: 'bsky',
      name: 'BlueSky',
      isAuthenticated: false,
      isSponsored: true,
    },
  ];

  const fileInputRef = useRef();

  const handleChange = (event) => {
    console.log(event);
    // do something with event data
  };

  const webcamRef = useRef(null);

  const capture = () => {
    const imageSrc = webcamRef.current.getScreenshot();
    console.log(imageSrc); // Send this to the backend for verification
  };

  return (
    <>
      <h1>KYC</h1>
      <p>Prove your identity(this may incurre extra costs)</p>
      <Connect>
        {(account, provider) => (
          <Devnet account={account} provider={provider} />
        )}
      </Connect>
      <p>- OR -</p>
      <p>Prove your identity for a platform</p>
      <div style={{ border: '1px solid grey', padding: '1rem' }}>
        {providers.map((provider) => (
          <div
            key={provider.id}
            style={{
              backgroundColor: 'grey',
              padding: '0.5rem',
              borderRadius: '10px',
            }}
          >
            {provider.isAuthenticated ? (
              <button>Submit data</button>
            ) : (
              <button className="read-the-docs">
                Sign in w/ {provider.name}
              </button>
            )}
            {provider.isSponsored && (
              <p>This provider can sponsor the process</p>
            )}
          </div>
        ))}
      </div>
      <div>
        <h2>Basic identity verification</h2>- Full name, - date of birth -
        gender - nationality - Twitter(currently X) profile verification
        <div>
          <label htmlFor="fname">First name:</label>
          <input type="text" id="fname" name="fname" />
        </div>
        <div>
          <label htmlFor="lname">Last name:</label>
          <input type="text" id="lname" name="lname" />
        </div>
        <div>
          <label htmlFor="nationality">Nationality:</label>
          <select name="nationality" id="nationality">
            <option value="">--Please choose an option--</option>
            {NATIONALITIES.map((nationality: Nationality) => (
              <option key={nationality.id} value={nationality.id}>
                {nationality.nationality}
              </option>
            ))}
          </select>
        </div>
        <div>
          <label htmlFor="start">Date of birth:</label>
          <input
            type="date"
            id="start"
            name="trip-start"
            value="2018-07-22"
            min="2018-01-01"
            max="2018-12-31"
          />
        </div>
        <h2>Identity Proof w/ Government-Issued ID</h2>
        <div>
          {/* NOTE This will only extract data from image */}
          <button onClick={() => fileInputRef.current.click()}>
            Upload your id
          </button>
          <input
            onChange={handleChange}
            multiple={false}
            ref={fileInputRef}
            type="file"
            hidden
          />
        </div>
        {/* NOTE Display not available yet */}
        <div>
          <button disabled>Scan your passport or ID</button>
        </div>
        <h2>Selfie Verification</h2>
        <div>
          <Webcam audio={false} ref={webcamRef} screenshotFormat="image/jpeg" />
          <button onClick={capture}>Capture Selfie</button>
        </div>
      </div>
    </>
  );
}

export default App;
