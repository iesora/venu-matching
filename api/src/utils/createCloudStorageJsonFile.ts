import * as fs from 'fs';
import { APP_DIRNAME } from 'src/var';

export const createCloudStorageJsonFile = () => {
  if (!fs.existsSync(APP_DIRNAME + 'cloud_storage.json')) {
    const cloud_storage_settings = {
      type: process.env.CLOUD_STORAGE_TYPE,
      project_id: process.env.CLOUD_STORAGE_PROJECT_ID,
      private_key_id: process.env.CLOUD_STORAGE_PRIVATE_KEY_ID,
      private_key: process.env.CLOUD_STORAGE_PRIVATE_KEY.replace(/\\n/g, '\n'),
      client_email: process.env.CLOUD_STORAGE_CLIENT_EMAIL,
      client_id: process.env.CLOUD_STORAGE_CLIENT_ID,
      auth_uri: process.env.CLOUD_STORAGE_AUTH_URL,
      token_uri: process.env.CLOUD_STORAGE_TOKEN_URI,
      auth_provider_x509_cert_url:
        process.env.CLOUD_STORAGE_AUTH_PROVIDER_X509_CERT_URL,
      client_x509_cert_url: process.env.CLOUD_STORAGE_CLIENT_X509_CERT_URL,
    };
    const jsonEncoded = JSON.stringify(cloud_storage_settings);
    fs.writeFile(APP_DIRNAME + '/cloud_storage.json', jsonEncoded, (err) => {
      if (err) {
        console.log(err);
      }
    });
  }
};
